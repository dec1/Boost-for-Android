#!/bin/bash

# see here for info on "new paths for toolchains":
# https://developer.android.com/ndk/guides/other_build_systems

# also useful ndk details:
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md

SAVED_PATH=$PATH 
export PATH=$(pwd)/bin:$SAVED_PATH

#----------------------------------------------------


BUILD_DIR=$(pwd)/build
mkdir -p ${BUILD_DIR}


BUILD_DIR_TMP=${BUILD_DIR}/tmp

PREFIX_DIR=${BUILD_DIR}/install
mkdir -p ${PREFIX_DIR}
 
LIBS_DIR=${PREFIX_DIR}/libs
INCLUDE_DIR=${PREFIX_DIR}/include

WITHOUT_LIBRARIES="--without-python"
WITHOUT_LIBRARIES+=" --without-process"     # avoid:  "libs/process/src/shell.cpp:23:10: fatal error: 'wordexp.h' file not found" 
                                            # 'process' control very restriced in  android sandboxes anyways

# only build these libs
# WITH_LIBRARIES="--with-chrono --with-system"

#---------------------------------------------------
host_os_tag() {
    # are we building on linux or mac
    
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     echo "linux-x86_64";;
        Darwin*)    echo "darwin-x86_64";;
        *)          echo "host_os_tag_unknown"
    esac
    
}
#-------------------------------------
export HOST_OS_TAG=$(host_os_tag)

#---------------------------------------------------
num_cpu_cores() {
    # are we building on linux or mac
    
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)     echo $(grep -c ^processor /proc/cpuinfo);;
        Darwin*)    echo $(sysctl -n hw.ncpu);;
        *)          echo "1"
    esac
    
}
#----------------------------------------------------------------------------------
# map abi to {NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin/*-clang++
clang_triple_for_abi_name() {

    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "aarch64-linux-android21"
        ;;
        armeabi-v7a)    echo "armv7a-linux-androideabi21"
        ;;
        x86)            echo "i686-linux-android21"
        ;;
        x86_64)         echo "x86_64-linux-android21"
        ;;
        
    esac
    
}
#----------------------------------------------------------------------------------
# map abi to {NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin/*-ranlib etc
tool_triple_for_abi_name() {

    local abi_name=$1

    case "$abi_name" in
        arm64-v8a)      echo "aarch64-linux-android"
        ;;
        armeabi-v7a)    echo "arm-linux-androideabi"
        ;;
        x86)            echo "i686-linux-android"
        ;;
        x86_64)         echo "x86_64-linux-android"
        ;;
        
    esac
    
}
#----------------------------------------------------------------------------------
abi_for_abi_name() {


    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "aapcs"
        ;;
        armeabi-v7a)    echo "aapcs"
        ;;
        x86)            echo "sysv"
        ;;
        x86_64)         echo "sysv"
        ;;
        
    esac
    
}
#----------------------------------------------------------------------------------
arch_for_abi_name() {

    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "arm"
        ;;
        armeabi-v7a)    echo "arm"
        ;;
        x86)            echo "x86"
        ;;
        x86_64)         echo "x86"
        ;;
        
    esac
    
}

#----------------------------------------------------------------------------------
address_model_for_abi_name() {

    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "64"
        ;;
        armeabi-v7a)    echo "32"
        ;;
        x86)            echo "32"
        ;;
        x86_64)         echo "64"
        ;;
        
    esac
    
}
#----------------------------------------------
compiler_flags_for_abi_name() {

    local abi_name=$1
    
    COMMON_FLAGS="" #-fno-integrated-as -Wno-long-long"
    local ABI_FLAGS
    case "$abi_name" in
        armeabi-v7a)
            ABI_FLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp" 
            ;;
        arm64-v8a|x86|x86_64)
            ;;
        *)
            echo "ERROR: Unknown ABI : $ABI" 1>&2
            exit 1
    esac
    
    echo "$COMMON_FLAGS $ABI_FLAGS"
}  
#----------------------------------------------
linker_flags_for_abi_name() {

    local abi_name=$1
    
    COMMON_FLAGS=""
    local ABI_FLAGS
    case "$abi_name" in
        armeabi-v7a)
            ABI_FLAGS="-Wl,--fix-cortex-a8"
            ;;
        arm64-v8a|x86|x86_64)
            ;;
        *)
            echo "ERROR: Unknown ABI : $ABI" 1>&2
            exit 1
    esac
    
    echo "$COMMON_FLAGS $ABI_FLAGS"
}   

