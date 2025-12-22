local Database = require("macros.database")
local FoodItem = require("macros.fooditem")

describe("Source", function()
    it("returns completion items", function()
        local db = Database:new()
        db:add(FoodItem.from("apple 1pc,1,2,3"))

        local Source = require("macros.source")
        local src = Source:new(db)

        local called = false

        src:complete({
            context = { cursor_before_line = "app" },
            offset = 1,
        }, function(result)
            called = true
            assert(#result.items == 1)
            assert(result.items[1].label == "apple pc")
        end)

        assert(called)
    end)
end)
