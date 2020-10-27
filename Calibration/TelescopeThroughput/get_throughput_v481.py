import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import datetime
import astropy
import astropy.time as atime
from tabulate import tabulate

####
# This macro takes as input the file:
# s_factor_all_crab_since_2014.csv 
# which was produced by Tony Lin and circulated by
# Colin Adams [reference missing]
# and computes yearly/seasonal average for the 3 parameters
# T factor: Whole dish reflectivity (WDR)
# g factor: Telescope gain
# S factor: total throughput (g*T)
####


### Auxiliary functions #############
def datestr2num(string):
    if type(string)==bytes:
        string = string.decode('utf-8')
    dt = datetime.datetime.strptime(str(string),"%Y-%m-%d %H:%M:%S")
    at = atime.Time(dt)
    return(at.mjd)
#####################################

### Plotting style ##################
mpl.rc('font',**{'family':'serif','serif':['Palatino']})
mpl.rc('axes',facecolor = (1,1,1,1))
mpl.rc('figure',facecolor = (1,1,1,1))
mpl.rc('text', usetex=True)
mpl.rc('figure',figsize=(4.2,2.4))
mpl.rc('figure',dpi=120)
mpl.rc('savefig',dpi=120)
######################################

data = np.loadtxt("s_factor_all_crab_since_2014.csv",converters={1: datestr2num}, skiprows=1,delimiter=',')
years = range(2014,2020+1,1)
mjds  = data[:,1]
midmjds  = {y:atime.Time("{0}-02-01".format(y)).mjd for y in years}
filts = {y:np.abs(mjds-midmjds[y])<6.5*30 for y in years}

t_table = []
g_table = []
s_table = []

fig = plt.figure(figsize=(9,3.2),dpi=100)
ax1 = fig.add_subplot(131)
ax2 = fig.add_subplot(132)
ax3 = fig.add_subplot(133)

headers = ["Tel"]
for y in years:
    headers.append("{0}".format(y))

for tel in range(1,4+1):
    t_table.append(["T{0}".format(tel)])
    g_table.append(["T{0}".format(tel)])
    s_table.append(["T{0}".format(tel)])
    
    ax1.scatter(data[:,1],
                data[:,tel+1],
                s=0.5,
                color='C{0}'.format(tel),
                label="T{0}".format(tel),
    )
    ax2.scatter(data[:,1],
                data[:,tel+5],
                s=0.5,
                color='C{0}'.format(tel),
                label="g{0}".format(tel),
    )
    ax3.scatter(data[:,1],
                data[:,tel+9],
                s=0.5,
                color='C{0}'.format(tel),
                label="S{0}".format(tel),
    )
    
    for y in years:
        filt      = filts[y]
        _mjds     = data[:,1][filt==True]
        #print(_mjds)
        t_factors = data[:,tel+1][filt==True]
        g_factors = data[:,tel+5][filt==True]
        s_factors = data[:,tel+9][filt==True]
        t_table[-1].append("{0:.3f}".format(np.mean(t_factors)))
        g_table[-1].append("{0:.3f}".format(np.mean(g_factors)))
        s_table[-1].append("{0:.3f}".format(np.mean(s_factors)))
        if len(_mjds)<1:
            continue
        
        ax1.errorbar(
            x=[0.5*(np.min(_mjds)+np.max(_mjds))],
            xerr=[0.5*(np.max(_mjds)-np.min(_mjds))],
            y=[np.mean(t_factors)],
            yerr=[np.std(t_factors)],
            ls='solid',
            marker='D',
            mfc='None',
            lw=1,
            color='C{0}'.format(tel)
        )
        ax2.errorbar(
            x=[0.5*(np.min(_mjds)+np.max(_mjds))],
            xerr=[0.5*(np.max(_mjds)-np.min(_mjds))],
            y=[np.mean(g_factors)],
            yerr=[np.std(g_factors)],
            ls='solid',
            marker='D',
            mfc='None',
            lw=1,
            color='C{0}'.format(tel)
        )
        ax3.errorbar(
            x=[0.5*(np.min(_mjds)+np.max(_mjds))],
            xerr=[0.5*(np.max(_mjds)-np.min(_mjds))],
            y=[np.mean(s_factors)],
            yerr=[np.std(s_factors)],
            ls='solid',
            marker='D',
            mfc='None',
            lw=1,
            color='C{0}'.format(tel)
        )
        
        
#ax1.set_ylabel('t-factors')
#ax2.set_ylabel('g-factors')
#ax3.set_ylabel('S-factors')

ax1.set_xlabel('Time [MJD]')
ax2.set_xlabel('Time [MJD]')
ax3.set_xlabel('Time [MJD]')

ax1.legend(ncol=2)
ax2.legend(ncol=2)
ax3.legend(ncol=2)

ax1.grid(lw=0.5,ls='dashed')
ax2.grid(lw=0.5,ls='dashed')
ax3.grid(lw=0.5,ls='dashed')

plt.suptitle('WDR (T-factors), Gain (g-factor) and Total Throughput (S-factors)',y=1.05,fontsize='x-large')
plt.savefig("TelescopeThroughput.pdf")
plt.tight_layout()

print("###### T-factor table ######")
print(tabulate(t_table,headers))
print("")
print("###### g-factor table ######")
print(tabulate(g_table,headers))
print("")
print("###### s-factor table ######")
print(tabulate(s_table,headers))

