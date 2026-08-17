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
local function food_id(food)
    return string.lower(food.name) .. ":" .. tostring(food.unit)
end

function Database:add(item)
    self.foods[food_id(item.food)] = item
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
    return self:calculate(food_id(food), food.amount)
end

--- Calculate macros for a selected food ID and amount.
---
---@param id string
---@param amount number
---
---@return FoodItem
function Database:calculate(id, amount)
    local item = self.foods[string.lower(id)]

    if item == nil then
        error("Unknown food ID: " .. id)
    end
    if amount <= 0 or amount ~= amount or amount == math.huge then
        error("Amount must be a positive finite number")
    end

    local ratio = amount / item.food.amount
    local macro = Macro:new(
        item.macro.protein * ratio,
        item.macro.carbs * ratio,
        item.macro.fat * ratio
    )
    local food = Food:new(item.food.name, item.food.unit, amount)

    return FoodItem:new(food, macro)
end

--- Return deterministic machine-readable fuzzy matches.
---
---@param query string
---
---@return table
function Database:search(query)
    query = string.lower(query)
    local results = {}

    for id, item in pairs(self.foods) do
        local pos = 1
        local match = true
        for i = 1, #query do
            local found = id:find(query:sub(i, i), pos, true)
            if found then
                pos = found + 1
            else
                match = false
                break
            end
        end
        if match then
            table.insert(results, {
                id = id,
                name = item.food.name,
                unit = tostring(item.food.unit),
            })
        end
    end

    table.sort(results, function(a, b)
        local a_prefix = vim.startswith(a.id, query)
        local b_prefix = vim.startswith(b.id, query)
        if a_prefix ~= b_prefix then
            return a_prefix
        end
        return a.id < b.id
    end)
    return results
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
    for key, item in pairs(self.foods) do
        if vim.startswith(key, prefix) then
            table.insert(
                results,
                item.food.name .. " " .. tostring(item.food.unit)
            )
        end
    end

    return results
end

--- A function that performs fuzzy matching on the database. Returns items where
--- all characters from the query appear in order in the key (case insensitive).
---
---@param query string
---
---@return table<string>
function Database:fuzzy_query(query)
    local results = {}
    for _, candidate in ipairs(self:search(query)) do
        table.insert(results, candidate.name .. " " .. candidate.unit)
    end
    return results
end

return Database
