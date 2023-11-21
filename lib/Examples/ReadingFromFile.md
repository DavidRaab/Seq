# Seq::Examples::ReadingFromFile

A file-handle is an iterator by default. So it is very easily to
connect a filehandle to the Seq module.

First, we can create a function `from_file` that serves as a Constructor
for opening a file and returning a sequence. We do this with the help
of `Seq->from_sub`

```perl
sub from_file($file) {
    return Seq->from_sub(sub {
        # On initialization we open the file
        open my $fh, '<', $file or die "Cannot open: $!\n";

        return sub {
            # as long filehandle is defined we read from it
            if ( defined $fh ) {
                # when a line can be read, we return it
                if (defined(my $line = <$fh>)) {
                    return $line;
                }
                # when no line can be returned anymore
                # we close the filehandle and undef it
                else {
                    close $fh;
                    $fh = undef;
                }
            }
            # when filehandle is not defined, we return undef
            return undef;
        };
    });
}
```

We now can create a sequence from a filename.

```perl
my $file = from_file($test_dir->child('text.txt'));
```

Here are the interesting bits.

* No file is opened. As long no value is read from the sequence. Nothing happens.
* Only getting elements from the file opens it. It will only read as much
  lines as needed.
* But file can be opened a lot of times, depending on how often we execute or ask
  it for values.


Consider just getting the `count` of a file.

```perl
$file->count()
```

This will basically return the amount of line numbers. `count` will open the
file, starts counting how many elements exists. Then aborts and closing
the file.

When we now assume that some other process change a file, and we call
`$file->count()` again. Then the whole process is repeated. File is opened
and counted again.

So what we have hear is a computation that depends on a mutable state (the
file). Whenever we execute the statement, we get the current line number
of the file.

This can be a wanted feature. As we just can describe a complex
data-transformation with `Seq`. And we can just evaluate that statement
as often as we want. Always fetching the newest value.

Sure, it also cannot be wanted. Opening the file again and again can be quit
slow. Maybe we just want to read the file a single time and keep its content
in-memory. Providing a better performance. This behabiour is maybe wanted
when we want something like a config-file that is only read once.

In the future there will be a `->cache` method that reads the whole
sequence defined so far in a memory array. Further request are
then served from this `cache`.

This way, we can have both. An automatic-updating computation or better
performance.