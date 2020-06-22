use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

rmtree CACHE;

my $fn = DOC ~ '/.ignore-cache';
$fn.IO.spurt(q:to/IGNORE/);
    # a comment
    contexts.pod6
    IGNORE

my Pod::From::Cache $m .= new( :doc-source( DOC ), :cache-path( CACHE ));
my $h = $m.sources.SetHash;
ok $h<t/doctest/community.pod6 t/doctest/operators.pod6 t/doctest/simple.pod6 t/doctest/sub/simple.pod6 >, 'contexts.pod6 is ignored';

is $m.pod( DOC ~ '/contexts.pod6' ) , Nil, 'Ignored files get Nil returned';

$fn.IO.unlink;

rmtree CACHE;

done-testing;
