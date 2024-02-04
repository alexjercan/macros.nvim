-- main module file
local Database = require("macros.database")
local Food = require("macros.food")
local Macro = require("macros.macro")
local unit = require("macros.unit")
local Unit = unit.Unit
local UnitType = unit.UnitType

---@class Config
local config = {}

---@class Macros
local M = {}

---@type Config
M.config = config

---Setup the module
---
---@param args Config?
M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})
    M.database = Database:new()
    M.database:add(Food:new("chicken breast", Unit:new(UnitType.gram), 100), Macro:new(31, 0, 3.6))
    M.database:add(Food:new("apple", Unit:new(UnitType.piece), 1), Macro:new(0.3, 25, 0.2))
end

---Prints the macros of the current line
M.macros = function()
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]

    local result = M.database:get(lines[line])
    local n = #lines[line]
    vim.api.nvim_buf_set_text(buffer, line - 1, n, line - 1, n, {"," .. tostring(result.macro)})
end

return M
