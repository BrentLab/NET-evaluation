#!/bin/bash

# ======================================================== #
# |         *** Define Default Arguments ***             | #
# ======================================================== #
p_in_net="/scratch/mblab/dabid/netprophet/net_out/zev_np2.1_tf167_target6175/net/net_np2wa_melted.tsv"
flag_match="ON"
p_dict_match="/scratch/mblab/dabid/netprophet/data_systematic_common.json"
p_out_eval="/scratch/mblab/dabid/netprophet/NET-evaluation/test_fdr.tsv"
flag_save_intermediate="OFF"
p_intermediate="OFF"
flag_slurm="ON"
flag_singularity="ON"
p_src_code="/scratch/mblab/dabid/netprophet/NET-evaluation/"
p_out_logs="/scratch/mblab/dabid/netprophet/NET-evaluation/"
p_singularity_bindpath="/scratch/mblab/dabid/netprophet/"
p_singularity_img="/scratch/mblab/dabid/netprophet/NET-evaluation/singularity/s_neteval"

# WebGestalt parameters
nbr_edges_per_reg=100
enrich_method="ORA"
organism="scerevisiae"
enrich_database="geneontology_Biological_Process_noRedundant"
interest_gene_type="genesymbol"
reference_set="genome_protein-coding"
reference_gene_type="genesymbol"
sig_method="fdr"
set_cover_num=10
fdr_threshold=0.05
top_threshold=10
min_num=10
max_num=500

# ======================================================== #
# |               *** Parse Arguments ***                | #
# ======================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                 p_in_net)
                     p_in_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_match)
                     flag_match="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_dict_match)
                     p_dict_match="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_out_eval)
                     p_out_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_save_intermediate)
                     flag_save_intermediate="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_dir_intermediate)
                     p_dir_intermediate="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 nbr_edges_per_reg)
                     nbr_edges_per_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 enrich_method)
                     enrich_method="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 organism)
                     organism="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 enrich_database)
                     enrich_database="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 interest_gene_type)
                     interest_gene_type="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 reference_set)
                     reference_set="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 reference_gene_type)
                     reference_gene_type="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 sig_method)
                     sig_method="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 set_cover_num)
                     set_cover_num="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 fdr_threshold)
                     fdr_threshold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 top_threshold)
                     top_threshold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 min_num)
                     min_num="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 max_num)
                     max_num="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_src_code)
                     p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_slurm)
                     flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_singularity)
                     flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_out_logs)
                     p_out_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_singularity_bindpath)
                     p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_singularity_img)
                     p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
            esac;;
    esac
done

# ======================================================== #
# |              *** Define Command ***                  | #
# ======================================================== #

command=""

if [ ${flag_slurm} == "ON" ]
then
    mkdir -p ${p_out_logs}
    command+="sbatch \
            -o ${p_out_logs}eval_go_%J.out \
            -e ${p_out_logs}eval_go_%J.err \
            -J eval_go "
fi

command+="${p_src_code}wrapper/evaluate_with_go.sh \
            --p_in_net ${p_in_net} \
            --flag_match ${flag_match} \
            --p_dict_match ${p_dict_match} \
            --p_out_eval ${p_out_eval} \
            --flag_save_intermediate ${flag_save_intermediate} \
            --p_dir_intermediate ${p_dir_intermediate} \
            --nbr_edges_per_reg ${nbr_edges_per_reg} \
            --enrich_method ${enrich_method} \
            --organism ${organism} \
            --enrich_database ${enrich_database} \
            --interest_gene_type ${interest_gene_type} \
            --reference_set ${reference_set} \
            --reference_gene_type ${reference_gene_type} \
            --sig_method ${sig_method} \
            --set_cover_num ${set_cover_num} \
            --fdr_threshold ${fdr_threshold} \
            --top_threshold ${top_threshold} \
            --min_num ${min_num} \
            --max_num ${max_num} \
            --p_src_code ${p_src_code} \
            --flag_slurm ${flag_slurm} \
            --flag_singularity ${flag_singularity} \
            --p_singularity_bindpath ${p_singularity_bindpath} \
            --p_singularity_img ${p_singularity_img}"

# ======================================================== #
# |                *** Run Command ***                   | #
# ======================================================== #
# echo "${command}"
eval ${command}
