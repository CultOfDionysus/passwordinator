use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use FindBin;
use IPC::Open3;
use Symbol qw(gensym);

# Isolate CLI and failure-path tests from network and random-source availability.
# These doubles do not validate Crypt::Random's entropy source.
my $dir = tempdir(CLEANUP => 1);
make_path("$dir/Crypt", "$dir/HTTP");
sub fixture {
    my ($path, $text) = @_;
    open my $fh, '>', "$dir/$path" or die $!;
    print {$fh} $text;
    close $fh;
}
fixture('Crypt/Random.pm', q{
package Crypt::Random;
use Exporter 'import';
our @EXPORT_OK = qw(makerandom_itv);
sub makerandom_itv { my %args = @_; return $args{Upper} - 1; }
1;
});
fixture('HTTP/Tiny.pm', q{
package HTTP::Tiny;
sub new {
    my ($class, %args) = @_;
    die 'Missing timeout or TLS verification' unless $args{timeout} == 5 && $args{verify_SSL};
    return bless {}, $class;
}
sub get {
    die 'Unexpected network request' if $ENV{TEST_OFFLINE};
    die 'Network failure' if $ENV{TEST_THROW};
    return {success => !$ENV{TEST_HTTP_FAIL}, status => 503,
            content => $ENV{TEST_JSON} // '["apple","berry","cherry"]'};
}
1;
});
sub run {
    my (@args) = @_;
    my $err = gensym;
    my $pid = open3(my $in, my $out, $err, $^X, "-I$dir", "$FindBin::Bin/../passwordinator.pl", @args);
    close $in;
    local $/;
    my $stdout = <$out> // '';
    my $stderr = <$err> // '';
    waitpid($pid, 0);
    return ($? >> 8, $stdout, $stderr);
}
my ($status, $out, $err) = run('--help');
is($status, 0, 'help succeeds');
like($out, qr/--offline/, 'help documents offline option');
($status, $out, $err) = run('--invalid');
ok($status != 0, 'unknown option rejected');
($status, $out, $err) = run('unexpected');
ok($status != 0, 'positional argument rejected');
{
    local $ENV{TEST_OFFLINE} = 1;
    ($status, $out, $err) = run('--offline');
    is($status, 0, 'offline succeeds');
    is($err, '', 'offline never contacts API');
    unlike($out, qr/3 Words Password/, 'offline omits word passwords');
    unlike($out, qr/\e\[/, 'piped output contains no ANSI escapes');
    like($out, qr/Very Complex-> 9{32}\s/, '32-character password');
    like($out, qr/Quite Complex-> 9{12}\s/, '12-character password');
    like($out, qr/A Bit Complex-> 9{8}\s/, '8-character password');
}
($status, $out, $err) = run('--no-color');
is($status, 0, 'valid API response succeeds');
like($out, qr/AppleBerryCherry/, 'valid words displayed');
for my $json ('not json', '{}', '[]', '["one","two"]', '["one",null,"three"]', '["one",{},"three"]', '["one","two","bad\\u001b"]') {
    local $ENV{TEST_JSON} = $json;
    ($status, $out, $err) = run();
    is($status, 0, "invalid API data does not abort: $json");
    like($out, qr/Very Complex->/, 'character passwords retained');
    like($err, qr/Word passwords unavailable/, 'failure explained');
    unlike($out, qr/3 Words Password/, 'invalid words omitted');
}
for my $failure ('TEST_THROW', 'TEST_HTTP_FAIL') {
    local $ENV{$failure} = 1;
    ($status, $out, $err) = run();
    is($status, 0, "$failure does not abort");
    like($err, qr/Word passwords unavailable/, 'API failure explained');
}
done_testing;
