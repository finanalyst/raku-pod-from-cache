# Pod::From::Cache
>
## Table of Contents
[Description](#description)  
[Caution Caution](#caution-caution)  
[Synopsis](#synopsis)  
[Initialisation](#initialisation)  
[Progress](#progress)  
[Ignore Files](#ignore-files)  
[Exceptions](#exceptions)  
[Examples / testing](#examples--testing)  

----
# Description
This is a replacement for _Pod::To::Cached_, which will be mothballed. It provides only two methods and has far fewer dependencies. It relies only on the CompUnit Modules.

# Caution Caution
_Pod::From::Cache_ relies on the _Precomp_ Modules which are designed to provide precompiled code as quickly as possible. Once a cache has been loaded it is difficult to make changes to the cache in the same program. Consequently it is not possible to change a source on file and for the change to be detected in the same program. 

# Synopsis
```
    use v6.d;
    use Pod::From::Cache;

    my $cache = Pod::From::Cache.new;
    # used the default values of
    # - :extensions = <rakudoc rakumod pod pod6 p6 pm pm6>
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
# Initialisation
When an instance of `Pod::From::Cache` is created, it recursively descends the directory starting at `:doc-source` and extracts all files that match the extensions in the list given by `:extensions`.

If a **Precomp** repository exists under the directory given by `:cache-path`, then any source that is newer than the source in the cache is renewed, and a list of refreshed-pods is collected.

If a repository does not exist, then all files will be added to it.

The list of refreshed files can be obtained as either

*  `$cache.list-files` or

*  `$cache.refreshed-pods`

All of the files found by the recursive descent can be found in `$cache.sources`.

Once `$cache` is instantiated, then the pod for a source file can be obtained as

```
$cache.pod( 'Language/Raku-101.pod' );
```
# Progress
```
my Pod::From::Cache $p .= new( :progress( &count ) );
# somewhere else
sub count(:$start, :$end) { # show a start, then decrease, or inverse thereof }
```
Optionally a closure with signature `(:start, :end)` can be provided that will show progress in some way. This is provided because large Pod6 files take considerable time to process.

*  `:start` is the list of files to be processed.

*  `:dec` is when a file has been processed.

# Ignore Files
It is possible to place a file `.ignore-cache` in the directory specified by `:doc-source` (by default `docs`). An ignore list can be provided via `:ignore` when the object is instantiated.

Each line should be the name of a file (and the path relative to the `:doc-source` directory) that is to be ignored.

Any file exactly matching a file in `.ignore-cache` will not be included in the sources added to the cache.

If the `.pod` method is called with a file matching a name in `.ignore-cache`, it will return Nil, rather than a pod tree.

# Exceptions
The following exceptions are thrown.

*  `X::Pod::From::Cache::NoPodInCache`

	*  An attempt has been made to extract pod from a file not in Sources

*  `X::Pod::From::Cache::NoSources`

	*  No sources matching `extensions` were found under `doc-sources` directory

*  `X::Pod::From::Cache::BadSource`

	*  An error was caught when compiling a file. Probably a compile error. The error is given in the Exception message.

# Examples / testing
Examples for use can be seen in the extra tests. Set the `NoDelete` environment variable to prevent the test directories from being deleted for inspection. Make sure to run the xt tests again without the `NoDelete` variable to clean the test directory.

```
NoDelete=1 prove6 -I. xt/
```






----
Rendered from README at 2023-04-13T09:01:16Z