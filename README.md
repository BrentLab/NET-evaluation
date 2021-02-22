# NET-evaluation
This package is for network evaluation with: (1) binding data, and (2) Gene Ontology analysis. The easiest way to run this package is with **singularity container**. Singularity makes it super easy, no need to install any more packages once singularity is installed on your computer. Follow steps below for running our package with singularity.  

# Method 1: The easiet
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

# Method 2: More advanced
## 1. Install required packages
`R>=3.4.4`, refer to [this](https://www.datacamp.com/community/tutorials/installing-R-windows-mac-ubuntu) tutorial for info about how to install R

`$ R`

`install.packages("WebGestaltR")`

`install.packages("rjson")`

`install.packages("optparse")`

## 2. Run netowrk evaluation
### 2.1 GO enrichment analysis
`$ /path/of/code/evaluate_with_go --p_net /path/of/network --flag_singularity OFF  --p_eval /home/output/zev_go.tsv ` 
