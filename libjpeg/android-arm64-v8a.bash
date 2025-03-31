download_zip=https://github.com/Suvitruf/libjpeg-version-9-android/archive/refs/heads/
filename_zip=master.zip
sha256_zip=5697933c56a6e4c9e3a4e2df0a00d537ef481527cfc596d8ecce57f2e6b8703f

download_dep()
{
    download_file $1 $filename_zip $download_zip $sha256_zip
    return $?
}

build_dep()
{
    # path has to be renamed as "jni" or ndk-build will cry
    jpegsrc=$2/jni
    if ! [[ -d "$jpegsrc" ]]; then
        run_unzip $2 $filename_zip $1
        if [[ $? -ne "0" ]]; then
            return 1
        fi
        mv "$2/libjpeg-version-9-android-master" "$2/jni"
        patch -d "$jpegsrc" < "$root_script_dir/libjpeg/android-arm64-v8a.diff"
    fi
    cd $jpegsrc/../
    run_ndkbuild "$android_ndk_bf"
    res=$?
    cd $root_script_dir
    return $res
}

install_dep()
{
    jpegsrc=$1/jni
    cp -f "$jpegsrc/libjpeg9/jpeglib.h" "$2/jpeglib.h"
    cp -f "$jpegsrc/libjpeg9/jconfig.h" "$2/jconfig.h"
    cp -f "$jpegsrc/libjpeg9/jmorecfg.h" "$2/jmorecfg.h"
    cp -f "$jpegsrc/libjpeg9/jerror.h" "$2/jerror.h"
    cp -f "$jpegsrc/../obj/local/arm64-v8a/libjpeg9.a" "$2/libjpeg.a"
    return 0
}
