# Collects system information for diagnosing ROCm issues, and outputs them to stdout.
# Should be run as superuser.
#
# Collects the following information:
#     - OS (from /etc/os-release)
#     - Linux kernel version (from uname)
#     - CPU information (from lscpu)
#     - Loaded kernel modules (from dkms)
#     - The 'amdgpu udev rule' (from /etc/udev/rules.d/70-amdgpu.rules)
#     - Devices on the PCI bus (from lspci)
#     - ROCm repo information (from a search for entries in /etc/apt, /etc/zypp, and /etc/yum)
#     - ROCm packages installed (from dpkg and rpm)
#     - ROCm ldconfig entries (/etc/ld.so.conf.d)
#     - ROCm ldcache entries (from ldconfig)
#     - ROCm available versions (from a search for /etc/opt/rocm*)
#     - ROCm System Management Interface: concise hardware info (from rocm-smi)
#     - rocminfo output (HSA agents)
#     - clinfo output (OpenCL info)
#     - Hardware topography (output of lstopo-no-graphics, if it is installed on the system)

# Figure out which package we are on
declare pkgtype="rpm"
if cat /etc/os-release | grep --ignore-case --extended-regexp 'debian|ubuntu' > /dev/null 2> /dev/null; then
    pkgtype="deb"
fi

# Figure out where the ROCm opt binaries are
declare rocm_opt_path="$(ls -v -d /opt/rocm-[3-9]* | tail -1)"
if [ -z "${rocm_opt_path}" ]; then
    rocm_opt_path="$(ls -v -d /opt/rocm* | tail -1)"
fi

cat << EOF
===== ----- ------ ----- =====
START: ROCM SYSTEM INFORMATION
===== ----- ------ ----- =====
EOF

# OS
cat << EOF
----- ----- ----- ----- -----
Start: OS
----- ----- ----- ----- -----
EOF

cat /etc/os-release

cat << EOF
----- ----- ----- ----- -----
END: OS
----- ----- ----- ----- -----
EOF


# Linux kernel information
cat << EOF
----- ----- ----- ----- -----
Start: Linux Kernel
----- ----- ----- ----- -----
EOF

uname --kernel-name --kernel-release --kernel-version

cat << EOF
----- ----- ----- ----- -----
END: Linux Kernel
----- ----- ----- ----- -----
EOF


# CPU information
cat << EOF
----- ----- ----- ----- -----
Start: CPU
----- ----- ----- ----- -----
EOF

lscpu

cat << EOF
----- ----- ----- ----- -----
END: CPU
----- ----- ----- ----- -----
EOF


# Loaded kernels
cat << EOF
----- ----- ----- ----- -----
Start: Loaded kernel modules
----- ----- ----- ----- -----
EOF

dkms status

cat << EOF
----- ----- ----- ----- -----
END: Loaded kernel modules
----- ----- ----- ----- -----
EOF


# AMDGPU udev rule
cat << EOF
----- ----- ----- ----- -----
Start: amdgpu udev rule
----- ----- ----- ----- -----
EOF

cat /etc/udev/rules.d/70-amdgpu.rules

cat << EOF
----- ----- ----- ----- -----
END: amdgpu udev rule
----- ----- ----- ----- -----
EOF


# PCI information
cat << EOF
----- ----- ----- ----- -----
Start: PCI information
----- ----- ----- ----- -----
EOF

lspci -vvvt
lspci -vvv

cat << EOF
----- ----- ----- ----- -----
END: PCI information
----- ----- ----- ----- -----
EOF


# ROCm repo information
cat << EOF
----- ----- ----- ----- -----
Start: ROCm repo information
----- ----- ----- ----- -----
EOF

