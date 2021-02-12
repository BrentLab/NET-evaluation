#!/bin/bash

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
# |            *** Load Modules for Slurm ***            | #
# ======================================================== #
if [ ${flag_slurm} == "ON" ]
then
    source ${p_src_code}wrapper/helper_load_modules.sh
fi

# ======================================================== #
# |               *** Define Command ***                 | #
# ======================================================== #
command=""
if [ ${flag_singularity} == "ON" ]
then
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    command+="singularity exec ${p_singularity_img} "
fi

command+="Rscript ${p_src_code}code/evaluate_with_go.R \
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
    --max_num ${max_num}"

# ======================================================== #
# |                 *** Run Command ***                  | #
# ======================================================== #
echo "${command}"
eval ${command}
