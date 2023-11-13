# ProofOfSpace

Use `./ProofOfSpace -r 16` to get optimal performance, this will run `check`, `farm` and `lookup` in parallel using 16 threads.

In case of CPU only and more than 16 cores, you can increase `-r` to get more performace.

The harvester and this tool will automatically use all availalable GPUs where it is supported.
Lower C levels (less than K32 C3) will use CPU only since GPU is not efficient for those.

## Limit GPU usage

To limit usage to a certain number of GPUs you can set environment variable:
```
export CHIAPOS_MAX_CUDA_DEVICES=X
```
For example if you have a fast and a slow GPU, set `CHIAPOS_MAX_CUDA_DEVICES=1`, to only use the fast one.

The same works for OpenCL via `CHIAPOS_MAX_OPENCL_DEVICES`.

Alternatively you can set `CUDA_VISIBLE_DEVICES` to a list of devices to use:
```
export CUDA_VISIBLE_DEVICES=1,2
```
This will use the second and third device. (first device is `0`)

Note: `CUDA_VISIBLE_DEVICES` applies to all CUDA applications.

Note: When changing environment variables you need to restart the Chia daemon for it to take effect: `./chia.bin stop all -d`

Note: See here how to set environment variables in Windows: https://phoenixnap.com/kb/windows-set-environment-variable#ftoc-heading-4

### Disable GPU usage

To disable usage of any GPU:
```
export CHIAPOS_MAX_GPU_DEVICES=0
```

To disable only CUDA or OpenCL GPU usage:
```
export CHIAPOS_MAX_CUDA_DEVICES=0
or
export CHIAPOS_MAX_OPENCL_DEVICES=0
```
This is needed to disable usage of an iGPU for example.

### Select OpenCL Platform

If you have more than one OpenCL platform, like Intel + AMD, you have to select one to be used for farming.
For example to use AMD:
```
export CHIAPOS_OPENCL_PLATFORM="AMD Accelerated Parallel Processing"
```
The name of your platform can be found using `clinfo`, see `Platform Name`.

CUDA is automatically used for Nvidia GPUs when available, there is no need to disable OpenCL for Nvidia.

## Limit RAM usage

To reduce RAM usage or increase the max number of cores used you can tune environment variable:
```
export CHIAPOS_MAX_CORES=8
or
export CHIAPOS_MAX_CORES=64
```
The default is `16` cores, which means RAM is allocated for 16 threads, irrespective of how many physical cores are present.

To reduce RAM usage while keeping maximum performance, `CHIAPOS_MAX_CORES` should be set to the number of physical cores or threads, when not using GPU(s).

When using GPU(s) to farm, it is recommended to allocate 2 cores per low end GPU, 4 cores per mid range GPU and 8 cores per high end GPU. With faster CPUs you can use less cores, and thus less RAM.

Note: When changing environment variables you need to restart the Chia daemon for it to take effect: `./chia.bin stop all -d`

## Checking plots

```
./ProofOfSpace check -r 8 -f plot-kxx-cx-xxx.plot
```

## Farming benchmark

To check how many plots of a certain K size and C level you can farm at a specific partial difficulty:
```
./ProofOfSpace farm -r 8 --diff 100 -f plot-kxx-cxx-xxx.plot 1000
```
This test will use all available GPUs. In case of CPU farming, set `-r` to the number of CPU cores / threads.

Note: **This should be performed with the plot on an SSD**, otherwise the benchmark will be IO bound and not accurate.
Alternatively if you dont have an SSD, you can run the benchmark a second time on HDD to get a faily accurate reading, since the data will then be cached in RAM (at least on Linux, and if there is no major disk IO otherwise, like plot copies).

The formula to convert total time for 1000 lookups to maximum farm size in TiB is:
```
max_farm_size_TiB = (plot_size_GiB / 1024) * plot_filter * 8 * 1000 / total_lookup_time_seconds;
```

## List of all Options