#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
persist_ndk_version()
{
    # Define the path to the source properties file
    local source_properties="${NDK_DIR}/source.properties"

    # Read the file contents into a variable while stripping carriage returns
    local file_contents="$(cat "$source_properties" | tr -d '\r')"
    
    # Define the output directory and header file
    local dir_path="${PREFIX_DIR}/include/boost"
    mkdir -p "$dir_path"
    local headerFile="${dir_path}/version_ndk.hpp"
    
    # Check if source.properties file exists
    if [[ ! -f "$source_properties" ]]; then
        echo "Error: $source_properties does not exist!"
        return 1
    fi

    # echo  "$source_properties contains:"
    # cat $source_properties
    # Read Pkg.ReleaseName (remove leading/trailing spaces, handle \r for carriage returns)
    local release_name="$(grep -m1 '^Pkg\.ReleaseName[[:space:]]*=' "$source_properties" \
                            | tr -d '\r' \
                            | cut -d= -f2 \
                            | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
                        )"

    
    # Read Pkg.BaseRevision (remove leading/trailing spaces, handle \r for carriage returns)
    local base_revision="$(grep -m1 '^Pkg\.BaseRevision[[:space:]]*=' "$source_properties" \
                            | tr -d '\r' \
                            | cut -d= -f2 \
                            | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
                        )"

    # Check if the variables are empty
    if [[ -z "$release_name" || -z "$base_revision" ]]; then
        echo "Error: Failed to read values from $source_properties"
        return 1
    fi

    # Concatenate ReleaseName and BaseRevision into ndk_ver
    local ndk_ver="${release_name} (${base_revision})"
    
    # Print the version to verify
    echo "NDK Version: $ndk_ver"
    
    # Write to the header file
    echo "writing NDK version $ndk_ver to $headerFile"
    
    # Create the header file with the NDK version information
    echo '#ifndef BOOST_VERSION_NDK_HPP' > "$headerFile"
    echo '#define BOOST_VERSION_NDK_HPP' >> "$headerFile"
    echo -e "\n// The version of the NDK used to build boost" >> "$headerFile"
    echo -e " #define BOOST_BUILT_WITH_NDK_VERSION  \"$ndk_ver\" \\n" >> "$headerFile"
    echo '#endif' >> "$headerFile"
}


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
fix_version_suffices() {
    # 1) remove files that are symbolic links
    # 2) remove version suffix (remaining) in:
    #    a) file names
    #    b) "soname" of the elf header

    Re0="^libboost_(.*)\.so"
    Re1="(\.[[:digit:]]+){3}$"

    for DIR_NAME in $ABI_NAMES; do
        DIR_PATH="$LIBS_DIR/$DIR_NAME"
        FILE_NAMES=$(find "$DIR_PATH" -type f)

        # echo "$FILE_NAMES"
        # echo ""
        # echo "should delete:"
        # echo "--------------"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo "$FILE_NAME" | grep -Ev "${Re0}${Re1}")
            # echo "checking file " $File
            if [ ! -z "$File" ] && ! [[ $File == cmake* ]] && ! [[ $File == *.a ]]; then
                rm "$DIR_PATH/$File"
            fi
        done

        #echo ""
        #echo "should NOT delete:"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo "$FILE_NAME" | grep -E "${Re0}${Re1}")
            if [ ! -z "$File" ]; then
                NEW_NAME=$(echo "$FILE_NAME" | grep -Eo "^libboost_[^.]+\.so")
                # echo $File " ->" $NEW_NAME
                mv "$DIR_PATH/$File" "$DIR_PATH/$NEW_NAME"
                # patchelf --set-soname $NEW_NAME $DIR_PATH/$NEW_NAME
            fi
        done
    done
}
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
do_build() 
{

    USER_CONFIG_FILE=$(pwd)/user-config.jam

    cd $BOOST_DIR

    #-------------------------------------------
    # Bootstrap
    # ---------
    if [ ! -f ${BOOST_DIR}/b2 ]
    then
    echo "Performing boost bootstrap"

    ./bootstrap.sh # 2>&1 | tee -a bootstrap.log
    fi
    
    #-------------------------------------------  

    # use as many cores as available (for build)
    num_cores=$(num_cpu_cores)
    echo " cores available = " $num_cores 



    #------------------------------------------- 
    for LINKAGE in $LINKAGES; do

        for ABI_NAME in $ABI_NAMES; do
        

            #-------------------
            LOG_FILE=${BUILD_DIR}/build_${ABI_NAME}_${LINKAGE}.log
            # clear any existing
            if [ -f "$LOG_FILE" ]  
            then 
                rm "$LOG_FILE"
            fi 

            # ------------------
            ABI_SPECIFIC_FLAGS=""
            if [ "$ABI_NAME" = "x86" ]; then
                # avoid possible memory leaks on x86
                ABI_SPECIFIC_FLAGS+=" boost.stacktrace.from_exception=off"
            fi

            # ------------------

            # toolset_name="$(toolset_for_abi_name $ABI_NAME)"
            abi="$(abi_for_abi_name $ABI_NAME)"
            address_model="$(address_model_for_abi_name $ABI_NAME)"
            arch_for_abi="$(arch_for_abi_name $ABI_NAME)"

            # used by scripts in ./bin/
            export BFA_CLANG_TRIPLE_FOR_ABI="$(clang_triple_for_abi_name $ABI_NAME)"
            export BFA_TOOL_TRIPLE_FOR_ABI="$(tool_triple_for_abi_name $ABI_NAME)"
            export BFA_COMPILER_FLAGS_FOR_ABI="$(compiler_flags_for_abi_name $ABI_NAME)"
            export BFA_LINKER_FLAGS_FOR_ABI="$(linker_flags_for_abi_name $ABI_NAME)"
            
            echo "------------------------------------------------------------"| tee -a ${LOG_FILE}
            echo "Building boost for: $ABI_NAME $LINKAGE on host ${HOST_OS_TAG}" | tee -a ${LOG_FILE}
        
            # echo "address-model=$address_model "            | tee -a ${LOG_FILE}
            # echo "architecture=$arch_for_abi "              | tee -a ${LOG_FILE}
            # echo "abi=$abi "                                | tee -a ${LOG_FILE}   
            # echo "link=$LINKAGE  "                          | tee -a ${LOG_FILE}  
            # echo "--user-config=$USER_CONFIG_FILE"          | tee -a ${LOG_FILE}

            # echo "WITH_LIBRARIES = $WITH_LIBRARIES"         | tee -a ${LOG_FILE} 
            # echo "WITHOUT_LIBRARIES = $WITHOUT_LIBRARIES"   | tee -a ${LOG_FILE} 
            # echo "ABI_SPECIFIC_FLAGS = $ABI_SPECIFIC_FLAGS"           | tee -a ${LOG_FILE}

            # echo "--builddir=${BUILD_DIR_TMP}/$ABI_NAME "  | tee -a ${LOG_FILE}
            # echo "--includedir=${INCLUDE_DIR}"              | tee -a ${LOG_FILE}
            # echo "--libdir=${LIBS_DIR}/$ABI_NAME"           | tee -a ${LOG_FILE}

            
            # echo "BFA_CLANG_TRIPLE_FOR_ABI=$(clang_triple_for_abi_name $ABI_NAME)"      | tee -a ${LOG_FILE}
            # echo "BFA_TOOL_TRIPLE_FOR_ABI=$(tool_triple_for_abi_name $ABI_NAME)"        | tee -a ${LOG_FILE}
            # echo "BFA_COMPILER_FLAGS_FOR_ABI=$(compiler_flags_for_abi_name $ABI_NAME)"  | tee -a ${LOG_FILE}
            # echo "BFA_LINKER_FLAGS_FOR_ABI=$(linker_flags_for_abi_name $ABI_NAME)"      | tee -a ${LOG_FILE}
            
            echo "------------------------------------------------------------"| tee -a ${LOG_FILE}
            # toolset=clang-$toolset_name     \
                                    
            {
                ./b2 -q -j$num_cores    \
                    binary-format=elf \
                    address-model=$address_model \
                    architecture=$arch_for_abi \
                    abi=$abi    \
                    link=$LINKAGE                  \
                    threading=multi              \
                    target-os=android           \
                    --user-config=$USER_CONFIG_FILE \
                    --ignore-site-config         \
                    --layout=system           \
                    $WITH_LIBRARIES           \
                    $WITHOUT_LIBRARIES           \
                    $ABI_SPECIFIC_FLAGS \
                    --build-dir=${BUILD_DIR_TMP}/$ABI_NAME/$LINKAGE \
                    --includedir=${INCLUDE_DIR} \
                    --libdir=${LIBS_DIR}/$ABI_NAME/$LINKAGE \
                    install 2>&1                 \
                    || { echo "Error: Failed to build boost for $ABI_NAME!";}
            } | tee -a ${LOG_FILE}
            
        done # for ABI_NAME in $ABI_NAMES
        
    done # for LINKAGE in $LINKAGES
}
#------------------------------------------- 

# do_build 

persist_ndk_version

# fix_version_suffices

echo "built boost to "  ${PREFIX_DIR}


export PATH=$SAVED_PATH



