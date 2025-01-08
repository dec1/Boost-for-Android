
Build and/or simply download the Boost C++ Libraries for the Android platform, with Google's Ndk.

The [Boost C++ Libraries](http://www.boost.org/), are possibly *the* most popular and generally useful c++ libraries. It would be nice to be able to use them when developing (native c++ or hybrid java/c++ with Google's [Ndk](https://developer.android.com/ndk/)) apps and/or libraries for Android devices.
The Boost libraries are written to be cross platform, and are available in source code format. However, building the libraries for a given target platform like Android can be very difficult and time consuming. (In particular, building **arm64_v8a** shared libraries that an application can actually load). This project aims to lower the barrier by offering a simple customizable build script you can use to build Boost for Android (abstracting away all the details of the underlying custom boost build system, and target architecture differences), and even providing standard prebuilt binaries to get you started fast.

Tested with **Boost 1.87.0** and **Google's Ndk 27c**  (LTS).

You can build directly on a Linux or MacOS machine, or indirectly on any of Linux, Windows, MacOS via [docker](https://www.docker.com) (or of course virtual machines and wsl). _No matter what OS you use to build with, the resulting binaries can then be copied to any other, and used from then on as if you had built them there to start with (they're cross compiled *for* android and have no memory of *where* they were built_).


Creates binaries for multiple abis (**armeabi-v7a**, **arm64-v8a**, **x86**, **x86_64**).


## Prebuilt
You can just download a current set of standard prebuilt binaries [here](https://github.com/dec1/Boost-for-Android/releases) if you don't need to customize the build, or don't have access to a unix-like development machine. 
<!--- [here](http://silverglint.com/boost-for-android/) --->

## Build Yourself

### Build using Docker
The easiest and most flexible way to build is to use [docker](https://www.docker.com). 
This way you need not need to install any build tools or other prerequisites, and can use any host operating system you wish that has docker installed. 

See [docker_readme](./docker/docker_readme.md) for instructions.

### Build directly on your Linux or MacOS machine

- Prerequisites
    - Linux: see [Dockerflile](./docker/droid_base#L18) 
    - MacOS: XCode ( Command Line Tools))
    - NDK (eg in Android studio or downloaded separately)
- Download the [boost source](https://www.boost.org) and [extract here](./boost/down/readme.md) 
    - Boost doesn't always build out of the box, so you may need to patch the source code to make necessary fixes - see [patch](./boost/patch/readme.md) 



- Clone this repo:
    - `git clone https://github.com/dec1/Boost-for-Android.git`

* Modify the paths (where the ndk is) and variables (which abis you want to build for) in _do.sh_ as you wish, and execute 
    - `cd Boost-for-Android`
    -  `./do.sh`

 If the build succeeded, then the boost binaries should now be in  **`./build/install`**

_Warning_: If you download the ndk directly do *not* extract it with [Ark](https://apps.kde.org/de/ark). It produces a corrupt extraction, that results in strange compiler errors. (use unzip instead)
```
> cd boost_for_android
> ./do.sh
```



* *__Note__:* If for some reason the build fails you may want to manually clear the */tmp/ndk-your_username* dir (which gets cleared automatically after a successful build).



## Test App 
Also included is a [test app](./example_app/) which can be opened by Android Studio. If you build and run this app it should show the date and time as calculated by boost *chrono*  (indicating that you have built, linked to and called the boost library correctly), as well as the ndk version used to build the boost library.
To use the test app make sure to adjust the values in the [local.properties](./example_app/local.properties) file.

*Note:* The test app uses [CMake for Android](https://developer.android.com/ndk/guides/cmake) and [Kotlin](https://developer.android.com/kotlin)


## *Header-only* Boost Libraries
Many of the boost libraries (eg. *algorithm*) can be used as "header only" ie do not require compilation . So you may get away with not building boost if you only
want to use these. To see which of the libraries do require building you can switch to the dir where you extracted the boost download and call:

```
> ./bootstrap.sh --show-libraries 
```

which for example with boost 1.87.0 produces the output:

```
The following Boost libraries have portions that require a separate build
and installation step. Any library not listed here can be used by including
the headers only.

The Boost libraries requiring separate building and installation are:
    - contract
    - date_time
    - exception
    - graph
    - graph_parallel
    - headers
    - locale
    - log
    - nowide
    - program_options
    - regex
    - serialization
    - test
    - thread
    - type_erasure
    - winapi
    - wave
    - variant2
    - variant
    - uuid
    - url
    - unordered
    - type_index
    - tuple
    - timer
    - throw_exception
    - system
    - stl_interfaces
    - stacktrace
    - smart_ptr
    - signals2
    - scope
    - redis
    - ratio
    - random
    - python
    - process
    - predef
    - poly_collection
    - pfr
    - parameter
    - outcome
    - optional
    - mysql
    - multi_index
    - msm
    - mpi
    - mp11
    - move
    - math
    - lockfree
    - lexical_cast
    - lambda2
    - json
    - iterator
    - iostreams
    - intrusive
    - interprocess
    - integer
    - heap
    - hana
    - geometry
    - function_types
    - function
    - flyweight
    - filesystem
    - fiber
    - endian
    - dll
    - detail
    - describe
    - crc
    - coroutine2
    - coroutine
    - core
    - conversion
    - context
    - container_hash
    - container
    - compat
    - cobalt
    - chrono
    - charconv
    - bind
    - bimap
    - beast
    - atomic
    - assert
    - asio
    - any

```


## Contributions
- Many thanks to [crystax](https://github.com/crystax/android-platform-ndk/tree/master/build/tools) for their version of _build-boost.sh which I adapted to make it work with the google ndk.

