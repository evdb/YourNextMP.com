#!/usr/bin/env perl

use strict;
use warnings;

use Text::CSV::Slurp;
use YourNextMP;
use Data::Dumper;
use IO::Prompt;

local $Data::Dumper::Sortkeys = 1;

my $csv_file = $ARGV[0] || die "Usage: $0 filename.csv\n";
my $data = Text::CSV::Slurp->load( file => $csv_file );

my %valid_fields = map { $_ => 1 } qw(party seat name address phone email fax);

my $parties_rs = YourNextMP->db('Party');
my $seats_rs   = YourNextMP->db('Seat');

foreach my $row (@$data) {

    # print '-' x 80;
    # print "\n";

    # ditch fields that are not needed
    delete $row->{$_} for grep { !$valid_fields{$_} } keys %$row;

    $row->{$_} ||= '' for qw(address phone email fax);

    # clean up whitespace
    for ( values %$row ) {
        s{^\s+}{};
        s{\s+$}{};
        s{\s+}{ }g;
        $_ ||= '';
    }

    $row->{address} =~ s{(?:,\s+)+}{, }xmsg;    # strip out extra commas
    $row->{email} = lc $row->{email};
    delete $row->{address} if $row->{address} =~ m{SW1A}i;
    delete $row->{email}   if $row->{email}   =~ m{\@parliament\.uk}i;
    for (qw(phone fax)) {
        next unless $row->{$_};
        delete $row->{$_} if $row->{$_} =~ m{020\s*7\s*219};
    }

    # Find the party
    my $party = $parties_rs->find( { name => $row->{party} } )
      || die "Can't find party '$row->{party}'";

    # Find the seat
    my $seat = $seats_rs->find( { code_from_name => $row->{seat} } )
      || warn("Can't find seat '$row->{seat}'\n") && next;

    # Find the candidate
    my $candidates = $seat->candidates->search( { name => $row->{name} } );
    $candidates = $seat->candidates->search( { party_id => $party->id } )
      if !$candidates->count;

    if ( $candidates->count > 1 ) {
        printf "Found several candidates in %s: %s\n", $seat->name,
          join( ', ', map { $_->name } $candidates->all );
        next;
    }

    my $candidate = $candidates->first;

    if ( $candidate && $candidate->name ne $row->{name} ) {
        printf "Name mismatch for %s: '%s' ne '%s'\n", $seat->name,
          $candidate->name, $row->{name};
        next;
    }

    # create candidate if missing
    if ( !$candidate ) {
        printf "Adding missing candidate for %s\n", $seat->name;

        eval {
            $candidate = $seat->add_to_candidates(
                {
                    party_id => $party->id,
                    name     => $row->{name},
                    email    => $row->{email},
                    phone    => $row->{phone},
                    fax      => $row->{fax},
                    address  => $row->{address},
                }
            );
        };
        if ($@) {
            warn "Probably duplicate candidate name: $row->{name}\n$@";
            next;
        }
    }

    # don't try to update a candidate that has been updated on the site.
    unless ( $candidate->can_scrape ) {
        print "skipping - can't scrape\n";
        next;
    }

    # find differences for existing candidate
    my %changed_fields    #
      = map { $_ => { old => ( $candidate->$_ || '' ), new => $row->{$_} } }   #
      grep { ( $candidate->$_ || '' ) ne $row->{$_} }
      grep { $row->{$_} }                                                      #
      qw(address phone email fax);

    if ( scalar keys %changed_fields ) {
        printf "Found changes for %s in %s\n", $row->{name}, $row->{seat};
        print Dumper( \%changed_fields );

        if ( grep { $changed_fields{$_}{old} } keys %changed_fields ) {
            print "Apply changes? [Yn]: ";
            my $char = '';
            while ( $char = getc ) {
                last if $char eq 'y' || $char eq 'n';
            }
            next if $char eq 'n';
        }

        print "Applying changes\n";
        my %updates =
          map { $_ => $changed_fields{$_}{new} } keys %changed_fields;

        use Data::Dumper;
        local $Data::Dumper::Sortkeys = 1;
        warn Dumper( \%updates );

        $candidate->update( \%updates );
    }

}
