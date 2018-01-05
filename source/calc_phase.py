"""Program to calculate the phase at a given time for 47Tuc W.

Ephemeris information from Ridolfi et al.
"""

import sys
import numpy as np
from astropy.io import fits


def orb_eph():
    """Define the frequence derivatives."""
    freq = np.zeros(9)
    freq[0] = 8.70594798*10**-5
    freq[1] = -1.26*10**-18
    # freq[2] = 4.0E-26
    # freq[3] = 6.3E-33
    # freq[4] = -9.2E-40
    # freq[5] = 6.3E-47
    # freq[6] = -2.71E-54
    # freq[7] = 7.4E-62
    # freq[8] = -1.22E-69
    return freq


def getorb_freq(time, freq=orb_eph(), time0=66643148.677248):
    """Return orbital frequency.

    time, time0 in seconds.
    """
    return (freq[0] + freq[1]*(time - time0) + freq[2]/2.0*(time - time0)**2
            + freq[3]/6.0*(time - time0)**3 + freq[4]/24.0*(time - time0)**4
            + freq[5]/120.0*(time - time0)**5
            + freq[6]/720.0*(time - time0)**6
            + freq[7]/5040.0*(time - time0)**7
            + freq[8]/40320.0*(time - time0)**8)


def getphase(time_f, time_p=66643148.677248):
    """Return phase at time_f."""
    freq_arr = orb_eph()
    phase = 0.0
    prod = 1.0
    for i, freq_d in enumerate(freq_arr):
        phase += freq_d*(time_f - time_p)**(i+1)*1.0/prod
        prod = prod*(i+2.0)
    phase_0 = (time_f - time_p)*freq_arr[0]
    phase0_1 = (time_f - time_p)*8.7059474484*10**-5
    phase0_2 = (time_f - time_p)*8.70594722*10**-5
    phase0_3 = (time_f - time_p)*8.70594646*10**-5
    return phase, phase_0, phase0_1, phase0_2, phase0_3


def calc_phase(infile, outfile):
    """Add phase column to the given table."""
    data = fits.open(infile)
    header = data[1].header
    times = data[1].data['time']
    phase = np.zeros_like(times)
    phase0 = np.zeros_like(times)
    phase0_1 = np.zeros_like(times)
    phase0_2 = np.zeros_like(times)
    phase0_3 = np.zeros_like(times)
    freqs = np.zeros_like(times)
    for i, time in enumerate(times):
        phases = getphase(time)
        phase[i], phase0[i], phase0_1[i], phase0_2[i], phase0_3[i] = phases
        freqs[i] = getorb_freq(time)
    diff = phase - phase0
    phase = phase - np.floor(phase)
    phase0 = phase0 - np.floor(phase0)
    phase0_1 = phase0_1 - np.floor(phase0_1)
    phase0_2 = phase0_2 - np.floor(phase0_2)
    phase0_3 = phase0_3 - np.floor(phase0_3)
    phase_col = fits.Column(name='phase_corr', format='D', array=phase)
    phase0_col = fits.Column(name='phase0', format='D', array=phase0)
    phase01_col = fits.Column(name='phase0_1', format='D', array=phase0_1)
    phase02_col = fits.Column(name='phase0_2', format='D', array=phase0_2)
    phase03_col = fits.Column(name='phase0_3', format='D', array=phase0_3)
    diff_col = fits.Column(name='difference', format='D', array=diff)
    freq_col = fits.Column(name='frequency', format='D', array=freqs)
    data[1].data = fits.BinTableHDU.from_columns(
        data[1].columns + phase_col + phase0_col + phase01_col +
        phase02_col + phase03_col + diff_col + freq_col).data
    data[1].header = header
    data.writeto(outfile, overwrite=True)


if __name__ == '__main__':
    calc_phase(sys.argv[1], sys.argv[2])
