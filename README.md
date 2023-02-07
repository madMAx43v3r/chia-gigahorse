## Gigahorse Compressed Plots

TODO

## Chia Gigahorse Node / Farmer / Harvester

In the [release](https://github.com/madMAx43v3r/chia-gigahorse/releases) section you can find Chia Blockchain binaries to farm compressed plots created with the new plotters provided in this repository.

The compressed plot harvester and farmer are not compatible with the official Chia node, it only works together with the Gigahorse node.
However it's possible to use a wallet from the official Chia repository, instead of the Gigahorse binary wallet.

Both NFT and OG plots are supported, as well as solo and pool farming (via the official pool protocol). Regular uncompressed plots are supported as well, so you can use the Gigahorse version while re-plotting your farm.

The dev fee is as follows:
- 3.125 % when using GPU(s) to farm compressed plots
- 1.562 % when using CPU(s) to farm compressed plots
- 0 % for regular uncompressed plots

The fee is applied per harvester, so you can mix CPU and GPU harvesters.
When you find a block there's a chance the farmer reward is used as fee, this is a random process.

When the fee is paid from a block, you will see a log entry like this:
```
full_node: WARNING  Used farmer reward of block 2187769 as dev fee (3.125 % on average)
```
It will show the block height as well as the average fee that applies, depending on if the proof was computed via CPU or GPU.

### Usage

Using the Gigahorse binaries is pretty much the same as with a normal Chia installation:
```
cd chia-gigahorse-farmer
. ./activate.sh
chia start farmer
```

Make sure to close any other instances first:
```
chia stop all -d
```
Otherwise the `chia ...` commands will use the old version that is already running.

## Gigahorse GPU Plotter

You can find the GPU plotter binaries in [cuda-plotter](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/cuda-plotter).

They support plotting for Chia as well as MMX.

## CPU Plotter

You can find the CPU plotter binaries in [cpu-plotter](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/cpu-plotter).

They support plotting for Chia as well as MMX.

## Farming Benchmark

To test how many plots you can farm on a given system you can use the `ProofOfSpace` tool in [chiapos](https://github.com/madMAx43v3r/chia-gigahorse/tree/master/chiapos).

