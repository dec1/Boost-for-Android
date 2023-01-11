# Author: Declan Moran (www.silverglint.com)


# Extract boost (src) archive to a directory of the form "major.minor.patch" 
# such that eg ...../1.79.0/bootstrap.sh, etc



#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Modify the variables below as appropriate for your local setup.
#----------------------------------------------------------------

# Specify the path to boost source code dir 
export BOOST_DIR=$(pwd)/../down/boost/1.79.0


# Where the Android Ndk you want to build with is located
export NDK_DIR=$(pwd)/../down/ndk/25

# Which target abis (~ architecture + instruction set) you want to build for     
export ABI_NAMES="arm64-v8a armeabi-v7a x86 x86_64"

# Whether to build boost as dynamic or shared libraries (or both)
export LINKAGES="" #shared static" # can be "shared" or "static" or "shared static" (both)

#For building boost with bzip2 sources
export BZIP2_SOURCES_PATH=$(pwd)/../../bzip/bzip2-master #path to bzip sources, in this you would have to create bz_version.h(in actual source this file will be present as bz_version.h.in template and in bzip cmake build this will be created)
#But for b2 build you need to create this file manually, just rename bz_version.h.in to bz_version.h
export BOOST_LIB_VISIBILITY="global" #possible values - global, protected, hidden.(https://www.boost.org/doc/libs/1_73_0/tools/build/doc/html/index.html#bbv2.builtin.features.visibility)
#The visibility should be set to global because boost_iostreams depends on symbols exported by bzip and if visibility is not set to global then all libs will be generated with hidden visiblity and boost_iostreams will fail in runtime saying not able to find "BZ2_bz..." symbol.

#----------------------------------------------------------------

./__build.sh
