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

describe("Database:fuzzy_query", function()
    it("matches characters in order", function()
        local db = Database:new()
        db:add(FoodItem.from("apple 1pc,1,2,3"))
        db:add(FoodItem.from("apricot 1pc,1,2,3"))
        db:add(FoodItem.from("banana 1pc,1,2,3"))
        db:add(FoodItem.from("chicken breast 100g,31,0,3.6"))

        local results = db:fuzzy_query("apl")
        table.sort(results)

        assert.same({ "apple pc" }, results)
    end)

    it("matches non-consecutive characters", function()
        local db = Database:new()
        db:add(FoodItem.from("chicken breast 100g,31,0,3.6"))
        db:add(FoodItem.from("chicken thigh 100g,25,0,5"))
        db:add(FoodItem.from("chocolate 100g,5,50,30"))

        local results = db:fuzzy_query("chbr")
        table.sort(results)

        assert.same({ "chicken breast g" }, results)
    end)

    it("is case insensitive", function()
        local db = Database:new()
        db:add(FoodItem.from("Apple 1pc,1,2,3"))
        db:add(FoodItem.from("BANANA 1pc,1,2,3"))

        local results = db:fuzzy_query("BAN")
        assert.same({ "BANANA pc" }, results)

        local results2 = db:fuzzy_query("app")
        assert.same({ "Apple pc" }, results2)
    end)

    it("returns empty for no matches", function()
        local db = Database:new()
        db:add(FoodItem.from("apple 1pc,1,2,3"))

        local results = db:fuzzy_query("zyx")
        assert.are.same({}, results)
    end)

    it("matches across spaces", function()
        local db = Database:new()
        db:add(FoodItem.from("chicken breast 100g,31,0,3.6"))
        db:add(FoodItem.from("white bread 100g,9,49,3.2"))

        local results = db:fuzzy_query("wbr")
        table.sort(results)

        assert.same({ "white bread g" }, results)
    end)

    it("returns multiple matches when multiple items match", function()
        local db = Database:new()
        db:add(FoodItem.from("apple 1pc,1,2,3"))
        db:add(FoodItem.from("apricot 1pc,1,2,3"))
        db:add(FoodItem.from("avocado 1pc,2,8,15"))

        local results = db:fuzzy_query("ap")
        table.sort(results)

        assert.are.equal(3, #results)
    end)
end)

describe("Database:search and calculate", function()
    it("returns deterministic candidates with stable IDs", function()
        local db = Database:new()
        db:add(FoodItem.from("chicken thigh 100g,25,0,5"))
        db:add(FoodItem.from("chicken breast 100g,31,0,3.6"))

        assert.same({
            {
                id = "chicken breast:g",
                name = "chicken breast",
                unit = "g",
            },
            {
                id = "chicken thigh:g",
                name = "chicken thigh",
                unit = "g",
            },
        }, db:search("ch"))
    end)

    it("ranks prefix matches before other fuzzy matches", function()
        local db = Database:new()
        db:add(FoodItem.from("chicken breast 100g,31,0,3.6"))
        db:add(FoodItem.from("egg 1pc,6,0,5"))

        local results = db:search("eg")
        assert.are.equal("egg:pc", results[1].id)
        assert.are.equal("chicken breast:g", results[2].id)
    end)

    it("calculates by selected ID", function()
        local db = Database:new()
        db:add(FoodItem.from("egg 1pc,6,0,5"))

        local item = db:calculate("egg:pc", 2)
        assert.are.equal("egg", item.food.name)
        assert.are.equal(2, item.food.amount)
        assert.are.equal(12, item.macro.protein)
        assert.are.equal(10, item.macro.fat)
    end)

    it("rejects unknown IDs and invalid amounts", function()
        local db = Database:new()
        db:add(FoodItem.from("egg 1pc,6,0,5"))

        assert.has_error(function()
            db:calculate("missing:pc", 1)
        end)
        assert.has_error(function()
            db:calculate("egg:pc", 0)
        end)
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
