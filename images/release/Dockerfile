#
# This is the image that controls the standard build environment for releasing OpenShift Origin.
# It is responsible for performing a cross platform build of OpenShift.
#
# The standard name for this image is openshift/origin-release
#
FROM openshift/origin-base

# Install golang
RUN yum install --nogpgcheck -y gcc-c++ gcc glibc-devel make curl 

ENV GOLANG_VERSION 1.5.2
ENV GOLANG_DOWNLOAD_URL http://tr.torolab.ibm.com/~vpapro/public/go1.5.3.linux.tar.gz
ENV GOLANG_DOWNLOAD_SHA1 820d8978fec251eb13a5d6913a20849f12ca83a1

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA1  golang.tar.gz" | sha1sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# Install the other packages
RUN yum install -y zip hg && yum clean all


# work around 64MB tmpfs size
ENV TMPDIR /openshifttmp

# Get the code coverage tool and godep
# Note there is a go bug, so you have to run go get twice
RUN mkdir $TMPDIR && \
    go get golang.org/x/tools/cmd/cover github.com/tools/godep github.com/golang/lint/golint; go get golang.org/x/tools/cmd/cover github.com/tools/godep github.com/golang/lint/golint

# Mark this as a os-build container
RUN touch /os-build-image

WORKDIR /go/src/github.com/openshift/origin

# (set an explicit GOARM of 5 for maximum compatibility)
ENV GOARM 5

ENV OS_VERSION_FILE /go/src/github.com/openshift/origin/os-version-defs

# Allows building Origin sources mounted using volume
ADD openshift-origin-build.sh /usr/bin/openshift-origin-build.sh

# Expect a tar with the source of OpenShift Origin (and /os-version-defs in the root)
CMD tar mxzf - && hack/build-cross.sh
