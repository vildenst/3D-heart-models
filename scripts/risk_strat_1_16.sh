#!/bin/bash -l

#SBATCH --job-name=pat6
#SBATCH --account=nn9249k
#SBATCH --time=24:00:00
#SBATCH --ntasks=24
#SBATCH --mem-per-cpu=4G

#SBATCH --output=out.txt
#SBATCH --error=err.txt

module purge
source /cluster/bin/jobsetup
#module load openmpi.gnu
module load openmpi.intel/1.7

MPIRUN=mpirun

CARP=/usit/abel/u1/mmaleck/nobackup/carp/1.8.1/bin/carp

s1_bcl=350                                     # S1 basic cycle length
num_bcl=5                                      # number of S1 pulses
s2_init=200                                    # Initial guess for shortest s1-s2 interval
s3_init=250                                    # Initial guess for shortest s2-s3 interval
s4_init=250
#s5_init=400
#s6_init=400
model=`basename *pts .pts`                            # base name of mesh file
reentry_duration=1000                          # How long to run simulation when reentry is detected (ms after last stimulus)

base_par=base.par   # location and name of base parameter file

stim_file=stim_coord.dat                       # filename containing list of stimulus coordinates or nodes
#stim_site_begin=1
#stim_site_end=1

####################################################################
#
# You don't need to change anything else below
# Edit at your own risk
#
####################################################################


####### CARP Command Options #######################################

com_base='$MPIRUN $CARP +F $base_par -simID $dir -tend $end -meshname $model -spacedt 10 -t_sentinel $sentinel ' 
com_stim='-num_stim 1 -stimulus[0].start $stim_start -stimulus[0].duration 10 -stimulus[0].strength 100 -stimulus[0].x0 ${x[0]} -stimulus[0].xd 1000 -stimulus[0].y0 ${x[1]} -stimulus[0].yd 1000 -stimulus[0].z0 ${x[2]} -stimulus[0].zd 1000 -stimulus[0].stimtype 0 '
com_s1='-stimulus[0].npls $num_bcl -stimulus[0].bcl $s1_bcl -chkpt_intv $s1_bcl ' 
com_restart='-start_statef $restart '
com_tsav='-num_tsav 6 -tsav[0] ${save[0]} -tsav[1] ${save[1]} -tsav[2] ${save[2]} -tsav[3] ${save[3]} -tsav[4]  ${save[4]} -tsav[5] ${save[5]} '

####### Functions ##################################################

func.restart ()              # This function will automatically find the closest restart file below time=$2 in folder=$1
{   
    if (($2=="$end"))
    then
	restart_dir=`ls -t $dir*/{check*,state*} 2> /dev/null | head -n 1 | awk -F"/" '{print $2}'`
	restart_time=`ls -t $dir*/{check*,state*} 2> /dev/null | head -n 1 | awk -F"/" '{print $NF}' | awk -F"." '{print $2}'`
	mv $site/$restart_dir "$dir"_"$restart_time"
	restart=`ls -t "$dir"_"$restart_time"/{check*,state*} 2> /dev/null | head -n 1 | sed 's/.gz//'`
	if (("$restart_time">"$end")); then status=Success; fi 
    fi

    if (($2=="$stim_start"))
    then
	restart_times=(`ls -t "$1"*/{check*,state*} 2> /dev/null | awk -F"/" '{print $NF}' | awk -F"." '{print $2}' | sort -gr`)
	for i in ${restart_times[@]} 
	do 
	    temp=$(($i-$2)) 
	    if (($temp <= 0))
	    then
		restart_time=$i
		restart_dir=`ls -t "$1"*/*"$restart_time"* 2> /dev/null | head -n 1 | awk -F"/" '{print $2}' `
		temp_dir=`grep -w simID $site/$restart_dir/parameters.par | awk '{for(i=1;i<NF;i++)if($i~/-simID/) print $(i+1)}' | awk -F"/" '{print $NF}'`
		latest_time=`ls -t $site/$restart_dir/{check*,state*} 2> /dev/null | head -n 1 | awk -F"/" '{print $NF}' | awk -F"." '{print $2}'`
		mv $site/$restart_dir $site/"$temp_dir"_"$latest_time" &> /dev/null
		restart=`ls -t $site/"$temp_dir"_"$latest_time"/*"$restart_time"* 2> /dev/null | head -n 1 | sed 's/.gz//'`
		break
	    fi
	done
    fi
}   

