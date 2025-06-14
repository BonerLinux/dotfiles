require("config.options")
require("config.lazy")

vim.keymap.set("n", "<leader>y", 'ggVG"+y', { desc = "Yank entire buffer to system clipboard" })
vim.keymap.set("n", "<leader>p", [[:%delete_ | put +<CR>]], { desc = "Replace buffer with system clipboard" })

