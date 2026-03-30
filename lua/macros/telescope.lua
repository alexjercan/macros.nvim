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
                        -- Insert the selected food item at cursor position
                        local buffer = vim.api.nvim_get_current_buf()
                        local lines =
                            vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
                        local line = vim.api.nvim_win_get_cursor(0)[1]
                        local n = #lines[line]

                        vim.api.nvim_buf_set_text(
                            buffer,
                            line - 1,
                            n,
                            line - 1,
                            n,
                            { selection[1] }
                        )
                    end
                end)
                return true
            end,
        })
        :find()
end

return M