func.find.last.restart ()
{
    restart_times=(`ls -t "$last_dir"*/{check*,state*} 2> /dev/null | awk -F"/" '{print $NF}' | awk -F"." '{print $2}' | sort -g`)
    for i in ${restart_times[@]} 
    do 
	temp=$(($i-$last_stim)) 
	if (($temp > 0))
	then
	    fail_stim=$i
	    break
	fi
    done
    echo "Earliest $extra for which restart file is available is $extra=$fail_stim" >> $out
}

func.check.status ()           # Check to see if particular simulation was already run successfully or prematurely aborted. 
{      
    temp=(`ls -d $dir* `)
    if [ ! -d ${temp[0]} ]     # Case when simulation has not been run. 
    then
	status=New
    else
	if ( ls -t $dir*/check* &> /dev/null ) || ( ls -t $dir*/state* &> /dev/null )  || ( ls -t $dir*/saved* &> /dev/null ) # Restart files exists. 
	then
	    if ( ls -t $dir*/checkpoint.$end.0.gz &> /dev/null ) || ( ls -t $dir*/state.$end.0.gz &> /dev/null )  || ( ls -t $dir*/saved* &> /dev/null )  # Restart file at time=$end already exists. 
	    then                                                                                                                                          # Means simulation already successfully finished.
		status=Success                                                                                                                            # Will skip to the next step.
	    else
		status=Restart                                                                                          # Simulation was prematurely aborted. 
		func.restart "$dir" "$end"                                                                              # Find latest restart file available and continue simulation from that point
	    fi
	else
	    status=New
	fi
    fi
}

func.run.sim ()
{
    # The following loop determines tsav timepoints. I picked 100ms after last stimulus and then a few more after that at 50ms intervals.   
    # I use the different tsav when finding the shortest s1-s2 or s2-s3 interval. It's a time saving trick.
    for ((a=0;a<=3;a++)); do save[$a]=`echo "$last_stim+100+($a+1)*50" | bc -l | awk -F"." '{print $1}'`; done
    save[4]=$save1
    save[5]=$end

    for ((a=0;a<=5;a++));
    do
        if [ "${save[$a]}" -le "$restart_time" ]; then save[$a]=$end; fi;   # For old versions of CARP, tsav can't be below simulation start
        if [ "${save[$a]}" -gt "$end" ]; then save[$a]=$end; fi;            # For old versions of CARP, tsav can't be beyond tend
    done

    save=($(printf '%s\n' "${save[@]}"|sort -u))                            # For old versions of CARP, tsav has to be in ascending order 

    for ((a=0;a<=5;a++));                                                   # In case there are less than 5 save points, pad the rest with end    
    do
        if [ ! ${save[$a]} ]; then save[$a]=$end; fi;
    done

    if [[ $status == 'New' ]]
    then
	mkdir $dir
	if [[ "$dir" == "$site/s1" ]]
	then
	    echo "Running $dir" >> $out
	    command=`echo $com_base $com_stim $com_s1 $com_tsav | sed 's|-spacedt\ 10|-spacedt\ 50|'`
	else
	    echo "Running $dir and restarting from $restart" >> $out    
	    command=`echo $com_base $com_stim $com_restart $com_tsav`
	fi
	eval eval $command >& $dir/logfile 
	if ( ls -t $dir*/checkpoint.$end.0.gz &> /dev/null ) || ( ls -t $dir*/state.$end.0.gz &> /dev/null ) || ( ls -t $dir*/saved* &> /dev/null ) ; then status=Success; else status=Fail; fi
    fi
    
    if [[ $status == 'Restart' ]]
    then
	mkdir $dir
	echo "Continuing $dir from $restart" >> $out
	if [ "$dir" == "$site/s1" ]
	then
	    command=`echo $com_base $com_stim $com_s1 $com_restart $com_tsav | sed 's|-spacedt\ 10|-spacedt\ 50|'`
	else
 	    command=`echo $com_base $com_stim $com_restart $com_tsav `
	fi
	eval eval $command >& $dir/logfile
	if ( ls -t $dir*/checkpoint.$end.0.gz &> /dev/null ) || ( ls -t $dir*/state.$end.0.gz &> /dev/null ) || ( ls -t $dir*/saved* &> /dev/null ) ; then status=Success; else status=Fail; fi
    fi
}

