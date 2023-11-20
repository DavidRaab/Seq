#!perl
use 5.036;
use Seq qw(id fst snd key);
use Test2::V0 ':DEFAULT', qw/number_ge check_isa dies hash field array item end bag float U/;
use FindBin qw($Bin);
use Path::Tiny;
use DDP;

# Some values, functions, ... for testing
my $range     = Seq->range(1, 10);
my $rangeDesc = Seq->range(10, 1);

my $add     = sub($x,$y) { $x + $y     };
my $add1    = sub($x)    { $x + 1      };
my $double  = sub($x)    { $x * 2      };
my $square  = sub($x)    { $x * $x     };
my $is_even = sub($x)    { $x % 2 == 0 };


#------ range wit Seq->from_sub ------#

# Example to implement own range() with Seq->from_sub(). not completely
# identical to built-in. But demonstrates the concept behind it

sub range($start, $stop) {
    ###-- -- -- -- -- IMPORTANT -- -- -- -- --###
    #          NO CODE SHOULD BE HERE           #
    #    Otherwise it will be CAUSE of BUGS.    #
    # You also should never manipulate function #
    # arguments not even assign a new value to  #
    # it. Do an explicit new assignment in the  #
    #          INITIALIZATION STAGE             #
    ###-- -- -- -- -- -- --- -- -- -- -- -- --###
    return Seq->from_sub(sub {
        # INITIALIZATION STAGE:
        my $current = $start;

        # The iterator returning one element when asked
        return sub {
            # As long $current is equal or smaller
            if ( $current <= $stop ) {
                # return $current and increase by 1
                return $current++;
            }
            # otherwise return undef to indicate end of sequence
            else {
                return undef;
            }
        }
    });
}

my $r = range(1,10);
is($r->to_array, Seq->range(1,10)->to_array, 'from_sub');
is($r->to_array, Seq->range(1,10)->to_array, 'testing that $r is not exhausted');


#------ Creating iterator from file ------#

sub from_file($file) {
    return Seq->from_sub(sub {
        open my $fh, '<', $file or die "Cannot open: $!\n";

        return sub {
            if ( defined $fh ) {
                if (defined(my $line = <$fh>)) {
                    return $line;
                }
                else {
                    close $fh;
                    $fh = undef;
                }
            }
            return undef;
        };
    });
}

# open a file from test directory
my $test_dir = path($Bin, qw/data 07-from_sub/);
my $file     = from_file($test_dir->child('text.txt'));

is(
    $file->to_array,
    [
        "Testing\n",
        "File\n",
        "Handle\n",
    ],
    'check content of file');

is($file->count, 3, 'line count');
is($file->count, 3, 'should return 3 again');
is(
    $file
    ->filter(sub($x) { $x =~ m/test/i })
    ->count,

    1,
    'one line containing test');

is($file->skip(1) ->first('EMPTY'), "File\n", 'getting second line');
is($file->skip(10)->first('EMPTY'),  "EMPTY", 'getting default value');
is($file->skip(10)->first(),             U(), 'getting undef');

my $length_of_lines =
    $file->map(sub($line) { length $line });

is($length_of_lines->to_array, [8, 5, 7], 'line lengths');
is($length_of_lines->reduce($add),    20, 'characters in file');

done_testing;
