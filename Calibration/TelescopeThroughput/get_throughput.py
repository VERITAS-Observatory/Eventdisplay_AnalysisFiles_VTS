#!/usr/bin/env python
# coding: utf-8

#####################################
##      PACKAGES that we need      ##
#####################################

import os,sys
import numpy as np

import matplotlib as mpl
import matplotlib.pyplot as plt
import datetime
import time
import math
import glob
import tabulate

import astropy
import astropy.units as u
import astropy.time as atime
import scipy.interpolate as sinterp
import scipy.signal as ssignal

time.sleep(1)
mpl.rc('font',**{'family':'serif','serif':['Palatino']})
mpl.rc('axes',facecolor = (1,1,1,1))
mpl.rc('figure',facecolor = (1,1,1,1))
mpl.rc('text', usetex=True)
mpl.rc('figure',figsize=(4.2,2.4))
mpl.rc('figure',dpi=100)
mpl.rc('savefig',dpi=100)

### Supress RuntimeWarnings (zero-divisions and such) in a very dirty way
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning) 

######################################
##       AUXILIARY FUNCTIONS        ##
######################################

def datestr2num(string):
    if type(string)==bytes:
        string = string.decode('utf-8')
    try:
        dt = datetime.datetime.strptime(str(string),"%Y-%m-%d %H:%M:%S")
    except:
        dt = datetime.datetime.strptime(str(string)+" 00:00:00","%Y-%m-%d %H:%M:%S")
    at = atime.Time(dt)
    return(at.mjd)

def find_nearest(array,value):
    idx = np.searchsorted(array, value, side="left")
    if idx > 0 and (idx == len(array) or math.fabs(value - array[idx-1]) < math.fabs(value - array[idx])):
        return idx-1,array[idx-1]
    else:
        return idx,array[idx]

def middle(array):
    return (np.min(array)+np.max(array))/2.


#########################################
## Definition of seasons             ####
#########################################

year_begin_mjd = atime.Time(np.asarray(\
    [datetime.datetime(2010,9,1,0,0),
     datetime.datetime(2011,9,1,0,0),
     datetime.datetime(2012,7,1,0,0),
     datetime.datetime(2013,3,1,0,0),
     datetime.datetime(2013,11,1,0,0),
     datetime.datetime(2014,4,1,0,0),
     datetime.datetime(2014,10,1,0,0),
     datetime.datetime(2015,9,1,0,0),
     datetime.datetime(2016,9,1,0,0),
     datetime.datetime(2017,9,1,0,0),
     datetime.datetime(2018,9,1,0,0),
     datetime.datetime(2019,9,1,0,0),
     datetime.datetime(2020,9,1,0,0),
     datetime.datetime(2021,9,1,0,0),
     datetime.datetime(2022,9,1,0,0),
     ])).mjd

year_end_mjd = atime.Time(np.asarray(\
    [datetime.datetime(2011,7,1,0,0),
     datetime.datetime(2012,7,1,0,0),
     datetime.datetime(2013,4,1,0,0),
     datetime.datetime(2013,12,1,0,0),
     datetime.datetime(2014,5,1,0,0),
     datetime.datetime(2014,12,1,0,0),
     datetime.datetime(2015,7,1,0,0),
     datetime.datetime(2016,7,1,0,0),
     datetime.datetime(2017,7,1,0,0),
     datetime.datetime(2018,7,1,0,0),
     datetime.datetime(2019,7,1,0,0),
     datetime.datetime(2020,7,1,0,0),
     datetime.datetime(2021,7,1,0,0),
     datetime.datetime(2022,7,1,0,0),
     datetime.datetime(2023,7,1,0,0),
     ])).mjd


##########################################################
# Reference reflectivities from Oct 17 2011 (Jeff Grube) #
##########################################################

RFCRV = {}

RFCRV[1] = np.asarray([\
    [260, 0.687594],
    [280, 0.712322],
    [300, 0.74184],
    [320, 0.771999],
    [340, 0.795119],
    [360, 0.811227],
    [380, 0.824711],
    [400, 0.830071],
    [450, 0.832925],
    [500, 0.813976],
    [550, 0.787787],
    [600, 0.755667],
    [650, 0.731054],
    [700, 0.70074]
])

RFCRV[2] = np.asarray([\
    [260, 0.721465],
    [280, 0.746258],
    [300, 0.773332],
    [320, 0.799048],
    [340, 0.818604],
    [360, 0.832089],
    [380, 0.842458],
    [400, 0.845727],
    [450, 0.844612],
    [500, 0.82504],
    [550, 0.798872],
    [600, 0.765328],
    [650, 0.738328],
    [700, 0.709881]
])

RFCRV[3] = np.asarray([\
    [260, 0.737282],
    [280, 0.77011],
    [300, 0.799097],
    [320, 0.824643],
    [340, 0.841625],
    [360, 0.85164],
    [380, 0.859993],
    [400, 0.860297],
    [450, 0.854456],
    [500, 0.830546],
    [550, 0.801317],
    [600, 0.76702],
    [650, 0.744134],
    [700, 0.716556],
])
 
RFCRV[4] = np.asarray([\
    [260, 0.739627],
    [280, 0.758912],
    [300, 0.782842],
    [320, 0.805983],
    [340, 0.82261],
    [360, 0.835201],
    [380, 0.8471],
    [400, 0.850328],
    [450, 0.850454],
    [500, 0.829861],
    [550, 0.806081],
    [600, 0.773829],
    [650, 0.755231],
    [700, 0.720607],
])

###########################################################################
##  Winston cone efficiency from CARE_VERITAS_AfterPMTUpgrade_V6_140916  ##
###########################################################################
WCEFF = {1: 1.0, 2: 1.0, 3: 1.0, 4: 1.0}

######################################################
## Some reference spectra (NSB,                     ##
## Cherenkov radiation, old PMT response, B filters ##
######################################################
NSB = np.loadtxt("NSB.csv",delimiter=',')
Cherenkov = np.loadtxt("CherenkovSpec.csv",delimiter=',')
PMTs = np.loadtxt("PMTs.csv",delimiter=',')
Bfilter = np.loadtxt("Bessel_B-1.txt")

# Create the figure
fig   = plt.figure(figsize=(6,3.4),dpi=150)
plot  = fig.add_subplot(111)

for T in range(4):
    plot.errorbar(
        x=RFCRV[T+1][:,0],
        y=RFCRV[T+1][:,1],
        marker='o',
        ms=2,
        ls='dotted',
        label='T{0}'.format(T+1)
    )
    
plot.plot(NSB[:,0],NSB[:,1],alpha=0.35,label='NSB',color='brown')
plot.plot(Cherenkov[:,0],Cherenkov[:,1],alpha=0.35,label='Cherenkov spec',color='indigo')
plot.plot(PMTs[:,0],PMTs[:,1],alpha=0.35,label='PMT QE',color='olive')
plot.plot(Bfilter[:,0],Bfilter[:,1]*0.01,alpha=0.35,color='blue',label='B-filter')

plot.set_ylabel('Reflectivity in MC')
plot.set_xlabel('Wavength (nm)')
plot.set_xlim(200,700)

plot.legend(fontsize='x-small',loc=4)

plt.grid(lw=1,alpha=0.5,ls='dotted')


plot.set_ylim(0.5,1)


fig.savefig("Reference_PMT_Cherenkov_Bfilters.pdf",bbox_inches='tight')
fig.savefig("Reference_PMT_Cherenkov_Bfilters.png",bbox_inches='tight',dpi=120)


#######################################################
## Mean reflectivity from Emmet's measurements       ##
## spoiler: does not match the observed reflectivity ##
#######################################################
def mean_reflectivity(reflectivity_curve,lmin=250,lmax=700,weights=None):
    # first interpolate to normalize all the arrays
    xi = np.linspace(lmin,lmax,100)
    
    # reflectivity 
    xref = reflectivity_curve[:,0]
    yref = reflectivity_curve[:,1]
    
    # interpolated reflectivity
    yref_i = sinterp.interp1d(xref,yref,fill_value="extrapolate")(xi)
    
    # interpolated_weights
    weights_y = np.ones(len(xi))
    
    try:
        for weight in weights:
            xweight = weight[:,0]
            yweight = weight[:,1]
            weights_y *= sinterp.interp1d(xweight,yweight,fill_value="extrapolate")(xi)
    except:
        try:
            weight  = weights
            xweight = weight[:,0]
            yweight = weight[:,1]
            weights_y *= sinterp.interp1d(xweight,yweight,fill_value="extrapolate")(xi)
        except:
            pass #print('No weights used')
        else:
            pass #print('Only one weight provided')
    else:
        pass #print('coadding weights')
    
    return(np.average(yref_i,weights=weights_y))


