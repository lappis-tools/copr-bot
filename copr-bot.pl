#!/usr/bin/perl
use warnings;
use strict;
use JSON;
use YAML::XS 'LoadFile';
use LWP::Simple;
use Data::Dumper;

my $config = LoadFile('config.yaml');

package MyBot;
use base qw( Bot::BasicBot );
my @urls = ($config->{BaseUrl}, "api", "status");
my $channel = "#".$config->{Channel};
my $json = JSON->new->allow_nonref;

sub said {
  #TODO: when someone asks for a package version, call her name.
  my ($self, $message) = @_;
  if ($message->{body} =~ /!version (.*)/) {
    my $response = LWP::Simple::get($urls[0].'/'.$urls[1]);
    my $info = $json->decode($response);
    return $info->{$1}->{"git"}->{"master"};
  }
}

sub tick {
  my ($self) = @_;
  my $response = LWP::Simple::get(join("/", @urls));
  my $info = $json->decode($response);
  my @mismatches;
  foreach my $key (keys %{$info}) {
    if($info->{$key} == 0) {
      push(@mismatches, $key);
    }
  }

  my $message = "Mismatched: ";
  $message .= join(", ", @mismatches);

  $self->say(channel => $channel, body=> $message) if @mismatches;
  return $config->{Tick};
}

MyBot->new(
  server => 'irc.freenode.net',
  port => '6667',
  channels => [ $channel ],
  nick => 'spb_devops',
)->run();
