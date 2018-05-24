
GlRuleFibers=GlRuleFibers
par_folder=/mnt/hgfs/par_files
model=$1

###############################################

#Start calculating fiber orientation

carpentry +F $par_folder/l_ab.par -meshname "$model" >> fibers.log
carpentry +F $par_folder/l_epi.par -meshname "$model" >> fibers.log
carpentry +F $par_folder/l_lv.par -meshname "$model" >> fibers.log
carpentry +F $par_folder/l_rv.par -meshname "$model" >> fibers.log

datasets="L_AB L_EPI_2 L_LV L_RV"
for i in $datasets
do
     cd $i
     igbextract -o ascii_1pL -O vm.tdat phie.igb>> fibers.log
     mv -f vm.tdat ../$i.dat
     cd ../
done

$GlRuleFibers -m "$model" -a L_AB.dat -e L_EPI_2.dat -l L_LV.dat -r L_RV.dat --alpha_endo 30 --alpha_epi 30 --beta_endo 40 --beta_epi 40 -o "$model"_done.lon>> fibers.log 


