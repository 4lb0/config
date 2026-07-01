CONFIG_PATH=`pwd`
mkdir -p ~/.config/nvim/
ln -sf $CONFIG_PATH/init.vim ~/.config/nvim/init.vim
ln -sf $CONFIG_PATH/.zshrc ~/.zshrc
ln -sf $CONFIG_PATH/.gitconfig ~/.gitconfig
ln -sf $CONFIG_PATH/.tmux.conf ~/.tmux.conf
ln -sf $CONFIG_PATH/konsole ~/.local/share/konsole
ln -sf $CONFIG_PATH/ssh_config ~/.ssh/config
ln -sf $CONFIG_PATH/.prettierrc ~/.prettierrc
mkdir -p ~/.config/opencode
ln -sf $CONFIG_PATH/opencode.json ~/.config/opencode/opencode.json
ln -sf $CONFIG_PATH/opencode-tui.json ~/.config/opencode/tui.json
touch ~/.ssh/private_config
