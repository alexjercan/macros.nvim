local unit = require("macros.unit")
local Unit = unit.Unit
local UnitType = unit.UnitType

describe("Unit", function()
    it("works with grams", function()
        assert(Unit.from("g").unit == UnitType.gram, "g")
    end)

    it("works with pieces", function()
        assert(Unit.from("p").unit == UnitType.piece, "p")
    end)
end)
