def calculate_performance_for_defined_bins(p_net
                                           , p_dir_results
                                           , l_nbr_edges_per_reg
                                           , p_eval):
    from os import listdir
    from pandas import Series, read_csv
    import numpy as np
    
    # get the set of regulators
    df_net = read_csv(p_net, header=None, sep='\t')
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    nbr_reg = len(set(list(df_net.loc[:, 'REGULATOR'])))
    
    l_score = []  # list of performance score
    
    # loop over bins and calculate sum(-log(pvalue))
    for nbr_edges_per_reg in l_nbr_edges_per_reg:
        print(nbr_edges_per_reg)
        sum_pvalue = 0
        p_dir = p_dir_results + 'bin_' + str(nbr_edges_per_reg) + '/'
        for targets_file in listdir(p_dir):
            if targets_file.endswith('.tsv'):
                df_go = read_csv(p_dir + targets_file, header=0, sep='\t')
                
                df_go_pvalue = df_go.sort_values(ascending=True, by='CORRECTED P-VALUE').loc[:, 'CORRECTED P-VALUE']
                pvalue = df_go_pvalue.iloc[0]
                if not np.isnan(pvalue):
                    sum_pvalue-=np.log(pvalue)
        l_score.append(sum_pvalue/(nbr_edges_per_reg*nbr_reg))
            
    Series(l_score, name='score').T.to_csv(p_eval, header=False, index=False, sep='\t')       


def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_net', '-p_net', help='path of input file for network')
    parser.add_argument('--p_dir_results', '-p_dir_results', help='path of directory of output results')
    parser.add_argument('--l_nbr_edges_per_reg', '-l_nbr_edges_per_reg', nargs='+', type=int, help='list of number of target genes per TF on average 5, 10, 15, etc.')
    parser.add_argument('--p_eval', '-p_eval', help='path of output file for evaluation performance')
    
    args = parser.parse_args()
    
    calculate_performance_for_defined_bins(p_net=args.p_net
                                           , p_dir_results=args.p_dir_results
                                           , l_nbr_edges_per_reg=args.l_nbr_edges_per_reg
                                           , p_eval=args.p_eval)


if __name__ == '__main__':
    main()