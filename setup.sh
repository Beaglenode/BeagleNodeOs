#!/bin/sh

# Check whether the script was sourced
if [ -z "$ZSH_NAME" ] && [ "$(basename -- "$0")" = "setup.sh" ]; then
    echo "The script must be sourced, not executed"
    exit 1
fi

# Obtain the absolute dir of the called script
# https://stackoverflow.com/a/179231/1036082
pushd . > '/dev/null';
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}";

while [ -h "$SCRIPT_PATH" ];
do
    cd "$( dirname -- "$SCRIPT_PATH"; )";
    SCRIPT_PATH="$( readlink -f -- "$SCRIPT_PATH"; )";
done

cd "$( dirname -- "$SCRIPT_PATH"; )" > '/dev/null';
SCRIPT_PATH="$( pwd; )";
popd  > '/dev/null';

# go to the poky submodule dir and source the build script
cd $SCRIPT_PATH/poky

# use default build dir if not specified via parameter
if [[ -z $1 ]]; then
   BUILD_DIR=$SCRIPT_PATH/../build
else
   BUILD_DIR=$1
fi

. ./oe-init-build-env $BUILD_DIR

# Remove the  default mate-yocto-bsp layer (ignore stdout and err if removed already)
bitbake-layers remove-layer meta-yocto-bsp 2> /dev/null 1> /dev/null

# Add the relevant layers
echo "Adding submodules layers (if not added already)"
bitbake-layers add-layer $SCRIPT_PATH/meta-arm/meta-arm-toolchain 1> /dev/null
bitbake-layers add-layer $SCRIPT_PATH/meta-arm/meta-arm 1> /dev/null
bitbake-layers add-layer $SCRIPT_PATH/meta-openembedded/meta-oe 1> /dev/null
bitbake-layers add-layer $SCRIPT_PATH/meta-ti/meta-ti-bsp  1> /dev/null
bitbake-layers add-layer $SCRIPT_PATH/meta-ti/meta-ti-extras 1> /dev/null

echo "Adding custom layers (if not added already)"
bitbake-layers add-layer $SCRIPT_PATH/meta-beaglenode 1> /dev/null

# Show the layers for visual confirmation
bitbake-layers show-layers
