use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

rmtree CACHE;
my Pod::From::Cache $m;
my $fn = 'simple.pod6';

plan 10;

subtest "Cache works", {
    lives-ok { $m .= new(:doc-source(DOC), :cache-path(CACHE)) }, "Instantiates with minimum parameters";
    ok CACHE.IO.d, 'cache created';

    is-deeply $m.list-files , $m.sources, 'All source files are refreshed' ;

    my $pod = $m.pod( (DOC ~ '/' ~ $fn ) );
    like $pod[0].contents[0].name, /
        'TITLE'
    /, 'Found compiled Title';
    like $pod[0].contents[0].contents[0].contents[0], /
        'Powerful cache'
        /, 'Found compiled Title value';

}

subtest "Refresh", {
    (DOC ~ "/$fn").IO.copy: "t/$fn";
    (DOC ~ "/$fn").IO.spurt(:append, qq:to/END/ );
=begin pod

=head The Time is { now.DateTime.hh-mm-ss }

=end pod
END
    $m .= new(:doc-source(DOC), :cache-path(CACHE) );

    is-deeply $m.refreshed-pods, [ DOC ~ "/$fn" , ], 'Detected refreshed source';

    like $m.pod( DOC ~ "/$fn" )[1].contents[0].contents[0].contents , /
    'The Time is'
    /, 'Found the extra information';

    throws-like { $m.pod(DOC ~ '/unknown-source.pod6') }, X::Pod::From::Cache::NoPodInCache, 'Unknown pod triggers error';
    throws-like { $m.pod(DOC ~ '/simple.pod') }, X::Pod::From::Cache::NoPodInCache, 'Mispelt source-name triggers error';

    my $rv = $m.pod(DOC ~ '/sub/simple.pod6');
    ok $rv.WHAT ~~ Array , 'found same name in subdirectory';

    rmtree CACHE;
    "t/$fn".IO.copy: DOC ~ "/$fn";
    "t/$fn".IO.unlink;
}
done-testing;
