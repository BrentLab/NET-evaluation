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
                    p_in_net="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_out_dir)
                    p_out_dir="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_out_eval)
                    p_out_eval="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                l_nbr_edges_per_reg)
                    narg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    l_nbr_edges_per_reg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    for (( i=1;i<`expr ${narg}`;i++ ))
                    do
                        arg="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                        l_nbr_edges_per_reg+=("${arg}")
                    done
                    
                    ;;
                p_gene_association)
                    p_gene_association="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_gene_ontology)
                    p_gene_ontology="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                nbr_genes)
                    nbr_genes="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                # logistic args
                flag_debug)
                    flag_debug="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_src_code)
                    p_src_code="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                # slurm args
                flag_slurm)
                    flag_slurm="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                # singularity args
                flag_singularity)
                    flag_singularity="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_singularity_img)
                    p_singularity_img="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
                    ;;
                p_singularity_bindpath)
                    p_singularity_bindpath="${!OPTIND}"; OPTIND=$(( ${OPTIND} + 1))
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

mkdir -p ${p_out_dir}

run_go_term_finder(){
    nbr_edges_per_reg=${1}

    # ======================================================== #
    # |               *** Define Commands ***                | #
    # ======================================================== #
    cmd_create_files=""
    cmd_go_term_finder=""
    cmd_filter_results=""


    if [ ${flag_singularity} == "ON" ]
    then
        export SINGULARITY_BINDPATH=${p_singularity_bindpath}
        cmd_create_files+="singularity exec ${p_singularity_img} "
        cmd_go_term_finder+="singularity exec ${p_singularity_img} "
        cmd_filter_results+="singularity exec ${p_singularity_img} "
    fi

    # CMD: create files
    if [ -d ${p_out_dir}bin_${nbr_edges_per_reg} ]; then
        rm -r ${p_out_dir}bin_${nbr_edges_per_reg}
    fi
    cmd_create_files+="python3 ${p_src_code}code/go/step1_create_target_gene_files_for_every_tf.py \
        --p_in_net ${p_in_net} \
        --p_out_dir ${p_out_dir}bin_${nbr_edges_per_reg}/ \
        --nbr_edges_per_reg ${nbr_edges_per_reg}"

    # CMD: GO term finder
    p_dir_go_term_finder=/home/packages/GO-TermFinder-0.86/
    cmd_go_term_finder+="perl ${p_dir_go_term_finder}examples/analyze.pl \
                                ${p_gene_association} \
                                ${nbr_genes} \
                                ${p_gene_ontology}"
    
    for target_file in ${p_out_dir}bin_${nbr_edges_per_reg}/*
    do
        cmd_go_term_finder+=" ${target_file}"
    done                            

    # CMD: filter results
    cmd_filter_results+="python3 ${p_src_code}code/go/step3_filter_go_term_finder_results.py \
                        --p_out_dir ${p_out_dir}bin_${nbr_edges_per_reg}/ \
                        --nbr_genes ${nbr_genes}"
    
    # ======================================================== #
    # |                 *** Run Commands ***                 | #
    # ======================================================== #
    if [ ${flag_debug} == "ON" ]
    then
        echo "*** CMD: CREATE FILE ***"
        echo "${cmd_create_files}"
        echo "*** CMD: GO-TERM-FINDER ***"
        echo "${cmd_go_term_finder}"
        echo "*** CMD: FILTER RESULTS"
        echo "${cmd_filter_results}"
    fi

    eval ${cmd_create_files}
    eval ${cmd_go_term_finder}
    eval ${cmd_filter_results}
}


# ======================================================== #
# |        *** Loop over the list of bin size ***        | #
# ======================================================== #
nbr_cpu=$((( $(nproc --all) <= 5 )) && echo "$(nproc --all)" || echo "5")
for (( i=0;i<${#l_nbr_edges_per_reg[@]}; i++ ))
do
    run_go_term_finder ${l_nbr_edges_per_reg[i]} &
    
    jobs_running=$(jobs -p | wc -l)
    while ((jobs_running >= nbr_cpu))
    do
        sleep 1
        jobs_running=$(jobs -p | wc -l)
    done
done

wait
# ======================================================== #
# |      *** End Loop over the list of bin size ***      | #
# ======================================================== #

# CMD: calculate performance over all bins: sum(-log(pvalue))/nbr_edges 
cmd_calculate_performance=""
if [ ${flag_singularity} == "ON" ]
then
    export SINGULARITY_BINDPATH=${p_singularity_bindpath}
    cmd_calculate_performance+="singularity exec ${p_singularity_img} "
fi
    
cmd_calculate_performance+="python3 ${p_src_code}code/go/step4_calculate_performance_for_defined_bins.py \
                           --p_in_net ${p_in_net} \
                           --p_out_dir ${p_out_dir} \
                           --l_nbr_edges_per_reg ${l_nbr_edges_per_reg[@]} \
                           --p_out_eval ${p_out_eval}"

if [ ${flag_debug} == "ON" ]
then
    echo "CMD: CALCULATE PERFORMANCE"
    echo "${cmd_calculate_performance}"
fi
eval ${cmd_calculate_performance}

