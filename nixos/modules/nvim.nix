{ config, pkgs, lib, ... }: 

{

programs.neovim = {
  enable = true;
  defaultEditor = true;
  vimAlias = true;
  viAlias = true;
};

programs.zsh = {
    shellAliases = {
      n = "nvim";
      ng = ''nvim --cmd "lua vim.defer_fn(function() require('telescope.builtin').live_grep() end, 10)"'';
      nf = ''nvim --cmd "lua vim.defer_fn(function() require('telescope.builtin').find_files() end, 10)"'';
    };
  };

environment.systemPackages = with pkgs; [
    neovim
    gnumake
    gcc
    ueberzugpp
    fd
    fzf
    ripgrep
];

}
