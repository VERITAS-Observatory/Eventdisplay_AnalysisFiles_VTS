# Atmospheric sounding data

Calculate monthly average density profiles for sounding data

for further background, see VERITAS wiki: 
https://veritas.sao.arizona.edu/wiki/index.php/Eventdisplay_Manual:_Radiosonde_data

## Data

Data is downloaded from UWYO using the script 
```
$EVNDISPSYS/script/VTS/UTILITY.downloadSoundingDatafromUWYO.sh
```
see http://weather.uwyo.edu/upperair/sounding.html for all details

Data should be prepared as discussed in the data directory

## Analysis

Run this macro to run the monthly average and plot average profiles:

```
.L $EVNDISPSYS/lib/libVAnaSum.so
.L soundings.C
soundings();
```
Important: even though this is v483, use at least v500 shared library for the plotting

Figures are written into the figure directory.
