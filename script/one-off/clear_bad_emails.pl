#!/usr/bin/env perl

use strict;
use warnings;

my @emails = qw(
  johnbaker@engdem.org
  dave@dunelmain.co.uk
  eastbourneindependent@yahoo.com
  info@christianparty.org.uk
  info@christianparty.org.uk
  efca@btinternet.com
  willdewick@hotmail.co.uk
  olidebotton@gmail.co.uk
  ronsinclair@btinternet.com
  garry@ashfieldconservatives.com
  info@christianparty.org.uk
  c.meeson@tiscali.co.uk
  info@christianparty.org.uk
  info@saveourpublicsevices.co.uk
  info@christianparty.org.uk
  j.greenhough@ntlworld.com
  info@christianparty.org.uk
  graeme@dudleyconservatives.com
  frank@frankhindle.org.uk
  mail@peterboroughconservatives.com
  kevin.mcelduff@sstaffslabour.org
  info@christianparty.org.uk
  timcutter1968@hotmail.com
  info@christianparty.org.uk
  info@christianparty.org.uk
  alastair.kirk@christian-education.org
  michael@davidsohn.co.uk
  greenwood-p@02.co.uk
  stephen.hammond@wimbledonconservatives.org.uk
  mark@sherwoodconservatives.com
  %20emma4wolverhampton@hotmail.com
  terryspencer@engdems.org
  rob4stoke@hotmail.co.uk
  garyindependent@hotmail.com
  scottmclean1025@aol.com
  info@christianparty.org.uk
  votetomgreatrex@hotmail.com
  swhyte@scottishtories.com
  jambos1@nildram.co.uk
  conservtc@aol.com
  matther.sidford@greenparty.org.uk
  info@juliehepburnsnp.com
  info@christianparty.org.uk
  arwick.nicholson@ukipnorthwales.org
  stuart@labour4tewkesbury.co.uk
  drdjpf@hotmail.co.uk
  irncrd@aol.com
  clarkg691@hotmail.com
  jambos1@nildram.co.uk
  enquiries@robmarris.org.uk
  info@christianparty.org.uk
  ronniecampbellmp@btconnect.com
  paul.edwards@congleton.gov.uk
  jim.fitzpatrick@defra.gsi.gov.uk
  austinforgrimsby@hotmail.co.uk
  spepper@chigwellschool.org
  margaretwestbrook@greenparty.org.uk
  office@bromleyconservatives.co.uk
  justin@swindonconservatives.com
  nickbrownmp@parliament.uk
  paulmurphymp@parliament.uk
  johnbaker@engdem.org
  dave@dunelmain.co.uk
  eastbourneindependent@yahoo.com
  info@christianparty.org.uk
  info@christianparty.org.uk
  efca@btinternet.com
  willdewick@hotmail.co.uk
  olidebotton@gmail.co.uk
  ronsinclair@btinternet.com
  garry@ashfieldconservatives.com
  info@christianparty.org.uk
  c.meeson@tiscali.co.uk
  info@christianparty.org.uk
  info@saveourpublicsevices.co.uk
  info@christianparty.org.uk
  j.greenhough@ntlworld.com
  info@christianparty.org.uk
  graeme@dudleyconservatives.com
  frank@frankhindle.org.uk
  mail@peterboroughconservatives.com
  kevin.mcelduff@sstaffslabour.org
  info@christianparty.org.uk
  timcutter1968@hotmail.com
  info@christianparty.org.uk
  info@christianparty.org.uk
  alastair.kirk@christian-education.org
  michael@davidsohn.co.uk
  greenwood-p@02.co.uk
  stephen.hammond@wimbledonconservatives.org.uk
  mark@sherwoodconservatives.com
  %20emma4wolverhampton@hotmail.com
  terryspencer@engdems.org
  rob4stoke@hotmail.co.uk
  garyindependent@hotmail.com
  scottmclean1025@aol.com
  info@christianparty.org.uk
  votetomgreatrex@hotmail.com
  swhyte@scottishtories.com
  jambos1@nildram.co.uk
  conservtc@aol.com
  matther.sidford@greenparty.org.uk
  info@juliehepburnsnp.com
  info@christianparty.org.uk
  arwick.nicholson@ukipnorthwales.org
  stuart@labour4tewkesbury.co.uk
  drdjpf@hotmail.co.uk
  irncrd@aol.com
  clarkg691@hotmail.com
  jambos1@nildram.co.uk
  enquiries@robmarris.org.uk
  info@christianparty.org.uk
  ronniecampbellmp@btconnect.com
  paul.edwards@congleton.gov.uk
  jim.fitzpatrick@defra.gsi.gov.uk
  austinforgrimsby@hotmail.co.uk
  spepper@chigwellschool.org
  margaretwestbrook@greenparty.org.uk
  office@bromleyconservatives.co.uk
  justin@swindonconservatives.com
  nickbrownmp@parliament.uk
  paulmurphymp@parliament.uk
  fife_office@mingcampbell.org.uk
  robintilbrook@engdem.org
  robintilbrook@engdem.org
);

use YourNextMP;

foreach my $email (@emails) {
    my $c = YourNextMP->db('Candidate')->search( { email => $email } )->first;

    if ($c) {
        warn "Clearing $email for candidate\n";
        $c->update( { email => undef } );
    }
    else {
        warn "No candidate for $email\n";
    }
}

