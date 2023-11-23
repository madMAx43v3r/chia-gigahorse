FROM debian:12-slim AS builder
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
	xz-utils curl

WORKDIR /

ARG GIT_RELEASE
RUN GIT_RELEASE=${GIT_RELEASE%-*} \
    && curl -L https://github.com/madMAx43v3r/chia-gigahorse/releases/download/v${GIT_RELEASE}/chia-gigahorse-farmer-${GIT_RELEASE}-x86_64.tar.gz --output chia-gigahorse-farmer.tar.gz \
    && tar -xf chia-gigahorse-farmer.tar.gz


FROM mikefarah/yq:4 AS yq


FROM debian:12-slim AS base
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
	ocl-icd-libopencl1 tzdata \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /chia-gigahorse-farmer

COPY --from=yq /usr/bin/yq /usr/bin/yq
COPY --from=builder /chia-gigahorse-farmer .
COPY docker-entrypoint.sh docker-start.sh .

ENV CHIA_ROOT="/root/.chia/mainnet"
ENV CHIA_SERVICES="farmer"

EXPOSE 8444 8555

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./docker-start.sh"]


FROM base AS nvidia
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


FROM base AS intel
RUN apt-get update && apt-get install --no-install-recommends -y intel-opencl-icd \
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