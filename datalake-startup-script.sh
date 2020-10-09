#!/bin/bash

export datalake=$PWD

# add user:admin with password:datalake2020
useradd admin
echo datalake2020 | passwd admin --stdin
cp ./BASHRC /root/.bashrc
cp ./BASHRC /home/admin/.bashrc
source ~/.bashrc

# install packages

dnf -y install drpm telnet net-tools tree wget mlocate epel-release
dnf -y group install "Development Tools"
dnf -y group install "Server with GUI"

systemctl set-default graphical

# install ruby 2.7.1

tar -C /opt -xzvf ../IMAGES/ruby-2.7.1.tar.gz
cd /opt/ruby-2.7.1
dnf -y install zlib-devel openssl-devel readline-devel sqlite-devel
./configure --prefix=/usr --exec-prefix=/usr \
--with-zlib-dir=/usr \
--with-openssl-dir=/usr \
--with-readline-dir=/usr
make install

# .nanorc .gemrc
echo "set tabsize 2" > ~/.nanorc
echo "set tabstospaces" >> ~/.nanorc
echo "gem: --no-document --verbose" > ~/.gemrc

# install fail2ban
dnf -y install fail2ban fail2ban-systemd
dnf -y install geoip

cd $datalake
cp ./geohostsdeny.conf /etc/fail2ban/action.d/
cp ./jail.local /etc/fail2ban

systemctl enable fail2ban
systemctl restart fail2ban

# install chkrootkit
# wget https://fossies.org/linux/misc/chkrootkit-0.53.tar.gz
tar -C /opt -xzvf ../IMAGES/chkrootkit-0.53.tar.gz
cd /opt/chkrootkit-0.53
dnf -y --enablerepo=PowerTools install glibc-static
make sense
./chkrootkit

# install docker-ce

dnf -y install yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
dnf -y install docker-ce docker-ce-cli
systemctl enable docker
systemctl restart docker

# add group:docker to user:admin
usermod -aG docker admin
systemctl restart docker

# FIX no route to host in docker

echo "/usr/bin/firewall-cmd --zone=public --add-masquerade --permanent" >> /etc/rc.d/rc.local
echo "/usr/bin/firewall-cmd --reload" >> /etc/rc.d/rc.local
echo "start-hos-pcu.sh" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# DATALAKE PROJECT
mkdir -p /opt/VOLUMES/portainer_data
mkdir -p /opt/VOLUMES/nodered_data
mkdir -p /opt/VOLUMES/mongodb_data
mkdir -p /opt/VOLUMES/mongodb_backup
chown admin:admin -R /opt/VOLUMES

# build docker images

cd $datalake
docker load < ../IMAGES/mongodb-trang.tar
docker load < ../IMAGES/nodered-trang.tar
docker load < ../IMAGES/scripts-trang.tar
docker load < ../IMAGES/adminer-trang.tar

# copy files
cp -r ./TRANG /opt
cp -r ./SCRIPTS /opt

chown admin:admin -R /opt/TRANG /opt/SCRIPTS
chmod +x /opt/TRANG/HOS-PCU/* /opt/SCRIPTS/HOS-PCU/*
# copy start-hos-pcu.sh stop-hos-pcu.sh to /usr/local/bin
dnf -y install dos2unix
dos2unix *.sh
chmod +x *.sh
cp *.sh /usr/local/bin

# install mongoid and mysql2 gem
dnf -y install mariadb-devel
yes | gem install mysql2
yes | gem install mongoid
yes | gem install mqtt

# install AnyDesk
cat > /etc/yum.repos.d/AnyDesk-CentOS.repo << "EOF"
[anydesk]
name=AnyDesk CentOS - stable
baseurl=http://rpm.anydesk.com/centos/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
EOF

dnf -y makecache
dnf -y install redhat-lsb-core
dnf -y install anydesk

perl -p -i -e "s/\#Wayland/Wayland/g" /etc/gdm/custom.conf
echo "ad.security.interactive_access=1" >> /etc/anydesk/system.conf

systemctl enable anydesk
systemctl restart anydesk

echo
echo "REBOOT NOW!"

reboot
