package ProgressBar;

=pod

=head1 NAME

ProgressBar - A Win32 OLE/IE based progress indicator

=head1 SYNOPSIS

	#!/usr/bin/perl

	use strict;
	use warnings;

	use Image::EXIF;
	use Browzer::ProgressBar;
	       
	my $source = "C:\\Users\\Public\\Pictures\\Sample Pictures\\";

	opendir(my $dh, $source) || die "can't opendir $source: $!";
	my @pictures = grep { /^\w+\.jpg/ && -f "$source/$_" } readdir($dh);
	closedir $dh;

	my $exif = Image::EXIF->new();
	my $pbar = ProgressBar->new();

	$pbar->set__titlebar_text( "Photographers" );
	$pbar->show();

	my $percent = 0;
	my $counter = 0;

	for my $pic (@pictures){

		++$counter;

		$exif->file_name($source.$pic);
		my $camera_info = $exif->get_camera_info();
		my $photographer = defined $camera_info->{'Photographer'} ? $camera_info->{'Photographer'} : "Unknown";
		
		print $photographer . "\n";

		$pbar->set__message_text( $counter . "/" . @pictures . " " . $pic );
		
		$percent = int(( 100 * $counter / @pictures ) + 0.5 ); 
		$pbar->update($percent);
	 
	}

	$pbar->close();

=head1 DESCRIPTION

The ProgressBar Perl module aims to be a simple browser based tool to visualize the progress of 
any automated batch processes in a situation, where standard output is not an option for feedback. 
=head2 Dependency

	- Win32::OLE module

Since the ProgressBar class utilizes the Win32::OLE module, it's theoretically a platform dependent 
solution, which will primarily work in MS Windows OS environment (using OLE automation 
on Linux is rare, but not completely unheard of: Wine makes it possible to run Windows programs 
alongside any Unix-like operating system, and moreover, even MS Office installs on Linux). 
For mimicking simple Windows GUI functionality, Win32::OLE module offers a lightweight, 
compact design, which lets you avoid robust modules, like Win32::GUI. 

	- HTML::Template

The HTML content of the module interface could be implemented by sending hard-wired HTML code to
the DHTML document object of the page, as it really means only a few lines, but it is not an elegant 
solution, especially if it aims to offer some extra customization options. The HTML::Template 
module makes an ideal tool to bring some good coding practices and portability into the picture 
with a more flexible functionality.

=head2 Basic concept

If you programatically maintain huge collections of items, your workflows most certainly will  
be built around iterative actions, sometimes with long running cycles. Feedback for users in 
regards to progress may easily become vital, especially where longer duration time is inevitable. 
You can provide a very simple visual feedback by implementing ProgressBar module into your code.

=head3 How to use the module

1. B<Object declaration>: 
	my $pbar = ProgressBar->new();
It's quite easy to create a ProgressBar object from code, because it doesn't take any arguments. 
Its class and object data members are initialized automatically, but some of the object variables 
can be set through simple object methods.

2. B<Data feed>:

	my $counter = 0;
	my $percent = 0;

You'll need to indirectly provide the ProgressBar object with a counter and a percent value, for 
which you may want to declare two numeric literals in the same scope where the ProgressBar object 
was created. These values drive the state of the ProgressBar object and help refresh the 
progressbar element of the interface window.
The counter value represents the factual number of the item beeing processed, thus - for the sake 
of simplicity - its assignment works on the assumption that its initial value (prior to the first 
"update" object method call) is set to 1. Please notice, that this value is initially set to 0 
in the example in the synopsis, but it's incremented inside the loop before the actual "update" 
method call.
If you must use C-style "for" loop for the processing, you need to properly set the loop condition, 
as it is highly susceptible to 'off by one' errors. 

3. B<Literal feedback>
	$pbar->set_titlebar_text( "Photographers" );
	$pbar->set_message_text( $counter . "/" . @pictures . " " . $pic );

