# Disable swap
echo "Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a