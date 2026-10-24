export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

setopt extended_glob

plugins=(
  git
  extract
  sudo
  colored-man-pages
  terraform
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

typeset -g ZSH_HIGHLIGHT_STYLES[alias]='fg=#E05263'
typeset -g ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#E05263'
typeset -g ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#E05263'

export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"
alias ls='ls -G'
alias ll='ls -alFG'
alias la='ls -AG'
alias l='ls -CFG'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias fping='ping -c 50 -i 0.2'
alias rbt='sudo reboot'
alias pwof='sudo shutdown -h now'

alias -g -- vim='nvim'
alias -g -- ivm='nvim' 
alias -g -- Do='Documents'

scrnrec() {
  if [ -z "$1" ]; then
    echo "you need to add a name for the file."
    echo "usage: scrnrec <videoname>"
    return 1
  fi

  ffmpeg -f avfoundation -framerate 40 -i "1:none" -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p "${HOME}/Movies/$1.mp4"
  echo "saved video as ~/Movies/$1.mp4"
}

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias mkdir='mkdir -pv'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias -g -- ytdlp='yt-dlp'

alias -g -- ytdlpc='yt-dlp --cookies-from-browser firefox:~/.zen'

alias -g -- ssh='kitty +kitten ssh'

alias update='brew update && brew upgrade'
alias cleanup='brew cleanup'

alias c='clear'
alias h='history'
alias j='jobs -l'

alias pfup="sudo pfctl -ef /etc/pf.conf"
alias pfdown="sudo pfctl -d"
alias pfstatus="sudo pfctl -sa"

alias server='python3 -m http.server'

alias gitpush='git push'
alias gps='git push'
alias gpl='git pull'
alias gs='git status'
alias ga='git add . && git status'
alias gc='git commit'

mkcd() {
  mkdir -p "$1" && cd "$1"
}

export PATH="/opt/homebrew/bin:$PATH"

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

echo "\n\n"
fastfetch 

eval "$(ssh-agent -s)" > /dev/null
ssh-add -l > /dev/null 2>&1 || ssh-add --apple-use-keychain ~/.ssh/id_ed25519 > /dev/null 2>&1
true

# rbenv initialization
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"


