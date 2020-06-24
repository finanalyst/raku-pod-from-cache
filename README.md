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
# - :extensions = <rakudoc pod pod6 p6 pm pm6>
# - :doc-source = 'docs',
# - :cache-path = 'rakudoc_cache'

say "Files changed since the cache was last refreshed";
say '(None)' unless +$cache.list-files;
.say for $cache.list-files;

# Get and use pod in a source
dd $cache.pod( $cache.sources[0] );

rm-cache( 'rakudoc_cache' );
# removes the cache directory using OS dependent methods.

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

## Ignore Files
It is possible to place a file `.ignore-cache` in the directory specified by `:doc-source` (by default `docs`).

Each line should be the name of a file (and the path relative to the `:doc-source` directory) that is to be ignored.

Any file exactly matching a file in `.ignore-cache` will not be included in the sources added
to the cache.

If the `.pod` method is called with a file matching a name in `.ignore-cache`, it will return Nil, rather
than a pod tree.

## Exceptions

The following exceptions are thrown.

- `X::Pod::From::Cache::NoPodInCache`

An attempt has been made to extract pod from a file not in Sources

- `X::Pod::From::Cache::NoSources`

No sources matching `extentions` were found under `doc-sources` directory

- `X::Pod::From::Cache::BadSource`

An error was caught when compiling a file. Probably a compile error. The error is given in the
Exception message.