func.check.propagation ()
{
    if [[ $status == 'Success' ]]                                                              
    then
	ref_time2=(`grep -w ^"$ref_node" $dir*/vm_act-thresh.dat | awk '{print $2}'`)
	if [ ${ref_time2[0]} ]
	then
	    status1=-1
	    echo "$dir Propagated ${ref_time2[@]}" >> $out
	    prop_stim=$stim_start
	else
	    status1=1
	    echo "$dir Failed" >> $out
	    fail_stim=$stim_start             #Simulation will not go below this value
	fi
    fi
}

func.check.reentry ()
{
    if [[ $status == 'Success' ]]                                                             
    then
	ref_time2=(`grep -w ^"$ref_node" $dir*/vm_act-thresh.dat | awk '{print $2}' | sort -g`)
	if (( "${#ref_time2[@]}" > 1 ))
	    then
            # If activated more than once, check to make sure that it is >25 ms between activation times.                                                                                                     
            # Sometimes, the same node is recorded as activating more than once in the same action potential.                                                                                                  
            # I think it is an error when there are notches in the AP (either due to numerical error or weird AP morphology).                                                                                  
	    for ((i=1;i<"${#ref_time2[@]}";i++))
	      do
	      dif[$i]=`echo "${ref_time2[$i]}-${ref_time2[$i-1]}" | bc -l | awk -F"." '{print $1}'`
	      if (( "${dif[$i]}" > 25 ))
		  then
		  lower_bound=$stim_start
		  reentry_status=yes
	      fi
	    done
	fi
	
	last_act=(`tail -q -n 1 $dir*/vm_act-thresh.dat | awk '{print $2}' | sort -gr`)
        if [[ ${last_act[0]} < $(($end-2)) ]]
	    then
            if [[ $reentry_status == 'yes' ]]
		then
                echo "$dir Unsustained Reentry ${ref_time2[@]}" >> $out
                echo "Last activation occured at ${last_act[0]}" >> $out
                reentry_status=unsustained
            else
                echo "$dir No Reentry" >> $out
                reentry_status=no
            fi
	fi
    fi
    
    #if [[ $status == 'Restart' ]]
    #then
#	last_act=(`tail -q -n 1 $dir*/vm_act-thresh.dat | awk '{print $2}' | sort -gr`)
	#if [[ ${last_act[0]} < $(($restart_time-2)) ]]
	 #   then

}

####### End Functions ####################################

####### Start of Simulations #############################

if ! (($stim_site_begin))
then
    stim_site_begin=1
    stim_site_end=`wc $stim_file | awk '{print $1}'`
fi

