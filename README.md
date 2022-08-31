# NET-evaluation
A package for network evaluation, we provide three independent evaluation metrics: (1) binding, (2a) Gene Ontology (GO), (2b) GO-directness, and (3) PPI. For a detailed description of the metrics, please refer to our NetProphet3 paper [to provide the link once published]. The easiest way to run this package is with the **singularity container** provided below. The advantage of the container is that there is no need for installing any dependency software except for the singularity software itself. Otherwise, users can still run this package the old way by installing all dependencies (which can be tedious).  

# I. The easiet, with the Singularity container
## 1. Install Singularity and download the container
- Refer to Singularity [website](https://singularity.lbl.gov/install-linux) to install singularity >= 3.6.2
- Download singularity container [to check instructions in NP3 package page]

## 2. Clone NET-evaluation repository
`git clone https://github.com/BrentLab/NET-evaluation.git`

## 3. Run Commands
There are four different evaluation commands for (1) binding, (2) GO, (3) GO-directness and (4) PPI. There is a sample code for running each of the commands in `toy_example/run.sh`. Below, we only explain the binding command in details, but the other commands follow the same principles. 

- For help:

`p_src_code="/path/of/code/that/was/cloned/from/github/repository"`

```
${p_src_code}binding -h # for binding
${p_src_code}go -h  # for GO
${p_src_code}go_directness -h  # for GO-directness
${p_src_code}ppi -h  # for ppi
```

- For running the binding command:

```
${p_src_code}binding \
    --p_in_net "${p_src_code}toy_example/zev.tsv" \
    --nbr_top_edges 50 \
    --nbr_edges_per_threshold 5 \
    --p_binding_event "${p_src_code}metadata/yeast/reg_target_cc_exo_chip_exclusive.txt" \
    --flag_debug "OFF" \
    --p_out_eval "/path/of/output/file.tsv" \
    --flag_singularity "ON" \
    --p_singularity_img "/path/of/singularity/container/s_neteval" \
    --p_singularity_bindpath "/home/"
```
# II. The more advanced, by installing all dependencies
## 1. Install required packages
- Install anaconda3 and create environment and call it np3. Refer to anaconda [website](https://docs.anaconda.com/anaconda/install/) on how to install anaconda
- The list of libraries requiered for np3 are in [fill in the url]
- For GO analysis, GO-Term-Finder v0.86 has to be install it 
- For running the binding command outside the singularity container:

```
${p_src_code}binding \
    --p_in_net "${p_src_code}toy_example/zev.tsv" \
    --nbr_top_edges 50 \
    --nbr_edges_per_threshold 5 \
    --p_binding_event "${p_src_code}metadata/yeast/reg_target_cc_exo_chip_exclusive.txt" \
    --conda_env "np3" \
    --flag_debug "OFF" \
    --p_out_eval "/path/of/output/file.tsv" \
    --flag_singularity "OFF" \
