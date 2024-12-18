#!/bin/bash

echo "Please enter the path to your custom configuration directory located in ~home/:"
read -r USER_INPUT
echo "Please enter pacman pacakages would like to install "
read -r PACKAGES_INPUT
echo "Please enter git username "
read -r GIT_USER_INPUT
echo "Please enter git email address "
read -r GIT_EMAIL_INPUT


# <VARIABLES>
CONFIG_PATH=${USER_INPUT:-~/Documents/configs/}
PACKAGES=${PACKAGES_INPUT:-"git base-devel vmware-horizon-client"}
GIT_USER=$GIT_USER_INPUT
GIT_EMAIL=$GIT_EMAIL_INPUT
# </VARIABLES>


# <PACMAN>
sudo pacman -Syu
sudo pacman -S --noconfirm $PACKAGES
# </PACMAN>


# <FIREFOX>
sudo pacman -S --noconfirm firefox
profile_folder=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*default-release")
if [ -z "$profile_folder" ]; then
    echo "Firefox profile folder with 'default-release' not found."
    exit 1
fi
# Path to prefs.js file in the profile folder
prefs_js_path="$profile_folder/prefs.js"

# Enable toolkit.legacyUserProfileCustomizations.stylesheets
if ! grep -q 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' "$prefs_js_path"; then
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$prefs_js_path"
    echo "Enabled toolkit.legacyUserProfileCustomizations.stylesheets in prefs.js"
else
    echo "toolkit.legacyUserProfileCustomizations.stylesheets is already enabled"
fi

css_source=$CONFIG_PATH/firefox/chrome/userChrome.css
mkdir -p "$profile_folder/chrome"
cp "$css_source" "$profile_folder/chrome/userChrome.css"
# </FIREFOX>


# <GIT>
sudo pacman -S --noconfirm git
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
# </GIT>


# <DOCKER>
sudo pacman -S --noconfirm docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER
# </DOCKER>


# <NEOVIM>
sudo pacman -S --noconfirm neovim
git clone https://github.com/NvChad/starter ~/.config/nvim
rm -rf ~/.config/nvim/*
mkdir -p ~/.config/nvim/
CONFIG_PATH=~/.config/nvim/
for item in $CONFIG_PATH*; do
    cp -r $item ~/.config/nvim/$(basename $item)
done
reset
# </NEOVIM>


# <YAY>
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
# </YAY>


# <ALACRITTY>
sudo pacman -S --noconfirm alacritty
mkdir -p ~/.config/alacritty
cp $CONFIG_PATH/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
reset
# </ALACRITTY>


# <TMUX>
sudo pacman -S --noconfirm tmux
cp $CONFIG_PATH/tmux/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
reset
# </TMUX>


# <FISH>
sudo pacman -S --noconfirm fish
echo "Changing shell to Fish"
chsh -s $(which fish) || { echo "Failed to change shell. Ensure you enter the correct password."; exit 1; }
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jorgebucaran/nvm.fish"
fish -c "fisher install PatrickF1/fzf.fish"
fisher install jorgebucaran/fish-bax
fisher install jorgebucaran/fish-nvm
fisher install jorgebucaran/fish-spin
fisher install jethrokuan/z

rm -f ~/.config/fish/config.fish
mkdir -p ~/.config/fish/
if [ -f "$CONFIG_PATH/fish/config.fish" ]; then
    cp $CONFIG_PATH/fish/config.fish ~/.config/fish/config.fish
    echo "Configuration file copied successfully."
else
    echo "Configuration file not found at $CONFIG_PATH/fish/config.fish"
    exit 1
fi
reset
# </FISH>


# <VSCODE>
cd ~/Downloads/
git clone https://aur.archlinux.org/visual-studio-code-bin.git
cd visual-studio-code-bin
makepkg -si
cd ..
rm -rf visual-studio-code-bin
reset
# </VSCODE>


# <RUST>
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
cd ~/Documents/
git clone https://github.com/rust-lang/rust.git
reset
cargo install exa
cargo install cargo-tarpaulin
sudo pacman -S --noconfirm gdb git base-devel cmake
cd ~/Downloads/
git clone https://aur.archlinux.org/rr.git
cd rr
makepkg -si
cd ..
rm -rf rr
wget -P ~ https://git.io/.gdbinit
ln -s $CONFIG_PATH/gdb/.gdbinit ~/.gdbinit
reset
# </RUST>


# <NPM>
sudo pacman -S --noconfirm nodejs npm protobuf
sudo npm i -g @bufbuild/connect-web @bufbuild/connect @bufbuild/buf @bufbuild/protobuf
# </NPM>


# <MINIKUBE>
sudo pacman -S --noconfirm kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
reset
# </MINIKUBE>


# <K9S>
sudo pacman -S --noconfirm k9s
# </K9S>


# <RIPGREP>
sudo pacman -S --noconfirm ripgrep
# </RIPGREP>


# <GITUI>
sudo pacman -S --noconfirm gitui
# </GITUI>


# <MONOSPACE>
FONT_DIR="$HOME/Downloads"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Monaspace.tar.xz"
FONT_FILE="$FONT_DIR/Monospace.tar.xz"
EXTRACT_DIR="$FONT_DIR/Monospace"
curl -L $FONT_URL -o $FONT_FILE
mkdir -p $EXTRACT_DIR
tar -xvf $FONT_FILE -C $EXTRACT_DIR
mkdir -p ~/.local/share/fonts
find $EXTRACT_DIR -name "*.otf" -exec cp {} ~/.local/share/fonts/ \;
fc-cache -fv
reset
# </MONOSPACE>


# <MOONLANDER>
sudo pacman -S --noconfirm libusb webkit2gtk gtk3
sudo bash -c 'cat > /etc/udev/rules.d/50-zsa.rules' <<EOF
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
EOF
mkdir ~/Apps
ORYX_DIR="$HOME/Apps"
ORYX_URL="https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz"
ORYX_FILE="$ORYX_DIR/keymapp-latest.tar.gz"
curl -L $ORYX_URL -o $ORYX_FILE
tar -xzf $ORYX_FILE -C $ORYX_DIR
chmod -R +x $ORYX_DIR/keymapp
rm $ORYX_FILE
reset
# </MOONLANDER>


# <HORIZON_CLIENT>
cd ~/Downloads/
git clone https://aur.archlinux.org/libudev0-shim.git
cd libudev0-shim
makepkg -si
cd ..
rm -rf libudev0-shim

cd ~/Downloads/
git clone https://aur.archlinux.org/vmware-keymaps.git
cd vmware-keymaps
makepkg -si
cd ..
rm -rf vmware-keymaps

cd ~/Downloads/
git clone https://aur.archlinux.org/vmware-horizon-client.git
cd vmware-horizon-client
makepkg -si
cd ..
rm -rf vmware-horizon-client
reset
# sudo nano /etc/gdm/custom.conf
# WaylandEnable=false
# systemctl restart gdm

# </HORIZON_CLIENT>


# <MISC>
rm -r ~/Videos ~/Pictures ~/Templates ~/Public ~/Desktop ~/icons.png
sudo hostnamectl set-hostname archy_host
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\archy_host.localdomain archy_host" | sudo tee -a /etc/hosts
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved


# tmux source ~/.tmux.conf
# </MISC>

echo "Installation completed successfully!"
