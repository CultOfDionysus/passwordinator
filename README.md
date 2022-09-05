# passwordinator
Perl script to suggest a range of varying strengh passwords

Simple script to randomly generate passwords. Yes, there are loads of these out there but this one has ANSI screen colours to make it look cool, IMO.

There are some module dependencies:

* Crypt::Random
* Term::ANSIColor
* LWP::UserAgent::JSON
* HTTP::Request::JSON
* JSON

So you'll need to install these according to your perl distribution. I use the CPAN module.

TODO: work out where these modules are packaged in Debian/Ubuntu

Usage:

```
perl passwordinator.pl
```

No arguments are currently supported.

Example results:


![passwordinator screenshot](https://user-images.githubusercontent.com/108018363/188439477-8515303f-a3d8-4f41-a114-bbba30fdcbe1.png)