##########################################################################
## Mean reflectivity value from reflectivity curves simulated in the MC ##
##########################################################################

print('Mean reflectivities from the MC / Reference')
for T in range(1,4+1):
    print(mean_reflectivity(RFCRV[T],weights=[Cherenkov]))

fig   = plt.figure(figsize=(6,6),dpi=150)
for T in range(1,4+1):
    plot  = fig.add_subplot(2,2,T)
    for k,d in enumerate(sorted(glob.glob("20*"))):
        if k%2 == 0: continue
        thisrefl = np.loadtxt("{0}/T{1}.csv".format(d,T),delimiter=',')
        plt.plot(thisrefl[:,0],thisrefl[:,1],
                 lw=0.8,label=d)
        
    plot.errorbar(
        x=RFCRV[T][:,0],
        y=RFCRV[T][:,1]*100,
        marker='o',
        ms=1.5,
        lw=0.9,
        ls='dashdot',
        color='black',
        label='Sim V6'
    )
        
    plot.legend(fontsize='xx-small',ncol=2)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    
    
fig.text(0.5, 0.05, 'Wavelength (nm)', ha='center',fontsize='large')
fig.text(0.05, 0.5, 'Mean reflectivity', 
         va='center', rotation='vertical',fontsize='large')


fig.savefig("DiffuseReflectivity_from_Emmet.pdf",bbox_inches='tight')
fig.savefig("DiffuseReflectivity_from_Emmet.png",bbox_inches='tight',dpi=120)

### Same as before, but convolved with Cherenkov spectrum

print("")
print("#Convolved with Cherenkov spectrum")
print("#Date, T1, T2, T3, T4")

reflectivityaveragetable = []

for d in sorted(glob.glob("20*")):
    
    CurrR_C = {}
    CurrR_B = {}
    SimuR_C = {}
    SimuR_B = {}
    Estimated_Ref = {}
    
    for T in range(1,4+1):
        thisrefl = np.loadtxt("{0}/T{1}.csv".format(d,T),delimiter=',')
        CurrR_C = mean_reflectivity(thisrefl,weights=[Cherenkov])/100
        CurrR_B = mean_reflectivity(thisrefl,weights=[Bfilter])/100
        SimuR_C = mean_reflectivity(RFCRV[T],weights=[Cherenkov])
        SimuR_B = mean_reflectivity(RFCRV[T],weights=[Bfilter])
        
        Estimated_Ref[T] = CurrR_B/SimuR_B * (CurrR_C/SimuR_C)**2
        
    
    print("{0}, {1:.2f}, {2:.2f}, {3:.2f}, {4:.2f},".format(d,
          Estimated_Ref[1],Estimated_Ref[2],Estimated_Ref[3],Estimated_Ref[4])
         )
    
    reflectivityaveragetable.append(
        [datetime.datetime.strptime(d+"000000","%Y%m%d%H%M%S"),
         Estimated_Ref[1],Estimated_Ref[2],Estimated_Ref[3],Estimated_Ref[4]
        ]
    )
    
reflectivityaveragetable = np.asarray(reflectivityaveragetable)

## Same as before, but convolved with a Blue filter

print("")
print("#Convolved with Blue filter")
print("#Date, T1, T2, T3, T4")
for d in sorted(glob.glob("20*")):
    
    thisrefl1 = np.loadtxt("{0}/T1.csv".format(d,T),delimiter=',')
    thisrefl2 = np.loadtxt("{0}/T2.csv".format(d,T),delimiter=',')
    thisrefl3 = np.loadtxt("{0}/T3.csv".format(d,T),delimiter=',')
    thisrefl4 = np.loadtxt("{0}/T4.csv".format(d,T),delimiter=',')
    
    MRef = []
    for T in range(1,4+1):
        TR = np.loadtxt("{0}/T{1}.csv".format(d,T),delimiter=',')
        MRef.append(mean_reflectivity(TR,weights=[Cherenkov])*\
                    mean_reflectivity(TR,weights=[Bfilter])*\
                    0.01/mean_reflectivity(RFCRV[T],weights=[Cherenkov]))
    
    
    print("{0}, {1:.2f}, {2:.2f}, {3:.2f}, {4:.2f}".format(d,MRef[0],MRef[1],MRef[2],MRef[3]))

######################################################
## Reflectivity measurement series from David Hanna ##
######################################################

def fill_empty(f):
    try:
        float(f)
    except:
        f=0
    return(f)

def filter_to_number(f):
    try:
        f = f.decode("utf-8")
    except:
        pass
    d = {'B':1, 'G':2, 'R':3, 'C':0}
    return d[f]

t_factors_raw = np.loadtxt("Parsed_reflectivity_DH.csv.txt",
                           skiprows=1,
                           converters={0: datestr2num, 3:fill_empty, 4:fill_empty, 5: filter_to_number}, 
                           delimiter=',')

#########################################
## Calculation of T, g and S factors ####
#########################################

print("###########################################")
print(" Calculation of T- g- and S- factors below ")
print(" ----------------------------------------- ")


##### T-factors

# Old T-factors derived from Tony's work.
v483_refs = np.asarray([  [56322.5, 151.5, 1.00, 1.00, 1.00, 1.00],
  [56687.5, 151.5, 0.90, 0.98, 0.82, 0.85],
  [57052.5, 151.5, 0.77, 0.86, 0.77, 0.78],
  [57418.0, 152.0, 0.78, 0.83, 0.73, 0.81],
  [57783.5, 151.5, 0.72, 0.82, 0.68, 0.74],
  [58148.5, 151.5, 0.71, 0.78, 0.72, 0.73],
  [58513.5, 151.5, 0.68, 0.72, 0.65, 0.68],
])

# Very early (and wrong, do not use) measurements using the prototype WDR.
# https://veritas.sao.arizona.edu/wiki/images/1/14/Reflectivity_tucson.pdf
# https://veritas.sao.arizona.edu/wiki/images/5/53/Reflectivity_zeuthen_13.pdf
MeanRefF4 = {T: mean_reflectivity(RFCRV[T],435,445) for T in range(1,4+1)}
T1_2010 = np.asarray([0.73,0.75,0.82,0.85,0.79,0.81,0.79,0.77,0.65,0.65,0.75,0.77,0.72,0.73])
T2_2010 = np.asarray([0.84,0.89,0.89,0.89,0.72,0.80,0.87])
T3_2010 = np.asarray([0.72,0.64,0.79,0.74,0.72])
T4_2010 = np.asarray([0.75,0.73,0.73,0.75,0.83,0.82])
    
old_results_ref_hanna = np.asarray([
    [atime.Time("2012-10-20 12:00:00").mjd, # aprox
     np.mean(T1_2010)/MeanRefF4[1],np.std(T1_2010)/MeanRefF4[1],
     np.mean(T2_2010)/MeanRefF4[2],np.std(T2_2010)/MeanRefF4[2],
     np.mean(T3_2010)/MeanRefF4[3],np.std(T3_2010)/MeanRefF4[3],
     np.mean(T4_2010)/MeanRefF4[4],np.std(T4_2010)/MeanRefF4[4],
    ],
    [atime.Time("2012-02-15 12:00:00").mjd,
     None, None,
     0.01*75.01/MeanRefF4[2],0.01*0.22/MeanRefF4[2],
     0.01*70.02/MeanRefF4[3],0.01*0.22/MeanRefF4[3],
     0.01*69.43/MeanRefF4[4],0.01*0.20/MeanRefF4[4],
    ],
    [atime.Time("2012-10-15 12:00:00").mjd,
     None, None,
     0.01*68.83/MeanRefF4[2],0.01*1.12/MeanRefF4[2],
     0.01*67.57/MeanRefF4[3],0.01*1.18/MeanRefF4[3],
     0.01*58.03/MeanRefF4[4],0.01*1.17/MeanRefF4[4],
    ],
    [atime.Time("2012-11-15 12:00:00").mjd,
     0.01*65.90/MeanRefF4[1],0.01*1.52/MeanRefF4[1],
     None, None,
     None, None,
     None, None],
    [atime.Time("2013-01-15 12:00:00").mjd,
     0.01*54.47/MeanRefF4[1],0.01*0.52/MeanRefF4[1],
     None, None,
     None, None,
     None, None],
])

