#!/usr/bin/perl

#  Directory Monitor (MS Windows)

#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#  Filename	 : dmon.pl 
#  Create date   : 06.09.2015
#  Author        : Csaba Gaspar <cgaspar AT finsock DOT com> 
#  Description   : Reports files with specific filename convention when uploaded to a particular directory.
#                    
#  Requires	 : Perl language support
#
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#  Usage         : dmon.pl -r regex -d "directory"
#
#		   Where:
# 
#                  	"-r" command line option expects a regex to specify a file name convention 
#	                "-d" command line option expects a path to the directory to be monitored
#   
#                  The script can be run by MS Windows Task Scheduler agent to be automated. 
#
#''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

use strict;
use warnings;

# For MsgBox Win32 module needs to be used
use Win32;

# For a simple but professional command line option handling 
# Getopt::Std module needs to be used
use Getopt::Std;

# We specify the USAGE string for die
my $USAGE = "Usage: $0 -r regex -d directory\n";

# %Opt hash will carry our command line options and their 
# actual values
my %Opt;

# The command line options need to be read and stored
getopts( 'r:d:', \%Opt ) or die $USAGE;

my $regex = $Opt{r} or die $USAGE; 
my $dir   = $Opt{d} or die $USAGE;

# $index will act as a counter for files obeying the specified 
# naming convention
my $index = 0;

# To be able to access the specified directory we need to create 
# a directory handle
opendir my $dh, $dir or die "Couldn't open $dir: $!\n";

# Any file in the specified directory obeying the given naming 
# convention will increase our file counter by one
do { $index++ if defined $_ and /$regex/i } while readdir $dh;

# Rerelasing the directory handle explicitely is a good coding 
# practice
closedir $dh;

# MsgBox provides us with a standard Windows dialogbox to report 
# whatever we found. The second parameter (FLAGS) specifies the required 
# icon (64 -> "i" in a bubble) and buttons (0 -> OK button) 
Win32::MsgBox("You've got ".$index." new file(s) uploaded!", 64+0, 'Directory Monitor') if $index;
