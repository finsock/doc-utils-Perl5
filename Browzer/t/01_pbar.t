use strict;
use warnings;

use Test::More tests => 22;
use Image::EXIF;
use_ok('Browzer::ProgressBar', 'the ProgressBar module is loaded.');
       
my $source = "C:\\Users\\Public\\Pictures\\Sample Pictures\\";

opendir(my $dh, $source) || die "can't opendir $source: $!";
my @pictures = grep { /^\w+\.jpg/ && -f "$source/$_" } readdir($dh);
closedir $dh;

my $exif = Image::EXIF->new();
my $pbar = ProgressBar->new();

ok( defined $pbar, 'the ProgressBar object is created.' );
ok($pbar->isa('ProgressBar'), 'the object has a correct type (ProgressBar).');

is($pbar->set_titlebar_text( "Photographers" ), 1, 'the titlebar text is set'); 
ok($pbar->show(), 'Browser object of the user interface is created.');

my $percent = 0;
my $counter = 0;

for my $pic (@pictures){

	++$counter;

	$exif->file_name($source.$pic);
	my $camera_info = $exif->get_camera_info();
	my $photographer = defined $camera_info->{'Photographer'} ? $camera_info->{'Photographer'} : "Unknown";
	
	print $photographer . "\n";
	
	is($pbar->set_message_text( $counter . "/" . @pictures . " " . $pic ), 1, 'the message text is set.');
	
	$percent = int(( 100 * $counter / @pictures ) + 0.5 ); 
	ok($pbar->update($percent), 'ProgressBar object is updated.');
 
}

ok($pbar->close(), 'the ProgressBar object is closed.')