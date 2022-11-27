def calculate_percentage_support(p_dir_go
                                , l_binding):
    from os import listdir
    from pandas import read_csv
    
    
    l_perc_support, l_edges = [], []
    for file in listdir(p_dir_go):
        if file.endswith('.tsv'):
            tf = file[0:file.find('.')]
            df_go = read_csv(p_dir_go + file, header=0, sep='\t')
            df_go_sorted = df_go.sort_values(ascending=True, by='CORRECTED P-VALUE')
            l_genes = df_go_sorted.iloc[0, 10].split(', ')
            l_edges = [(tf, g) for g in l_genes]
            perc_support = sum([1 if e in l_binding else 0 for e in l_edges])*100/len(l_edges) if len(l_edges) != 0 else 0
            l_perc_support.append(perc_support)
        
    return sum(l_perc_support)/len(l_perc_support) if len(l_perc_support) != 0 else 0
    

def evaluate(p_in_dir_go
             , p_binding_event
             , nbr_top_edges
             , nbr_edges_per_threshold
             , p_out_eval='NONE'
            ):
    import multiprocessing as mp
    from pandas import read_csv, DataFrame
    import os
    
    # read binding event file and pull supported edges
    df_binding = read_csv(p_binding_event, header=0, sep='\t')
    l_binding = [(reg, target) for reg, target in zip(df_binding['REGULATOR'], df_binding['TARGET'])]
    
    d_seed__perc = {}
    pool = mp.Pool(processes=10)
    
    l_res = pool.starmap(calculate_percentage_support, [(p_in_dir_go + 'bin_' + str(b) +'/'
                                                         , l_binding)  for b in range(nbr_edges_per_threshold
                                                                                      , nbr_top_edges+1
                                                                                      , nbr_edges_per_threshold)])
        
    pool.close()
    pool.join()
    
    if p_out_eval != 'NONE':
        p_dir, file_name = os.path.split(p_out_eval)
        if not os.path.exists(p_dir):
            os.makedirs(p_dir)
        DataFrame(l_res
                  , index=[i for i in range(nbr_edges_per_threshold
                                            , nbr_top_edges+1
                                            , nbr_edges_per_threshold)]
                 ).round(0).to_csv(p_out_eval , index=True , header=False)
    return DataFrame(l_res
                  , index=[i for i in range(nbr_edges_per_threshold
                                            , nbr_top_edges+1
                                            , nbr_edges_per_threshold)]
                 )
                    


if __name__ == "__main__":
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_dir_go', '-p_in_dir_go', help='path of directory for GO results')
    parser.add_argument('--p_binding_event', '-p_binding_event', help='path of file for evidence of direct binding')
    parser.add_argument('--nbr_top_edges', '-nbr_top_edges', type=int, nargs='?', default=50, help='number of top edges per TF on average')
    parser.add_argument('--nbr_edges_per_threshold', '-nbr_edges_per_threshold', type=int, nargs='?', default=5, help='number of edges per threshold')
    parser.add_argument('--p_out_eval', '-p_out_eval', help='path of file for evaluation results')
    args = parser.parse_args()
    
    evaluate(p_in_dir_go=args.p_in_dir_go
             , p_binding_event=args.p_binding_event
             , nbr_top_edges=args.nbr_top_edges
             , nbr_edges_per_threshold=args.nbr_edges_per_threshold
             , p_out_eval=args.p_out_eval
            )




