#!/usr/bin/env perl

use strict;
use warnings;

my @emails = qw(
  charles@charleswalker.org
  a.vanterheyden@pirateparty.co.uk
  aidan.burley@chaseconservatives.com
  alan.lawther@allianceparty.org
  ali@dualchas.com
  anniesland@tory.org
  apitfiled@hotmail.com
  arshaadalibradford@googlemail.com
  awclayworthrushclp@btinternet.com
  beverley.golden@nfgp.org.uk
  billhall@oneltel.com
  billyshaw7@msn.com
  brendan.heading@allianceparty.org
  brian.binley@brianbinley.com
  brooksnewmark@braintreeconservatives.co.uk
  charles.graham@greenparty.org.uk
  chesterfield@cix.co.uk
  chris4cambs@me.com
  clare@clareadamson.org
  colin.mathews@greenparty.org.uk
  conservtc@aol.com
  contact@paulfoster.org
  contact@richardottoway.com
  contact@tonylloydmp.co.uk
  dave@dunelmain.co.uk
  daveatgosportforlife@ntlworld.com
  debbie.lemay@talktalk.ne
  drdjpf@hotmail.co.uk
  drew4stroud2010@hotmail.com
  duncan.kerr@greenparty.org.uk
  efca@btinternet.com
  electnigel@yahoo.com
  emilybenn@ewaslabour.org.uk
  emma4wolverhampton@hotmail.com
  engelin@perliament.uk
  enquiries@robmarris.org.uk
  graeme@dudleyconservatives.com
  harshadbhai.patel@brent.gov.uk
  hc4mp@green010.org.uk
  hendrick@prestonlabour.fsnet.co.uk
  ian.parker-joseph@lpuk.org
  info@alancampbellmp.co.uk
  info@annesnelgrove.co.uk
  info@austinmitchell.org
  info@chrisbryant.co.uk
  info@davidkidney.com
  info@dorries.org.uk
  info@douglascarswell.com
  info@edwarddavey.co.uk
  info@frank-dobson.org.uk
  info@henrybellingham.com
  info@ianaustin.co.uk
  info@janetanderson.co.uk
  info@jimknightmp.com
  info@johspellar.labour.co.uk
  info@jonathanedwards.co.uk
  info@juliehepburnsnp.com
  info@kevanjonesmp.org.uk
  info@lindagilroy.org.uk
  info@lindariordanmp.co.uk
  info@mikenattrass.co.uk
  info@nigelwaterson.com
  info@owenpaterson.org.uk
  info@patmcfadden.com
  info@paulmurphymp.co.uk
  info@richardyoungerross.org.uk
  info@robertflello.co.uk
  info@rosiewinterton.co.uk
  info@sammywilson.org
  info@sarahmccarthy-fry.com
  info@shonamcisaac.com
  info@solihullmeriden-libdems.org.uk
  info@verabaird.com
  info@waynedavid.labour.co.uk
  irncrd@aol.com
  joe.rooney@nus.org.uk
  joebenton.bootle@lineone.net
  joejenkins@engdem.org
  john@johnrandallmp.com
  johnbaker@engdem.org
  julie@leicester-libdems.org.uk
  keatsgreen@hotmail.com
  kendall@tiscali.co.uk
  liam@northdown.org
  luciana.berger@nus.org.uk
  mail@oxfordshireconservatives.com
  mark@markwilliams.org.uk
  markadshead@yournextmp.com
  markchivertoniow@hotmail.com
  martin@garnett10.plus.uk
  matther.sidford@greenparty.org.uk
  mfellows@eis.learn-rep.org.uk
  mikelsusperregi@engdem.org
  mz@gmrespect.org.uk
  n.coghillmarshall@btinternet.com
  natalie.hurst@greenparty.org.uk
  oakensend@from-tc.gov.uk
  office@billericayconservatives.com
  office@ilfordleytoncons.tory.org
  office@ukipwales.org
  orgsec@stonecons.freeserve.co.uk
  paul-greenwood@dsl.pipex.com
  paulwhitelegg@engdem.org
  peterbarber@stockportgreenparty.org.uk
  peterbone@tory.org
  peterbraney@ukip.org.uk
  ph@soton.ac.uk
  phil@ncst.org.uk
  quinns@drumroad.wanadoo.co.uk
  rene@swanseaconservatives.com
  ronniecampbellmp@btconnect.com
  ros.kayes@southdorsetlibdems.org
  sam.moss@greenparty.org.uk
  sandersa@cix.co.uk
  siobhainmcdonagh@hotmail.com
  stephen.hammond@wimbledonconservatives.org.uk
  stephenwright@engdem.org
  steve@stevebicklabour.org.uk
  stuart@lancasterlibdems.org
  susan.pearc@greenparty.org.uk
  swhyte@scottishtories.com
  sylviahermon@hotmail.co.uk
  tom-watson@telltom.com
  tom.greatrex@scotlandoffice.gsi.gov.uk
  tony.baldry@conservatives.com
  tonyharper3@binternet.com
  trevor.ringland@voteforchangeni.com
  ukipemids@btconnect.com
  vernon@vernon-coaker-mp.co.uk
  votejohnstockton@johnstockton-labour.org.uk
  warwick.nicholson@ukipnorthwales.org
  you_smell_.of_wee@virgin.net
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