The ProgressBar object is prepared to report a generic and a current collection element related message
in the simple browser based user interface, above and below the actual progressbar. The generic message
appears in the titlebar content (in the HTML DOM document title property) of the browser window and 
also above the progressbar (this latter line is combined with the actual percentage value of the  
number of the element being processed). The current element related message can indicate any element 
specific information below the progressbar you consider important.

The generic information needs to be set only once outside of the processing loop using the 
set__titlebar_text() object method, while the element specific information should be updated from
inside the process loop in each cycle using the set__message_text() object method of the ProgressBar 
object.4. B<Opening the user interface>
	$pbar->show();

When the ProgressBar object is fully prepared, calling the C<show> object method once from outside the
processing loop opens up the user simple, browser based interface. Its HTML content will be refreshed
cycle by cycle from inside the loop.	
5. B<Updating the object state>

	$pbar->update($percent);
The ProgressBar object has to be updated after each iteration from inside your processing loop by calling 
the "update()" object method. This method has an important argument: the percantage, which represents 
the current element in the whole collection. Using the following elementery formula, you can calculate this
value easily and pass it to the object method:

	$percent = int(( 100 * $counter / @pictures ) + 0.5 );
The @pictures array in the above example is placed into scalar context, hence it represents the size of the 
array, that is, the total number of elements in your collection. 
6. B<Closing the user interface>

	$pbar->close();
	
The ProgressBar module doesn't really need an explicit destructor method, Perl takes care of the memory 
for you, but you might need to close the user interface of your ProgressBar object right after the 
processing loop iterates your entire collection. You can do this by calling the "Close()" object method.
=head2 Customizing the bar