# Reflectivity values in from David Hanna, measured using the WDR method.
# The name of the file contains the month starting from 2014 Jan.

# averages is the old format, tracknums is the new format as of Aug 11.
WDRformat="tracknums"
hanna_reflectdir = "ReflectivityFromDHanna/"
if WDRformat=="averages":
    hanna_files = [f.split("/")[-1] \
        for f in sorted(glob.glob(hanna_reflectdir+"/averages*"))]
    months_raw  = np.unique([int(f.split("_")[1]) for f in hanna_files])
    init_date = datetime.datetime(2014,1,1,0,0,0)

    table_reflectivities = []
    for month_tot in months_raw:
        years  = int(month_tot/12)
        months = int(month_tot%12)
        dt = atime.Time(datetime.datetime(\
            2014+years,
            1+months,
            15,
            0,0,0)).mjd
        
        reflect_date = [0 for k in range(9)]
        reflect_date[0] = dt
        
        b_filt = [0,0,0,0]
        b_err  = [0,0,0,0]
        for n in range(80):
            fname = "averages_{0}_{1}.dat".format(month_tot,n+1)
            if not fname in hanna_files:
                break
            
            nm  = int(n/4)+1
            tel = n%4 + 1
            cont=np.loadtxt(hanna_reflectdir+"/"+fname)
            reflect_date[tel*2-1] += cont[4]
            reflect_date[tel*2]   += cont[5]**2
        
        for tel in range(4):
            reflect_date[1+tel*2] = reflect_date[1+tel*2]/nm
            reflect_date[1+tel*2+1] = np.sqrt(reflect_date[1+tel*2+1])/nm
        
        table_reflectivities.append(reflect_date)

    table_reflectivities_array = np.asarray(table_reflectivities)
    table_reflectivities = dict()
    for tel in range(4):
        table_reflectivities[tel+1] = np.transpose([
            table_reflectivities[:,0],
            table_reflectivities[:,T*2+1],
            table_reflectivities[:,T*2+2]
        ])

    
    #print(table_reflectivities)

elif WDRformat=='tracknums':
    hanna_files = glob.glob(hanna_reflectdir+"/tracknums*.dat")
    init_date = atime.Time(datetime.datetime(2014,1,1,0,0,0)).mjd
    hanna_contents = [np.loadtxt(hf).reshape(3,-1) for hf in hanna_files]
     
    table_reflectivities = dict()
    for tel in range(4):
        hc = hanna_contents[tel]
        hc   = np.delete(hc, 0, axis=1)
        days = hc[0]
        vals = hc[1]
        errs = hc[2]
        mjds = days+init_date
        table_reflectivities[tel+1] = np.transpose([mjds,vals,errs])

refl_result = dict()

fig   = plt.figure(figsize=(5,5),dpi=150)
for T in range(1,4+1):
    plot  = fig.add_subplot(2,2,T)
    
    SimuR_B = mean_reflectivity(RFCRV[T],weights=[Bfilter])
    
    mjds = table_reflectivities[T][:,0]
    vals = table_reflectivities[T][:,1]/(SimuR_B)#*WCEFF[T])
    errs = table_reflectivities[T][:,2]/(SimuR_B)#*WCEFF[T])
    
    filt = ((errs/vals) < 0.5)* (vals<np.median(vals)+5*np.std(vals))* (vals>np.median(vals)-3*np.std(vals))
    
    smoo = ssignal.medfilt(vals[filt],3)
    #smoo = ssignal.savgol_filter(vals[filt],3,1)
    
    mjds = np.append([55851,55901,55951,55991],mjds)
    vals = np.append([1,1,1,1],vals)
    smoo = np.append([1,1,1,1],smoo)
    errs = np.append([0,0,0,0],errs)
    filt = np.asarray(np.append([1,1,1,1],filt),dtype='bool')
    
    plot.errorbar(
        x    = atime.Time(mjds,format='mjd').datetime,
        y    = vals,
        yerr = errs,
        marker='o',
        ms=2.,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='gray',
        label='raw',
        alpha=0.5,
        zorder=-10
    )
    
    tfilthannaold = old_results_ref_hanna[:,2*T-1]!=None
    plot.errorbar(
        x    = [atime.Time(_dt,format='mjd').datetime \
                for _dt in old_results_ref_hanna[tfilthannaold][:,0]],
        y    = old_results_ref_hanna[:,2*T-1][tfilthannaold],
        yerr = old_results_ref_hanna[:,2*T][tfilthannaold],
        marker='*',
        ms=4,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C6',
        label='test full-dish',
        alpha=0.5,
        zorder=-10
    )
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjds[filt],format='mjd').datetime,
        y    = smoo,
        yerr = errs[filt],
        marker='o',
        ms=1.4,
        mew=1,
        lw=0.8,
        ls='None'
        ,
        color='C{0}'.format(T-1),
        label='filtered'
    )
    
    xint = np.linspace(min(mjds),max(mjds),1000)
    spli = sinterp.splrep(mjds[filt],smoo,s=0.01)
    yint = sinterp.splev(xint,spli)
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        yint,
        lw=0.5,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
    for k in range(len(year_begin_mjd)):
        tfilt  = (mjds>=year_begin_mjd[k])*(mjds<=year_end_mjd[k])*filt
        tfilt2 = tfilt[filt]
        if np.sum(tfilt)==0: 
            tfiltspline = (xint>=year_begin_mjd[k])*(xint<=year_end_mjd[k])
            if np.sum(tfiltspline)==0: 
                continue
            else:
                mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
                mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
                val_season_val.append(middle(yint[tfiltspline]))
                val_season_err.append(0.05)#*np.std(yint[tfiltspline]))
        
        else:
            mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
            mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
            val_season_val.append(middle(smoo[tfilt2]))
            val_season_err.append(np.sqrt((np.std(smoo[tfilt2]))**2 + np.mean(errs[tfilt])**2))
    
    
    mjd_season_val = np.asarray(mjd_season_val)
    mjd_season_err = np.asarray(mjd_season_err)
    val_season_val = np.asarray(val_season_val)
    val_season_err = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.set_ylim(0.5,1.05)
    plot.set_yticks(np.arange(0.5,1.15,0.1))
    plot.legend(fontsize='xx-small',ncol=1)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
        
    refl_result[T] = dict()
    refl_result[T]['mjds']   = mjds
    refl_result[T]['vals']   = vals
    refl_result[T]['errs']   = errs
    refl_result[T]['smoo']   = smoo
    refl_result[T]['spline'] = spli
    refl_result[T]['mjds_average']   = mjd_season_val
    refl_result[T]['mjds_avererr']   = mjd_season_err
    refl_result[T]['vals_average']   = val_season_val
    refl_result[T]['errs_average']   = val_season_err
    
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'T-factors from WDR/D.Hanna', 
         va='center', rotation='vertical',fontsize='large')

plt.tight_layout()
    
fig.savefig("TFactors_WDR_Plus_splineInterp_FromDHanna.pdf",bbox_inches='tight')
fig.savefig("TFactors_WDR_Plus_splineInterp_FromDHanna.png",bbox_inches='tight',dpi=120)

## Create a table with the T-factors

table_summary = []

mjdsave = refl_result[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave): 
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    table_summary.append([season])

    table_summary[-1].append(mjd)
    table_summary[-1].append(refl_result[1]['mjds_avererr'][k])
    table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
    for T in range(1,4+1):
        table_summary[-1].append('{0:.3f}'.format(refl_result[T]['vals_average'][k]))
        table_summary[-1].append('{0:.3f}'.format(refl_result[T]['errs_average'][k]))

