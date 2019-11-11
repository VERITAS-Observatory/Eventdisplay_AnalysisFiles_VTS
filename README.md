# Eventdisplay Analysis Files - version v480

Configuration and runparameter files for Eventdisplay

Required for the analysis of VERITAS data. Analysis requires additional IRF files (lookup tables, radial acceptances, etc) - these are available through the UCLA archive.

Further information on this release: https://veritas.sao.arizona.edu/wiki/index.php/Eventdisplay_v480

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

Frogs
- Frogs parameter files (experimental)

