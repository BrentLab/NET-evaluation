calculate_pvalue = function(l_target
                            , flag_save_intermediate
                            , p_intermediate
                            , enrich_method
                            , organism
                            , enrich_database
                            , interest_gene_type
                            , reference_set
                            , reference_gene_type
                            , sig_method
                            , set_cover_num
                            , fdr_threshold
                            , top_threshold
                            , min_num
                            , max_num){
  pvalue=tryCatch({
    df_go = WebGestaltR(enrichMethod=enrich_method
                        , organism=organism
                        , enrichDatabase=enrich_database
                        , interestGene=l_target
                        , interestGeneType=interest_gene_type
                        , referenceSet=reference_set
                        , referenceGeneType=reference_gene_type
                        , isOutput=FALSE
                        , projectName=NULL
                        , sigMethod=sig_method
                        , setCoverNum =set_cover_num
                        , fdrThr=fdr_threshold
                        , topThr=top_threshold
                      )
    pvalue = df_go[1, "pValue"]
  }, error = function(err){
    pvalue = 1
  }, finally = {
    pvalue
  })
  
  if (flag_save_intermediate == "ON"){
    write.table(
      file=p_intermediate
      , x=df_go
      , row.names=FALSE, col.names=TRUE,  sep='\t', quote=FALSE)
  }
  pvalue
}
calculate_sum_minus_log_pvalues = function(p_net
                                           , flag_match
                                           , p_dict_match
                                           , p_eval
                                           , nbr_edges_per_reg
                                           , flag_save_intermediate
                                           , p_dir_intermediate
                                           # WebGestaltR parameters
                                           , enrich_method
                                           , organism
                                           , enrich_database
                                           , interest_gene_type
                                           , reference_set
                                           , reference_gene_type
                                           , sig_method
                                           , set_cover_num
                                           , fdr_threshold
                                           , top_threshold
                                           , min_num
                                           , max_num
                                           ){
  if (flag_match == "ON"){
    d_match = fromJSON(paste(readLines(p_dict_match), collapse=""))
  }
  df_net = read.csv(p_net, header=FALSE, sep='\t')
  sum = 0
  if (dim(df_net)[2] > 3){
    df_net = read.csv(p_net, header=TRUE, row.names=1, sep='\t')
  } 
  colnames(df_net) = c('REGULATOR', 'TARGET', 'VALUE')
  nbr_reg = length(unique(df_net$REGULATOR))
  df_net = df_net[order(-df_net$VALUE), ]
  df_net = df_net[seq(nbr_reg*nbr_edges_per_reg), ]
  for (reg in unique(df_net$REGULATOR)){
    print(reg)
    l_target = df_net[df_net$REGULATOR == reg, "TARGET"]
    l_target = sapply(unlist(l_target), function(x) d_match[x][[1]])
    pvalue = calculate_pvalue(l_target=l_target
                              , flag_save_intermediate=flag_save_intermediate
                              , p_intermediate=paste(p_dir_intermediate, paste(reg, ".tsv", sep=""), sep="") 
                              # WebGestaltR parameters
                              , enrich_method=enrich_method
                              , organism=organism
                              , enrich_database=enrich_database
                              , interest_gene_type=interest_gene_type
                              , reference_set=reference_set
                              , reference_gene_type=reference_gene_type
                              , sig_method=sig_method
                              , set_cover_num=set_cover_num
                              , fdr_threshold=fdr_threshold
                              , top_threshold=top_threshold
                              , min_num=min_num
                              , max_num=max_num
                              )
    if (!is.null(pvalue)){
      sum = sum -log(pvalue)
    }
  }

  write.table(
    file=p_eval
    , x=data.frame(c(sum))
    , row.names=FALSE, col.names=FALSE,  sep='\t', quote=FALSE)

}

if (sys.nframe() == 0){
  # =========================================== #
  # |       *** Install packages ***          | #
  # =========================================== #
  if (!require(optparse)){
    install.packages("optparse", repo="http://cran.rstudio.com/")
    library("optparse")
  }
  
  if (!require(rjson)){
    install.packages("rjson")
    library("rjson")
  }
  
  if (!require("WebGestaltR")){
    install.packages("WebGestaltR")
    library("WebGestaltR")
  }
  
  # =========================================== #
  # |         **** Parse Arguments ****       | #
  # =========================================== #
  opt_parser = OptionParser(option_list=list(
    p_in_net = make_option(c("--p_in_net"), type="character")
    , flag_match = make_option(c("--flag_match"))
    , p_dict_match = make_option(c("--p_dict_match"))
    , p_out_eval = make_option(c("--p_out_eval"))
    , flag_save_intermediate = make_option(c("--flag_save_intermediate"))
    , p_dir_intermediate = make_option(c("--p_dir_intermediate"))
    , nbr_edges_per_reg = make_option(c("--nbr_edges_per_reg"), type="integer", default=100)
    
    # WebGestaltR
    , enrich_method = make_option(c("--enrich_method"), type="character", default="ORA")
    , organism = make_option(c("--organism"), type="character", default="scerevisiae")
    , enrich_database = make_option(c("--enrich_database"), type="character", default="geneontology_Biological_Process_noRedundant")
    , interest_gene_type = make_option(c("--interest_gene_type"), type="character", default="genesymbol")
    , reference_set = make_option(c("--reference_set"), type="character", default="genome_protein-coding")
    , reference_gene_type = make_option(c("--reference_gene_type"), type="character", default="genesymbol")
    , sig_method = make_option(c("--sig_method"), type="character", default="fdr")
    , set_cover_num = make_option(c("--set_cover_num"), type="integer", default=10)
    , fdr_threshold = make_option(c("--fdr_threshold"), type="double", default=0.05)
    , top_threshold = make_option(c("--top_threshold"), type="integer", default=10)
    , min_num = make_option(c("--min_num"), type="integer", default=10)
    , max_num = make_option(c("--max_num"), type="integer", default=500)
   ))
  opt = parse_args(opt_parser, positional_arguments = TRUE)$options
  
  calculate_sum_minus_log_pvalues(p_net=opt$p_in_net
                                  , flag_match=opt$flag_match
                                  , p_dict_match=opt$p_dict_match
                                  , p_eval=opt$p_out_eval
                                  , nbr_edges_per_reg=opt$nbr_edges_per_reg
                                  , flag_save_intermediate=opt$flag_save_intermediate
                                  , p_dir_intermediate=opt$p_dir_intermediate 
                                  # WebGestaltR parameters
                                  , enrich_method=opt$enrich_method
                                  , organism=opt$organism
                                  , enrich_database=opt$enrich_database
                                  , interest_gene_type=opt$interest_gene_type
                                  , reference_set=opt$reference_set
                                  , reference_gene_type=opt$reference_gene_type
                                  , sig_method=opt$sig_method
                                  , set_cover_num=opt$set_cover_num
                                  , fdr_threshold=opt$fdr_threshold
                                  , top_threshold=opt$top_threshold
                                  , min_num=opt$min_num
                                  , max_num=opt$max_num
                                  )
}


 
