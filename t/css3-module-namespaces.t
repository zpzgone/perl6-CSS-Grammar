#!/usr/bin/env perl6

use Test;

use CSS::Grammar;
use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;
use CSS::Grammar::CSS3::Module::Namespaces;

# prepare our own composite class with namespace extensions

grammar t::CSS3::NamespaceGrammar
      is CSS::Grammar::CSS3::Module::Namespaces
      is CSS::Grammar::CSS3
      {};

class t::CSS3::NamespaceActions
    is CSS::Grammar::CSS3::Module::Namespaces::Actions
    is CSS::Grammar::Actions
{};

use lib '.';
use t::CSS;

my $css_actions = t::CSS3::NamespaceActions.new;

for (
    at_decl => {input => '@namespace empty "";',
                ast => {"prefix" => "empty", "url" => ""},
    },
    at_decl => {input => '@namespace "";',
                ast => {"url" => ""},
    },
    at_decl => {input => '@namespace "http://www.w3.org/1999/xhtml";',
                ast => {"url" => "http://www.w3.org/1999/xhtml"},
    },
    at_decl => {input => '@namespace svg "http://www.w3.org/2000/svg";',
                ast => {"prefix" => "svg", "url" => "http://www.w3.org/2000/svg"},
    },
    at_decl => {input => '@namespace toto url(http://toto.example.org);',
                ast => {"prefix" => "toto", "url" => "http://toto.example.org"},
    },
    ) {
    my $rule = $_.key;
    my %test = $_.value;
    my $input = %test<input>;

    $css_actions.warnings = ();
    my $p3 = t::CSS3::NamespaceGrammar.parse( $input, :rule($rule), :actions($css_actions));
    t::CSS::parse_tests($input, $p3, :rule($rule), :compat('css3-namespace'),
                         :warnings($css_actions.warnings),
                         :expected(%test) );
}

done;
