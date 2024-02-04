local Food = require("macros.food")
local Macro = require("macros.macro")
local FoodItem = require("macros.fooditem")

--- Database that will store the food items.
---
---@class Database
---
---@field foods table<string, FoodItem>
local Database = {
    foods = {},
}

--- A function that creates a new database.
---
---@param foods table<string, FoodItem>?
---
---@return Database
function Database:new(foods)
    local o = setmetatable({}, self)
    self.__index = self
    o.foods = foods or {}
    return o
end

--- A function that adds a food item to the database.
---
---@param food Food
---@param macro Macro
function Database:add(food, macro)
    self.foods[food.name] = FoodItem:new(food, macro)
end

--- A function that returns a food item from the database. This function will
--- get as an argument the name and the amount of the food item. For example a
--- food item can be "white flour 500g", or it can be "apple 1pc".
---
---@param input string
---
---@return FoodItem
function Database:get(input)
    local food = Food.from(input)
    local item = self.foods[food.name]

    if item == nil then
        error("Unknown food: " .. food.name)
    end

    local ratio = food.amount / item.food.amount
    local macro = Macro:new(
        item.macro.protein * ratio,
        item.macro.carbs * ratio,
        item.macro.fat * ratio
    )

    return FoodItem:new(food, macro)
end

return Database