print('#### T factors')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'T[1]','err[1]','T[2]','err[2]',
                                               'T[3]','err[3]','T[4]','err[4]']))

table_summary_refl = list(table_summary)

##########################
#### Photostat GAINs
#
# Needs:
#   https://www.hep.physics.mcgill.ca/~veritas/photostat/
#   https://www.hep.physics.mcgill.ca/~veritas/photostat/processed_gain_all_runs_no_CFD.csv
#
##########################

v483_refs = np.asarray([  [56322.5, 151.5, 1.000, 1.000, 1.000, 1.000],
  [56687.5, 151.5, 0.976, 0.981, 0.984, 0.958],
  [57052.5, 151.5, 0.930, 0.958, 0.966, 0.929],
  [57418.0, 152.0, 0.937, 0.967, 0.970, 0.935],
  [57783.5, 151.5, 0.920, 0.938, 0.967, 0.945],
  [58148.5, 151.5, 0.964, 0.963, 0.974, 0.966],
  [58513.5, 151.5, 0.919, 0.946, 0.949, 0.955],
])


def obs_type_gains(t):
    if t.decode()=='STD':
        return(0)
    elif t.decode()=='RHV':
        return(1)
    elif t.decode()=='FILTER':
        return(2)
    else:
        return(3)
    
def get_zero(x):
    return(0)
    
def date_to_mjd_gains(t):
    _dt = datetime.datetime.strptime(t.decode(),"%Y-%m-%d %H:%M:%S")
    return atime.Time(_dt).mjd
    

pstat_gains1 = np.loadtxt("processed_gain_all_runs_no_CFD.csv", 
                      skiprows=1, delimiter=',',\
                      converters={4:date_to_mjd_gains,5:obs_type_gains})


pstat_gains2 = np.loadtxt("Gain_all_normal_runs_2012_to_2019_remove_duplicate.csv", 
                      skiprows=1, delimiter=',',usecols=(0,1,2,3,5,6),\
                      converters={5:date_to_mjd_gains,6:get_zero})

filt2g = pstat_gains2[:,0]<pstat_gains1[0][0]


pstat_gains = np.concatenate([pstat_gains2[filt2g],pstat_gains1])

gains_all = []

# Table / dict with the gains per epoch for all telescopes
# This is the same as the relative TLCFG of 0.939 0.924 0.924 1.00 the Elisa mentioned
# in the issue #49 (https://veritas.sao.arizona.edu/wiki/images/f/f3/CARE_V6_Std.txt)
gains_epoch_dict = dict(
    {
        4: { 1: 5.11, 2: 5.32, 3: 4.76, 4: 5.00 },
        5: { 1: 5.20, 2: 5.31, 3: 5.33, 4: 5.46 },
        6: { 1: 5.20, 2: 5.12, 3: 5.12, 4: 5.54 },
        6: { 1: 5.73*0.939, 2: 5.73*0.924, 3: 5.73*0.924, 4: 5.73*1.000 }
    }
)

def gainref_from_run(run):
    if run<=46641:   gain_ref_teldict = gains_epoch_dict[4]
    elif run<=63372: gain_ref_teldict = gains_epoch_dict[5]
    else:            gain_ref_teldict = gains_epoch_dict[6]
    return(gain_ref_teldict)

def gainref_from_mjd(mjd):
    if mjd<atime.Time(datetime.datetime(2009,9,14,3,0)).mjd:
        gain_ref_teldict = gains_epoch_dict[4]
    elif mjd<atime.Time(datetime.datetime(2012,8,22,3,0)).mjd:
        gain_ref_teldict = gains_epoch_dict[5]
    else:
        gain_ref_teldict = gains_epoch_dict[6]
    return(gain_ref_teldict)

### Collect the data and derive the photostat based g-factors

for run in np.unique(pstat_gains[:,0]):
    gain_ref_teldict = gainref_from_run(run)
   
    # filter to match the runs in the given interval 
    rfilt = pstat_gains[:,0]==run
    if pstat_gains[:,5][rfilt][0] != 0: continue
    gains_all.append([pstat_gains[:,4][rfilt][0]])
    for T in range(4):
	# filter to match the telescope
        tfilt = pstat_gains[:,1]==T
        if np.sum(tfilt*rfilt)==0: 
            gains_all[-1].append(0)
            gains_all[-1].append(1)
        elif pstat_gains[:,2][tfilt*rfilt][0]==np.nan:
            gains_all[-1].append(0)
            gains_all[-1].append(1)
        elif pstat_gains[:,3][tfilt*rfilt][0]==np.nan:
            gains_all[-1].append(0)
            gains_all[-1].append(1)
        else:
            gains_all[-1].append(pstat_gains[:,2][tfilt*rfilt][0]/gain_ref_teldict[T+1])
            gains_all[-1].append(pstat_gains[:,3][tfilt*rfilt][0]/gain_ref_teldict[T+1])

# convert to numpy array
gains_all = np.asarray(gains_all)
gains_qua = gains_all

#### Make the plot
gain_result = dict()
fig   = plt.figure(figsize=(5,5),dpi=150)
for T in range(1,4+1):
    plot  = fig.add_subplot(2,2,T)
    
    raw_mjds = gains_qua[:,0]
    raw_vals = gains_qua[:,2*T-1]
    raw_errs = gains_qua[:,2*T]
    
    mjds = []
    vals = []
    errs = []
    
    filt = ((raw_errs/raw_vals) < 0.2)*\
            (raw_vals > 0)*(raw_vals < 3)*\
            (raw_vals<np.median(raw_vals)+0.5*np.std(raw_vals))*\
            (raw_vals>np.median(raw_vals)-0.5*np.std(raw_vals))
    
    raw_mjds = raw_mjds[filt]
    raw_vals = raw_vals[filt]
    raw_errs = raw_errs[filt]
        
    for mjd in np.unique(sorted(raw_mjds)):
        vals.append(np.mean(raw_vals[raw_mjds==mjd]))
        errs.append(np.mean(raw_errs[raw_mjds==mjd]) +\
                    np.std(raw_vals[raw_mjds==mjd])/np.sum(raw_mjds==mjd))
        mjds.append(mjd)
    
    mjds = np.asarray(mjds)
    vals = np.asarray(vals)
    errs = np.asarray(errs)
   
    # smoothed values 
    smoo = np.array(vals)
    smoo = ssignal.savgol_filter(smoo,13,1)
    smoo = ssignal.medfilt(smoo,9)
    
    plot.errorbar(
        x    = atime.Time(mjds,format='mjd').datetime,
        y    = vals,
        yerr = errs,
        marker='o',
        ms=1.8,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='gray',
        label='raw',
        alpha=0.5,
        zorder=-10
    )
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjds[errs/smoo<0.1],format='mjd').datetime,
        y    = smoo[errs/smoo<0.1],
        yerr = errs[errs/smoo<0.1],
        marker='o',
        ms=0.8,
        mew=0.5,
        lw=0.5,
        ls='None',
        color='C{0}'.format(T-1),
        label='filtered'
    )
    
    xint = np.linspace(min(mjds),max(mjds),100)
    spli = sinterp.splrep(mjds,smoo,s=0.008)
    yint = sinterp.splev(xint,spli)
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        yint,
        lw=0.5,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
   
    # seasonal values 
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
    for k in range(len(year_begin_mjd)):
        tfilt = (mjds>=year_begin_mjd[k])*(mjds<=year_end_mjd[k])*(errs/smoo<0.1)
        if np.sum(tfilt)==0: 
            tfiltspline = (xint>=year_begin_mjd[k])*(xint<=year_end_mjd[k])
            if np.sum(tfiltspline)==0: 
                continue
            else:
                mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
                mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
                val_season_val.append(np.median(yint[tfiltspline]))
                val_season_err.append(0*np.std(yint[tfiltspline]))
        else:
            mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
            mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
            val_season_val.append(np.median(vals[tfilt]))
            val_season_err.append(np.sqrt((np.std(vals[tfilt]))**2 + np.mean(errs[tfilt])**2))
    
    mjd_season_val = np.asarray(mjd_season_val)
    mjd_season_err = np.asarray(mjd_season_err)
    val_season_val = np.asarray(val_season_val)
    val_season_err = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.set_ylim(0.7,1.12)
    plot.set_yticks(np.arange(0.5,1.15,0.1))
    plot.legend(fontsize='xx-small',ncol=3,loc=4)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
    gain_result[T] = dict()
    gain_result[T]['mjds']   = mjds
    gain_result[T]['vals']   = vals
    gain_result[T]['errs']   = errs
    gain_result[T]['smoo']   = smoo
    gain_result[T]['spline'] = spli
    gain_result[T]['mjds_average']   = mjd_season_val
    gain_result[T]['mjds_avererr']   = mjd_season_err
    gain_result[T]['vals_average']   = val_season_val
    gain_result[T]['errs_average']   = val_season_err
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'g-factors from photostat gains', 
         va='center', rotation='vertical',fontsize='large')

