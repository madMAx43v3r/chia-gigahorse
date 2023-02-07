# ProofOfSpace

Use `-r 8` to get optimal performance, this will run `check` and `lookup` in parallel using 8 threads.

In case of CPU only and more than 8 cores, you can increase `-r` to get more performace.

The harvester and this tool will automatically use all availalable GPUs where it is supported.
Lower C levels will use CPU only since GPU is not efficient for those.

To disable GPU usage or to limit to a certain number of GPUs you can set environment variable:
```
export CHIAPOS_MAX_CUDA_DEVICES=0
or
export CHIAPOS_MAX_CUDA_DEVICES=1
```
For example if you have a fast and a slow GPU, set `CHIAPOS_MAX_CUDA_DEVICES=1`, to only use the fast one.

To reduce RAM usage or increase the max number of cores used you can tune environment variable:
```
export CHIAPOS_MAX_CORES=8
or
export CHIAPOS_MAX_CORES=64
```
The default is `16` cores, which means RAM is allocated for 16 threads, irrespective of how many physical cores are present.

To reduce RAM usage while keeping maximum performance, `CHIAPOS_MAX_CORES` should be set to the number of physical cores / threads.

The actual RAM usage depends on the maximum K size and compression level of your plots, and can be approximated as:
```
RAM_needed_GB = 2^(K_max + C_max - 38) * CHIAPOS_MAX_CORES
```

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

