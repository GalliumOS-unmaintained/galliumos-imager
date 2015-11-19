#!/bin/bash

#Makes a GalliumOS Live cd that is installable
#
#Based on this tutorial: 
#https://help.ubuntu.com/community/MakeALiveCD/DVD/BootableFlashFromHarddiskInstall

#GPL2 License

VERSION="1.0.16"

echo "
################################################
######                                    ######
######                                    ######
###### GalliumOS    Imager $VERSION         ######
######                                    ######
######                                    ######
######                                    ######
################################################


"

#Configuration file name and path
CONFIG_FILE="./galliumos-imager.config"

#Current directory
CURRENT_DIR=`pwd`

#Build
BUILD=$1

if [ -z $1 ]
then
  echo "Build type wasn't specified. Current types: haswell, haswell-cbox, broadwell, broadwell-cbox, sandy"
  exit 1
fi

#Convience function to unmount filesystems
unmount_filesystems() {
    echo "Unmounting filesystems"
    umount "${WORK}"/rootfs/proc > /dev/null 2>&1
    umount "${WORK}"/rootfs/sys > /dev/null 2>&1
    umount -l "${WORK}"/rootfs/dev/pts > /dev/null 2>&1
    umount -l "${WORK}"/rootfs/dev > /dev/null 2>&1
}

#Starting the process

#We depend on the umask being 022
umask 022

