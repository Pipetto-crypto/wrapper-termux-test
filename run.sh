 #!/bin/bash

function fail {
    printf '%s\n' "$1" >&4 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

clear

exec 3>&1 4>&2 
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.txt 2>&1

pkg update -y || fail "Couldn't update termux packages"
pkg upgrade -y || fail "Couldn't upgrade termux packages"
pkg install x11-repo tur-repo -y || fail "Couldn't install required termux repos"
pkg install ldd hangover-wine vulkan-validation-layers termux-x11-nightly vulkan-tools -y || fail "Couldn't install required termux packages"

kill $(pidof app_process)
export TERMUX_X11_DEBUG=1
termux-x11 || fail "Couldn't start Termux:X11, did you make sure you have the apk installed" &
sleep 5

unzip -d $PREFIX -o wrapper.zip || fail "Couldn't extract wrapper"

export DISPLAY=:0
export VK_ICD_FILENAMES=$PREFIX/share/vulkan/icd.d/wrapper_icd.aarch64.json
export VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation

echo -e "Everything installed fine, running vkcube to test wrapper. Check Termux:X11 to see if cube appears then close this prompt with CTRL+C" >&3

vkcube || fail "Failed to run vkcube"
