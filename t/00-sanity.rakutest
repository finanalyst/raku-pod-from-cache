use v6.d;
use Test;

plan 2;
use-ok 'Pod::From::Cache', 'Module OK';

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if AUTHOR {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
    skip-rest "Skipping author test";
    exit;
}

done-testing;
