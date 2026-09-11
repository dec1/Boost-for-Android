### Boost


- [download](https://www.boost.org/users/download/) boost source code
- Extract the archive into a subdir of this dir 

- You should then have something like:

    ```bash
    readme.md           # ie this file
    1.92.0              # where the exact name of this dir reflects the version of boost you downloaded
        boostcpp.jam
        bootstrap.bat
        bootstrap.sh
        index.htm
        index.html
        ......
    ```

Ensure that `BOOST_DIR` in `do.sh` points to the correct location.