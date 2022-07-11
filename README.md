# Eventdisplay Analysis Files - version v487 (latest: auxv01)

Configuration and runparameter files for Eventdisplay

Required for the analysis of VERITAS data. 

Analysis requires additional IRF files (lookup tables, radial acceptances, etc). These are available through the UCLA archive.
To download and unpack the IRFs from the UCLA archive, run in the Eventdisplay_AnalysisFiles directory:

```
./get_irfs_from_ucla.sh
```

Further information on this relase: https://veritas.sao.arizona.edu/wiki/index.php/Eventdisplay_v487

Following directories and files are available:

ParameterFiles
- parameter files required for running most steps of Eventdisplay
- EVNDISP.global.runparameter (global parameters like VERITAS position; URL of VERITAS DB; location of VERITAS raw data archive)
- VERITAS.Epochs.runparameter (definition of VERITAS epochs (V4,V5,V6); summer/winter; absolute gains)
- EVNDISP.reconstruction.runparameter (parameters used in eventdisplay reconstruction)
- EVNDISP.specialchannels.dat (definition of special channels like L2 channels)
- EVNDISP.validchannels.dat (criteria for dead channel finders)
- ANASUM.runparameter (parameter file for anasum step)
- ANASUM.timemask.dat (time mask example for anasum step)
- ANASUM.runlist (run list example for anasum step)

GammaHadronCutFiles
- parameter files for gamma/hadron separation cuts

AstroData:
- example catalogues and typical Crab Nebula spectra

Calibration 
- low-gain calibration files required for Eventdisplay analysis
- pulse-shapes used in CARE simulations (Calibration/CareSimulations)
- example file for calibration list to be used to overwrite DB flasher/laser values in the anlaysis (Calibration/calibrationlist.dat)

DetectorGeometry
- configuration files for pixel and telescope positions

# IRF Description

## v487

All v487 effectivea area IRFs are identical to v486 in their values, but **not** in the data format.
Mixing of version is therefore not possible at the anasum stage.

### V4

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V4 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485b (plate scale corrections) | - DONE |
V4 Summer | 0-65 deg | 0-2 deg | 75-750 MHz | v485b (plate scale corrections) | - DONE |

### V5

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V5 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485 | identical with v485 DONE |
V5 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485 | identical with v485 DONE |

### V6 Winter (nominal HV)

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485, v486 | identical with v485, except 55,60deg (v486) |
V6 2019_2019w |  0-60 deg |  0-2 deg | 50-450 MHz  | v486 | - |
V6 2020_2021w |  0-60 deg |  0-2 deg | 50-450 MHz  | v486 | - |
V6 2021_2022w |  0-60 deg |  0-2 deg | 50-450 MHz  | v487 | - |

### V6 Summer (nominal HV)

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485c | identical with v485c  |
V6 2019_2019s |  0-60 deg |  0-2 deg | 50-450 MHz  | v486 | - |
V6 2020_2020s |  0-60 deg |  0-2 deg | 50-450 MHz  | v486 | - |
V6 2021_2021s |  0-60 deg |  0-2 deg | 50-450 MHz  | v487 | - |

Remarks:
- Extended025-Moderate-TMVA-BDT and Extended050-Moderate-TMVA-BDT for zenith range 0-50 deg only (2012-2019)

### V6 Winter (reduced HV)

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2012_2013b | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 | 
V6 2013_2014a | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2013_2014b | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2014_2015 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2015_2016 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2016_2017 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2017_2018 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2018_2019 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485 |
V6 2019_2019s |  0-55 deg |  0.5 deg | 150-900 MHz  | v486 | - |
V6 2019_2020w |  0-55 deg |  0.5 deg | 150-900 MHz  | v486 | - |
V6 2020_2020s |  0-55 deg |  0.5 deg | 150-900 MHz  | v486 | - |
V6 2020_2021w |  0-55 deg |  0.5 deg | 150-900 MHz  | v486 | - |
V6 2021_2021s |  0-55 deg |  0.5 deg | 150-900 MHz  | v487 | - |
V6 2021_2022w |  0-55 deg |  0.5 deg | 150-900 MHz  | v487 | - |

## Lookup tables

Why are lookup table files so big?

A lookup is a 2D-Histogram (TH2F\*), with the dimensions log10(size), distance to telescope, and variable of interest (width, length, energy).
To cover the full parameter space of observations, there lookup tables included for:

NSB=11 x Ze(9) x Woff(9) x Az(4) x Tel(4) x Var(3) x Hist(2) = 85,000 histograms

Woff = distance to comera center, Var = (width, length, energy), Hist = number of histogram required (2)

# Technical

For version changes, the following files need to be changed:
- [README.md](README.md)
- [get_irfs_from_ucla.sh](get_irfs_from_ucla.sh) 
- [put_irfs_to_ucla.sh](put_irfs_to_ucla.sh)

For related/identical IRFs between different Eventdisplay version, use the script `relate_versions.sh` (Note: extremely finetuned)

## Uploading IRFs

1. Pack IRFs into several tar packages
```
./pack_irfs_pack_ucla.sh
```
2. Inspect tar packages in directory `tar_packages` and move them to the directory `archive`
3. Upload files to UCLA
```
./put_irfs_to_ucla.sh
```
4. Test some uploads with downloading script (modify, to not download again everything):
```
get_irfs_from_ucla.sh
```

Note that for DESY users, the tar packages are not downloaded but copied from their archive location.
