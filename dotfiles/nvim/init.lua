-- Require your configuration files
require("config.options")
require("config.lazy")

-- Key mappings
vim.keymap.set("n", "<leader>y", 'ggVG"+y', { desc = "Yank entire buffer to system clipboard" })
vim.keymap.set("n", "<leader>p", [[:%delete_ | put +<CR>]], { desc = "Replace buffer with system clipboard" })

-- Define the function without 'local'
function insert_debug_text()
    local var_name = vim.fn.input("Enter variable name: ")
    local debug_text = 'echo "' .. var_name .. ': " . $' .. var_name .. ' . "<br>"; //delete me'
    -- Insert the debug text at the current cursor position
    vim.api.nvim_put({debug_text}, 'l', true, true)
end

-- Set the key mapping after the function definition
vim.api.nvim_set_keymap('n', '<leader>d', ':lua insert_debug_text()<CR>', { noremap = true, silent = true })

