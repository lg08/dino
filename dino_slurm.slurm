#!/bin/bash
#SBATCH --job-name=dino-skl               # create a short name for your job
#SBATCH --nodes=1                         # node count
#SBATCH --ntasks=1                        # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                 # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=16G                 # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:2		              # number of gpus per node
#SBATCH --time=12:00:00                   # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin                 # send email when job begins
#SBATCH --mail-type=end                   # send email when job ends
#SBATCH --mail-user=smohr@princeton.edu
#SBATCH --output=slurm_output/slurm-%j.out             # where to store the output file

module purge
module load anaconda3/2022.5
conda activate /scratch/network/smohr/dino

nvidia-smi
# Generate X1
python dino.py --output_dir output \
               --task_file task_specs/sts-x1.json \
               --num_entries_per_label 5000 \
               --batch_size 64 \
               --top_p 0.9 \
               --top_k 0 \
               --remove_duplicates
# Generate X1-Small
python dino.py --output_dir output \
               --task_file task_specs/sts-x1-small.json \
               --num_entries_per_label 100 \
               --batch_size 64 \
               --top_p 0.9 \
               --top_k 0 \
               --remove_duplicates
# Generate X1X2-small
python dino.py --output_dir output \
               --task_file task_specs/sts-x2-small.json \
               --input_file output/sts-x1-small-dataset.jsonl \
               --input_file_type jsonl \
               --num_entries_per_input_and_label 1 \
               --remove_duplicates \
               --remove_identical_pairs

# Generate X1X2-
python dino.py --output_dir output \
               --task_file task_specs/sts-x2.json \
               --input_file output/sts-x1-dataset.jsonl \
               --input_file_type jsonl \
               --num_entries_per_input_and_label 1 \
               --remove_duplicates \
               --remove_identical_pairs
