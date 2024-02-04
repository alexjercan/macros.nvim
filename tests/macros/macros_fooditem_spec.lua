local FoodItem = require("macros.fooditem")
local Food = require("macros.food")
local Macro = require("macros.macro")
local unit = require("macros.unit")
local Unit = unit.Unit
local UnitType = unit.UnitType

describe("FoodItem", function()
    it("works with grams", function()
        local food = Food:new("chicken breast", Unit:new(UnitType.gram), 100)
        local macro = Macro:new(31, 0, 3.6)
        local item = FoodItem:new(food, macro)

        assert(tostring(item) == "chicken breast 100g,31,0,3.6", "chicken breast,31,0,3.6")
    end)
end)

