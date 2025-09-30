#!/usr/bin/env perl
# 
# Create a range of different strength passwords suitable for a range of applications
#
# https://github.com/CultOfDionysus/passwordinator
#

use strict;
use warnings;
use Crypt::Random qw( makerandom_itv );
use Term::ANSIColor;
use LWP::UserAgent::JSON;
use HTTP::Request::JSON;
use JSON;

my $version = '1.0';

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

my $user_agent = LWP::UserAgent::JSON->new;
#my $request    = HTTP::Request::JSON->new(GET =>'https://random-word-api.herokuapp.com/word?number=3&length=6');
my $request    = HTTP::Request::JSON->new(GET =>'https://random-word.ryanrk.com/api/en/word/random/3');
my $response   = $user_agent->request($request);
my $words      = from_json($response->content);

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
print colored(['cyan on_black'], "<- 3 random words with a 2/1 chance of being Hax0rified");
print "\n\n";

exit 0;


sub mkpasswd {

	my $range;
	my $pass;

	if ($_[0] == 1) { # Type 1 - all chars upper/lower/special
		$range = '/%?<>[]{}+!$%^&*()-=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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
   my $num = makerandom_itv(Lower => 0, Upper => 3, Strength => 0); #2/1 chance of conversion
   return $temp if ($num == 0);
   $temp =~ s/[i,I]/!/;
   $temp =~ s/[t,T]/7/;
   $temp =~ s/[e,E]/3/;
   $temp =~ s/[S,s]/5/;
   $temp =~ s/[l,L]/1/;
   $temp =~ s/[B,b]/8/;
   $temp =~ s/[Z,z]/2/;
   $temp =~ s/[A,a]/4/;
   $temp =~ s/[G,g]/9/;
   $temp =~ s/[O,o]/0/;
   return $temp;
}
