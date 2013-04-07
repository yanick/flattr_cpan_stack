package FlattrCPANStack;
use Dancer ':syntax';

use 5.10.0;

use strict;
use warnings;

use Net::OAuth2::Profile::WebServer;
use JSON qw/ encode_json/;
use YAML qw/ LoadFile /;

my $auth = Net::OAuth2::Profile::WebServer->new
  ( name           => 'Flattr'
  , client_id      => ''
  , client_secret  => ''
  , site           => 'https://flattr.com'
  , authorize_path    => '/oauth/authorize'
  , access_token_path => '/oauth/token'
  , scope => 'flattr'
  );

get '/' => sub {
    redirect $auth->authorize;
};

get '/oauth/callback' => sub {
    
    my $access_token  = $auth->get_access_token(param('code'));

    my $authors = LoadFile( 'STACK.yml' );

    my $page;

    for my $auth ( keys %$authors ) {
        next unless $authors->{$auth}{flattr};
        $page .= sprintf "<div>%s - %s</div>\n",
            $auth, flattr( $access_token, $auth, $authors->{$auth}{flattr} );
    }


    return $page;
};

sub flattr {
    my( $access_token, $auth, $flattr ) = @_;

    my $resp = $access_token->post(
        "http://flattr.com/submit/auto?url=https%3A%2F%2Fmetacpan.org%2Fauthor%2F$auth&user_id=$flattr"
    );

    my( $thing ) = (split '/', $resp->header('location'))[-1];

    $resp = $access_token->post(
        "https://api.flattr.com/rest/v2/things/$thing/flattr"
    );

    my %codes = (
        403 => 'flattr_once or owner',
        401 => 'flat broke',
        404 => 'Wut?',
        400 => 'you broke it',
    );

    return $codes{ $resp->code } || $resp->code;
}

dance;
