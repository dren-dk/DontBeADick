package Cammy;
require Exporter;
@ISA=qw(Exporter);
@EXPORT = qw(init config cfgBoard cfgRAM cfgLocalStorage cfgRemoteStorage cfgQuorum cfgGPGPassPhrase cfgSSSS cfgMotion cfgCamera cfgCameraNames);

use strict;
use warnings;
use Data::Dumper;

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

1;
