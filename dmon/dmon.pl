#!/usr/bin/perl

#  Directory Monitor (MS Windows)

#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#  Filename	     : dmon.pl 
#  Create date   : 06.09.2015
#  Author        : Csaba Gaspar <cgaspar AT finsock DOT com> 
#  Description   : Reports files with specific filename convention when uploaded to a particular directory.
#                    
#  Requires	     : Perl language support, Win32 module, GetOpt::Std module
#
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#  Usage         : dmon.pl -r regex -d "directory"
#
#  Where         :
#                  	"-r" command line option expects a regex to specify a file name convention 
#	                "-d" command line option expects a path to the directory to be monitored
#   
#                  The script can be run by MS Windows Task Scheduler agent to be automated. 
#
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

use strict;
use warnings;

use Win32;
use Getopt::Std;

my $USAGE = "Usage: $0 -r regex -d directory\n";

my %Opt;

getopts( 'r:d:', \%Opt ) or die $USAGE;

my $regex = $Opt{r} or die $USAGE; 
my $dir   = $Opt{d} or die $USAGE;

my $index = 0;

opendir my $dh, $dir or die "Couldn't open $dir: $!\n";

do { $index++ if defined $_ and /$regex/i } while readdir $dh;

closedir $dh;

Win32::MsgBox("You've got ".$index." new file(s) uploaded!", 64+0, 'Directory Monitor') if $index;
