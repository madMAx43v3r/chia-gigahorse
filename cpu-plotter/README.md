# chia-plotter (pipelined multi-threaded)

This version creates v2.4 compressed plots, with compression level `-C` from 1 to 9.

Both Chia and MMX are supported. The respective binary node / harvester are needed to farm these plots.

Remote copy to a plot sink is now supported via `-d @hostname` or `-d @ip`.

## Usage

Join the Discord for support: [https://discord.gg/BswFhNkMzY](https://discord.gg/BswFhNkMzY)

```
For <poolkey> and <farmerkey> see output of `chia keys show`.
To plot for pools, specify <contract> address via -c instead of <poolkey>, see `chia plotnft show`.
<tmpdir> needs about 220 GiB space, it will handle about 25% of all writes. (Examples: './', '/mnt/tmp/')
<tmpdir2> needs about 110 GiB space and ideally is a RAM drive, it will handle about 75% of all writes.
Combined (tmpdir + tmpdir2) peak disk usage is less than 256 GiB.
In case of <count> != 1, you may press Ctrl-C for graceful termination after current plot is finished,
or double press Ctrl-C to terminate immediately.

Usage:
  chia_plot [OPTION...]

  -k, --size arg       K size (default = 32, k <= 32)
  -C, --level arg      Compression level (default = 1, min = 1, max = 9)
  -x, --port arg       Network port (default = 8444, chives = 9699, MMX = 11337)
  -n, --count arg      Number of plots to create (default = 1, -1 = infinite)
  -r, --threads arg    Number of threads (default = 4)
  -u, --buckets arg    Number of buckets (default = 256)
  -v, --buckets3 arg   Number of buckets for phase 3+4 (default = buckets)
  -t, --tmpdir arg     Temporary directory, needs ~220 GiB (default = $PWD)
  -2, --tmpdir2 arg    Temporary directory 2, needs ~110 GiB [RAM] (default = <tmpdir>)
  -d, --finaldir arg   Final directory to copy plots to (default = <tmpdir>, remote = @host)
  -z, --dstport arg    Destination port for remote copy (default = 1337)
  -s, --stagedir arg   Stage directory to write plot file (default = <tmpdir>)
  -w, --waitforcopy    Wait for copy to start next plot
  -p, --poolkey arg    Pool Public Key (48 bytes)
  -c, --contract arg   Pool Contract Address (62 chars)
  -f, --farmerkey arg  Farmer Public Key (48 bytes)
  -G, --tmptoggle      Alternate tmpdir/tmpdir2 (default = false)
  -D, --directout      Create plot directly in finaldir (default = false)
  -Z, --unique         Make unique plot (default = false)
  -K, --rmulti2 arg    Thread multiplier for P2 (default = 1)
      --version        Print version
      --help           Print help

```

Make sure to crank up `<threads>` if you have plenty of cores, the default is 4.
Depending on the phase more threads will be launched, the setting is just a multiplier.

RAM usage depends on `<threads>` and `<buckets>`.
With the new default of 256 buckets it's about 0.5 GB per thread at most.

`-G` option will alternate the temp dirs used while plotting to give each one, tmpdir and tmpdir2, equal usage. The first plot creation will use tmpdir and tmpdir2 as expected. The next run, if -n equals 2 or more, will swap the order to tmpdir2 and tmpdir. The next run swaps again to tmpdir and tmpdir2. This will occur until the number of plots created is reached or until stopped.

### RAM disk setup on Linux
`sudo mount -t tmpfs -o size=110G tmpfs /mnt/ram/`

Note: 128 GiB System RAM minimum required for RAM disk.

### Remote Copy

```
./chia_plot -d @192.168.0.111 ...
```
Replace `192.168.0.111` with the IP address or hostname where `chia_plot_sink` is running.

