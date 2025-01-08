# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)


#-----------------------------------------
add_library (native-lib  SHARED
             src/main/cpp/native-lib.cpp)


#-----------------------------------------
add_library (boost_system SHARED IMPORTED)

set_target_properties( boost_system PROPERTIES IMPORTED_LOCATION
                    ${MY_BOOST_LIBS_DIR}/${ANDROID_ABI}/shared/libboost_system.so
                    )
#-----------------------------------------
add_library( boost_chrono SHARED IMPORTED)

set_target_properties(boost_chrono PROPERTIES IMPORTED_LOCATION
                    ${MY_BOOST_LIBS_DIR}/${ANDROID_ABI}/shared/libboost_chrono.so
                    )
#-----------------------------------------

include_directories( ${MY_BOOST_INC_DIR}
                    )

#-----------------------------------------
find_library (log-lib log)

#-----------------------------------------
target_link_libraries( # Specifies the target library.
                       native-lib

                       ${log-lib}

                       boost_system
                       boost_chrono

                       )




