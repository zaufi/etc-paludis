#!/bin/bash
#
# Configure environment for paludis
#

LC_ALL=en_US.UTF-8

# I don't care about tests
SKIP_FUNCTIONS="test"
# Use all cores available
MAKEOPTS="-j4"
# Reduce SPAM from cmake based builds
CMAKE_VERBOSE=OFF
# Tell to cmake.eclass to use ordinal Makefiles
CMAKE_MAKEFILE_GENERATOR='emake'

# Tell to autotools (if used) not to create useless,
# for one time build, `.d' files and reduce compilation messages.
# Also disable NLS explicitly to avoid wasting some time to build them.
EXTRA_ECONF="--disable-maintainer-mode --disable-dependency-tracking --enable-silent-rules --disable-nls --enable-fast-install"
AM_OPTS="--ignore-deps"
# Maximum number of Perl threads to use in automake for generating multiple Makefile.in files concurrently
AUTOMAKE_JOBS=4

# Prepare compiler options (use "predefined" vairables to group them),
# so particular environments may refer them to turn OFF for example...

GRAPHITE="-floop-block -floop-interchange -ftree-loop-distribution -floop-strip-mine -fgraphite-identity -fivopts"
MISC_FLAGS="-fipa-pta -fweb"
SOME_O3_FLAGS="-ftree-vectorize"
ARCH_FLAGS="-march=native -mtls-dialect=gnu2"

# Suppress useless^W warnings about unused local typedefs appeared for some packages
CXXONLY_FLAGS="-fnothrow-opt -Wno-unused-local-typedefs"

CFLAGS="-O2 -ggdb -pipe ${ARCH_FLAGS} ${SOME_O3_FLAGS} ${MISC_FLAGS}"
CXXFLAGS="${CFLAGS} ${CXXONLY_FLAGS}"
LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,--enable-new-dtags -Wl,--hash-style=gnu"

PAX_MARKINGS=XT

# Tell to glibc to use features of at least this kernel
NPTL_KERN_VER="4.6.0"

# Tune my hooks
PALUDIS_FILESYSTEM_HOOK_NO_WARNING=yes

# Setup per package environment
[ -e /usr/libexec/paludis-hooks/setup_pkg_env.bash ] && source /usr/libexec/paludis-hooks/setup_pkg_env.bash

# Detect terminal width dynamically for better [ ok ] align
save_COLUMNS=${COLUMNS}
COLUMNS=$(stty size 2>/dev/null | cut -d' ' -f2)
test -z "${COLUMNS}" && COLUMNS=${save_COLUMNS}
unset save_COLUMNS
PALUDIS_ENDCOL=$'\e[A\e['$(( ${COLUMNS:-80} - 7 ))'G'
