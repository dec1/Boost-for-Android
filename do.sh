# Author: Declan Moran (www.silverglint.com)


# Extract boost (src) archive to a directory of the form "major.minor.patch" 
# such that eg ...../1.72.0/bootstrap.sh, etc



#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Modify the variables below as appropriate for your local setup.
#----------------------------------------------------------------

# Specify the path to boost source code dir 
export BOOST_DIR=/Users/bytedance/workspace/android/_video/reportSDK/report/deps/boost_1_68_0


# Where the Android Ndk you want to build with is located
export NDK_DIR=$NDK_ROOT

# Which target abis (~ architecture + instruction set) you want to build for     
export ABI_NAMES="arm64-v8a armeabi-v7a x86 x86_64"

# Whether to build boost as dynamic or shared libraries (or both)
export LINKAGES="static" # can be "shared" or "static" or "shared static" (both)


#----------------------------------------------------------------

./build.sh