for j in $(eval echo {$stim_site_begin..$stim_site_end})    #cycle through nodes in stim_coord.dat row by row
do

    site=site$j            #create site folder 
    mkdir $site &> /dev/null

    #### Determine the stimulus coordinates ########

    num_rows=`awk '{print NF}' $stim_file  | head -n 1`
    if(("$num_rows"==1))
    then
	node=`awk -v i=$j 'NR==i{print}' $stim_file`   
	x[0]=`awk -v i="$node" 'NR==(i+2){print $1}' $model.pts`
        x[1]=`awk -v i="$node" 'NR==(i+2){print $2}' $model.pts`
        x[2]=`awk -v i="$node" 'NR==(i+2){print $3}' $model.pts`
	x[0]=`echo "${x[0]}-500" | bc -l`
        x[1]=`echo "${x[1]}-500" | bc -l`
        x[2]=`echo "${x[2]}-500" | bc -l`
    else
	x=(`awk -v i=$j 'NR==i{print}' $stim_file`)
    fi
    
    # Check to see if there is a hold file. Means that there is already a process running.
    
    if test `find $site/hold -mmin -720`
    then
	continue
    else
	echo "Simulation started at" `date '+%D %H:%M'`". This hold file will prevent writing to this folder until" `date -d+720minutes '+%D %H:%M'`". Delete this hold file to override." > $site/hold 
    fi

    ########## Test Stimulus #################################################################################
    # For new stimulus sites only. Runs a 10 ms simulation to make sure that stim site and parameters are OK #           
    ##########################################################################################################

    dir=$site/s1
    end=10
    stim_start=0
    out=$site/status
    restart_time=0
	
    func.check.status

    date '+%D %H:%M' > $out
    echo -e "\n#################### s1 ####################\n" >> $out

    if [[ $status == 'New' ]]
    then
	dir=$site/test
	mkdir $dir
	echo 'Running stimulus check' >> $out
	sentinel=5
	command=`echo $com_base $com_stim`
	eval $command >& $dir/logfile
	if [ -f $dir/vm_act-thresh.dat ]
	then
	    last_act=`tail -n 1 $dir/vm_act-thresh.dat | awk '{print $2*10}' | awk -F"." '{print $1}'`
	    if (($last_act < 95))
	    then
		echo "Error - Stimulus not capturing. Check stimulus strength and location." >> $out
		rm $site/hold
		continue
	    else
		echo "Stimulus check - OK" >> $out
	    fi
	else
	    echo "Error - Check parameters" >> $out
	    rm $site/hold
	    continue 
	fi
    fi
    
    ########## Start of S1 Pacing ##########    

    dir=$site/s1
    end=$[($num_bcl-1)*$s1_bcl+$s2_init]
    stim_start=0
    last_stim=$[($num_bcl-1)*$s1_bcl] # Time of last s1 stimulus
    save1=$[$last_stim+$s2_init]
    sentinel=$s1_bcl

    func.check.status           # Check Status
    func.run.sim                # Run the simulation
    
    # Determine reference node which is used to detect stimulus success/failure/reentry. We're using the 10000th node that gets activated as reference node.  
    s1_act=`ls -t $dir*/vm_act* | tail -n 1`
    ref_node=`head -n 10000 $s1_act | tail -n 1 | awk '{print $1}'`     
    if ! (($ref_node))
    then
	echo "Error: Reference node cannot be found. Check vm_act-thresh.dat in $dir." >> $out
	continue
    else
	echo "Reference node is $ref_node" >> $out
    fi

    func.check.propagation # Output the times ref_node is activated
    ref_time=`echo ${ref_time2[0]} | awk -F"." '{print $1} '`

    # The following variables are needed for the s2 simulation
    
    last_dir=$dir                     # s1 directory 
    
    echo -e "\n############################################\n" >> $out

    ########## S2 and S3 Pacing Routines ##########
    
    for extra in s2 s3 s4 
    do
	if [[ $status != 'Success' ]]              # Check to make sure that previous simulation successfully finished
	then
	    echo -e "\n#################### $extra ####################\n" >> $out
	    echo "Error - Previous stimulus did not successfully complete" >> $out
	    rm $site/hold
	    break
	else
	    echo -e "\n#################### $extra ####################\n" >> $out
	    echo "Previous stimulus was delivered at $last_stim" >> $out
	fi

	func.find.last.restart
	
	init="$extra"_init
	stim_start=$[$last_stim+${!init}]

	if [[ "$stim_start" -lt "$fail_stim" ]]
	then
	    stim_start=$fail_stim
	fi
	
	end_add=`echo "$ref_time*10" | bc -l | awk -F"." '{print $1}'`
        if (($end_add > 200)); then end_add=200; fi;	
	if (($end_add < 50)); then end_add=50; fi;

	end=`echo "$stim_start+$end_add" | bc -l | awk -F"." '{print $1}'`
	save1=$[$stim_start+$s3_init]; if [[ "$save1" > "$end" ]]; then save1=$end; fi
	dir=$site/"$extra"_$stim_start
	sentinel=$s1_bcl

	func.restart "$last_dir" "$stim_start"
	func.check.status
	func.run.sim 
	func.check.propagation
	status2=$status1

	interval=(50 10)
	k_max=`echo "${#interval[@]}-1" | bc -l`
	k=0
	loop_iteration=0	

	loop=begin
	while [ $k -le $k_max ]
	do
	    if [[ $status == 'Success' ]]
	    then
		stim_start=$[$stim_start+($status1*${interval[$k]})]

		if [[ "$stim_start" -lt "$fail_stim" ]]
		then
		    stim_start=$[$stim_start-($status1*${interval[$k]})]
		    k=$[$k+1]
		    continue
		fi
		end=`echo "$stim_start+$end_add" | bc -l | awk -F"." '{print $1}'`
		save1=$[$stim_start+$s3_init]; if [[ "$save1" > "$end" ]]; then save1=$end; fi
		dir=$site/"$extra"_$stim_start
		sentinel=$s1_bcl

		func.restart "$last_dir" "$stim_start"
		func.check.status
		func.run.sim 
		func.check.propagation
		loop_iteration=$[$loop_iteration+1]
		echo $dir $loop_iteration
		if [[ $loop_iteration > 6 ]]
		then
		    status=Fail
		    echo "$extra error. Too many iterations with failed stimulus. Check simulations and stimulus site. Might need stronger stimulus or stimulus might need to be moved." >> $out
                    eval echo $command >> $out
                    rm $site/hold
                    break
		fi
	      
		if [[ $status1 != $status2 ]]
		then
		    if [[ $k == $k_max ]]
		    then
			last_stim=$prop_stim
			echo "Last successful $extra was at $last_stim" >> $out
			loop=end
			break
		    else
			k=$[$k+1]
			loop_iteration=0
			status2=$status1
		    fi
		fi
	    fi

	    if [[ $status == 'Fail' ]]
	    then
		echo "$extra Error" >> $out
		eval echo $command >> $out
		rm $site/hold
		break
	    fi
	done

	if [[ $loop == 'begin' ]]
	then
	    echo "Error: Last $extra was not found." >> $out
	    status=Fail
	    rm $site/hold
	    break
	else
	# Run simulation longer to check for reentry
	    if [[ $status == 'Success' ]]
	    then
		stim_start=$last_stim
		dir=$site/"$extra"_$stim_start
		save1=$[$stim_start+$s3_init]
		last_dir=$dir
		end=`echo "$stim_start+$reentry_duration" | bc -l | awk -F"." '{print $1}'`
		
		reentry_status=undetermined
		sentinel=10
		
		func.check.status
		func.run.sim 
		func.check.reentry
	    fi
	fi
	
	if [[ $reentry_status == 'yes' ]]
	then
	    echo "$dir Reentry ${ref_time2[@]}" >> $out
	    echo "Lower Bound = $stim_start" >> $out
	    k=0
	    status1=1
	    status2=1
	    break
	fi

	if [[ $reentry_status == 'unsustained' ]]
	then
	    k=0
	    status1=1
	    status2=1
	    break
	fi

	echo -e "\n############################################\n" >> $out
	
    done
    rm $site/hold

done