- `CHIAPOS_MAX_CORES`: max number of CPU threads (needed even when using GPU(s), but probably less, see above)
- `CHIAPOS_MAX_GPU_DEVICES`: max number of CUDA or OpenCL devices
- `CHIAPOS_MAX_CUDA_DEVICES`: max number of CUDA devices (overrides CHIAPOS_MAX_GPU_DEVICES)
- `CHIAPOS_MAX_OPENCL_DEVICES`: max number of OpenCL devices (overrides CHIAPOS_MAX_GPU_DEVICES)
- `CHIAPOS_RECOMPUTE_HOST`: list of recompute servers, separated by `,` without whitepace (optional port via `HOST:PORT` syntax)
- `CHIAPOS_RECOMPUTE_PORT`: optional custom default port for recompute servers (default = 11989)
- `CHIAPOS_RECOMPUTE_TIMEOUT`: timeout in milliseconds for processing a request (default = 5000)
- `CHIAPOS_RECOMPUTE_CONNECT_TIMEOUT`: timeout in milliseconds for connecting to a server (default = 2000)
- `CHIAPOS_RECOMPUTE_RETRY_INTERVAL`: interval in seconds how often to retry using a previously failed server (default = 100)

# Remote Compute Docker Usage

The Dockerfile file uses multiple build stages to support 4 different applications CPU-Only, NVIDIA-GPU, Intel-GPU, and AMD-GPU.

## CPU-Only

Docker Run Example:

`docker run --rm -it -p 11989:11989 ghcr.io/madmax43v3r/chia-recompute:latest`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-recompute:latest
    restart: unless-stopped
    ports:
      - "11989:11989"
    environment:
      TZ: 'America/Chicago'
#      CHIA_RECOMPUTE_PORT: 12000
### Enable Proxy Mode ###
#      CHIA_RECOMPUTE_PROXY: 'true'
#      CHIA_RECOMPUTE_NODES: 192.168.1.1,192.168.1.2:11990
### GPU Specific Options ###
#      CHIAPOS_MAX_CUDA_DEVICES: 0
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
#      CUDA_VISIBLE_DEVICES: 0   
```
## NVIDIA-GPU

Docker Run Example:

`docker run --rm -it --runtime=nvidia -p 11989:11989 ghcr.io/madmax43v3r/chia-recompute:latest-nvidia`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-recompute:latest-nvidia
    restart: unless-stopped
    runtime: nvidia
    ports:
      - "11989:11989"
    environment:
      TZ: 'America/Chicago'
#      CHIA_RECOMPUTE_PORT: 12000
### Enable Proxy Mode ###
#      CHIA_RECOMPUTE_PROXY: 'true'
#      CHIA_RECOMPUTE_NODES: 192.168.1.1,192.168.1.2:11990
### GPU Specific Options ###
#      CHIAPOS_MAX_CUDA_DEVICES: 0
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
#      CUDA_VISIBLE_DEVICES: 0 
```
Note: for nvidia you also need the `NVIDIA Container Toolkit` installed on the host, for more info please see: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

## Intel-GPU

Docker Run Example:

`docker run --rm -it --device=/dev/dri -p 11989:11989 ghcr.io/madmax43v3r/chia-recompute:latest-intel`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-recompute:latest-intel
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    ports:
      - "11989:11989"
    environment:
      TZ: 'America/Chicago'
#      CHIA_RECOMPUTE_PORT: 12000
### Enable Proxy Mode ###
#      CHIA_RECOMPUTE_PROXY: 'true'
#      CHIA_RECOMPUTE_NODES: 192.168.1.1,192.168.1.2:11990
### GPU Specific Options ###
#      CHIAPOS_MAX_CUDA_DEVICES: 0
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
#      CUDA_VISIBLE_DEVICES: 0 
```
Note: for ARC GPU's you will need to be running kernel 6.2+ on your docker host

## AMD-GPU

Docker Run Example:

`docker run --rm -it --device=/dev/kfd --device=/dev/dri -p 11989:11989 ghcr.io/madmax43v3r/chia-recompute:latest-amd`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-recompute:latest-amd
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
      - /dev/kfd:/dev/kfd
    ports:
      - "11989:11989"
    environment:
      TZ: 'America/Chicago'
#      CHIA_RECOMPUTE_PORT: 12000
### Enable Proxy Mode ###
#      CHIA_RECOMPUTE_PROXY: 'true'
#      CHIA_RECOMPUTE_NODES: 192.168.1.1,192.168.1.2:11990
### GPU Specific Options ###
#      CHIAPOS_MAX_CUDA_DEVICES: 0
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
#      CUDA_VISIBLE_DEVICES: 0 
```
