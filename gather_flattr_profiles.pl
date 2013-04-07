#!/usr/bin/perl 

use 5.10.0;

use strict;
use warnings;

use MetaCPAN::API;
use YAML qw/ LoadFile DumpFile/;

my $authors = -f 'STACK.yml' ? LoadFile( 'STACK.yml' ) : {};

my $mcpan = MetaCPAN::API->new;

for my $id ( keys %$authors ) {
    my $author = $mcpan->author($id) or next;
    my @profiles = @{$author->{donation} or next};
    next unless @profiles;
    my( $flattr ) = grep { $_->{name} eq 'flattr' } @profiles;
    next unless $flattr;
    next unless $flattr->{id};
    $authors->{$id}{flattr} = $flattr->{id};
}

DumpFile('STACK.yml', $authors);
