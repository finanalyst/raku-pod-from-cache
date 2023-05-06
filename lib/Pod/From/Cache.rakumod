use v6.d;

#| removes the cache using OS dependent arguments.
sub rm-cache($path = 'rakudo_cache' ) is export {
    if $*SPEC ~~ IO::Spec::Win32 {
        my $win-path = "$*CWD/$path".trans( ["/"] => ["\\"] );
        shell "rmdir /S /Q $win-path"  if $win-path.IO.d;
    } else {
        shell "rm -r $path" if $path.IO.d;
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

    my constant CUPSFS = ::("CompUnit::PrecompilationStore::File" ~ ("System","").first({ ::("CompUnit::PrecompilationStore::File$_") !~~ Failure }));

    submethod BUILD(
        :@!extensions = <rakudoc rakumod pod pod6 p6 pm pm6>,
        :$!doc-source = 'docs',
        :$!cache-path = 'rakudoc_cache' # trans OS default directory name
        ) {
           $!precomp-repo = CompUnit::PrecompilationRepository::Default.new(
              :store(CUPSFS.new(:prefix($!cache-path.IO)))
           )
        }

    submethod TWEAK( :$progress, :@ignore = () ) {
        # get the .ignore-cache contents, if it exists and add to a set.
        if ( $!doc-source ~ '/.ignore-cache').IO.f {
            for ($!doc-source ~ '/.ignore-cache').IO.lines {
                $!ignore{$!doc-source ~ '/' ~ .trim}++;
            }
        }
        if +@ignore {
            for @ignore { $!ignore{ $!doc-source ~ '/' ~ .trim }++ }
        }
        self.get-pods;
        $progress.(:start(+@!sources)) if $progress ~~ Callable;
        die "No pod sources in ｢$!doc-source｣."
            unless @!sources;
        for @!sources -> $pod-file-path {
            $progress.(:dec) with $progress;
            my $pod-file-path-io = $pod-file-path.IO;
            my $t = $pod-file-path-io.modified;
            my $id = CompUnit::PrecompilationId.new-from-string($pod-file-path ~ "|" ~ $pod-file-path-io.slurp);
            %!ids{$pod-file-path} = $id.id;
            my ( $handle, $checksum );
            try {
                ( $handle, $checksum ) =
                        $!precomp-repo.load($id, :source($pod-file-path.IO));
            }
            if !$checksum.defined and !$handle {
                @!refreshed-pods.push($pod-file-path);
                $handle = $!precomp-repo.try-load(
                    CompUnit::PrecompilationDependency::File.new(
                        :src($pod-file-path),
                        :$id,
                        :spec(CompUnit::DependencySpecification.new(:short-name($pod-file-path))),
                    )
                );
            }
            CATCH {
                default {
                    %!errors{$pod-file-path} = .message.Str;
                }
            }
        }
        die %!errors.fmt("File source %s has error:\n%s").join("\n")
            if %!errors;
    }

    #| Recursively finds all rakudoc files with extensions in @!extensions
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
    method list-changed-files {
        @!refreshed-pods
    }
    #| see list-refreshed-files
    method list-files {
        @!refreshed-pods
    }

    #| pod(Str $pod-file-path) returns the pod tree in the pod file
    method pod( Str $pod-file-path ) {
        return Nil if $!ignore{$pod-file-path};
        die "No pod in cache associated with ｢$pod-file-path｣. Has the path changed?"
            unless %!ids{$pod-file-path}:exists;
        my $handle = $!precomp-repo.try-load(
                CompUnit::PrecompilationDependency::File.new(
                        :src($pod-file-path),
                        :id(CompUnit::PrecompilationId.new(%!ids{$pod-file-path}))
                        ),
                );

        nqp::atkey( $handle.unit , '$=pod' )
    }
    method source-last-commit {
        my $commit-id = '';
        my $proc = run <<git -C { $!doc-source } rev-parse --short HEAD>>, :out, :err;
        $commit-id = $proc.out.slurp(:close);
        $commit-id = 'git commit failed' if $proc.err.slurp(:close);
        $commit-id
    }
}
