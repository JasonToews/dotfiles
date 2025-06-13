#!/usr/bin/env bash
# -------------------------------------------------------------------
# macOS bootstrap for ~/workspace/dotfiles
# -------------------------------------------------------------------
# • Installs Homebrew plus everything explicitly listed
# • Sets up nvm, pyenv, rustup, jenv
# • Copies repo-scoped configs into ~/.config
# • Symlinks dotfiles via GNU Stow
# • Installs Oh-My-Zsh and Powerline fonts
# • Makes Zsh the default shell and launches AstroNvim
# -------------------------------------------------------------------
set -euo pipefail

########################################################################
# 0. Guardrails & helpers
########################################################################
[[ "$(uname)" == "Darwin" ]] || { echo "🛑  This script is for macOS only."; exit 1; }

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
msg() { printf "\n\033[1;32m%s\033[0m\n" "$*"; }   # green-bold banner

########################################################################
# 1. Xcode Command-Line Tools (full Xcode via Cask later)
########################################################################
if ! xcode-select -p &>/dev/null; then
  msg "📦  Installing Xcode Command-Line Tools…"
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 30; done
fi

########################################################################
# 2. Homebrew bootstrap & installs
########################################################################
if ! command -v brew &>/dev/null; then
  msg "🧰  Installing Homebrew…"
  NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH for Apple-silicon machines
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

msg "🍺  Installing Homebrew packages…"

# Taps
# brew tap homebrew/cask
# brew tap homebrew/cask-fonts
# brew tap homebrew/cask-versions

# CLI tools
brew install git
brew install gh
brew install act
brew install nvm
brew install pyenv
brew install kubernetes-cli
brew install awscli
brew install go
brew install rustup-init
brew install jenv
brew install z
brew install terraform
brew install lazygit
brew install neovim
brew install mysql
brew install bottom 

# GUI apps
brew install --cask android-studio
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask postman
brew install --cask lm-studio

# Fonts
brew install --cask font-jetbrains-mono-nerd-font

########################################################################
# 3. Language-version managers
########################################################################
# --- Node via nvm -----------------------------------------------------
msg "⬢  Installing latest LTS Node with nvm…"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
# shellcheck source=/dev/null
. "$(brew --prefix nvm)/nvm.sh"
nvm install --lts
nvm alias default node

# --- Python via pyenv -------------------------------------------------
msg "🐍  Installing latest Python with pyenv…"
if ! grep -q 'pyenv init' "$HOME/.zprofile" 2>/dev/null; then
  cat >> "$HOME/.zprofile" <<'EOF'

# >>> pyenv >>>
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# <<< pyenv <<<
EOF
fi
# shellcheck source=/dev/null
eval "$(pyenv init -)"
latest_py=$(pyenv install --list |
            grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' |
            tail -1 | tr -d ' ')
pyenv install -s "$latest_py"
pyenv global  "$latest_py"

# --- Rust via rustup --------------------------------------------------
msg "🦀  Installing Rust toolchain…"
if ! command -v rustup &>/dev/null; then
  rustup-init -y --no-modify-path
fi

if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
else
  msg "⚠️  ~/.cargo/env not found; initializing rustup manually…"
  "$HOME/.cargo/bin/rustup" show &>/dev/null || true
  [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
fi

# --- Java via jenv ----------------------------------------------------
msg "☕  Configuring Java with jenv…"

brew install openjdk

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

sudo ln -sf "$(brew --prefix openjdk)/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk.jdk || true

# Ensure jenv is ready
mkdir -p "$HOME/.jenv"
mkdir -p "$HOME/.jenv/versions"

jenv add "$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"

# Only set global if directory exists
if [ -d "$HOME/.jenv" ]; then
  jenv global "$(jenv versions --bare | grep openjdk | head -1)" || jenv global system
fi

# ########################################################################
# # 4. Copy repo-scoped configs into ~/.config
# ########################################################################
# msg "🗂   Copying dotfiles/ → ~/.config…"
# mkdir -p "$HOME/.config"
# rsync -a --update --delete "$DOTFILES_DIR/dotfiles/" "$HOME/.config/"

########################################################################
# 5. Link dotfiles packages with Stow
########################################################################
msg "🔗  Linking packages with GNU Stow…"
brew install stow
stow -v --dir="$DOTFILES_DIR/stow" --target="$HOME" nvim zsh

########################################################################
# 6. Oh-My-Zsh (shell framework)
########################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  msg "💡  Installing Oh-My-Zsh…"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

########################################################################
# 7. Powerline / Nerd fonts (for fancy Zsh & Neovim themes)
########################################################################
msg "🔤  Installing Powerline/Nerd fonts…"
(
  cd "$(mktemp -d)"
  git clone https://github.com/powerline/fonts.git --depth=1
  cd fonts
  ./install.sh
)

########################################################################
# 8. Finishing touches
########################################################################
msg "✅  Installation complete. Configuring services now…"

# Make Zsh the default login shell
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# Optional GitHub auth (interactive — safe to skip/abort)
gh auth login || true

echo "NOTE: To add the new font to iTerm2, go to iTerm2->Preferences->Profiles->Text->Change Font, and select JetBrainsMono Nerd Font"

# Launch Neovim to signal finish & generate any first-run assets
exec nvim

