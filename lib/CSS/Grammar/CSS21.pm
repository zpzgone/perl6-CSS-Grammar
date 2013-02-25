use v6;

use CSS::Grammar;

# specification: http://www.w3.org/TR/2011/REC-CSS2-20110607/

grammar CSS::Grammar::CSS21:ver<02.20110607.000> is CSS::Grammar {

# as defined in w3c Appendix G: Grammar of CSS 2.1
# http://www.w3.org/TR/CSS21/grammar.html

    rule TOP {^ <stylesheet> $}

    # productions
    rule stylesheet { <charset>?
                      [<import> | <unexpected>]*
                      [<at_rule> | <ruleset> | <unexpected> | <unknown>]* }

    rule charset { \@(:i'charset') <string> ';' }
    rule import  { \@(:i'import')  [<string>|<url>] ';' }

    rule unexpected {<charset>|<import>}

    proto rule at_rule { <...> }
    rule at_rule:sym<media>   { \@(:i'media') <media_list> <rulesets> }
    rule at_rule:sym<page>    { \@(:i'page')  <page=.pseudo>? <declarations> }

    rule media_list {<medium> [',' <medium>]*}
    rule medium {<ident>}

    rule unary_operator {'-'}
    rule operator {'/'|','}

    # inherited combinators: '+' (adjacent)
    token combinator:sym<not>   {'-'}

    rule ruleset {
        <!after \@> # not an "@" rule
        <selectors> <declarations>
    }

    rule declarations {
        '{' <declaration> [';' <declaration> ]* ';'? <end_block>
    }

    rule rulesets {
        '{' <ruleset>* <end_block>
    }

    rule selectors {
        <selector> [',' <selector>]*
    }

    rule end_block {[$<closing_paren>='}' ';'?]?}

    rule property {<ident>}

    rule declaration {
         <property> ':' [ <expr> <prio>? | <expr_missing> ]
         | <skipped_term>
    }

    rule expr_missing {''}

    rule expr { <term> [ <operator>? <term> ]* }

    rule term { <unary_operator>? <term=.pterm> | <term=aterm> | [<!before <[\!\)]>><skipped_term>] }

    # pterm - able to be prefixed by a unary operator
    proto rule pterm {<...>}
    rule pterm:sym<length>     {<length>}
    rule pterm:sym<angle>      {<angle>}
    rule pterm:sym<time>       {<time>}
    rule pterm:sym<freq>       {<freq>}
    rule pterm:sym<percentage> {<percentage>}
    rule pterm:sym<dimension>  {<dimension>}
    rule pterm:sym<num>        {<num>}
    rule pterm:sym<ems>        {:i'em'}
    rule pterm:sym<exs>        {:i'ex'}
    # aterm - atomic; these can't be prefixed by a unary operator
    proto rule aterm {<...>}
    rule aterm:sym<string>     {<string>}
    rule aterm:sym<url>        {<url>}
    rule aterm:sym<color_rgb>  {<color_rgb>}
    rule aterm:sym<color_hex>  {<id>}
    rule aterm:sym<function>   {<function>}
    rule aterm:sym<ident>      {<ident>}

    rule selector {<simple_selector>[[<.ws>?<combinator><.ws>?]? <simple_selector>]*}

    token simple_selector { <element_name> [<id> | <class> | <attrib> | <pseudo>]*
                          |                [<id> | <class> | <attrib> | <pseudo>]+ }

    token class        {'.'<name>}
    token element_name {<ident>}

    rule attrib        {'[' <ident> [ <attribute_selector> [<ident>|<string>] ]? ']'}

    rule pseudo       {':' [<function>|<ident>] }
    token function    {<ident> '(' <expr> [')' | <unclosed_paren>]}

    # 'lexer' css2 exceptions
    token nonascii       {<- [\o0..\o177]>}
    token regascii       {<[\o40..~]>}
}
