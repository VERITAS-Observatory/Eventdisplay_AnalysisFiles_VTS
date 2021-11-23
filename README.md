# Eventdisplay Analysis Files - version v485 (latest: auxv02)

**in development - v485-auxv02-dev1**

Configuration and runparameter files for Eventdisplay

Required for the analysis of VERITAS data. 

Analysis requires additional IRF files (lookup tables, radial acceptances, etc). These are available through the UCLA archive.
To download and unpack the IRFs from the UCLA archive, run in the Eventdisplay_AnalysisFiles directory:

```
./get_irfs_from_ucla.sh
```

Further information on this relase: https://veritas.sao.arizona.edu/wiki/index.php/Eventdisplay_v485

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

# v485 History

**Version** | **Eventdisplay version** | **Changes** |
:---:|:---:|:---:
v485-auxv01 | Eventdisplay version v485a,b | IRFs for V6 period for all off-axis angles and with improved MC statistics |
v485-auxv02 | Eventdisplay version v485c | IRFs for V4 including plate scale correction; IRFs for V6 with extended zenith angle range; IRFs for V6 with new throughput correction epochs |

# IRF Description

## v485-auxv02

V4 Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V4 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485b (plate scale corrections) | - DONE |
V4 Summer | 0-65 deg | 0-2 deg | 75-750 MHz | v485b (plate scale corrections) | - DONE |


V5 Epoch | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V5 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485 | identical with v485-auxv01 DONE |
V5 Winter | 0-65 deg | 0-2 deg | 75-750 MHz | v485 | identical with v485-auxv01 DONE |


V6 Winter Epoch (nominal HV) | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |

V6 Summer Epoch (nominal HV) | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2012_2013b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE | 
V6 2013_2014a | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2013_2014b | 0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2014_2015 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2015_2016 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2016_2017 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2017_2018 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2018_2019 |  0-60 deg |  0-2 deg | 50-450 MHz  | v485 | identical with v485-auxv01 DONE |

V6 Winter Epoch (red HV) | Zenith Range | Wobble Offset | NSB Range |  Eventdisplay version (production) | Comment |
:---:|:---:|:---:|:---:|:---:|:---:
V6 2012_2013a | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2012_2013b | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE | 
V6 2013_2014a | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2013_2014b | 0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2014_2015 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2015_2016 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2016_2017 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2017_2018 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |
V6 2018_2019 |  0-55 deg |  0.5 deg | 150-900 MHz  | v485 | identical with v485-auxv01 DONE |

# Technical

For version changes, the following files need to be changed:
- [README.md](README.md)
- [get_irfs_from_ucla.sh](get_irfs_from_ucla.sh) 
- [put_irfs_to_ucla.sh](put_irfs_to_ucla.sh)
