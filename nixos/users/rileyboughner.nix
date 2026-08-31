{
  config,
  pkgs,
  username,
  ...
}:
{

  home.stateVersion = "26.05";
  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    nixfmt
    stylua
  ];

  programs.nixvim = {
    enable = true;

    # Reuse home-manager's pkgs instead of nixvim constructing its own from
    # a pinned/followed nixpkgs source (avoids the nixpkgs-follows mismatch warning).
    nixpkgs.useGlobalPackages = true;

    extraPlugins = [
      pkgs.vimPlugins.pywal-nvim
    ];

    extraConfigLua = ''
       -- Appearance
       vim.opt.termguicolors = true
       vim.opt.number = true
       vim.opt.wrap = false

       -- Search
       vim.opt.ignorecase = true
       vim.opt.smartcase = true

       -- Tabs / indentation
       vim.opt.tabstop = 2
       vim.opt.shiftwidth = 2
       vim.opt.expandtab = true

       -- UI
       vim.opt.signcolumn = "yes"
       vim.opt.cursorline = true

       -- Clipboard
       vim.opt.clipboard = "unnamedplus"

       -- Spell check (English) for prose filetypes; toggle manually elsewhere
       vim.opt.spelllang = "en_us"
       vim.api.nvim_create_autocmd("FileType", {
         pattern = { "markdown", "text", "gitcommit", "tex" },
         callback = function()
           vim.opt_local.spell = true
         end,
       })

       -- Extensionless files (e.g. plain-text notes) get no filetype, so the
       -- FileType autocmd above never fires for them; catch those directly.
       -- Deferred via schedule() since this can register ahead of Neovim's
       -- own filetype-detection autocmd on the same event, seeing a
       -- not-yet-detected empty filetype on files that do have one.
       vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
         pattern = "*",
         callback = function()
           local buf = vim.api.nvim_get_current_buf()
           local win = vim.api.nvim_get_current_win()
           vim.schedule(function()
             if vim.api.nvim_win_is_valid(win)
               and vim.api.nvim_win_get_buf(win) == buf
               and vim.api.nvim_get_option_value("filetype", { buf = buf }) == ""
             then
               vim.wo[win].spell = true
             end
           end)
         end,
       })

      -- Pywal switch colors signal --
       vim.api.nvim_create_autocmd("Signal", {
          pattern = "SIGUSR1",
          callback = function()
            vim.cmd("colorscheme pywal")
          end,
        })

      -- Format Command --
      vim.api.nvim_create_user_command("Format", function()
         require("conform").format({
           async = true,
           lsp_fallback = true,
         })
       end, {})

       -- Pywal colors
       vim.api.nvim_create_autocmd("VimEnter", {
         callback = function()
           vim.cmd("colorscheme pywal")
         end,
       })

       -- Leader key
       vim.g.mapleader = " "

       -- Keybinds
       local map = vim.keymap.set

       -- Save / quit
       map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
       map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

       -- Spell check
       map("n", "<leader>ss", "<cmd>set spell!<CR>", { desc = "Toggle spell check" })
       map("n", "<leader>sn", "]s", { desc = "Next misspelled word" })
       map("n", "<leader>sp", "[s", { desc = "Previous misspelled word" })
       map("n", "<leader>sw", "z=", { desc = "Spelling suggestions" })
       map("n", "<leader>sd", "zg", { desc = "Add word to dictionary" })
       map("n", "<leader>sb", "zw", { desc = "Mark word as wrong" })

       -- Better movement
       map("n", "J", "mzJ`z")
       map("n", "<C-d>", "<C-d>zz")
       map("n", "<C-u>", "<C-u>zz")

       -- Clear search highlight
       map("n", "<Esc>", "<cmd>noh<CR>")

       -- Formal-languages / math symbol abbreviations (type the trigger + a space)
       local symbol_abbrevs = {
         ["\\forall"] = "∀",
         ["\\exists"] = "∃",
         ["\\in"] = "∈",
         ["\\notin"] = "∉",
         ["\\emptyset"] = "∅",
         ["\\eps"] = "ε",
         ["\\cup"] = "∪",
         ["\\cap"] = "∩",
         ["\\subeq"] = "⊆",
         ["\\supeq"] = "⊇",
         ["\\sub"] = "⊂",
         ["\\sup"] = "⊃",
         ["\\to"] = "→",
         ["\\implies"] = "⇒",
         ["\\iff"] = "⇔",
         ["\\Sigma"] = "Σ",
         ["\\delta"] = "δ",
         ["\\Delta"] = "Δ",
         ["\\lambda"] = "λ",
         ["\\neq"] = "≠",
         ["\\leq"] = "≤",
         ["\\geq"] = "≥",
         ["\\land"] = "∧",
         ["\\lor"] = "∨",
         ["\\vdash"] = "⊢",
         ["\\models"] = "⊨",
       }
       -- :iabbrev rejects LHS values that mix a leading non-keyword char
       -- (the backslash) with trailing keyword chars (E474: Invalid
       -- argument), so use a plain insert-mode keymap on the literal
       -- "trigger + space" sequence instead.
       for trigger, symbol in pairs(symbol_abbrevs) do
         vim.keymap.set("i", trigger .. " ", symbol .. " ")
       end
    '';

    plugins = {
      # Better syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = [
            "nix"
            "lua"
            "bash"
            "json"
            "yaml"
            "markdown"
          ];
        };
      };

      # File searching
      telescope.enable = true;

      # Icons (used by telescope); explicit to avoid the deprecated auto-enable warning
      web-devicons.enable = true;

      # Status bar
      lualine.enable = true;

      # Git indicators
      gitsigns.enable = true;

      # Better comments
      comment.enable = true;

      # Keybinding helper
      which-key.enable = true;

      # LSP
      lsp = {
        enable = true;

        servers = {
          nil_ls.enable = true;
          lua_ls.enable = true;
          bashls.enable = true;
        };
      };

      # Autocomplete
      cmp = {
        enable = true;

        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };
      # Formatting
      conform-nvim = {
        enable = true;

        settings = {
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
          };
        };
      };
    };
  };

  programs.git = {
    enable = true;
    settings.user.name = "Riley Boughner";
    settings.user.email = "mail@rileyboughner.dev";
    settings = {
      credential.helper = "store";
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Everforest-Dark-BL-LB";
      package = pkgs.everforest-gtk-theme;
    };
    iconTheme = {
      name = "Everforest-Dark";
      package = pkgs.everforest-gtk-theme;
    };
    cursorTheme = {
      name = "capitaine-cursors-white";
      package = pkgs.capitaine-cursors;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
