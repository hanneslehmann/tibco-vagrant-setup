#!/usr/bin/env bash
echo "Bootstrap script starting..." > /var/log/bootstrap.log

# Add tibco user and docker group
/usr/sbin/groupadd tibco
/usr/sbin/groupadd docker
/usr/sbin/useradd tibco -g tibco -G wheel
/usr/sbin/useradd docker -g docker --no-create-home 
echo "tibco" | passwd --stdin tibco
echo "tibco        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/tibco
chmod 0440 /etc/sudoers.d/tibco
/usr/sbin/usermod -aG docker tibco

# Installing vagrant keys
#mkdir -pm 700 /home/tibco/.ssh
#wget --no-check-certificate 'https://github.com/hanneslehmann/setup_scripts/raw/master/vagrant/insecure_private_key' -O /home/tibco/.ssh/authorized_keys
#chmod 0600 /home/tibco/.ssh/authorized_keys
#chown -R tibco /home/tibco/.ssh

# Customize the message of the day
echo 'Welcome to your Tibco VM.' > /etc/motd

# install docker
yum -y update
yum -y install net-tools
cd /tmp && { curl -O -sSL https://get.docker.com/rpm/1.7.0/centos-7/RPMS/x86_64/docker-engine-1.7.0-1.el7.centos.x86_64.rpm ; cd -; }
yum localinstall -y --nogpgcheck /tmp/docker-engine-1.7.0-1.el7.centos.x86_64.rpm

# create docker dirs / adjust permissions and bild the base image for ems
mkdir -p /home/tibco/docker
chown -R tibco /home/tibco/docker
cp /var/lib/tibcovm-vagrant/Docker_EMS /home/tibco/docker/Dockerfile
service docker start
cd /home/tibco/docker
sudo docker build -t tib_ems . 
# until now, run this command manually
# docker run -i -t -p 7220:7222 -v /mnt/share/installation:/installation tib_ems /bin/bash
# and then install a tibco product into the image


echo "Bootstrap script finished." >> /var/log/bootstrap.log