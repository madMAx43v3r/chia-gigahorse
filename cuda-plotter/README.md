# Gigahorse GPU Plotter

Gigahorse is a madMAx GPU plotter for compressed k32 plots either fully in RAM with 256G, partially in RAM with 128G or via disk mode.

Other K sizes are supported as well, such as k29 - k34, in theory any K size (if compiled for it).
RAM requirements scale with K size, so k33 needs 512G, k30 only needs 64G, etc.

For k30+ at least 8 GB VRAM are required, use `-S 3` or `-S 2` to reduce VRAM usage (at the cost of performance). The minimum VRAM needed is 4 GB.

Supported GPUs are:

All GPUs for compute capability 5.2 (Maxwell 2.0), 6.0, 6.1 (Pascal), 7.0 (Volta), 7.5 (Turing) and 8.0, 8.6, 8.9 (Ampere).

Which includes: GTX 1000 series, GTX 1600 series, RTX 2000 series, RTX 3000 series and RTX 4000 series

When buying a new GPU, it's recommended to go for a Turing or newer.

## Usage

```
For <pool_key> and <farmer_key>: see output of `chia keys show`.
To plot for pools, specify <contract_address> via -c (instead of <pool_key>): see output of `chia plotnft show`.

Usage:
  cuda_plot [OPTION...]

  -C, --level arg      Compression level (1 to 9 and 11 to 20)
  -x, --port arg       Network port (default = 8444, MMX = 11337)
  -n, --count arg      Number of plots to create (default = 1, unlimited =
                       -1)
  -g, --device arg     CUDA device (default = 0)
  -r, --ndevices arg   Number of CUDA devices (default = 1)
  -t, --tmpdir arg     Temporary directories for plot storage (default =
                       $PWD)
  -2, --tmpdir2 arg    Temporary directory 2 for partial RAM / disk mode
                       (default = @RAM)
  -3, --tmpdir3 arg    Temporary directory 3 for disk mode (default = @RAM)
  -d, --finaldir arg   Final destinations (default = <tmpdir>, remote =
                       @HOST)
  -z, --dstport arg    Destination port for remote copy (default = 1337)
  -w, --waitforcopy    Wait for copy to start next plot
  -p, --poolkey arg    Pool Public Key (48 bytes)
  -c, --contract arg   Pool Contract Address (62 chars)
  -f, --farmerkey arg  Farmer Public Key (48 bytes)
  -Z, --unique         Make unique plot (default = false)
  -D, --directio       Use direct IO for final copy (default = false, Linux
                       only)
  -S, --streams arg    Number of parallel streams (default = 3, must be >= 2)
  -B, --chunksize arg  Bucket chunk size in MiB (default = 16, 1 to 256)
  -Q, --maxtmp arg     Max number of plots to cache in tmpdir (default = -1)
  -A, --copylimit arg  Max number of parallel copies in total (default = -1)
  -W, --maxcopy arg    Max number of parallel copies to same HDD (default =
                       1, unlimited = -1)
  -M, --memory arg     Max shared / pinned memory in GiB (default =
                       unlimited)
      --version        Print version
  -h, --help           Print help
```

Important: `-t` only stores the final plot file, to cache it for final copy. \
Important: `-2` / `-3` should be an SSD for partial RAM / disk mode, not a RAM disk. \
Important: `-M` is need on Windows to limit max GPU shared memory, see below.

Note: The first plot will be slow due to memory allocation. Hence `-n -1` is the recommended way of plotting with Gigahorse.\
Note: `-W` is per HDD, not global. And it doesnt apply to remote destinations. Use `-Q` to limit max number of total parallel copies.

### Full RAM mode (no `-2`, no `-3`)

The GPU plotter uses RAM internally, there is no need for a RAM disk.
All that's needed is a `-t` drive to cache the plots for final copy.

Example with full RAM mode and remote copy:
```
cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -d @REMOTE_HOST -c <contract_address> -f <farmer_key>
```
`REMOTE_HOST` can be a host name or IP address, the `@` prefix is needed to signal remote copy mode.

Example with full RAM mode and local destination:
```
cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -d /mnt/hdd1/ -d /mnt/hdd2/ -c <contract_address> -f <farmer_key>
```

