def evaluate_network(p_net
                     , p_eval
                     , p_reg
                     , p_target
                     , nbr_bins
                     , nbr_edges_per_reg
                     , p_binding_event
                     , fname_net
                    ):
    
    from pandas import read_csv, DataFrame, melt
    from json import load

    # ===================================================================== #
    # |                       *** Read Input Data ***                     | #
    # ===================================================================== #
    # read list of regualtors and target genes
#     l_reg = list(read_csv(p_reg, header=None)[0])
    if p_target != "NONE":
        l_target = list(read_csv(p_target, header=None)[0])
    
    # read input networks that we want to evaluate
    if isinstance(p_net, str):
        if (p_net != "NONE"):
            df_net = read_csv(p_net, header=None, sep='\t', low_memory=False)
        else:
            exit()
    elif isinstance(p_net, DataFrame):
        df_net = p_net
    # Change the shape of network to | Regulator | Target | Value |
    if df_net.shape[1] > 3:  # network is written in matrix, flatten the network
        df_net = read_csv(p_net, header=0, index_col=0, sep='\t')
        if df_net.shape[1] > len(l_target):
            df_net = df_net.dropna(axis='columns')
        df_net = melt(df_net.reset_index(), id_vars='index', value_vars=l_target)
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    df_net = df_net[~df_net.VALUE.isnull()]  # do not consider values that are np.NaN
    df_net.loc[:, 'VALUE'] = df_net.loc[:, 'VALUE'].abs()
    df_net = df_net.sort_values(ascending=False, by='VALUE')  # sort based on the score values
    df_net.index = [(reg, target) for reg, target in zip(list(df_net['REGULATOR']), df_net['TARGET'])]
    
    # get the regulators that do exist in binding data, and ignore the others 
    df_binding_event = read_csv(p_binding_event, header=0, sep='\t')
    df_net = df_net[df_net.REGULATOR.isin(list(set(df_binding_event.REGULATOR.to_list()))) 
                    & df_net.TARGET.isin(list(set(df_binding_event.TARGET.to_list())))]
    l_reg_binding = list(set(df_net[df_net.REGULATOR.isin(list(set(df_binding_event.REGULATOR.to_list())))].REGULATOR.to_list()))
    
    # ===================================================================== #
    # |                  *** Evaluation by Percentage ***                 | #
    # ===================================================================== #
    # Read evaluation network, this can be binding or PWM network
    df_binding_event.index = [(reg, target) for reg, target in zip(list(df_binding_event['REGULATOR']), df_binding_event['TARGET'])]

    # Calculate the number of predicted and supported edges
    nbr_tf = len(l_reg_binding)
    last_rank = int(nbr_tf * nbr_edges_per_reg)
    bin_size = int(last_rank/nbr_bins)

    df_net['PREDICTED'] = (df_net['REGULATOR'].isin(list(set(df_binding_event['REGULATOR'].to_list())))
                           & df_net['TARGET'].isin(list(set(df_binding_event['TARGET'].to_list())))
                          ).astype(int)
    df_net['SUPPORTED'] = (df_net.index.isin(df_binding_event.index.to_list())).astype(int)

    l_x, l_per_sup, l_nbr_sup,  l_nbr_pred = [], [], [], []
    for i in range(0, last_rank, bin_size):
        df_net_bin = df_net.iloc[0:i+bin_size, :]
        predicted = sum(df_net_bin['PREDICTED'])
        supported = sum(df_net_bin['SUPPORTED'])
        l_x.append(i+bin_size)
        l_per_sup.append(supported/predicted*100)
        l_nbr_sup.append(supported)
        l_nbr_pred.append(predicted)

        
    # write the evaluation into network
    df_eval = DataFrame({fname_net: l_per_sup})
    df_eval_nbr_sup = DataFrame({fname_net: l_nbr_sup})
    df_eval_nbr_pred = DataFrame({fname_net: l_nbr_pred})
    
    if p_eval:
        df_eval.T.to_csv(p_eval, header=False, index=True, sep='\t', mode='a')
    return df_eval


if __name__ == "__main__":
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_net', '-p_net', help='path of input file for network')
    parser.add_argument('--p_eval', '-p_eval', help='path of output file for evaluation')
    parser.add_argument('--fname_net', '-fname_net', help='name of data or network', nargs='?', default="")
    parser.add_argument('--p_reg', '-p_reg', nargs='?', default='NONE', help='path of file for list of regulators')
    parser.add_argument('--p_target', '-p_target', nargs='?', default='NONE', help='path of file for list of target genes')
    parser.add_argument('--nbr_bins', '-nbr_bins', nargs='?', default=20, type=int, help='nbre of cutoffs (default 20)')
    parser.add_argument('--nbr_edges_per_reg', '-nbr_edges_per_reg', nargs='?', default=100, type=int, help='nbre of edges per regulator in total (default 100)')
    parser.add_argument('--p_binding_event', '-p_in_binding_event', help='path of file for binding network with the form |REGULATOR|TARGET|VALUE|')
    
    args = parser.parse_args()
    
    evaluate_network(p_net=args.p_net
                     , p_eval=args.p_eval
                     , fname_net=args.fname_net
                     , p_reg=args.p_reg
                     , p_target=args.p_target
                     , nbr_bins=args.nbr_bins
                     , nbr_edges_per_reg=args.nbr_edges_per_reg
                     , p_binding_event=args.p_binding_event
                    )
