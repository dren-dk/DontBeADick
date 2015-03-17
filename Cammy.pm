package Cammy;
require Exporter;
@ISA=qw(Exporter);
@EXPORT = qw(init config cfgBoard cfgRAM cfgLocalStorage cfgRemoteStorage cfgQuorum cfgGPGPassPhrase cfgSSSS cfgMotion cfgCamera cfgCameraNames retire);

use strict;
use warnings;
use Data::Dumper;
use Filesys::Df;
use File::Path qw(make_path remove_tree);

my $config;
sub init {
    my $configFile = shift;
    die "Error: The config file $config doesn't exist: $config" unless -f $configFile;

    open CF, "<$configFile" or die "Failed to read $configFile $!";
    my $configContent = join '', <CF>;
    close CF;
    $config = eval $configContent;

    for my $k (qw(board ram disk quorum ssss gpgpass remote motion camera)) {
	die "Missing option: $k in ".Dumper $config unless $config->{$k};
    }
}

sub config() {
    return $config;
}

sub cfgBoard {
    return @{$config->{board}}
}

sub cfgRAM {
    return $config->{ram};
}

sub cfgLocalStorage {
    return $config->{disk};
}

sub cfgRemoteStorage {
    return @{$config->{remote}};
}

sub cfgQuorum {
    return $config->{quorum}; 
}

sub cfgSSSS {
    return $config->{ssss};
}

sub cfgGPGPassPhrase {
    return $config->{gpgpass};
}

sub cfgMotion {
    return $config->{motion};
}

sub cfgCamera {
    my ($name) = @_;
    return $config->{camera}{$name};
}

sub cfgCameraNames() {
    return sort keys %{$config->{camera}};
}

my $MIN_FREE = 150*1024; # The minimum number of free 1kB blocks 
my $MAX_AGE = 29; # The maximum age of the oldest directory in days.

sub retire {
    my ($dir) = @_;
    
    opendir DIR, $dir or die "Failed to read directory $dir: $!";
    my @dirs = sort grep {!/^\./} readdir DIR;
    closedir DIR;

    while (my $goner = shift @dirs) {
	my $fn = "$dir/$goner";
	my $mtime = (stat $fn)[9];
	my $age = (time-$mtime)/(24*60*60);
	my $free = df $dir;

	print STDERR "$fn: $age days old, free space: $free->{bfree}\n";

	if ($free->{bfree} < $MIN_FREE || $age > $MAX_AGE) {
	    print STDERR "Nuking\n";
	    remove_tree($fn);
	}
    }
}

1;