plt.tight_layout()

fig.savefig("GFactors_Photostat_CAdams.pdf",bbox_inches='tight')
fig.savefig("GFactors_Photostat_CAdams.png",bbox_inches='tight',dpi=120)

##############################
## Table with the g-factors ##
##############################

table_summary = []

mjdsave = gain_result[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave):
    # derive the season naming, e.g. 2014-2015 if the date is 2015 April 22. 
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    # if more than 1 bin in a season, then append a letter (e.g. 2012-2013b).
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    table_summary.append([season])

    table_summary[-1].append(mjd)
    table_summary[-1].append(gain_result[1]['mjds_avererr'][k])
    table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
    for T in range(1,4+1):
        table_summary[-1].append('{0:.3f}'.format(gain_result[T]['vals_average'][k]))
        table_summary[-1].append('{0:.3f}'.format(gain_result[T]['errs_average'][k]))

print('#### g factors (photostats)')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'g[1]','err[1]','g[2]','err[2]',
                                               'g[3]','err[3]','g[4]','err[4]']))

table_summary_gain = list(table_summary)

#####################################################
## S-factors = g-factors * T-factors               ##
## ----------------------------------------------- ##
## since we have several ways to compute them,     ##
## derive those factors from different approaches  ##
## to compare the results                          ##
#####################################################

v483_refs = np.asarray([  [56322.5, 151.5, 1.00, 1.00, 1.00, 1.00],
  [56687.5, 151.5, 0.91, 0.98, 0.83, 0.81],
  [57052.5, 151.5, 0.72, 0.82, 0.74, 0.72],
  [57418.0, 152.0, 0.73, 0.79, 0.71, 0.76],
  [57783.5, 151.5, 0.66, 0.76, 0.66, 0.70],
  [58148.5, 151.5, 0.68, 0.76, 0.67, 0.71],
  [58513.5, 151.5, 0.63, 0.69, 0.62, 0.66],
])

fig   = plt.figure(figsize=(5,5),dpi=150)

resulting_factors = dict()

xint = np.linspace(
    max([table_summary_gain[0][1]-table_summary_gain[0][2]/2.,table_summary_refl[0][1]-table_summary_refl[0][2]/2.]),
    min([table_summary_gain[-1][1]+table_summary_gain[0][2]/2.,table_summary_refl[-1][1]+table_summary_refl[-1][1]/2.]),
    1000
)

for T in range(1,4+1):
    
    plot  = fig.add_subplot(2,2,T)
    

    ### first way: make interpolations to obtain a regularly space fake dataset then multiply one-by-one.
    refl = sinterp.splev(xint,refl_result[T]['spline'])
    gain = sinterp.splev(xint,gain_result[T]['spline'])
    tota = refl*gain
    
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
   
    ### individual measurements: look for the closest pairs 
    s_factors_indiv = {'x': [], 'y': [], 'yerr': [], 'xerr': []}
    
    for i,gmjd in enumerate(gain_result[T]['mjds']):
        k,tmjd = find_nearest(refl_result[T]['mjds'],gmjd)
        s_factors_indiv['xerr'].append(np.abs(gmjd-tmjd))
        s_factors_indiv['x'].append(0.5*(gmjd+tmjd))
        s_factors_indiv['y'].append(gain_result[T]['vals'][i]*refl_result[T]['vals'][k])
        s_factors_indiv['yerr'].append(
            (gain_result[T]['vals'][i]*refl_result[T]['errs'][k])**2 +\
            (gain_result[T]['errs'][i]*refl_result[T]['vals'][k])**2
        )
    
    
    plot.errorbar(
        x    = atime.Time(s_factors_indiv['x'],format='mjd').datetime,
        y    = s_factors_indiv['y'],
        yerr = s_factors_indiv['yerr'],
        marker='o',
        ms=1.5,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='gray',
        label='raw',
        alpha=0.33,
        zorder=-20
    )
    
    ### third way: seasonal averages.
    for k,mjd in enumerate(refl_result[T]['mjds_average']):
        if mjd in gain_result[T]['mjds_average']:
            l = np.where(gain_result[T]['mjds_average']==mjd)
            mjd_season_val.append(mjd)
            mjd_season_err.append(refl_result[T]['mjds_avererr'][k])
            val_season_val.append((refl_result[T]['vals_average'][k]*\
                                   gain_result[T]['vals_average'][l])[0])
            val_season_err.append(np.sqrt(
                (refl_result[T]['vals_average'][k]*gain_result[T]['errs_average'][l])**2 +\
                (refl_result[T]['errs_average'][k]*gain_result[T]['vals_average'][l])**2
            )[0])
    
    resulting_factors[T] = dict()
    resulting_factors[T]['mjds_average'] = np.asarray(mjd_season_val)
    resulting_factors[T]['mjds_avererr'] = np.asarray(mjd_season_err)
    resulting_factors[T]['vals_average'] = np.asarray(val_season_val)
    resulting_factors[T]['errs_average'] = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        tota,
        lw=1,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
    plot.set_ylim(0.45,1.1)
    plot.set_yticks(np.arange(0.5,1.15,0.1))
    plot.legend(fontsize='x-small',ncol=1)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'S-factors from WDR/D.Hanna + photostat gains (C.Adams/T.Lin)', 
         va='center', rotation='vertical',fontsize='large')
plt.tight_layout()

fig.savefig("SFactors_Photostat_WDR.pdf",bbox_inches='tight')
fig.savefig("SFactors_Photostat_WDR.png",bbox_inches='tight',dpi=120)

### get the corresponding S-factor table

table_summary = []

mjdsave = resulting_factors[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave):
    
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    try:
        resulting_factors[1]['mjds_avererr'][k]
    except IndexError:
        pass
    else:
        table_summary.append([season])

        table_summary[-1].append(mjd)
        table_summary[-1].append(resulting_factors[1]['mjds_avererr'][k])
        table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
        for T in range(1,4+1):
            table_summary[-1].append('{0:.3f}'.format(resulting_factors[T]['vals_average'][k]))
            table_summary[-1].append('{0:.3f}'.format(resulting_factors[T]['errs_average'][k]))


print('#### S factors (photostat gains + WDR)')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'S[1]','err[1]','S[2]','err[2]',
                                               'S[3]','err[3]','S[4]','err[4]']))

table_summary_sfac = list(table_summary)

#### what needs to be written in the MSCW.sizescal.runparameter of ED

print("To write down in the MSCW.sizescal.runparameter")

