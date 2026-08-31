# oh-my-posh bakes the resolved Nix store path of its own binary into the cached
# init script (~/.cache/oh-my-posh/init.*.zsh). Nix rebuilds can change that path
# without oh-my-posh noticing, and weekly nix.gc then deletes the old one out from
# under it. Detect a stale cache and clear it before sourcing.
for _omp_cached_init in $HOME/.cache/oh-my-posh/init.*.zsh(N); do
  _omp_cached_bin=$(sed -n "s/.*_omp_executable=\$'\(.*\)'.*/\1/p" "$_omp_cached_init" 2>/dev/null | head -n1)
  if [[ -n "$_omp_cached_bin" && ! -x "$_omp_cached_bin" ]]; then
    rm -rf "$HOME/.cache/oh-my-posh"
    break
  fi
done
unset _omp_cached_init _omp_cached_bin

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
