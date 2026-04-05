#!/usr/bin/env lua

-- Standalone CLI tool for looking up food macros
-- Usage: macros "egg 2p"
-- Output: egg 2pc,12,0,10

local VERSION = "0.1.0"

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
local FoodItem = require("macros.fooditem")

-- Get the macros file path
local data_path = vim.fn.stdpath("data")
local macros_path = string.format("%s/macros.csv", data_path)

-- Print usage information
local function print_usage()
    print([[
macros - Food macro lookup tool

USAGE:
    macros [OPTIONS] [FOOD_QUERY]

OPTIONS:
    -h, --help       Show this help message
    -v, --version    Show version information
    -q, --query      Fuzzy search for available foods
    -i, --insert     Add a new food item to the database

EXAMPLES:
    macros "egg 2p"              # Look up 2 pieces of egg
    macros "chicken breast 100g" # Look up 100g of chicken breast
    macros -q "chick"            # Search for foods matching "chick"
    macros -i "banana 100g,1,23,0.3"  # Add banana to database

OUTPUT FORMAT:
    <food> <amount><unit>,<protein>,<carbs>,<fat>
    
    Example: egg 2pc,12,0,10

INSERT FORMAT:
    <food> <amount><unit>,<protein>,<carbs>,<fat>
    
    Example: banana 100g,1,23,0.3
]])
end

-- Print version information
local function print_version()
    print("macros version " .. VERSION)
end

-- Load database
local function load_database()
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
    
    return db
end

-- Query for foods using fuzzy matching
local function query_foods(db, query)
    local results = db:fuzzy_query(query)
    
    if #results == 0 then
        io.stderr:write("No foods found matching: " .. query .. "\n")
        os.exit(1)
    end
    
    print("Foods matching '" .. query .. "':\n")
    for _, food in ipairs(results) do
        print("  " .. food)
    end
end

-- Lookup food macros
local function lookup_food(db, food_query)
    local ok, result = pcall(function()
        return db:get(food_query)
    end)
    
    if not ok then
        io.stderr:write("Error: " .. tostring(result) .. "\n")
        io.stderr:write("\nTip: Use -q to search for available foods\n")
        os.exit(1)
    end
    
    print(tostring(result))
end

-- Insert a new food item
local function insert_food(food_item_str)
    -- Check if macros file exists, create if not
    local file = io.open(macros_path, "a+")
    if not file then
        io.stderr:write("Error: Cannot open macros database at " .. macros_path .. "\n")
        os.exit(1)
    end
    
    -- Parse the food item
    local ok, food_item = pcall(function()
        return FoodItem.from(food_item_str)
    end)
    
    if not ok then
        io.stderr:write("Error parsing food item: " .. tostring(food_item) .. "\n")
        io.stderr:write("\nExpected format: <food> <amount><unit>,<protein>,<carbs>,<fat>\n")
        io.stderr:write("Example: banana 100g,1,23,0.3\n")
        os.exit(1)
    end
    
    -- Write to file
    file:write(tostring(food_item) .. "\n")
    file:close()
    
    print("Successfully added: " .. tostring(food_item))
end

-- Parse command line arguments
if #arg == 0 then
    print_usage()
    os.exit(1)
end

local mode = "lookup"
local query_arg = nil
local food_args = {}

-- Parse flags and arguments
for i = 1, #arg do
    local a = arg[i]
    if a == "-h" or a == "--help" then
        print_usage()
        os.exit(0)
    elseif a == "-v" or a == "--version" then
        print_version()
        os.exit(0)
    elseif a == "-q" or a == "--query" then
        mode = "query"
        -- Collect remaining arguments as query
        for j = i + 1, #arg do
            table.insert(food_args, arg[j])
        end
        break
    elseif a == "-i" or a == "--insert" then
        mode = "insert"
        -- Collect remaining arguments as food item
        for j = i + 1, #arg do
            table.insert(food_args, arg[j])
        end
        break
    else
        table.insert(food_args, a)
    end
end

-- Check if we have arguments for the selected mode
if #food_args == 0 then
    if mode == "query" then
        io.stderr:write("Error: -q/--query requires a search term\n\n")
    elseif mode == "insert" then
        io.stderr:write("Error: -i/--insert requires a food item\n\n")
    else
        io.stderr:write("Error: No food item specified\n\n")
    end
    print_usage()
    os.exit(1)
end

local food_query = table.concat(food_args, " ")

-- Execute the appropriate command
if mode == "insert" then
    insert_food(food_query)
elseif mode == "query" then
    -- Load database for query
    local db = load_database()
    query_foods(db, food_query)
else
    -- Load database for lookup
    local db = load_database()
    lookup_food(db, food_query)
end
