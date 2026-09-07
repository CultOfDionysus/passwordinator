#!/usr/bin/env perl
# 
# Create a range of different strength passwords suitable for a range of applications
#
# https://github.com/CultOfDionysus/passwordinator
#

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Term::ANSIColor;
use HTTP::Tiny;
use JSON::PP qw(decode_json);

my $version = '1.1';
my ($offline, $no_colour, $help, $show_version);
GetOptions(
    'offline' => \$offline,
    'no-color|no-colour' => \$no_colour,
    'help|h' => \$help,
    'version' => \$show_version,
) or die "Try --help for usage.\n";
die "Unexpected arguments: @ARGV\n" if @ARGV;
if ($help) {
    print "Usage: perl passwordinator.pl [--offline] [--no-color] [--version] [--help]\n";
    print "  --offline   Generate character passwords without contacting the word API.\n";
    print "  --no-color  Disable ANSI colours (also disabled when piping or with NO_COLOR).\n";
    exit 0;
}
if ($show_version) { print "Passwordinator $version\n"; exit 0; }
$ENV{ANSI_COLORS_DISABLED} = 1 if $no_colour || exists $ENV{NO_COLOR} || !-t STDOUT;
require Crypt::Random;
Crypt::Random->import(qw(makerandom_itv));

my $banner = << 'END_BANNER';
          .oPYo.                                                  8  o                o                  
          8    8                                                  8                   8                  
         o8YooP' .oPYo. .oPYo. .oPYo. o   o   o .oPYo. oPYo. .oPYo8 o8 odYo. .oPYo.  o8P .oPYo. oPYo.    
          8      .oooo8 Yb..   Yb..   Y. .P. .P 8    8 8  `' 8    8  8 8' `8 .oooo8   8  8    8 8  `'    
          8      8    8   'Yb.   'Yb. `b.d'b.d' 8    8 8     8    8  8 8   8 8    8   8  8    8 8        
          8      `YooP8 `YooP' `YooP'  `Y' `Y'  `YooP' 8     `YooP'  8 8   8 `YooP8   8  `YooP' 8        
END_BANNER

my @pcolours = ("bright_red", "bright_white", "bright_blue");
my $pqcomplex = &mkpasswd(1,12);
my $pbcomplex = &mkpasswd(2,8);
my $pnotcomplex = &mkpasswd(3,8);
my $pvcomplex = &mkpasswd(1,32);

my $words;
unless ($offline) {
    eval {
        my $response = HTTP::Tiny->new(timeout => 5, verify_SSL => 1)->get(
            'https://random-word.ryanrk.com/api/en/word/random/3');
        die "Word API request failed (HTTP $response->{status}).\n" unless $response->{success};
        my $decoded = decode_json($response->{content});
        die "Word API returned an invalid word list.\n"
            unless ref($decoded) eq 'ARRAY' && @$decoded == 3
                && !grep { !defined($_) || ref($_) || !/\A[a-zA-Z]{1,64}\z/ } @$decoded;
        $words = $decoded;
        1;
    } or warn "Word passwords unavailable; character passwords are still available.\n";
}

print colored(['bright_blue on_black'],"$banner\n\n");
print colored(['green on_black'], "     Very Complex-> ");
print colored(['bright_green on_black'],$pvcomplex), colored(['cyan on_black'], "\t<- 32 chars, mixed case, numbers, specials");
print "\n\n";
print colored(['green on_black'], "    Quite Complex-> ");
print colored(['bright_cyan on_black'],$pqcomplex), colored(['cyan on_black'], "\t\t\t<- 12 chars, mixed case, numbers, specials");
print "\n\n";
print colored(['green on_black'], "    A Bit Complex-> ");
print colored(['bright_yellow on_black'],$pbcomplex), colored(['cyan on_black'], "\t\t\t\t<- 8 chars, mixed case, numbers, no visually-similar chars");
print "\n\n";
print colored(['green on_black'], "      Not Complex-> ");
print colored(['red on_black'],$pnotcomplex), colored(['cyan on_black'], "\t\t\t\t<- 8 chars, lower case only, numbers, no visually-similar chars");
print "\n\n";
if ($words) {
    print colored(['green on_black'], " 3 Words Password-> ");

    my $i=0;
    foreach my $word (@$words) {
    	print colored(["$pcolours[$i] on_black"], ucfirst $word);
    	$i++;
    }
    print "\t\t";
    print colored(['cyan on_black'], "<- 3 random words via https://random-word.ryanrk.com API");
    print "\n\n";

    print colored(['green on_black'], " 3 W0rd5 P4ssword-> ");

    $i=0;
    foreach my $word (@$words) {
    	print colored(["$pcolours[$i] on_black"], ucfirst &leetist($word));
    	$i++;
    }
    print "\t\t";
    print colored(['cyan on_black'], "<- 3 random words with a 2-in-3 chance of being Hax0rified");
    print "\n\n";

}

exit 0;


sub mkpasswd {

	my $range;
	my $pass = '';

	if ($_[0] == 1) { # Type 1 - all chars upper/lower/special
		$range = '/%?<>[]{}+!$^&*()-=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	}
 	else { 
		if ($_[0] == 2) { #  Type 2 - num/char upper/lower, visually similar chars removed
  			$range = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRTUVWXY346789';
  		}
  		else { #  Type 3 (default) - lower case and nums only
  			$range = 'abcdefghijkmnpqrstuvwxyz23456789';
  		}
	}
	foreach (1 .. $_[1]) { # keylen is 2nd arg
		my $num = makerandom_itv(Lower => 0, Upper => length($range), Strength => 0); # See https://metacpan.org/pod/Crypt::Random#BLOCKING-BEHAVIOUR
    		my $tmp = substr($range, $num, 1);
    		$pass .= $tmp;
 		}
  	return $pass;
}

# based on https://metacpan.org/dist/Acme-1337/source/lib/Acme/L337.pm
# Toss a coin to see if we alter the text or not

sub leetist { 
   my $temp = $_[0];
   my $num = makerandom_itv(Lower => 0, Upper => 3, Strength => 0); #2-in-3 chance of conversion
   return $temp if ($num == 0);
   $temp =~ s/[iI]/!/;
   $temp =~ s/[tT]/7/;
   $temp =~ s/[eE]/3/;
   $temp =~ s/[Ss]/5/;
   $temp =~ s/[lL]/1/;
   $temp =~ s/[Bb]/8/;
   $temp =~ s/[Zz]/2/;
   $temp =~ s/[Aa]/4/;
   $temp =~ s/[Gg]/9/;
   $temp =~ s/[Oo]/0/;
   return $temp;
}
