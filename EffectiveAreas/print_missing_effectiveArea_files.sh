# print missing effective area files
#

ME="GEO"
VE="effArea-v483-auxv01-CARE_June1702-Cut"

for A in ATM61 ATM62
do
   for E in V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 V6_2019_2020
   do
      for T in T1234 T123 T124 T134 T234
      do
         for C in NTel2-PointSource-Hard-TMVA-BDT NTel2-PointSource-Moderate NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Moderate-TMVA-Preselection NTel2-PointSource-Soft NTel2-PointSource-Soft-TMVA-BDT NTel2-PointSource-Soft-TMVA-Preselection NTel3-PointSource-Hard NTel3-PointSource-Hard-TMVA-BDT
         do
             EFF="${VE}-${C}-${ME}-${E}-${A}-${T}.root"
             if [[ ! -e ${EFF} ]]; then
                 echo "MISSING $EFF"
             fi
         done
      done
   done
done
     

