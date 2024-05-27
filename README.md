## Gigahorse 3.0 Compressed Plots

![image](https://github.com/madMAx43v3r/chia-gigahorse/assets/951738/ffa6f03b-a7f7-413c-908c-ca492689c64d)

The chart has been updated for plot filter 256, effective starting on June 13th 2024 (max farm size is half than before).

Partial difficulty is important for maximum farm size, especially for C19 / C20 and C29 to C33 (higher difficulty is better).

Solo farming roughly corresponds to a partial difficulty of 500k (500000).

Join the Discord for support: https://discord.gg/BswFhNkMzY

## Chia Gigahorse Node / Farmer / Harvester

In the [release](https://github.com/madMAx43v3r/chia-gigahorse/releases) section you can find Chia Blockchain binaries to farm compressed plots created with the new plotters provided in this repository.

The compressed plot harvester and farmer are not compatible with the official Chia Node, it only works together with the Gigahorse Node.
However it's possible to use a wallet from the official Chia repository, instead of the Gigahorse binary wallet.

Both NFT and OG plots are supported, as well as solo and pool farming (via the official pool protocol). Regular uncompressed plots are supported as well, so you can use the Gigahorse version while re-plotting your farm.

The dev fee is as follows:
- 3.125 % when using GPU(s) to farm compressed plots
- 1.562 % when using CPU(s) to farm compressed plots
- 0 % for regular uncompressed plots

When you find a block there's a chance the 0.25 XCH farmer reward is used as fee, this is a random process. In case of CPU farming it's 1 out of 8 blocks on average, and for GPU farming it's 1 out of 4 blocks on average.

When the fee is paid from a block, you will see a log entry like this:
```
full_node: WARNING  Used farmer reward of block 2187769 as dev fee (3.125 % on average)
```
It will show the block height as well as the average fee that applies, depending on if the proof was computed via CPU or GPU.

### Pool Partial Difficulty

When farming NFT plots on a pool it is recommended to set the partial difficulty to 20 or more, otherwise your harvester will be overloaded with computing full proofs.

The chance of having to compute a full proof is roughly `1 / (2 * difficulty)`. The cost of computing a full proof is 8 (for C6+) or 16 (for C5 and lower) times that of a quality lookup.

For example:
- Difficulty 20 (at C6+): `8 / 40 = 20 %` compute overhead
- Difficulty 100 (at C6+): `8 / 200 = 4 %` compute overhead
- Difficulty 1000 (at C6+): `8 / 2000 = 0.4 %` compute overhead

### Plot Reload Interval

It is recommended to increase your plot reload interval to at least 3600 seconds in `config.yaml`:
```
harvester:
  plots_refresh_parameter:
    interval_seconds: 3600
```
The default value of 120 sec will cause too much CPU load with large plot counts.

### Usage Linux

Make sure to close any other instances first:
```
chia stop all -d
```
Or close the Chia GUI if you are running it. Otherwise you cannot start the Gigahorse version.

Using the Gigahorse binaries is pretty much the same as with a normal Chia installation:
```
cd chia-gigahorse-farmer
./chia.bin start farmer (full node + farmer + harvester)
./chia.bin start harvester (remote harvester)
./chia.bin show -s
./chia.bin farm summary
./chia.bin plotnft show
./chia.bin wallet show
./chia.bin stop all -d
```
Note the usage of `./chia.bin ...` instead of just `chia ...`, this is the only difference in usage with Gigahorse.

Alternatively, you can `. ./activate.sh` in `chia-gigahorse-farmer` to be able to use `chia ...` commands instead of `./chia.bin ...`.

### Usage Windows

Make sure to close any running Chia GUI first, otherwise you cannot start the Gigahorse version.

To start the farmer double click `start_farmer.cmd` in `chia-gigahorse-farmer`, this will open a terminal where you can continue to issue commands.
To only open a terminal without starting anything you can use `chia.cmd`. To stop everything you can use `stop_all.cmd`.

The usage in general is the same as normal chia:
```
chia.exe start farmer (not: chia start farmer)
chia.exe start harvester (not: chia start harvester)
chia show -s
chia farm summary
chia plotnft show
chia wallet show
chia stop all -d
```

### Official GUI + Gigahorse

You can start the official Chia GUI after starting Gigahorse in a terminal, however it needs to be the same version. It will still complain about version mismatch but when the base version (like `1.6.2`) is the same then it works.

When you close the GUI everything will be stopped, so you need to restart Gigahorse in the terminal again if so desired.

### Installation

Note: There is no need to re-sync the blockchain, Gigahorse node will re-use your existing DB and config. Even the old v1 DB format still works.

#### Linux
```
sudo apt install ocl-icd-libopencl1
tar xf chia-gigahorse-farmer-*.tar.gz
```

#### Windows

Just unzip the chia-gigahorse-farmer-*.zip somewhere.

You might also have to install latest Microsoft Visual C++ Redistributable: https://aka.ms/vs/17/release/vc_redist.x64.exe

### Limit GPU / RAM usage

Please take a look at:
- [How to limit GPU usage](https://github.com/madMAx43v3r/chia-gigahorse/blob/master/chiapos/README.md#limit-gpu-usage)
- [How to limit RAM usage](https://github.com/madMAx43v3r/chia-gigahorse/blob/master/chiapos/README.md#limit-ram-usage)

Note: When changing environment variables you need to restart the Chia daemon for it to take effect: `./chia.bin stop all -d` or `chia.exe stop all -d`

### RAM / VRAM requirements to farm

![image](https://github.com/madMAx43v3r/chia-gigahorse/assets/951738/742fde23-cce2-4548-91ec-b22199fb435e)

![image](https://github.com/madMAx43v3r/chia-gigahorse/assets/951738/a1fd6c50-711d-4b79-947a-76a32783ccec)

When mixing different K size and C levels, only the higest RAM / VRAM requirement applies.

## K33+

![image](https://github.com/madMAx43v3r/chia-gigahorse/assets/951738/6bb34775-8e8b-480b-84f6-4bff49b46534)

K33+ performance for the new C11 to C20 is considerably less than K32.
In addition higher K size benefits more from a higher partial difficulty.

### Remote Compute

It's possible to move the compute task to another machine or machines, in order to avoid having to install a GPU or powerful CPU in every harvester:

![Remote_Compute_Drawings drawio](https://github.com/madMAx43v3r/chia-gigahorse/assets/951738/9bb8d9b7-6a15-4b4a-82aa-6ab72471d5e5)

To use the remote compute feature:
- Start `chia_recompute_server` on the machine that is doing the compute (included in release).
- `export CHIAPOS_RECOMPUTE_HOST=...` on the harvester (replace `...` with the IP address or host name of the compute machine, and make sure to restart via `chia stop all -d` or `stop_all.cmd` on windows)
- On Windows you need to set `CHIAPOS_RECOMPUTE_HOST` variable via system settings.
- `CHIAPOS_RECOMPUTE_HOST` can be a list of recompute servers, such as `CHIAPOS_RECOMPUTE_HOST=192.168.0.11,192.168.0.12`. A non-standard port can be specified via `HOST:PORT` syntax, such as `localhost:12345`. Multiple servers are load balanced in a fault tolerant way.
- `CHIAPOS_RECOMPUTE_PORT` can be set to specify a custom default port for `chia_recompute_server` (default = 11989).
- See `chia_recompute_server --help` for available options.

To use the remote compute proxy:
- Start `chia_recompute_proxy -n B -n C ...` on a machine `A`. (`B`, `C`, etc are running `chia_recompute_server`)
- Set `CHIAPOS_RECOMPUTE_HOST` on your harvester(s) to machine A.
- `chia_recompute_proxy` can be run on a central machine, or on each harvester itself, in which case `A = localhost`.
- See `chia_recompute_proxy --help` for available options.

When using `CHIAPOS_RECOMPUTE_HOST`, the local CPU and GPUs are not used, unless you run a local `chia_recompute_server` and `CHIAPOS_RECOMPUTE_HOST` includes the local machine.

#### CPU based Compute Servers
For CPU based compute it's important to increase `CHIAPOS_MAX_CORES` on the harvesters to achieve full CPU utilization on compute servers.
Because `CHIAPOS_MAX_CORES` is the maximum parallel requests made from a harvester to recompute servers, and a request is processed on a single CPU core only.
By default `CHIAPOS_MAX_CORES` is the number of phsical CPU cores on the harvester.

For example if you have a single compute server with 32 CPU cores, you should set `CHIAPOS_MAX_CORES` on the harvesters to 32.
The sum of `CHIAPOS_MAX_CORES` accross all harvesters should be greater or equal to the sum of CPU cores on all compute servers.
In case of low number of harvesters (ie. 1-3) you should set `CHIAPOS_MAX_CORES` to the number of CPU cores on your compute server.

### Known Issues

- AMD GPU getting stuck in Linux, workaround is: `watch -n 0.1 sudo cat /sys/kernel/debug/dri/0/amdgpu_pm_info`

### Fixed in latest version

N / A

## Gigahorse GPU Plotter

You can find the GPU plotter binaries in [cuda-plotter](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/cuda-plotter).

They support plotting for Chia as well as MMX.

## CPU Plotter

You can find the CPU plotter binaries in [cpu-plotter](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/cpu-plotter).

They support plotting for Chia as well as MMX.

## Farming Benchmark

To test how many plots you can farm on a given system you can use the `ProofOfSpace` tool in [chiapos](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/chiapos).

## Plot Sink

Plot Sink is a tool to receive plots over the network and copy them to multiple HDDs in parallel.

You can find binaries in [plot-sink](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/plot-sink)

See also the open source repository: https://github.com/madMAx43v3r/chia-plot-sink

## Docker Usage

The Dockerfile file uses multiple build stages to support 4 different applications CPU-Only, NVIDIA-GPU, Intel-GPU, and AMD-GPU.

It is highly recommended to run the container with the `/root/.chia/mainnet` directory mapped to a local volume for persistant storage of the database and config files

### CPU-Only

Docker Run Example:

`docker run --rm -it -v /path/to/.chia:/root/.chia/mainnet -p 8444:8444 ghcr.io/madmax43v3r/chia-gigahorse:latest`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-gigahorse:latest
    restart: unless-stopped
    volumes:
      - /path/to/.chia:/root/.chia/mainnet
#      - /path/to/plots:/plots
#      - /path/to/ssl/ca:/path/in/container
    ports:
      - "8444:8444"
    environment:
#      TZ: 'UTC'
      CHIA_SERVICES: 'farmer'
#      CHIA_UPNP: 'true'
#      CHIA_LOG_LEVEL: 'WARNING'
#      CHIA_HOSTNAME: 127.0.0.1
#      CHIA_PLOTS: /plots
### Remote harvester settings
#      CHIA_FARMER_ADDRESS: 127.0.0.1
#      CHIA_FARMER_PORT: 8447
#      CHIA_CA: /path/in/container
### Remote compute server
#      CHIAPOS_RECOMPUTE_HOST: 192.168.1.12   
```
### NVIDIA-GPU

Docker Run Example:

`docker run --rm -it --runtime=nvidia -v /path/to/.chia:/root/.chia/mainnet -p 8444:8444 ghcr.io/madmax43v3r/chia-gigahorse:latest-nvidia`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-gigahorse:latest-nvidia
    restart: unless-stopped
    runtime: nvidia
    volumes:
      - /path/to/.chia:/root/.chia/mainnet
#      - /path/to/plots:/plots
#      - /path/to/ssl/ca:/path/in/container
    ports:
      - "8444:8444"
    environment:
#      TZ: 'UTC'
      CHIA_SERVICES: 'farmer'
#      CHIA_UPNP: 'true'
#      CHIA_LOG_LEVEL: 'WARNING'
#      CHIA_HOSTNAME: 127.0.0.1
#      CHIA_PLOTS: /plots
### Remote harvester settings
#      CHIA_FARMER_ADDRESS: 127.0.0.1
#      CHIA_FARMER_PORT: 8447
#      CHIA_CA: /path/in/container
### Remote compute server
#      CHIAPOS_RECOMPUTE_HOST: 192.168.1.12
### GPU Specific Options ###
#      NVIDIA_VISIBLE_DEVICES: 0,3
```
Note: for nvidia you also need the `NVIDIA Container Toolkit` installed on the host, for more info please see: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker

### Intel-GPU

Docker Run Example:

`docker run --rm -it --device=/dev/dri -v /path/to/.chia:/root/.chia/mainnet -p 8444:8444 ghcr.io/madmax43v3r/chia-gigahorse:latest-intel`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-gigahorse:latest-intel
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - /path/to/.chia:/root/.chia/mainnet
#      - /path/to/plots:/plots
#      - /path/to/ssl/ca:/path/in/container
    ports:
      - "8444:8444"
    environment:
#      TZ: 'UTC'
      CHIA_SERVICES: 'farmer'
#      CHIA_UPNP: 'true'
#      CHIA_LOG_LEVEL: 'WARNING'
#      CHIA_HOSTNAME: 127.0.0.1
#      CHIA_PLOTS: /plots
### Remote harvester settings
#      CHIA_FARMER_ADDRESS: 127.0.0.1
#      CHIA_FARMER_PORT: 8447
#      CHIA_CA: /path/in/container
### Remote compute server
#      CHIAPOS_RECOMPUTE_HOST: 192.168.1.12
### GPU Specific Options ###
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
```
Note: for ARC GPU's you will need to be running kernel 6.2+ on your docker host

### AMD-GPU

Docker Run Example:

`docker run --rm -it --device=/dev/kfd --device=/dev/dri -v /path/to/.chia:/root/.chia/mainnet -p 8444:8444 ghcr.io/madmax43v3r/chia-gigahorse:latest-amd`

Docker Compose Example:
```yml
version: '3'
services:
  chia:
    image: ghcr.io/madmax43v3r/chia-gigahorse:latest-amd
    restart: unless-stopped
    devices:
      - /dev/dri:/dev/dri
      - /dev/kfd:/dev/kfd
    volumes:
      - /path/to/.chia:/root/.chia/mainnet
#      - /path/to/plots:/plots
#      - /path/to/ssl/ca:/path/in/container
    ports:
      - "8444:8444"
    environment:
#      TZ: 'UTC'
      CHIA_SERVICES: 'farmer'
#      CHIA_UPNP: 'true'
#      CHIA_LOG_LEVEL: 'WARNING'
#      CHIA_HOSTNAME: 127.0.0.1
#      CHIA_PLOTS: /plots
### Remote harvester settings
#      CHIA_FARMER_ADDRESS: 127.0.0.1
#      CHIA_FARMER_PORT: 8447
#      CHIA_CA: /path/in/container
### Remote compute server
#      CHIAPOS_RECOMPUTE_HOST: 192.168.1.12
### GPU Specific Options ###
#      CHIAPOS_MAX_OPENCL_DEVICES: 0
```

### Further Customization

You can modify the container options by uncommenting the relevent settings in the docker-compose example and changing them from the defaults.

#### Services

You can set which services to run with the `CHIA_SERVICES` environment variable.

Docker Run Examples:
```
-e CHIA_SERVICES="harvester"
-e CHIA_SERVICES="node farmer-only"
-e CHIA_SERVICES="node farmer-only wallet"
```
Docker Compose Examples:
```yml
environment:
  - CHIA_SERVICES="harvester"

environment:
  - CHIA_SERVICES="node farmer-only"
  
environment:
  - CHIA_SERVICES="node farmer-only wallet"
```
When setting `CHIA_SERVICES="harvester"` you will also need to specify the following environment variables `CHIA_CA` `CHIA_FARMER_ADDRESS` `CHIA_FARMER_PORT`

Docker Compose - uncomment the relevant lines in the example above and adjust the settings accordingly.

Docker Run - add the following to your command:

`-e CHIA_FARMER_ADDRESS="farmer.ip.address" -e CHIA_FARMER_PORT="8447" -v /path/to/ssl/ca:/path/in/container -e CHIA_CA="/path/in/container"`

#### Plots

Add plot directories by uncommenting the `CHIA_PLOTS` environment variable and set the `/path/to/plots` volume to a local plot directory

#### Keys

Add keys by entering the container shell and using the chia keys command:

`docker exec -it container-name bash`
`./chia.bin keys add`
