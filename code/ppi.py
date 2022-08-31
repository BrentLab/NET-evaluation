"""
First, we calculate the jaccard index of (TF, TF) pairs in the function calculate_jaccard.
Then, Rank (TF, TF) edges based on the jaccard index and calculate the support using data 
from STRING DB in function calculate_support_ppi. The evaluate_with_ppi call these two functions.
"""

def calculate_jaccard(df_net_sorted_thresholded):
    """
    calculate jaccard distance for TF-TF pairs
    df_net_sorted_thresholded: a dataframe of columns, and TFs that are not accounted in the STRING database are excluded.
    """
    from pandas import DataFrame
    
    l_jaccard, l_intersection, l_tf1, l_tf2 = [], [], [], []
    l_tf = list(set(df_net_sorted_thresholded.iloc[:, 0]))
    for idx_tf1, tf1 in enumerate(l_tf):
        l_target_tf1 = list(df_net_sorted_thresholded.loc[df_net_sorted_thresholded.REGULATOR == tf1, 'TARGET'])
        for tf2 in l_tf[idx_tf1+1:]: 
            l_target_tf2 = list(df_net_sorted_thresholded.loc[df_net_sorted_thresholded.REGULATOR == tf2, 'TARGET'])
            len_intersection = len(set(l_target_tf1) & set(l_target_tf2))
            len_union = len(set(l_target_tf1 + l_target_tf2))
            if len(l_target_tf1) == 0 or len(l_target_tf2) == 0:
                jaccard = 0
            else:
                jaccard = len_intersection/len_union
            l_jaccard.append(jaccard)
            l_intersection.append(len_intersection)
            l_tf1.append(tf1)
            l_tf2.append(tf2)
    
    df_jaccard = DataFrame([l_tf1, l_tf2, l_jaccard, l_intersection], index=['protein1', 'protein2', 'jaccard', 'intersection']).T
    df_jaccard_sorted = df_jaccard.sort_values(ascending=False, by='jaccard')
    return df_jaccard_sorted


# check supported pairs and calculate % support
def calculate_support_ppi(df_jaccard_sorted
                          , l_support_700
                         ):
    from pandas import DataFrame, concat
    
    l_jaccard_support_700, l_jaccard_support_perc_700 = [], []  # list to store binary and percent support
    
    df_jaccard_sorted.index = [(p1, p2) for p1, p2 in zip(df_jaccard_sorted['protein1'], df_jaccard_sorted['protein2'])]
    for idx, row in df_jaccard_sorted.iterrows():
        # 700
        l_jaccard_support_700.append(1 if idx in l_support_700 else 0)
        l_jaccard_support_perc_700.append(sum(l_jaccard_support_700)*100/len(l_jaccard_support_700))
        
    df_ppi_support = DataFrame(l_jaccard_support_perc_700, index=df_jaccard_sorted.index, columns=['support'])
                
    return df_ppi_support.round(0)

def evaluate(p_in_net
             , p_STRING_db
             , nbr_top_edges=100
             , nbr_edges_per_threshold=10
             , threshold=25
             , STRING_confidence=700
             , p_out_eval='NONE'
            ):
    from pandas import read_csv, DataFrame
    
    # read string database for PPI
    df_string = read_csv(p_STRING_db, header=0, sep=' ')
    df_string['protein1'] = [p[p.find('.')+1:] for p in df_string['protein1']]
    df_string['protein2'] = [p[p.find('.')+1:] for p in df_string['protein2']]

    # extract list of TFs in the network and number of TFs in the network
    df_net = read_csv(p_in_net, header=None, sep='\t')
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    l_tf = list(set(df_net.iloc[:, 0]))
    
    # sort edges in this database and extract
    # only interactions having high confidence >0.7
    df_string_tf = df_string.loc[(df_string.protein1.isin(l_tf))
                                     & (df_string.protein2.isin(l_tf)) , :]
    df_string_tf_conf_700 = df_string_tf.loc[df_string_tf['combined_score']>STRING_confidence, :]

    # filter edges based on TFs covered in STRING database
    df_net = df_net.loc[df_net.REGULATOR.isin(set(list(df_string_tf_conf_700.protein1) + list(df_string_tf_conf_700.protein2))), :]
    nbr_reg = len(set(df_net.REGULATOR))
    
    # create a list of support with symmetric entries
    l_support_700 = []
    for idx, row in df_string_tf_conf_700.iterrows():
        l_support_700.append((row['protein1'], row['protein2']))
        l_support_700.append((row['protein2'], row['protein1']))
    
    # sort edges of network to cropped at threshold 25 (default)
    df_net['VALUE'] = abs(df_net['VALUE'])
    df_net_sorted = df_net.sort_values(ascending=False, by='VALUE')
    df_net_sorted_thresholded = df_net_sorted.iloc[0:(nbr_reg*threshold), :]
    df_jaccard_sorted = calculate_jaccard(df_net_sorted_thresholded)
    df_ppi_support = calculate_support_ppi(df_jaccard_sorted, l_support_700)
    df_ppi_support = df_ppi_support.iloc[[i-1 for i in range(nbr_edges_per_threshold, nbr_top_edges, nbr_edges_per_threshold)], :]
    df_ppi_support.index = [i for i in range(nbr_edges_per_threshold, nbr_top_edges, nbr_edges_per_threshold)]
    
    if p_out_eval != 'NONE':
        df_ppi_support.to_csv(p_out_eval
                              , header=True
                              , index=True
                             )

    return df_ppi_support


if __name__ == '__main__':
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_net', '-p_in_net', help='path of input file for network')
    parser.add_argument('--nbr_top_edges', '-nbr_top_edges', nargs='?', type=int, default=100, help='number of top edges')
    parser.add_argument('--nbr_edges_per_threshold', '-nbr_edges_per_threshold', nargs='?', type=int, default=10, help='number of edges per threshold')
    parser.add_argument('--threshold', '-threshold', nargs='?', type=int, default=25, help='the threshold bin default 25')
    parser.add_argument('--p_STRING_db', '-p_STRING_db', nargs='?', help='path of string database')
    parser.add_argument('--STRING_confidence', '-STRING_confidence', nargs='?', type=int, default=700, help='threshold for STRING confidence score for considering a supported edge')
    parser.add_argument('--p_out_eval', '-p_out_eval', help='path of output file for evaluation', default='NONE')
    args = parser.parse_args()
    
    evaluate(p_in_net=args.p_in_net
             , nbr_top_edges=args.nbr_top_edges
             , nbr_edges_per_threshold=args.nbr_edges_per_threshold
             , threshold=args.threshold
             , p_STRING_db=args.p_STRING_db
             , STRING_confidence=args.STRING_confidence
             , p_out_eval=args.p_out_eval
            )    