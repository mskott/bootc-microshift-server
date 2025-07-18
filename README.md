# Bootc based MicroShift server

Based on the documentation for [Red Hat MicroShift 4.19](https://docs.redhat.com/en/documentation/red_hat_build_of_microshift/4.19/).

Extra features added to the image:
- GitOps
- Red Hat InSights
- TuneD

## Installing a VM

`kickstart.ks` file:
```
lang en_US.UTF-8
keyboard dk
timezone UTC
text
reboot

# Partition the disk with hardware-specific boot and swap partitions, adding an
# LVM volume that contains a 10GB+ system root. The remainder of the volume will
# be used by the CSI driver for storing data.
zerombr
clearpart --all --initlabel
# Create boot and swap partitions as required by the current hardware platform
reqpart --add-boot
# Add an LVM volume group and allocate a system root logical volume
part pv.01 --grow
volgroup rhel pv.01
logvol / --vgname=rhel --fstype=xfs --size=10240 --name=root

# Lock root user account
rootpw --lock

# Configure network to use DHCP and activate on boot
network --bootproto=dhcp --device=link --activate --onboot=on

# Pull a 'bootc' image from a remote registry
ostreecontainer --url "ghcr.io/mskott/bootc-microshift-server:main"

%post --log=/dev/console --erroronfail

# Create an OpenShift pull secret file
cat > /etc/crio/openshift-pull-secret <<'EOF'
#Insert OpenShift pull-secret here
EOF
chmod 600 /etc/crio/openshift-pull-secret

%end

```

Install virtual machine:
```shell
sudo virt-install \
    --name microshift \
    --vcpus 2 \
    --memory 4096 \
    --disk path=/var/lib/libvirt/images/microshift.qcow2,size=20 \
    --network network=default,model=virtio \
    --events on_reboot=restart \
    --location /var/lib/libvirt/images/rhel-9.6-x86_64-boot.iso \
    --initrd-inject kickstart.ks \
    --extra-args "inst.ks=file://kickstart.ks" \
    --wait
```