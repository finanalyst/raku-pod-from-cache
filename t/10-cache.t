use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

rmtree CACHE;
my Pod::From::Cache $m;

plan 3;

lives-ok { $m .= new(:doc-source(DOC), :cache-path(CACHE)) }, "Instantiates with minimum parameters";
ok CACHE.IO.d, 'cache created';

is-deeply $m.list-files , $m.sources, 'All source files are refreshed' ;

diag 'Prepare for 20-refresh.t';
my $fn = 'simple.pod6';
(DOC ~ "/$fn").IO.copy: "t/$fn";
(DOC ~ "/$fn").IO.spurt(:append, qq:to/END/ );
    =begin pod

    =head The Time is { now.DateTime.hh-mm-ss }

    =end pod
    END

done-testing;