for l in table_summary_refl:
    print("* T V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])

print("")
for l in table_summary_gain:
    print("* G V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])

print("")
for l in table_summary_sfac:
    print("* s V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])


# Do not continue running the single PE values (comment the next line to show it)
exit(0)








##########################
#### GAINs from single PE
#
# Needs 
#   1) wget -e robots=off --reject="index.html*" -nH -r --no-parent \
#      --cut-dirs=3 -l2  https://www.hep.physics.mcgill.ca/~veritas/gain/plots/
#   2) get the list of runs: ls -d [1-9]* | awk -F"_" '{print $1}' 
#   3) inject that list in log generator: https://veritasm.sao.arizona.edu/DQM/loggen.html 
#      to get a file with the dates for each run
#   4) create a csv/table with dates and runs: date_and_runs.txt
#      cat loggen.csv | grep -v ^$ | awk -F ", " '{print $1", "$2}' > date_and_runs.txt
#
##########################

v483_refs = np.asarray([\
  [56322.5, 151.5, 1.000, 1.000, 1.000, 1.000],
  [56687.5, 151.5, 0.976, 0.981, 0.984, 0.958],
  [57052.5, 151.5, 0.930, 0.958, 0.966, 0.929],
  [57418.0, 152.0, 0.937, 0.967, 0.970, 0.935],
  [57783.5, 151.5, 0.920, 0.938, 0.967, 0.945],
  [58148.5, 151.5, 0.964, 0.963, 0.974, 0.966],
  [58513.5, 151.5, 0.919, 0.946, 0.949, 0.955],
])


singlePE = np.loadtxt("singlePE/date_and_runs.txt", 
                      skiprows=1, delimiter=',',dtype='int')

gains_all = []
gains_qua = []

# Table / dict with the gains per epoch for all telescopes
# This is the same as the relative TLCFG of 0.939 0.924 0.924 1.00 the Elisa mentioned
# in the issue #49 (https://veritas.sao.arizona.edu/wiki/images/f/f3/CARE_V6_Std.txt)
gains_epoch_dict = dict(
    {
        4: {1: 5.11, 2: 5.32, 3: 4.76, 4: 5.00 },
        5: {1: 5.20, 2: 5.31, 3: 5.33, 4: 5.46 },
        6: {1: 5.20, 2: 5.12, 3: 5.12, 4: 5.54 },
        6: {1: 5.73*0.939, 2: 5.73*0.924, 3: 5.73*0.924, 4: 5.73*1.000}
    }
)

### Collect the data and derive the single PE based g-factors
## this is very similar to the photostat gains.

for k,run in enumerate(singlePE[:,1]):
    dt = datetime.datetime.strptime(
        "{0}_0300".format(int(singlePE[k,0])),"%Y%m%d_%H%M",
    )
    
    if run<46642:   majorepoch=4
    elif run<63373: majorepoch=5
    else:           majorepoch=6
    
    gain_ref = gains_epoch_dict[majorepoch]
    
    gainfile = glob.glob("singlePE/{0}_*/*.gains".format(run))
    if len(gainfile)==0: continue
    gaindata = np.loadtxt(gainfile[0],
                          skiprows=8,
                          delimiter=' ',
                          converters={1: lambda f: int(f[1])},
                          )
    
    Gr = [gain_ref[1],gain_ref[2],gain_ref[3],gain_ref[3]]
    Nm = [gaindata[0,6],gaindata[1,6],gaindata[2,6],gaindata[3,6]]
    
    gains_all.append([atime.Time(dt).mjd])
    for T in range(4):
        Gr = gain_ref[T+1]
        Nm = gaindata[T,6]        
        gains_all[-1].append(gaindata[T,2]/Gr)
        gains_all[-1].append(gaindata[T,3]/(Gr*np.sqrt(Nm)))
        
        if gaindata[T,2] == 0: gains_all.pop()
    
    gains_qua.append([atime.Time(dt).mjd])
    for T in range(4):
        Gr = gain_ref[T+1]
        Nm = gaindata[T,6]
        gains_qua[-1].append(gaindata[T,4]/Gr)
        gains_qua[-1].append(gaindata[T,5]/(Gr*np.sqrt(Nm)))

gains_all = np.asarray(gains_all)
gains_qua = np.asarray(gains_qua)

#### Make the plot

gain_result = dict()

fig   = plt.figure(figsize=(5,5),dpi=150)
for T in range(1,4+1):
    plot  = fig.add_subplot(2,2,T)
    
    raw_mjds = gains_qua[:,0]
    raw_vals = gains_qua[:,2*T-1]
    raw_errs = gains_qua[:,2*T]
    
    mjds = []
    vals = []
    errs = []
    
    filt = ((raw_errs/raw_vals) < 0.2)*            (raw_vals<np.median(raw_vals)+1*np.std(raw_vals))*            (raw_vals>np.median(raw_vals)-1*np.std(raw_vals))
    
    raw_mjds = raw_mjds[filt]
    raw_vals = raw_vals[filt]
    raw_errs = raw_errs[filt]
        
    for mjd in np.unique(sorted(raw_mjds)):
        vals.append(np.mean(raw_vals[raw_mjds==mjd]))
        errs.append(np.mean(raw_errs[raw_mjds==mjd]) + np.std(raw_vals[raw_mjds==mjd])/np.sum(raw_mjds==mjd))
        mjds.append(mjd)
    
    mjds = np.asarray(mjds)
    vals = np.asarray(vals)
    errs = np.asarray(errs)
        
    smoo = ssignal.savgol_filter(vals,3,1)
    
    plot.errorbar(
        x    = atime.Time(mjds,format='mjd').datetime,
        y    = vals,
        yerr = errs,
        marker='o',
        ms=1.8,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='gray',
        label='raw',
        alpha=0.5,
        zorder=-10
    )
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjds,format='mjd').datetime,
        y    = smoo,
        yerr = errs,
        marker='o',
        ms=1.2,
        mew=0.5,
        lw=0.8,
        ls='None',
        color='C{0}'.format(T-1),
        label='filtered'
    )
    
    xint = np.linspace(min(mjds),max(mjds),100)
    spli = sinterp.splrep(mjds,smoo,s=0.0008)
    yint = sinterp.splev(xint,spli)
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        yint,
        lw=0.5,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
    for k in range(len(year_begin_mjd)):
        tfilt = (mjds>=year_begin_mjd[k])*(mjds<=year_end_mjd[k])
        if np.sum(tfilt)==0: 
            tfiltspline = (xint>=year_begin_mjd[k])*(xint<=year_end_mjd[k])
            if np.sum(tfiltspline)==0: 
                continue
            else:
                mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
                mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
                val_season_val.append(np.median(yint[tfiltspline]))
                val_season_err.append(0*np.std(yint[tfiltspline]))
        else:
            mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
            mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
            val_season_val.append(np.median(vals[tfilt]))
            val_season_err.append(np.sqrt((np.std(vals[tfilt]))**2 + np.mean(errs[tfilt])**2))
    
    mjd_season_val = np.asarray(mjd_season_val)
    mjd_season_err = np.asarray(mjd_season_err)
    val_season_val = np.asarray(val_season_val)
    val_season_err = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.set_ylim(0.7,1.12)
    plot.set_yticks(np.arange(0.7,1.15,0.1))
    plot.legend(fontsize='xx-small',ncol=3,loc=4)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
    gain_result[T] = dict()
    gain_result[T]['mjds']   = mjds
    gain_result[T]['vals']   = vals
    gain_result[T]['errs']   = errs
    gain_result[T]['smoo']   = smoo
    gain_result[T]['spline'] = spli
    gain_result[T]['mjds_average']   = mjd_season_val
    gain_result[T]['mjds_avererr']   = mjd_season_err
    gain_result[T]['vals_average']   = val_season_val
    gain_result[T]['errs_average']   = val_season_err
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'g-factors from single PE', 
         va='center', rotation='vertical',fontsize='large')

plt.tight_layout()

fig.savefig("GFactors_SinglePE.pdf",bbox_inches='tight')
fig.savefig("GFactors_SinglePE.png",bbox_inches='tight',dpi=120)

### table with the results

table_summary = []

mjdsave = gain_result[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave):
    
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    table_summary.append([season])

    table_summary[-1].append(mjd)
    table_summary[-1].append(gain_result[1]['mjds_avererr'][k])
    table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
    for T in range(1,4+1):
        table_summary[-1].append('{0:.3f}'.format(gain_result[T]['vals_average'][k]))
        table_summary[-1].append('{0:.3f}'.format(gain_result[T]['errs_average'][k]))

print('#### g factors (single PE)')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'g[1]','err[1]','g[2]','err[2]',
                                               'g[3]','err[3]','g[4]','err[4]']))

table_summary_gain = list(table_summary)


######################################
## T-factors are the same as before ##
######################################

v483_refs = np.asarray([\
  [56322.5, 151.5, 1.00, 1.00, 1.00, 1.00],
  [56687.5, 151.5, 0.90, 0.98, 0.82, 0.85],
  [57052.5, 151.5, 0.77, 0.86, 0.77, 0.78],
  [57418.0, 152.0, 0.78, 0.83, 0.73, 0.81],
  [57783.5, 151.5, 0.72, 0.82, 0.68, 0.74],
  [58148.5, 151.5, 0.71, 0.78, 0.72, 0.73],
  [58513.5, 151.5, 0.68, 0.72, 0.65, 0.68],
])

