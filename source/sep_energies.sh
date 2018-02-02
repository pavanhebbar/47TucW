binsize=0.05
binsize2=0.05
for year_data in 2002 2005 2015
do
	year_data=$(basename $year_data)
	cd $year_data
	for obs_id in $(find . -type d -name '*' -mindepth 1 -maxdepth 1)
	do
		
		obs_id=$(basename $obs_id)
		if [ "$obs_id" = "reproj" ]; then
			break
		fi
		echo "Processing folder "$obs_id""
		cd "$obs_id"
		dmextract "source_1as_phase.evt[bin phase_corr=0.0:1.0:$binsize]" source_1as_phase.lc op=generic error=gaussian bkg=bkg_phase.evt bkgerror=gaussian clobber=yes
		dmextract "source_1as_phase.evt[bin phase0=0.0:1.0:$binsize]" source0_1as_phase.lc op=generic error=gaussian bkg=bkg_phase.evt bkgerror=gaussian clobber=yes
		dmextract "source_1as_phase.evt[bin phase0_1=0.0:1.0:$binsize]" source1_1as_phase.lc op=generic error=gaussian bkg=bkg_phase.evt bkgerror=gaussian clobber=yes
		dmextract "source_1as_phase.evt[bin phase0_2=0.0:1.0:$binsize]" source2_1as_phase.lc op=generic error=gaussian bkg=bkg_phase.evt bkgerror=gaussian clobber=yes
		dmextract "source_1as_phase.evt[bin phase0_3=0.0:1.0:$binsize]" source3_1as_phase.lc op=generic error=gaussian bkg=bkg_phase.evt bkgerror=gaussian clobber=yes
		if [ "$year_data" -ne "2005" ]; then
			dmcopy "source_1as_phase.evt[energy=300:8000]" source_1asphase_filten.evt clobber=yes
			dmcopy "source_1as_phase.evt[energy=300:2000]" source_1asphase_lowen.evt clobber=yes
			dmcopy "source_1as_phase.evt[energy=2000:8000]" source_1asphase_highen.evt clobber=yes
			dmcopy "source_1as_phase.evt[energy=200:1000]" source_1asphase_vlowen.evt clobber=yes
			dmcopy "bkg_phase.evt[energy=300:8000]" bkgphase_filten.evt clobber=yes
			dmcopy "bkg_phase.evt[energy=300:2000]" bkgphase_lowen.evt clobber=yes
			dmcopy "bkg_phase.evt[energy=2000:8000]" bkgphase_highen.evt clobber=yes
			dmcopy "bkg_phase.evt[energy=200:1000]" bkgphase_vlowen.evt clobber=yes
			dmextract "source_1asphase_vlowen.evt[bin phase_corr=0.0:1.0:$binsize2]" source_1asphase_vlowen.lc op=generic error=gaussian bkg=bkgphase_vlowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_filten.evt[bin phase_corr=0.0:1.0:$binsize]" source_1asphase_filten.lc op=generic error=gaussian bkg=bkgphase_filten.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_lowen.evt[bin phase_corr=0.0:1.0:$binsize]" source_1asphase_lowen.lc op=generic error=gaussian bkg=bkgphase_lowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_highen.evt[bin phase_corr=0.0:1.0:$binsize2]" source_1asphase_highen.lc op=generic error=gaussian bkg=bkgphase_highen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_vlowen.evt[bin phase0=0.0:1.0:$binsize2]" source0_1asphase_vlowen.lc op=generic error=gaussian bkg=bkgphase_vlowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_filten.evt[bin phase0=0.0:1.0:$binsize]" source0_1asphase_filten.lc op=generic error=gaussian bkg=bkgphase_filten.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_lowen.evt[bin phase0=0.0:1.0:$binsize]" source0_1asphase_lowen.lc op=generic error=gaussian bkg=bkgphase_lowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_highen.evt[bin phase0=0.0:1.0:$binsize2]" source0_1asphase_highen.lc op=generic error=gaussian bkg=bkgphase_highen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_vlowen.evt[bin phase0_1=0.0:1.0:$binsize2]" source1_1asphase_vlowen.lc op=generic error=gaussian bkg=bkgphase_vlowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_filten.evt[bin phase0_1=0.0:1.0:$binsize]" source1_1asphase_filten.lc op=generic error=gaussian bkg=bkgphase_filten.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_lowen.evt[bin phase0_1=0.0:1.0:$binsize]" source1_1asphase_lowen.lc op=generic error=gaussian bkg=bkgphase_lowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_highen.evt[bin phase0_1=0.0:1.0:$binsize2]" source1_1asphase_highen.lc op=generic error=gaussian bkg=bkgphase_highen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_vlowen.evt[bin phase0_2=0.0:1.0:$binsize2]" source2_1asphase_vlowen.lc op=generic error=gaussian bkg=bkgphase_vlowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_filten.evt[bin phase0_2=0.0:1.0:$binsize]" source2_1asphase_filten.lc op=generic error=gaussian bkg=bkgphase_filten.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_lowen.evt[bin phase0_2=0.0:1.0:$binsize]" source2_1asphase_lowen.lc op=generic error=gaussian bkg=bkgphase_lowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_highen.evt[bin phase0_2=0.0:1.0:$binsize2]" source2_1asphase_highen.lc op=generic error=gaussian bkg=bkgphase_highen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_vlowen.evt[bin phase0_3=0.0:1.0:$binsize2]" source3_1asphase_vlowen.lc op=generic error=gaussian bkg=bkgphase_vlowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_filten.evt[bin phase0_3=0.0:1.0:$binsize]" source3_1asphase_filten.lc op=generic error=gaussian bkg=bkgphase_filten.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_lowen.evt[bin phase0_3=0.0:1.0:$binsize]" source3_1asphase_lowen.lc op=generic error=gaussian bkg=bkgphase_lowen.evt bkgerror=gaussian clobber=yes
			dmextract "source_1asphase_highen.evt[bin phase0_3=0.0:1.0:$binsize2]" source3_1asphase_highen.lc op=generic error=gaussian bkg=bkgphase_highen.evt bkgerror=gaussian clobber=yes
		fi
		cd ..
		pwd
	done
	cd ..
done
