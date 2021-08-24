#  sounding (balloon) data from UWYO for VERITAS

Downloaded for Tucson:

USM00072274  32.2278 -110.9558  751.4 AZ TUCSON

Downloading script:

$EVNDISPSYS/scripts/VTS/UTILITY.downloadSoundingDatafromUWYO.sh

## data preparation

Prepare a list of file:
```
ls -1 sound*.dat > filelist.dat
```

Convert to root file:

```
.L /Users/maierg/Experiments/EVNDISP/EVNDISP-500/Eventdisplay/lib/libVAnaSum.so
VAtmosphereSoundings a;
a.readSoundingsFromTextFile("filelist.dat");
a.writeRootFile("sounding.root");
```