#Source the config file
if [ -r "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Can't read config file.  Exiting"
    exit 1
fi

#Set some other variables based on the config file
CD="${WORK}"/CD
CASPER="${CD}"/casper

#Checking for root
if [ "$USER" != "root" ]; then
    echo "You aren't root, so I'm exiting.  Become root and try again."
    exit 1
fi

#Unmount the filesystems in case the script failed before
unmount_filesystems

#Make the directories
echo "Making the necessary directories"
mkdir -p "${CD}"/casper
mkdir -p "${CD}"/boot/grub
mkdir -p "${WORK}"/rootfs/dev/pts


#Create devices in /dev
echo "Creating some links and dirs in /dev"
mkdir "${WORK}"/rootfs/dev/mapper > /dev/null 2>&1
mkdir "${WORK}"/rootfs/dev/pts > /dev/null 2>&1
ln -s /proc/kcore "${WORK}"/rootfs/dev/core > /dev/null 2>&1
ln -s /proc/self/fd "${WORK}"/rootfs/dev/fd > /dev/null 2>&1

cd "${WORK}"/rootfs/dev
ln -s fd/2 stderr > /dev/null 2>&1
ln -s fd/0 stdin > /dev/null 2>&1
ln -s fd/1 stdout > /dev/null 2>&1
ln -s ram1 ram > /dev/null 2>&1
ln -s shm /run/shm > /dev/null 2>&1

mknod agpgart c 10 175
chown root:video agpgart
chmod 660 agpgart

mknod audio c 14 4
mknod audio1 c 14 20
mknod audio2 c 14 36
mknod audio3 c 14 52
mknod audioctl c 14 7
chown root:audio audio*
chmod 660 audio*

mknod console c 5 1
chown root:tty console
chmod 600 console

mknod dsp c 14 3
mknod dsp1 c 14 19
mknod dsp2 c 14 35
mknod dsp3 c 14 51
chown root:audio dsp*
chmod 660 dsp*

mknod full c 1 7
chown root:root full
chmod 666 full

mknod fuse c 10 229
chown root:messagebus fuse
chmod 660 fuse

mknod kmem c 1 2
chown root:kmem kmem
chmod 640 kmem

mknod loop0 b 7 0
mknod loop1 b 7 1
mknod loop2 b 7 2
mknod loop3 b 7 3
mknod loop4 b 7 4
mknod loop5 b 7 5
mknod loop6 b 7 6
mknod loop7 b 7 7
chown root:disk loop*
chmod 660 loop*

cd mapper
mknod control c 10 236
chown root:root control
chmod 600 control
cd ..

mknod mem c 1 1
chown root:kmem mem
chmod 640 mem

mknod midi0 c 35 0
mknod midi00 c 14 2
mknod midi01 c 14 18
mknod midi02 c 14 34
mknod midi03 c 14 50
mknod midi1 c 35 1
mknod midi2 c 35 2
mknod midi3 c 35 3
chown root:audio midi*
chmod 660 midi*

mknod mixer c 14 0
mknod mixer1 c 14 16
mknod mixer2 c 14 32
mknod mixer3 c 14 48
chown root:audio mixer*
chmod 660 mixer*

mknod mpu401data c 31 0
mknod mpu401stat c 31 1
chown root:audio mpu401*
chmod 660 mpu401*

mknod null c 1 3
chown root:root null
chmod 666 null

mknod port c 1 4
chown root:kmem port
chmod 640 port

mknod ptmx c 5 2
chown root:tty ptmx
chmod 666 ptmx

mknod ram0 b 1 0
mknod ram1 b 1 1
mknod ram2 b 1 2
mknod ram3 b 1 3
mknod ram4 b 1 4
mknod ram5 b 1 5
mknod ram6 b 1 6
mknod ram7 b 1 7
mknod ram8 b 1 8
mknod ram9 b 1 9
mknod ram10 b 1 10
mknod ram11 b 1 11
mknod ram12 b 1 12
mknod ram13 b 1 13
mknod ram14 b 1 14
mknod ram15 b 1 15
mknod ram16 b 1 16
chown root:disk ram*
chmod 660 ram*

mknod random c 1 8
chown root:root random
chmod 666 random

mknod rmidi0 c 35 64
mknod rmidi1 c 35 65
mknod rmidi2 c 35 66
mknod rmidi3 c 35 67
chown root:audio rmidi*
chmod 660 rmidi*

mknod sequencer c 14 1
chown root:audio sequencer
chmod 660 sequencer

mknod smpte0 c 35 128
mknod smpte1 c 35 129
mknod smpte2 c 35 130
mknod smpte3 c 35 131
chown root:audio smpte*
chmod 660 smpte*

mknod sndstat c 14 6
chown root:audio sndstat
chmod 660 sndstat

mknod tty c 5 0
mknod tty0 c 4 0
mknod tty1 c 4 1
mknod tty2 c 4 2
mknod tty3 c 4 3
mknod tty4 c 4 4
mknod tty5 c 4 5
mknod tty6 c 4 6
mknod tty7 c 4 7
mknod tty8 c 4 8
mknod tty9 c 4 9
chown root:tty tty*
chmod 600 tty*

mknod urandom c 1 9
chown root:root urandom
chmod 666 urandom

mknod zero c 1 5
chown root:root zero
chmod 666 zero

cd "${CURRENT_DIR}"

#Mount dirs into copied distro
echo "Mounting system file dirs"
mount --bind /dev/ "${WORK}"/rootfs/dev
mount --bind /dev/pts "${WORK}"/rootfs/dev/pts
#rsync -av /var/run/resolvconf "${WORK}"/rootfs/run
mount -t proc proc "${WORK}"/rootfs/proc
mount -t sysfs sysfs "${WORK}"/rootfs/sys

cp /etc/mtab "${WORK}"/rootfs/etc/mtab

FORCE_INSTALL='apt-get -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'

echo "Installing the essential tools on the build host"
$FORCE_INSTALL install xorriso squashfs-tools

echo "Upgrading packages and installing essential packages in the rootfs dir"
chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 update"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL dist-upgrade"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install dmraid lvm2 samba-common"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install galliumos-core galliumos-desktop"

#Install development repo
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install galliumos-base-dev"

echo "Installing Ubiquity"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install casper lupin-casper"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install ubiquity-frontend-gtk"

echo "Installing kernel"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install linux-firmware-image-${KERNEL_VERSION} linux-headers-${KERNEL_VERSION} linux-image-${KERNEL_VERSION}"

echo "Installing other stuff"
chroot "${WORK}"/rootfs /bin/bash -c "$FORCE_INSTALL install xbindkeys synaptic intel-microcode iucode-tool i965-va-driver libva-intel-vaapi-driver vainfo compton fonts-croscore synaptic slim zram-config chromium-browser" 

chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 --purge remove xserver-xorg-input-synaptics acpid acpi-support irqbalance ubuntu-release-upgrader-core ubuntu-sso-client colord gnome-sudoku gnome-mines firefox"

chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 --purge autoremove"
chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 clean"

echo "Installing base"
chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install xf86-input-cmt"

if [ $BUILD == "haswell" ]
then
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-broadwell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-device-c710"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-haswell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-laptop"
elif [ $BUILD == "haswell-cbox" ]
then
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-laptop"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-broadwell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-device-c710"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-haswell"
elif [ $BUILD == "broadwell" ]
then
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-haswell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-device-c710"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-broadwell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-laptop"
elif [ $BUILD == "broadwell-cbox" ]
then
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-laptop"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-haswell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-device-c710"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-broadwell"
elif [ $BUILD == "sandy" ]
then
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-haswell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 remove --purge galliumos-broadwell"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-device-c710"
  chroot "${WORK}"/rootfs /bin/bash -c "apt-get -q=2 install galliumos-laptop"
fi

if [ -n "$UBIQUITY_KERNEL_PARAMS" ]; then
  echo "Replacing ubiquity default extra kernel params with: $UBIQUITY_KERNEL_PARAMS"
  sed -i "s/defopt_params=\"\"/defopt_params=\"${UBIQUITY_KERNEL_PARAMS}\"/" \
"${WORK}"/rootfs/usr/share/grub-installer/grub-installer
fi

#Update initramfs 
echo "Updating initramfs"
chroot "${WORK}"/rootfs depmod -a "${KERNEL_VERSION}"
chroot "${WORK}"/rootfs update-initramfs -u -k all

#Clean up downloaded packages
echo "Cleaning up files that are not needed in the new image"
chroot "${WORK}"/rootfs /bin/bash -c "apt-get clean"

#Truncate all logs
find "${WORK}"/rootfs/var/log -type f -exec truncate -s 0 {} \;

echo "Copying over kernel and initrd"
cp -p "${WORK}"/rootfs/boot/vmlinuz-"${KERNEL_VERSION}" "${CASPER}"/vmlinuz
cp -p "${WORK}"/rootfs/boot/initrd.img-"${KERNEL_VERSION}" "${CASPER}"/initrd.img
echo "Creating filesystem.manifest"
chroot "${WORK}"/rootfs dpkg-query -W --showformat='${Package} ${Version}\n' > "${CASPER}"/filesystem.manifest

cp "${CASPER}"/filesystem.manifest "${CASPER}"/filesystem.manifest-desktop
REMOVE='ubiquity apt-clone archdetect-deb dpkg-repack gir1.2-javascriptcoregtk-3.0 gir1.2-json-1.0 gir1.2-timezonemap-1.0 gir1.2-webkit-3.0 libdebian-installer4 libtimezonemap-data libtimezonemap1 python3-icu python3-pam rdate sbsigntool ubiquity-casper ubiquity-ubuntu-artwork ubuntu-drivers-common ubiquity-frontend-gtk xubuntu-live-settings casper user-setup os-prober'
for i in $REMOVE
do
   sed -i "/${i}/d" "${CASPER}"/filesystem.manifest-desktop
done


rm -f "${WORK}"/rootfs/etc/mtab
rm -rf "${WORK}"/rootfs/run/*
unmount_filesystems

echo "Making squashfs - this is going to take a while"
mksquashfs "${WORK}"/rootfs "${CASPER}"/filesystem.squashfs -noappend

echo "Making filesystem.size"
echo -n $(du -s --block-size=1 "${WORK}"/rootfs | \
    tail -1 | awk '{print $1}') > "${CASPER}"/filesystem.size
echo "Making md5sum"
rm -f "${CD}"/md5sum.txt
find "${CD}" -type f -print0 | xargs -0 md5sum | sed "s@${CD}@.@" | \
    grep -v md5sum.txt >> "${CD}"/md5sum.txt

echo "Creating release notes url"
mkdir "${CD}"/.disk > /dev/null 2>&1
echo "${RELEASE_NOTES_URL}" > "${CD}"/.disk/release_notes_url
echo "GalliumOS 1.0beta1 \"Vivid Vervet\" - Release amd64 (20151109.1)" > "${CD}"/.disk/info

echo "Creating grub.cfg"
echo "
set default=\"0\"
set timeout=5

insmod gfxterm
insmod vbe
insmod jpeg
terminal_output gfxterm
loadfont /boot/grub/unicode.pf2

background_image -m stretch /boot/grub/galliumos.jpg

set menu_color_normal=white/black
set menu_color_highlight=black/white
set color_normal=white/black

menuentry \"GalliumOS Live\" {
linux /casper/vmlinuz boot=casper $KERNEL_PARAMS quiet splash --
initrd /casper/initrd.img
}

menuentry \"GalliumOS Install Only\" {
linux /casper/vmlinuz boot=casper $KERNEL_PARAMS only-ubiquity quiet splash --
initrd /casper/initrd.img
}
" > "${CD}"/boot/grub/grub.cfg
rsync -a /boot/grub/i386-pc "${CD}"/boot/grub/
rsync -a /boot/grub/unicode.pf2 "${CD}"/boot/grub/
cp "${WORK}"/rootfs/usr/share/xfce4/backdrops/galliumos-default.jpg "${CD}"/boot/grub/galliumos.jpg

echo "Creating the iso"
DATE=`date +%Y%m%d`
echo "ISO: $2/dist/galliumos-$DATE-$1.iso"
grub-mkrescue -d /usr/lib/grub/i386-pc/ -o $2/dist/galliumos-1.0a-$DATE-NIGHTLY-$1.iso "${CD}"

echo "We are done."
echo ""
