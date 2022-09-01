#!/bin/bash

p_wd="/home/dabid/Documents/"  # change this to your home directory
p_src_code="/home/dabid/Documents/NET-evaluation/"  # change this to the path of cloned repository NET-evaluation


## binding command
#${p_src_code}binding \
#    --p_in_net "${p_src_code}toy_example/zev.tsv" \
#    --nbr_top_edges 50 \
#    --nbr_edges_per_threshold 5 \
#    --p_binding_event "${p_src_code}metadata/yeast/reg_target_cc_exo_chip_exclusive.txt" \
#    --conda_env "np3" \
#    --flag_debug "ON" \
#    --p_out_eval "${p_wd}net_eval2/eval_binding.tsv" \
#    --flag_singularity "ON" \
#    --p_singularity_bindpath "${p_wd}" \
#    --p_singularity_img "${p_src_code}singularity/s_neteval.sif"


## go command
#${p_src_code}go \
#    --p_in_net "${p_src_code}toy_example/zev.tsv" \
#    --p_gene_association "${p_src_code}metadata/yeast/gene_association.sgd" \
#    --p_gene_ontology "${p_src_code}metadata/yeast/gene_ontology_edit.obo" \
#    --nbr_genes 7200 \
#    --flag_debug "OFF" \
#    --p_out_eval "${p_wd}net_eval2/go/eval_go.tsv" \
#    --p_out_dir "${p_wd}net_eval2/go/" \
#    --flag_singularity "ON" \
#    --p_singularity_bindpath "${p_wd}" \
#    --p_singularity_img "${p_src_code}singularity/s_neteval.sif"
    
    
# go-directness command
${p_src_code}go_directness \
    --p_in_dir_go "${p_wd}net_eval2/go/" \
    --nbr_top_edges 50 \
    --nbr_edges_per_threshold 5 \
    --p_binding_event "${p_src_code}metadata/yeast/reg_target_cc_exo_chip_exclusive.txt" \
    --flag_debug "ON" \
    --p_out_eval "${p_wd}net_eval2/eval_go_directness.tsv" \
    --flag_slurm "OFF" \
    --flag_singularity "ON" \
    --p_singularity_bindpath "${p_wd}" \
    --p_singularity_img "${p_src_code}singularity/s_neteval.sif"
    
    
# ppi command
#${p_src_code}ppi \
#    --p_in_net "${p_src_code}toy_example/zev.tsv" \
#    --flag_debug "OFF" \
#    --p_out_eval "${p_wd}net_eval2/eval_ppi.tsv" \
#    --flag_singularity "ON" \
#    --p_singularity_bindpath "${p_wd}" \
#    --p_singularity_img "${p_src_code}singularity/s_neteval.sif" \
#    --nbr_top_edges 100 \
#    --nbr_edges_per_threshold 10 \
#    --threshold 25 \
#    --p_STRING_db "${p_src_code}metadata/yeast/4932.protein.links.v11.5.txt" \
#    --STRING_confidence 700
