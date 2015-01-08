Don't Be A Dick: DBAD
=====================

A system for allowing video surveilance, while doing everything possible to
guard against unauthorized access to the recorded images.

A description of the system in Danish is available here:
http://osaa.dk/wiki/index.php/ProjectDontBeADick

Solution Overview
=================

It's assumed that a number of cameras are plugged into a box, called the crypto-box,
the crypto-box runs:

* Motion, which detects movement from each camera.
* For each captured image motion runs the included encrypt script.
* The encrypt script stores the encrypted copy of the photo in /disk
* The push-remote script copies new files from /disk to an off-site server.
* rekey is run as a cronjob about once a day to generate a new key.
* nuke-old is run as a cronjob once a minute to remove old files from local storage (and remotely on the remote storage servers) when space is running low or when the key-time is older than 29 days.


File systems
============

The crypto box needs three filesystems:

* /: Read-only for the OS.
* /ram: tmpfs (ram-based) file system for temporary clear-text.
* /disk: Persistent storage for local encrypted files, at least enough storage for a week of offline operation.  



Installation of SSSS
====================

We need SSSS to handle splitting and combining secrets, unfortunatly
the version shipped by ubuntu uses /dev/random, so it will hang for minutes
waiting for entropy, which makes it useless.

To get a generally less buggy and faster version of SSSS, clone and build this copy:
git clone https://github.com/dren-dk/SSSS.git && cd SSSS && make


Installation and GPG key config
===============================

Install gpg:
 sudo apt-get install gpgv2

...  and generate a private key for the crypto box:
 gpg --gen-key


Import the public keys for each of the board members into the gpg keychain:
 gpg --search-keys <email>

... and mark each key as trusted, after validating the fingerprints:
 gpg --edit-key <email>
  > trust
  > 5
  > y


Configuring remote storage
==========================

Storing the images locally is dangerous and too easy to sabotage, so at least one
remote storage server should be set up.

The push-remote script uses rsync to push new files from local storage to each of
the remote servers, so the first thing to do is to set up ssh key trust so
it's possible to run rsync from the crypto-box.

It's not a good idea to give the crypto-box shell access on the remote servers,
so a forced ssh command must be configured on the remote servers to allow only
the specific rsync command, this is done by adding the key to .ssh/authorized_keys with:

from="your-source-host.example.com",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-ptycommand="/home/remoteuser/remote-ssh-command" ssh-rsa ... 

To test sync to remote storage, run:
debug=1 ./push-remote

Using debug=1 causes the push-remote script to rsync to each of the remote servers in turn and exit, without forking.


Configuration of the encryption scripts
=======================================
 
Copy config.pl to ~/.dont-be-a-dick.config and edit it to match your installation,
nothing will work unless you understand and edit every single value.


Camera
======

Search for 1mp onvif ip camera on ebay and you will find a bunch of cameras such ash this: 
http://www.ebay.com/itm/CCTV-1MP-1280X720P-H264-P2P-36-LEDs-Waterproof-Outdoor-Security-IP-Camera-Onvif-/171436984448?pt=AU_Home_Personal_Security&hash=item27ea70c880

... that output h.264 over rtsp with a configurable frame rate and quality, which is much more effcient than
jpeg over http, which is often used by simpler cameras.

Unfortunately the software for this camera is utter shit and rather than implement a simple web UI for configuring
the camera, a special 32 bit windows application is needed and it only works with IE.

MS offers virtual machines for download that run 32bit IE, it seems windows 7 with IE 11 works with the shitty
camera configuration software: 
https://www.modern.ie/en-us/virtualization-tools


Building Motion
===============

The main stream version of Motion doesn't support streaming, unfortunatly many modern IP cameras only output
an h.264 stream via rtsp, so an alternative version of motion must be used with the needed support.

This page discusses the solution (bottom answer):
http://askubuntu.com/questions/514828/how-can-i-access-the-h264-stream-from-my-ip-cam-with-motion


First download, compile and install ffmpeg:
./configure --prefix=/opt/ffmpeg --disable-swresample && make && sudo make install


Then clone, patch and compile motion:
git clone git@github.com:dren-dk/motion.git

CFLAGS=-g ./configure --with-ffmpeg=/opt/ffmpeg/lib --with-ffmpeg-headers=/opt/ffmpeg/include
CFLAGS=-g make


Motion Keepalive
================

Motion likes to hang forever in stead of re-connecting to RTSP if any sort of problem (like camera reboot)
causes the stream to stop, so something more reliable is needed to take it out behind the barn when
it starts sulking and start it again.

