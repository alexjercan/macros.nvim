#!/usr/bin/env lua

-- Standalone CLI tool for looking up food macros
-- Usage: lua macros.lua "egg 2p"
-- Output: egg 2pc,12,0,10

-- Add the lua directory to package path so we can require modules
local script_path = arg[0]:match("(.*/)")
if script_path then
    package.path = script_path .. "lua/?.lua;" .. package.path
else
    package.path = "./lua/?.lua;" .. package.path
end

-- Create a minimal vim API shim for standalone usage
_G.vim = {
    trim = function(s)
        return s:match("^%s*(.-)%s*$")
    end,
    split = function(s, sep, opts)
        opts = opts or {}
        local parts = {}
        if opts.plain == false then
            -- Use pattern matching
            for part in s:gmatch("[^" .. sep:gsub("%s+", "%%s+") .. "]+") do
                if opts.trimempty ~= true or part ~= "" then
                    table.insert(parts, part)
                end
            end
        else
            -- Plain split
            local pattern = "(.-)" .. sep
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
        stdpath = function(what)
            -- For CLI usage, use a standard location
            local home = os.getenv("HOME")
            if what == "data" then
                return home .. "/.local/share/nvim"
            end
            return home .. "/.local/share/nvim"
        end,
    },
    notify = function(msg, level)
        io.stderr:write(msg .. "\n")
    end,
    log = {
        levels = {
            WARN = 2,
            ERROR = 4,
        },
    },
}

-- Load the required modules
local Database = require("macros.database")

-- Get the macros file path
local data_path = vim.fn.stdpath("data")
local macros_path = string.format("%s/macros.csv", data_path)

-- Parse command line arguments
if #arg == 0 then
    io.stderr:write("Usage: " .. arg[0] .. " \"<food item>\"\n")
    io.stderr:write("Example: " .. arg[0] .. " \"egg 2p\"\n")
    io.stderr:write("Output format: egg 2pc,12,0,10\n")
    os.exit(1)
end

-- Combine all arguments into a single food query
local food_query = table.concat(arg, " ")

-- Create database and load data
local db = Database:new()

-- Check if the macros file exists
local file = io.open(macros_path, "r")
if not file then
    io.stderr:write("Error: Macros database not found at " .. macros_path .. "\n")
    io.stderr:write("Please run the plugin in Neovim first to create the database.\n")
    os.exit(1)
end
file:close()

-- Load the database
local ok, err = pcall(function()
    db:load(macros_path)
end)

if not ok then
    io.stderr:write("Error loading database: " .. tostring(err) .. "\n")
    os.exit(1)
end

-- Query the database
local ok, result = pcall(function()
    return db:get(food_query)
end)

if not ok then
    io.stderr:write("Error: " .. tostring(result) .. "\n")
    os.exit(1)
end

-- Output the result in CSV format
print(tostring(result))
