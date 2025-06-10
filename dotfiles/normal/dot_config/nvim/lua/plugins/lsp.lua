return {

  {
    "dundalek/lazy-lsp.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local lsp_zero = require("lsp-zero")

      lsp_zero.on_attach(function(client, bufnr)
        vim.keymap.set("n", "<leader>gd", require('telescope.builtin').lsp_definitions, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, opts)

        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, { buffer = bufnr, desc = "LSP format buffer" })
      end)

      require("lazy-lsp").setup {}
    end,
  },
}
