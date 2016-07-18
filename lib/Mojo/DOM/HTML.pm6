unit module Mojo::DOM::HTML;
use v6;

use Mojo::DOM::Entities;

grammar Tokenizer {
    token TOP { <html-token>* }

    token html-token { <text>? <markup> }
    token text { <-[ < ]>+ }

    proto token markup { * }
    token markup:sym<doctype> {
        '<!DOCTYPE' $<doctype> = [
        \s+ \w+                                                          # Doctype
        [ [ \s+ \w+ ]? [ \s+ [ '"' <-["]>* '"' | "'" <-[']>* "'" ] ]+ ]? # External ID
        [ \s+ "[" .+? "]" ]?                                             # Int Subset
        \s* ] '>'
    }
    token markup:sym<comment> { '<--' $<comment> = [ .*? ] '--' \s* '>' }
    token markup:sym<cdata> { '<[CDATA[' .*? ']]>' }
    token markup:sym<pi> { '<?' $<pi> = [ .*? ] '?>' }
    token markup:sym<tag> { '<' \s* <end-mark>? \s* <tag-name> [ \s+ <attr> ** 0..32766 ]? <empty-tag-mark>? '>' }
    token markup:sym<runaway-lt> { '<' }

    token end-mark { '/' }
    token empty-tag-mark { '/' }
    token tag-name { <-[ < > \s ]>+ }

    rule attr { <attr-key> [ '=' <attr-value> ]? }
    token attr-key { <-[ < > = \s \/ ]>+ }
    token attr-value {
        | [ '"' $<raw-value> = [ .*? ] '"'  ]
        | [ "'" $<raw-value> = [ .*? ] "'" ]
        | [ $<raw-value> = <-[ > \s ]>* ]
    }
}

# HTML elements that only contain raw text
my %RAW = set <script stype>;

# HTML elements that only contain raw text and entities
my %RCDATA = set <title textarea>;

# HTML elements with optional end tags
my %END = body => 'head', optgroup => 'optgroup', option => 'option';

# HTML elements that break paragraphs
%END{$_} = 'p' for <
  address article aside blockquote dir div dl fieldset footer form h1 h2
  h3 h4 h5 h6 header hr main menu nav ol p pre section table ul
>;

# HTML table elements with optional end tags
my %TABLE = set <colgroup tbody td tfoot th thead tr>;

# HTML elements with optional end tags and scoping rules
my %CLOSE
  = li => [set <li>, set <ul ol>], tr => [set <tr>, set <table>];
%CLOSE{$_} = [%TABLE, set <table>] for <colgroup tbody tfoot thead>;
%CLOSE{$_} = [set <dd dt>, set <dl>] for <dd dt>;
%CLOSE{$_} = [set <rp rt>, set <ruby>] for <rp rt>;
%CLOSE{$_} = [set <th td>, set <table>] for <td th>;

# HTML elements without end tags
my %EMPTY = set <
  area base br col embed hr img input keygen link menuitem meta param
  source track wbr
>;

# HTML elements categorized as phrasing content (and obsolete inline elements)
my @PHRASING = <
  a abbr area audio b bdi bdo br button canvas cite code data datalist
  del dfn em embed i iframe img input ins kbd keygen label link map mark
  math meta meter noscript object output picture progress q ruby s samp
  script select slot small span strong sub sup svg template textarea time u
  var video wbr
>;
my @OBSOLETE = < acronym applet basefont big font strike tt >;
my %PHRASING = set @OBSOLETE, @PHRASING;

# HTML elements that don't get their self-closing flag acknowledged
my %BLOCK = set <
  a address applet article aside b big blockquote body button caption
  center code col colgroup dd details dialog dir div dl dt em fieldset
  figcaption figure font footer form frameset h1 h2 h3 h4 h5 h6 head
  header hgroup html i iframe li listing main marquee menu nav nobr
  noembed noframes noscript object ol optgroup option p plaintext pre rp
  rt s script section select small strike strong style summary table
  tbody td template textarea tfoot th thead title tr tt u ul xmp
>;

our enum MarkupType < Cdata Comment Doctype Pi Root Runaway Tag Text >;

class TreeMaker {
    has Bool $.xml;

    my sub _end($end, $xml, $current is rw) {

        # Search stack for start tag
        my $next = $current;
        repeat {

            # Ignore useless end tag
            return if $next[0] eq Root;

            # Right tag
            return $current = $next[3] if $next[1] eq $end;

            # Phrasing content can only cross phrasing content
            return if !$xml && %PHRASING{$end} && !%PHRASING{$next[1]};

        } while ?($next = $next[3]);

        # The above loop runs not without this? WTH?
        return;
    }

    my sub _node($current is rw, $type, $content) {
        push $current, [ $type, $content, $current ];
    }

    my sub _start($start, %attrs, $xml, $current is rw) {

        # Autoclose optional HTML elements
        if !$xml && $current[0] ~~ Root {
            if %END{$start} -> $end {
                _end($end, False, $current);
            }
            elsif %CLOSE{$start} -> $close {
                my (%allowed, %scope) = |$close;

                # Close allowed parent elements in scope
                my @parent = $current;
                while @parent[0] ~~ Root && %scope ∌ @parent[1] {
                    _end(@parent[1], False, $current) if %scope ∋ @parent[1];
                    @parent = @parent[3];
                }
            }
        }

        # New tag
        push $current, my @new = [ Tag, $start, %attrs, $current ];
        $current = @new;
    }

    method TOP($/) {
        my $current = my @tree = [ Root ];

        my $xml = $.xml // False;
        for $<html-token>».made -> @html-token {
            my $text   = @html-token[0];
            my %markup = @html-token[1];

            $text ~= '<' if %markup<type> ~~ Runaway;
            _node($current, Text, html-unescape $text)
                if defined $text;

            given %markup<type> {
                when Tag {

                    # End
                    if %markup<end> {
                        _end(%markup<tag>, $xml, $current);
                    }

                    # Start
                    else {
                        my $start   = %markup<tag>;
                        my %attrs   = %markup<attrs>;
                        my $closing = %markup<empty>;

                        # "image" is an alias for "img"
                        $start = 'img' if !$xml && $start eq 'image';
                        _start($start, %attrs, $xml, $current);

                        # Element without end tag (self-closing)
                        _end($start, $xml, $current)
                            if (!$xml && %EMPTY ∋ $start)
                                || (($xml || %BLOCK ∌ $start) && $closing);

                        # FIXME Raw text elements (NYI)
                        # CODE NEEDED SOMEWHERE...
                    }

                }

                when Doctype {
                    _node($current, Doctype, %markup<doctype>);
                }

                when Comment {
                    _node($current, Comment, %markup<comment>);
                }

                when Pi {
                    _node($current, Pi, %markup<pi>);
                }
            }
        }

        make @tree;
    }

    method html-token($/) {
        make [ $<text>.made, $<markup>.made ];
    }

    method text($/) { make ~$/ }

    method markup:sym<tag>($/) {
        make {
            type  => Tag,
            end   => ?$<end-mark>,
            tag   => $.xml ?? ~$<tag-name> !! (~$<tag-name>).lc,
            attrs => Hash.new($<attr>».made),
            empty => ?$<empty-tag-mark>,
        }
    }

    method markup:sym<doctype>($/) {
        make {
            type    => Doctype,
            doctype => ~$<doctype>,
        }
    }

    method markup:sym<comment>($/) {
        make {
            type    => Comment,
            comment => ~$<comment>,
        }
    }

    method markup:sym<cdata>($/) {
        make {
            type  => Cdata,
            cdata => ~$<cdata>,
        }
    }

    method markup:sym<pi>($/) {
        $!xml = True if !defined $!xml && (~$<pi>) ~~ /^ xml >>/;
        make {
            type => Pi,
            pi   => ~$<pi>,
        }
    }

    method markup:sym<runaway-lt>($/) {
        make { type => Runaway }
    }

    method attr($/) {
        if $<attr-value> {
            make $<attr-key>.made => $<attr-value>.made;
        }
        else {
            make $<attr-key>.made => Nil;
        }
    }

    method attr-key($/)   { make ~$/ }
    method attr-value($/) { make html-unescape ~$<raw-value> }
}


