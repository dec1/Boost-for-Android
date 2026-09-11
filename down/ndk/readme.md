### NDK 

Download and extract the android NDK  here to automatically mount it when building with docker.
You can manually mount it found somewhere else when building with docker.
If not using docker it doenst matter where you (or Android Studio) download it  

In all cases ensure that `NDK_DIR` in `do.sh` points to the correct location.



- Extract the archive into a subdir of this dir 

- You should then have something like:

    ```bash
    readme.md               # ie this file
    NDK_DIR                 # where the exact name of this dir reflects the version of NDK you downloaded
        source.properties 
        sources  
        toolchains  
        wrap.sh
        ......
    ```

