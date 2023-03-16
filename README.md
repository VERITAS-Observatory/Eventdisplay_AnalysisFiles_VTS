# Eventdisplay Analysis Files - version v490

Configuration and run parameter files for Eventdisplay.

Required for the analysis of VERITAS data. 

Analysis requires additional IRF files (lookup tables, radial acceptances, etc) which are too big for this repository. These files are available through the UCLA archive.
To download and unpack the IRFs from the UCLA archive, run in the Eventdisplay_AnalysisFiles directory:

```
./get_irfs_from_ucla.sh
```

Further information on this release: https://veritas.sao.arizona.edu/wiki/index.php/Eventdisplay_v490

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
- TMVA.BDT.runparameter (runparameters for TMVA training)

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

# IRF Description

## Eventdisplay version v490

Import Notes:
1. Analysis and file format change with v490. Do not use IRFs from older versions of Eventdisplay with v490.
2. IRFs should not be used for analysis of observations outside of the indicated parameter space. This is especially important for the elevation range of V6 IRFs: no reliable analysis results can be achieved below 30 deg elevation.
3. IRFs for reduced HV observations are available for wobble offsets 0.5 deg only.
4. Radial acceptances depend significantly on the field observered. No generic radial acceptace files are therefore provided as this point as part of the IRF packages.

Cuts and Epochs:
- effective areas for nominal high voltage conditions are available for the following cuts: [IRF_GAMMAHADRONCUTS.dat](IRF_GAMMAHADRONCUTS.dat)
- effective areas for reduced high voltage conditions are available for the following cuts: [IRF_GAMMAHADRONCUTS_RedHV.dat](IRF_GAMMAHADRONCUTS_RedHV.dat)
- [Summer](IRF_EPOCHS_SUMMER.dat) and [Winter](IRF_EPOCHS_WINTER.dat) epochs

### V4

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V4 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v490 | - |
V4 Summer | 0-65 deg | 0-2 deg | 75-750 MHz | v490 | - |

### V5

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V5 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v490 | - |
V5 Summer | 0-65 deg | 0-2 deg | 75-750 MHz | v490 | - |

### V6 Winter (nominal HV)

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2019_2019w |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2020_2021w |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2021_2022w |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |

### V6 Summer (nominal HV)

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | -  |
V6 2020_2020s |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 2021_2021s |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |
V6 V6_2022_2022s |  0-60 deg |  0-2 deg | 50-450 MHz  | v490 | - |

### V6 Winter (reduced HV)

Only Winter simulations are available for the reduced HV operation. 
Epochs for summer epochs include the corresponding throughput corrections applied on Winter simulations.

Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2012_2013b | 0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - | 
V6 2013_2014a | 0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2013_2014b | 0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2014_2015 |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2015_2016 |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2016_2017 |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2017_2018 |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2018_2019 |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2019_2020w |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2020_2020s |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2020_2021w |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2021_2021s |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |
V6 2021_2022w |  0-55 deg |  0.5 deg | 150-900 MHz  | v490 | - |

## Lookup tables

Why are lookup table files so big?

A lookup is a 2D-Histogram (TH2F\*), with the dimensions log10(size), distance to telescope, and variable of interest (width, length, energy).
To cover the full parameter space of observations, the lookup tables include:

NSB=11 x Ze(9) x Woff(9) x Az(4) x Tel(4) x Var(3) x Hist(2) = 85,000 histograms

Woff = distance to camera center, Var = (width, length, energy), Hist = number of histogram required (2)

# Technical

For version changes, the following files need to be changed:
- [README.md](README.md)
- [get_irfs_from_ucla.sh](get_irfs_from_ucla.sh) 
- [put_irfs_to_ucla.sh](put_irfs_to_ucla.sh)
- [pack_irfs_pack_ucla.sh](pack_irfs_pack_ucla.sh)


## Uploading IRFs

1. Pack IRFs into several tar packages
```
./pack_irfs_pack_ucla.sh
```
2. Inspect tar packages in the directory `tar_packages` and move them to the directory `archive`
3. Upload files to UCLA
```
./put_irfs_to_ucla.sh
```
4. Test some uploads with downloading script (modify, to not download again everything):
```
get_irfs_from_ucla.sh
```

Note that for DESY users, the tar packages are not downloaded but copied from their archive location.
