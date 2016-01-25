# This image is intended for testing purposes, it has the same behavior as
# the origin-docker-builder image, but does so as a custom image so it can
# be used with Custom build strategies.  It expects a set of
# environment variables to parameterize the build:
#
#   OUTPUT_REGISTRY - the Docker registry URL to push this image to
#   OUTPUT_IMAGE - the name to tag the image with
#   SOURCE_URI - a URI to fetch the build context from
#   SOURCE_REF - a reference to pass to Git for which commit to use (optional)
#
# This image expects to have the Docker socket bind-mounted into the container.
# If "/root/.dockercfg" is bind mounted in, it will use that as authorization 
# to a Docker registry.
#
# The standard name for this image is openshift/origin-custom-docker-builder
#
FROM openshift/origin-base

RUN yum install -y gettext automake make

# Install docker
RUN mkdir /docker && cd /docker
RUN wget ftp://ftp.unicamp.br/pub/linuxpatch/s390x/redhat/rhel7.1/docker/docker-1.8.3-rhel7.1-20151027.tar.gz
RUN tar -xvzf docker-1.8.3-rhel7.1-20151027.tar.gz && cp docker-1.8.3-rhel7.1-20151027/docker /usr/bin


ENV HOME /root
ADD ./build.sh /tmp/build.sh
CMD ["/tmp/build.sh"]
