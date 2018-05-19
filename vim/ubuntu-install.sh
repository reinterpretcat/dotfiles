#!/bin/bash
set -e

echo 'Install common dependencies..'
apt update && apt install -y \
    vim git wget             \
    clang                    \
    autoconf pkg-config        # for universal ctags


echo 'Install plugin manager..'
VundleDir=~/.vim/bundle/Vundle.vim
if [ ! -d "$VundleDir" ] ; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VundleDir
fi;


echo 'Install plugin dependencies..'
#
# powerline
 apt install -y fonts-powerline

#
#fzf
apt install silversearcher-ag
FzfDir=~/.fzf
if [ ! -d "$FzfDir" ] ; then
    git clone --depth 1 https://github.com/junegunn/fzf.git $FzfDir
    $FzfDir/install
fi;

#
# YouCompleteMe
YcmDir=~/.vim/bundle/YouCompleteMe
if [ ! -d "$YcmDir" ] ; then
    apt-get install -y build-essential cmake python-dev python3-dev
    git clone https://github.com/Valloric/YouCompleteMe.git $YcmDir
    cd $YcmDir
    git submodule update --init --recursive
    # See docs for extra languages support
    ./install.py --clang-completer
    cd ~
fi;

# ctags
if ! [ -x "$(command -v ctags)" ]; then
    cd /tmp
    git clone https://github.com/universal-ctags/ctags.git
    cd ctags
    ./autogen.sh && ./configure && make && make install
fi;

echo 'Copy vim configs..'
cp $DOTFILES_DIR/vim/vimrc.ide ~/.vimrc.ide
cp $DOTFILES_DIR/vim/vimrc.plugins ~/.vimrc.plugins

echo 'Install vim plugins..'
vim -u ~/.vimrc.plugins +BundleInstall +qall

