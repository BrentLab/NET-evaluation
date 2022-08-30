def process_result_file_into_dataframe(p_file
                                       , nbr_genes
                                      ):
    import numpy as np
    from pandas import DataFrame
    
    l_go_entries = []
    with open(p_file, 'r') as f:
        flag_start_p, flag_start = False, False
        for line in f.readlines():
            if line.startswith('Finding terms for P'):
                flag_start_p = True
            elif flag_start_p and line.startswith('-- '):
                flag_start = True
                go_id, term, corrected_pvalue, uncorrected_pvalue, fdr_rate, num_annotation, genes, nb_gene_go = [np.nan for _ in range(8)]
            elif flag_start and line.startswith('\n'):
                flag_start = False
                fold_enrichment = nbr_gene_inter*nbr_genes/(nbr_gene_net*nbr_gene_go)
                l_go_entries.append([go_id, term, corrected_pvalue, uncorrected_pvalue, fdr_rate, nbr_gene_inter, nbr_gene_net, nbr_gene_go, fold_enrichment, num_annotation, genes])
            elif line.startswith('Finding terms for C'):
                flag_start_p = False
                break
            elif flag_start:
                if line.startswith('GOID'):
                        go_id = line.split('\t')[1]
                        go_id = go_id[0:go_id.find('\n')]
                elif line.startswith('TERM'):
                    term = line.split('\t')[1]
                    term = term[0:term.find('\n')]
                elif line.startswith('CORRECTED P-VALUE'):
                    corrected_pvalue = line.split('\t')[1]
                    corrected_pvalue = corrected_pvalue[0:corrected_pvalue.find('\n')]
                elif line.startswith('UNCORRECTED P-VALUE'):
                    uncorrected_pvalue = line.split('\t')[1]
                    uncorrected_pvalue = uncorrected_pvalue[0:uncorrected_pvalue.find('\n')]
                elif line.startswith('FDR_RATE'):
                    fdr_rate = line.split('\t')[1]
                    fdr_rate = float(fdr_rate[0:fdr_rate.find('%')])
                elif line.startswith('NUM_ANNOTATIONS'):
                    num_annotation = line.split('\t')[1]
                    num_annotation = num_annotation[0:num_annotation.find('\n')]
                    nbr_gene_go = int(num_annotation.split(' ')[7])
                    nbr_gene_net = int(num_annotation.split(' ')[2])
                    nbr_gene_inter = int(num_annotation.split(' ')[0])
                elif line.startswith('The genes annotated'):
                    continue
                else:
                    genes = line
                    genes = genes[0:genes.find('\n')]
    df_go =DataFrame(l_go_entries, columns=['GOID', 'TERM', 'CORRECTED P-VALUE', 'UNCORRECTED P-VALUE', 'FDR RATE', 'NBR GENE INTER', 'NBR GENE NET', 'NBR GENE GO', 'FOLD ENRICHMENT', 'NUM ANNOTATION', 'GENES'])
    return df_go


def write_filtered_go_into_file(file
                                , p_dir_results
                                , nbr_genes
                               ):
    df_go = process_result_file_into_dataframe(p_dir_results + file
                                               , nbr_genes
                                              )
    df_go = df_go.loc[(df_go['FDR RATE'] <= 0.1) 
                      & (df_go['NBR GENE GO'] < 300)
                      & (df_go['NBR GENE GO'] > 4), :]
    if df_go.shape[0] > 0:
        df_go.to_csv(p_dir_results + file[0:file.find('.terms')] + '.tsv', header=True, index=False, sep='\t')

        
def filter_go_term_finder_results(p_dir_results
                                 , nbr_genes):
    from os import listdir
    from pandas import read_csv
    import multiprocessing as mp
    
    pool = mp.Pool(20)
    pool.starmap(write_filtered_go_into_file
                 , [(file
                     , p_dir_results
                     , nbr_genes
                    ) for file in listdir(p_dir_results) if file.endswith('.terms')])
    pool.close()
    pool.join()
            

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_out_dir', '-p_out_dir', help='path of output directory for GO-term-finder results')
    parser.add_argument('--nbr_genes', '-nbr_genes', type=int, help='total number of genes in the organism')
    
    args = parser.parse_args()
    
    filter_go_term_finder_results(p_dir_results=args.p_out_dir
                                  , nbr_genes=args.nbr_genes
                                 )
if __name__ == '__main__':
    main()