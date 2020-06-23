use Test;
use File::Directory::Tree;

constant CACHE = ~'t'.IO.add('cache');
constant DOC = ~'t'.IO.add('doctest');

use Pod::From::Cache;

rmtree CACHE;
my Pod::From::Cache $m;

my $fn = 'simple.pod6';
plan 5;

lives-ok { $m .= new(:doc-source(DOC), :cache-path(CACHE)) }, "Instantiates with minimum parameters";
ok CACHE.IO.d, 'cache created';

is-deeply $m.list-files , $m.sources, 'All source files are refreshed' ;

my $pod = $m.pod( ~DOC.IO.add($fn) );
like $pod[0].contents[0].name, /
    'TITLE'
/, 'Found compiled Title';
like $pod[0].contents[0].contents[0].contents[0], /
    'Powerful cache'
    /, 'Found compiled Title value';

diag "Must run 20-refresh.t or copy t/$fn back to t/doctest/";
DOC.IO.add($fn).copy: 't'.IO.add($fn);
DOC.IO.add($fn).spurt(:append, qq:to/END/ );
    =begin pod

    =head The Time is { now.DateTime.hh-mm-ss }

    =end pod
    END
