local Unit = require("macros.unit").Unit

--- This class represents a food item.
---
---@class Food
---
---@field name string
---@field unit Unit
---@field amount number
local Food = {}

--- A function that creates a new food item.
---
---@param name string
---@param unit Unit
---@param amount number
---
---@return Food
function Food:new(name, unit, amount)
    local o = setmetatable({}, self)
    self.__index = self
    o.name = name
    o.unit = unit
    o.amount = amount
    return o
end

--- A function that parses a string and returns the corresponding food item.
--- For example a food item can be "white flour 500g", or it can be
--- "apple 1pc".
---
---@param food string
---
---@return Food
Food.from = function (food)
    local parts = {}
    for part in string.gmatch(food, "%S+") do
        table.insert(parts, part)
    end

    local name = table.concat(parts, " ", 1, #parts - 1)
    local quantity, unit = parts[#parts]:match("(%d+)(%a+)")

    local amount = tonumber(quantity)

    if amount == nil then
        error("Invalid amount: " .. quantity)
    end

    return Food:new(name, Unit.from(unit), amount)
end

--- A function that displays the food item as a string.
---
---@param self Food
---
---@return string
function Food:__tostring()
    return self.name .. " " .. self.amount .. tostring(self.unit)
end

return Food
