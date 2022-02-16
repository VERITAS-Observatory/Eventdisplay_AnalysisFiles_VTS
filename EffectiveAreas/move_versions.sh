# renanme files for a new version

OLDV="v486"
NEWV="v487"

filelist=$(find . -name "*${OLDV}*.root")
for F in ${filelist}
do 
   fname=$(basename $F)
   nfil=${fname/$OLDV/$NEWV}
   if [[ ! -e ${nfil} ]]; then
      mv -v ${fname} ${nfil}
   fi
done
