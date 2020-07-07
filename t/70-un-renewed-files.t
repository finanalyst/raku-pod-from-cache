use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;
my $fn = DOC ~ '/.ignore-cache';

# expecting a cache to remain from the last test

my Pod::From::Cache $cache .= new( :doc-source( DOC ), :cache-path( CACHE ));

nok $cache.list-files, 'no files have channged';
$fn.IO.unlink;
rmtree CACHE;

done-testing;
