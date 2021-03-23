def process_result_file_into_dataframe(p_file):
    import numpy as np
    from pandas import DataFrame
    
    l_go_entries = []
    with open(p_file, 'r') as f:
        flag_start = False
        for line in f.readlines():
            if line.startswith('-- '):
                flag_start = True
                go_id, term, corrected_pvalue, uncorrected_pvalue, fdr_rate, num_annotation, genes = [np.nan for _ in range(7)]
            elif flag_start and line.startswith('\n'):
                flag_start = False
                l_go_entries.append([go_id, term, corrected_pvalue, uncorrected_pvalue, fdr_rate, num_annotation, genes])
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
                elif line.startswith('The genes annotated'):
                    continue
                else:
                    genes = line
                    genes = genes[0:genes.find('\n')]
    df_go =DataFrame(l_go_entries, columns=['GOID', 'TERM', 'CORRECTED P-VALUE', 'UNCORRECTED P-VALUE', 'FDR RATE', 'NUM ANNOTATION', 'GENES'])
    return df_go
    
def filter_go_term_finder_results(p_dir_results
                                 , p_metadata):
    from os import listdir
    from pandas import read_csv
    
    df_metadata = read_csv(p_metadata, header=0, sep='\t')
    l_go_id_bio_process = list(set(list(df_metadata.loc[df_metadata['namespace']== 'biological_process', 'id'])))
    for file in listdir(p_dir_results):
        if file.endswith('.terms'):
            df_go = process_result_file_into_dataframe(p_dir_results + file)
            df_go = df_go.loc[df_go['GOID'].isin(l_go_id_bio_process), :]
            df_go = df_go.loc[df_go['FDR RATE'] <= 10, :]
            if df_go.shape[0] > 0:
                df_go.to_csv(p_dir_results + file[0:file.find('.terms')] + '.tsv', header=True, index=False, sep='\t')
            

def main():
    from argparse import ArgumentParser
    
    parser = ArgumentParser()
    
    parser.add_argument('--p_dir_results', '-p_dir_results', help='path of output directory for GO-term-finder results')
    parser.add_argument('--p_metadata', '-p_metadata', help='path of metadata')
    
    args = parser.parse_args()
    
    filter_go_term_finder_results(p_dir_results=args.p_dir_results
                                 , p_metadata=args.p_metadata)
if __name__ == '__main__':
    main()