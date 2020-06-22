use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

rmtree CACHE;
my Pod::From::Cache $m;

plan 5;

lives-ok { $m .= new(:doc-source(DOC), :cache-path(CACHE)) }, "Instantiates with minimum parameters";
ok CACHE.IO.d, 'cache created';

is-deeply $m.list-files , $m.sources, 'All source files are refreshed' ;

my $pod = $m.pod( (DOC ~ '/simple.pod6' ) );
like $pod[0].contents[0].name, /
    'TITLE'
/, 'Found compiled Title';
like $pod[0].contents[0].contents[0].contents[0], /
    'Powerful cache'
    /, 'Found compiled Title value';

diag 'Must run 20-refresh.t or copy t/simple.pod6 back to t/doctest/';
my $fn = 'simple.pod6';
(DOC ~ "/$fn").IO.copy: "t/$fn";
(DOC ~ "/$fn").IO.spurt(:append, qq:to/END/ );
    =begin pod

    =head The Time is { now.DateTime.hh-mm-ss }

    =end pod
    END

done-testing;
