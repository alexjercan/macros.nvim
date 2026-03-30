-- main module file
local Database = require("macros.database")
local FoodItem = require("macros.fooditem")
local Source = require("macros.source")

local data_path = vim.fn.stdpath("data")
local macros_path = string.format("%s/macros.csv", data_path)

---@class Config
---
---@field items table<string>
local DEFAULT_CONFIG = {
    items = {},
}

---@class Macros
local M = {}

---@type Config
M.config = DEFAULT_CONFIG

---@type Database
M.database = Database:new()

local function register_cmp_source()
    local ok, cmp = pcall(require, "cmp")
    if not ok then
        vim.notify(
            "Could not load nvim-cmp, macros completion source will not be available",
            vim.log.levels.WARN
        )
    else
        cmp.register_source("macros", Source:new(M.database))
    end
end

register_cmp_source()

local function validate_config(cfg)
    local ok, err = pcall(vim.validate, {
        items = {
            cfg.items,
            function(v)
                if type(v) ~= "table" then
                    return false
                end
                for _, item in ipairs(v) do
                    if type(item) ~= "string" then
                        return false
                    end
                end
                return true
            end,
            "table of strings",
        },
    })

    if not ok then
        error("macros.nvim config error: " .. err)
    end
end

---Setup the module
---
---@param args Config?
M.setup = function(args)
    args = args or {}
    M.config = vim.tbl_deep_extend("force", M.config, args)

    validate_config(M.config)

    -- create the file if it doesn't exist
    if vim.fn.filereadable(macros_path) == 0 then
        vim.fn.writefile({}, macros_path)
    end

    M.database = Database:new()

    for _, item in ipairs(M.config.items) do
        M.database:add(FoodItem.from(item))
    end
    M.database:load(macros_path)
end

---Prints the macros of the current line
M.macros = function()
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]

    local result = M.database:get(lines[line])
    local n = #lines[line]
    vim.api.nvim_buf_set_text(
        buffer,
        line - 1,
        n,
        line - 1,
        n,
        { "," .. tostring(result.macro) }
    )
end

---Insert a new item into the database and file from the current line
M.insert = function()
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]

    local result = FoodItem.from(lines[line])
    M.database:add(result)

    local fd = io.open(macros_path, "a")
    if fd == nil then
        error("File not found: " .. macros_path)
    end

    fd:write(tostring(result) .. "\n")
    fd:close()
end

---Find the best matching items for a query based on prefix
M.query = function()
    local query = vim.fn.input("Query prefix: ")
    local results = M.database:query(query)
    if #results == 0 then
        vim.print("No matching items found.")
        return
    end

    local choices = {}
    for i, item in ipairs(results) do
        choices[i] = i .. ". " .. item
    end

    vim.cmd("redraw!")
    local choice = vim.fn.inputlist(choices)
    if choice < 1 or choice > #choices then
        return
    end

    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local n = #lines[line]

    vim.api.nvim_buf_set_text(
        buffer,
        line - 1,
        n,
        line - 1,
        n,
        { results[choice] }
    )
end

---Find the best matching items for a query using fuzzy matching
M.query2 = function()
    local query = vim.fn.input("Fuzzy query: ")
    local results = M.database:fuzzy_query(query)
    if #results == 0 then
        vim.print("No matching items found.")
        return
    end

    local choices = {}
    for i, item in ipairs(results) do
        choices[i] = i .. ". " .. item
    end

    vim.cmd("redraw!")
    local choice = vim.fn.inputlist(choices)
    if choice < 1 or choice > #choices then
        return
    end

    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local n = #lines[line]

    vim.api.nvim_buf_set_text(
        buffer,
        line - 1,
        n,
        line - 1,
        n,
        { results[choice] }
    )
end

---Open Telescope picker for searching food items with real-time feedback
M.telescope_query = function()
    local ok, telescope = pcall(require, "macros.telescope")
    if not ok then
        vim.notify(
            "Telescope is not installed. Please install telescope.nvim to use this feature.",
            vim.log.levels.ERROR
        )
        return
    end

    telescope.food_picker(M.database)
end

---Run health checks
function M.health()
    require("macros.health").check()
end

return M
