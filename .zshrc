#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  #source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi
export TERM="xterm-256color"
export ZSH="$HOME/.oh-my-zsh"
export INTERFACES="wlp2s0"
export LANG="en_US.UTF-8"
PATH=$PATH:~/.local/bin:~/.pixi/bin
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=( 
  z 
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh
# stty -ixon
source ~/.zsh_aliases
# source ~/miniconda3/bin/activate && conda deactivate
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
micromamba activate  # this activates the base environment