# https://veritas.sao.arizona.edu/wiki/images/1/14/Reflectivity_tucson.pdf
# https://veritas.sao.arizona.edu/wiki/images/5/53/Reflectivity_zeuthen_13.pdf
MeanRefF4 = {T: mean_reflectivity(RFCRV[T],435,445) for T in range(1,4+1)}
T1_2010 = np.asarray([0.73,0.75,0.82,0.85,0.79,0.81,0.79,0.77,0.65,0.65,0.75,0.77,0.72,0.73])
T2_2010 = np.asarray([0.84,0.89,0.89,0.89,0.72,0.80,0.87])
T3_2010 = np.asarray([0.72,0.64,0.79,0.74,0.72])
T4_2010 = np.asarray([0.75,0.73,0.73,0.75,0.83,0.82])
    
old_results_ref_hanna = np.asarray([
    [atime.Time("2012-10-20 12:00:00").mjd, # aprox
     np.mean(T1_2010)/MeanRefF4[1],np.std(T1_2010)/MeanRefF4[1],
     np.mean(T2_2010)/MeanRefF4[2],np.std(T2_2010)/MeanRefF4[2],
     np.mean(T3_2010)/MeanRefF4[3],np.std(T3_2010)/MeanRefF4[3],
     np.mean(T4_2010)/MeanRefF4[4],np.std(T4_2010)/MeanRefF4[4],
    ],
    [atime.Time("2012-02-15 12:00:00").mjd,
     None, None,
     0.01*75.01/MeanRefF4[2],0.01*0.22/MeanRefF4[2],
     0.01*70.02/MeanRefF4[3],0.01*0.22/MeanRefF4[3],
     0.01*69.43/MeanRefF4[4],0.01*0.20/MeanRefF4[4],
    ],
    [atime.Time("2012-10-15 12:00:00").mjd,
     None, None,
     0.01*68.83/MeanRefF4[2],0.01*1.12/MeanRefF4[2],
     0.01*67.57/MeanRefF4[3],0.01*1.18/MeanRefF4[3],
     0.01*58.03/MeanRefF4[4],0.01*1.17/MeanRefF4[4],
    ],
    [atime.Time("2012-11-15 12:00:00").mjd,
     0.01*65.90/MeanRefF4[1],0.01*1.52/MeanRefF4[1],
     None, None,
     None, None,
     None, None],
    [atime.Time("2013-01-15 12:00:00").mjd,
     0.01*54.47/MeanRefF4[1],0.01*0.52/MeanRefF4[1],
     None, None,
     None, None,
     None, None],
])

# Reflectivity data:
# The averages files is the old format, tracknums files is the new format as of Aug 11.
# in both cases, the files are provided by David Hanna.
WDRformat="tracknums"
hanna_reflectdir = "ReflectivityFromDHanna/"
if WDRformat=="averages":
    hanna_files = [f.split("/")[-1] \
        for f in sorted(glob.glob(hanna_reflectdir+"/averages*"))]
    months_raw  = np.unique([int(f.split("_")[1]) for f in hanna_files])
    init_date = datetime.datetime(2014,1,1,0,0,0)

    table_reflectivities = []
    for month_tot in months_raw:
        years  = int(month_tot/12)
        months = int(month_tot%12)
        dt = atime.Time(datetime.datetime(\
            2014+years,
            1+months,
            15,
            0,0,0)).mjd
        
        reflect_date = [0 for k in range(9)]
        reflect_date[0] = dt
        
        b_filt = [0,0,0,0]
        b_err  = [0,0,0,0]
        for n in range(80):
            fname = "averages_{0}_{1}.dat".format(month_tot,n+1)
            if not fname in hanna_files:
                break
            
            nm  = int(n/4)+1
            tel = n%4 + 1
            cont=np.loadtxt(hanna_reflectdir+"/"+fname)
            reflect_date[tel*2-1] += cont[4]
            reflect_date[tel*2]   += cont[5]**2
        
        for tel in range(4):
            reflect_date[1+tel*2] = reflect_date[1+tel*2]/nm
            reflect_date[1+tel*2+1] = np.sqrt(reflect_date[1+tel*2+1])/nm
        
        table_reflectivities.append(reflect_date)

    table_reflectivities_array = np.asarray(table_reflectivities)
    table_reflectivities = dict()
    for tel in range(4):
        table_reflectivities[tel+1] = np.transpose([
            table_reflectivities[:,0],
            table_reflectivities[:,T*2+1],
            table_reflectivities[:,T*2+2]
        ])

    
    #print(table_reflectivities)

elif WDRformat=='tracknums':
    hanna_files = glob.glob(hanna_reflectdir+"/tracknums*.dat")
    init_date = atime.Time(datetime.datetime(2014,1,1,0,0,0)).mjd
    hanna_contents = [np.loadtxt(hf).reshape(3,-1) for hf in hanna_files]
     
    table_reflectivities = dict()
    for tel in range(4):
        hc = hanna_contents[tel]
        hc   = np.delete(hc, 0, axis=1)
        days = hc[0]
        vals = hc[1]
        errs = hc[2]
        mjds = days+init_date
        table_reflectivities[tel+1] = np.transpose([mjds,vals,errs])

refl_result = dict()

fig   = plt.figure(figsize=(5,5),dpi=150)
for T in range(1,4+1):
    plot  = fig.add_subplot(2,2,T)
    
    SimuR_B = mean_reflectivity(RFCRV[T],weights=[Bfilter])
    
    mjds = table_reflectivities[T][:,0]
    vals = table_reflectivities[T][:,1]/(SimuR_B)#*WCEFF[T])
    errs = table_reflectivities[T][:,2]/(SimuR_B)#*WCEFF[T])
    
    filt = ((errs/vals) < 0.5)*\
            (vals<np.median(vals)+5*np.std(vals))*\
            (vals>np.median(vals)-3*np.std(vals))    
    
    smoo = ssignal.medfilt(vals[filt],3)
    
    mjds = np.append([55851,55901,55951,55991],mjds)
    vals = np.append([1,1,1,1],vals)
    smoo = np.append([1,1,1,1],smoo)
    errs = np.append([0,0,0,0],errs)
    filt = np.asarray(np.append([1,1,1,1],filt),dtype='bool')
    
    plot.errorbar(
        x    = atime.Time(mjds,format='mjd').datetime,
        y    = vals,
        yerr = errs,
        marker='o',
        ms=2.,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='gray',
        label='raw',
        alpha=0.5,
        zorder=-10
    )
    
    tfilthannaold = old_results_ref_hanna[:,2*T-1]!=None
    plot.errorbar(
        x    = [atime.Time(_dt,format='mjd').datetime \
                for _dt in old_results_ref_hanna[tfilthannaold][:,0]],
        y    = old_results_ref_hanna[:,2*T-1][tfilthannaold],
        yerr = old_results_ref_hanna[:,2*T][tfilthannaold],
        marker='*',
        ms=4,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C6',
        label='test full-dish',
        alpha=0.5,
        zorder=-10
    )
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjds[filt],format='mjd').datetime,
        y    = smoo,
        yerr = errs[filt],
        marker='o',
        ms=1.4,
        mew=1,
        lw=0.8,
        ls='None'
        ,
        color='C{0}'.format(T-1),
        label='filtered'
    )
    
    xint = np.linspace(min(mjds),max(mjds),1000)
    spli = sinterp.splrep(mjds[filt],smoo,s=0.01)
    yint = sinterp.splev(xint,spli)
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        yint,
        lw=0.5,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
    
    #### Seasonal averages
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
    for k in range(len(year_begin_mjd)):
        tfilt  = (mjds>=year_begin_mjd[k])*(mjds<=year_end_mjd[k])*filt
        tfilt2 = tfilt[filt]
        if np.sum(tfilt)==0: 
            tfiltspline = (xint>=year_begin_mjd[k])*(xint<=year_end_mjd[k])
            if np.sum(tfiltspline)==0: 
                continue
            else:
                mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
                mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
                val_season_val.append(middle(yint[tfiltspline]))
                val_season_err.append(0.05)#*np.std(yint[tfiltspline]))
        
        else:
            mjd_season_val.append((year_begin_mjd[k]+year_end_mjd[k])/2.)
            mjd_season_err.append((year_end_mjd[k]-year_begin_mjd[k])/2.)
            val_season_val.append(middle(smoo[tfilt2]))
            val_season_err.append(np.sqrt((np.std(smoo[tfilt2]))**2 + np.mean(errs[tfilt])**2))
    
    
    mjd_season_val = np.asarray(mjd_season_val)
    mjd_season_err = np.asarray(mjd_season_err)
    val_season_val = np.asarray(val_season_val)
    val_season_err = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.set_ylim(0.5,1.05)
    plot.set_yticks(np.arange(0.5,1.15,0.1))
    plot.legend(fontsize='xx-small',ncol=1)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
        
    refl_result[T] = dict()
    refl_result[T]['mjds']   = mjds
    refl_result[T]['vals']   = vals
    refl_result[T]['errs']   = errs
    refl_result[T]['smoo']   = smoo
    refl_result[T]['spline'] = spli
    refl_result[T]['mjds_average']   = mjd_season_val
    refl_result[T]['mjds_avererr']   = mjd_season_err
    refl_result[T]['vals_average']   = val_season_val
    refl_result[T]['errs_average']   = val_season_err
    
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'T-factors from WDR/D.Hanna', 
         va='center', rotation='vertical',fontsize='large')

