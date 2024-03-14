          seed =  -1

       seqfile = demeter.nuc4L.txt
      Imapfile = demeter.Imap.txt
       outfile = out.txt
      mcmcfile = mcmc.txt

   speciesdelimitation = 1 1 2 1
   speciestree = 0

  species&tree = 2  D  E
                   30  20
                   (D, E);

       usedata = 1    * 0: no data (prior); 1:seq like
         nloci = 1    * number of data sets in seqfile (there are 53 loci in the data file)

     cleandata = 0    * remove sites with ambiguity data (1:yes, 0:no)?

    thetaprior = 3 0.002 e  # invgamma(a, b) for theta
      tauprior = 3 0.03    # invgamma(a, b) for root tau & Dirichlet(a) for other tau's

       finetune = 1: .01 .02 .03 .04 .05 .01 .01  # auto (0 or 1): MCMC step lengths

         print = 1 0 0 0   * MCMC samples, locusrate, heredityscalars Genetrees
        burnin = 10000
      sampfreq = 2
       nsample = 100000
