calculate_pvalue = function(l_target
                            , flag_save_intermediate
                            , p_intermediate
                            , enrichMethod
                            , organism
                            , enrichDatabase
                            , interestGeneType
                            , referenceSet
                            , referenceGeneType
                            , sigMethod
                            , setCoverNum
                            , fdrThr
                            , topThr
                            , minNum
                            , maxNum){
  pvalue=tryCatch({
      df_go = WebGestaltR(enrichMethod=enrichMethod
                        , organism=organism
                        , enrichDatabase=enrichDatabase
                        , interestGene=l_target
                        , interestGeneType=interestGeneType
                        , referenceSet=referenceSet
                        , referenceGeneType=referenceGeneType
                        , isOutput=FALSE
                        , projectName=NULL
                        , sigMethod=sigMethod
                        , setCoverNum =setCoverNum
                        , fdrThr=fdrThr
                        , topThr=topThr
                      )
      if (dim(df_go)[1] < 1){
          pvalue = 1
      } else {
          pvalue = df_go[1, "pValue"]
          if (flag_save_intermediate == "ON"){
                write.table(
                  file=p_intermediate
                  , x=df_go
                  , row.names=FALSE, col.names=TRUE,  sep='\t', quote=FALSE)
          }
      }
      pvalue

  }, error = function(err){
    pvalue = 1

  })
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
                                           , enrichMethod
                                           , organism
                                           , enrichDatabase
                                           , interestGeneType
                                           , referenceSet
                                           , referenceGeneType
                                           , sigMethod
                                           , setCoverNum
                                           , fdrThr
                                           , topThr
                                           , minNum
                                           , maxNum
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
                              , enrichMethod=enrichMethod
                              , organism=organism
                              , enrichDatabase=enrichDatabase
                              , interestGeneType=interestGeneType
                              , referenceSet=referenceSet
                              , referenceGeneType=referenceGeneType
                              , sigMethod=sigMethod
                              , setCoverNum=setCoverNum
                              , fdrThr=fdrThr
                              , topThr=topThr
                              , minNum=minNum
                              , maxNum=maxNum
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
  library("optparse")
  library("rjson")
  library("WebGestaltR")
  
  # =========================================== #
  # |         **** Parse Arguments ****       | #
  # =========================================== #
  opt_parser = OptionParser(option_list=list(
    p_net = make_option(c("--p_net"), type="character")
    , flag_singularity = make_option(c("--flag_singularity"), type="character")
    , flag_match = make_option(c("--flag_match"))
    , p_dict_match = make_option(c("--p_dict_match"))
    , p_eval = make_option(c("--p_eval"))
    , flag_save_intermediate = make_option(c("--flag_save_intermediate"))
    , p_dir_intermediate = make_option(c("--p_dir_intermediate"))
    , nbr_edges_per_reg = make_option(c("--nbr_edges_per_reg"), type="integer", default=100)
    
    # WebGestaltR
    , enrichMethod = make_option(c("--enrichMethod"), type="character", default="ORA")
    , organism = make_option(c("--organism"), type="character", default="scerevisiae")
    , enrichDatabase = make_option(c("--enrichDatabase"), type="character", default="geneontology_Biological_Process_noRedundant")
    , interestGeneType = make_option(c("--interestGeneType"), type="character", default="genesymbol")
    , referenceSet = make_option(c("--referenceSet"), type="character", default="genome_protein-coding")
    , referenceGeneType = make_option(c("--referenceGeneType"), type="character", default="genesymbol")
    , sigMethod = make_option(c("--sigMethod"), type="character", default="fdr")
    , setCoverNum = make_option(c("--setCoverNum"), type="integer", default=10)
    , fdrThr = make_option(c("--fdrThr"), type="double", default=0.05)
    , topThr = make_option(c("--topThr"), type="integer", default=10)
    , minNum = make_option(c("--minNum"), type="integer", default=10)
    , maxNum = make_option(c("--maxNum"), type="integer", default=500)
   ))
  opt = parse_args(opt_parser, positional_arguments = TRUE)$options
  
  calculate_sum_minus_log_pvalues(p_net=opt$p_net
                                  , flag_match=opt$flag_match
                                  , p_dict_match=opt$p_dict_match
                                  , p_eval=opt$p_eval
                                  , nbr_edges_per_reg=opt$nbr_edges_per_reg
                                  , flag_save_intermediate=opt$flag_save_intermediate
                                  , p_dir_intermediate=opt$p_dir_intermediate 
                                  # WebGestaltR parameters
                                  , enrichMethod=opt$enrichMethod
                                  , organism=opt$organism
                                  , enrichDatabase=opt$enrichDatabase
                                  , interestGeneType=opt$interestGeneType
                                  , referenceSet=opt$referenceSet
                                  , referenceGeneType=opt$referenceGeneType
                                  , sigMethod=opt$sigMethod
                                  , setCoverNum=opt$setCoverNum
                                  , fdrThr=opt$fdrThr
                                  , topThr=opt$topThr
                                  , minNum=opt$minNum
                                  , maxNum=opt$maxNum
                                  )
}


 
