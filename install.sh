#!/usr/bin/env bash
set -euo pipefail

#===========================
#      PARAMETERS
#===========================
EFI_SIZE_MB=512                  # EFI partition size
DEFAULT_SWAP_MB=32768            # default swap size
SUBVOLS=(root home var tmp media snapshots)
MOUNT_OPTS="compress=zstd,space_cache=v2,discard=async"
TIMERS=(auto-btrfs-balance auto-btrfs-scrub auto-btrfs-snapshot-daily auto-btrfs-snapshot-weekly)
BASE_PKGS=(base base-devel linux-zen linux-zen-headers linux-firmware vim git networkmanager)

#===========================
#     USER PROMPTS
#===========================
ask_user() {
  read -p "Enter preferred username: " USERNAME
  [[ -z "$USERNAME" ]] && { echo "Username required."; exit 1; }

  read -p "Enter hostname: " HOSTNAME
  [[ -z "$HOSTNAME" ]] && { echo "Hostname required."; exit 1; }

  read -p "Enter target disk (e.g. /dev/nvme0n1): " DISK
  [[ ! -b "$DISK" ]] && { echo "Block device $DISK not found."; exit 1; }

  read -p "Swap size in MB [${DEFAULT_SWAP_MB}]: " SWAP_MB
  SWAP_MB=${SWAP_MB:-$DEFAULT_SWAP_MB}
  # calculate end (EFI + swap + 1MiB gap)
  SWAP_END_MB=$(( EFI_SIZE_MB + SWAP_MB + 1 ))

  read -s -p "User password: " PASSWORD; echo
  [[ -z "$PASSWORD" ]] && { echo "Password required."; exit 1; }

  read -s -p "Root password: " ROOT_PASSWORD; echo
  [[ -z "$ROOT_PASSWORD" ]] && { echo "Root password required."; exit 1; }

  read -p "Timezone (e.g. America/New_York): " TIMEZONE
  [[ -z "$TIMEZONE" ]] && { echo "Timezone required."; exit 1; }
  [[ ! -f "/usr/share/zoneinfo/${TIMEZONE}" ]] && { echo "Timezone $TIMEZONE not found."; exit 1; }
}

#===========================
#   DISK PARTITIONING
#===========================
partition_disk() {
  echo "→ Partitioning $DISK"
  parted "$DISK" --script mklabel gpt
  parted "$DISK" --script mkpart EFI fat32 1MiB $((EFI_SIZE_MB+1))MiB
  parted "$DISK" --script set 1 esp on
  parted "$DISK" --script mkpart swap linux-swap $((EFI_SIZE_MB+1))MiB ${SWAP_END_MB}MiB
  parted "$DISK" --script mkpart primary btrfs ${SWAP_END_MB}MiB 100%
}

#===========================
#   FORMAT & BTRFS SETUP
#===========================
setup_btrfs() {
  echo "→ Formatting"
  mkfs.fat -F32 "${DISK}1"
  mkswap     "${DISK}2"
  mkfs.btrfs -f "${DISK}3"
  swapon "${DISK}2"

  echo "→ Creating subvolumes"
  mount -o subvolid=5 "${DISK}3" /mnt
  for sv in "${SUBVOLS[@]}"; do
    btrfs subvolume create /mnt/@${sv}
  done
  umount /mnt

  echo "→ Mounting subvolumes + EFI"
  mount -o subvol=@root,$MOUNT_OPTS "${DISK}3" /mnt
  mkdir -p /mnt/{home,var,tmp,media,.snapshots,boot/efi}
  for sv in "${SUBVOLS[@]:1}"; do
    mount -o subvol=@${sv},$MOUNT_OPTS "${DISK}3" /mnt/${sv}
  done
  mount "${DISK}1" /mnt/boot/efi
}

#===========================
#  BASE INSTALL & FSTAB
#===========================
install_base() {
  echo "→ Installing base system"
  pacstrap /mnt "${BASE_PKGS[@]}"
  echo "→ Generating /etc/fstab"
  genfstab -U /mnt >> /mnt/etc/fstab
}

#===========================
#      IN-CHROOT CONFIG
#===========================
configure_chroot() {
  arch-chroot /mnt /bin/bash -e <<EOF
# — Localization
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# — Hostname
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<H
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
H

# — Users & passwords
echo "root:${ROOT_PASSWORD}" | chpasswd
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# — GRUB for UEFI
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# — Clone your repo & deploy configs
git clone https://github.com/rrumana/arch.git /root/arch

# dotfiles → ~/.config
mkdir -p /home/${USERNAME}/.config
cp -r /root/arch/dotfiles/* /home/${USERNAME}/.config/
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config

# home-dotfiles → ~
rsync -av /root/arch/home/ /home/${USERNAME}/
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# wallpapers → ~/Pictures/wallpapers
mkdir -p /home/${USERNAME}/Pictures/wallpapers
cp -r /root/arch/wallpapers/* /home/${USERNAME}/Pictures/wallpapers/
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/Pictures/wallpapers

# — paru & PKG LIST
sudo -u ${USERNAME} bash -c '
  git clone https://aur.archlinux.org/paru.git /home/${USERNAME}/paru
  cd /home/${USERNAME}/paru
  makepkg -si --noconfirm
'
if [[ ! -f /root/arch/package_list.txt ]]; then
  echo "ERROR: package_list.txt missing!" >&2
  exit 1
fi
sudo -u ${USERNAME} bash -c '
  paru -S --needed --noconfirm - < /root/arch/package_list.txt
'

# — Timers/Services
cp /root/arch/timers/* /etc/systemd/system/
systemctl daemon-reload
for t in ${TIMERS[*]}; do
  systemctl enable --now "\${t}.timer"
done

# — Core services
systemctl enable NetworkManager containerd cups bluetooth
EOF
}

#===========================
#         MAIN
#===========================
main() {
  ask_user
  partition_disk
  setup_btrfs
  install_base
  configure_chroot
  echo "✅ All done! Exit, reboot, and enjoy your new Arch system."
}

main "$@"

