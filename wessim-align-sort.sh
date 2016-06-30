#!/usr/bin/env bash

ORIGINAL_GENOME=$1      # used for alignment
GENOME_FILE=$2          # used as a reference for reads by wessim
TARGET_FILE=$3          # used as a target for reads by wessim
NUMBER_OF_READS=$4      # used for wessim
EXPERIMENT_NAME=$5      # used to name output files

CNV_HOME=$(pwd)
MODEL_FILE=$CNV_HOME'/input/models/ill100v4_p.gzip'

# Step 2 (WESSIM)
NUMBER_OF_THREADS=8
READ_LENGTH=100
OUTPUT_FILE=$CNV_HOME'/output/wessim_output/'$EXPERIMENT_NAME

cd $CNV_HOME
cd 2_wessim/Wessim/
python Wessim1.py -R $GENOME_FILE -B $TARGET_FILE -n $NUMBER_OF_READS -l $READ_LENGTH -M $MODEL_FILE -z -o $OUTPUT_FILE -t $NUMBER_OF_THREADS -p

# Step 3 (BWA)
NUMBER_OF_THREADS=4
INPUT_FILE_1=$CNV_HOME'/output/wessim_output/'$EXPERIMENT_NAME'_1.fastq.gz'
INPUT_FILE_2=$CNV_HOME'/output/wessim_output/'$EXPERIMENT_NAME'_2.fastq.gz'
OUTPUT_FILE=$CNV_HOME'/output/bwa_output/'$EXPERIMENT_NAME'.sam'

cd $CNV_HOME
cd 3_bwa_aligner/bwa/
# ./bwa index $ORIGINAL_GENOME
./bwa mem -t $NUMBER_OF_THREADS $ORIGINAL_GENOME $INPUT_FILE_1 $INPUT_FILE_2 > $OUTPUT_FILE

# Step 4 (SAMTOOLS)
INPUT_FILE=$CNV_HOME'/output/bwa_output/'$EXPERIMENT_NAME'.sam'
OUTPUT_FILE=$CNV_HOME'/output/samtools_output/'$EXPERIMENT_NAME'.sorted.sam'
TEMP_FILE=$CNV_HOME'/output/samtools_output/'$EXPERIMENT_NAME'.sort'

cd $CNV_HOME
samtools sort -O sam -T $TEMP_FILE -o $OUTPUT_FILE $INPUT_FILE