N.B. If you want to make OG, non-NFT compressed plots, use `-p <pool_key>` instead of `-c <contract_address>`.

### Partial RAM mode (128G RAM, SSD for `-2`)

To enable partial RAM mode, specify an SSD drive for `-2`:
```
cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -2 /mnt/fast_ssd/ -d @REMOTE_HOST -c <contract_address> -f <farmer_key>
```

`tmpdir2` requires around 150G - 180G of free space for k32, depending on compression level.

N.B. If you want to make OG, non-NFT compressed plots, use `-p <pool_key>` instead of `-c <contract_address>`.

### Disk mode (8G RAM, SSD for `-3`, optional second SSD for `-2`)

To enable disk mode, specify an SSD drive for `-3`.
```
cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -3 /mnt/fast_ssd/ -d @REMOTE_HOST -c <contract_address> -f <farmer_key>
```
Optionally another SSD can be used for `-2`, if not specified `-2` will be set to the same path as `-3`.

`-2` gets 1/4 of the total writes, while `-3` gets 3/4 (so it should be the faster SSD).

`tmpdir2` + `tmpdir3` requires around 250G of free space for k32, depending on compression level.

N.B. If you want to make OG, non-NFT compressed plots, use `-p <pool_key>` instead of `-c <contract_address>`.

#### Multiple SSDs for 1/4 RAM mode

You can also specify `-2` and `-3` together, where `-3` should be the faster SSD as it will get most of the writes:
```
cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -2 /mnt/fast_ssd/ -3 /mnt/super_fast_ssd/ -d @REMOTE_HOST -c <contract_address> -f <farmer_key>
```
If `-2` is not specified it defaults to the same as `-3`.

N.B. If you want to make OG, non-NFT compressed plots, use `-p <pool_key>` instead of `-c <contract_address>`.

### Multiple Destinations

Multiple destinations can be specified by repeating `-d`:
```
cuda_plot_kxx -d /mnt/hdd0/ -d /mnt/hdd1/ -d /mnt/hdd2 ...
```
The same can be done with remote destinations:
```
cuda_plot_kxx -d @HOST0 -d @HOST1 -d @HOST2 ...
```
It's also possible to mix local HDDs and remote destinations.

At most one copy is done per HDD, while remote destinations are load-balanced.

It's possible to unmount and remount new drives onto the same mount points, the plotter will automatically recover and resume operation.

### Multi-GPU

To plot with multiple GPUs the `-r` flag is used, for example to plot with the first two GPUs:
```
cuda_plot_kxx -r 2 ...
```
Or to plot with GPU 1 and 2 (ie. second and third)
```
cuda_plot_kxx -g 1 -r 2 ...
```
In multi-GPU mode `-g` is an offset to the first GPU to use.

The work is divided evenly between GPUs, so ideally they should be equally fast. Only a power of two is supported, ie. 2, 4, 8 GPUs, etc.

### Pausing behavior

The plotter will automatically pause (and resume) plotting if `tmpdir` is running out of space, which can happen when copy operations are not fast enough.
This free space check will fail when multiple instances are sharing the same drive though. In this case it's recommended to partition the drive and give each plotter their own space.

`-Q` can be used to limit the maxmimum number of plots to be cached in `-t`, this is useful to avoid a slowdown of `-t` as it gets full.

In case of remote copy, the plotter will automatically pause and resume operation when the remote host goes down or the receiver (`chia_plot_sink`) is restarted.

### Windows

On Windows there is a limit on how much pinned memory can be allocated, usually it's half the available RAM.
You can check the limit in TaskManger as "Shared GPU memory" when selecting the Performance tab on your GPU.

Because of this, it's required to limit the max pinned memory via `-M`. For exmaple if your limit is 128 GB, you need to specify `-M 128`.
Unfortunately this will slow down the plotter somewhat, consider using Linux for best performance.

## Remote copy

I've created a remote copy tool called `chia_plot_sink` which receives plots over network from one or more plotters and distributes them over the given list of directories in parallel.

Usage:
```
chia_plot_sink -- /mnt/disk0/ /mnt/disk1/ ...
chia_plot_sink -- /mnt/disk*/
```
Trailing slashes can be omitted here. Port 1337 is used by default. The tool can be used on localhost as well of course.

Ctrl+C will wait for all active copy operations to finish, while not accepting new connections.

