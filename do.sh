#!/bin/bash

#----------------------------------------------------------------
# Modify the variables below as appropriate for your local setup.
#----------------------------------------------------------------

# Specify the path to boost (unzipped) source code dir 
export BOOST_DIR=$(pwd)/boost/down/1.87.0


# Where the Android Ndk you want to build with is located
export NDK_DIR=~/Library/Android/sdk/ndk/27.2.12479018

# Which target abis (~ architecture + instruction set) you want to build for (separate by spaces)    
export ABI_NAMES="arm64-v8a armeabi-v7a x86 x86_64"
# export ABI_NAMES="arm64-v8a"

# Whether to build boost as dynamic or shared libraries (or both)
export LINKAGES="shared static" # can be "shared" or "static" or "shared static" (both)
#export LINKAGES="shared" # can be "shared" or "static" or "shared static" (both)

#----------------------------------------------------------------

./__build.sh

