#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'YourNextMP';
all_from 'lib/YourNextMP.pm';

requires 'App::Cache';
requires 'Carp';
requires 'Catalyst';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Credential::Password';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Engine::FastCGI';
requires 'Catalyst::Exception';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::Compress::Gzip';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBIC';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Runtime';    # => '5.80013';
requires 'Catalyst::Test';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::TT';
requires 'Class::C3';
requires 'Config';
requires 'Config::General';
requires 'Crypt::DH';
requires 'Crypt::DH::GMP';
requires 'Crypt::SSLeay';
requires 'Cwd';
requires 'Data::Dumper';
requires 'DateTime';
requires 'DateTime::Format::Pg';
requires 'DBD::Pg';
requires 'DBI';
requires 'DBIx::Class';
requires 'DBIx::Class::Schema::Loader' => '0.05000';
requires 'Digest::MD5';
requires 'Encode';
requires 'FCGI';
requires 'FCGI::ProcManager';
requires 'File::Copy::Recursive';
requires 'File::Find';
requires 'File::Finder';
requires 'File::Path';
requires 'File::Slurp';
requires 'File::Spec';
requires 'File::Temp';
requires 'FindBin';
requires 'Geo::Postcode';
requires 'Getopt::Long';
requires 'HTML::FormHandler::Model::DBIC';
requires 'HTTP::Date';
requires 'Image::Imlib2';
requires 'JSON';
requires 'LWP::Simple';
requires 'LWP::UserAgent';
requires 'Module::Install::Base';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Net::OpenID::Consumer';
requires 'Net::SSL';
requires 'Net::SSLeay';
requires 'parent';
requires 'Path::Class';
requires 'Pod::Usage';
requires 'SQL::Abstract' => '1.60';
requires 'Test::More';
requires 'Test::WWW::Mechanize';
requires 'Test::WWW::Mechanize::Catalyst';
requires 'URI';
requires 'Web::Scraper';
requires 'WebService::TWFY::API';
requires 'WWW::Mechanize';
requires 'XML::LibXML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

