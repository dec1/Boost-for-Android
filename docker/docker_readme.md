

# Docker

The easiest and most flexible way to build is to use [docker](https://www.docker.com). 
This way you need not need to install any build tools or other prerequisites, and can use any host operating system you wish that has docker installed.
You only need to download and extract the two archives: [boost sources](https://www.boost.org) and [android ndk](https://developer.android.com/ndk) to your host machine. 



## (1) Clone this repo:

`> git clone https://github.com/dec1/Boost-for-Android.git ./boost_for_android` 

`> cd boost_for_android`

## (2) Download  boost and ndk 

And extract then to the sub dir *down* (eg to *down/boost/1.71.1/bootstrap.sh...* and *down/ndk/20/source.properties....* etc).

If necessary, modify the variables in *./do.sh*, to match these paths (and/or required build configuration).

If necessary, fix any bugs in boost  (eg for [1.71.0](https://github.com/boostorg/build/issues/385)).


## (3) Build docker image

build docker image *my_img_droid_base* from the docker file *droid_base* (using the *docker* dir as the *build context*)

`> docker build -t my_img_droid_base -f docker/droid_base ./docker` 

    
## (4) Run docker container

Run a docker container *my_ctr_droid_base* from this image, mounting the current dir as */home/bfa*

If you have downloaded boost and ndk as suggested to this (host) dir then they will automatically be available in the */home/bfa/down* dir of the container too.
(Otherwise you need to mount the respective paths additionally).

_Note_:
* Need to pass absolute host paths to mount volume hence _$(pwd)_. 
* We want the container to run with the same user id as you have on your host and not as root (the default). Hence the *$(id -u):$(id -g)*

`> docker run -v $(pwd):/home/bfa -it --entrypoint=/bin/bash --user $(id -u):$(id -g) --workdir /home/bfa --name my_ctr_droid_base my_img_droid_base`

If a container with this name already exists you must first delete it first with

- `> docker rm my_ctr_droid_base`

Remove any existing build directory (from any previous build) 
- `> sudo rm -rf build`


## (5) Build boost inside docker container

Now inside docker container, build boost.

`$./do.sh`


## (6) Exit container
Boost should be built in the dir */build/install* (by default)

`$ exit`



