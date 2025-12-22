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
---@param item FoodItem
function Database:add(item)
    local key = string.lower(item.food.name .. " " .. tostring(item.food.unit))
    self.foods[key] = item
end

--- A function that adds multiple food items to the database.
---
---@param items table<FoodItem>
function Database:extend(items)
    for _, item in ipairs(items) do
        self:add(item)
    end
end

--- A function that adds food items from a file to the database.
---
---@param file string
function Database:load(file)
    local fd = io.open(file, "r")

    if fd == nil then
        error("File not found: " .. file)
    end

    for line in fd:lines() do
        local ok, item = pcall(FoodItem.from, line)
        if ok then
            self:add(item)
        else
            vim.notify(
                "Skipping invalid line in macros.csv: " .. line,
                vim.log.levels.WARN
            )
        end
    end
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
    local key = string.lower(food.name .. " " .. tostring(food.unit))
    local item = self.foods[key]

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

--- A function that queries the database for a list of food items that match a
--- given prefix.
---
---@param prefix string
---
---@return table<string>
function Database:query(prefix)
    prefix = string.lower(prefix)
    local results = {}
    for key, _ in pairs(self.foods) do
        if vim.startswith(key, prefix) then
            table.insert(results, key)
        end
    end

    return results
end

return Database
