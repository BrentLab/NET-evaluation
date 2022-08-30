#!/bin/bash

p_wd="/scratch/mblab/dabid/proj_net/"
p_src_code="${p_wd}code/NET-evaluation/"

# # run ppi command
# ${p_src_code}ppi \
#     --p_in_net "${p_wd}output/yeast/np3_paper/section_1/res_kem_ldbp_atomic_10cv_tf313_target6112/seed_0/net_np3.tsv" \
#     --conda_env "np3" \
#     --flag_debug "ON" \
#     --p_out_eval "${p_src_code}test/eval_test3.tsv" \
#     --flag_slurm "ON" \
#     --p_out_logs "${p_src_code}test/" \
#     --flag_singularity "OFF" \
#     --p_singularity_bindpath "${p_wd}" \
#     --p_singularity_img "${p_src_code}singularity/s_neteval"
# #         --nbr_top_edges 100 \
# #     --nbr_edges_per_threshold 10 \
# #     --threshold 25 \
# #     --p_STRING_db "${p_src_code}metadata/4932.protein.links.v11.5.txt" \
# #     --STRING_confidence 700 \


# # run binding command
# ${p_src_code}binding \
#     --p_in_net "${p_wd}output/yeast/np3_paper/section_1/res_kem_ldbp_atomic_10cv_tf313_target6112/seed_0/net_np3.tsv" \
#     --nbr_top_edges 200 \
#     --nbr_edges_per_threshold 20 \
#     --p_binding_event "${p_src_code}metadata/reg_target_cc_exo_chip_exclusive.txt" \
#     --conda_env "np3" \
#     --flag_debug "ON" \
#     --p_out_eval "${p_src_code}test/eval_binding_test2.tsv" \
#     --flag_slurm "ON" \
#     --p_out_logs "${p_src_code}test/" \
#     --flag_singularity "ON" \
#     --p_singularity_bindpath "${p_wd}" \
#     --p_singularity_img "${p_src_code}singularity/s_neteval"


# # run go command
# ${p_src_code}go \
#     --p_in_net "${p_wd}output/yeast/np3_paper/section_1/res_kem_ldbp_atomic_10cv_tf313_target6112/seed_0/net_np3.tsv" \
#     --p_gene_association "${p_src_code}metadata/yeast/gene_association.sgd" \
#     --p_gene_ontology "${p_src_code}metadata/yeast/gene_ontology_edit.obo" \
#     --nbr_genes 7200 \
#     --flag_debug "ON" \
#     --p_out_eval "${p_src_code}test/go_test/eval_go_test.tsv" \
#     --p_out_dir "${p_src_code}test/go_test/" \
#     --flag_slurm "ON" \
#     --p_out_logs "${p_src_code}test/" \
#     --flag_singularity "ON" \
#     --p_singularity_bindpath "${p_wd}" \
#     --p_singularity_img "${p_src_code}singularity/s_neteval"
    
    
# run go command
${p_src_code}go_directness \
    --p_in_dir_go "${p_src_code}test/go_test/" \
    --nbr_top_edges 50 \
    --nbr_edges_per_threshold 10 \
    --p_binding_event "${p_src_code}metadata/yeast/reg_target_cc_exo_chip_exclusive.txt" \
    --flag_debug "ON" \
    --p_out_eval "${p_src_code}test/go_test/eval_go_directness3.tsv" \
    --flag_slurm "ON" \
    --p_out_logs "${p_src_code}test/" \
    --flag_singularity "ON" \
    --p_singularity_bindpath "${p_wd}" \
    --p_singularity_img "${p_src_code}singularity/s_neteval"