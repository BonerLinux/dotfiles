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

       -- Better movement
       map("n", "J", "mzJ`z")
       map("n", "<C-d>", "<C-d>zz")
       map("n", "<C-u>", "<C-u>zz")

       -- Clear search highlight
       map("n", "<Esc>", "<cmd>noh<CR>")
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
