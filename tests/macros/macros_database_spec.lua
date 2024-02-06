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
end)
