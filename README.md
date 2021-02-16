# NET-evaluation
This package is for network evaluation with two methods: (1) binding data, and (2) Gene Ontology analysis. The easiest way to run this package is through our provided singularity container, that can be downloaded [here](http:/). With the singularity container, no need to install any more packages as we have already installed all required packages in the container. 

# Method 1: The easiet, via Singularity
## 1. Install Singularity
Refer to the singularity [website](https://singularity.lbl.gov/install-linux) to install singularity 2.4 or higher.
## 2. Download singularity container from [here]()
## 3. Run go command for GO enrichment analysis
- For information/help  about the arguments of go command:

`$ go -h`

- To Run the command, refer to this toy example once singularity is installed & sinuglarity container is downloaded :

`$ cd /path/singularity/container`

`$ /path/singularity/container/home/evaluate_net/go --p_net /home/data/zev.tsv --flag_singularity ON --p_singularity_img /path/singularity/container --p_eval /home/output/zev_go.tsv ` 

# Method 2: The more advanced, via installing all required dependencing
## 1. Install required packages
## 2. Run go command for GO enrichment analysis
