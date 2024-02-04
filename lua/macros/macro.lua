--- This class represents a macro tuple
---
---@class Macro
---
---@field protein number
---@field carbs number
---@field fat number
local Macro = {}

--- Creates a new macro tuple.
function Macro:new(protein, carbs, fat)
    local o = setmetatable({}, self)
    self.__index = self
    o.protein = protein
    o.carbs = carbs
    o.fat = fat
    return o
end

--- A function that displays the macro tuple as a string.
---
---@param self Macro
---
---@return string
function Macro:__tostring()
    return self.protein .. "," .. self.carbs .. "," .. self.fat
end

return Macro
