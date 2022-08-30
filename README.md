# NET-evaluation
A package for network evaluation, we provide three independent evaluation metrics: (1) binding, (2a) Gene Ontology (GO), (2b) GO-directness, and (3) PPI. For a detailed description of the metrics, please refer to our NetProphet3 paper [to provide the link once published]. The easiest way to run this package is with the **singularity container** provided below. The advantage of the container is that there is no need for installing any dependency software except for the singularity software itself. Otherwise, users can still run this package the old way by installing all dependencies (which can be tedious).  

# I. The easiet, with the Singularity container
## 1. Install Singularity and download the container
- Refer to Singularity [website](https://singularity.lbl.gov/install-linux) to install singularity >= 3.6.2
- Download singularity container [to check instructions in NP3 package page]

## 2. Clone NET-evaluation repository
`git clone [find url]`

## 3. Run Commands
There are four different evaluation commands for (1) binding, (2) GO, (3) GO-directness and (4) PPI. There is a sample code for running each of the commands in `toy_example/run.sh`. Below, only the binding command is explained thouroughly, but the other commands follow the same principles.
### the binding command:

`p_src_code="/path/of/code/that/was/cloned/from/directroy/"`
`p_singularity_img="/path/of/singularity/container/"`

- For info & help about the command:

`$ ${p_src_code}binding -h`

- For running the command:

```
$ ${p_src_code}binding \
    --p_in_net '${p_src_code}toy_example/zev.tsv' \
    --p_binding_event ${p_src_code}metadata/yeast/reg_target \
    --
```
    
    /zev.tsv --p_singularity_img /path/of/singularity/container --p_singularity_bindpath /path/of/output/directory/ --p_eval /path/of/output/directory/zev_go.tsv ` 
### Binding data
- For info & help about the command:

`$ /path/of/singularity/container/home/NET-evaluate_with_binding -h`

- To run the command, you can start with this toy example:

`$ /path/of/singularity/container/home/NET-evaluation/evaluate_with_binding --p_net /path/of/singularity/container/home/toy_example/zev.tsv --p_singularity_img /path/of/singularity/container/ --p_singularity_bindpath /path/of/output/directory/ --p_eval /path/of/output/directory/zev_binding.tsv`

# II. More advanced, install all dependencies
## 1. Install required packages
### Install R and depedencies
`R>=3.4.4`, refer to [this](https://www.datacamp.com/community/tutorials/installing-R-windows-mac-ubuntu) tutorial on how to install R

Once R is installed, install required packages, run:

`$ R`

`install.packages("WebGestaltR")`

`install.packages("rjson")`

`install.packages("optparse")`

### Install python and dependencies
To install python via Anaconda 3, refer to anaconda [website](https://docs.anaconda.com/anaconda/install/) on how to install anaconda

Once anaconda 3 is installed, run:

`$ conda create -n neteval python=3.7 pandas`

`$ conda activate neteval`

## 2. Run Commands
### GO enrichement analysis
- For info & help about the command:

`$ /path/of/code/NET-evaluate/evaluate_with_go -h`

- To run the command, you can start with this toy example:

`$ /path/of/code/NET-evaluation/evaluate_with_go --p_net /path/of/code/NET-evaluation/toy_example/zev.tsv --flag_singularity OFF --p_eval /path/of/output/directory/zev_go.tsv ` 
### With Binding data
- For info & help about the command:

`$ /path/of/code/NET-evaluation/evaluate_with_binding -h`

- To run the command, you can start with this toy example:

`$ /path/of/code/NET-evaluation/evaluate_with_binding --p_net /path/of/code/NET-evaluation/toy_example/zev.tsv --flag_singularity OFF --p_eval /path/of/output/directory/zev_binding.tsv`
