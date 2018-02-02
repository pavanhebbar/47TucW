"""Program to merge the light curves from different obsIds"""

import sys
import numpy as np
import matplotlib.pyplot as plt
from astropy.io import fits
import glob2


def get_lcfiles(year_data, lc_file):
    """Get a list of light curves in the given year obeservation."""
    lc_loc = glob2.glob(year_data + '/*/' + lc_file)
    return lc_loc


def extract_netrate(lc_file):
    """Extract counts from the given lcfile."""
    l_curve = fits.getdata(lc_file)
    counts = [l_curve['counts'], l_curve['count_rate']]
    bkg_counts = [l_curve['bg_counts'], l_curve['bg_rate'],
                  l_curve['bg_exposure']]
    net_counts = [l_curve['net_counts'], l_curve['net_rate']]
    return counts, bkg_counts, net_counts


def add_lcs(lc_locs):
    """Add light curves."""
    tot_counts = 0
    tot_time = 0
    tot_bg = 0
    tot_netcount = 0
    if not lc_locs:
        return tot_counts, tot_time, tot_bg, tot_netcount
    for loc in lc_locs:
        info = extract_netrate(loc)
        tot_counts += info[0][0]
        tot_bg += info[1][0]
        tot_time += info[1][2]
        tot_netcount += info[2][0]
    return tot_counts, tot_time, tot_bg, tot_netcount


def get_table(year_data, lc_en='full', num=''):
    """return HDU table in the given energy."""
    if lc_en == 'full':
        lclocs = get_lcfiles(year_data, 'source'+num+'_1as_phase.lc')
    else:
        lclocs = get_lcfiles(year_data, 'source'+num+'_1asphase_' +
                             lc_en+'en.lc')
    totcounts, tot_time, tot_bg, tot_netcount = add_lcs(lclocs)
    tot_netcount[np.where(tot_netcount < 0)] = 0.0
    sb_area_ratio = (totcounts - tot_netcount)*1.0/tot_bg
    totc_up = totcounts + (totcounts + 0.75)**0.5 + 1.0
    totc_down = totcounts - (totcounts - 0.25)**0.5
    totc_down[np.where(totc_down < 0)] = 0
    totbg_errup = 1.0 + (tot_bg + 0.75)**0.5
    totbg_errdown = (tot_bg - 0.25)**0.5
    totbg_errdown[np.where(totbg_errdown < 0)] = 0.0
    netc_up = (((totc_up - totcounts)**2 +
                totbg_errup**2*sb_area_ratio**2)**0.5 +
               tot_netcount)
    netc_down = (tot_netcount -
                 ((totcounts - totc_down)**2 +
                  totbg_errdown**2*sb_area_ratio**2)**0.5)
    netc_down[np.where(netc_down < 0)] = 0.0
    if num == '':
        phase = fits.getdata(lclocs[0])['phase_corr']
    elif num == '0':
        phase = fits.getdata(lclocs[0])['phase0']
    else:
        phase = fits.getdata(lclocs[0])['phase0_'+num]
    phase_col = fits.Column(name='phase', format='E', array=phase)
    time_col = fits.Column(name='total_time', format='D', array=tot_time)
    count_col = fits.Column(name='counts', format='E', array=totcounts)
    bg_col = fits.Column(name='bkg_counts', format='E', array=tot_bg)
    netc_col = fits.Column(name='net_counts', format='D', array=tot_netcount)
    netcup_col = fits.Column(name='net_count_upper', format='D',
                             array=netc_up)
    netcd_col = fits.Column(name='net_count_lower', format='D',
                            array=netc_down)
    hdutable = fits.BinTableHDU.from_columns([phase_col, time_col, count_col,
                                              bg_col, netc_col, netcup_col,
                                              netcd_col],
                                             name=lc_en+' energy')
    # val = fit_lc(tot_netcount, tot_netcount**0.5)
    # print lc_en, val, get_chi2(tot_netcount, tot_netcount**0.5, val)
    if not np.sum(tot_netcount) == 0:
        plotfig(year_data+'/'+year_data+'_'+num+lc_en+'.png', 'phase',
                'net counts', phase,
                tot_netcount, netc_up, netc_down)
    return hdutable


def make_fits(year_data):
    """Make a fits file from hdu tables"""
    prheader = fits.Header()
    prheader['EXTEND'] = 'T'
    nums = ['', '0', '1', '2', '3']
    for num in nums:
        print num
        hdu0 = fits.PrimaryHDU(header=prheader)
        hdu1 = get_table(year_data, 'full', num)
        if year_data == "2005":
            hdulist = fits.HDUList([hdu0, hdu1])
        else:
            hdu2 = get_table(year_data, 'filt', num)
            hdu3 = get_table(year_data, 'vlow', num)
            hdu4 = get_table(year_data, 'low', num)
            hdu5 = get_table(year_data, 'high', num)
            hdulist = fits.HDUList([hdu0, hdu1, hdu2, hdu3, hdu4, hdu5])
        hdulist.writeto(year_data+'/merged_lcs'+num+'.fits', overwrite=True)


def plotfig(name, xlabel, ylabel, xdata, ydata, yup, ydown):
    """Plot figure."""
    plt.figure()
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.step(xdata, ydata, where='mid')
    asymmerr = [ydata - ydown, yup - ydata]
    plt.errorbar(xdata, ydata, yerr=asymmerr, fmt='b.')
    plt.tight_layout()
    plt.savefig(name)
    plt.close()


def fit_lc(l_curve, errors):
    """Fits the light curve to a constant."""
    phase = np.linspace(0, 1, len(l_curve))  # Doesn't really matter
    val = np.polyfit(phase, l_curve, 0, w=1.0/errors)
    return val


def get_chi2(l_curve, errors, val):
    """Return the chi cquare value."""
    return np.sum((l_curve - val)**2*1.0/errors**2)


if __name__ == '__main__':
    make_fits(sys.argv[1])
