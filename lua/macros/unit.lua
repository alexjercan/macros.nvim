--- @class UnitType
---
--- This class represents the type of unit of measurement for the ingredients.
local UnitType = {
    gram = {},
    piece = {},
}

--- @class Unit
---
--- This module contains the unit of measurement for the ingredients.
---
--- @field unit UnitType
local Unit = { }

--- A function that creates a new unit.
---
--- @param unit UnitType
---
--- @return Unit
function Unit:new(unit)
    local o = setmetatable({}, self)
    self.__index = self
    o.unit = unit
    return o
end

--- A function that parses a string and returns the corresponding unit.
---
--- @param unit string
---
--- @return Unit
Unit.from = function(unit)
    if unit == "g" or unit == "gr" or unit == "gram" or unit == "grams" then
        return Unit:new(UnitType.gram)
    elseif unit == "p" or unit == "pc" or unit == "pcs" or unit == "piece" or unit == "pieces" then
        return Unit:new(UnitType.piece)
    else
        error("Unknown unit: " .. unit)
    end
end

--- A function that displays the unit as a string.
---
--- @param self Unit
---
--- @return string
function Unit:__tostring()
    if self.unit == UnitType.gram then
        return "g"
    elseif self.unit == UnitType.piece then
        return "pc"
    else
        error("Unknown unit: " .. self)
    end
end

return {
    Unit = Unit,
    UnitType = UnitType,
}
