use v6.*;

class X::Pod::From::Cache::NoPodInCache is Exception {
    has $.pod-file-path;
    method message { "No pod in cache associated with '$!pod-file-path'. Has the path changed?" }
}
class X::Pod::From::Cache::NoSources is Exception {
    has $.doc-source;
    method message { "No pod sources in '$!doc-source'." }
}
class X::Pod::From::Cache::BadSource is Exception {
    has %.errors;
    method message {
        %!errors.fmt("File source %s has error:\n%s").join("\n")
    }
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

class Pod::From::Cache {
    use nqp;

    has $!doc-source;
    has @.extensions;
    has $!cache-path;
    has $!precomp-repo;
    has @.refreshed-pods;
    has @.sources;
    has %!errors;
    has %!ids;
    has SetHash $!ignore .= new;

    submethod BUILD(
        :@!extensions = <rakudoc pod pod6 p6 pm pm6>,
        :$!doc-source = 'docs',
        :$!cache-path = 'rakudoc_cache' # trans OS default directory name ,
        ) {
            $!precomp-repo = CompUnit::PrecompilationRepository::Default.new(
                :store(CompUnit::PrecompilationStore::File.new(:prefix($!cache-path.IO))),
            );
        }

    submethod TWEAK {
        # get the .ignore-cache contents, if it exists and add to a set.
        if ( $!doc-source ~ '/.ignore-cache').IO.f {
            for ($!doc-source ~ '/.ignore-cache').IO.lines {
                $!ignore{ $!doc-source ~ '/' ~ .trim }++;
            }
        }
        self.get-pods;
        X::Pod::From::Cache::NoSources.new(:$!doc-source).throw
            unless @!sources;
        for @!sources -> $pod-file-path {
            my $t = $pod-file-path.IO.modified;
            my $id = CompUnit::PrecompilationId.new-from-string($pod-file-path);
            %!ids{$pod-file-path} = $id.id;
            my $handle;
            my $checksum;
            try {
                ($handle, $checksum) = $!precomp-repo.load( $id, :src($pod-file-path), :since($t) );
            }
            if $! or ! $checksum.defined {
                @!refreshed-pods.push($pod-file-path);
                $handle = $!precomp-repo.try-load(
                    CompUnit::PrecompilationDependency::File.new(
                        :src($pod-file-path),
                        :$id,
                        :spec(CompUnit::DependencySpecification.new(:short-name($pod-file-path))),
                    )
                )
            }
            CATCH {
                default {
                    %!errors{$pod-file-path} = .message.Str;
                }
            }
        }
        X::Pod::From::Cache::BadSource.new(:errors(%!errors.list)).throw
            if %!errors;
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
        @!sources .= grep({ ! $!ignore{$_} });
    }

    #| lists the files that have changed
    #| since the last time the routine was run
    #| This is an alias for @.refreshed-pods as it replaces the same method in Pod::To::Cached
    method list-files {
        @!refreshed-pods
    }

    #| pod(Str $pod-file-path) returns the pod tree in the pod file
    method pod( Str $pod-file-path ) {
        return Nil if $!ignore{$pod-file-path};
        X::Pod::From::Cache::NoPodInCache.new(:$pod-file-path).throw
            unless %!ids{$pod-file-path}:exists;
        my $handle = $!precomp-repo.try-load(
                CompUnit::PrecompilationDependency::File.new(
                        :src($pod-file-path),
                        :id(CompUnit::PrecompilationId.new(%!ids{$pod-file-path}))
                        ),
                );

        nqp::atkey( $handle.unit , '$=pod' )
    }
}
