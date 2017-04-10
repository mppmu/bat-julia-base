# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_install() {
    mkdir -p src && (
        cd src
        GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
        GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`
        git clone "https://github.com/${GITHUB_USER}/bat"
        cd bat
        git checkout "${GIT_BRANCH}"
        ./autogen.sh
    )

    mkdir -p build/bat && (
        cd build/bat
        ../../src/bat/configure \
            --prefix="${INSTALL_PREFIX}" \
            --enable-roostats --enable-parallel --with-cuba=download
        time make -j"$(nproc)" install
    )
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
CPATH="${INSTALL_PREFIX}/include:\$CPATH"
PKG_CONFIG_PATH="${INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH LD_LIBRARY_PATH CPATH PKG_CONFIG_PATH
EOF
}
