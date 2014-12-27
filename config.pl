{ # -*- mode: perl-mode -*-
    # This is an example config file for DBAD
    # Copy this file to ~/.dont-be-a-dick.config
    # and edit it to suit your installation.


    # Ram based file system, unencrypted data is stored here
    ram  =>'/home/ff/projects/DontBeADick/ram',

    # The local persistent storage, only encrypted data is stored here 
    disk=>'/home/ff/projects/DontBeADick/disk',

    # The emails of the board members, each of these public keys must be
    # imported and trusted by gpg:
    board=>['ff@osaa.dk', 
	    'brix@osaa.dk',
	    'paulbendixen@gmail.com',
	    'jacob@rotand.dk',
	    'mihtjel@mihtjel.dk'],

    # The number of board members that are needed to decrypt
    quorum=>3,

    # The directory were SSSS was built
    ssss=>'/home/ff/projects/ssss-0.5u', 

    # Passpharse needed to use the gpg private key
    gpgpass=>'passphrase-for-private-key', 

    # Remote target dirs to rsync the files from local storage to
    remote=>['dumbo:/mnt/data/photos/dbad/', 'hal.osaa.dk:storage/'],
}
