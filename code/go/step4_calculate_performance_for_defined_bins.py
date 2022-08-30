def collect_l_pvalue(p_in_go_file):
    from pandas import read_csv
    
    df_go = read_csv(p_in_go_file, header=0, sep='\t')
    df_go_pvalue = df_go.sort_values(ascending=True, by='CORRECTED P-VALUE').loc[:, 'CORRECTED P-VALUE']
    pvalue = df_go_pvalue.iloc[0]
    return pvalue
            

def calculate_performance_for_defined_bins(p_net
                                           , p_dir_results
                                           , l_nbr_edges_per_reg
                                           , p_eval):
    
    from pandas import Series, read_csv, DataFrame
    from statistics import mean, median
    import numpy as np
    import multiprocessing as mp
    from os import listdir
    
    # get the set of regulators after reading network
    df_net = read_csv(p_net, header=None, sep='\t')
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    nbr_reg = len(set(list(df_net.loc[:, 'REGULATOR'])))
    
    pool = mp.Pool(40)
    
    # loop over bins and calculate sum(-log(pvalue))
    l_sum_pvalue, l_mean_pvalue, l_median_pvalue, l_nbr_tf = [], [], [], []  # list of performance score
    for nbr_edges_per_reg in l_nbr_edges_per_reg:
        p_dir = p_dir_results + 'bin_' + str(nbr_edges_per_reg) + '/'
        l_pvalue = pool.starmap(collect_l_pvalue, [(p_dir + tf_file, ) for tf_file in listdir(p_dir) if tf_file.endswith('.tsv')])
        # calcualte stats
        l_sum_pvalue.append(sum(-np.log(l_pvalue)))
        l_mean_pvalue.append(mean(-np.log(l_pvalue)))
        l_median_pvalue.append(median(-np.log(l_pvalue)))
        l_nbr_tf.append(len(l_pvalue))
    pool.close()
    pool.join()
        
        

    DataFrame([l_sum_pvalue, l_mean_pvalue, l_median_pvalue, l_nbr_tf], index=['sum', 'mean', 'median', 'nbr_tf']).T.to_csv(p_eval, header=True, index=False, sep='\t')       


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_in_net', '-p_in_net', help='path of input file for network')
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of directory of output results')
    parser.add_argument('--l_nbr_edges_per_reg', '-l_nbr_edges_per_reg', nargs='+', type=int, help='list of number of target genes per TF on average 5, 10, 15, etc.')
    parser.add_argument('--p_out_eval', '-p_out_eval', help='path of output file for evaluation performance')
    
    args = parser.parse_args()
    
    calculate_performance_for_defined_bins(p_net=args.p_in_net
                                           , p_dir_results=args.p_out_dir
                                           , l_nbr_edges_per_reg=args.l_nbr_edges_per_reg
                                           , p_eval=args.p_out_eval)


if __name__ == '__main__':
    main()