During copy the files have a `*.tmp` extension, so in the case of a crash they can be easily removed later.

## Performance

CPU load is very small, a decent quad-core is fine (2 GHz or more).
In case of partial RAM mode SSD speed will be the bottleneck, unless you have 3-4 fast SSDs in a RAID 0.
MLC based SSDs work best, like a Samsung 970 PRO, sustained sequential write speed is the most important metric.
Partial RAM mode is only recommended for existing setups that don't support 256G of RAM. Full RAM mode is always cheaper and faster, in case of DDR3 / DDR4.

On PCIe 3.0 systems the bottleneck will be PCIe bandwidth, DDR3-1600 quad-channel is fast enough (no need for DDR4, except for dual-channel systems).
On PCIe 3.0 systems a RTX 3060 or 3060 Ti are good enough, anything bigger won't be much faster.
On PCIe 4.0 systems RAM bandwidth will be the bottleneck when paired with a bigger GPU.

To make good use of an RTX 3090 you'll need PCIe 4.0 together with 256G of quad-channel DDR4-3200 memory (or better).

### Multi-Socket Systems

Systems with more than one socket and/or featuring processors that leverage multi-chip module (MCM) designs (e.g. Threadripper and EPYC) or Cluster-on-Die (CoD) technology (e.g. high-core-count Broadwell-EP) can be usually configured with either Uniform Memory Access (UMA) topology—all the memory on the system is presented as one addressable space—or Non-Uniform Memory Access (NUMA) topology—the memory on the system is presented as two or more addressable spaces called nodes. Each NUMA node may additionally contain processor cores, shared caches, and I/O (PCIe lanes).

The quickest and easiest way to determine how your system is configured, how many NUMA nodes are present, and which processors, caches, and I/O are assigned to each node is to install `hwloc` (or `hwloc-nox` on non-GUI systems) and run `lstopo`. Here's an example of a two-socket (2P) system configured for NUMA topology with some PCIe devices and half the system memory present in each node:

<img src="https://user-images.githubusercontent.com/8540936/214699108-b23110b0-ab37-40d7-804b-17efc93e3981.png" width="400" />

UMA topology is easier for users and applications to work with because the system looks and feels like one big computer, but performance suffers whenever data must be transferred between processors—imagine a PCIe device attached to one socket reading from and writing to a region of memory attached to a different socket—and there are limited tools available to mitigate this. NUMA topology is harder to work with because you have to know where everything is and specifically tune your workloads to keep them local, but latency and bandwidth can be greatly improved when it is done correctly using the available tools.

If your system is configurable for either UMA or NUMA topology, you can typically do so from within your system BIOS. Some systems have options specifically to enable or disable NUMA; some systems require you to enable memory channel interleave for UMA or disable memory channel interleave for NUMA. And some systems give you some flexibility to choose how many NUMA nodes you want. For example, many EPYC systems let you disable NUMA altogether or choose the number of NUMA nodes per socket.

It's recommended to run one GPU per CPU in case of multi-socket machines, while making sure to match each GPU with the correct CPU that's directly connected, and restricting memory allocations to local RAM.

Example:
```
numactl -N 0 -m 0 ./cuda_plot_k32 -g 0 ...
numactl -N 1 -m 1 ./cuda_plot_k32 -g 1 ...
```

If you have a multi-socket machine and only one GPU, but you want the plotter to be able to access all the memory on the system, you can configure it to preferentially allocate memory from the local node (ideally the node containing the GPU, storage devices, etc.) before allocating memory from other nodes:

Example:
```
numactl -N 0 --preferred=0 ./cuda_plot_k32 ...
```

### Example HP Z420 + RTX 3060 Ti

My test machine is a HP Z420 workstation with a single Xeon E5-2695 v2, 256G (8x32G) of DDR3-1600 memory, 1 TB Samsung 970 PRO SSD, 10G fiber NIC and a RTX 3060 Ti.
It only cost around $1500 to build.

Plotting time for k32 and full RAM mode is ~175 sec, or ~155 sec for level 7+.
Plotting time for k32 and partial RAM mode is ~280 sec, or ~250 sec for level 7+, using a 1 TB Samsung 970 PRO for `tmpdir` and `tmpdir2` (half the RAM filled with zeros).

