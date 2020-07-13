# How to generate g-, T- and S- factors for ED

> Last update: 2020/07/13



S- factors (or what we call total throughput correction) are obtained from two components: gains and reflectivity.

Gains can be obtained from photostat gains (they come for free) and single PE runs. 
Photostat gains are currently recommended due to high cadence and easier/more robust calibration.

## Gains

Just run the script fetch_phgain.sh or run manually 

```
wget https://www.hep.physics.mcgill.ca/~veritas/photostat/processed_gain_all_runs_no_CFD.csv -O processed_gain_all_runs_no_CFD.csv
```

This will modify your local files only. If you want others to have the updated file, please keep this repository updated by committing the results.

As of July 2020 Colin Adams and the McGill group maintains this file updated. Ping them if you need further help. 

## Reflectivity

Reflectivity values are more tricky. They are compiled (as of July 2020) by David Hanna and stored in 
files with only one column and values, errors for the 4 telescopes. Filenames are
averages_MM_Measurement.dat, where MM is the month since beginning of data taking and Measurement is ?? (note for myself: check this)

All these files are packed into a tarball that you have to get from David Hanna (he names them spectra_and_reflec.tar) and untar it 
into the ReflectivityFromDHanna directory.

Once you have the `processed_gain_all_runs_no_CFD.csv` file (gains) and `ReflectivityFromDHanna` directory (WDR), you can proceed 
to run the script `get_throughput_v483.py`
