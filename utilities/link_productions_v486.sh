# script linking different productions
# and IRF subdirectory for most efficient
# IRF generation
#
# **extremely fine tuned**

# list of epochs used in v485
EPOCHSV485=(V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 )
set -- EPOCHSV485
EPOCHSATM61=( V6_2019_2020w V6_2020_2021w )
set -- EPOCHSATM61
EPOCHSATM62=( V6_2019_2019s V6_2020_2020s )
set -- EPOCHSATM62

# cuts
CUTS=( NTel3-PointSource-Hard-TMVA-BDT NTel2-PointSource-Hard-TMVA-BDT NTel2-PointSource-Moderate-TMVA-BDT NTel2-PointSource-Soft-TMVA-BDT NTel2-Extended025-Moderate-TMVA-BDT NTel2-Extended050-Moderate-TMVA-BDT )
set -- CUTS

PDIR=$(pwd)

link_V4()
{
    echo "======================"
    echo "Linking V4"
    echo "   (reproduced with v485b with plase-scale corrections included)"
    mkdir -p GRISU
    cd GRISU
    for A in ATM21 ATM22
    do
       if [[ ! -e V4_${A}_gamma ]]; then
          ln -s ../../v485b/GRISU/V4_${A}_gamma .
       else
          file  V4_${A}_gamma
       fi
    done
    cd ${PDIR}
}

link_V5()
{
    echo "======================"
    echo "Linking V5b"
    echo "   (original v485 production)" 
    mkdir -p GRISU
    cd GRISU
    for A in ATM21 ATM22
    do
       if [[ ! -e V5_${A}_gamma ]]; then
          ln -s ../../v485/GRISU/V5_${A}_gamma .
       else
          file  V5_${A}_gamma
       fi
    done
    cd ${PDIR}
}

link_CARE_RedHV()
{
    echo "======================"
    echo "Linking V5_CARE_RedHV"
    echo "   (original v485 production until V6_2018_2019)" 
    mkdir -p CARE_RedHV
    cd CARE_RedHV
    for A in ATM61
    do
       for E in ${EPOCHSV485[@]}
       do
           if [[ ! -e ${E}_${A}_gamma ]]; then
              ln -s ../../v485/CARE_RedHV/${E}_${A}_gamma .
           else
              file ${E}_${A}_gamma
           fi
       done
    done
    # new epoch starting 2019
    for E in ${EPOCHSATM61[@]}
    do
       echo "Missing CARE_RedHV $E"
    done
    for E in ${EPOCHSATM62[@]}
    do
       echo "Missing CARE_RedHV $E"
    done
    cd ${PDIR}
}

link_CARE_June2020_ATM62()
{
    echo "======================"
    echo "Linking CARE_June2020/ATM62"
    echo "   (original v485 production until V6_2018_2019)" 
    mkdir -p CARE_June2020
    cd CARE_June2020
    A="ATM62"
    for E in ${EPOCHSV485[@]}
    do
       ## evndisp
       P="../../v485/CARE_June2020/${E}_${A}_gamma"
       echo $P
       if [[ -e ${P} ]]; then
          DESTTDIR="./${E}_${A}_gamma"
          mkdir -p ${DESTTDIR}
          SDIR=$(ls -1 ${P} | grep ze | grep NSB)
          for S in ${SDIR}; do
              if [[ ! -e ${DESTTDIR}/${S} ]]; then
                 ln -s ../${P}/${S} ${DESTTDIR}/${S}
              fi
          done
       fi
       ## effective areas
       for C in ${CUTS[@]}
       do
          EFFDIR=EffectiveAreas_Cut-${C}
          P="../../v485/CARE_June2020/${E}_${A}_gamma/${EFFDIR}"
          mkdir -p ${DESTTDIR}/${EFFDIR}
          SNFIL=$(find ${P} -name "*.root" | wc -l)
          SFIL=$(find ${P} -name "*.root")
          echo "Linking (checking) $SNFIL files in ${P}"
          for S in ${SFIL}; do
             FN=$(basename $S)
             FS=$(readlink -f $S)
             echo ${DESTTDIR}/${EFFDIR}/${FN} 
             if [[ ! -e ${DESTTDIR}/${EFFDIR}/${FN} ]]; then
                ln -s ${FS} ${DESTTDIR}/${EFFDIR}/${FN}
             fi
          done
       done
    done
    ##########################
    # new epochs starting 2019
    # ./IRF.production.sh CARE_June2020 MAKETABLES "V6_2019_2019s V6_2020_2020s" 62 0
    for E in ${EPOCHSATM62[@]}
    do
       if [[ ! -e ${E}_${A}_gamma ]]; then
           echo "Missing CARE_June2020 $E"
       else
          file ${E}_${A}_gamma
       fi
    done
    cd ${PDIR}
}

link_CARE_June2020_ATM61()
{
    echo "======================"
    echo "Linking CARE_June2020/ATM61"
    echo "   (original v485 production until V6_2018_2019; ex 55-60 deg)" 
    mkdir -p CARE_June2020
    cd CARE_June2020
    A="ATM61"
    ##########################
    # link evndisp directories 
    # (0 - 50 deg)
    for E in ${EPOCHSV485[@]}
    do
       ## evndisp
       P="../../v485/CARE_June2020/${E}_${A}_gamma"
       echo $P
       if [[ -e ${P} ]]; then
          DESTTDIR="./${E}_${A}_gamma"
          mkdir -p ${DESTTDIR}
          SDIR=$(ls -1 ${P} | grep ze | grep NSB)
          for S in ${SDIR}; do
              if [[ ! -e ${DESTTDIR}/${S} ]]; then
                 ln -s ../${P}/${S} ${DESTTDIR}/${S}
              fi
          done
       fi
       ## effective areas
       for C in ${CUTS[@]}
       do
          EFFDIR=EffectiveAreas_Cut-${C}
          P="../../v485/CARE_June2020/${E}_${A}_gamma/${EFFDIR}"
          mkdir -p ${DESTTDIR}/${EFFDIR}
          SDIR=$(ls -1 ${P} | grep root | wc -l)
       done
    done
    ##########################
    # new epochs starting 2019
    # ./IRF.production.sh CARE_June2020 MAKETABLES "V6_2019_2020w V6_2020_2021w" 61 0
    # ./IRF.production.sh CARE_June2020 MAKETABLES "V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019" 61 0
    for E in ${EPOCHSATM61[@]}
    do
       if [[ ! -e ${E}_${A}_gamma ]]; then
           echo "Missing CARE_June2020 $E"
       else
          file ${E}_${A}_gamma
       fi
    done
    cd ${PDIR}
}

#link_V4

#link_V5

#link_CARE_RedHV

link_CARE_June2020_ATM62

#link_CARE_June2020_ATM61

