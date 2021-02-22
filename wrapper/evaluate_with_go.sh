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
                 # GENERAL argumentss
                 p_net)
                     p_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_match)
                     flag_match="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_dict_match)
                     p_dict_match="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_eval)
                     p_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
                 p_src_code)
                     p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 # WEBGESTALT arguments
                 enrichMethod)
                     enrichMethod="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 organism)
                     organism="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 enrichDatabase)
                     enrichDatabase="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 interestGeneType)
                     interestGeneType="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 referenceSet)
                     referenceSet="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 referenceGeneType)
                     referenceGeneType="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 sigMethod)
                     sigMethod="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 setCoverNum)
                     setCoverNum="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 fdrThr)
                     fdrThr="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 topThr)
                     topThr="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 minNum)
                     minNum="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 maxNum)
                     maxNum="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;

                 # SLURM arguments
                 flag_slurm)
                     flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
                 flag_debug_R)
                     flag_debug_R="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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
    --p_net ${p_net} \
    --flag_match ${flag_match} \
    --p_dict_match ${p_dict_match} \
    --p_eval ${p_eval} \
    --flag_save_intermediate ${flag_save_intermediate} \
    --p_dir_intermediate ${p_dir_intermediate} \
    --flag_singularity ${flag_singularity} \
    --nbr_edges_per_reg ${nbr_edges_per_reg} \
    --enrichMethod ${enrichMethod} \
    --organism ${organism} \
    --enrichDatabase ${enrichDatabase} \
    --interestGeneType ${interestGeneType} \
    --referenceSet ${referenceSet} \
    --referenceGeneType ${referenceGeneType} \
    --sigMethod ${sigMethod} \
    --setCoverNum ${setCoverNum} \
    --fdrThr ${fdrThr} \
    --topThr ${topThr} \
    --minNum ${minNum} \
    --maxNum ${maxNum}"

# ======================================================== #
# |                 *** Run Command ***                  | #
# ======================================================== #
if [ ${flag_debug_R} == "ON" ]
then
    echo "${command}"
fi

eval ${command}