grep --ignore-case --extended-regexp 'rocm|amdgpu' /etc/apt/sources.list.d/* /etc/zypp/repos.d/* /etc/yum.repos.d/*

cat << EOF
----- ----- ----- ----- -----
END: ROCm repo information
----- ----- ----- ----- -----
EOF


# ROCm packages installed
cat << EOF
----- ----- ----- ----- -----
Start: ROCm packages installed
----- ----- ----- ----- -----
EOF

if [ "$pkgtype" = "deb" ]; then
    dpkg -l | grep --ignore-case --extended-regexp 'ocl-icd|kfdtest|llvm-amd|miopen|half|^ii  hip|hcc|hsa|rocm|atmi|^ii  comgr|composa|amd-smi|aomp|amdgpu|rock|mivision|migraph|rocprofiler|roctracer|rocbl|hipify|rocsol|rocthr|rocff|rocalu|rocprim|rocrand|rccl|rocspar|rdc|rocwmma|rpp|openmp|amdfwflash|ocl|opencl' | sort
else
    rpm -qa | grep --ignore-case --extended-regexp 'ocl-icd|kfdtest|llvm-amd|miopen|half|hip|hcc|hsa|rocm|atmi|comgr|composa|amd-smi|aomp|amdgpu|rock|mivision|migraph|rocprofiler|roctracer|rocblas|hipify|rocsol|rocthr|rocff|rocalu|rocprim|rocrand|rccl|rocspar|rdc|rocwmma|rpp|openmp|amdfwflash|ocl|opencl' | sort
fi

cat << EOF
----- ----- ----- ----- -----
END: ROCm packages installed
----- ----- ----- ----- -----
EOF


# ROCm ldconfig entries
cat << EOF
----- ----- ----- ----- -----
Start: ROCm ldconfig entries
----- ----- ----- ----- -----
EOF

grep --ignore-case --extended-regexp 'rocm' /etc/ld.so.conf.d/*

cat << EOF
----- ----- ----- ----- -----
END: ROCm ldconfig entries
----- ----- ----- ----- -----
EOF


# ROCm ldcache entries
cat << EOF
----- ----- ----- ----- -----
Start: ROCm ldcache entries
----- ----- ----- ----- -----
EOF

ldconfig -p | /bin/grep --ignore-case --extended-regexp 'rocm'

cat << EOF
----- ----- ----- ----- -----
END: ROCm ldcache entries
----- ----- ----- ----- -----
EOF


# ROCm available versions
cat << EOF
----- ----- ----- ----- -----
Start: ROCm available versions
----- ----- ----- ----- -----
EOF

ls -v -d /opt/rocm*

cat << EOF
----- ----- ----- ----- -----
END: ROCm available versions
----- ----- ----- ----- -----
EOF


# ROCm System management interface: concise hardware info
cat << EOF
----- ----- ----- ----- -----
Start: ROCm System Management Interface: concise hardware info
----- ----- ----- ----- -----
EOF

$rocm_opt_path/bin/rocm-smi --showhw

cat << EOF
----- ----- ----- ----- -----
END: ROCm System management Interface: concise hardware info
----- ----- ----- ----- -----
EOF


# rocminfo
cat << EOF
----- ----- ----- ----- -----
Start: rocminfo
----- ----- ----- ----- -----
EOF

$rocm_opt_path/bin/rocminfo

cat << EOF
----- ----- ----- ----- -----
END: rocminfo
----- ----- ----- ----- -----
EOF


# clinfo
cat << EOF
----- ----- ----- ----- -----
Start: clinfo
----- ----- ----- ----- -----
EOF

if [ -f $rocm_opt_path/opencl/bin/clinfo ]; then
    # Path as of 3.5
    $rocm_opt_path/opencl/bin/clinfo
else
    $ROCM_VERSION/opencl/bin/x86_64/clinfo
fi

cat << EOF
----- ----- ----- ----- -----
END: clinfo
----- ----- ----- ----- -----
EOF


# lstopo; may not be present on every system.
cat << EOF
----- ----- ----- ----- -----
Start: lstopo (may not be present on all systems)
----- ----- ----- ----- -----
EOF

lstopo-no-graphics

cat << EOF
----- ----- ----- ----- -----
END: lstopo (may not be present on all systems)
----- ----- ----- ----- -----
EOF
