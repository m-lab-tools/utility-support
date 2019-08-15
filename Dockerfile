# WARNING: we are using a 32bit centos 6.10+ base image.
FROM i386/centos:6
LABEL vendor="measurement-lab" description="Docker for building 32 bit mlab slices"

# Force arch to i386 so all util-linux-ng dependencies are correct.
WORKDIR /etc/yum.repos.d
RUN sed -i -e 's/$basearch/i386/g' *.repo
RUN yum install -y util-linux-ng

# Run all commands using linux32.
RUN linux32 yum -y update
RUN linux32 yum install -y wget git svn binutils qt gcc make patch libgomp
RUN linux32 yum install -y glibc-headers glibc-devel kernel-headers kernel-devel htop dkms
RUN linux32 yum install -y rpm-builder rpm-build m4 python-devel openssl-devel vim sudo man
RUN linux32 yum install -y http://mirror.measurementlab.net/fedora-epel/6/i386/python-gflags-1.4-3.el6.noarch.rpm

RUN linux32 rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# Build & install mlab_utility RPM package.
WORKDIR /
RUN git clone --recursive https://github.com/m-lab-tools/utility-support.git
WORKDIR /utility-support
RUN linux32 ./package/slicebuild.sh mlab_utility
RUN linux32 yum install -y /utility-support/build/slicebase-i386/i686/mlab_utility-*.i686.rpm
WORKDIR /

# Build & install the collectd-mlab slice package.
RUN git clone https://github.com/m-lab/collectd-mlab.git
WORKDIR /collectd-mlab
RUN linux32 make rpm
WORKDIR /
RUN linux32 yum install -y /build/noarch/collectd-mlab-2.0-2.noarch.rpm

# NOTE: do not run ttys in docker; mingetty spams /var/log/messages with errors.
RUN rm /etc/init/tty*.conf

# Stash environment variables and start init scripts.
CMD echo ${COMMUNITY} > /home/mlab_utility/conf/snmp.community && \
    echo ${HOSTNAME} > /home/mlab_utility/conf/hostname && \
    exec linux32 /sbin/init
