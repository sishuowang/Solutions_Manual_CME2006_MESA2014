
This dataset from Steiper et al. (2004) is used in the book to illustrate the 
ML clock and local-clock estimation of species divergence times (look at baseml.ctl), 
as well as Bayesian clock and relaxed-clock dating.

(A) 
To run baseml for the likelihood analysis, open a command-line window, 
cd to the folder Steiper2004, and 

C:\Users\ziheng\Programs\paml4.7\bin\baseml baseml.Clock.ctl

C:\Users\ziheng\Programs\paml4.7\bin\baseml baseml.LocalClock.ctl

Use the correct path for the baseml program, depending on where you have 
installed paml.


(B)
To run mcmctree for the Bayesian analysis, open two command-line windows, 
cd to r1/ and r2/, and run two copies of the same analysis simultaneously 
to check consistency between runs. 
 
For example, in one window

cd r1
C:\Users\ziheng\Programs\paml4.7\bin\mcmctree ..\mcmctree.clock1.ctl

and in the other 

cd r2
C:\Users\ziheng\Programs\paml4.7\bin\mcmctree ..\mcmctree.clock1.ctl


Change the path for mcmctree depending on where you have installed paml.


ziheng yang
May 2013
