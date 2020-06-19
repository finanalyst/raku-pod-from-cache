# Pod::From::Cache

## Description
    This is a replacement for Pod::To::Cached, which will be mothballed.
    It provides only two methods and has far fewer dependencies. It relies only
    on the CompUnit Modules.
    
   
## Synopsis
``` raku
use v6.d;
use Pod::From::Cache;

my $cache = Pod::From::Cache.new;
# used the default values of
# - :extensions = <pod pod6 p6 pm pm6 rakupod>
# - :doc-source = 'docs',
# - :cache-path = 'rakudoc_cache'

say "Files changed since the cache was last refreshed";
say '(None)' unless +$cache.list-files;
.say for $cache.list-files;

# Get and use pod in a source
dd $cache.pod( $cache.sources[0] );
```

## Initialisation

When an instance of `Pod::From::Cache` is created, it recursively descends the directory
starting at `:doc-source` and extracts all files that match the extensions in the list
given by `:extensions`. 

If a *Precomp* repository exists under the directory given by `:cache-path`, then any source
that is newer than the source in the cache is renewed, and a list of refreshed-pods is collected.

If a repository does not exist, then all files will be added to it.

The list of refreshed files can be obtained as either
- `$cache.list-files` or
- `$cache.refreshed-pods`

All of the files found by the recursive descent can be found in 
`$cache.sources`.

Once `$cache` is instantiated, then the pod for a source file can be obtained as
```raku
$cache.pod( 'Language/Raku-101.pod' );
```