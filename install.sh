#!/usr/bin/env bash
set -euo pipefail

# ===========================
# User Input & Validation
# ===========================
read -p "Enter preferred username: " USERNAME
if [[ -z "$USERNAME" ]]; then
    echo "Username is required. Exiting..."
    exit 1
fi

read -p "Enter hostname: " HOSTNAME
if [[ -z "$HOSTNAME" ]]; then
    echo "Hostname is required. Exiting..."
    exit 1
fi

read -p "Enter target disk (e.g. /dev/sda): " DISK
if [[ ! -b "$DISK" ]]; then
    echo "Disk ${DISK} not found or is not a block device. Exiting..."
    exit 1
fi

read -p "Enter your desired swap size in MB (default: 32768): " SWAP_SIZE
if [[ -z "$SWAP_SIZE" ]]; then
    SWAP_SIZE=32768
fi

SWAP_END=$((512 + SWAP_SIZE + 1))

read -p "Enter your desired user password: " -s PASSWORD
if [[ -z "$PASSWORD" ]]; then
    echo "Password is required. Exiting..."
    exit 1
fi

read -p "Enter your desired root password: " -s ROOT_PASSWORD
if [[ -z "$ROOT_PASSWORD" ]]; then
    echo "Root password is required. Exiting..."
    exit 1
fi

read -p "Enter your timezone (e.g. America/New_York): " TIMEZONE
if [[ -z "$TIMEZONE" ]]; then
    echo "Timezone is required. Exiting..."
    exit 1
fi
if [[ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    echo "Timezone ${TIMEZONE} not found. Exiting..."
    exit 1
fi

# ===========================
# Partitioning and Formatting
# ===========================
echo "Partitioning disk ${DISK}..."
parted "$DISK" --script mklabel gpt
parted "$DISK" --script mkpart EFI fat32 1MiB 513MiB
parted "$DISK" --script set 1 esp on
parted "$DISK" --script mkpart swap linux-swap 513MiB "${SWAP_END}MiB"
parted "$DISK" --script mkpart primary btrfs "${SWAP_END}MiB" 100%

echo "Formatting partitions..."
mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.btrfs -f "${DISK}3"

echo "Activating swap..."
swapon "${DISK}2"

echo "Creating btrfs subvolume..."
mount -o subvolid=5 "${DISK}3" /mnt
btrfs subvolume create /mnt/@
umount /mnt

echo "Mounting in preparation for installation..."
mount -o compress=zstd,subvol=@ "${DISK}3" /mnt
mkdir -p /mnt/boot/efi
mount "${DISK}1" /mnt/bootefi

# ===========================
# Base System Installation
# ===========================
echo "Installing base system..."
pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware vim git networkmanager

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Copying pkglist.txt to /mnt/root..."
if [[ -f ./pkglist.txt ]]; then
    cp ./pkglist.txt /mnt/root/pkglist.txt
else
    echo "pkglist.txt not found in the current directory. Exiting..."
    exit 1
fi

# ===========================
# Chroot: System Configuration & User Setup
# ===========================
arch-chroot /mnt /bin/bash -e <<EOF
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

echo "${HOSTNAME}" > /etc/hostname

cat <<EOL > /etc/hosts
127.0.0.1    localhost
::1          localhost
127.0.1.1    ${HOSTNAME}.localdomain ${HOSTNAME}
EOL

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "root:${ROOT_PASSWORD}" | chpasswd

useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Installing paru as user ${USERNAME}..."
sudo -u ${USERNAME} bash -c '
cd /home/${USERNAME} || exit 1
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
'

echo "Installing packages from pkglist.txt..."
mv /root/pkglist.txt /home/${USERNAME}/pkglist.txt
sudo -u ${USERNAME} bash -c '
paru -S --needed --noconfirm - < /home/${USERNAME}/pkglist.txt
'

echo "Setting up dotfiles..."
# Clone your dotfiles repository. Replace the URL with your actual repository.
sudo -u ${USERNAME} bash -c '
git clone https://github.com/yourusername/dotfiles.git /home/${USERNAME}/dotfiles
'

# Copy dotfiles and .config folder.
cp /home/${USERNAME}/dotfiles/.bashrc /home/${USERNAME}/.bashrc
cp /home/${USERNAME}/dotfiles/.tmux.conf /home/${USERNAME}/.tmux.conf
rsync -av /home/${USERNAME}/dotfiles/.config/ /home/${USERNAME}/.config/

# Place wallpapers in Pictures directory if available.
mkdir -p /home/${USERNAME}/Pictures/wallpapers
if [ -d /home/${USERNAME}/dotfiles/wallpapers ]; then
    rsync -av /home/${USERNAME}/dotfiles/wallpapers/ /home/${USERNAME}/Pictures/wallpapers/
fi

systemctl enable NetworkManager
systemctl enable cups
systemctl enable bluetooth
systemctl enable containerd

EOF

# ===========================
# Final Message
# ===========================
echo "Installation complete. You can now exit chroot and reboot into your new system."
