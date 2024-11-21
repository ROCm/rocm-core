# ROCM-CORE

rocm-core is a utility which can be used to get ROCm release version. 
It also provides the Lmod modules files for the ROCm release.
getROCmVersion function provides the ROCm version. 

Lmod module files can be loaded with the following commads.
module load rocm/x.y or 
module load rocm

You can find sources and binaries in our [GitHub repository](https://github.com/ROCm/rocm-core).

> [!NOTE]
> As with all ROCm projects, the documentation is open source. For more information, see [Contribute to ROCm documentation](https://rocm.docs.amd.com/en/latest/contribute/contributing.html).

## Building our documentation

To build the ROCM-CORE documentation locally, run the following code from within the `docs` folder in
our repository:

``` shell
cd docs

pip3 install -r sphinx/requirements.txt

python3 -m sphinx -T -E -b html -d _build/doctrees -D language=en . _build/html
```

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
  git clone <URL to git repo >
```

Go to Root Directory, create a build directory:

```shell
  cd rocm-core; mkdir -p build ;  cd build
```

Next, configure CMake. Invoke cmake with the following variables define as deemed fit

```shell
         cmake \
             -DCMAKE_CURRENT_BINARY_DIR=$PWD \
             -DCMAKE_CURRENT_SOURCE_DIR=$PWD/../ \
             -DCMAKE_VERBOSE_MAKEFILE=1 \
             -DCMAKE_INSTALL_PREFIX=./ \
             -DCPACK_GENERATOR=DEB \
             -DCPACK_DEBIAN_PACKAGE_RELEASE="local.9999~20.04" \
             -DCPACK_RPM_PACKAGE_RELEASE="local.9999" \
             -DROCM_VERSION="5.5.0" \
             ..
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
After this the package "rocm-core_1.0.0-local_amd64.deb" will be generated accordingly
The content of which will be the following :

```shell
$dpkg -I rocm-core_1.0.0-local_amd64.deb
 new Debian package, version 2.0.
 size 6604 bytes: control archive=1608 bytes.
     285 bytes,    10 lines      control
     191 bytes,     3 lines      md5sums
    2360 bytes,    65 lines   *  postinst             #!/bin/bash
     593 bytes,    25 lines   *  prerm                #!/bin/bash
 Architecture: amd64
 Description: Radeon Open Compute (ROCm) Runtime software stack
 Homepage: https://github.com/RadeonOpenCompute/ROCm
 Maintainer: ROCm Dev Support <rocm-dev.support@amd.com>
 Package: rocm-core
 Priority: optional
 Section: devel
 Version: 1.0.0-local
 Installed-Size: 70


$dpkg -c rocm-core_1.0.0-local_amd64.deb
drwxrwxr-x root/root         0 2022-11-09 09:02 ./opt/
drwxrwxr-x root/root         0 2022-11-09 09:02 ./opt/rocm/
drwxrwxr-x root/root         0 2022-11-09 09:02 ./opt/rocm/include/
-rw-r--r-- root/root      2970 2022-11-09 09:02 ./opt/rocm/include/rocm_version.h
drwxrwxr-x root/root         0 2022-11-09 09:02 ./opt/rocm/lib/
lrwxrwxrwx root/root         0 2022-11-09 09:02 ./opt/rocm/lib/librocm-core.so -> librocm-core.so.1
lrwxrwxrwx root/root         0 2022-11-09 09:02 ./opt/rocm/lib/librocm-core.so.1 -> librocm-core.so.1.0.0.
-rwxr-xr-x root/root     17096 2022-11-09 09:02 ./opt/rocm/lib/librocm-core.so.1.0.0.
-rw-r--r-- root/root       420 2022-11-09 09:02 ./opt/rocm/lib/rocmmod
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
$readelf -d ./opt/rocm/lib/librocm-core.so.1.0.0.

Dynamic section at offset 0x2de0 contains 28 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libstdc++.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libgcc_s.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000e (SONAME)             Library soname: [librocm-core.so.1]
 0x000000000000000c (INIT)               0x1000
 0x000000000000000d (FINI)               0x12dc
 0x0000000000000019 (INIT_ARRAY)         0x3dd0
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x3dd8
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x000000006ffffef5 (GNU_HASH)           0x2f0
 0x0000000000000005 (STRTAB)             0x480
 0x0000000000000006 (SYMTAB)             0x318
 0x000000000000000a (STRSZ)              558 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000003 (PLTGOT)             0x4000
 0x0000000000000002 (PLTRELSZ)           168 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x820
 0x0000000000000007 (RELA)               0x760
 0x0000000000000008 (RELASZ)             192 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffffb (FLAGS_1)            Flags: NODELETE
 0x000000006ffffffe (VERNEED)            0x6d0
 0x000000006fffffff (VERNEEDNUM)         3
 0x000000006ffffff0 (VERSYM)             0x6ae
 0x000000006ffffff9 (RELACOUNT)          3
 0x0000000000000000 (NULL)               0x0
```


## Formatting the code

All the code is formatted using `clang-format`. To format a file, use:

```shell
clang-format-10 -style=file -i <path-to-source-file>
```

To format the code per commit, you can install githooks:

```shell
./.githooks/install
```

