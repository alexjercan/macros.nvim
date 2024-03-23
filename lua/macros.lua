-- main module file
local Database = require("macros.database")
local FoodItem = require("macros.fooditem")

local data_path = vim.fn.stdpath("data")
local macros_path = string.format("%s/macros.csv", data_path)

---@class Config
---
---@field items table<string>
local config = {
    items = {},
}

---@class Macros
local M = {}

---@type Config
M.config = config

---@type Database
M.database = Database:new()

---Setup the module
---
---@param args Config?
M.setup = function(args)
    -- create the file if it doesn't exist
    if vim.fn.filereadable(macros_path) == 0 then
        vim.fn.writefile({}, macros_path)
    end

    M.config = vim.tbl_deep_extend("force", M.config, args or {})
    M.database:extend({})
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

return M
