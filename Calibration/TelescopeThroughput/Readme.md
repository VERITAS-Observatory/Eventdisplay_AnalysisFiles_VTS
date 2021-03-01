# How to generate g-, T- and S- factors for ED

> Last update: 2021/03/01

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
files with only one column: number of days since 2014-1-1, reflectivities, errors. Filenames are
tracknums-T{}.dat, where T{} is the telescope number. Move these files into the ReflectivityFromDHanna directory
(create if necessary).

## Computation of correction factors.

Once you have the `processed_gain_all_runs_no_CFD.csv` file (gains) and `ReflectivityFromDHanna` directory (WDR), you can proceed 
to run the script `get_throughput.py` with Python3 (you may need a few python modules, you can install them with pip / conda). 
It may happen that you need to modify slightly the script for newer periods of time (note to myself: check this and perhaps prepare for the next 2-3 years).
