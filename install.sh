#!/usr/bin/env bash
set -euo pipefail

#############################
# 0. Guardrails & helpers   #
#############################
[[ "$(uname)" == "Darwin" ]] || { echo "macOS only."; exit 1; }
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
msg() { printf "\n\033[1;32m%s\033[0m\n" "$*"; }   # green bold

#############################
# 1. Xcode CLT / Xcode      #
#############################
if ! xcode-select -p &>/dev/null; then
  msg "Installing Xcode Command-Line Tools…"
  xcode-select --install
  # Wait until installation finishes
  until xcode-select -p &>/dev/null; do sleep 30; done
fi

#############################
# 2. Homebrew & Bundle      #
#############################
if ! command -v brew &>/dev/null; then
  msg "Installing Homebrew…"
  NONINTERACTIVE=1 \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

msg "Running brew bundle…"
brew bundle --file="$DOTFILES_DIR/Brewfile"

#############################
# 3. Language managers      #
#############################
# --- nvm (Node) ---
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
[[ -s "$(brew --prefix nvm)/nvm.sh" ]] && \. "$(brew --prefix nvm)/nvm.sh"
nvm install --lts
nvm alias default node

# --- pyenv (Python) ---
if ! grep -q 'pyenv init' ~/.zprofile 2>/dev/null; then
  cat >> ~/.zprofile <<'EOF'

# >>> pyenv >>>
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# <<< pyenv <<<
EOF
fi
eval "$(pyenv init -)"
latest_py=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
pyenv install -s "$latest_py"
pyenv global "$latest_py"

# --- rustup (Rust) ---
if ! command -v rustup &>/dev/null; then
  rustup-init -y --no-modify-path
fi
source "$HOME/.cargo/env"

# --- Java via jenv ---
sudo ln -sf "$(brew --prefix)/opt/openjdk/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk 2>/dev/null || true
jenv add "$(/usr/libexec/java_home)"
jenv global system

#############################
# 4. Copy dot_files → ~/.config
#############################
msg "Copying dot_files into ~/.config…"
mkdir -p ~/.config
rsync -a --update --delete "$DOTFILES_DIR/dot_files/" ~/.config/

#############################
# 5. Oh-My-Zsh (if missing)
#############################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  msg "Installing Oh-My-Zsh…"
  RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

#############################
# 6. Finish up
#############################
msg "Installation complete. Configuring services now..."

# Make zsh the default shell
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# Prompt for GitHub auth (interactive)
gh auth login || true

# Launch Neovim for good measure
exec nvim

