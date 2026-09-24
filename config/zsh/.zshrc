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

_todo() {
  case $CURRENT in
    2)
      local -a cmds
      cmds=(
        'task:manage todoist tasks'
        'config:view or change todo settings'
        'tui:launch the vim-motion gum interface'
      )
      _describe 'command' cmds
      ;;
    3)
      if [[ ${words[2]} == task ]]; then
        local -a actions
        actions=(
          'complete:mark a task done by number or text'
          'create:add a new task'
          'remove:delete a task by number or text'
          'list:show tasks (all, overdue, or today)'
        )
        _describe 'action' actions
      elif [[ ${words[2]} == config ]]; then
        local -a keys
        keys=('default_mode:which interface todo launches by default')
        _describe 'option' keys
      fi
      ;;
    4)
      if [[ ${words[2]} == task && ${words[3]} == list ]]; then
        local -a views
        views=('overdue:only overdue tasks' 'today:only tasks due today')
        _describe 'view' views
      elif [[ ${words[2]} == config && ${words[3]} == default_mode ]]; then
        local -a modes
        modes=('text:plain unix-style output' 'tui:vim-motion gum interface')
        _describe 'value' modes
      fi
      ;;
  esac
}
compdef _todo todo
