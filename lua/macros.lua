-- main module file
local Database = require("macros.database")
local FoodItem = require("macros.fooditem")

---@class Config
---
---@field file string?
---@field items table<string>
local config = {
    file = nil,
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
    M.config = vim.tbl_deep_extend("force", M.config, args or {})
    M.database:extend({})
    for _, item in ipairs(M.config.items) do
        M.database:add(FoodItem.from(item))
    end
    if M.config.file then
        M.database:load(M.config.file)
    end
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

return M
