use Test;

use File::Directory::Tree;
use Pod::From::Cache;

constant CACHE = 't/cache';
constant DOC = 't/tmp';

my Pod::From::Cache $m;

plan 1;
rmtree CACHE;
if DOC.IO.d { empty-directory(DOC) }
else { mktree DOC }

(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =pod A test file
    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT


throws-like { $m .= new(:doc-source(DOC), :cache-path(CACHE)) },
        X::Pod::From::Cache::BadSource, 'Caught compile error', message => / 'File source' .+ 'a-pod-file' .+ 'has error:' /;

diag 'Prepare for t/45-compile-ok';

(DOC ~ '/a-pod-file.pod6').IO.spurt(q:to/POD-CONTENT/);
    =begin pod

    =TITLE This is a title

    Some text

    =end pod
    POD-CONTENT

done-testing;
