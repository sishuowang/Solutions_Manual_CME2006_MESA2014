          seed = -1

       seqfile = demeter.nuc4L.txt
      Imapfile = demeter.Imap.txt
      mcmcfile = mcmc.out
       outfile = out

 speciesdelimitation = 0 * fixed species tree
* speciesdelimitation = 1 0 5    * speciesdelimitation algorithm0 and finetune(e)
 speciesdelimitation = 1 1 2 1  * speciesdelimitation algorithm1 finetune (a m)

speciesmodelprior = 1         * 0: uniform labeled histories; 1:uniform rooted trees; 2:user probs

  species&tree = 2  D  E
                   30  20
                   (D, E);

       usedata = 1  * 0: no data (prior); 1:seq like
         nloci = 1  * number of data sets in seqfile

     cleandata = 0  * remove sites with ambiguity data (1:yes, 0:no)?

    thetaprior = 3 500   # gamma(a, b) for theta
      tauprior = 2 2000  # gamma(a, b) for root tau & Dirichlet(a) for other tau's

*      heredity = 0 4 4   # (0: No variation, 1: estimate, 2: from file) & a_gamma b_gamma (if 1)
*     locusrate = 0 2.0   # (0: No variation, 1: estimate, 2: from file) & a_Dirichlet (if 1)
* sequenceerror = 0 0 0 0 : 0.05 1   # sequencing errors: gamma(a, b) prior

      finetune = 1: 1.2 .0005 .002 .0002 .2 .25 1.0  # finetune for GBtj, GBspr, theta, tau, mix, locusrate, seqerr

         print = 1 0 0 0
        burnin = 10000
      sampfreq = 2
       nsample = 100000
