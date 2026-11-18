CONFIG_PATH=`pwd`

# jq generates the OpenCode save-mode profile (opencode/oc-mode)
if command -v brew >/dev/null 2>&1; then
  brew list --formula jq >/dev/null 2>&1 || brew install jq
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required by opencode/oc-mode" >&2
  exit 1
fi

mkdir -p ~/.config/nvim/
ln -sf $CONFIG_PATH/init.vim ~/.config/nvim/init.vim
ln -sf $CONFIG_PATH/.zshrc ~/.zshrc
ln -sf $CONFIG_PATH/.gitconfig ~/.gitconfig
ln -sf $CONFIG_PATH/.tmux.conf ~/.tmux.conf
ln -sf $CONFIG_PATH/.p10k.zsh ~/.p10k.zsh
[ -L ~/.local/share/konsole ] && rm ~/.local/share/konsole
ln -sf $CONFIG_PATH/konsole ~/.local/share/konsole
ln -sf $CONFIG_PATH/ssh_config ~/.ssh/config
ln -sf $CONFIG_PATH/.prettierrc ~/.prettierrc
mkdir -p ~/.config/opencode
ln -sf $CONFIG_PATH/opencode/opencode.json ~/.config/opencode/opencode.json
ln -sf $CONFIG_PATH/opencode/AGENTS.md ~/.config/opencode/AGENTS.md
ln -sf $CONFIG_PATH/opencode-tui.json ~/.config/opencode/cli.json
# Resetting the config also resets the tmux "SAVE" indicator
sh $CONFIG_PATH/opencode/oc-mode sync 2>/dev/null || true
mkdir -p ~/.config/cliamp
ln -sf $CONFIG_PATH/cliamp.toml ~/.config/cliamp/config.toml
[ -L ~/.config/zsh ] && rm ~/.config/zsh
ln -sf $CONFIG_PATH/zsh ~/.config/zsh

P10K_DIR="$HOME/.powerlevel10k"
P10K_REPO="https://github.com/romkatv/powerlevel10k.git"

if [ -d "$P10K_DIR/.git" ]; then
  git -C "$P10K_DIR" pull --ff-only
else
  git clone --depth=1 "$P10K_REPO" "$P10K_DIR"
fi

touch ~/.ssh/private_config
