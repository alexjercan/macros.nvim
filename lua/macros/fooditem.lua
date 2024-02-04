local Food = require("macros.food")
local Macro = require("macros.macro")

--- Tuple class that will store the food item and its macronutrients.
---
---@class FoodItem
---
---@field food Food
---@field macro Macro
local FoodItem = {}

--- A function that creates a new food item.
---
---@param food Food
---@param macro Macro
---
---@return FoodItem
function FoodItem:new(food, macro)
    local o = setmetatable({}, self)
    self.__index = self
    o.food = food
    o.macro = macro
    return o
end

--- A function that parses a string and returns the corresponding food item.
---
---@param input string
---
---@return FoodItem
function FoodItem.from(input)
    local parts = vim.split(input, ",")
    local food = Food.from(parts[1])
    local macro =
        Macro:new(tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
    return FoodItem:new(food, macro)
end

--- A function that displays the food item as a string.
---
---@param self FoodItem
---
---@return string
function FoodItem:__tostring()
    return tostring(self.food) .. "," .. tostring(self.macro)
end

return FoodItem
