# print missing effective area files
# (V6 only)
#

EPOCHS=( V4 V5 V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2019s V6_2019_2020w V6_2020_2020s V6_2020_2021w )
set -- EPOCHS
CLISTNV="NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Soft-TMVA-BDT NTel3-PointSource-Hard-TMVA-BDT NTel2-PointSource-Hard-TMVA-BDT NTel2-Extended050-Moderate-TMVA-BDT NTel2-Extended025-Moderate-TMVA-BDT"
VERSION=$(cat ../IRFVERSION)


ME="GEO"
VE="effArea-v483-auxv01-CARE_June1702-Cut"

for A in ATM61 ATM62
do
   for E in ${EPOCHS[@]}
   do
      ATM=${A}
      SIMTYPE="CARE_June2020"
      if [[ $E == "V4" ]] || [[ $E == "V5" ]]; then
          SIMTYPE="GRISU"
          if [[ $ATM == "ATM61" ]]; then
             ATM="ATM21"
          else
             ATM="ATM22"
          fi
      fi
      if [[ ${E: -1} == "w" ]] && [[ ${A} == "ATM62" ]]; then
         continue
      elif [[ ${E: -1} == "s" ]] && [[ ${A} == "ATM61" ]]; then
         continue
      fi
      for T in T1234 T123 T124 T134 T234
      do
         for C in ${CLISTNV}
         do
             if [[ $E == "V4" ]] || [[ $E == "V5" ]]; then
                if [[ ${C} == *"Extend"* ]] || [[ ${C} == *"Super"* ]]; then
                    continue
                fi
              fi
             #EFF="effArea-v486-auxv01-CARE_June2020-Cut-NTel3-PointSource-Hard-TMVA-BDT-GEO-V6_2018_2019-ATM61-T234.root"
             EFF="effArea-${VERSION}-auxv01-${SIMTYPE}-Cut-${C}-GEO-${E}-${ATM}-${T}.root"
             if [[ ! -e ${EFF} ]]; then
                 echo "MISSING $EFF"
             fi
         done
      done
   done
done
     

