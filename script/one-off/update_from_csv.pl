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

my %valid_fields = map { $_ => 1 } qw(party seat name address phone email);

my $parties_rs = YourNextMP->db('Party');
my $seats_rs   = YourNextMP->db('Seat');

foreach my $row (@$data) {

    # ditch fields that are not needed
    delete $row->{$_} for grep { !$valid_fields{$_} } keys %$row;

    # clean up whitespace
    for ( values %$row ) {
        s{^\s+}{};
        s{\s+$}{};
        s{\s+}{ }g;
    }

    $row->{address} =~ s{(?:,\s+)+}{, }xmsg;    # strip out extra commas
    $row->{email} = lc $row->{email};

    # Find the party
    my $party = $parties_rs->find( { name => $row->{party} } )
      || die "Can't find party '$row->{party}'";

    # Find the seat
    my $seat = $seats_rs->find( { code_from_name => $row->{seat} } )
      || warn("Can't find seat '$row->{seat}'\n") && next;

    # Find the candidate
    my $candidates = $seat->candidates->search( { name => $row->{name} } )
      || $seat->candidates->search( { party_id => $party->id } );

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
                    address  => $row->{address},
                }
            );
        };
        if ($@) {
            warn "Probably duplicate candidate name: $row->{name}\n$@";
            next;
        }
    }

    # find differences for existing candidate
    my %changed_fields    #
      = map { $_ => { old => ( $candidate->$_ || '' ), new => $row->{$_} } }   #
      grep { ( $candidate->$_ || '' ) ne $row->{$_} }
      grep { $row->{$_} }                                                      #
      qw(address phone email);

    if ( scalar keys %changed_fields ) {
        printf "Found changes for %s in %s\n", $row->{name}, $row->{seat};
        print Dumper( \%changed_fields );

        print "Apply changes? [Yn]: ";
        next if ( getc || 'y' ) eq 'n';

        print "Applying changes\n";
        my %updates =
          map { $_ => $changed_fields{$_}{new} } keys %changed_fields;

        use Data::Dumper;
        local $Data::Dumper::Sortkeys = 1;
        warn Dumper( \%updates );

        $candidate->update( \%updates );
    }

}
