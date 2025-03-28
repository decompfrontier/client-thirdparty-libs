download_tar=https://github.com/leenjewel/openssl_for_ios_and_android/releases/download/20170105/
filename_tar=openssl_curl_for_ios_android.20170105.zip
sha256_tar=B3057B35DC4DB0246E0A9F4CD28705606479E12C89BFF5ECDC0C38131C228643

download_dep()
{
    download_file $1 $filename_tar $download_tar $sha256_tar
    return $?
}

build_dep()
{
    if [[ -d "$2/output" ]]; then
        return 0
    fi
    run_unzip $2 $filename_tar $1 output/android/$target_lib-android-$target_arch
    return $?
}

install_dep()
{
    cd $1/output/android/$target_lib-android-$target_arch/
    cp -r include/* $2/
    if [[ $? -ne "0" ]]; then
        echo "Cannot copy include files for $target_lib"
        return 1
    fi
    cp -r lib/*.a $2/
    if [[ $? -ne "0" ]]; then
        echo "Cannot copy include files for $target_lib"
        return 1
    fi
    return 0
}