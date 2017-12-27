
for year_data in $(find . -type d -name '*' -maxdepth 1 -mindepth 1)
do
	year_data=$(basename $year_data)
	cd $year_data
	for obs_id in $(find . -type d -name '*' -maxdepth 1 -mindepth 1)
	do
		
		obs_id=$(basename $obs_id)
		if [ "$obs_id" = "reproj" ]; then
			break
		fi
		echo "Processing folder "$obs_id""
		cd "$obs_id"
		python ../../calc_phase.py 'source_1as_bary.evt' 'source_1as_phase.evt'
		python ../../calc_phase.py 'bkg_bary.evt' 'bkg_phase.evt'
		python ../../calc_phase.py 'source_1as_bary.asol' 'source_1as_phase.asol'
		cd ..
		pwd
	done
	#reproject_obs "*/repro/source_1as_phase.evt" reproj/ clobber=yes
	cd ..
done
