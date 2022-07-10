use Test;
use Pod::From::Cache;
use File::Temp;

constant TMP = tempdir;
constant REP = TMP ~ '/ref';
constant DOC = 't/doctest';

constant COUNT = 3; # number of caches to create

plan 2 * COUNT;

diag "Create multiple ({ COUNT }) caches";

my @caches;

for ^COUNT {
    lives-ok {
        @caches[$_] = Pod::From::Cache.new( :doc-source( DOC ), :cache-path( REP ~ $_ ) )
    }, "created cache no $_";
 }
todo 'Only one instance per program allowed by Precomp Modules', 3;
for ^COUNT {
    ok (REP ~ $_ ).IO.d, "Repo $_ "
}

done-testing;
