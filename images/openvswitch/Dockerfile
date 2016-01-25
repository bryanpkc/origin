#
# This is an openvswitch image meant to enable OpenShift OVS based SDN
#
# The standard name for this image is openshift/openvswitch
#

FROM rhel7

# MAINTAINER Scott Dodson <sdodson@redhat.com>

# ADD https://copr.fedoraproject.org/coprs/maxamillion/origin-next/repo/epel-7/maxamillion-origin-next-epel-7.repo /etc/yum.repos.d/

# TODO: systemd update from centos 7.1 -> 7.2 is broken, remove this once 7.2
# base images land
# RUN yum swap -y -- remove systemd-container\* -- install systemd systemd-libs

RUN yum install -y wget tar make gcc openssl python perl && yum clean all

# Install openvswitch from the source
RUN mkdir openvswitch && cd ./openvswitch
RUN wget http://openvswitch.org/releases/openvswitch-2.4.0.tar.gz
RUN tar -xvf openvswitch-2.4.0.tar.gz
RUN cd openvswitch-2.4.0/ && ./configure && make && make install

# RUN yum install -y openvswitch \
#    && yum clean all

ADD  scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*
VOLUME [ "/etc/openswitch" ]

ENV HOME /root
ENTRYPOINT [ "/usr/local/bin/ovs-run.sh" ]
