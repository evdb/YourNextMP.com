#!/usr/bin/env perl

use strict;
use warnings;

# There is a list of BNP candidates here:
#
# http://bnpelectionresults.blogspot.com/2009/12/list-of-ppc-standing-for-bnp-
# so-far.html
#
# This is not a suitable source to scrape but it was worth parsing (by hand)
# to do a one off update - which is what this code does.
#
# I'll ask the blog author to keep our list up-to-date along side his list.


my @candidates = (
    { seat => 'Aberavon',                      name => 'Kevin Edwards' },
    { seat => 'Aberdeen South',                name => 'Susan Ross' },
    { seat => 'Alyn and Deeside',              name => 'John Walker' },
    { seat => 'Amber Valley',                  name => 'Michael Clarke' },
    { seat => 'Ashfield',                      name => 'Edward Holmes' },
    { seat => 'Banff and Buchan',              name => 'Richard Payne' },
    { seat => 'Barking',                       name => 'Nick Griffin' },
    { seat => 'Barnsley Central',              name => 'Ian Sutton' },
    { seat => 'Barnsley East',                 name => 'Colin Porter' },
    { seat => 'Bedford',                       name => 'Robin Johnstone' },
    { seat => 'Bermondsey and Old Southwark',  name => 'Stephen Tyler' },
    { seat => 'Birmingham, Northfield',        name => 'Les Orton' },
    { seat => 'Bishop Auckland',               name => 'Adam Walker' },
    { seat => 'Blackley and Broughton',        name => 'Derek Adams' },
    { seat => 'Blackpool North and Cleveleys', name => 'James Clayton' },
    { seat => 'Blackpool South',               name => 'Roy Goodwin' },
    { seat => 'Boston and Skegness',           name => 'David Owens' },
    { seat => 'Bosworth',                      name => 'John Ryde' },
    { seat => 'Bracknell',                     name => 'Mark Burke' },
    { seat => 'Brentwood and Ongar',           name => 'Paul Morris' },
    { seat => 'Bridgwater and West Somerset',  name => 'Donna Treanor' },
    { seat => 'Bromsgrove',                    name => 'Elizabeth Wainwright' },
    { seat => 'Buckingham',                    name => 'Adam Worley' },
    { seat => 'Burnley',                       name => 'Sharon Wilkinson' },
    { seat => 'Burton',                        name => 'Alan Hewitt' },
    { seat => 'Carlisle',                      name => 'Paul Stafford' },
    { seat => 'Carshalton and Wallington',     name => 'Charlotte Lewis' },
    { seat => 'Charnwood',                     name => 'Cathy Duffy' },
    { seat => 'Chippenham',                    name => 'Michael Simpkins' },
    { seat => 'Clwyd South',                   name => 'Sarah Hynes' },
    { seat => 'Copeland',                      name => 'Clive Jefferson' },
    { seat => 'Corby',                         name => 'Roy Davies' },
    { seat => 'Coventry North East',           name => 'Tom Gower' },
    { seat => 'Crawley',                       name => 'Richard Trower' },
    { seat => 'Croydon Central',               name => 'Cliff Le May' },
    { seat => 'Dagenham and Rainham',          name => 'Mick Barnbrook' },
    { seat => 'Darlington',                    name => 'John Hoodless' },
    { seat => 'Derby North',                   name => 'Peter Cheeseman' },
    { seat => 'South Derbyshire',              name => 'Peter Jarvis' },
    { seat => 'Dover',                         name => 'Dennis Whiting' },
    { seat => 'Dudley North',                  name => 'Ken Griffiths' },
    { seat => 'Ealing North',                  name => 'Dave Furness' },
    { seat => 'Easington',                     name => 'Cheryl Dunn' },
    { seat => 'East Renfrewshire',             name => 'Gary Raikes' },
    { seat => 'Eltham',                        name => 'Roberta Woods' },
    { seat => 'Enfield North',                 name => 'Tony Avery' },
    { seat => 'Epping Forest',                 name => 'Pat Richardson' },
    { seat => 'Erewash',                       name => 'Mark Bailey' },
    { seat => 'Exeter',                        name => 'Robert Farmer' },
    { seat => 'Feltham and Heston',            name => 'John Donnelly' },
    { seat => 'Gordon',                        name => 'Elise Jones' },
    { seat => 'Grantham and Stamford',         name => 'Christopher Robinson' },
    { seat => 'Harlow',                        name => 'Eddie Butler' },
    { seat => 'Hartlepool',                    name => 'Ronnie Bage' },
    { seat => 'Hayes and Harlington',          name => 'Chris Forster' },
    { seat => 'Hemsworth',                     name => 'Ian Kitchen' },
    { seat => 'Hereford',                      name => 'John Oliver' },
    { seat => 'Heywood and Middleton',         name => 'Peter Greenwood' },
    { seat => 'Holborn and St Pancras',        name => 'Robert Carlyle' },
    { seat => 'Horsham',                       name => 'Daniel McDonald' },
    { seat => 'Hyndburn',                      name => 'Andrew Eccles' },
    { seat => 'Kettering',                     name => 'Clive Skinner' },
    { seat => 'Knowsley',                      name => 'Gary Aronsson' },
    { seat => 'Leicester West',                name => 'Gary Reynolds' },
    { seat => 'Lincoln',                       name => 'Rev Robert West' },
    { seat => 'Loughborough',                  name => 'Kevan Stafford' },
    { seat => 'Louth and Horncastle',          name => 'Julia Green' },
    { seat => 'Ludlow',                        name => 'Christina Evans' },
    { seat => 'Maidenhead',                    name => 'Tim Rait' },
    { seat => 'Mid Sussex',                    name => 'Stuart Minihane' },
    { seat => 'Middlesbrough',                 name => 'Michael Ferguson' },
    { seat => 'Milton Keynes South',           name => 'Matthew Tait' },
    { seat => 'Mitcham and Morden',            name => 'Tony Martin' },
    { seat => 'Morley and Outwood',            name => 'Chris Beverley' },
    { seat => 'Newcastle upon Tyne Central',   name => 'Ken Booth' },
    { seat => 'Newport East',                  name => 'John Voisey' },
    { seat => 'North Cornwall',                name => 'Susan Bowen' },
    { seat => 'North Devon',                   name => 'Gary Marshall' },
    { seat => 'North Durham',                  name => 'Peter Molloy' },
    { seat => 'North Warwickshire',            name => 'Jason Holmes' },
    { seat => 'North West Durham',             name => 'Michael Stewart' },
    { seat => 'North West Leicestershire',     name => 'Ian Meller' },
    { seat => 'North West Norfolk',            name => 'David Fleming' },
    { seat => 'Northampton North',             name => 'Raymond Beasley' },
    { seat => 'Nottingham North',              name => 'Simon Brindley' },
    { seat => 'Nuneaton',                      name => 'Martyn Findley' },
    { seat => 'Orpington',                     name => 'Tess Cullhane' },
    { seat => 'Pendle',                        name => 'James Jackman' },
    { seat => 'Penrith and The Border',        name => 'Chris Davidson' },
    { seat => 'Plymouth, Moor View',           name => 'Roy Cook' },
    { seat => 'Poole',                         name => 'David Holmes' },
    { seat => 'Rochford and Southend East',    name => 'Geoff Strobridge' },
    { seat => 'Rutland and Melton',            name => 'Keith Addison' },
    { seat => 'Salford and Eccles',            name => 'Tina Wingfield' },
    { seat => 'Salisbury',                     name => 'Sean Witheridge' },
    { seat => 'Scunthorpe',                    name => 'Douglas Ward' },
    { seat => 'Sedgefield',                    name => 'Mark Walker' },
    { seat => 'Sevenoaks',                     name => 'Paul Golding' },
    {
        seat => 'Sheffield, Brightside and Hillsborough',
        name => 'Mark Collett'
    },
    { seat => 'Sherwood',                   name => 'James North' },
    { seat => 'Shrewsbury and Atcham',      name => 'James Whittall' },
    { seat => 'North Shropshire',           name => 'Phillip Reddall' },
    { seat => 'Sleaford and North Hykeham', name => 'Mike Clayton' },
    {
        seat => 'South Basildon and East Thurrock',
        name => 'Christopher Roberts'
    },
    { seat => 'South Leicestershire',       name => 'Paul Preston' },
    { seat => 'Southend West',              name => 'Stewart Freeman' },
    { seat => 'St Austell and Newquay',     name => 'James Fitton' },
    { seat => 'Stafford',                   name => 'Roland Hynd' },
    { seat => 'Stoke-on-Trent Central',     name => 'Simon Darby' },
    { seat => 'Stoke-on-Trent North',       name => 'Melanie Baddeley' },
    { seat => 'Stoke-on-Trent South',       name => 'Michael Coleman' },
    { seat => 'North Swindon',              name => 'Reg Bates' },
    { seat => 'Telford',                    name => 'Phil Spencer' },
    { seat => 'Thurrock',                   name => 'Emma Colgate' },
    { seat => 'Torbay',                     name => 'Ann Conway' },
    { seat => 'Totnes',                     name => 'Michael Turner' },
    { seat => 'Hornchurch and Upminster',   name => 'Mark Logan' },
    { seat => 'Uxbridge and South Ruislip', name => 'Keith Hardman' },
    { seat => 'Walsall North',              name => 'Christopher Woodall' },
    { seat => 'Wells',                      name => 'Richard Boyce' },
    { seat => 'Weston-Super-Mare',          name => 'Peryn Parsons' },
    { seat => 'Windsor',                    name => 'Peter Phillips' },
    { seat => 'Workington',                 name => 'Martin Wingfield' },
    { seat => 'The Wrekin',                 name => 'Susan Harwood' },
    { seat => 'Wrexham',                    name => 'Melvin Roberts' },
    { seat => 'Yeovil',                     name => 'Robert Baehr' },
    { seat => 'York Central',               name => 'Jeff Kelly' },
);

use YourNextMP;

my $seat_rs = YourNextMP->db('Seat');
my $can_rs  = YourNextMP->db('Candidate');
my $bnp     = YourNextMP->db('Party')->find( { code => 'british_national' } );

foreach my $candidate (@candidates) {
    my $seat = $seat_rs->find( { name => $candidate->{seat} } )
      || warn("Bad seat: $candidate->{seat}\n") && next;

    if ( my $existing = $seat->candidates( { party_id => $bnp->id } )->first ) {

        # exact match
        next if $existing->name eq $candidate->{name};

        # warn otherwise
        warn sprintf "Skipping %s - won't replace '%s' with '%s'\n",
          $seat->name, $existing->name, $candidate->{name};
        next;
    }

    # check that the candidate does not already exist
    if ( my $existing =
        $can_rs->search( { name => $candidate->{name} } )->first )
    {
        warn sprintf "'%s' already exists in %s", $candidate->{name},
          $existing->seat_names;
        next;
    }

    printf "Adding '%s' to '%s'\n", $candidate->{name}, $seat->name;
    $seat->add_to_candidates(
        {
            name     => $candidate->{name},
            party_id => $bnp->id,
        }
    );

}
