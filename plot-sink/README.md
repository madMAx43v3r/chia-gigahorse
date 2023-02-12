# chia-plot-sink

Final copy engine to receive plots from one or more plotters via TCP and distribute to multiple disks in parallel.

`chia_plot_sink` acts as a TCP server listening for connections from plotters, run `chia_plot_sink` on any machine hosting disks as follows:

```
./chia_plot_sink -- /mnt/disk0/ /mnt/disk1/ ...
```

On the plotting machine or machines, set `-d @ip.of.plot.sink` for transfer over network (should be at least 10Gb for a single plotter making 3 minute plots). If the drives are on the plotter itself, use `-d @localhost` or use the hostname of the machine such as `-d @DESKTOP-ABCDEF12` on windows.

```
./cuda_plot_kxx -n -1 -C 7 -t /mnt/ssd/ -d @<HOSTNAME> -c <pool_contract> -f <farmer_key>
```

If plot_sink is taken offline or disconnected (such as temporarily stopped for changing the disk outputs) the plotter will give errors while it is off, but will resume normal operation when it is back online.

### Disable folders when unmounted

In order to allow unmounting and re-mounting drives while plot sink is running, you can put a file called `chia_plot_sink_disable` or `chia_plot_sink_disable.txt` into the folder when unmounted.

If `chia_plot_sink` finds such a file in a folder it will not copy any plots there. The same works for the GPU plotter as well.

## Manual Copy

You can use the `chia_plot_copy` tool to manually send plots to a plot sink as follows:
```
./chia_plot_copy -d -t <IP/HOST> -- my/path/plot-*
```
`-d` will delete plots when the copy is successful.

### Windows

Windows PowerShell (and Command Prompt) doesn't expand wildcards like a typical shell, so you have to jump through an extra hoop to expand any wildcard(s) before calling the program:

```
.\chia_plot_copy.exe -d -t <IP/HOST> -- $(Resolve-Path -Path "my\path\plot-*")
```
