vim.api.nvim_create_user_command("Macros", require("macros").macros, {})
vim.api.nvim_create_user_command("MacrosInsert", require("macros").insert, {})
