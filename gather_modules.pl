#!/usr/bin/perl -s

use 5.10.0;

use strict;
use warnings;

use Pinto::Schema;
use YAML qw/ LoadFile DumpFile/;

my $schema = Pinto::Schema->connect(
    'dbi:SQLite:/usr/local/soft/pinto/.pinto/db/pinto.db' );

my $author = -f 'STACK.yml' ? LoadFile( 'STACK.yml' ) : {};
$_->{dists} = [] for values %$author;

my $rs = $schema->resultset('Distribution');

while( my $p = $rs->next ) {
    push @{ $author->{$p->author_canonical}{dists} }, $p->archive;
}

DumpFile('STACK.yml', $author);
