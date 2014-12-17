DontBeADick
===========

A system for allowing video surveilance, while doing everything possible to
guard against unauthorized access to the recorded images.

A description of the system in Danish is available here:
http://osaa.dk/wiki/index.php/ProjectDontBeADick

We need SSSS to handle splitting and combining secrets, unfortunatly
the version shipped by ubuntu uses /dev/random, so it will hang for minutes
waiting for entropy.

To get a generally less buggy and faster version of SSSS, clone and build:
git clone https://github.com/dren-dk/SSSS.git && cd SSSS && make



