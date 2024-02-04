local Food = require("macros.food")
local unit = require("macros.unit")
local UnitType = unit.UnitType
local Unit = unit.Unit

describe("food", function()
    it("works with single word grams", function()
        local food = Food.from("apple 100g")
        local expected = Food:new("apple", Unit:new(UnitType.gram), 100)

        assert(
            food.name == expected.name and food.unit.unit == expected.unit.unit and food.amount == expected.amount,
            "apple 100g"
        )
    end)

    it("works with multi word grams", function()
        local food = Food.from("white flour 500g")
        local expected = Food:new("white flour", Unit:new(UnitType.gram), 500)

        assert(
            food.name == expected.name and food.unit.unit == expected.unit.unit and food.amount == expected.amount,
            "white flour 500g"
        )
    end)

    it("works with single word pieces", function()
        local food = Food.from("apple 1pc")
        local expected = Food:new("apple", Unit:new(UnitType.piece), 1)

        assert(
            food.name == expected.name and food.unit.unit == expected.unit.unit and food.amount == expected.amount,
            "apple 1pc"
        )
    end)

    it("works with multi word pieces", function()
        local food = Food.from("white flour 1piece")
        local expected = Food:new("white flour", Unit:new(UnitType.piece), 1)

        assert(
            food.name == expected.name and food.unit.unit == expected.unit.unit and food.amount == expected.amount,
            "white flour 1piece"
        )
    end)

    it("works with single word to string", function()
        local food = Food:new("apple", Unit:new(UnitType.gram), 100)
        assert(tostring(food) == "apple 100g", "apple 100g")
    end)
end)
