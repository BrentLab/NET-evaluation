#!/bin/bash

# ======================================================== #
# |                    *** Usage ***                     | #
# ======================================================== #
usage(){
cat << EOF
    evaluate-network v1.0
    
    go command for GO enrichment analysis: leverages GO-TermFinder
    go [options]
    
    GENERAL arguments
    --p_in_net                : path of file for input network, the format of network is a three column network |REGULATOR|TARGET|VALUE, with no header, (mandatory)
    --l_nbr_edges_per_reg     : an array for the number of target genes per one regulators on average, default (10 5 10 15 20 25 30 35 40 45 50), (optional)
    --p_out_eval              : path of output file for evaluation (mandatory)
    --p_out_dir               : path of output directory for temporarily files
    --p_gene_association      : path of file of gene association. This file can be downloaded from the geneonthology website (mandatory).
    --p_ontology_obo          : path of file of ontology .obo definition (optional). This file can be downloaded from the geneontology website (mandatory).
    --nbr_genes               : total number of genes in the organisms to calculate fold-enrichment and p-values (mandatory). 
   
    SINGULARITY arguments
    --flag_singularity        : ON or OFF, for singularity run (optional, default ON)
    --p_singularity_bindpath  : path for mounted directory to singularity container when data are located outsite the container (optional)
    --p_singularity_img       : path of directory for singularity containerr image downloaded from github page (mandatory, if flag_singularity ON)
   
    SLURM arguments
    --flag_slurm              : ON or OFF, for SLURM run (optional, default OFF)
    --p_out_logs              : path of directory for SLURM log files (mandatory if flag_slurm ON)
    
    
EOF
}

# ======================================================== #
# |         *** Define Default Arguments ***             | #
# ======================================================== #

# General arguments
flag_slurm=OFF
flag_singularity=ON
flag_debug=OFF
l_nbr_edges_per_reg=(10 5 10 15 20 25 30 35 40 45 50) 
p_singularity_img=NONE
p_singularity_bindpath=/home/
p_src_code="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)/"
data=""

# ======================================================== #
# |               *** Parse Arguments ***                | #
# ======================================================== #
while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            usage
            exit 2
            ;;
        -)
            case "${OPTARG}" in
                 # GENERAL arguments
                 p_in_net)
                     p_in_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_out_eval)
                     p_out_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 l_nbr_edges_per_reg)
                     narg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     l_nbr_edges_per_reg=("${narg}")
                     
                     for (( i=1;i<`expr ${narg}+1`;i++ ))
                     do
                         arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                         l_nbr_edges_per_reg+=("${arg}")
                     done
                     ;;
                 p_gene_association)
                     p_gene_association="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_gene_ontology)
                     p_gene_ontology="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 nbr_genes)
                     nbr_genes="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_out_dir)
                     p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_debug)
                     flag_debug="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                     
                 # SLURM arguments
                 flag_slurm)
                     flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_out_logs)
                     p_out_logs="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 data)
                     data="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                     
                 # SINGULARITY arguments
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
# |              *** Define Command ***                  | #
# ======================================================== #

command=""

if [ ${flag_slurm} == "ON" ]
then
    mkdir -p ${p_out_logs}
    command+="sbatch \
            -o ${p_out_logs}eval_go_%J.out \
            -e ${p_out_logs}eval_go_%J.err \
            --mem=20G \
            -J eval_go_${data} \
            -N 1 \
            -n 4 "
fi

command+="${p_src_code}wrapper/go.sh \
            --p_in_net ${p_in_net} \
            --l_nbr_edges_per_reg ${l_nbr_edges_per_reg[@]} \
            --p_gene_association ${p_gene_association} \
            --p_gene_ontology ${p_gene_ontology} \
            --nbr_genes ${nbr_genes} \
            --p_out_dir ${p_out_dir} \
            --p_out_eval ${p_out_eval} \
            --p_src_code ${p_src_code} \
            --flag_slurm ${flag_slurm} \
            --flag_singularity ${flag_singularity} \
            --p_singularity_bindpath ${p_singularity_bindpath} \
            --p_singularity_img ${p_singularity_img} \
            --flag_debug ${flag_debug}"

# ======================================================== #
# |                *** Run Command ***                   | #
# ======================================================== #
if [ ${flag_debug} == "ON" ]
then
    echo "${command}"
fi

eval ${command}
