#!/bin/bash

#SBATCH --account=hci-collab
#SBATCH --partition=hci-rw
#SBATCH -N 1
#SBATCH --job-name=somaticCoup                                          
#SBATCH -o slurm_std.out                                                    
#SBATCH --mail-user=preetida.bhetariya@utah.edu                                 
#SBATCH -e errorlog
#SBATCH -t 10:00:00

email=preetida.bhetariya@utah.edu


set -e; start=$(date +'%s')
echo -e "---------- Starting -------- $((($(date +'%s') - $start)/60)) min"

module load samtools 
module load bcftools


#bam=`ls *.bam` 
#echo $bam

#java -jar -Xmx100G ~/BioApps2/Picard/2.1.1/picard.jar AddOrReplaceReadGroups INPUT=$bam OUTPUT=rdGrp_$bam RGID=hci RGLB=hci RGSM=hci RGPL=illumina RGPU=1 CREATE_INDEX=true TMP_DIR=. VALIDATION_STRINGENCY=SILENT

#samtools index rdGrp_$bam

#ln -s rdGrp_$bam ctDNA.bam 
#ln -s rdGrp_$bam.bai ctDNA.bai 

#ln -s /scratch/mammoth/serial/u0944235/A5805/Alignments/15352X17/Bam/15352X17_Hg38_final.bam norm.bam
#ln -s /scratch/mammoth/serial/u0944235/A5805/Alignments/15352X17/Bam/15352X17_Hg38_final.bai norm.bai

#Job params
jobName=`basename $(pwd)`
tumorBam=`readlink -f ctDNA.bam`
normalBam=`readlink -f norm.bam`

#Hotspot settings
bed=/scratch/mammoth/serial/u0944235/A5805/VcfBedToInject/Bed

regionsForAnalysis=/scratch/mammoth/serial/u0944235/A5805/VcfBedToInject/Bed/HSV1_GBM_IDT_Probes_Hg38Pad150bps_91K.bed.gz
#mpileup=/uufs/chpc.utah.edu/common/home/u0944235/controlBKAF/samples/onlycfcontrol/FSbams/bkg.mpileup.gz
minTumorAlignmentDepth=100
minNormalAlignmentDepth=50

#regionsForAnalysis=/uufs/chpc.utah.edu/common/home/u0028003/Anno/B37/HunterKeith/HSV1_GBM_IDT_Probes_B37Pad25bps.bed
#mpileup=/uufs/chpc.utah.edu/common/home/u0944235/Pancreatic_SolidTumor/14543X1/VCFcalling/controls/Controls_FS5/FS5/bkg.mpileup.gz


#Exome settings
#regionsForAnalysis=/uufs/chpc.utah.edu/common/home/u0028003/Anno/B37/HunterKeith/b37_xgen_exome_targets_pad25.bed
#mpileup=/uufs/chpc.utah.edu/common/home/u0028003/Lu/Underhill/BkgrdNormals/Exome/20BamXgenExome.mpileup.gz
#minTumorAlignmentDepth=20
#minNormalAlignmentDepth=20

#General filter settings
minTumorAF=0.001
maxNormalAF=0.4
minTNRatio=1.2
minTNDiff=0.001
minZScore=4



#Set machine params
threads=`nproc`
memory=$(expr `free -g | grep -oP '\d+' | head -n 1` - 2)G
allRam=$(expr `free -g | grep -oP '\d+' | head -n 1` - 2)
echo "Threads: "$threads "  Memory: " $memory "  Host: " `hostname`; echo

# Print out a workflow
~/miniconda3/bin/snakemake --dag --snakefile *.sm --config name=$jobName rA=$regionsForAnalysis tBam=$tumorBam nBam=$normalBam  threads=$threads memory=$memory allRam=$allRam \
email=$email bed=$bed mpileup=$mpileup mtad=$minTumorAlignmentDepth mnad=$minNormalAlignmentDepth mtaf=$minTumorAF \
mnaf=$maxNormalAF mr=$minTNRatio md=$minTNDiff zscore=$minZScore | dot -Tsvg > $jobName"_dag.svg" 

#~/BioApps/SnakeMake/snakemake  --dag --snakefile *.sm  \
#--config name=$jobName rA=$regionsForAnalysis tBam=$tumorBam nBam=$normalBam  threads=$threads memory=$memory \
#email=$email mpileup=$mpileup mtad=$minTumorAlignmentDepth mnad=$minNormalAlignmentDepth mtaf=$minTumorAF \
#mnaf=$maxNormalAF mr=$minTNRatio md=$minTNDiff zscore=$minZScore \
#| dot -Tsvg > $jobName"_dag.svg"

# Launch it
~/miniconda3/bin/snakemake -p -T --cores $threads --snakefile *.sm \
--config name=$jobName rA=$regionsForAnalysis tBam=$tumorBam nBam=$normalBam  threads=$threads memory=$memory allRam=$allRam \
email=$email bed=$bed mpileup=$mpileup mtad=$minTumorAlignmentDepth mnad=$minNormalAlignmentDepth mtaf=$minTumorAF \
mnaf=$maxNormalAF mr=$minTNRatio md=$minTNDiff zscore=$minZScore --latency-wait 30

# Cleanup
mkdir -p Raw Txt Filt Log;
gzip *.log
mv -f *.log.gz Log/
mv -f *.raw.* Raw/
mv -f *.txt.gz Txt/
mv -f *.filt.* Filt/
mv -f Filt/*_Consensus* .
rm -rf snappy* .snakemake


echo -e "\n---------- Complete! -------- $((($(date +'%s') - $start)/60)) min total"





