use Test;
use File::Directory::Tree;

# This test must follow 10-cache.t

constant CACHE = 't'.IO.add('cache');
constant DOC = 't'.IO.add('doctest');

use Pod::From::Cache;

my Pod::From::Cache $m;

my $fn = 'simple.pod6';
plan 5;

$m .= new(:doc-source(DOC), :cache-path(CACHE) );

is-deeply $m.refreshed-pods, [ ~DOC.IO.add($fn) , ], 'Detected refreshed source';

like $m.pod( ~DOC.IO.add($fn) )[1].contents[0].contents[0].contents , /
    'The Time is'
    /, 'Found the extra information';

throws-like { $m.pod(~DOC.IO.add('unknown-source.pod6')) }, X::Pod::From::Cache::NoPodInCache, 'Unknown pod triggers error';
throws-like { $m.pod(~DOC.IO.add($fn.chop)) }, X::Pod::From::Cache::NoPodInCache, 'Mispelt source-name triggers error';

my $rv = $m.pod(~DOC.IO.add('sub').add($fn));
ok $rv.WHAT ~~ Array , 'found same name in subdirectory';

rmtree CACHE;
't'.IO.add($fn).copy: DOC.IO.add($fn);
't'.IO.add($fn).unlink;

done-testing;
