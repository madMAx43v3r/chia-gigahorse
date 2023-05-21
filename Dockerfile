FROM ubuntu:20.04 AS base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade \
		&& apt-get install -y \
			xz-utils \
			libgomp1 \
			ocl-icd-libopencl1 \
			curl \
			clinfo \
			&& rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY docker-start.sh .
ARG GIT_RELEASE
ARG GIT_RELEASE_NUM=${GIT_RELEASE:1}
ARG GIT_RELEASE_URL=https://github.com/madMAx43v3r/chia-gigahorse/releases/download/${GIT_RELEASE}/chia-gigahorse-farmer-${GIT_RELEASE_NUM}-x86_64.tar.gz
RUN curl -L ${GIT_RELEASE_URL} --output chia-gigahorse-farmer.tar.gz \
    && tar -xf chia-gigahorse-farmer.tar.gz \
    && cp -r chia-gigahorse-farmer/* . \
    && rm -rf chia-gigahorse-farmer \
    && rm *.tar.gz

ENV CHIA_SERVICES="farmer"
ENV CHIA_ROOT="/data/"
VOLUME /data

# node p2p port
EXPOSE 8444/tcp
# http api port
EXPOSE 8555/tcp

CMD ["./docker-start.sh"]

FROM base AS amd
ARG AMD_DRIVER=amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz
ARG AMD_DRIVER_URL=https://drivers.amd.com/drivers/linux
RUN mkdir -p /tmp/opencl-driver-amd \
    && cd /tmp/opencl-driver-amd \
    && curl --referer ${AMD_DRIVER_URL} -O ${AMD_DRIVER_URL}/${AMD_DRIVER} \
    && tar -Jxvf ${AMD_DRIVER} \
    && cd amdgpu-pro-20.40-1147286-ubuntu-20.04 \
    && ./amdgpu-install --opencl=legacy,pal --headless --no-dkms -y \
    && rm -rf /tmp/opencl-driver-amd

FROM base AS nvidia
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
