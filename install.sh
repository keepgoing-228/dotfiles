#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

DOT_FOLDERS="zsh,p10k,tmux,git"

# install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "[✓] oh-my-zsh already installed."
fi

# install powerlevel10k
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "[+] Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "[✓] powerlevel10k already installed."
fi

# zshrc plugin: zsh-autosuggestions and pwp
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "[+] Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "[✓] zsh-autosuggestions already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/pwp" ]; then
    echo "[+] Installing pwp plugin..."
    git clone https://github.com/ttkalcevic/pwp.git "$ZSH_CUSTOM/plugins/pwp"
else
    echo "[✓] pwp already installed."
fi

# stow link dotfiles
for folder in $(echo $DOT_FOLDERS | sed "s/,/ /g"); do
    echo "[+] Folder :: $folder"
    stow --ignore=README.md --ignore=LICENSE \
        -t $HOME -D $folder
    stow -v -t $HOME $folder
done

# Reload shell once installed
echo "[+] Reloading shell..."
exec $SHELL -l
