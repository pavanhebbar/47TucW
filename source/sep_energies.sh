for year_data in 2002 2015
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
		dmcopy "source_1as_phase.evt[energy=300:8000]" source_1asphase_filten.evt clobber=yes
		dmcopy "source_1as_phase.evt[energy=300:2000]" source_1asphase_lowen.evt clobber=yes
		dmcopy "source_1as_phase.evt[energy=2000:8000]" source_1asphase_highen.evt clobber=yes
		dmcopy "source_1as_phase.evt[energy=200:1000]" source_1asphase_vlowen.evt clobber=yes
		dmcopy "bkg_phase.evt[energy=300:8000]" bkgphase_filten.evt clobber=yes
		dmcopy "bkg_phase.evt[energy=300:2000]" bkgphase_lowen.evt clobber=yes
		dmcopy "bkg_phase.evt[energy=2000:8000]" bkgphase_highen.evt clobber=yes
		dmcopy "bkg_phase.evt[energy=200:1000]" bkgphase_vlowen.evt clobber=yes
		dmextract "source_1as_phase.evt[bin phase_corr=0.0:1.0:0.05]" source_1as_phase.lc op=generic error=gehrels bkg=bkg_phase.evt bkgerror=gehrels clobber=yes
		dmextract "source_1asphase_vlowen.evt[bin phase_corr=0.0:1.0:0.05]" source_1asphase_vlowen.lc op=generic error=gehrels bkg=bkgphase_vlowen.evt bkgerror=gehrels clobber=yes
		dmextract "source_1asphase_filten.evt[bin phase_corr=0.0:1.0:0.05]" source_1asphase_filten.lc op=generic error=gehrels bkg=bkgphase_filten.evt bkgerror=gehrels clobber=yes
		dmextract "source_1asphase_lowen.evt[bin phase_corr=0.0:1.0:0.05]" source_1asphase_lowen.lc op=generic error=gehrels bkg=bkgphase_lowen.evt bkgerror=gehrels clobber=yes
		dmextract "source_1asphase_highen.evt[bin phase_corr=0.0:1.0:0.05]" source_1asphase_highen.lc op=generic error=gehrels bkg=bkgphase_highen.evt bkgerror=gehrels clobber=yes
		cd ..
		pwd
	done
	cd ..
done
