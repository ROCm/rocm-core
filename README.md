# ROCM-CORE Introduction

ROCM-CORE is a package which can be used to get ROCm release version, get ROCm install path information etc.
It is also important to note that ROCM-CORE takes the role as a base component on which all of ROCm can depend,
to make it easy to remove all of ROCm with a package manager.

getROCmVersion function provides the ROCm version. 

It also provides an example Lmod modules files for the ROCm release.

Lmod module files can be loaded with the following commands.
``` shell
module load rocm/x.y or 
module load rocm
```

You can find sources and binaries in our [GitHub repository](https://github.com/ROCm/rocm-core).

> [!NOTE]
> As with all ROCm projects, the documentation is open source. For more information, see [Contribute to ROCm documentation](https://rocm.docs.amd.com/en/latest/contribute/contributing.html).

## Installing ROCM-CORE

To install ROCM-CORE, you must first install these prerequisites:

* A [ROCm](https://rocm.docs.amd.com/)-enabled platform

### Installing with pre-built packages

You can install ROCM-CORE on Ubuntu using

```shell
apt-get install rocm-core
```

## Building ROCM-CORE from source

You can build ROCM-CORE form source

First, get the sources from repository.

```shell
  git clone https://github.com/ROCm/rocm-core.git
```

Go to Root Directory, create a build directory:

```shell
  cd rocm-core; mkdir build; cd build
```

Next, configure CMake. Invoke cmake with the following variables define as deemed fit

```shell
cmake -S $PWD/../ -B . \
    -DCMAKE_VERBOSE_MAKEFILE=1 \
    -DCMAKE_INSTALL_PREFIX=./ \
    -DROCM_VERSION="6.4.0" \
    ..
```

>[!NOTE]
>When specifying the path for the `CMAKE_PREFIX_PATH` variable, **do not** use the tilde (`~`)
>shorthand to represent the home directory.

### Install

Once cmake configuration successfully completed, from the same build directory run build, install commands

```shell
cmake --build .
cmake --install .
```

### Package Generated

Once cmake configuration and build successfully completed from the same build directory trigger package generation

```shell
cpack
```

After this the package "rocm-core_6.4.0.60400-crdnnh.15158~22.04_amd64.deb" will be generated accordingly
The content of which will be the following :

```shell
$ dpkg -I rocm-core_6.4.0.60400-crdnnh.15158~22.04_amd64.deb
 new debian package, version 2.0.
 size 13986 bytes: control archive=2083 bytes.
     305 bytes,    10 lines      control
     917 bytes,    11 lines      md5sums
    2871 bytes,    75 lines   *  postinst             #!/bin/bash
     873 bytes,    32 lines   *  prerm                #!/bin/bash
 Architecture: amd64
 Description: Radeon Open Compute (ROCm) Runtime software stack
 Homepage: https://github.com/RadeonOpenCompute/ROCm
 Maintainer: ROCm Dev Support <rocm-dev.support@amd.com>
 Package: rocm-core
 Priority: optional
 Section: devel
 Version: 6.4.0.60400-crdnnh.15158~22.04
 Installed-Size: 125

$ dpkg -c rocm-core_6.4.0.60400-crdnnh.15158~22.04_amd64.deb
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/.info/
-rw-r--r-- root/root        12 2024-11-22 10:37 ./opt/rocm-6.4.0/.info/version
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/include/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/include/rocm-core/
-rw-r--r-- root/root      2801 2024-11-22 10:37 ./opt/rocm-6.4.0/include/rocm-core/rocm_getpath.h
-rw-r--r-- root/root      2440 2024-11-22 10:37 ./opt/rocm-6.4.0/include/rocm-core/rocm_version.h
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/rocm-core/
-rw-r--r-- root/root      2878 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/rocm-core/rocm-core-config-version.cmake
-rw-r--r-- root/root      1590 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/rocm-core/rocm-core-config.cmake
-rw-r--r-- root/root       842 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/rocm-core/rocmCoreTargets-release.cmake
-rw-r--r-- root/root      3774 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/cmake/rocm-core/rocmCoreTargets.cmake
lrwxrwxrwx root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/librocm-core.so -> librocm-core.so.1
lrwxrwxrwx root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/librocm-core.so.1 -> librocm-core.so.1.0.60400
-rw-r--r-- root/root     16640 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/librocm-core.so.1.0.60400
-rw-r--r-- root/root       550 2024-11-22 10:37 ./opt/rocm-6.4.0/lib/rocmmod
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/libexec/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/libexec/rocm-core/
-rw-r--r-- root/root      8208 2024-11-22 10:34 ./opt/rocm-6.4.0/libexec/rocm-core/runpath_to_rpath.py
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/share/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/share/doc/
drwxr-xr-x root/root         0 2024-11-22 10:37 ./opt/rocm-6.4.0/share/doc/rocm-core/
-rw-r--r-- root/root      1113 2024-11-22 10:34 ./opt/rocm-6.4.0/share/doc/rocm-core/LICENSE.txt


```

### Setting up locations

By default, the install location is set to `/opt/rocm`. You can change this using
`CMAKE_INSTALL_PREFIX`:

```shell
cmake -DCMAKE_INSTALL_PREFIX=<rocm-core-install-path> ..
```

## ROCM-CORE Library

ROCM-CORE Library generated will be found in lib directory of the rocm-core package generated.

```shell
find . -name librocm-core.so.*
```

### Sample Usage of APIs provided by rocm-core Library
#### Get ROCm Version

For getting ROCm Version make use of getROCMVersion() API.
Sample Usage Example as shown below.

```shell
//  Usage :
 int mj=0,mn=0,p=0,ret=0;
 ret=getROCMVersion(&mj,&mn,&p);
 if(ret !=VerSuccess )  // error occured
```

