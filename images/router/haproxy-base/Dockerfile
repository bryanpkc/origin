#
# This is the HAProxy router base for OpenShift Origin. It contains the necessary
# HAProxy binaries to be dynamically managed by the OpenShift router.
#
# The standard name for this image is openshift/origin-haproxy-router-base
#
FROM openshift/origin-base

#
# Note: /var is changed to 777 to allow access when running this container as a non-root uid
#       this is temporary and should be removed when the container is switch to an empty-dir
#       with gid support.
#
#RUN yum -y install haproxy && \
RUN yum install --nogpgcheck -y \
        git \
        java-1.8.0-openjdk \
        gcc-c++ \
        tar \
        openssl \
        openssl-devel \
        pcre \
        pcre-devel \
        make
# Clone the source code of HAProxy from github
RUN git clone http://git.haproxy.org/git/haproxy-1.6.git

# Build and install Node.js
RUN cd haproxy-1.6/ && make TARGET=linux26 USE_OPENSSL=1 && make install

RUN \
    mkdir -p /var/lib/containers/router/{certs,cacerts} && \
    mkdir -p /var/lib/haproxy/{conf,run,bin,log} && \
    touch /var/lib/haproxy/conf/{{os_http_be,os_edge_http_be,os_tcp_be,os_sni_passthrough,os_reencrypt}.map,haproxy.config} && \
    chmod -R 777 /var && \
    yum clean all

ADD conf/ /var/lib/haproxy/conf/
# add the dummy cert to the app cert directory as well to avoid errors with default config
ADD conf/ /var/lib/containers/router/certs/
EXPOSE 80
