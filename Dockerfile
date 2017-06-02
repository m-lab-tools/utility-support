FROM tenforward/centos-i386
LABEL vendor="measurement-lab" description="Docker for building 32 bit mlab slices"

RUN linux32 yum -y update
RUN linux32 yum install -y wget git svn binutils qt gcc make patch libgomp
RUN linux32 yum install -y glibc-headers glibc-devel kernel-headers kernel-devel htop dkms
RUN linux32 yum install -y rpm-builder rpm-build m4 python-devel openssl-devel

RUN linux32 rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN linux32 yum install -y sudo man


RUN git clone --recursive https://github.com/m-lab-tools/utility-support.git
WORKDIR /utility-support
RUN linux32 ./package/slicebuild.sh mlab_utility
RUN linux32 yum install -y /utility-support/build/slicebase-i386/i686/mlab_utility-master-*.mlab.i686.rpm

WORKDIR /

# Build the mlab_utility slice package.
RUN git clone https://github.com/m-lab/collectd-mlab.git
WORKDIR /collectd-mlab
RUN linux32 ls -al
RUN linux32 make rpm

WORKDIR /
RUN linux32 yum install -y http://mirror.measurementlab.net/fedora-epel/6/i386/python-gflags-1.4-3.el6.noarch.rpm
RUN linux32 yum install -y /build/noarch/collectd-mlab-2.0-2.noarch.rpm

RUN sed -i -e 's|for iface in netifaces.interfaces():|for iface in filter(lambda x: "eth0" in x, netifaces.interfaces()):|g' /usr/lib/python2.6/site-packages/mlab/disco/network.py

CMD echo ${SNMP_COMMUNITY} > /home/mlab_utility/conf/snmp.community && exec linux32 /sbin/init
