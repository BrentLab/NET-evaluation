#!/bin/bash

while getopts ":h-:" OPTION
do
    case "${OPTION}" in
        h)
            echo "help"
            ;;
        -)
            case "${OPTARG}" in
                # input
                p_in_dir_go)
                    p_in_dir_go="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_top_edges)
                    nbr_top_edges="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                nbr_edges_per_threshold)
                    nbr_edges_per_threshold="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_binding_event)
                    p_binding_event="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                conda_env)
                    conda_env="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # output
                p_out_eval)
                   p_out_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                   ;;
                
                # SLURM
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1 ))
                    ;;
                
                # SINGULARITY
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
else
    source activate ${conda_env}
fi

command+="python3 ${p_src_code}code/go_directness.py \
        --p_in_dir_go ${p_in_dir_go} \
        --nbr_top_edges ${nbr_top_edges} \
        --nbr_edges_per_threshold ${nbr_edges_per_threshold} \
        --p_binding_event ${p_binding_event} \
        --p_out_eval ${p_out_eval}"
   
# ======================================================== #
# |                 *** Run Command ***                  | #
# ======================================================== #
if [ ${flag_debug} == "ON" ]
then
    echo "${command}"
fi
eval ${command}

if [ ${flag_slurm} == "ON" ] && [ ${flag_singularity} == "OFF" ]; then
    source deactivate ${conda_env}
fi


