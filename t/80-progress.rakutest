use Test;
use File::Directory::Tree;

constant CACHE = 't/cache';
constant DOC = 't/doctest';

use Pod::From::Cache;

rmtree CACHE;
my Pod::From::Cache $m;

plan 6;

$m .= new(:doc-source(DOC), :cache-path(CACHE), :progress( &count-down ) );

done-testing;

sub count-down(:$start,:$dec) {
    if $start {
        is $start , 5, 'start given correct number of files'
    }
    if $dec {
        ok $dec , 'dec called';
    }
}