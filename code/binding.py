def calculate_support(l_net_predicted, l_net_supported):
    predicted = sum(l_net_predicted)
    supported = sum(l_net_supported)
    
    return (supported/predicted*100, supported, predicted)


def evaluate(p_in_net
             , p_binding_event
             , nbr_top_edges
             , nbr_edges_per_threshold
             , p_out_eval='NONE'
             ):
    
    from pandas import read_csv, DataFrame, melt
    from json import load

    # ===================================================================== #
    # |                       *** Read Input Data ***                     | #
    # ===================================================================== #
    
    df_net = read_csv(p_in_net, header=None, sep='\t')
    df_net.columns = ['REGULATOR', 'TARGET', 'VALUE']
    df_net = df_net[~df_net.VALUE.isnull()]  # do not consider values that are np.NaN
    df_net.loc[:, 'VALUE'] = df_net.loc[:, 'VALUE'].abs()  # take absolute value
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
    last_rank = nbr_top_edges*nbr_tf
    bin_size = nbr_edges_per_threshold*nbr_tf

    df_net['PREDICTED'] = (df_net['REGULATOR'].isin(list(set(df_binding_event['REGULATOR'].to_list())))
                           & df_net['TARGET'].isin(list(set(df_binding_event['TARGET'].to_list())))
                          ).astype(int)
    df_net['SUPPORTED'] = (df_net.index.isin(df_binding_event.index.to_list())).astype(int)

    l_net_predicted = list(df_net.loc[:, 'PREDICTED'])
    l_net_supported = list(df_net.loc[:, 'SUPPORTED'])
    
    import multiprocessing as mp
    
    l_t_per_nbr_nbr_pred = []
    
    pool = mp.Pool(5)
    l_t_per_nbr_nbr_pred = pool.starmap(calculate_support
                                        , [(l_net_predicted[0:i+bin_size], l_net_supported[0:i+bin_size])
                                           for i in range(0, last_rank, bin_size)])
    pool.close()
    pool.join()

        
    # write the evaluation into network
    df_eval = DataFrame(l_t_per_nbr_nbr_pred
                        , columns=['per', 'supported', 'predicted']
                        , index=[i for i in range(nbr_edges_per_threshold
                                             , nbr_top_edges+1
                                             , nbr_edges_per_threshold)
                                ]
                       )
    
    if p_out_eval:
        df_eval.iloc[:, 0].round(0).to_csv(p_out_eval, header=False, index=True, sep='\t')
    return df_eval.round(0)


if __name__ == "__main__":
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--p_in_net', '-p_in_net', help='path of input file for network')
    parser.add_argument('--nbr_top_edges', '-nbr_top_edges', nargs='?', type=int, default=50, help='number of top edges')
    parser.add_argument('--nbr_edges_per_threshold', '-nbr_edges_per_threshold', nargs='?', type=int, default=5, help='number of edges per threshold')
    parser.add_argument('--p_binding_event', '-p_binding_event', help='path of file for binding network with the form |REGULATOR|TARGET|')
    parser.add_argument('--p_out_eval', '-p_out_eval', nargs='?', help='path of output file for evaluation', default='NONE')
        
    args = parser.parse_args()
    
    evaluate(p_in_net=args.p_in_net
             , p_out_eval=args.p_out_eval
             , nbr_top_edges=args.nbr_top_edges
             , nbr_edges_per_threshold=args.nbr_edges_per_threshold
             , p_binding_event=args.p_binding_event
             )

