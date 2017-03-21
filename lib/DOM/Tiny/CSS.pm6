unit class DOM::Tiny::CSS;
use v6;

use DOM::Tiny::HTML;

my class Joiner {
    has @.combine;

    submethod BUILD(:@combine) {
        PRE { @combine.elems !%% 2 }
        @!combine = @combine.reverse;
    }

    # TODO This is a slightly horrible recursive solution. A loop may be
    # preferable.

    my sub next-combination(@next, $current) {
        return True unless @next;
        try-combination(@next[0], @next[1], @next[2..*], $current);
    }

    my multi try-combination('', $test, @next, $current) {
        my @possibles = $current.ancestor-nodes(:context).grep($test);

        return False unless @possibles;

        for @possibles -> $ancestor {
            return True if next-combination(@next, $ancestor);
        }

        False;
    }

    my multi try-combination('>', $test, @next, $current) {
        return False if $*TREE-CONTEXT.defined && $current === $*TREE-CONTEXT;
        return False unless $current.parent ~~ $test;
        next-combination(@next, $current.parent);
    }

    my multi try-combination('+', $test, @next, $current) {
        my $siblings := $current.split-siblings(:tags-only)<before>;
        return False unless $siblings.elems > 0;
        my $previous-sibling = $siblings[*-1];
        return False unless $previous-sibling ~~ $test;
        next-combination(@next, $previous-sibling);
    }

    my multi try-combination('~', $test, @next, $current) {
        my @previous-siblings = $current.split-siblings(:tags-only)<before>.reverse;
        my @possibles = @previous-siblings.grep($test);

        return False unless @possibles;

        for @possibles -> $sibling {
            return True if next-combination(@next, $sibling);
        }

        False;
    }

    multi method ACCEPTS(::?CLASS:D: DocumentNode:D $current is copy) {
        return False unless $current ~~ @!combine[0];
        return True if @!combine.elems == 1;
        next-combination(@!combine[1..*], $current);
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
        my $unescaped-re = $!i ?? rx:i{ $unescaped } !! rx{ $unescaped };

        $!rx := do given $!op {
            when '~=' { rx{ [ ^ | \s+ ] $unescaped-re [ \s+ | $ ] } }
            when '*=' { rx{ $unescaped-re } }
            when '^=' { rx{ ^ $unescaped-re } }
            when '$=' { rx{ $unescaped-re $ } }
            default   { rx{ ^ $unescaped-re $ } }
        }
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
    rule TOP { <joiner> +% ',' }

    token joiner {
        <.ws> <node-match>
            [ <join-op> <node-match> ]* <.ws>
    }
    token join-op {
        | \s+ <!before '>' | '~' | '+'>
        | <.ws> '>' <.ws>
        | <.ws> '~' <.ws>
        | <.ws> '+' <.ws>
    }

    token node-match { <selector>+ }

    proto token selector      { * }
    token selector:sym<class> { '.' <name> }
    token selector:sym<id>    { '#' <name> }
    token selector:sym<attr>  {
        '[' <.ws> <attr-key> <.ws> [ <attr-op> <.ws> <attr-value> <.ws> ]? ']'
    }
    token selector:sym<pseudo-class> {
        ':' <pseudo-class>
    }
    token selector:sym<tag> {
        [ <.escape> \s || '\\' . || <-[,.#:\[\s>~+()]> ]+ #]
    }
    token selector:sym<any> { '*' }

    proto token pseudo-class { * }
    token pseudo-class:sym<not>   { :i not '(' <TOP> ')' }
    token pseudo-class:sym<nth>   { <nth-x> '(' <.ws> <equation> <.ws> ')' }
    token pseudo-class:sym<first> { <first-x> }
    token pseudo-class:sym<last>  { <last-x> }
    token pseudo-class:sym<only>  { <only-x> }
    token pseudo-class:sym<other> {
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
    token equation:sym<even>     { :i even }
    token equation:sym<odd>      { :i odd }
    token equation:sym<number>   { $<number> = [ <[+-]>? \d+ ] }
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
            || $<value> = [ <-[ \  \] ]>+ ]
        ]
        [ \s+ $<case-i> = 'i' ]?
    }

    proto token attr-op { * }
    token attr-op:sym<=>  { '=' }
    token attr-op:sym<~=> { '~=' }
    token attr-op:sym<^=> { '^=' }
    token attr-op:sym<$=> { '$=' }
    token attr-op:sym<*=> { '*=' }

    token name { [ <.escape> \s || '\\' . || <-[\\,.#:[\ )>~+]> ]+ } #]
    token escape {
        | '\\' <-[0..9 a..f A..F]>
        | '\\' <[0..9 a..f A..F]> ** 1..6
    }
}

class Compiler {
    method TOP($/)   {
        if $<joiner>.elems > 1 {
            make any(|$<joiner>».made);
        }
        else {
            make $<joiner>[0].made;
        }
    }

    method joiner($/) {
        make Joiner.new(
            combine => flat roundrobin(
                $<node-match>».made,
                $<join-op>».Str».trim,
            ),
        );
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

    method name($/) { make ~$/ }
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
