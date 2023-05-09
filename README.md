# Datasets from Instructions (D<small>INO</small> 🦕)

This repository was branched from the code for [Generating Datasets with Pretrained Language Models](https://arxiv.org/abs/2104.07540). We provided additional experiemnts on their code for the final project assignment for COS 484 at Princeton University in Spring 2023.

## 🔧 Setup

All requirements for D<small>INO</small> can be found in ``requirements.txt``. You can install all required packages in a new environment with ``pip install -r requirements.txt``.

## 💬 CLI Usage

#### Single Texts
To generate datasets for (single) text classification, you can use D<small>INO</small> as follows:
````
python3 dino.py \
 --output_dir <OUTPUT_DIR> \
 --task_file <TASK_FILE> \
 --num_entries_per_label <N> \
 --batch_size 1
````
where ``<OUTPUT_DIR>`` is a directory to which the generated dataset is written, ``<TASK_FILE>`` is a JSON file containing a *task specification* (see [Task Specs](#-task-specs)), and ``<N>`` is the number of examples to generate per label. To get an overview of additional parameters, run ``python3 dino.py --help``.

#### Text Pairs
To generate datasets for text pair classification, you first need a dataset of raw input texts (which you can also generate using D<small>INO</small>). You can then run
````
python3 dino.py \
 --output_dir <OUTPUT_DIR> \
 --task_file <TASK_FILE> \
 --input_file <INPUT_FILE> \
 --input_file_type <INPUT_FILE_TYPE> \
 --num_entries_per_input_and_label <N>
````
with ``<OUTPUT_DIR>`` and ``<TASK_FILE>`` as before. ``<INPUT_FILE>`` refers to the file containing raw input texts, ``<INPUT_FILE_TYPE>`` specifies its type, which should be one of

   - ``plain``: for a plain text file with one input text per line
   - ``jsonl``: for a dataset file generated by D<small>INO</small> in a previous step

and ``<N>`` is the number of examples to generate per label and input text.

## 📋 Task Specs

🚨 *Before you write custom task specifications, please note that this is still a very early release and we have not tested D<small>INO</small> on other tasks than semantic textual similarity yet. Please let us know if you see something strange.* 🚨

To generate a dataset for a task, you need to provide a file containing a *task specification*, containing (among other things) the instructions given to the pretrained language model. A task specification is a single JSON object that looks like this:

```
{
  "task_name": "<TASK_NAME>",
  "labels": {
    "<LABEL_1>": {
      "instruction": "<INSTRUCTION_1>",
      "counter_labels": [<COUNTER_LABELS_1>]
    },

    ...,

    "<LABEL_n>": {
      "instruction": "<INSTRUCTION_n>",
      "counter_labels": [<COUNTER_LABELS_n>]
    }
  }
}
```
Here, ``<TASK_NAME>`` is the name for the task and ``<LABEL_1>``, ..., ``<LABEL_n>`` are the task's labels. For each label ``<LABEL_i>``, ``<INSTRUCTION_i>`` is the instruction provided to the language model for generating examples with label `<LABEL_i>` (see [Writing Instructions](#writing-instructions)). You can additionally specify a list of counter labels ``<COUNTER_LABELS_n>`` for each label. This tells the model to generate outputs that are not only likely given the current label, but also unlikely given all counter labels (see [the paper](https://arxiv.org/abs/2104.07540) for details).

#### Examples

You can find two examples of task specifications in ``/task_specs``:

- ``sts.json`` is a task specification for generating a semantic textual similarity dataset if *a set of raw input texts is already given*.
- ``sts-x1.json`` is a task specification for generating a set of raw input texts. This set can then be used in a subsequent step to generate a full STS dataset using ``sts.json``.

#### Writing Instructions

When writing instructions for a new task, you should consider the following things:

- Always end your instructions with an (opening) **quotation mark** (`"`). This is required because it allows us to interpret the next quotation mark generated by the language model as a signal that it is done generating an example.
- For good results, keep the instructions as **short and simple** as possible as this makes it easier for a pretrained language model to understand them.
- If you are writing instructions for a text **pair** classification task, make sure that each instruction contains the placeholder ``<X1>`` exactly once. At this position, the provided raw input sentences are inserted during generation.

An example for an instruction that prompts the model to generate a positive review for a restaurant would be:
````
Task: Write a review for a really great restaurant.
Review: "
````

An example for an instruction that prompts the model to generate a sentence that has the same meaning as another given sentence would be:
````
Task: Write two sentences that mean the same thing.
Sentence 1: "<X1>"
Sentence 2: "
````

## 🦕 Generated D<small>INO</small>s

This section lists datasets that we used as our model datasets as we attempt to reproduce baseline results.

| Dataset | Description | Link |
| :------ | :---------- | :--- |
| STS&#8209;🦕&#8209;x<sub>2</sub>&nbsp;(pp) | A postprocessed version of STS-🦕-x<sub>2</sub>. Postprocessing includes label smoothing, data augmentation and selecting at most two x<sub>2</sub>'s for each (x<sub>1</sub>, y) and is performed <a href="https://github.com/timoschick/dino/blob/fce28bc331fd07887c5e1a41d9ad781c4a9e207b/scripts/sts/postprocess_dataset.py">using this script</a>. | [📥&nbsp;Download](https://www.cis.uni-muenchen.de/~schickt/dino/sts-dino-x2-postprocessed.jsonl) |
| STS&#8209;🦕&#8209;x<sub>1</sub>x<sub>2</sub>&nbsp;(pp)   | A postprocessed version of STS-🦕-x<sub>1</sub>x<sub>2</sub>. Postprocessing includes label smoothing, data augmentation and selecting at most two x<sub>2</sub>'s for each (x<sub>1</sub>, y) and is performed <a href="https://github.com/timoschick/dino/blob/fce28bc331fd07887c5e1a41d9ad781c4a9e207b/scripts/sts/postprocess_dataset.py">using this script</a>. | [📥&nbsp;Download](https://www.cis.uni-muenchen.de/~schickt/dino/sts-dino-x1x2-postprocessed.jsonl) |
| STS&#8209;🦕&#8209;x<sub>2</sub>&nbsp;(raw) | A semantic textual similarity dataset generated with DINO, where the first text for each pair (x<sub>1</sub>, x<sub>2</sub>) is from the STS benchmark. For almost all use cases, you probably want to use the postprocessed (pp) version of this dataset. | [📥&nbsp;Download](https://www.cis.uni-muenchen.de/~schickt/dino/sts-dino-x2.jsonl) |
| STS&#8209;🦕&#8209;x<sub>1</sub>x<sub>2</sub>&nbsp;(raw) | A semantic textual similarity dataset generated with DINO, where each pair (x<sub>1</sub>, x<sub>2</sub>) is generated from scratch. For almost all use cases, you probably want to use the postprocessed (pp) version of this dataset. | [📥&nbsp;Download](https://www.cis.uni-muenchen.de/~schickt/dino/sts-dino-x1x2.jsonl) |

## 📕 Citation

We heavily adapt our code from the paper provided below:
````
@article{schick2020generating,
  title={Generating Datasets with Pretrained Language Models},
  author={Timo Schick and Hinrich Schütze},
  journal={Computing Research Repository},
  volume={arXiv:2104.07540},
  url={https://arxiv.org/abs/2104.07540},
  year={2021}
}
````
