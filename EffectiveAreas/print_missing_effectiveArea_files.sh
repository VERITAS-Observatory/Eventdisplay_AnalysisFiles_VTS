#!/bin/bash
# print missing effective area files
#

CLISTNV=$(cat ../GammaHadronCutFiles/IRF_GAMMAHADRONCUTS.dat)
VERSION=$(cat ../IRFVERSION)

ME="AP"

for A in ATM61 ATM62
do
   if [[ ${A} == "ATM61" ]]; then
      EPOCHS=$(cat ../IRF_EPOCHS_WINTER.dat)
   else
      EPOCHS=$(cat ../IRF_EPOCHS_SUMMER.dat)
   fi
   for E in V4 V5 ${EPOCHS[@]}
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
      for T in T1234 T123 T124 T134 T234
      do
         for C in ${CLISTNV}
         do
             if [[ $E == "V4" ]] || [[ $E == "V5" ]]; then
                if [[ ${C} == *"Extend"* ]] || [[ ${C} == *"Super"* ]]; then
                    continue
                fi
              fi
             EFF="effArea-${VERSION}-auxv01-${SIMTYPE}-Cut-${C}-GEO-${E}-${ATM}-${T}.root"
             if [[ ! -e ${EFF} ]]; then
                 echo "MISSING $EFF"
             fi
         done
      done
   done
done
