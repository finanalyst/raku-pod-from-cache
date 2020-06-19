use v6.*;

unit class Pod::From::Cache;
use nqp;

class X::Pod::From::Cache::NoPodInCache is Exception {
    has $!pod-file-path;
    method message { "No pod in cache associated with '$!pod-file-path'. Has the path changed?" }
}

has $!doc-source;
has @.extensions;
has $!cache-path;
has $!precomp-repo;
has @.refreshed-pods;
has %.handles;
has @.sources;

submethod BUILD(
    :@!extensions = <pod pod6 p6 pm pm6 rakupod>,
    :$!doc-source = 'docs',
    :$!cache-path = 'rakudoc_cache' # trans OS default directory name ,
    ) {
        $!precomp-repo = CompUnit::PrecompilationRepository::Default.new(
            :store(CompUnit::PrecompilationStore::File.new(:prefix($!cache-path.IO))),
        );
    }

submethod TWEAK {
    for self.get-pods -> $pod-file-path {
use trace;
        my $t = $pod-file-path.IO.modified;
        my $id = CompUnit::PrecompilationId.new-from-string($pod-file-path);
        my $handle;
        my $checksum;
say "At line $?LINE";
        ($handle, $checksum) = $!precomp-repo.load( $id, :src($pod-file-path), :since($t) );
say "At line $?LINE err: ", $!;
        if $! or ! $checksum.defined
        {
            @!refreshed-pods.push( $pod-file-path );
say "At line $?LINE";
            $handle = $!precomp-repo.try-load(
                    CompUnit::PrecompilationDependency::File.new(
                            :src($pod-file-path),
                            :$id,
                            :spec(CompUnit::DependencySpecification.new(:short-name($pod-file-path))),
                            ),
                    );
        }
        %!handles{$pod-file-path} = $handle.unit.Str;

say "At line $?LINE";    }
}

#| Recursively finds all rukupod files with extensions in @!extensions
#| Returns an array of Str
method get-pods {
    @!sources = my sub recurse ($dir) {
        gather for dir($dir) {
            take .Str if  .extension ~~ any( @!extensions );
            take slip sort recurse $_ if .d;
        }
    }($!doc-source); # is the first definition of $dir
}


#| removes the cache using OS dependent arguments.
sub rm-cache($path = 'rakudo_cache' ) is export {
    if $*SPEC ~~ IO::Spec::Win32 {
        my $win-path = "$*CWD/$path".trans( ["/"] => ["\\"] );
        shell "rmdir /S /Q $win-path" ;
    } else {
        shell "rm -rf $path";
    }
}

#| lists the files that have changed
#| since the last time the routine was run
#| This is an alias for @.refreshed-pods as it replaces the same method in Pod::To::Cached
method list-files {
    @!refreshed-pods
}

#| pod(Str $pod-file-path) returns the pod tree in the pod file
method pod( Str $pod-file-path ) {
    X::Pod::From::Cache::NoPodInCache.new(:$pod-file-path).throw
        unless %!handles{ $pod-file-path }:exists;
    nqp::atkey( %!handles{ $pod-file-path }, '$=pod' )
}