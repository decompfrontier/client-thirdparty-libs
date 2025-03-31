filename_tar=libpng-1.6.16.tar.gz

download_dep()
{
    # nothing to download...
    return 0
}

build_dep()
{
    libpng_root=$2/libpng-1.6.16

    if ! [[ -d "$libpng_root" ]]; then
        run_untar $2 $filename_tar "$root_script_dir/libpng"
        if [[ $? -ne "0" ]]; then
            return 1
        fi
    fi

    cd "$libpng_root"
    ndk_root=$android_ndk_bf
    ndk_toolchain="$ndk_root/toolchains/llvm/prebuilt/$ndk_osname/bin"
    ndk_cc="$ndk_toolchain/aarch64-linux-android21-clang"
    CC=$ndk_cc ./configure --enable-static --host=aarch64-linux-gnueabi
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd "$2"
    make libpng16.la
    ret=$?
    cd $root_script_dir

    return $ret
}

install_dep()
{
    libpng_root=$1/libpng-1.6.16
    cp -f "$libpng_root/.libs/libpng16.a" "$2"
    cp -f "$libpng_root/png.h" "$2"
    return 0
}
