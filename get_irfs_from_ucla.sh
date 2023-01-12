#!/bin/bash
# download IRFs from UCLA
# - downloading in tar packages
# 

[[ "$1" ]] && IRFTYPE=$1 || IRFTYPE=""

# make sure that bbftp is installed
command -v bbftp >/dev/null 2>&1 || { echo >&2 "bbftp is not installed. Aborting."; exit 1; }

# Eventdisplay version
VERSION=$(cat IRFVERSION)
if [[ $IRFTYPE ]]; then
   VERSION=${VERSION}${IRFTYPE}
fi

echo "Downloading IRF packages for ${VERSION}/"

# Epochs
EPOCHS=$(cat IRF_EPOCHS_SUMMER.dat IRF_EPOCHS_WINTER.dat | sort -u)
# list of cuts
CLISTNV=$(cat IRF_GAMMAHADRONCUTS.dat)
CLISTRV=$(cat IRF_GAMMAHADRONCUTS_RV.dat)
CLISTUV=$(cat IRF_GAMMAHADRONCUTS_UV.dat)

## function to download and upack
download_and_unpack()
{
    D=${1}
    if [[ $HOSTNAME == *"desy"* ]]; then
       echo "DESY host detected"
       cp -v -i /lustre/fs23/group/veritas/Eventdisplay_AnalysisFiles/${VERSION}/archive/$D.tar .
    else
       echo "Downloading $D.tar from  /veritas/upload/EVNDISP/${VERSION}/${D}"
       if [[ -e ${D}.tar ]]
       then
           echo "   File ${D}.tar exists locally"
           echo "   move or remove before resume downloading"
           continue
       fi
       bbftp -u bbftp -V -S -m -p 12 -e "get /veritas/upload/EVNDISP/${VERSION}/${D}.tar ${D}.tar" gamma1.astro.ucla.edu
   fi
   tar --keep-newer-files -xvf ${D}.tar
   rm -v ${D}.tar
}

dowload_radialacceptances()
{
  download_and_unpack RadialAcceptances
}

dowload_lookuptables()
{
    for I in ${EPOCHS[@]} V4 V5
    do
      download_and_unpack Tables_${I}
    done
}

download_effectivareas_V4V5()
{
    for I in V4 V5
    do
        for A in ATM21 ATM22
        do
           for T in ${CLISTNV}
           do
               # no extended cuts for V4 and V5
               if [[ $T == *"Extended"* ]]; then
                   continue
               fi
               D="EffectiveAreas_${I}_${A}_${T}"
               download_and_unpack ${D}
           done
        done
    done
}

download_effectivareas_V6()
{
    # Effective areas for different epochs
    for A in ATM61 ATM62
    do
        for I in ${EPOCHS[@]}
        do
            # skip summer/winter epochs
            if [[ ${I: -1} == "w" ]] && [[ ${A} == "ATM62" ]]; then
               continue
            elif [[ ${I: -1} == "s" ]] && [[ ${A} == "ATM61" ]]; then
               continue
            fi
            for F in nominalHV RedHV UV
            do
               if [[ ${F} == "RedHV" ]] && [[ ${A} == "ATM62" ]]; then
                  continue
               fi
               if [[ ${F} == "UV" ]]; then
                   if [[ ${A} == "ATM62" ]]; then
                       continue
                   fi
                   A="ATM21"
               fi
               if [[ ${F} == "RedHV" ]]; then
                  CLIST=${CLISTRV}
               elif [[ ${F} == "UV" ]]; then
                   CLIST=${CLISTUV}
               else
                  CLIST=${CLISTNV}
               fi
               for T in $CLIST
               do
                  D="EffectiveAreas_${F}_${I}_${A}_${T}"
                  download_and_unpack ${D}
               done
          done
       done
    done
}

dowload_radialacceptances

dowload_lookuptables

download_effectivareas_V4V5

download_effectivareas_V6
