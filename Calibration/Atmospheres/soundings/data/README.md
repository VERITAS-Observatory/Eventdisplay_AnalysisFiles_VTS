#  sounding (balloon) data from UWYO for VERITAS

Downloaded for Tucson:

USM00072274  32.2278 -110.9558  751.4 AZ TUCSON

Downloading script:

$EVNDISPSYS/scripts/VTS/UTILITY.downloadSoundingDatafromUWYO.sh

## data preparation

Prepare a list of file:

```console
ls -1 sound*.dat > file_list.dat
```

Convert to root file:

```console
.L $EVNDISPSYS/lib/libVAnasum.so
VAtmosphereSoundings a;
a.readSoundingsFromTextFile("file_list.dat");
a.writeRootFile("sounding.root");
```
