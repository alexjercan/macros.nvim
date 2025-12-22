--- Source for the completion engine
---
--- @class Source
---
--- @field database Database
local Source = {}

--- Creates a new Source instance.
---
--- @param database Database
---
--- @return Source
function Source:new(database)
    local obj = {
        database = database,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

--- Check if the Source is available.
---
--- @return boolean
function Source.is_available()
    return true
end

--- Complete the given parameters.
---
--- @param params table
--- @param callback function
function Source:complete(params, callback)
    local prefix = params.context.cursor_before_line:sub(params.offset)
    vim.print("Prefix: " .. prefix)

    local results = self.database:query(prefix)
    vim.print("Results: ")
    vim.print(results)

    local items = {}
    for _, food in ipairs(results) do
        items[#items + 1] = {
            label = food,
            insertText = food,
            kind = vim.lsp.protocol.CompletionItemKind.Text,
        }
    end

    table.sort(results)

    callback({
        items = items,
        isIncomplete = false,
    })
end

function Source.get_debug_name()
    return "macros"
end

return Source
