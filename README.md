# Eventdisplay Analysis Files

[![DOI](https://zenodo.org/badge/220767628.svg)](https://doi.org/10.5281/zenodo.10616288)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Configuration and run parameter files for Eventdisplay. Required for the analysis of VERITAS data.

The version of Eventdisplay for this repository can be found in the files [IRFVERSION](IRFVERSION) and [IRFMINORVERSION](IRFMINORVERSION).

The analysis requires additional IRF files (lookup tables, gamma-hadron BDT trees, etc) which are too big for this repository. These files are available through the UCLA archive or direct download from DESY disks (restricted access).

To download and unpack the IRFs from the UCLA archive, run in the Eventdisplay\_AnalysisFiles\_VTS directory:

```bash
./download_irfs.sh transfer/file_list_V6.dat
./download_irfs.sh transfer/file_list_V4V5.dat
```

Total download size is about 200 GB.

For further information on this release, see the [Eventdisplay v492 release page](https://github.com/VERITAS-Observatory/EventDisplay_Release_v492/blob/main/README.md) (restricted access).

Following directories and files are available:

ParameterFiles:

- parameter files required for running most steps of Eventdisplay
- EVNDISP.global.runparameter (global parameters like VERITAS position; URL of VERITAS DB; location of VERITAS raw data archive)
- VERITAS.Epochs.runparameter (definition of VERITAS epochs (V4,V5,V6); summer/winter; absolute gains)
- EVNDISP.reconstruction.runparameter (parameters used in Eventdisplay reconstruction)
- EVNDISP.specialchannels.dat (definition of special channels like L2 channels)
- EVNDISP.validchannels.dat (criteria for dead channel finders)
- ANASUM.runparameter (parameter file for anasum step)
- ANASUM.timemask.dat (time mask example for anasum step)
- ANASUM.runlist (run list example for anasum step)
- TMVA.BDT.runparameter and TMVA.BDT.V4.runparameter (runparameter for TMVA training)
- XGB-classify-parameter.json (parameter file for XGBoost classification step)

GammaHadronCutFiles

- parameter files for gamma/hadron separation cuts

AstroData:

- example catalogs and typical Crab Nebula spectra

Calibration:

- low-gain calibration files required for Eventdisplay analysis
- pulse-shapes used in CARE simulations (Calibration/CareSimulations)
- example file for calibration list to be used to overwrite DB flasher/laser values in the analysis (Calibration/calibrationlist.dat)

DetectorGeometry:

- configuration files for pixel and telescope positions

A full list of the available instrument response functions can be found in the [v492 release page](https://github.com/VERITAS-Observatory/EventDisplay_Release_v492/blob/main/README.md).

## Technical details for maintainers

### Updating IRF files

For version changes, the following files need to be changed:

- [README.md](README.md)
- [IRFVERSION](IRFVERSION)
- [IRFMINORVERSION](IRFMINORVERSION)

### Uploading IRF files

1. Pack IRF files into several tar packages (scripts are located in the `transfer/` directory)

```bash
./transfer/pack_irfs_for_ucla.sh
```

2. Inspect tar packages in the directory `tar_packages` and move them to the directory `archive`

3. Upload files to UCLA (scripts are located in the `transfer/` directory)

```bash
./transfer/put_irfs_to_ucla.sh
```

4. Test some uploads with the downloading script (modify to avoid downloading everything again):

```bash
./download_irfs.sh transfer/file_list_V6.dat
```

Note that for DESY users, the tar packages are not downloaded but copied from their archive location.

## Citing this Software

Please cite this software if it is used for a publication, see the [Zenodo record](https://doi.org/10.5281/zenodo.10616288) and [CITATION.cff](CITATION.cff) for details.
