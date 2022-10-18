
For building :

  git clone <URL to git repo >

  cd rocm-core; mkdir -p build ;  cd build

  After this invoke cmake with the following variables define as deemed fit


         cmake \
             -DCMAKE_CURRENT_BINARY_DIR=$PWD \
             -DCMAKE_CURRENT_SOURCE_DIR=$PWD/../ \
             -DCMAKE_VERBOSE_MAKEFILE=1 \
             -DCMAKE_INSTALL_PREFIX=./ \
             -DCPACK_GENERATOR=DEB \
             ..

         make
         make install
         make package

After this the package "rocm-core_1.0.0-local_amd64.deb" will be generated accordingly

The content of which will be the following :

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



The flags for the lib would the following :

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


