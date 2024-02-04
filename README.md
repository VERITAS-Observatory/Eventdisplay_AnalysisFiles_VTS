# Eventdisplay Analysis Files

[![DOI](https://zenodo.org/badge/220767628.svg)](https://zenodo.org/doi/10.5281/zenodo.10616288)

Configuration and run parameter files for Eventdisplay.

Required for the analysis of VERITAS data.

Analysis additional IRF files (lookup tables, radial acceptances, etc) which are too big for this repository. These files are available through the UCLA archive (restricted access).
To download and unpack the IRFs from the UCLA archive, run in the Eventdisplay_AnalysisFiles directory:

```bash
./download_irfs.sh transfer/file_list_V6.dat
./download_irfs.sh transfer/file_list_V4V5.dat
```

Further information on this release see the [Eventdisplay v490 release page](https://github.com/VERITAS-Observatory/EventDisplay_Release_v490/blob/main/README.md) (restricted access).

Following directories and files are available:

Parameter Files

- parameter files required for running most steps of Eventdisplay
- EVNDISP.global.runparameter (global parameters like VERITAS position; URL of VERITAS DB; location of VERITAS raw data archive)
- VERITAS.Epochs.runparameter (definition of VERITAS epochs (V4,V5,V6); summer/winter; absolute gains)
- EVNDISP.reconstruction.runparameter (parameters used in Eventdisplay reconstruction)
- EVNDISP.specialchannels.dat (definition of special channels like L2 channels)
- EVNDISP.validchannels.dat (criteria for dead channel finders)
- ANASUM.runparameter (parameter file for anasum step)
- ANASUM.timemask.dat (time mask example for anasum step)
- ANASUM.runlist (run list example for anasum step)
- TMVA.BDT.runparameter (runparameter for TMVA training)

GammaHadronCutFiles

- parameter files for gamma/hadron separation cuts

AstroData:

- example catalogs and typical Crab Nebula spectra

Calibration

- low-gain calibration files required for Eventdisplay analysis
- pulse-shapes used in CARE simulations (Calibration/CareSimulations)
- example file for calibration list to be used to overwrite DB flasher/laser values in the analysis (Calibration/calibrationlist.dat)

DetectorGeometry

- configuration files for pixel and telescope positions

A full list of the available instrument response functions can be found in the release documentation (e.g. [v490 release page](https://github.com/VERITAS-Observatory/EventDisplay_Release_v490/blob/main/README.md)).

## Technical

For version changes, the following files need to be changed:

- [README.md](README.md)
- [download_irfs.sh](download_irfs.sh)
- [put_irfs_to_ucla.sh](put_irfs_to_ucla.sh)
- [transfer/pack_irfs_pack_ucla.sh](transfer/pack_irfs_pack_ucla.sh)

## Uploading IRFs

1. Pack IRFs into several tar packages

```bash
./pack_irfs_pack_ucla.sh
```

2. Inspect tar packages in the directory `tar_packages` and move them to the directory `archive`

3. Upload files to UCLA

```bash
./put_irfs_to_ucla.sh
```

4. Test some uploads with downloading script (modify, to not download again everything):
```bash
./download_irfs_from_ucla.sh transfer/file_list_V6.dat
```

Note that for DESY users, the tar packages are not downloaded but copied from their archive location.
