#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Image::EXIF;
use Browzer::ProgressBar;
       
my $source = "C:\\Users\\Public\\Pictures\\Sample Pictures\\";

opendir(my $dh, $source) || die "can't opendir $source: $!";
my @pictures = grep { /^\w+\.jpg/ && -f "$source/$_" } readdir($dh);
closedir $dh;

my $exif = Image::EXIF->new();
my $pbar = ProgressBar->new();

$pbar->set_titlebar_text( "Photographers" );
$pbar->show();

my $percent = 0;
my $counter = 0;

for my $pic (@pictures){

	++$counter;

	$exif->file_name($source.$pic);
	my $camera_info = $exif->get_camera_info();
	my $photographer = defined $camera_info->{'Photographer'} ? $camera_info->{'Photographer'} : "Unknown";
	
	print $photographer . "\n";

	$pbar->set_message_text( $counter . "/" . @pictures . " " . $pic );
	
	$percent = int(( 100 * $counter / @pictures ) + 0.5 ); 
	$pbar->update($percent);
 
}

$pbar->close();
 