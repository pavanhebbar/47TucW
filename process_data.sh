#Bash script to analyse the data for 47TucW
#! /bin/bash


for year_data in 2002_data 2005_data 2015_data
do
	year_data=$(basename $year_data)
	year="${year_data/_data/}"
	mkdir source/"$year"
	cd $year_data
	for obs_id in $(find . -type d -name '*' -maxdepth 1 -mindepth 1)
	do
		obs_id=$(basename $obs_id)
		if [ "$obs_id" = "reproj" ]; then
			break
		fi
		echo "Processing folder "$obs_id""
		mkdir ../source/"$year"/"$obs_id"
		cd "$obs_id"/repro
		evtfile=$(find $PWD -name "*_evt2.fits")
		echo $evtfile
		#Get the region files
		cp /Users/pavanrh/UofA_projects/47TucW_study/"$year_data"/"$obs_id"/repro/47TucW_* ./
		cp /Users/pavanrh/UofA_projects/47TucW_study/"$year_data"/"$obs_id"/repro/47TucW_* ../../../source/"$year"/"$obs_id"/
		source_fk5=$(find . -name "*as_fk5.reg")
		source_phy=$(find . -name "*as_phy.reg")
		bkg_fk5=$(find . -name "*_bkg_fk5.reg")
		bkg_phy=$(find . -name "*_bkg_phy.reg")
		if [ -z "$source_fk5" ] || [ -z "$source_phy" ]; then
			echo "Source region file missing"
			ds9 "$evtfile"
			source_fk5=$(find . -name "*as_fk5.reg")
			source_phy=$(find . -name "*as_phy.reg")
		fi
		if [ -z "$bkg_fk5" ] || [ -z "$bkg_phy" ]; then
			echo "Backround region file missing"
			ds9 "$evtfile"
			bkg_fk5=$(find . -name "*as_fk5.reg")
			bkg_phy=$(find . -name "*as_phy.reg")
		fi	
		echo "Region files stored"
		cd ../../../source/"$year"/"$obs_id"
		dmcopy infile=""$evtfile"[sky=region("$source_phy")]" outfile=source_1as.evt clobber=yes
		dmcopy infile=""$evtfile"[sky=region("$bkg_phy")]" outfile=background.evt clobber=yes
		cd ../../../"$year_data"/"$obs_id"/repro
		echo "Dmcopy done"
		orbitfile=$(find $(cd ../primary; pwd) -name 'orbit*')
		asolfile=$(find $PWD -name 'pcad*')
		statfile=$(find $PWD -name '*stat*.fits')
		echo "Orbit files extracted"
		#Getting RA, dec
		linenum=0
		while read line
		do
			(( linenum++ ))
			if [ "$linenum" = "2" ]; then
				ra_deg=0
				ra_min=${line:10:2}
				ra_sec=${line:14:5}
				echo ""$ra_deg" "$ra_min" "$ra_sec""
				ra=$(calc "$ra_deg"*15 + "$ra_min"/60*15 + "$ra_sec"/3600*15)
				if [ "${ra:1:1}" = "~" ]; then
					ra=${ra:2:10}
				fi
				if [ "${ra:0:1}" = " " ]; then
					ra=${ra:1:9}
				fi
				echo "RA="$ra""
				dec_deg=-72
				dec_min=${line:24:2}
				dec_sec=${line:27:5}
				dec=$(calc "$dec_min"*-1/60 - "$dec_sec"/3600 + "$dec_deg")
				if [ "${dec:1:1}" = "~" ]; then
					dec=${dec:2:10}
				fi
				if [ "${dec:0:1}" = " " ]; then
					dec=${dec:1:9}
				fi
				echo "Dec="$dec""
			fi
		done<$source_fk5
		echo "RA-dec extracted"
		#APPLYING BARYCENTRIC CORRECTION
		cd ../../../source/"$year"/"$obs_id"
		axbary source_1as.evt "$orbitfile" source_1as_bary.evt ra="$ra" dec="$dec" refframe=FK5 clobber=yes mode=h
		axbary background.evt "$orbitfile" bkg_bary.evt ra="$ra" dec="$dec" refframe=FK5 clobber=yes mode=h
		axbary "$asolfile" "$orbitfile" source_1as_bary.asol ra="$ra" dec="$dec" refframe=FK5 clobber=yes mode=h
		dmhedit source_1as_bary.evt file= op=add key=ASOLFILE value="source_1as_bary.asol"
		axbary "$statfile" "$orbitfile" source_1as_bary.expstats ra="$ra" dec="$dec" refframe=FK5 clobber=yes mode=h
		cd ../../../"$year_data"/
		pwd
	done
	cd ..
done
