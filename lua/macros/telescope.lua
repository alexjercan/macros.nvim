local M = {}

--- Creates a Telescope picker for searching food items in the database
---
---@param database Database The database to search
---@param opts table? Optional Telescope configuration
M.food_picker = function(database, opts)
    -- Lazy load telescope dependencies only when the function is called
    local ok_pickers, pickers = pcall(require, "telescope.pickers")
    local ok_finders, finders = pcall(require, "telescope.finders")
    local ok_conf, conf = pcall(require, "telescope.config")
    local ok_actions, actions = pcall(require, "telescope.actions")
    local ok_action_state, action_state =
        pcall(require, "telescope.actions.state")

    if
        not (
            ok_pickers
            and ok_finders
            and ok_conf
            and ok_actions
            and ok_action_state
        )
    then
        error(
            "Telescope is not installed. Please install telescope.nvim to use this feature."
        )
    end

    opts = opts or {}

    -- Capture the buffer and cursor position BEFORE telescope opens,
    -- so we know exactly where to insert the new line later.
    local target_buffer = vim.api.nvim_get_current_buf()
    local target_win = vim.api.nvim_get_current_win()
    local target_line = vim.api.nvim_win_get_cursor(target_win)[1]

    -- Get all food items from the database
    local items = {}
    for _, item in pairs(database.foods) do
        table.insert(items, item.food.name .. " " .. tostring(item.food.unit))
    end

    pickers
        .new(opts, {
            prompt_title = "Macros Food Database",
            finder = finders.new_table({
                results = items,
            }),
            sorter = conf.values.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection then
                        -- Prompt for quantity after food selection
                        vim.schedule(function()
                            local quantity = vim.fn.input("Quantity: ")
                            if quantity == "" then
                                return
                            end

                            -- Parse quantity as a number
                            local qty = tonumber(quantity)
                            if not qty then
                                vim.notify(
                                    "Invalid quantity: " .. quantity,
                                    vim.log.levels.ERROR
                                )
                                return
                            end

                            -- Build the food string with quantity
                            -- selection[1] is "food name unit", we need "food name qty unit"
                            local selected_text = selection[1]
                            local parts = {}
                            for word in selected_text:gmatch("%S+") do
                                table.insert(parts, word)
                            end

                            -- Last part is the unit, everything else is the food name
                            local unit = parts[#parts]
                            table.remove(parts, #parts)
                            local food_name = table.concat(parts, " ")

                            local food_string = food_name .. " " .. qty .. unit

                            -- Get the macros for this food item
                            local result = database:get(food_string)

                            -- Format the output nicely with macros
                            local output = food_string
                                .. ","
                                .. tostring(result.macro)

                            -- Insert on next line (like 'o' in vim)
                            -- Use the buffer/line we captured BEFORE telescope opened.
                            vim.api.nvim_buf_set_lines(
                                target_buffer,
                                target_line,
                                target_line,
                                false,
                                { output }
                            )

                            -- Move cursor to the new line at the beginning
                            if vim.api.nvim_win_is_valid(target_win) then
                                vim.api.nvim_set_current_win(target_win)
                                vim.api.nvim_win_set_cursor(
                                    target_win,
                                    { target_line + 1, 0 }
                                )
                            end
                        end)
                    end
                end)
                return true
            end,
        })
        :find()
end

return M
