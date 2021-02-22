# NET-evaluation
This package is for network evaluation with: (1) binding data, and (2) Gene Ontology analysis. The easiest way to run this package is with **singularity container**. Singularity makes it super easy, no need to install any more packages once singularity is installed on your computer. Follow steps below for running our package with singularity.  

# I. The easiet, with Singularity container
## 1. Install Singularity
Refer to Singularity [website](https://singularity.lbl.gov/install-linux) to install singularity 2.4 or higher.
## 2. Download singularity container from [here]()
## 3. Run network evaluation
### 3.1 GO enrichement analysis
- For info & help about the command:

`$ /path/of/singularity/container/home/NET-evaluate/evaluate_with_go -h`

- To run the command, you can start with this toy example:

`$ /path/of/singularity/container/home/NET-evaluation/evaluate_with_go --p_net /path/of/singularity/container/home/toy_example/zev.tsv --p_singularity_img /path/of/singularity/container --p_singularity_bindpath /path/of/output/directory/ --p_eval /path/of/output/directory/zev_go.tsv ` 
### 3.2 With Binding data
- For info & help about the command:

`$ /path/of/singularity/container/home/NET-evaluate_with_binding -h`

- To run the command, you can start with this toy example:

`$ /path/of/singularity/container/home/NET-evaluation/evaluate_with_binding --p_net /path/of/singularity/container/home/toy_example/zev.tsv --p_singularity_img /path/of/singularity/container/ --p_singularity_bindpath /path/of/output/directory/ --p_eval /path/of/output/directory/zev_binding.tsv`

# II. More advanced, install all dependencies
## 1. Install required packages
### 1.1 Install R and depedencies
`R>=3.4.4`, refer to [this](https://www.datacamp.com/community/tutorials/installing-R-windows-mac-ubuntu) tutorial on how to install R

Once R is installed, install required packages, run:

`$ R`

`install.packages("WebGestaltR")`

`install.packages("rjson")`

`install.packages("optparse")`

### 1.2 Install python and dependencies
'Anaconda 3, refer to anaconda [website](https://docs.anaconda.com/anaconda/install/) on how to install anaconda

Once anaconda 3 is installed, run:

`$ conda create -n np3 python=3.7 pandas`

`$ conda activate np3`

## 2. Run netowrk evaluation
### 2.1 GO enrichement analysis
- For info & help about the command:

`$ /path/of/code/NET-evaluate/evaluate_with_go -h`

- To run the command, you can start with this toy example:

`$ /path/of/code/NET-evaluation/evaluate_with_go --p_net /path/of/code/NET-evaluation/toy_example/zev.tsv --flag_singularity OFF --p_eval /path/of/output/directory/zev_go.tsv ` 
### 2.2 With Binding data
- For info & help about the command:

`$ /path/of/singularity/container/home/NET-evaluate_with_binding -h`

- To run the command, you can start with this toy example:

`$ /path/of/code/NET-evaluation/evaluate_with_binding --p_net /path/of/code/NET-evaluation/toy_example/zev.tsv --flag_singularity OFF --p_eval /path/of/output/directory/zev_binding.tsv`