plt.tight_layout()

## Table with results

table_summary = []

mjdsave = refl_result[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave): 
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    table_summary.append([season])

    table_summary[-1].append(mjd)
    table_summary[-1].append(refl_result[1]['mjds_avererr'][k])
    table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
    for T in range(1,4+1):
        table_summary[-1].append('{0:.3f}'.format(refl_result[T]['vals_average'][k]))
        table_summary[-1].append('{0:.3f}'.format(refl_result[T]['errs_average'][k]))

print('#### T factors')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'T[1]','err[1]','T[2]','err[2]',
                                               'T[3]','err[3]','T[4]','err[4]']))

table_summary_refl = list(table_summary)

## The corresponding S-factors (again, using single PE gains

##### S-factors

v483_refs = np.asarray([\
  [56322.5, 151.5, 1.00, 1.00, 1.00, 1.00],
  [56687.5, 151.5, 0.91, 0.98, 0.83, 0.81],
  [57052.5, 151.5, 0.72, 0.82, 0.74, 0.72],
  [57418.0, 152.0, 0.73, 0.79, 0.71, 0.76],
  [57783.5, 151.5, 0.66, 0.76, 0.66, 0.70],
  [58148.5, 151.5, 0.68, 0.76, 0.67, 0.71],
  [58513.5, 151.5, 0.63, 0.69, 0.62, 0.66],
])

fig   = plt.figure(figsize=(5,5),dpi=150)

resulting_factors = dict()



for T in range(1,4+1):
    
    plot  = fig.add_subplot(2,2,T)
    
    refl = sinterp.splev(xint,refl_result[T]['spline'])
    gain = sinterp.splev(xint,gain_result[T]['spline'])
    tota = refl*gain
    
    mjd_season_val = []
    mjd_season_err = []
    val_season_val = []
    val_season_err = []
    
    for k,mjd in enumerate(refl_result[T]['mjds_average']):
        if mjd in gain_result[T]['mjds_average']:
            l = np.where(gain_result[T]['mjds_average']==mjd)
            mjd_season_val.append(mjd)
            mjd_season_err.append(refl_result[T]['mjds_avererr'][k])
            val_season_val.append((refl_result[T]['vals_average'][k]*\
                                   gain_result[T]['vals_average'][l])[0])
            val_season_err.append(np.sqrt(
                (refl_result[T]['vals_average'][k]*gain_result[T]['errs_average'][l])**2 +\
                (refl_result[T]['errs_average'][k]*gain_result[T]['vals_average'][l])**2
            )[0])
    
    resulting_factors[T] = dict()
    resulting_factors[T]['mjds_average'] = np.asarray(mjd_season_val)
    resulting_factors[T]['mjds_avererr'] = np.asarray(mjd_season_err)
    resulting_factors[T]['vals_average'] = np.asarray(val_season_val)
    resulting_factors[T]['errs_average'] = np.asarray(val_season_err)
    
    plot.errorbar(
        x    = atime.Time(v483_refs[:,0],format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in v483_refs[:,1]],
        y    = v483_refs[:,T+1],
        yerr = 0*v483_refs[:,T+1],
        marker='s',
        ms=2,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='C4',
        label='Tony/Colin',
        alpha=0.8,
        zorder=3
    )
    
    plot.errorbar(
        x    = atime.Time(mjd_season_val,format='mjd').datetime,
        xerr = [datetime.timedelta(days=d) for d in mjd_season_err],
        y    = val_season_val,
        yerr = val_season_err,
        marker='D',
        ms=3,
        mew=0.5,
        lw=0.9,
        ls='None',
        color='black',
        label='average',
        alpha=0.5,
        zorder=5
    )
    
    plot.plot(
        atime.Time(xint,format='mjd').datetime,
        tota,
        lw=1,
        ls='dashed',
        color='C{0}'.format(T-1),
        label='spline'
    )
    
    plot.set_ylim(0.45,1.1)
    plot.set_yticks(np.arange(0.5,1.15,0.1))
    plot.legend(fontsize='x-small',ncol=1)
    plot.grid(lw=0.5,ls='dotted')
    plot.set_title("T{0}".format(T))
    for tick in plot.get_xticklabels():
        tick.set_rotation(45)
        tick.set_fontsize('small')
        
    
fig.text(0.5, 0.0, 'Date', ha='center',fontsize='large')
fig.text(-0.02, 0.5, 'S-factors from WDR/D.Hanna + Gains from single PE', 
         va='center', rotation='vertical',fontsize='large')
plt.tight_layout()

fig.savefig("SFactors_SinglePE_WDR.pdf",bbox_inches='tight')
fig.savefig("SFactors_SinglePE_WDR.png",bbox_inches='tight',dpi=120)

## corresponding table

table_summary = []

mjdsave = resulting_factors[1]['mjds_average']
diffs  = mjdsave[1:]-mjdsave[:-1]
begmjd = np.append(mjdsave[0]-diffs[0]/2.,mjdsave[:-1]+diffs/2.)
endmjd = np.append(mjdsave[:-1]+diffs/2.,mjdsave[-1]+diffs[-1]/2.)

for k,mjd in enumerate(mjdsave):
    
    season = "{0}-{1}".format(int(atime.Time(mjdsave[k]-270,format='mjd').datetime.strftime("%Y")),
                              int(atime.Time(mjdsave[k]+95,format='mjd').datetime.strftime("%Y")))
    
    if k>0:
        if season==table_summary[-1][0]:
            table_summary[-1][0]+="a"
            season+="b"
        elif season[0:9]==table_summary[-1][0][0:9]:
            season+=chr(ord(table_summary[-1][0][9]) + 5)
    
    try:
        resulting_factors[1]['mjds_avererr'][k]
    except IndexError:
        pass
    else:
        table_summary.append([season])

        table_summary[-1].append(mjd)
        table_summary[-1].append(resulting_factors[1]['mjds_avererr'][k])
        table_summary[-1].append("{0}-{1}".format(int(begmjd[k]),int(endmjd[k])))
        for T in range(1,4+1):
            table_summary[-1].append('{0:.3f}'.format(resulting_factors[T]['vals_average'][k]))
            table_summary[-1].append('{0:.3f}'.format(resulting_factors[T]['errs_average'][k]))

print('#### S factors (single PE)')
print(tabulate.tabulate(table_summary,headers=['season','mjdav','width','range_mjd',
                                               'S[1]','err[1]','S[2]','err[2]',
                                               'S[3]','err[3]','S[4]','err[4]']))

table_summary_sfac = list(table_summary)


print("To write down in the MSCW.sizescal.runparameter")

for l in table_summary_refl:
    print("* T V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])

print("")
for l in table_summary_gain:
    print("* G V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])

print("")
for l in table_summary_sfac:
    print("* s V6_"+l[0].replace("-","_"),l[4],l[6],l[8],l[10])


