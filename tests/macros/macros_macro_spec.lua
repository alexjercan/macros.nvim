local Macro = require("macros.macro")

describe("macro", function()
    it("works with anything", function()
        local macro = Macro:new(31, 0, 3.6)

        assert(tostring(macro) == "31,0,3.6", "macro 31,0,3.6")
    end)
end)
