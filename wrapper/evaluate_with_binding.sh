#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                 p_net)
                     p_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_eval)
                     p_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 nbr_bins)
                     nbr_bins="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 nbr_edges_per_reg)
                     nbr_edges_per_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_binding_event)
                     p_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 p_src_code)
                     p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 fname_net)
                     fname_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 conda_env)
                     conda_env="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                     ;;
                 flag_debug_PY)
                     flag_debug_PY="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
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

command+="python3 ${p_src_code}code/evaluate_with_binding.py \
        --p_net ${p_net} \
        --fname_net ${fname_net} \
        --nbr_bins ${nbr_bins} \
        --nbr_edges_per_reg ${nbr_edges_per_reg} \
        --p_binding_event ${p_binding_event} \
        --p_eval ${p_eval}"
    
# ======================================================== #
# |                 *** Run Command ***                  | #
# ======================================================== #
if [ ${flag_debug_PY} == "ON" ]
then
    echo "${command}"
fi
eval ${command}


