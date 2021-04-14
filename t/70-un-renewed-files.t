use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;
my $fn = DOC ~ '/.ignore-cache';

rmtree CACHE;
my Pod::From::Cache $cache .= new( :doc-source( DOC ), :cache-path( CACHE ));

$cache .= new( :doc-source( DOC ), :cache-path( CACHE ));
nok $cache.list-files, 'no files have changed';
$fn.IO.unlink;
rmtree CACHE;

done-testing;
