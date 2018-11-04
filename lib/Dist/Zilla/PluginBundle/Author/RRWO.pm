package Dist::Zilla::PluginBundle::Author::RRWO;

use v5.10;

use strict;
use warnings;

our $VERSION = 'v0.1.0';

use Moose;
with
  'Dist::Zilla::Role::PluginBundle::Easy',
  'Dist::Zilla::Role::PluginBundle::PluginRemover' => { -version => '0.103' },
  'Dist::Zilla::Role::PluginBundle::Config::Slicer';

use Types::Standard -types;

use Module::Metadata                   ();
use Pod::Weaver::Plugin::AppendPrepend ();
use Pod::Weaver::Section::Contributors ();
use Pod::Weaver::Section::SourceGitHub ();
use Test::TrailingSpace                ();

# RECOMMEND PREREQ: Type::Tiny::XS

has authority => (
    is       => 'ro',
    isa      => Str,
    init_arg => undef,
    lazy     => 1,
    default  => sub {
        my $self = shift;

        return $self->payload->{'Authority.authority'}
          if exists $self->payload->{'Authority.authority'};

        $self->payload->{authority} // 'cpan:RRWO';
    },
);

has fake_release => (
    is       => 'ro',
    isa      => Bool,
    init_arg => undef,
    lazy     => 1,
    default =>
      sub { $ENV{FAKE_RELEASE} || $_[0]->payload->{fake_release} // 0 },
);

has plugin_prereq_phase => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{plugin_prereq_phase} // 'x_Dist_Zilla' },
);

has plugin_prereq_relationship => (
    is   => 'ro',
    isa  => Str,
    lazy => 1,
    default =>
      sub { $_[0]->payload->{plugin_prereq_relationship} // 'requires' },
);

has cpanfile => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => 'cpanfile',
);

has skipfile => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => 'MANIFEST.SKIP',
);

has readme => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => 'README.md',
);

sub configure {
    my ($self) = @_;

    $self->add_plugins(

        [
            'Prereqs' => 'pluginbundle version' => {
                '-phase'          => 'develop',
                '-relationship'   => 'recommends',
                $self->meta->name => $self->VERSION,
            }
        ],

        [
         'Keywords'
        ],

        [
            'GatherDir' => {
                exclude_filename =>
                  [ $self->readme, $self->cpanfile, $self->skipfile ],
            },
        ],
        ['PruneCruft'],
        ['CPANFile'],
        [
            'License' => {
                ':version' => '5.038',
                filename   => 'LICENSE',
            }
        ],
        ['ExtraTests'],
        ['ExecDir'],
        ['ShareDir'],
        ['MakeMaker'],
        ['Manifest'],
        ['TestRelease'],
        ['ConfirmRelease'],
        ['UploadToCPAN'],
        ['RecommendedPrereqs'],
        ['AutoPrereqs'],
        [
            'RemovePrereqs' => {
                remove => [qw/ strict warnings /],
            },
        ],
        [
            'EnsurePrereqsInstalled' => {
                ':version' => '0.003',
                'type'     => [qw/ requires recommends /],
            }
        ],

        ['GitHub::Meta'],
        [
            'Git::Contributors' => {
                ':version' => '0.029',
                order_by => 'name'
            }
        ],

        ['PodWeaver'],
        [
            'ReadmeAnyFromPod' => {
                type     => 'gfm',
                filename => $self->readme,
                location => 'build',
            }
        ],

        [
            'Generate::ManifestSkip' => {
                ':version' => 'v0.1.3',
                skipfile   => $self->skipfile,
            }
        ],

        [
            'CopyFilesFromBuild' => {
                copy => [ $self->readme, $self->cpanfile, $self->skipfile ],

            }
        ],

        [
            'Metadata' => {
                x_authority => $self->authority,
            }
        ],
        ['MetaProvides::Package'],
        ['MetaJSON'],
        ['MetaYAML'],
        [
            'InstallGuide' => {
                ':version' => '1.200005',
            }
        ],

        ['MetaTests'],
        ['PodSyntaxTests'],
        ['Test::ChangesHasContent'],
        ['Test::CheckManifest'],
        ['Test::EOF'],
        [
            'Test::EOL' => {
                ':version' => '0.14',
            }
        ],
        [
            'Test::NoTabs' => {
                ':version' => '0.08',
            }
        ],
        [
            'Test::Portability' => {
                ':version' => '2.000007',
            },
        ],
        [
            'Test::TrailingSpace' => {
                filename_regex => '\.(?:p[lm]|pod)\z',
            }
        ],
        [
            'Test::MinimumVersion' => {
                ':version' => '2.000008',
            }
        ],
        ['Test::Pod::Coverage::Configurable'],
        ['Test::Fixme'],
        [
            'Test::ReportPrereqs' => {
                ':version'        => '0.022',
                version_extractor => 'Module::Metadata',
                verify_prereqs    => 1,
            }
        ],
        ['RewriteVersion'],
        ['NextRelease'],
        ['BumpVersionAfterRelease'],
        [
            'Git::Commit' => {
                allow_dirty_match => '^lib/',
                commit_msg        => 'Commit Changes and bump $VERSION',
                -phase            => 'Commit_Changes',
            }
        ],
    );

    $self->add_bundle(
        'Git' => {
            allow_dirty => [qw/ dist.ini /],
            push_to     => 'origin master:master',
            tag_format  => '%v',
            commit_msg  => '%v%n%n%c',
        }
    );

}

1;
