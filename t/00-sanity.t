use Test;

use-ok 'Pod::From::Cache', 'Module OK';

my $m;
use Pod::From::Cache;

lives-ok { $m = Pod::From::Cache.new(:doc-source<t/doctest>) }, "Instantiates with default parameters";

done-testing;
