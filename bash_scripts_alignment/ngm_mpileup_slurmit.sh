#!/bin/bash
#SBATCH --job-name=ngm_bbmap_mapping_job
#SBATCH --ntasks=1
#SBATCH --time=30:00
#SBATCH --mem=5120

module add bcftools

BAM="results/SRR5215282.fastq.gz.bam"

echo "sorted bam to mpileup\n"

samtools mpileup -f H3N2_flu.fasta results/SRR5215282.fastq.gz.bam.sort > SRR5215282.VAF

echo "\ndone!\n"








#/nas02/home/c/d/cdjones/bin/NextGenMap-0.5.0/bin/ngm-0.5.0/ngm -r /proj/cdjones_lab/cdjones/Deniz/target/dsim-all-chromosome-r2.02.fasta -q  /proj/cdjones_lab/cdjones/Deniz/raw_data/L3DSECH_1_S1_L001_R1_001.fastq -o  /proj/cdjones_lab/cdjones/Deniz/ngm_alignments/L3DSECH_1_S1_L001_R1_001.ngm.sam  --gap-read-penalty = 10 --gap-ref-penalty = 10 --kmer-min =  0


