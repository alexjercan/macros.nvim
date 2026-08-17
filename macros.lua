#!/usr/bin/env lua

local VERSION = "0.1.0"

local script_path = arg[0]:match("(.*/)")
if script_path then
    package.path = script_path .. "lua/?.lua;" .. package.path
else
    package.path = "./lua/?.lua;" .. package.path
end

_G.vim = {
    trim = function(s)
        return s:match("^%s*(.-)%s*$")
    end,
    split = function(s, sep, opts)
        opts = opts or {}
        local parts = {}
        if opts.plain == false then
            for part in s:gmatch("[^" .. sep:gsub("%s+", "%%s+") .. "]+") do
                if opts.trimempty ~= true or part ~= "" then
                    table.insert(parts, part)
                end
            end
        else
            local last_end = 1
            local s_start, s_end = s:find(sep, 1, true)
            while s_start do
                local part = s:sub(last_end, s_start - 1)
                if opts.trimempty ~= true or part ~= "" then
                    table.insert(parts, part)
                end
                last_end = s_end + 1
                s_start, s_end = s:find(sep, last_end, true)
            end
            local last_part = s:sub(last_end)
            if opts.trimempty ~= true or last_part ~= "" then
                table.insert(parts, last_part)
            end
        end
        return parts
    end,
    startswith = function(s, prefix)
        return s:sub(1, #prefix) == prefix
    end,
    fn = {
        stdpath = function()
            return os.getenv("HOME") .. "/.local/share/nvim"
        end,
    },
    notify = function(msg)
        io.stderr:write(msg .. "\n")
    end,
    log = { levels = { WARN = 2, ERROR = 4 } },
}

local Database = require("macros.database")
local FoodItem = require("macros.fooditem")

local function usage()
    print([[
macros - Food macro lookup tool

USAGE:
    macros [--database PATH] search QUERY [--json]
    macros [--database PATH] calculate --food ID --amount NUMBER [--json]
    macros [--database PATH] insert ROW

OPTIONS:
    --database PATH     Food database. Defaults to MACROS_DATABASE, then Neovim data.
    --json              Emit stable JSON for search and calculation.
    -h, --help          Show this help message.
    -v, --version       Show version information.
]])
end

local function fail(message)
    io.stderr:write("Error: " .. message .. "\n")
    os.exit(1)
end

local function json_string(value)
    return '"'
        .. value:gsub('[\\"%z\1-\31]', function(char)
            local escapes = {
                ["\\"] = "\\\\",
                ['"'] = '\\"',
                ["\b"] = "\\b",
                ["\f"] = "\\f",
                ["\n"] = "\\n",
                ["\r"] = "\\r",
                ["\t"] = "\\t",
            }
            return escapes[char] or string.format("\\u%04x", char:byte())
        end)
        .. '"'
end

local function json_number(value)
    if value ~= value or value == math.huge or value == -math.huge then
        error("Cannot encode a non-finite number")
    end
    return string.format("%.15g", value)
end

local database_path = os.getenv("MACROS_DATABASE")
    or (vim.fn.stdpath("data") .. "/macros.csv")
local json = false
local positionals = {}
local options = {}
local i = 1
while i <= #arg do
    local value = arg[i]
    if value == "-h" or value == "--help" then
        usage()
        os.exit(0)
    elseif value == "-v" or value == "--version" then
        print("macros version " .. VERSION)
        os.exit(0)
    elseif value == "--json" then
        json = true
    elseif value == "--database" then
        i = i + 1
        database_path = arg[i] or fail("--database requires a path")
    elseif value == "--food" or value == "--amount" then
        i = i + 1
        options[value] = arg[i] or fail(value .. " requires a value")
    elseif value:sub(1, 1) == "-" then
        fail("Unknown option: " .. value)
    else
        table.insert(positionals, value)
    end
    i = i + 1
end

local command = table.remove(positionals, 1)
if command == nil then
    usage()
    os.exit(1)
end

local function load_database()
    local db = Database:new()
    db:load(database_path)
    return db
end

local ok, result = pcall(function()
    if command == "search" then
        local query = table.concat(positionals, " ")
        if query == "" then
            error("search requires a query")
        end
        local results = load_database():search(query)
        if json then
            local encoded = {}
            for _, candidate in ipairs(results) do
                table.insert(
                    encoded,
                    '{"id":'
                        .. json_string(candidate.id)
                        .. ',"name":'
                        .. json_string(candidate.name)
                        .. ',"unit":'
                        .. json_string(candidate.unit)
                        .. "}"
                )
            end
            return '{"results":[' .. table.concat(encoded, ",") .. "]}"
        end
        local lines = {}
        for _, candidate in ipairs(results) do
            table.insert(lines, candidate.name .. " " .. candidate.unit)
        end
        return table.concat(lines, "\n")
    elseif command == "calculate" then
        if #positionals > 0 then
            error("calculate accepts only --food and --amount")
        end
        local id = options["--food"] or error("calculate requires --food")
        local amount = tonumber(options["--amount"])
        if amount == nil then
            error("calculate requires a numeric --amount")
        end
        local item = load_database():calculate(id, amount)
        if json then
            return '{"food":'
                .. json_string(item.food.name)
                .. ',"amount":'
                .. json_number(item.food.amount)
                .. ',"unit":'
                .. json_string(tostring(item.food.unit))
                .. ',"protein":'
                .. json_number(item.macro.protein)
                .. ',"carbs":'
                .. json_number(item.macro.carbs)
                .. ',"fat":'
                .. json_number(item.macro.fat)
                .. "}"
        end
        return tostring(item)
    elseif command == "insert" then
        local row = table.concat(positionals, " ")
        if row == "" then
            error("insert requires a food row")
        end
        local item = FoodItem.from(row)
        local file = assert(io.open(database_path, "a"))
        file:write(tostring(item) .. "\n")
        file:close()
        return tostring(item)
    else
        error("Unknown command: " .. command)
    end
end)

if not ok then
    fail(tostring(result):gsub("^.-:%d+: ", ""))
end
if result ~= "" then
    print(result)
end
