local M = {}

function M.check()
    local health = vim.health or require("health")

    health.start("macros.nvim")

    -- Neovim version
    if vim.fn.has("nvim-0.9") == 1 then
        health.ok("Neovim >= 0.9")
    else
        health.error("Neovim < 0.9 is not supported")
    end

    -- Config sanity
    local macros = require("macros")

    if type(macros.config) ~= "table" then
        health.error("Config is not a table")
    else
        health.ok("Config table loaded")

        if type(macros.config.items) ~= "table" then
            health.error("config.items must be a table of strings")
        else
            health.ok(
                string.format(
                    "config.items contains %d entries",
                    #macros.config.items
                )
            )
        end
    end

    -- Database status
    local db = macros.database

    if type(db) ~= "table" or type(db.foods) ~= "table" then
        health.error("Database not initialized correctly")
    else
        local count = vim.tbl_count(db.foods)
        if count == 0 then
            health.warn(
                "Database is empty (no food items loaded)",
                "Add items via config.items or :MacrosInsert"
            )
        else
            health.ok(string.format("Database contains %d food items", count))
        end
    end

    -- Data file
    local data_path = vim.fn.stdpath("data")
    local macros_path = string.format("%s/macros.csv", data_path)

    if vim.fn.filereadable(macros_path) == 1 then
        health.ok("macros.csv exists")

        local fd = io.open(macros_path, "a")
        if fd then
            fd:close()
            health.ok("macros.csv is writable")
        else
            health.error("macros.csv is not writable")
        end
    else
        health.warn("macros.csv not found (will be created on setup)")
    end

    -- Optional integrations
    local ok_cmp = pcall(require, "cmp")
    if ok_cmp then
        health.ok("nvim-cmp detected (completion enabled)")
    else
        health.info("nvim-cmp not installed (completion disabled)")
    end
end

return M
