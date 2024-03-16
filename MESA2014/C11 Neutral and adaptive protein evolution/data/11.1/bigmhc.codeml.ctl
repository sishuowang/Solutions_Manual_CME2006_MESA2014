      seqfile = bigmhc.phy
     treefile = bigmhc.trees

      outfile = mlc
        noisy = 3
      verbose = 0
      runmode = 0

      seqtype = 1
    CodonFreq = 2  * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
                   * 4:F1x4MG, 5:F3x4MG, 6:FMutSel0, 7:FMutSel
*      estFreq = 0  * 0: use observed freqs; 1: estimate freqs by ML

   aaRatefile = jones.dat
        model = 0
      NSsites = 8
                   * 0:one w;1:NearlyNeutral;2:PositiveSelection; 3:discrete;
                   * 4:freqs;5:gamma;6:2gamma;7:beta;8:beta&w+;9:beta&gamma;
                   * 10:beta&gamma+1; 11:beta&normal>1; 12:0&2normal>1;
                   * 13:3normal>0;
        icode = 0
    fix_kappa = 0
        kappa = 1.6
    fix_omega = 0
        omega = .9

        ncatG = 10
        getSE = 0

   Small_Diff = .1e-6
*    cleandata = 1
   fix_blength = 2  * 0: ignore, -1: random, 1: initial, 2: fixed
