unit class DOM::Tiny::CSS;
use v6;

use DOM::Tiny::HTML;

my class Joiner {
    has @.combine;

    submethod BUILD(:@combine) {
        @!combine = @combine.reverse;
    }
}

my class AncestorJoiner is Joiner {
    method no-gaps { False }

    multi method ACCEPTS(::?CLASS:D: DocumentNode:D $current is copy) {
        return False unless $current ~~ @.combine[0];

        my @ancestors = $current.ancestor-nodes(:context);
        COMBINATION: for @.combine[1 .. *] -> $selector {
            for @ancestors -> $current {
                if $current ~~ $selector {
                    shift @ancestors;
                    next COMBINATION;
                }
                elsif $.no-gaps {
                    return False;
                }
            }

            return False;
        }

        True;
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class ParentJoiner is AncestorJoiner {
    method no-gaps { True }
}

my class CousinJoiner is Joiner {
    multi method ACCEPTS(::?CLASS:D: DocumentNode:D $current) {
        my @cousins = $current.split-siblings(:tags-only)<before>.reverse;
        unshift @cousins, $current;

        return False if @cousins.elems < @.combine.elems;

        for @cousins.combinations(@.combine.elems) -> $combination {
            return $combination ~~ @.combine;
        }

        False;
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class SiblingJoiner is Joiner {
    multi method ACCEPTS(::?CLASS:D: DocumentNode:D $current) {
        my @siblings = $current.split-siblings(:tags-only)<before>.reverse;
        unshift @siblings, $current;
        @siblings = @siblings[^@.combine.elems];
        @siblings ~~ @.combine;
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class HasAttr {
    has $.name;

    submethod BUILD(:$name) {
        my $unescaped-name = _unescape($name);
        $!name = regex { [ ^ | ':' ] $unescaped-name $ };
    }

    multi method ACCEPTS(::?CLASS:D: Tag:D $current) {
        $current.attr ~~ $!name
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class AttrIs is HasAttr {
    has Str $.op is required;
    has Str $.value is required;
    has Bool $.i = False;

    has $!rx;
    method value-regex() {
        return $!rx with $!rx;

        my $unescaped = _unescape($!value);

        my $rx = do given $!op {
            when '~=' { rx{  [ ^ | \s+ ] $unescaped [ \s+ | $ ] } }
            when '*=' { rx{ $unescaped } }
            when '^=' { rx{ ^ $unescaped } }
            when '$=' { rx{ $unescaped $ } }
            default   { rx{ ^ $unescaped $ } }
        }

        $rx = rx:i{ $rx } if $!i;
        $!rx := $rx;
    }

    multi method ACCEPTS(::?CLASS:D: Tag:D $current) {
        return False unless callsame;
        my $name = $current.attr.keys.first($.name);
        $current.attr{ $name } ~~ $.value-regex;
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class TagMatch {
    has $.name;

    multi method ACCEPTS(::?CLASS:D: Tag:D $current) {
        my $unescaped = _unescape($!name);
        $current ~~ Tag && (
            $current.tag ~~ $!name | / [ ^ | ':' ] "$unescaped" $/
        );
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class Pseudo { }

my class PseudoNot is Pseudo {
    has @.groups;

    multi method ACCEPTS(::?CLASS:D: Node:D $current) {
        $current ~~ none(|@!groups);
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class PseudoNth is Pseudo {
    has $.end = False;
    has $.of-type = False;
    has $.coeff;
    has $.offset;

    multi method ACCEPTS(::?CLASS:D: Tag:D $current) {
        my @siblings = |$current.siblings(:tags-only, :including-self);
        @siblings .= grep({ .tag eq $current.tag }) if $!of-type;
        my $pos = @siblings.first({ $_ === $current }, :k);
        $pos = @siblings.end - $pos if $!end;
        $pos++;
        #say "offset=$!offset";
        #say "coeff=$!coeff";
        #say "pos=$pos";

        if $!coeff > 0 {
            #say "accept={?(($pos - $!offset) %% $!coeff)} $current";
            ?(($pos - $!offset) %% $!coeff)
        }
        elsif $!coeff < 0 {
            #say "accept={$pos == $!offset} $current";
            #say "access={?(($pos - $!offset) %% $!coeff) && $pos <= $!offset} $current";
            ?(($pos - $!offset) %% $!coeff)
                && $pos <= $!offset #>
        }
        else {
            #say "accept={$pos == $!offset} $current";
            $pos == $!offset
        }
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class PseudoOnly is Pseudo {
    has $.of-type = False;

    multi method ACCEPTS(::?CLASS:D: Tag:D $current) {
        my @siblings = $current.siblings(:tags-only, :!including-self);
        @siblings .= grep({ .tag eq $current.tag }) if $!of-type;
        @siblings.elems == 0
    }

    multi method ACCEPTS(::?CLASS:D: $) { False }
}

my class PseudoEmpty is Pseudo {
    multi method ACCEPTS(::?CLASS: Tag:D $current) {
        $current.children.grep(none(Comment, PI)).elems == 0
    }

    multi method ACCEPTS(::?CLASS: $) { False }
}

my class PseudoChecked is Pseudo {
    multi method ACCEPTS(::?CLASS: Tag:D $current) {
        $current.attr ~~ / ^ [ checked | selected ] $ /
    }

    multi method ACCEPTS(::?CLASS: $) { False }
}

my class PseudoRoot is Pseudo {
    multi method ACCEPTS(::?CLASS: DocumentNode:D $current) {
        $current.parent ~~ Root
    }

    multi method ACCEPTS(::?CLASS: $) { False }
}

grammar Selector {
    rule TOP { <ancestor-child> +% ',' }

    rule ancestor-child { <ancestors=.parent-child> + }
    rule parent-child   { <family=.cousins> +% '>' }
    rule cousins        { <clans=.brother-sister> +% '~' }
    rule brother-sister { <siblings=.node-match> +% '+' }

    token node-match { <selector>+ }

    proto rule selector      { * }
    rule selector:sym<class> { '.' <name> }
    rule selector:sym<id>    { '#' <name> }
    rule selector:sym<attr>  {
        '[' <attr-key> [ <attr-op> <attr-value> ]? ']'
    }
    token selector:sym<pseudo-class> {
        ':' <pseudo-class>
    }
    token selector:sym<tag> {
        [ <.escape> \s | '\\' . | <-[,.#:\[\s>~+()]> ]+ #]
    }
    token selector:sym<any> { '*' }

    proto rule pseudo-class { * }
    rule pseudo-class:sym<not>   { :i not '(' <TOP> ')' }
    rule pseudo-class:sym<nth>   { <nth-x> '(' <equation> ')' }
    rule pseudo-class:sym<first> { <first-x> }
    rule pseudo-class:sym<last>  { <last-x> }
    rule pseudo-class:sym<only>  { <only-x> }
    rule pseudo-class:sym<other> {
        | :i empty
        | :i checked
        | :i root
    }

    token nth-x {
        | :i 'nth-child'
        | :i 'nth-last-child'
        | :i 'nth-of-type'
        | :i 'nth-last-of-type'
    }
    token first-x { :i 'first-child' | :i 'first-of-type' }
    token last-x  { :i 'last-child'  | :i 'last-of-type' }
    token only-x  { :i 'only-child'  | :i 'only-of-type' }

    proto rule equation { * }
    rule equation:sym<even>     { :i even }
    rule equation:sym<odd>      { :i odd }
    rule equation:sym<number>   { $<number> = [ <[+-]>? \d+ ] }
    token equation:sym<function> {
        | <.ws> <coeff> :i n <.ws> $<offset> = <.full-offset> <.ws>
        | <.ws> <coeff> :i n <.ws>
        | <.ws> $<offset> = <.partial-offset> <.ws>
    }

    token coeff { <[+-]>? [ \d+ ]? }
    token full-offset { <[+-]> <.ws> \d+ }
    token partial-offset { <[+-]>? <.ws> \d+ }

    token attr-key { [ <.escape> | <[\w -]> ]+ }
    token attr-value { [
            || '"' $<value> = [ [ '\\"' | <-["]> ]* ] '"'
            || "'" $<value> = [ [ "\\'" | <-[']> ]* ] "'"
            || $<value> = [ <-[ \] ]>+ ]
        ]
        [ \s+ $<case-i> = 'i' ]?
    }

    proto token attr-op { * }
    token attr-op:sym<=>  { '=' }
    token attr-op:sym<~=> { '~=' }
    token attr-op:sym<^=> { '^=' }
    token attr-op:sym<$=> { '$=' }
    token attr-op:sym<*=> { '*=' }

    token name { [ <.escape> | '\\.' | <-[,.#:[) >~+]> ]+ } #]
    token escape {
        | '\\' <-[0..9 a..f A..F]>
        | '\\' <[0..9 a..f A..F]> ** 1..6
    }
}

class Compiler {
    method TOP($/)   {
        if $<ancestor-child>.elems > 1 {
            make any(|$<ancestor-child>».made);
        }
        else {
            make $<ancestor-child>[0].made;
        }
    }

    method ancestor-child($/) {
        if $<ancestors>.elems > 1 {
            make AncestorJoiner.new(combine => $<ancestors>».made);
        }
        else {
            make $<ancestors>[0].made;
        }
    }

    method parent-child($/)   {
        if $<family>.elems > 1 {
            make ParentJoiner.new(combine => $<family>».made);
        }
        else {
            make $<family>[0].made;
        }
    }

    method cousins($/)        {
        if $<clans>.elems > 1 {
            make CousinJoiner.new(combine => $<clans>».made);
        }
        else {
            make $<clans>[0].made;
        }
    }

    method brother-sister($/) {
        if $<siblings>.elems > 1 {
            make SiblingJoiner.new(combine => $<siblings>».made);
        }
        else {
            make $<siblings>[0].made;
        }
    }

    method node-match($/) {
        if $<selector>.elems > 1 {
            make all(|$<selector>».made);
        }
        else {
            make $<selector>[0].made;
        }
    }

    method selector:sym<class>($/) {
        make AttrIs.new(
            name  => 'class',
            op    => '~=',
            value => $<name>.made,
        )
    }
    method selector:sym<id>($/) {
        make AttrIs.new(
            name  => 'id',
            op    => '=',
            value => $<name>.made,
        )
    }
    method selector:sym<attr>($/) {
        with $<attr-op> {
            make AttrIs.new(
                name  => ~$<attr-key>,
                op    => ~$<attr-op>,
                |$<attr-value>.made,
            );
        }
        else {
            make HasAttr.new(name => ~$<attr-key>);
        }
    }
    method selector:sym<pseudo-class>($/) { make $<pseudo-class>.made }
    method selector:sym<tag>($/) { make TagMatch.new(name => (~$/).trim) }
    method selector:sym<any>($/) { make TagMatch.new(name => *) }

    method pseudo-class:sym<not>($/) {
        make PseudoNot.new(groups => $<TOP>.made)
    }
    method pseudo-class:sym<nth>($/) {
        my $nth              = ~$<nth-x>;
        my $end              = $nth.index('-last-').defined;
        my $of-type          = $nth.ends-with('-of-type');
        my ($coeff, $offset) = |$<equation>.made;

        make PseudoNth.new(:$end, :$of-type, :$coeff, :$offset);
    }
    method pseudo-class:sym<first>($/) {
        my $first   = ~$<first-x>;
        my $of-type = $first.ends-with('-of-type');

        make PseudoNth.new(:!end, :$of-type, :coeff(0), :offset(1));
    }
    method pseudo-class:sym<last>($/) {
        my $last    = ~$<last-x>;
        my $of-type = $last.ends-with('-of-type');

        make PseudoNth.new(:end, :$of-type, :coeff(0), :offset(1));
    }
    method pseudo-class:sym<only>($/) {
        make PseudoOnly.new(
            of-type => (~$<only-x>).ends-with('-of-type'),
        );
    }
    method pseudo-class:sym<other>($/) {
        given ~$/ {
            when 'empty'   { make PseudoEmpty.new }
            when 'checked' { make PseudoChecked.new }
            when 'root'    { make PseudoRoot.new }
        }
    }

    method equation:sym<even>($/)     { make [2, 2] }
    method equation:sym<odd>($/)      { make [2, 1] }
    method equation:sym<number>($/)   { make [0, (~$<number>).Int] }
    method equation:sym<function>($/) {
        my $coeff = do given ~$<coeff> {
            when '-' { -1 }
            when ''  { 1 }
            default  { .subst(/\s+/, '').Int }
        }
        my $offset = ($<offset>//'').Str.subst(/\s+/, '').Int // 0;
        make [$coeff, $offset]
    }

    method attr-value($/) {
        my $i = $<case-i> ?? (~$<case-i> eq 'i') !! False;
        make \(value => ~$<value>, :$i);
    }

    method name($/) {
        make (~$/).trim;
    }
}

has $.tree is rw;

method matches(DOM::Tiny::CSS:D: Str:D $css) returns Bool:D {
    my $*TREE-CONTEXT = $!tree.root;
    ?($!tree ~~ _compile($css));
}

method select(DOM::Tiny::CSS:D: Str:D $css) {
    return () unless $!tree ~~ HasChildren;

    my $matcher = _compile($css);
    #dd $matcher;
    my @search = $!tree.child-nodes(:tags-only);
    gather while @search.shift -> $current {
        my $*TREE-CONTEXT = $!tree;
        @search.prepend: $current.child-nodes(:tags-only);
        take $current if $current ~~ $matcher;
    }
}

method select-one(DOM::Tiny::CSS:D: Str:D $css) returns DocumentNode:D {
    self.select($css).first
}

my sub _compile($css) {
    DOM::Tiny::CSS::Selector.parse($css,
        actions => DOM::Tiny::CSS::Compiler,
    ).made // fail('syntax error in selector');
}

my multi _unescape(Str:D $value is copy) {
    # Remove escaped newlines
    $value .= trans([ "\\\n" ] => [ '' ]);

    # Unescape Unicode characters
    $value .= subst(/
        "\\" $<cp> = [ <[ 0..9 a..f A..F ]> ** 1..6 ] \s?
    /, { :16(~$<cp>).chr }, :global);

    # Remove backslash
    $value .= trans([ '\\' ] => [ '' ]);

    $value;
}

my multi _unescape($value) { $value }
