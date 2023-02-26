# ProofOfSpace

Use `./ProofOfSpace -r 16` to get optimal performance, this will run `check` and `lookup` in parallel using 16 threads.

In case of CPU only and more than 16 cores, you can increase `-r` to get more performace.

The harvester and this tool will automatically use all availalable GPUs where it is supported.
Lower C levels (less than K32 C3) will use CPU only since GPU is not efficient for those.

## Limit GPU usage

To disable GPU usage or to limit to a certain number of GPUs you can set environment variable:
```
export CHIAPOS_MAX_CUDA_DEVICES=0
or
export CHIAPOS_MAX_CUDA_DEVICES=1
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
./ProofOfSpace check -r 8 -f *.plot
```

## Farming benchmark

To check how many plots of a certain K size and C level you can farm on a machine on Linux:
```
time ./ProofOfSpace lookup -r 8 -f *.plot
```

To check how many plots of a certain K size and C level you can farm on a machine on Windows:
```
Measure-Command {./ProofOfSpace lookup -r 8 -f *.plot|Out-Default}
```
This will measure the total time of performing 1000 lookups.

Note: **This should be performed with the plot on an SSD**, otherwise the benchmark will be IO bound and not accurate.

Note: The `real` time is what counts, not `user`. (For Windows use `Total Seconds`)

To convert the total time in seconds to maximum farm size in TiB:
```
max_farm_size_TiB = (plot_size_GiB / 1024) * plot_filter * 8 * 1000 / total_lookup_time_seconds;
```
The plot filter on MMX testnet10 and mainnet will be `256`, while Chia and testnet9 are using `512`.

In case of CPU farming, set `-r` to the number of CPU cores / threads.

