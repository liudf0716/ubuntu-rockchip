# shellcheck shell=bash

export BOARD_NAME="Forlinx OK3588-C"
export BOARD_MAKER="Forlinx"
export BOARD_SOC="Rockchip RK3588"
export BOARD_CPU="ARM Cortex A76 / A55"
export UBOOT_PACKAGE="u-boot-turing-rk3588"
export UBOOT_RULES_TARGET="ok3588-c-rk3588"
export COMPATIBLE_SUITES=("noble" "oracular" "plucky")
export COMPATIBLE_FLAVORS=("server" "desktop")

function config_image_hook__ok3588-c() {
    local rootfs="$1"
    local suite="$3"

    if [ "${suite}" == "jammy" ] || [ "${suite}" == "noble" ]; then
        # Install panfork
        chroot "${rootfs}" add-apt-repository -y ppa:jjriek/panfork-mesa
        chroot "${rootfs}" apt-get update
        chroot "${rootfs}" apt-get -y install mali-g610-firmware
        chroot "${rootfs}" apt-get -y dist-upgrade

        # Install libmali blobs alongside panfork
        chroot "${rootfs}" apt-get -y install libmali-g610-x11

        # Install the rockchip camera engine
        chroot "${rootfs}" apt-get -y install camera-engine-rkaiq-rk3588

        # The OK3588-C uses UART2 for console output (standard for RK3588)
        sed -i 's/console=ttyS2,1500000/console=ttyS2,1500000/g' "${rootfs}/etc/kernel/cmdline"
    elif [ "${suite}" == "oracular" ]; then
        sed -i 's/console=ttyS2,1500000/console=ttyS2,1500000/g' "${rootfs}/etc/kernel/cmdline"
    fi

    return 0
}
