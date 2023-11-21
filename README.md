# NAME

Seq - A lazy sequence implementation

# SYNOPSIS

This is a lazy sequence implementation. C# has LINQ, Java has Stream, F#
has Seq. Perl also has Seq. Some useful stuff implemented, but currently
lacking Documentation. Look at test scripts so far.

```perl
use v5.36;
use Seq;

# Fibonacci Generator
my $fib =
    Seq->concat(
        Seq->wrap(1,1),
        Seq->unfold([1,1], sub($state) {
            my $next = $state->[0] + $state->[1];
            return $next, [$state->[1],$next];
        })
    );

# prints: 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765
$fib->take(20)->iter(sub($x) {
    say $x;
});

# Represents all possible combinations
# [[clubs => 7], [clubs => 8], [clubs => 9], ...]
my $cards =
    Seq::cartesian(
        Seq->wrap(qw/clubs spades hearts diamond/),
        Seq->wrap(qw/7 8 9 10 B D K A/)
    );

use Path::Tiny qw(path);
# get the maximum id from test-files so far
my $maximum_id =
    Seq
    ->wrap(   path('t')->children )
    ->map(    sub($x) { $x->basename })
    ->choose( sub($x) { $x =~ m/\A(\d+) .* \.t\z/xms ? $1 : undef } )
    ->max;
```

# EXPORT

This modules does not export anything by default. But you can request the following
functions: id, fst, snd, key, assign

# CONSTRUCTORS

This module uses functional-programming as the main paradigm. Functions are
divided into constructors that create *Sequences* and functions
that operate on Sequences (Methods). They are called methods for convenience,
but no object-orientation is involved. Perls OO capabilities are only
used as a chaning mechanism.

Constructors must be called with the Package name. Functions that operate
on Sequences can either be called as a method or directly from the Package.

```perl
my $range =
    Seq
    ->wrap(1,2,3)
    ->append(Seq->wrap(4,5,6));
```

or

```perl
my $range =
    Seq::to_array(
        Seq::append(
            Seq->wrap(1,2,3),
            Seq->wrap(4,5,6),
        )
    );
```

## $seq = Seq->empty()

Returns an empty sequence. Useful as an initial state or as a starting point.

```perl
Seq->empty->append( $another_seq )
```

## $seq = Seq->range($start, $stop)

Returns a sequence from $start to $stop. Range can also be backwards. $start
and $stop are inclusive.

```perl
Seq->range(1, 5); # 1,2,3,4,5
Seq->range(5, 1); # 5,4,3,2,1
Seq->range(1, 1); # 1
```

## $seq = Seq->wrap(...)

Just takes whatever you pass it to, and puts it in a sequence. This should be
your primarily way to create a sequence with values.

```perl
Seq->wrap(qw/Hello World/); # "Hello", "World"
Seq->wrap(1 .. 10);         # AVOID this, use Seq->range(1, 10) instead.
Seq->wrap(@array);
```

## $seq = Seq->concat(@sequences)

Takes multiple *Sequences* and returns a single flattened sequence.

```perl
# 1, 2, 3, 4, 5, 5, 4, 3, 2, 1
Seq->concat(
    Seq->range(1, 5),
    Seq->range(5, 1),
);
```

# Github

Development project is on Github [Perl-Seq](https://github.com/DavidRaab/Seq)

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Seq

You can also look for information at [my Blog on Perl Seq](https://davidraab.github.io/tags/perl-seq/)

# AUTHOR

David Raab, C<< <davidraab83 at gmail.com> >>

# LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by David Raab.

This is free software, licensed under:

  The MIT (X11) License
