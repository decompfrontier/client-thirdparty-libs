filename_tar=libxml2-a03fa1623ff0721f5e99fbaa26cfaa8c1388868a.tar.gz

download_dep()
{
    # nothing to download...
    return 0
}

build_dep()
{
    if ! [[ -d "$2/bakefile" ]]; then
        run_untar $2 $filename_tar "$root_script_dir/libxml2"
        if [[ $? -ne "0" ]]; then
            return 1
        fi
    fi

    cd "$2"
    ndk_root=$android_ndk_bf
    ndk_toolchain="$ndk_root/toolchains/llvm/prebuilt/$ndk_osname/bin"
    ndk_cc="$ndk_toolchain/aarch64-linux-android21-clang"
    CC=$ndk_cc ./autogen.sh --host=aarch64-linux-gnueabi --enable-static --disable-shared --without-iconv --without-lzma
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd "$2"
    make libxml2.la
    ret=$?
    cd $root_script_dir

    return $ret
}

install_dep()
{
    cp -f "$1/.libs/libxml2.a" "$2"
    cp -rf "$1/include/libxml" "$2/libxml"
    return 0
}