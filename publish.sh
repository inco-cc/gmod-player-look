#!/bin/sh

dir=$PWD
gmpublish=$HOME/.local/share/Steam/steamapps/common/GarrysMod/bin/linux64/gmpublish

[ ! -e $gmpublish ] && echo 'Please configure your gmpublish path.' >&2 && exit 1

$gmpublish create -addon $PWD/`basename $PWD`.gma -icon $PWD/icon.jpg
