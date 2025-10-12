export TERM="xterm-256color"
export ZSH="$HOME/.oh-my-zsh"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export VAST_CONTAINERLABEL="${VAST_CONTAINERLABEL:-$(cat ~/.vast_containerlabel 2>/dev/null || echo "$HOST")}"
PATH=$PATH:~/.local/bin:~/.pixi/bin
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=( 
  z 
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh
source ~/.zsh_aliases
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE="$HOME/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
if micromamba env list | grep -w 'main' >/dev/null 2>&1; then
  micromamba activate main
else
  micromamba activate base
fi