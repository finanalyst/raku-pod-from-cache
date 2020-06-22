use Test;
use File::Directory::Tree;
use Pod::From::Cache;

constant CACHE = 't/cache';
constant DOC = 't/tmp';

my Pod::From::Cache $m;

# test zero sources in docs

if DOC.IO.d { empty-directory(DOC) }
else { mktree DOC }

(DOC ~ '/notasource.txt').IO.spurt(q:to/TEXT/);
    =begin pod

    This may be valid Pod but the extension is wrong

    =end pod
    TEXT

plan 1;

throws-like { $m .= new(:doc-source(DOC), :cache-path(CACHE)) },
        X::Pod::From::Cache::NoSources, 'No sources detected in directory';

rmtree CACHE;
rmtree DOC;

done-testing;
