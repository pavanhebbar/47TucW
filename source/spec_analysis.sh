for year_data in 2002 2015
do
	year_data=$(basename $year_data)
	cd $year_data
	for obs_id in $(find . -maxdepth 1 -mindepth 1 -name '*' -type d)
	do
		obs_id=$(basename $obs_id)
		if [ "$obs_id" = "reproj" ]; then
			break
		fi
		echo "Processing folder "$obs_id""
		cd "$obs_id"
		dmhedit bkg_bary.evt file= op=add key=ASOLFILE value="source_1as_bary.asol"
		punlearn dmgti
		pset dmgti infile=source_1as_phase.asol
		pset dmgti outfile=high.gti
		pset dmgti userlimit="((phase0_1<=0.1)||(phase0_1>0.4))"
		pset dmgti clobber=yes
		dmgti mode=h
		pset gti_align times=high.gti
		pset gti_align statfile=source_1as_bary.expstats
		pset gti_align outfile=high_align.gti
		pset gti_align evtfile=source_1as_bary.evt
		gti_align mode=h clob+
		dmcopy source_1as_bary.evt"[@high_align.gti]" source_1as_high.evt clob+
		dmcopy bkg_bary.evt"[@high_align.gti]" bkg_high.evt clob+
		pset specextract bkgfile="bkg_high.evt[sky=region(47TucW_bkg_phy.reg)]"
		dmkeypar source_1as_high.evt BPIXFILE
		bpixfile=$(pget dmkeypar value)
		dmkeypar source_1as_high.evt MASKFILE
		maskfile=$(pget dmkeypar value)
		pset specextract badpixfile="../../../"$year_data"_data/$obs_id/repro/"$bpixfile""
		pset specextract mskfile="../../../"$year_data"_data/$obs_id/repro/"$maskfile""
		specextract "source_1as_high.evt[sky=region(47TucW_1as_phy.reg)]" source_1as_high clob+ mode=h
		punlearn dmgti
		punlearn gti_align
		pset dmgti infile=source_1as_phase.asol
		pset dmgti outfile=transit.gti
		pset dmgti userlimit="((0.1<phase0_1)&&(phase0_1<=0.4))"
		pset dmgti clobber=yes
		dmgti mode=h
		pset gti_align times=transit.gti
		pset gti_align statfile=source_1as_bary.expstats
		pset gti_align outfile=transit_align.gti
		pset gti_align evtfile=source_1as_bary.evt
		gti_align mode=h clob+
		dmcopy source_1as_bary.evt"[@transit_align.gti]" source_1as_trans.evt clob+
		dmcopy bkg_bary.evt"[@high_align.gti]" bkg_trans.evt clob+
		pset specextract bkgfile="bkg_trans.evt[sky=region(47TucW_bkg_phy.reg)]"
		pset specextract badpixfile="../../../"$year_data"_data/$obs_id/repro/"$bpixfile""
		pset specextract mskfile="../../../"$year_data"_data/$obs_id/repro/"$maskfile""
		specextract "source_1as_trans.evt[sky=region(47TucW_1as_phy.reg)]" source_1as_trans clob+ mode=h
		cd ..
	done
	cd ..
done
