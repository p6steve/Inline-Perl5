#!/usr/bin/env perl6

use v6;
use Inline::Perl5;

say "1..12";

my $i = p5_init_perl();
say $i.run('
use 5.10.0;
$| = 1;

sub test {
    say "ok 1 - executing a parameterless function without return value";
    return;
}

sub test_int_params {
    if ($_[0] == 2 and $_[1] == 1) {
        say "ok 2 - int params";
    }
    else {
        say "not ok 2 - int params";
    }
    return;
}

sub test_str_params {
    if (@_ == 2 and $_[0] eq "Hello" and $_[1] eq "Perl 5") {
        say "ok 3 - str params";
    }
    else {
        say "not ok 3 - str params";
    }
    return;
}

sub test_int_retval {
    return 1;
}

sub test_int_retvals {
    return 3, 1, 2;
}

sub test_str_retval {
    return "Hello Perl 6!";
}

sub test_mixed_retvals {
    return ("Hello", "Perl", 6);
}

sub test_undef {
    my ($self, $undef) = @_;

    return (@_ == 2 and $self eq "main" and not defined $undef);
}

package Foo;

sub new {
    my ($class, $val) = @_;
    return bless \$val, $class;
}

sub test {
    my ($self) = @_;
    return $$self;
}

sub sum {
    my ($self, $a, $b) = @_;
    return $a + $b;
}
');

$i.call('main::test');
$i.call('main::test_int_params', 2, 1);
$i.call('main::test_str_params', 'Hello', 'Perl 5');
if ($i.call('main::test_int_retval') == 1) {
    say "ok 4 - return one int";
}
else {
    say "not ok 4 - return one int";
}
my @retvals = $i.call('main::test_int_retvals');
if (@retvals == 3 and @retvals[0] == 3 and @retvals[1] == 1 and @retvals[2] == 2) {
    say "ok 5 - return one int";
}
else {
    say "not ok 5 - return one int";
    say "    got: {@retvals}";
    say "    expected: 3, 1, 2";
}
if ($i.call('main::test_str_retval') eq 'Hello Perl 6!') {
    say "ok 6 - return one string";
}
else {
    say "not ok 6 - return one string";
}
@retvals = $i.call('main::test_mixed_retvals');
if (@retvals == 3 and @retvals[0] eq 'Hello' and @retvals[1] eq 'Perl' and @retvals[2] == 6) {
    say "ok 7 - return mixed values";
}
else {
    say "not ok 7 - return mixed values";
    say "    got: {@retvals}";
    say "    expected: 'Hello', 'Perl', 6";
}

if ($i.call('test', $i.call('new', 'Foo', 1).ptr) == 1) {
    say "ok 8 - Perl 5 object";
}
else {
    say "not ok 8 - Perl 5 object";
}

if ($i.call('new', 'Foo', 1).call('test') == 1) {
    say "ok 9 - Perl 5 method call";
}
else {
    say "not ok 9 - Perl 5 method call";
}

if ($i.call('new', 'Foo', 1).call('sum', 3, 1) == 4) {
    say "ok 10 - Perl 5 method call with parameters";
}
else {
    say "not ok 10 - Perl 5 method call with parameters";
}

if (try { $i.call('new', 'Foo', 1).sum(3, 1) == 4 }) {
    say "ok 11 - method call on Perl5Object";
}
else {
    say "not ok 11 - method call on Perl5Object # TODO";
}

if ($i.call('test_undef', 'main', Any) == 1) {
    say "ok 12 - Any converted to undef";
}
else {
    say "not ok 12 - Any converted to undef";
}

$i.DESTROY;

# vim: ft=perl6
