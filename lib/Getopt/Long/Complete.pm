package Getopt::Long::Complete;

our $DATE = '2014-07-27'; # DATE
our $VERSION = '0.09'; # VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
                    GetOptions
               );
our @EXPORT_OK = qw(
                    GetOptions
                    GetOptionsWithCompletion
               );

sub GetOptionsWithCompletion {
    my $comp = shift;

    my $hash;
    if (ref($_[0]) eq 'HASH') {
        $hash = shift;
    }

    if (defined $ENV{COMP_LINE}) {
        require Complete::Bash;
        require Complete::Getopt::Long;

        my ($words, $cword) = @{ Complete::Bash::parse_cmdline(
            undef, undef, '=') };
        shift @$words; $cword--; # strip command name
        my $compres = Complete::Getopt::Long::complete_cli_arg(
            words => $words, cword => $cword, getopt_spec=>{ @_ },
            completion => $comp);
        print Complete::Bash::format_completion($compres);
        exit 0;
    }

    require Getopt::Long;
    if ($hash) {
        Getopt::Long::GetOptions($hash, @_);
    } else {
        Getopt::Long::GetOptions(@_);
    }
}

sub GetOptions {
    GetOptionsWithCompletion({}, @_);
}

1;
#ABSTRACT: A drop-in replacement for Getopt::Long, with tab completion

__END__

=pod

=encoding UTF-8

=head1 NAME

Getopt::Long::Complete - A drop-in replacement for Getopt::Long, with tab completion

=head1 VERSION

This document describes version 0.09 of Getopt::Long::Complete (from Perl distribution Getopt-Long-Complete), released on 2014-07-27.

=head1 SYNOPSIS

=head2 First example (simple)

You just replace C<use Getopt::Long> with C<use Getopt::Long::Complete> and your
program suddenly supports tab completion. This works for most/many programs. For
example, below is source code for C<delete-user>.

 use Getopt::Long::Complete;
 my %opts;
 GetOptions(
     'help|h'     => sub { ... },
     'on-fail=s'  => \$opts{on_fail},
     'user=s'     => \$opts{name},
     'force'      => \$opts{force},
     'verbose!'   => \$opts{verbose},
 );

To activate completion, put your script somewhere in C<PATH> and execute this in
the shell or put it into your bash startup file (e.g. C</etc/bash_profile> or
C<~/.bashrc>):

 complete -C delete-user delete-user

Now, tab completion works:

 % delete-user <tab>
 --force --help --noverbose --no-verbose --on-fail --user --verbose -h
 % delete-user --h<tab>

=head2 Second example (additional completion)

The previous example only provides completion for option names. To provide
completion for option values as well as arguments, you need to provide more
hints. Instead of C<GetOptions>, use C<GetOptionsWithCompletion>. It's basically
the same as C<GetOptions> but accepts a coderef in the first argument. The code
will be invoked when completion to option value or argument is needed. Example:

 use Getopt::Long::Complete qw(GetOptionsWithCompletion);
 use Complete::Unix qw(complete_user);
 use Complete::Util qw(complete_array_elem);
 my %opts;
 GetOptionsWithCompletion(
     sub {
         my %args  = @_;
         my $word  = $args{word}; # the word to be completed
         my $ospec = $args{ospec};
         if ($ospec && $ospec eq 'on-fail=s') {
             return complete_array_elem(words=>[qw/die warn ignore/], word=>$word);
         } elsif ($ospec eq 'user=s') {
             return complete_user(word=>$word);
         }
         [];
     },
     'help|h'     => sub { ... },
     'on-fail=s'  => \$opts{on_fail},
     'user=s'     => \$opts{name},
     'force'      => \$opts{force},
     'verbose!'   => \$opts{verbose},
 );

=head1 DESCRIPTION

This module provides a quick and easy way to add tab completion feature to your
scripts, including scripts already written using the venerable L<Getopt::Long>
module.

This module is basically just a thin wrapper for Getopt::Long. Its C<GetOptions>
function just checks for COMP_LINE/COMP_POINT environment variable before
passing its arguments to Getopt::Long's GetOptions. If COMP_LINE is defined,
completion reply will be printed to STDOUT and then the program will exit.
Otherwise, Getopt::Long's GetOptions is called.

To keep completion quick, you should do C<GetOptions()> or
C<GetOptionsWithCompletion()> as early as possible in your script. Preferably
before loading lots of other Perl modules.

Tab completion will behave like Getopt::Long using these configuration: bundling
(so -abc works), no_ignore_case, auto_abbrev, permute (so you need to give C<-->
to end completing option names/values). I believe this is a pretty sane default.

=head1 FUNCTIONS

=head2 GetOptions([\%hash, ]@spec)

Will call Getopt::Long's GetOptions, except when COMP_LINE environment variable
is defined.

=head2 GetOptionsWithCompletion(\&completion, [\%hash, ]@spec)

Just like C<GetOptions>, except that it accepts an extra first argument
C<\&completion> containing completion routine for completing option I<values>
and arguments. See Synopsis for example.

=head1 SEE ALSO

L<Complete::Getopt::Long> (the backend for this module), C<Complete::Bash>.

Other option-processing modules featuring shell tab completion:
L<Getopt::Complete>.

L<Perinci::CmdLine> - an alternative way to easily create command-line
applications with completion feature.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Getopt-Long-Complete>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Getopt-Long-Complete>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Getopt-Long-Complete>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
