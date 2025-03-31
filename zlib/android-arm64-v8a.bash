download_zip=https://github.com/fmrico/zlib-1.2.8/archive/refs/heads/
filename_zip=master.zip
sha256_zip=70dffbf2433a125d8e07c420fd843bf2b11a45d5a5cbfc41af691b725b6b94ff

download_dep()
{
    download_file $1 $filename_zip $download_zip $sha256_zip
    return $?
}

build_dep()
{
    zlibsrc=$2/zlib-1.2.8-master
    if ! [[ -d "$zlibsrc" ]]; then
        run_unzip $2 $filename_zip $1
        if [[ $? -ne "0" ]]; then
            return 1
        fi
    fi

    ndk_root=$android_ndk_bf
    ndk_toolchain="$ndk_root/toolchains/llvm/prebuilt/$ndk_osname/bin"
    ndk_cc="$ndk_toolchain/aarch64-linux-android21-clang"

    cd $zlibsrc
    CC=$ndk_cc ./configure --static
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd $zlibsrc
    make libz.a
    ret=$?
    cd $root_script_dir

    return $ret
}

install_dep()
{
    zlibsrc=${1}/zlib-1.2.8-master
    cp -f "$zlibsrc/zconf.h" "$2"
    cp -f "$zlibsrc/zlib.h" "$2"
    cp -f "$zlibsrc/libz.a" "$2"
    return 0
}
