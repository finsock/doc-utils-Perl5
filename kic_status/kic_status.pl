#!/usr/bin/perl

use strict;
use warnings;

use XML::Simple;
use LWP::Simple;
use Win32;
use MIME::Base64;
use Log::Log4perl;

my $L4P_CONF = "kic_status.config";
my $APP_PATH = "G:\\Data\\Records Management Admin\\RM Task Automation";
my $APP_TITLE = "KIC PAN - Passive Alert Notification";

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
  
my %run_level_status = (
      MC_Running       	 		=> "The Message Connector is RUNNING.",
	  MC_Storage_Full   		=> "Fatal Error\n\nThe Message Connector STORAGE IS FULL!\nPlease call your KIC Administrator!",    
	  MC_Not_Running    		=> "Fatal Error\n\nThe Message Connector is NOT RUNNING!\nPlease call your KIC Administrator!",  
	  MC_Storage_Above_Target   => "Warning\n\nThe Message Connector STORAGE REACHES 90%.\nPlease call your KIC Administrator!",   	  
);
  
my $credentials = "VwlldzpFCVRAYV4xb2Nrcw=="; # Base64 obfuscation - not actual credentials
  
my $data = get('http://'.MIME::Base64::decode($credentials).'@kofaxprdfs:25086/call/master/GetState');

my $parser = new XML::Simple;
my $dom = $parser->XMLin($data);

my $run_level 		= $dom->{'c:RunLevel'};
my $storage_info 	= $dom->{'c:Components'}->{'c:Component'}->[18]->{'c:Info'};
my $fill_percent 	= $dom->{'c:Components'}->{'c:Component'}->[18]->{'c:Counters'}->{'c:fillpercent'};
my $visible_percent = $dom->{'c:Components'}->{'c:Component'}->[18]->{'c:Counters'}->{'c:visiblepercent'};

	Log::Log4perl->init( "$APP_PATH\\CONF\\$L4P_CONF" );
	$logger = Log::Log4perl->get_logger() or abort( "Could not find '$L4P_CONF'!" );

	if (( defined $storage_info and $storage_info ne "" ) and defined $run_level and defined $fill_percent and defined $fill_percent ) {

		my ( $messages, $disk_usage, $active ) = split( /\./, $storage_info );
		my ( $messages_text, $messages_value ) = split( /:/, $messages );
		my ( $disk_usage_text, $disk_usage_value ) = split( /:/, $disk_usage );
		my ( $active_text, $active_value ) = split( /:/, $active );
		
		$messages_text =~ s/^\s+//;
		$disk_usage_text =~ s/^\s+//;
		$active_text =~ s/^\s+//;
		
		$messages_value =~ s/^\s+//;
		$disk_usage_value =~ s/^\s+//;
		$active_value =~ s/^\s+//;
		
		if (( $run_level == 80 ) or ( $run_level == 0 )) {
			my $status = ( $run_level == 80 ) ? $run_level_status{ MC_Storage_Full } : $run_level_status{ MC_Not_Running };
			error("$status\n\nRun Level Status: [ $run_level ]", $run_level, $messages_value, $disk_usage_value, $active_value );
		} else {
			if ( $fill_percent >= 90 ) {
				warn("$run_level_status{MC_Storage_Above_Target}\n\nRun Level Status: [ $run_level ]\n\n$messages_text:\t\t$messages_value\n$disk_usage_text:\t$disk_usage_value\n$active_text:\t\t$active_value", $run_level, $messages_value, $disk_usage_value, $active_value );
			} else {
				inform("$run_level_status{MC_Running}\n\nRun Level Status: [ $run_level ]\n\n$messages_text:\t\t$messages_value\n$disk_usage_text:\t$disk_usage_value\n$active_text:\t\t$active_value", $run_level, $messages_value, $disk_usage_value, $active_value );
			}
		}
	} else {
		abort( "The KIC Monitor status information is not available!" );
	}
    
sub inform {
	my ( $msg, $runlev, $messval, $diskusg, $actval ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->info( "informed about status (INFO) - [ $runlev ], $messval, $diskusg, $actval" ) if defined $logger;
		Win32::MsgBox( $msg, $flags{Information}+$flags{OKOnly}, $APP_TITLE ) if (( defined $msg ) and ( $msg ne "" ));
	}
}

sub warn {
	my ( $msg, $runlev, $messval, $diskusg, $actval ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->warn( "informed about status (WARNING) - [ $runlev ], $messval, $diskusg, $actval" ) if defined $logger;
		Win32::MsgBox( $msg, $flags{Exclamation}+$flags{OKOnly}, $APP_TITLE ) if (( defined $msg ) and ( $msg ne "" ));
	}
}

sub error {
	my ( $msg, $runlev, $messval, $diskusg, $actval ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->error( "informed about status (ERROR) - [ $runlev ], $messval, $diskusg, $actval" ) if defined $logger;				
		Win32::MsgBox( "$msg\n\nAborting...", $flags{Critical}+$flags{OKOnly}, $APP_TITLE );
	}
}

sub abort {
	my ( $msg ) = @_;
	if ( ( defined $msg ) and ( $msg ne "" ) ) {
		$logger->error( "informed about status (ABORT) - $msg" ) if defined $logger;				
		Win32::MsgBox( "$msg\n\nAborting...", $flags{Critical}+$flags{OKOnly}, $APP_TITLE );
		exit;
	}
}