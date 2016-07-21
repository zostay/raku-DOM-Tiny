unit class Mojo::DOM::CSS;
use v6;

use Mojo::DOM::HTML;

grammar Selector {
    rule TOP { <group> +% ',' }
    rule group { <ancestor-child> }

    rule ancestor-child { <ancestors=.parent-child> + }
    rule parent-child   { <family=.cousins> +% '>' }
    rule cousins        { <clans=.brother-sister> +% '~' }
    rule brother-sister { <siblings=.selector> +% '+' }

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
        [ <.escape> \s | '\\.' | <-[,.#:\[ >~+]> ]+ #]
    }
    token selector:sym<any> { '*' }

    proto rule pseudo-class { * }
    rule pseudo-class:sym<not>   { not <TOP> }
    rule pseudo-class:sym<nth>   { <nth-x> <equation> }
    rule pseudo-class:sym<first> { <first-x> }
    rule pseudo-class:sym<last>  { <last-x> }
    rule pseudo-class:sym<only>  { <only-x> }
    rule pseudo-class:sym<other> { empty | checked | warning }

    token nth-x {
        | 'nth-child'
        | 'nth-last-child'
        | 'nth-of-type'
        | 'nth-last-of-type'
    }
    token first-x { 'first-child' | 'first-of-type' }
    token last-x  { 'last-child' | 'last-of-type' }
    token only-x  { 'only-child' | 'only-of-type' }

    proto rule equation { * }
    rule equation:sym<even>     { even }
    rule equation:sym<odd>      { odd }
    rule equation:sym<number>   { $<number> = [ <[+-]>? \d+ ] }
    rule equation:sym<function> {
        $<coeff>  = [ <[+-]>? [ \d+ ]? ]? n
        $<offset> = [ <[+-]>? \d+ ]?
    }

    token attr-key { [ <.escape> | <[\w -]> ]+ }
    token attr-value {
        [ '"' $<value> = [ [ '\\"' | <-["]> ]* ] '"'
        | "'" $<value> = [ [ "\\'" | <-[']> ]* ] "'"
        | $<value> = [ <-[\\]> ]+? ]
        [ \s+ $<case-i> = 'i' ]?
    }

    proto token attr-op { * }
    token attr-op:sym<=>  { '=' }
    token attr-op:sym<~=> { '~=' }
    token attr-op:sym<^=> { '^=' }
    token attr-op:sym<$=> { '$=' }
    token attr-op:sym<*=> { '*=' }

    token name { [ <.escape> | '\\.' | <-[,.#:[ >~+]> ]+ } #]
    token escape {
        | '\\' <-[0..9 a..f A..F]>
        | '\\' <[0..9 a..f A..F]> ** 1..6
    }
}

class Compiler {
    method TOP($/)   { make [ $<group>».made ] }
    method group($/) { make $<ancestor-child>.made }

    method !combinator($/, $group, $joiner, :$flat = True) {
        my @comb = $/{$group}».made;
        make roundrobin(@comb, $joiner xx @comb.elems - 1).flat.list;
    }

    method ancestor-child($/) { self!combinator($/, 'ancestors', ' ') }
    method parent-child($/) { self!combinator($/, 'family', '>') }
    method cousins($/) { self!combinator($/, 'clans', '~') }
    method brother-sister($/) { self!combinator($/, 'siblings', '+') }

    method selector:sym<class>($/) {
        make { attr => (_name('class'), _value('~', ~$<name>)) }
    }
    method selector:sym<id>($/) {
        make { attr => (_name('id'), _value('', ~$<name>)) }
    }
    method selector:sym<attr>($/) {
        make {
            attr => (
                _name(~$<attr-key>),
                _value(~$<attr-op>, |$<attr-value>.made),
            )
        }
    }
    method selector:sym<pseudo-class>($/) { make $<pseudo-class>.made }
    method selector:sym<tag>($/) { make { tag => (~$/).trim } }

    method pseudo-class:sym<not>($/) {
        make { pc => ('not', $<TOP>.made) }
    }
    method pseudo-class:sym<nth>($/) {
        make { pc => (~$<nth-x>, $<equation>.made) }
    }
    method pseudo-class:sym<first>($/) {
        my $suffix = (~$<first-x>).substr('first-'.chars);
        make { pc => ('nth-' ~ $suffix, [ 0, 1 ]) }
    }
    method pseudo-class:sym<last>($/) {
        my $suffix = (~$<last-x>).substr('last-'.chars);
        make { pc => ('nth-' ~ $suffix, [ -1, 1 ]) }
    }
    method pseudo-class:sym<only>($/) {
        make { pc => (~$<only-x>, Nil) }
    }
    method pseudo-class:sym<other>($/) {
        make { pc => (~$/, Nil) }
    }

    method equation:sym<even>($/)     { make [2, 2] }
    method equation:sym<odd>($/)      { make [2, 1] }
    method equation:sym<number>($/)   { make [0, (~$<number>).Int] }
    method equation:sym<function>($/) {
        my $coeff = do given ~$<coeff> {
            when '-' { -1 }
            default  { .Int }
        }
        my $offset = (~$<offset>).Int // 0;
        make [$coeff, $offset]
    }

    method attr-value($/) {
        my $i = (~$<case-i> eq 'i');
        make \($<value>, :$i);
    }
}

has $.tree is rw;

method matches(Mojo::DOM::CSS:D: Str:D $css) {
    $.tree[0] !~~ Tag ?? False !! _match(_compile($css), $.tree, $.tree);
}

method select(Mojo::DOM::CSS:D: Str:D $css) {
    _select($.tree, _compile($css));
}

method select-one(Mojo::DOM::CSS:D: Str:D $css) {
    _select($.tree, _compile($css), :one);
}

my sub _compile($css) {
    Mojo::DOM::CSS::Selector.parse($css,
        actions => Mojo::DOM::CSS::Compiler,
    ).made;
}

my sub _match($group, $current, $tree) {
    _combinator(.reverse, $current, $tree, 0) and return True
        for $group;
    False;
}

my sub _combinator($selectors, $current, $tree, $pos is copy) {
    given $selectors[$pos] {
        when Associative {
            succeed False unless _selector($_, $current);
            succeed True  unless $_ = $selectors[++$pos];
            proceed;
        }

        when '>' {
            _ancestor($selectors, $current, $tree, ++$pos, :one);
        }

        when '~' {
            _sibling($selectors, $current, $tree, ++$pos, :!immediate);
        }

        when '+' {
            _sibling($selectors, $current, $tree, ++$pos, :immediate);
        }

        when ' ' {
            _ancestor($selectors, $current, $tree, ++$pos, :!one);
        }

        default { False }
    }
}

my sub _ancestor($selectors, $current is copy, $tree, $pos, Bool :$one!) {
    while $current = $current[3] {
        return False if $current[0] ~~ Root || $current === $tree;
        return True if _combinator($selectors, $current, $tree, $pos);
        last if $one;
    }

    return False;
}

my sub _sibling($selectors, $current, $tree, $pos, Bool :$immediate!) {
    my $found = False;
    for _siblings($current) -> $sibling {
        return $found if $sibling === $current;

        # "+" (immediately preceding sibling)
        if $immediate { $found = _combinator($selectors, $sibling, $tree, $pos) }

        # "~" (preceding sibling)
        else { return True if _combinator($selectors, $sibling, $tree, $pos) }
    }

    return False;
}

my sub _siblings($current, :$type) {
    my $parent = $current[3];
    my @siblings = $parent[($parent[0] ~~ Root ?? 1 !! 4) .. *].grep: { .[0] ~~ Tag };
    @siblings .= grep({ $type eq .[1] }) with $type;
    return @siblings;
}

my sub _selector($selector, $current) {
    for $selector.kv -> $type, $def {
        given $type {

            # Tag
            when 'tag' {
                succeed False unless $current[1] ~~ $def;
            }

            # Attributes
            when 'attr' {
                succeed False unless _attr(|$def[0,1], $current);
            }

            # Pseudo-class
            when 'pc' {
                succeed False unless _pc(|$def[0,1], $current);
            }
        }
    }

    True;
}

my sub _pc($class, $args, $current) {
    given $class {
        # :checked
        when 'checked' {
            ($current[2]<checked>:exists)
                || ($current[2]<selected>:exists)
        }

        # :not
        when 'not' {
            !_match($args, $current, $current);
        }

        # :empty
        when 'empty' {
            !$current[4 .. *].grep(!_empty(*))
        }

        # :root
        when 'root' {
            $current[3] && $current[3][0] ~~ Root;
        }

        # :only-child or :only-of-type
        when 'only-child' | 'only-of-type' {
            my $type = $class eq 'only-of-type' ?? $current[1] !! Nil;
            for _siblings($current, $type) -> $s {
                succeed False if $s !=== $current;
            }

            True
        }

        default {
            # :nth-child, :nth-last-child, :nth-of-type, :nth-last-of-type
            if $args ~~ Positional {
                my $type = $class.ends-with('of-type') ?? $current[1] !! Nil;
                my @siblings = _siblings($current, $type);
                @siblings .= reverse if $class.starts-with('nth-last');

                for @siblings.keys -> $i {
                    next if (my $result = $args[0] * $i + $args[1]) < 1;
                    last unless my $sibling = @siblings[$result - 1];
                    succeed True if $sibling === $current;
                }
            }

            False
        }
    }
}


my sub _select($tree, $group, Bool :$one = False) {
    my @results;
    my @queue = $tree[($tree[0] ~~ Root ?? 1 !! 4) .. *];
    while @queue.shift -> $current {
        next unless $current[0] ~~ Tag;

        @queue.prepend: $current[4 .. *];
        next unless _match($group, $current, $tree);
        return $current if $one;
        push @results, $current;
    }

    return $one ?? Nil !! @results;
}

my sub _attr($name-re, $value-re, $current) {
    my %attrs = $current[2];
    for %attrs.kv -> $name, $value {
        next unless $name ~~ $name-re;
        return True unless defined $value && defined $value-re;
        return True if $value ~~ $value-re;
    }

    return False;
}

my sub _empty($current) { $current[0] ~~ Comment | PI }

my sub _name($name) {
    my $unescaped-name = _unescape($name);
    regex { [ ^ | ':' ] $unescaped-name }
}

my sub _unescape($value is copy) {
    # Remove escaped newlines
    $value .= trans([ "\\\n" ] => [ '' ]);

    # Unescape Unicode characters
    $value .= subst(/
        "\\" $<cp> = [ <[ 0..9 a..f A..F ]> ** 1..6 ] \s?
    /, { :16($<cp>).chr }, :global);

    # Remove backslash
    $value .= trans([ '\\' ] => [ '' ]);
}

my sub _value($op, $value, Bool :$i = False) {
    return Nil without $value;

    my $unescaped = _unescape($value);

    my $rx = do given $op {
        when '~=' { rx{  [ ^ | \s+ ] $unescaped [ \s+ | $ ] } }
        when '*=' { rx{ $unescaped } }
        when '^=' { rx{ ^ $unescaped } }
        when '$=' { rx{ $unescaped $ } }
        default   { rx{ ^ $unescaped $ } }
    }

    $rx = rx:i{ $rx } if $i;
    $rx;
}
