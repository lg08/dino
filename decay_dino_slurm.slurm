#!/bin/bash
#SBATCH --job-name=dino-decay-lks           # create a short name for your job
#SBATCH --nodes=1                           # node count
#SBATCH --ntasks=1                          # total number of tasks across all nodes
#SBATCH --cpus-per-task=1                   # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=16G                   # memory per cpu-core (4G is default)
#SBATCH --gres=gpu:2		                # number of gpus per node
#SBATCH --time=24:00:00                     # total run time limit (HH:MM:SS)
#SBATCH --mail-type=begin                   # send email when job begins
#SBATCH --mail-type=end                     # send email when job ends
#SBATCH --mail-user=lgen@princeton.edu      # address to send emails to
#SBATCH --output=slurm_output/slurm-%j.out  # where to store the output file

module purge
module load anaconda3/2022.5
conda activate /scratch/network/lgen/dino_env

nvidia-smi
# Generate X1
python dino.py --output_dir output \
               --task_file task_specs/sts-x1-decay.json \
               --num_entries_per_label 3500 \
               --batch_size 128 \
               --top_p 0.9 \
               --top_k 0 \
               --remove_duplicates \
               --decay_constant 50
# Generate X1X2
python dino.py --output_dir output \
               --task_file task_specs/sts-x2-decay.json \
               --input_file output/sts-x1-decay-dataset.jsonl \
               --input_file_type jsonl \
               --num_entries_per_input_and_label 5 \
               --remove_duplicates \
               --remove_identical_pairs \
               --decay_constant 50
