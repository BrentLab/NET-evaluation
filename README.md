# NET-evaluation
This package is for network evaluation with two methods: (1) binding data, and (2) Gene Ontology analysis. The easiest way to run this package is through our provided singularity container, that can be downloaded [here](http:/). With the singularity container, no need to install any more packages as we have already installed all required packages in the container. 

# Method 1: The easiet, via Singularity
## 1. Install Singularity
Refer to Singularity [website](https://singularity.lbl.gov/install-linux) to install singularity 2.4 or higher.
## 2. Download singularity container from [here](https://www.dropbox.com/sh/04fnshj2stcgalt/AADjwy85iAD4HN_oYwZOLDCia?dl=0)
## 3. Run go command for GO enrichment analysis
- For info & help about the command of **go**:

`$ /path/of/singularity/container/home/NET-evaluate/go -h`

- To run the command of **go**, run this toy example once singularity is installed and the container is downloaded from the link above:

`$ /path/of/singularity/container/home/NET-evaluation/evaluate_with_go --p_net /home/toy_example/zev.tsv --flag_singularity ON --p_singularity_img /path/of/singularity/container --p_eval /home/toy_example/zev_go.tsv ` 

# Method 2: The more advanced, via installing all required dependencing
## 1. Install required packages
`R>=3.4.4`, refer to [this](https://www.datacamp.com/community/tutorials/installing-R-windows-mac-ubuntu) tutorial for info about how to install R

`$ R`

`install.packages("WebGestaltR")`

`install.packages("rjson")`

`install.packages("optparse"`

## 2. Run go command for GO enrichment analysis
`$ cd /path/of/code/`

`$ /path/of/code/go --p_net /path/of/network --flag_singularity OFF  --p_eval /home/output/zev_go.tsv ` 
