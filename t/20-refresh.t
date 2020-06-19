use Test;
use File::Directory::Tree;

# This test must follow 10-cache.t

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

my Pod::From::Cache $m;

my $fn = 'simple.pod6';
plan 2;

$m .= new(:doc-source(DOC), :cache-path(CACHE) );

is-deeply $m.refreshed-pods, [ DOC ~ "/$fn" , ], 'Detected refreshed source';

like $m.pod( DOC ~ "/$fn" )[1].contents[0].contents[0].contents , /
    'The Time is'
    /, 'Found the extra information';

rmtree CACHE;
rmtree $fn;
"t/$fn".IO.copy: DOC ~ "/$fn";
"t/$fn".IO.unlink;

done-testing;
