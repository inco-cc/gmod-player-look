#!/bin/sh

gmad=$HOME/.steam/steam/steamapps/common/GarrysMod/bin/linux64/gmad

[ ! -e $gmad ] && echo 'Please configure your gmad path.' >&2 && exit 1

$gmad create -folder $PWD -out $PWD/`basename $PWD`.gma
