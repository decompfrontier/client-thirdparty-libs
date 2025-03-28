#!/bin/bash
# Client decompfile third party downloader

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <platform> <arch> <output dir>"
    exit 1
fi

## utilities

# function: download_file
# argument 1: output directory
# argument 2: filename to download
# argument 3: url to download without the filename
# argument 4: sha256 of the file
download_file()
{
    outfile=$1/$2
    url=$3$2

    if [[ -f "$outfile" ]]; then
        return 0
    fi

    echo Downloading $2...
    wget -O "$outfile" -o /dev/null  $url
    if [[ $? -ne "0" ]]; then
        return 1
    fi

    cd $1
    echo "$4 $2" | sha256sum --check --status
    if [[ $? -ne "0" ]]; then
        rm -rf $outfile
        echo "SHA-256 verification failed for $2"
        return 1
    fi
    cd $root_script_dir
    return 0
}

# function: run_unzip
# argument 1: output directory
# argument 2: filename to extract
# argument 3: directory where the file is found
# argument 4: extra args
run_unzip()
{
    7z x "$3/$2" "-o$1" -y $4 >> /dev/null
    if [[ $? -ne "0" ]]; then
        echo "Unzip failed for $2"
        return 1
    fi
    return 0
}

root_script_dir=${PWD}
platform=$1
arch=$2
output_dir=$root_script_dir/$3
libraries=(libcurl openssl libjpeg libpng libtiff libxml2 zlib)

for lib in "${libraries[@]}"
do
    src_script=$root_script_dir/$lib/$platform-$arch.bash
    rootmk_dir=$root_script_dir/$lib/build/$platform-$arch
    tar_dir=$rootmk_dir/tarball
    build_dir=$rootmk_dir/build

    if ! [[ -f "$build_dir/.installed" ]]; then
        if ! [[ -f "$src_script" ]]; then
            echo "Cannot find configuration $lib for $platform $arch"
            exit 1
        fi

        mkdir -p $tar_dir
        mkdir -p $build_dir

        source $src_script

        download_dep $tar_dir

        if [[ $? -ne "0" ]]; then
            exit 1
        fi

        echo Extracting and building $lib...
        build_dep $tar_dir $build_dir

        echo Installing $lib...
        install_dep $build_dir $output_dir

        touch $build_dir/.installed
    fi
done
