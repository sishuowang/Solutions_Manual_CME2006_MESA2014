          seed = -1

       seqfile = ../../Steiper2004ABCDE.txt
      treefile = ../../Steiper2004.MCMCtree.trees
       outfile = out

       usedata = 1    * 0: no data; 1:seq like; 2:normal like
         ndata = 5
         clock = 1    * 1: global clock; 2: independent rates; 3: correlated rates
       RootAge = '<0.6'  * safe constraint on root age, used if no fossil for root.

         model = 0    * 0:JC69, 1:K80, 2:F81, 3:F84, 4:HKY85
         alpha = 0   * alpha for gamma rates at sites
         ncatG = 5    * No. categories in discrete gamma

     cleandata = 0    * remove sites with ambiguity data (1:yes, 0:no)?

       BDparas = 1 1 0   * birth, death, sampling
   kappa_gamma = 2 0.5       * gamma prior for kappa
   alpha_gamma = 2 2       * gamma prior for alpha
   rgene_gamma = 2 2       * gamma prior for rate for genes
  sigma2_gamma = 1 10      * gamma prior for sigma^2

      finetune = 1: .05  0.05  0.2  0.2  1  * times, rates, paras, mixing, RateParas

         print = 1
        burnin = 8000
      sampfreq = 2
       nsample = 20000
