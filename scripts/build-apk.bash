flutter build apk -v
if [ $? -ne 0 ]; then
    printf "\e[31;1m%s\e[0m\n" "Build failed with exit code $?"
    exit 1
fi
cp ./build/app/outputs/apk/release/app-release.apk dist/app.apk
if [ $? -ne 0 ]; then
    printf "\e[31;1m%s\e[0m\n" "Failed to copy built .apk, please check the build/app/outputs/apk/release folder."
    exit 1
fi
printf "\e[33;1m%s\e[0m\n" 'Built APK has been stored in dist/app.apk'