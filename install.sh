CONFIG_PATH=`pwd`
mkdir -p ~/.config/nvim/
ln -sf $CONFIG_PATH/init.vim ~/.config/nvim/init.vim
ln -sf $CONFIG_PATH/.zshrc ~/.zshrc
ln -sf $CONFIG_PATH/.gitconfig ~/.gitconfig
ln -sf $CONFIG_PATH/.tmux.conf ~/.tmux.conf
ln -sf $CONFIG_PATH/konsole ~/.local/share/konsole
ln -sf $CONFIG_PATH/ssh_config ~/.ssh/config
ln -sf $CONFIG_PATH/.prettierrc ~/.prettierrc
touch $CONFIG_PATH/.ssh/private_config
