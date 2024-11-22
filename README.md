# ROCM-CORE Introduction

rocm-core is a utility which can be used to get ROCm release version. 
It also provides the Lmod modules files for the ROCm release.
getROCmVersion function provides the ROCm version. 

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
  cd rocm-core; mkdir -p build ;  cd build
```

Next, configure CMake. Invoke cmake with the following variables define as deemed fit

```shell
cmake '-DCMAKE_PREFIX_PATH=/opt/rocm-6.4.0' \ 
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_VERBOSE_MAKEFILE=1 \
-DCPACK_GENERATOR=DEB \
-DROCM_PATCH_VERSION=60400 \
-DCMAKE_INSTALL_PREFIX=/opt/rocm-6.4.0 \
-DCPACK_PACKAGING_INSTALL_PREFIX=/opt/rocm-6.4.0 \
-DROCM_DEP_ROCMCORE=ON \
-DFILE_REORG_BACKWARD_COMPATIBILITY=OFF \
-DCPACK_RPM_PACKAGE_RELOCATABLE=ON \
-DCPACK_SET_DESTDIR=OFF \
-DINCLUDE_PATH_COMPATIBILITY=OFF \
-DCMAKE_INSTALL_LIBDIR=lib \
-DBUILD_SHARED_LIBS=ON \
-DCPACK_DEBIAN_PACKAGE_RELEASE=crdnnh.15156~22.04 \
-DCPACK_RPM_PACKAGE_RELEASE=crdnnh.15156 \
-DROCM_VERSION=6.4.0 \
-DBUILD_ID=15156 \
```
>[!NOTE]
>When specifying the path for the `CMAKE_PREFIX_PATH` variable, **do not** use the tilde (`~`)
>shorthand to represent the home directory.

### Install

```shell
         make
         make install
```

### Package Generated

```shell
         make package
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

The flags for the lib would the following :

```shell
$ readelf -d ./opt/rocm-6.4.0/lib/librocm-core.so.1.0.60400

Dynamic section at offset 0x2de8 contains 27 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [librocm-core.so.1]
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN]
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x15f0
 0x0000000000000019 (INIT_ARRAY)         0x3dd8
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3de0
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x2f0
 0x0000000000000005 (STRTAB)             0x590
 0x0000000000000006 (SYMTAB)             0x320
 0x000000000000000a (STRSZ)              384 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x4000
 0x0000000000000002 (PLTRELSZ)           408 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x868
 0x0000000000000007 (RELA)               0x7a8
 0x0000000000000008 (RELASZ)             192 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffffb (FLAGS_1)            Flags: NODELETE
 0x000000006ffffffe (VERNEED)            0x748
 0x000000006fffffff (VERNEEDNUM)         1
 0x000000006ffffff0 (VERSYM)             0x710
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000000 (NULL)               0x0

```

