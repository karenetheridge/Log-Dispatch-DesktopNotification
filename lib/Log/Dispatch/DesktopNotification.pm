use strict;
use warnings;
package Log::Dispatch::DesktopNotification;
# ABSTRACT: Send log messages to a desktop notification system

our $VERSION = '0.03';

use Module::Load qw/load/;
use Module::Load::Conditional qw/can_load/;
use namespace::clean 0.19;

=head1 SYNOPSIS

    my $notify = Log::Dispatch::DesktopNotification->new(
        name      => 'notify',
        min_level => 'debug',
        app_name  => 'MyApp',
    );

=head1 METHODS

=head2 new

Creates a new L<Log::Dispatch> output that can be used to graphically notify a
user on this system. Uses C<output_class> and calls C<new> on the returned
class, passing along all arguments.

=cut

sub new {
    my ($class, @args) = @_;
    return $class->output_class->new(@args);
}

=head2 output_class

Returns the name of a L<Log::Dispatch::Output> class that is suitable to
graphically notify a user on the current system.

On MacOS X, that will be L<Log::Dispatch::MacGrowl>. On other systems,
L<Log::Dispatch::Gtk2::Notify> will be returned if it is available and usable.
Otherwise, L<Log::Dispatch::Null> will be returned.

=cut

sub output_class {
    if ($^O eq 'darwin') {
        my $mod = 'Log::Dispatch::MacGrowl';
        load $mod; return $mod;
    }

    if (can_load(modules => { Gtk2 => undef }) && Gtk2->init_check) {
        my $mod = 'Log::Dispatch::Gtk2::Notify';
        return $mod if can_load(modules => { $mod => undef });
    }

    my $mod = 'Log::Dispatch::Null';
    load $mod; return $mod;
}

=head1 LIMITATIONS

Currently only supports Mac OS X and systems on which notification-daemon is
available (most *N*Xes).

=head1 SEE ALSO

=for :list
* L<Log::Dispatch>
* L<Log::Dispatch::Gtk2::Notify>
* L<Log::Dispatch::MacGrowl>
* L<Log::Dispatch::Null>

=cut

1;
