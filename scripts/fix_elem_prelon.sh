#USAGE: sh fix_elem_prelon.sh path/Patientname path/elemname

echo 2 > $1.lon; awk 'NR>1{print 1,0,0,0,1,0}' $2.elem >> $1.lon
