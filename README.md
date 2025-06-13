## Jason's Dotfiles


### Installation
```
mkdir ~/workspace
git clone https://github.com/jasontoews/dotfiles ~/workspace/dotfiles      # or any path you prefer
cd ~/workspace/dotfiles
/bin/bash install.sh


# A one-liner if you ever want to only re-stow the dotfiles
stow -v --dir=~/workspace/dotfiles/stow --target=$HOME nvim zsh

# Sanity checks
file ~/.config/nvim           # → “… symbolic link …/dotfiles/stow/nvim/.config/nvim”
file ~/.zshrc                 # → “… symbolic link …/dotfiles/stow/zsh/.zshrc”
nvim --version


```


