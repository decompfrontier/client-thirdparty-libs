filename_tar=$tiff_filename.tar.gz
sha256_tar=3CD566C19291EA3379115DD0D2EBCDEFB6A7CF0511CC33E733EC3A500E10DA69
download_tar=http://download.osgeo.org/libtiff/old/

download_dep()
{
    download_file $1 $filename_tar $download_tar $sha256_tar
    return $?
}

build_dep()
{
    tiff_root=$2/$tiff_filename

    if ! [[ -d "$tiff_root" ]]; then
        run_untar $2 $filename_tar $1
        if [[ $? -ne "0" ]]; then
            return 1
        fi
    fi

    cd "$tiff_root"
    ./autogen.sh
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd "$tiff_root"
    ndk_root=$android_ndk_bf
    ndk_toolchain="$ndk_root/toolchains/llvm/prebuilt/$ndk_osname/bin"
    ndk_cc="$ndk_toolchain/$target_compiler-linux-android21-clang"
    ndk_cxx="$ndk_toolchain/$target_compiler-linux-android21-clang++"
    CC=$ndk_cc CXX=$ndk_cxx ./configure --enable-static --disable-shared --host=$configure_arch --without-x --disable-cxx --disable-zlib --disable-jpeg
    ret=$?
    cd $root_script_dir

    if [[ $ret -ne "0" ]]; then
        return $ret
    fi

    cd "$tiff_root"
    make -C port && make -C libtiff libtiff.la
    ret=$?
    cd $root_script_dir

    return $ret
}

install_dep()
{
    tiff_root=$1/$tiff_filename
    mkdir -p "$2/libtiff" > /dev/null
    cp -f "$tiff_root/libtiff/tiff.h" "$2/"
    cp -f "$tiff_root/libtiff/tiffio.h" "$2/"
    cp -f "$tiff_root/libtiff/tiffvers.h" "$2/"
    cp -f "$tiff_root/libtiff/tiffconf.h" "$2/"
    cp -f "$tiff_root/libtiff/.libs/libtiff.a" "$2/"
    return 0
}
