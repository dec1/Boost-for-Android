#!/bin/bash

#----------------------------------------------------------------
# Modify the variables below as appropriate for your local setup.
#----------------------------------------------------------------

# Specify the path to boost (unzipped) source code dir (see also `down/boost/readme.md`)
export BOOST_DIR=$(pwd)/down/boost/1.92.0


# Where the Android Ndk you want to build with is located (see also `down/ndk/readme.md)
export NDK_DIR=$(pwd)/down/ndk/r30

# Which target abis (~ architecture + instruction set) you want to build for (separate by spaces)    
export ABI_NAMES="arm64-v8a armeabi-v7a x86 x86_64"
# export ABI_NAMES="arm64-v8a"

# Whether to build boost as dynamic or shared libraries (or both)
export LINKAGES="shared static" # can be "shared" or "static" or "shared static" (both)
#export LINKAGES="shared" # can be "shared" or "static" or "shared static" (both)

#----------------------------------------------------------------

./__build.sh

