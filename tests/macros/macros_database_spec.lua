local Database = require("macros.database")
local Food = require("macros.food")
local Macro = require("macros.macro")
local FoodItem = require("macros.fooditem")
local unit = require("macros.unit")
local Unit = unit.Unit
local UnitType = unit.UnitType

describe("Database", function()
    it("works with gram items", function()
        local db = Database:new()
        local food = Food:new("chicken breast", Unit:new(UnitType.gram), 100)
        local macro = Macro:new(31, 0, 3.6)
        db:add(FoodItem:new(food, macro))

        local item = db:get("chicken breast 200g")
        local expected = FoodItem:new(
            Food:new("chicken breast", Unit:new(UnitType.gram), 200),
            Macro:new(62, 0, 7.2)
        )

        assert(
            item.food.name == expected.food.name
                and item.food.unit.unit == expected.food.unit.unit
                and item.food.amount == expected.food.amount
                and item.macro.protein == expected.macro.protein
                and item.macro.carbs == expected.macro.carbs
                and item.macro.fat == expected.macro.fat,
            "chicken breast 200g"
        )
    end)

    it("works with piece items", function()
        local db = Database:new()
        local food = Food:new("apple", Unit:new(UnitType.piece), 1)
        local macro = Macro:new(0.3, 25, 0.2)
        db:add(FoodItem:new(food, macro))

        local item = db:get("apple 2pc")
        local expected = FoodItem:new(
            Food:new("apple", Unit:new(UnitType.piece), 2),
            Macro:new(0.6, 50, 0.4)
        )

        assert(
            item.food.name == expected.food.name
                and item.food.unit.unit == expected.food.unit.unit
                and item.food.amount == expected.food.amount
                and item.macro.protein == expected.macro.protein
                and item.macro.carbs == expected.macro.carbs
                and item.macro.fat == expected.macro.fat,
            "apple 2pc"
        )
    end)

    it("works with fractional piece items", function()
        local db = Database:new()
        local food = Food:new("apple", Unit:new(UnitType.piece), 1)
        local macro = Macro:new(0.3, 25, 0.2)
        db:add(FoodItem:new(food, macro))

        local item = db:get("apple 0.5pc")
        local expected = FoodItem:new(
            Food:new("apple", Unit:new(UnitType.piece), 0.5),
            Macro:new(0.15, 12.5, 0.1)
        )

        assert(
            item.food.name == expected.food.name
                and item.food.unit.unit == expected.food.unit.unit
                and item.food.amount == expected.food.amount
                and item.macro.protein == expected.macro.protein
                and item.macro.carbs == expected.macro.carbs
                and item.macro.fat == expected.macro.fat,
            "apple 0.5pc"
        )
    end)

    it("supports fractional grams", function()
        local db = Database:new()
        db:add(
            FoodItem:new(
                Food:new("olive oil", Unit:new(UnitType.gram), 10),
                Macro:new(0, 0, 10)
            )
        )

        local item = db:get("olive oil 2.5g")
        assert(item.food.amount == 2.5)
        assert(item.macro.fat == 2.5)
    end)
end)

describe("Database:query", function()
    it("returns matching prefixes", function()
        local db = Database:new()
        db:add(FoodItem.from("apple 1pc,1,2,3"))
        db:add(FoodItem.from("apricot 1pc,1,2,3"))
        db:add(FoodItem.from("banana 1pc,1,2,3"))

        local results = db:query("ap")
        table.sort(results)

        assert.same({ "apple pc", "apricot pc" }, results)
    end)

    it("returns empty for no matches", function()
        local db = Database:new()
        local results = db:query("zzz")
        assert.are.same({}, results)
    end)
end)

describe("Database:load", function()
    it("loads items from file", function()
        local tmp = vim.fn.tempname()
        vim.fn.writefile({
            "apple 1pc,1,2,3",
            "banana 100g,1,2,3",
        }, tmp)

        local db = Database:new()
        db:load(tmp)

        local results = db:query("")
        assert(#results == 2)
    end)
end)

describe("Database:get errors", function()
    it("errors on unknown food", function()
        local db = Database:new()
        assert.has_error(function()
            db:get("banana 1pc")
        end)
    end)
end)
