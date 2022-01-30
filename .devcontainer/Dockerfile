#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Update the VARIANT arg in devcontainer.json to pick an Debian version: buster (or debian-10), stretch (or debian-9)
# To fully customize the contents of this image, use the following Dockerfile instead:
# https://github.com/microsoft/vscode-dev-containers/tree/v0.128.0/containers/debian/.devcontainer/base.Dockerfile
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	python3-setuptools python3-wheel python3-pip \
	xz-utils make gcc bison libc6-dev \
	fish tcsh expect \
	&& rm -rf /var/lib/apt/lists/*
RUN wget -O- https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz | \
	tar -xJC /usr/local/bin --strip-components 1 shellcheck-v0.7.1/shellcheck
RUN pip3 install docopt.sh==0.9.17
RUN git clone --depth 1 --branch v1.2.1 https://github.com/bats-core/bats-core.git /tmp/bats \
	&& /tmp/bats/install.sh /usr/local \
	&& rm -rf /tmp/bats \
	&& git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-support.git /usr/local/bats/support \
	&& git clone --depth 1 --branch v2.0.0 https://github.com/bats-core/bats-assert.git /usr/local/bats/assert \
	&& git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-file.git /usr/local/bats/file
