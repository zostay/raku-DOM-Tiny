use v6;

use Test;
use DOM::Tiny;

#plan 6;

lives-ok {
    with DOM::Tiny.parse: "<foo><bar>meow</bar></foo>" {
        for .find("foo") {
            .content: DOM::Tiny.parse: "meow";
        }
        is ~$_, '<foo>meow</foo>';
    }
}

lives-ok {
    with DOM::Tiny.parse: "<foo><bar>meow</bar></foo>" {
        for .find("foo") {
            .content: ~DOM::Tiny.parse("<b>meow</b>").at: "b";
        }
        is ~$_, '<foo><b>meow</b></foo>';
    }
}

todo 'This immutability problem needs to be tracked down and resolved.';

lives-ok {
    with DOM::Tiny.parse: "<foo><bar>meow</bar></foo>" {
        for .find("foo") {
            .content: DOM::Tiny.parse("<b>meow</b>").at: "b";
        }
        is ~$_, '<foo><b>meow</b></foo>';
    }
}

done-testing;
