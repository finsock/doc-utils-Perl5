#!/usr/bin/perl
use strict;
use warnings;
use Win32;
use Log::Log4perl;
use File::stat;
use Time::localtime;

my $L4P_CONF = "dip_alerter.config";
my $APP_TITLE = "OnBase DIP Alerter";
my $APP_PATH = "G:\\Data\\Records Management Admin\\RM Task Automation";
my $TOLERANCE = 30;

my $dir = "\\\\KOFAXPRDFS\\CaptureSV\\ReleaseTC\\AP Invoices";
my $index = 0;

my $logger;

my %flags = (
    OKOnly           => 0,    # Display OK button only.
    OKCancel         => 1,    # Display OK and Cancel buttons.
    AbortRetryIgnore => 2,    # Display Abort, Retry, and Ignore buttons.
    YesNoCancel      => 3,    # Display Yes, No, and Cancel buttons.
    YesNo            => 4,    # Display Yes and No buttons.
    RetryCancel      => 5,    # Display Retry and Cancel buttons.
    Critical         => 16,   # Display Critical Message icon.
    Question         => 32,   # Display Warning Query icon.
    Exclamation      => 48,   # Display Warning Message icon.
    Information      => 64,   # Display Information Message icon.
    DefaultButton1   => 0,    # First button is default.
    DefaultButton2   => 256,  # Second button is default.
    DefaultButton3   => 512,  # Third button is default.
    DefaultButton4   => 768,  # Fourth button is default.
    ApplicationModal => 0,    # The user must respond to the message box before continuing work in the current application.
    SystemModal      => 4096, # All applications are suspended until the user responds to the message box.
);

	Log::Log4perl->init( "$APP_PATH\\CONF\\$L4P_CONF" );
	$logger = Log::Log4perl->get_logger() or abort( "Could not find '$L4P_CONF'!" );
	
	opendir my $dh, $dir or die "Couldn't open $dir: $!\n";

	do { $index++ if defined $_ and /\A(?:.+)(?:\.txt)\z/ } while readdir $dh;

	closedir $dh;
		
	inform( "Warning! ".$index." export file(s) are waiting for OnBase document import!\nPlease call Svetlana (7985)!", $index ) if $index > $TOLERANCE;
	
sub inform {
	my ( $msg, $idx ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->info( "informed about [ $idx ] unexported file(s)" ) if defined $logger;
		Win32::MsgBox( $msg, $flags{Information}+$flags{OKOnly}, $APP_TITLE ) if (( defined $msg ) and ( $msg ne "" ));
	}
}

sub abort {
	my ( $msg ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->error( $msg ) if defined $logger;				
		Win32::MsgBox( "$msg\n\nAborting...", $flags{Critical}+$flags{OKOnly}, $APP_TITLE );
		exit;
	}
}
