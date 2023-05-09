## Gigahorse Compressed Plots

![image](https://user-images.githubusercontent.com/951738/217386439-751908c7-f1b3-4c4e-9c7a-073d9c9fa721.png)

Since Chia still has a plot filter of 512 until some time in 2024, the farming capacity is twice that until then.

MMX testnet10 and mainnet will have a plot filter of 256.

Join the Discord for support: https://discord.gg/BswFhNkMzY

### RAM / VRAM requirements to farm

![image](https://user-images.githubusercontent.com/951738/217621063-bec9e8b7-3fc0-40f9-a6d7-649e3d90b015.png)

![image](https://user-images.githubusercontent.com/951738/217621150-b110fb00-12be-452d-8ea5-ece2fb69cc40.png)

When you mix different K size and C levels, only the higest RAM / VRAM requirement will apply.

For now all the compute is done on the harvester machine, offloading to farmer machine will be supported in the future.

## FlexFarmer v2.3.0

Using FlexFarmer is an alternative to running Gigahorse Chia node / farmer / harvester. It does not require running a Node, but you have to switch your NFT to flexpool.

See here for more info on how to use FlexFarmer:
https://www.reddit.com/r/Flexpool/comments/11a2mqe/flexfarmer_v230_gigahorse_madmax43v3rs_compressed/

GPU farming on Nvidia is only supported on Linux for now. Support for AMD and Intel is in the works, and that will work on Windows as well.

Note: The fee is taken from the partials with FlexFarmer, instead of the 0.25 XCH farmer block reward, so there is no fear of paying too much fee if unlucky.

## Chia Gigahorse Node / Farmer / Harvester

In the [release](https://github.com/madMAx43v3r/chia-gigahorse/releases) section you can find Chia Blockchain binaries to farm compressed plots created with the new plotters provided in this repository.

The compressed plot harvester and farmer are not compatible with the official Chia node, it only works together with the Gigahorse node.
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
Otherwise the `./chia.bin ...` command will use the old version that is already running.

Using the Gigahorse binaries is pretty much the same as with a normal Chia installation:
```
cd chia-gigahorse-farmer
./chia.bin start farmer
```
Note the usage of `./chia.bin ...` instead of just `chia ...`, this is the only difference in usage with Gigahorse.

Also: There is no need to re-sync the blockchain, Gigahorse node will re-use your existing DB and config. Even the old v1 DB format still works.

### Usage Windows

Make sure to close any running Chia GUI first.

To start the farmer double click `start_farmer.cmd` in `chia-gigahorse-farmer`, this will open a terminal where you can continue to issue commands.
To only open a terminal without starting anything you can use `chia.cmd`. To stop everything you can use `stop_all.cmd`.

The usage in general is the same as normal chia:
```
.\chia.exe start farmer
.\chia.exe farm summary
.\chia.exe plotnft show
.\chia.exe show -s
.\chia.exe wallet show
.\chia.exe stop all -d
```

You can even start the official Chia GUI after starting Gigahorse, however it needs to be the same version. It will still complain about version mismatch but when the base version (like `1.6.2`) is the same then it works.

When you close the GUI everything will be stopped, so you need to restart Gigahorse via `start_farmer.cmd` or `.\chia.exe start farmer` again if so desired.

### Installation

#### Linux
```
sudo apt install libgomp1 ocl-icd-opencl-dev
tar xf chia-gigahorse-farmer-*.tar.gz
```

#### Windows

Just unzip the chia-gigahorse-farmer-*.zip somewhere.

You might also have to install latest Microsoft Visual C++ Redistributable: https://aka.ms/vs/17/release/vc_redist.x64.exe

### Limit GPU / RAM usage

Please take a look at:
- [How to limit GPU usage](https://github.com/madMAx43v3r/chia-gigahorse/blob/master/chiapos/README.md#limit-gpu-usage)
- [How to limit RAM usage](https://github.com/madMAx43v3r/chia-gigahorse/blob/master/chiapos/README.md#limit-ram-usage)

Note: When changing environment variables you need to restart the Chia daemon for it to take effect: `./chia.bin stop all -d`

### Known Issues

- AMD GPU getting stuck in Linux, workaround is: `watch -n 0.1 sudo cat /sys/kernel/debug/dri/0/amdgpu_pm_info`

### Fixed in latest version

- Harvester crashing randomly after some time
- Multiple OpenCL GPUs not working together when farming
- Multiple GPUs not being fully utilized when farming

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
