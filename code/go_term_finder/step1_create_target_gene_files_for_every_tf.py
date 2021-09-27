def write_l_target_into_file(reg
                            , p_dir_out
                            , df_net):
    df_target = df_net.loc[df_net['REGULATOR'] == reg, 'TARGET']
    if df_target.shape[0] > 0:
        df_target.to_csv(p_dir_out + reg, header=False, index=False)

            
def create_target_gene_files_for_every_tf(p_net
                                         , p_dir_out
                                         , nbr_edges_per_reg):
    from pandas import read_csv
    from os import makedirs, path
    import multiprocessing as mp
    
    df_net = read_csv(p_net, header=None, sep='\t')
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    df_net.loc[:, 'VALUE'] = abs(df_net.loc[:, 'VALUE'])  # take absolute values in case values + and -
    df_net_sorted = df_net.sort_values(ascending=False, by='VALUE')
    
    l_reg = set(list(df_net.loc[:, 'REGULATOR']))
    df_net = df_net_sorted.iloc[[i for i in range(len(l_reg)*nbr_edges_per_reg)], :]
    
    if not path.exists(p_dir_out):
        makedirs(p_dir_out)
        
    pool = mp.Pool(20)
    pool.starmap(write_l_target_into_file, [(reg, p_dir_out, df_net) for reg in l_reg])
    pool.close()
    pool.join()
    

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_net', '-p_net', help='path of input file for network')
    parser.add_argument('--p_dir_out', '-p_dir_out', help='path of output directory')
    parser.add_argument('--nbr_edges_per_reg', '-nbr_edges_per_reg', type=int, help='number of target genes pere regulator on average')
    
    args = parser.parse_args()
    
    create_target_gene_files_for_every_tf(p_net=args.p_net
                                          , p_dir_out=args.p_dir_out
                                          , nbr_edges_per_reg=args.nbr_edges_per_reg)
    
    
if __name__ == '__main__':
    main()