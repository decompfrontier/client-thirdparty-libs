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
    ndk_cc="$ndk_toolchain/$target_arch-linux-android21-clang"
    CC=$ndk_cc ./configure --enable-static --disable-shared --host=$target_arch-linux-gnueabi
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd "$libpng_root"
    make libpng16.la
    ret=$?
    cd $root_script_dir

    #if [[ $ret -ne "0" ]]; then
        # this fixes a shitty bug on the x86_64 build
    #   mkdir -p "$libpng_root/.libs/.libs"
    #    cd "$libpng_root/.libs"
    #    cp \*.o .libs/
    #    cd $root_script_dir

    #    cd "$libpng_root"
    #    make libpng16.la
    #    ret=$?
    #    cd $root_script_dir
    #fi

    return $ret
}

install_dep()
{
    libpng_root=$1/libpng-1.6.16
    cp -f "$libpng_root/.libs/libpng16.a" "$2"
    cp -f "$libpng_root/png.h" "$2"
    cp -f "$libpng_root/pnglibconf.h" "$2"
    cp -f "$libpng_root/pngconf.h" "$2"
    return 0
}
