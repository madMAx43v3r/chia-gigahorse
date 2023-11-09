FROM debian:12-slim AS base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
	ocl-icd-libopencl1 \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /chia-recompute

COPY docker-start.sh chia_recompute* .
ENV CHIA_RECOMPUTE_PORT="11989"
EXPOSE 11989

CMD ["./docker-start.sh"]


FROM base AS nvidia
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


FROM base AS intel
RUN apt-get update && apt-get install -y intel-opencl-icd \
	&& rm -rf /var/lib/apt/lists/*


FROM base AS amd
ARG AMD_DRIVER=amdgpu-pro-20.40-1147286-ubuntu-20.04.tar.xz
ARG AMD_DRIVER_URL=https://drivers.amd.com/drivers/linux
RUN apt-get update && apt-get install -y \
	curl xz-utils \
    && mkdir -p /tmp/opencl-driver-amd \
    && cd /tmp/opencl-driver-amd \
    && curl --referer ${AMD_DRIVER_URL} -O ${AMD_DRIVER_URL}/${AMD_DRIVER} \
    && tar -Jxvf ${AMD_DRIVER} \
    && cd amdgpu-pro-20.40-1147286-ubuntu-20.04 \
    && ./amdgpu-install --opencl=legacy,pal --headless --no-dkms -y \
    && rm -rf /tmp/opencl-driver-amd \
    && rm -rf /var/lib/apt/lists/*