#!/usr/bin/env perl6

my $pod-file-path = "simple.pod6";
my $t = $pod-file-path.IO.modified;
say 'At line ',$?LINE, ' file was last modifed at ', $t.DateTime.hh-mm-ss;
my $id = CompUnit::PrecompilationId.new-from-string($pod-file-path);
my $f = CompUnit::PrecompilationDependency::File.new(
        :src($pod-file-path),
        :$id,
        :spec(CompUnit::DependencySpecification.new(:short-name($pod-file-path))),
        );
my $precomp-repo = CompUnit::PrecompilationRepository::Default.new(
        :store(CompUnit::PrecompilationStore::File.new(:prefix('tcache'.IO))),
        );
my $pod;
use nqp;
my $hand;
my $cs;
($hand, $cs) = $precomp-repo.load( $id, :src($pod-file-path), :since($t) );
if $! or ! $cs.defined
    {
        say "Use try-load";
        $hand = $precomp-repo.try-load(
                $f,
                );
    }
$pod = nqp::atkey($hand.unit, '$=pod');
dd $pod;

$pod-file-path.IO.spurt(:append, qq:to/END/);
    =begin pod

    =head Time is { DateTime.now.hh-mm-ss }

    =end pod
    END
