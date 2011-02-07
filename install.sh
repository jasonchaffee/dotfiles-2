#!/bin/bash

function link {
    rm -r $HOME/.$1
    ln -s `pwd`/$1 $HOME/.$1
}

link zshrc
link muttrc
link hgrc
link gitconfig
mkdir $HOME/.bazaar
rm $HOME/.bazaar/bazaar.conf
ln -s `pwd`/bazaar.conf $HOME/.bazaar/bazaar.conf
if [[ $(uname) = 'Linux' ]]; then
    QUAKE=$HOME/.quakelive/quakelive/home/baseq3
elif [[ $(uname) = 'Darwin' ]]; then
    QUAKE=$HOME/Library/Application\ Support/QuakeLive/quakelive/home/baseq3
fi
if [ -d $QUAKE ]; then
    rm $QUAKE/lol2fast4u.cfg $QUAKE/autoexec.cfg
    ln -s `pwd`/lol2fast4u.cfg $QUAKE/lol2fast4u.cfg
    echo 'exec "lol2fast4u.cfg"' > $QUAKE/autoexec.cfg
fi