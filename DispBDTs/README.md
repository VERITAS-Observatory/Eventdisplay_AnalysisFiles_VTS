# Support files for dispBDT angular reconstruction

dispBDT files are provided in three different bins of zenith angle:
- small (SZE; <38 deg): use dispBDT files trained for 20 deg zenith angle
- medium (MZE; 38 deg < ze < 48 deg): use dispBDT files trained for 45 deg zenith angle
- large (LZE: 48 deg < ze < 58 deg): use dispBDT files trained for 55 deg zenith angle
- very large (XZE: >= 58 deg): use dispBDT files trained for 60 deg zenith angle

Note that this is encoded both in the script `copy_dispBDTs.sh` as in the
analysis steering scripts for MSCW.
