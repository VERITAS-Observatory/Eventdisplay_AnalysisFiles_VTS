# copy IRFs from equivalent productions 
# (for efficiency reasons)
#
# **extremely fine tuned**

# list of epochs used in v485
EPOCHSV485=(V6_2012_2013a V6_2012_2013b V6_2013_2014a V6_2013_2014b V6_2014_2015 V6_2015_2016 V6_2016_2017 V6_2017_2018 V6_2018_2019 )
set -- EPOCHSV485
EPOCHSATM61=( V6_2019_2020w V6_2020_2021w )
set -- EPOCHSATM61
EPOCHSATM62=( V6_2019_2019s V6_2020_2020s )
set -- EPOCHSATM62

PDIR=$(pwd)

copy_files()
{
   filelist=$(find ../${1}/${2}/ -name "*${3}*.root")
   for F in ${filelist}
   do 
       fname=$(basename $F)
       nfil=${fname/$4/$5}
       if [[ ! -e $2/${nfil} ]]; then
          cp -v ${F} $2/${nfil}
       fi
   done
}

link_V4()
{
    echo "======================"
    echo "Copying V4 IRFs"
    for A in ATM21 ATM22
    do
       copy_files v485c Tables GRISU-V4-${A} v485 v486
       copy_files v485c RadialAcceptances "GRISU-*-V4" v485 v486
       copy_files v485c EffectiveAreas "GRISU-*-V4-${A}" v485 v486
    done
}

link_V5()
{
    echo "======================"
    echo "Copying V5 IRFs"
    for A in ATM21 ATM22
    do
       copy_files v485 Tables GRISU-V5-${A} v485 v486
       copy_files v485 RadialAcceptances "GRISU-*-V5" v485 v486
       copy_files v485 EffectiveAreas "GRISU-*-V4-${A}" v485 v486
    done
}

link_CARE_RedHV()
{
    echo "======================"
    echo "Linking V6_CARE_RedHV"
    echo "   (original v485 production until V6_2018_2019)" 
    for A in ATM61
    do
       for E in ${EPOCHSV485[@]}
       do
           copy_files v485 Tables "CARE_RedHV-${A}-${E}" v485 v486
           copy_files v485 EffectiveAreas "CARE_RedHV*${E}-${A}" v485 v486
       done
    done
}

link_CARE_June2020_ATM62()
{
    echo "======================"
    echo "Linking CARE_June2020_ATM62"
    echo "   (original v485 production until V6_2018_2019)" 
    for A in ATM62
    do
       for E in ${EPOCHSV485[@]}
       do
           copy_files v485c Tables "CARE_June2020-${A}-${E}" v485 v486
           copy_files v485c EffectiveAreas "CARE_June2020*${E}-${A}" v485 v486
           # Radial acceptances (independent of atmosphere)
           copy_files v485 RadialAcceptances CARE_June2020 v485 v486
       done
    done
}

link_V4

link_V5

link_CARE_RedHV

link_CARE_June2020_ATM62