The cool part of the object is its simple design. The default look of the bar itself aims to be a humble 
reminiscence of the atavistic progressbars known typically from old text user interfaces of the 1980s and 
1990s (e.g. Norton Commander). Its building block is a text-based semigraphics (a UTF-8 block element with 
an HTML entity of &#x2591) called "LIGHT SHADE".
If you want to customize this default look by changing the face or number of the bar building blocks, you 
can actually do it by altering the values of three class data members by changing the parameters of the 
C<__init_bar> mutator method in the constructor of the ProgressBar class. These data members are:

	$__BAR_CHAR_FACE   - the HTML entity of the LIGHT SHADE block element   
	$__BAR_CHAR_NUM    - the number of block elements (the length) of the entire bar
	$__BAR_CHAR_WIDTH  - the CSS width of the block element
	
The CSS width of the default block element is empirically set to 11.6 px (full bar length measured on the 
screen and devided by the number of block elements), but this may vary with different screen resolutions, 
as CSS value and unit specifications don't relate to physical units. A CSS 'px' unit is generally 1/96 of 
an inch, this ratio can be used to finetune the CSS width of the new block element of your choice and, 
indirectly, the CSS width of the HTML table which accomodates the progress bar (the value applied to a 
CSS "width" style element of an HTML table in which the bar is embedded).
Read more: CSS Values and Units Module Level 3: L<http://www.w3.org/TR/css3-values/#reference-pixel> 

These block element values - the face code, total number and CSS unit width - are class data members and act
as constants, they are accessable only from inside the object and their initial values are set programatically 
from the object constructor. These initial values need to be altered in the class code for customization, 
they cannot be applied from your own code.
=head2 Customizing the interface window

The position and size of the progress bar interface window can also be set in the object constructor code by 
changing the parameters of the This simple customization can be achieved by changing some of the arguments of the 
C<__init_window> mutator method. The values are as follows:
 
	$__WIN_POS_LEFT    - the vertical coordinate of the upper left corner of the browser window
	$__WIN_POS_TOP     - the horizontal coordinate of the upper left corner of the browser window
	$__WIN_SIZE_WIDTH  - the width of the browser window
	$__WIN_SIZE_HEIGHT - the height of the browser window
 
=head1 METHODS

=cut

use 5.014002;
use strict;
use warnings;
use vars qw($VERSION);
our $VERSION = '0.01';
use Win32::OLE;
use HTML::Template;

Win32::OLE->Option( Warn => 0 );


# Class member declarations, mutator and accessor class methods for the progress bar design element.
{
	
	my $__BAR_CHAR_FACE  = undef;   # The HTML entity of the block element
	my $__BAR_CHAR_NUM   = undef;   # The number of block elements (the length) of the entire bar
	my $__BAR_CHAR_WIDTH = undef;   # The CSS width of the block element

	sub __init_bar { my $class = shift; ( $__BAR_CHAR_FACE, $__BAR_CHAR_NUM, $__BAR_CHAR_WIDTH ) = @_ }

	sub __get_bc_face{ $__BAR_CHAR_FACE }
	sub __get_bc_num{ $__BAR_CHAR_NUM }
	sub __get_bc_width{ $__BAR_CHAR_WIDTH }
	
}
# Class member declarations, mutator and accessor class methods for the browser window position and size. 
# The coordinates are relative to the left corner of the screen. 

{
		my $__WIN_POS_LEFT    = undef;   # The vertical coordinate of the upper left corner of the browser window
	my $__WIN_POS_TOP     = undef;   # The horizontal coordinate of the upper left corner of the browser window
	my $__WIN_SIZE_WIDTH  = undef;   # The width of the browser window
	my $__WIN_SIZE_HEIGHT = undef;   # The height of the browser window
	my $__WIN_MARGIN      = undef;   # The margin of the browser window 
	
	sub __init_window { my $class = shift; ( $__WIN_POS_LEFT, 
						 $__WIN_POS_TOP, 
						 $__WIN_SIZE_WIDTH, 
						 $__WIN_SIZE_HEIGHT,
						 $__WIN_MARGIN ) = @_ }

	sub __get_win_pos_left{ $__WIN_POS_LEFT }
	sub __get_win_pos_top{ $__WIN_POS_TOP }
	sub __get_win_size_width{ $__WIN_SIZE_WIDTH }
	sub __get_win_size_height{ $__WIN_SIZE_HEIGHT } 
	sub __get_win_margin{ $__WIN_MARGIN } 
	
}
=pod

=head2 new

my $object = ProgressBar->new();

The C<new> constructor lets you create a new B<ProgressBar> object. It doesn't take any parameters, its class 
and object data members are initialized and set internally. Two "private" class methods (C<_init_bar> and 
C<_init_window>) are called to set design related class data members of the progress bar and the 
browser window. 

These values should probably be simply set in compile time (constants), but the way they are encapsulated offers
a simple customization option. Changing these values in the constructor code feels somewhat better supported 
in contrast to the other option, changing them directly in the closure:
	$class->__init_bar( "&#x2591", 24, 11.66 );
	$class->__init_window( 760, 450, 333, 105 );
Some of the feedback related variables (__titlebar_text, __message_text) can be set through simple mutator 
methods from your code.

Returns a new B<ProgressBar> object.

=cut

sub new {
		my $class = shift;

	$class->__init_bar( "&#x2591", 24, 11.66 );
	$class->__init_window( 760, 450, 333, 105, 5 );
	
	bless { 
	        __percent_complete => 0,
		__current_step => 0,
		__checksum => 0,
		__titlebar_text => "",
		__progressbar_text => "", 
		__message_text => "",
		__IE => undef, 
		__doc => undef }, $class;
		
}  

=pod

=head2 set_titlebar_text

The C<set_titlebar_text> is a mutator method, it lets you set a generic, application related message for the B<ProgressBar> 
object to be displayed. This generic message will appear in the titlebar content (in the HTML DOM document title property) of 
the browser-based user interface and also above the progressbar (this latter line is combined with the actual percentage 
value of the number of the element being processed).

Returns 1 if the text of the titlebar is successfuly set, otherwise returns 0, so the method call can be tested.  

=cut

sub set_titlebar_text{
	
	my ($self, $text) = @_;
	
	$self->{__titlebar_text} = $text;
	
	return $self->{__titlebar_text} eq $text ? 1:0;
	
}

=pod

=head2 set_message_text

The C<set_message_text> is a mutator method, it lets you set a current element related message for the B<ProgressBar> 
object to be displayed. This current element related message can indicate any element specific information below the 
progressbar you consider important.

Returns 1 if the text of the message is successfuly set, otherwise returns 0, so the method call can be tested. When 
testing this method call please keep in mind, that it should be run from inside a processing loop.    

=cut

sub set_message_text{
	
	my ($self, $text) = @_;	
	
	$self->{__message_text} = $text;	
	
	return $self->{__message_text} eq $text ? 1:0;	
	
}
sub __update_progressbar{

	my $self = shift;	
	my @elements = ( "text", "progressbar", "pc");
	my $compl = "% Complete: ";
	my $bc_num = __get_bc_num();
	my $bc_face = __get_bc_face();
	
	if ( defined $self->{__doc} ) {
				$self->{__doc}->GetElementById($elements[0])->{InnerHtml} = $self->{__message_text};

		for my $cnt ( $self->{__current_step} .. $self->{__percent_complete} ) {
			my $sum = int(( $cnt * $bc_num / 100 ) + 0.5 );
						$self->{__progressbar_text} .= $bc_face if $sum > $self->{__checksum};
			$self->{__doc}->GetElementById($elements[1])->{InnerHtml} = $self->{__progressbar_text};
			$self->{__doc}->GetElementById($elements[2])->{InnerHtml} = $cnt.$compl.$self->{__titlebar_text};			

			$self->{__checksum} = $sum;
			
		}
		$self->{__doc}->{Title} = $self->{__titlebar_text};
		$self->{__current_step} = $self->{__percent_complete} + 1; 
		
		sleep 1;
	} 
		
	return;
}

=pod

=head2 update

The C<update> method keeps refreshing the state of the B<ProgressBar> object after each iteration from inside the 
processing loop. This method has an important argument: the percantage, which represents the current element in 
the whole collection. Using the following elementery formula, you can calculate this value easily and pass it to 
the object method:

	$percent = int(( 100 * $counter / scalar @pictures  ) + 0.5 );

The actual value of the C<$counter> variable gives the sequence number of the current element being processed from a 
collection of things you process (mostly files). The C<@pictures> array in the above example is placed into scalar 
context, hence it represents the size of this array, that is, the total number of elements in your collection. 

Returns 1 if the update is successful (the newly set percentage value is higher than the previous one), otherwise 
returns 0, so the method call can be tested. When testing this method call please keep in mind, that it should 
be run from inside a processing loop. 

=cut
sub update{
	
	my ($self, $pc) = @_;
	
	my $pc_prev = $self->{__percent_complete};
	$self->{__percent_complete} = $pc and $self->__update_progressbar() if $pc;
	
	return $self->{__percent_complete} > $pc_prev ? 1:0;}

=pod

=head2 show

The C<show> object method opens up a simple, browser-based interface. It needs to be called just once from outside 
the processing loop after the B<ProgressBar> object is created and its messages are set. Its HTML content will be 
refreshed cycle by cycle from inside the loop. 

The method relies on a template (HTML skeleton), which is stored under the __DATA__ token at the end of the package.
When the template is used, the width of the table, which holds the progress bar, is interpolated into the HTML code.
The textual elements of the HTML page are updated through HTML DOM C<InnerHTML> property tags.
Returns 1 if the browser object of the user interface is successful created, otherwise returns 0, so the method 
call can be tested. 

=cut
sub show{

	my $self = shift;
	
	my $HomePage = "about:blank";
	
	my $bc_num   = __get_bc_num();
	my $bc_width = __get_bc_width();
	
	my $table_width = int(( $bc_num * $bc_width) + 0.5 );
	
	my $margin = __get_win_margin();

	my %win_pos = (
		Left => __get_win_pos_left(),
		Top  => __get_win_pos_top(),
	);	
		my %win_size = (
		Width  => __get_win_size_width(),		Height => __get_win_size_height(),
	);
	
	my %ie_args = (
		Visible     		=> 0,
		RegisterAsDropTarget 	=> 1,
		RegisterAsBrowser 	=> 1,
		Resizable 		=> 0,
		Toolbar			=> 0,	
		Menubar			=> 0,
		Statusbar 		=> 0,
	);
	
	$self->{__IE} = Win32::OLE->new( 'InternetExplorer.Application' );
	
	foreach my $key ( keys %ie_args ) { 
		$self->{__IE}->{$key} = $ie_args{$key};
	}
	if ( $win_pos{Left} )    { $self->{__IE}->{Left}   = $win_pos{Left};	}
	if ( $win_pos{Top} )     { $self->{__IE}->{Top}    = $win_pos{Top};     }
	if ( $win_size{Width} )  { $self->{__IE}->{Width}  = $win_size{Width};  }
	if ( $win_size{Height} ) { $self->{__IE}->{Height} = $win_size{Height};	}
	
	$self->{__IE}->Navigate2( $HomePage );

	while( $self->{__IE}->{Busy} )
	{
	    while ($self->{__IE}->SpinMessageLoop()) { select undef,undef,undef,0.25; }
	}

	$self->{__IE}->{Visible} = 1; 
	
	$self->{__doc} = $self->{__IE}->{Document};
	
	# Idiom below to slurp the entire template file (in the temporary scope of the do block, 
	# the $/ input record seperator is temporarily set to undef, so that the diamond operator 
	# retrieves the entire template (the text after __DATA__ token) from the DATA filehandle
	# until it reaches EOF. Then it returns text assigning it to a scalar. 
		my $html = do { local $/; <DATA> }; 

	my $template = HTML::Template->new(
		scalarref         => \$html,
		loop_context_vars => 1,
	);

	$template->param( MARGIN => $margin );
	$template->param( WIDTH => $table_width );

	$self->{__doc}->Write( $template->output() );
	
	return defined $self->{__IE} ? 1:0;}

=pod

=head2 close

The C<close> object method lets you close the user interface of your ProgressBar object right after the 
processing loop iterates your entire collection.
Returns 1 if the browser object of the user interface previously existed and now it is successfully closed, 
otherwise returns 0, so the method call can be tested. 

=cut

sub close{
	
	my $self = shift;
	
	my $IE = defined $self->{__IE};
	undef $self->{__doc};
	$self->{__IE}->Quit;
        undef $self->{__IE};
        
        return ( $IE and !defined $self->{__IE}) ? 1:0;
        	
}

1;

=pod

=head1 SUPPORT

cgaspar@finsock.com

=head1 AUTHOR

Copyright 2016 Csaba Gaspar.

=cut

__DATA__

<HTML>
  <BODY SCROLL='no' STYLE='margin:<TMPL_VAR NAME=MARGIN>px'>
    <DIV STYLE='text-align:center; font-family:arial,cursive; font-size:12px;'>
      <SPAN ID='pc' NAME='pc'>0</span>
    </DIV>
    <TABLE STYLE='width:<TMPL_VAR NAME=WIDTH>;table-layout:fixed;margin-left:auto;margin-right:auto'>
    <TR>
      <TD>
        <DIV ID='progressbar' NAME='progressbar' STYLE='border:1px dotted blue; line-height:19px; height:19px; color:blue;'></DIV>
      </TD>
    </TR>
    </TABLE>
    <DIV STYLE='text-align:center; font-family:arial; font-size:10px'>
      <SPAN ID='text' NAME='text'></span>
    </DIV>
  </BODY>
</HTML>