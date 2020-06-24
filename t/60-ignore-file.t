use Test;
use File::Directory::Tree;

constant CACHE = ~'t'.IO.add('cache');
constant DOC   = ~'t'.IO.add('doctest');

use Pod::From::Cache;

rmtree CACHE;

my $fn = ~DOC.IO.add('.ignore-cache');
$fn.IO.spurt(q:to/IGNORE/);
    # a comment
    contexts.pod6
    IGNORE

my Pod::From::Cache $m .= new( :doc-source( DOC ), :cache-path( CACHE ));
my $h = $m.sources.SetHash;

cmp-ok $h, 'eqv', <community.pod6 operators.pod6 simple.pod6 sub/simple.pod6>.map({$m.path-for-fragment: $_}).SetHash, 'contexts.pod6 is ignored';

is $m.pod( ~DOC.IO.add('contexts.pod6') ) , Nil, 'Ignored files get Nil returned';

$fn.IO.unlink;

rmtree CACHE;

done-testing;
