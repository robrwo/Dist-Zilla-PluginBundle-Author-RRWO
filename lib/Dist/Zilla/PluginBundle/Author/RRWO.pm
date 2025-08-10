package Dist::Zilla::PluginBundle::Author::RRWO;

use v5.20;
use warnings;

our $VERSION = 'v0.2.0';

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

use experimental qw( signatures );

has authority => (
    is       => 'ro',
    isa      => Str,
    init_arg => undef,
    lazy     => 1,
    default  => sub($self) {

        return $self->payload->{'Authority.authority'}
          if exists $self->payload->{'Authority.authority'};

        $self->payload->{authority} // 'cpan:RRWO';    # FIXME
    },
);

has fake_release => (
    is       => 'ro',
    isa      => Bool,
    init_arg => undef,
    lazy     => 1,
    default  => sub { $ENV{FAKE_RELEASE} || $_[0]->payload->{fake_release} // 0 },
);

has plugin_prereq_phase => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { $_[0]->payload->{plugin_prereq_phase} // 'x_Dist_Zilla' },
);

has plugin_prereq_relationship => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => sub { $_[0]->payload->{plugin_prereq_relationship} // 'requires' },
);

has readme => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => 'README.md',
);

has license => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    default => 'LICENSE',
);

sub configure($self) {

    $self->add_bundle(
        'Git' => {
            allow_dirty => [qw/ dist.ini /],
            push_to     => 'origin master:master',    # configurable main:main
            tag_format  => '%v',
            commit_msg  => '%v%n%n%c',
        }
    );

    $self->add_plugins(

        [
            'Prereqs' => 'BuildRequires' => {
                '-phase'        => 'build',
                '-relationship' => 'requires',

                # TODO hashref of build_requires
            }
        ],

        [
            'Prereqs' => 'TestRequires' => {
                '-phase'        => 'test',
                '-relationship' => 'requires',

                # TODO hashref of test_requires
            }
        ],

        [
            'Prereqs' => 'RuntimeRequires' => {
                '-phase'        => 'runtime',
                '-relationship' => 'requires',

                # TODO hashref of runtime_requires
            }
        ],

        [
            'Prereqs' => 'DevelopRequires' => {
                '-phase'        => 'develop',
                '-relationship' => 'requires',

                # TODO hashref of develop_requires
            }
        ],

        [
            'Prereqs' => 'DevelopRecommends' => {
                '-phase'          => 'develop',
                '-relationship'   => 'recommends',
                $self->meta->name => $self->VERSION,
            }
        ],

        [
            'Keywords'    # TODO keyword (multi)
        ],

        [
            'GatherDir' => {
                exclude_filename => [ $self->readme, $self->license, qw( SECURITY.md cpanfile ), ],
                prune_directory  => [qw( ^local )],
            },
        ],

        ['PruneCruft'],

        ['CPANFile'],
        [
            'License' => {
                ':version' => '5.038',
                filename   => $self->license,
            }
        ],
        ['ExecDir'],
        ['ShareDir'],
        ['MakeMaker'],
        ['Manifest'],
        ['TestRelease'],
        ['CheckExtraTests'],
        ['ConfirmRelease'],
        ['Signature'],
        ['UploadToCPAN'],
        ['RecommendedPrereqs'],
        ['AutoPrereqs'],    # TODO skip (multi)

        [
            'SecurityPolicy',
            {
                # TODO use git_url and check for report_url
            }
        ],

        ['PodWeaver'],

        [
            'UsefulReadme' => {
                phase    => 'build',
                type     => 'gfm',
                filename => $self->readme,
                location => 'build',
            }
        ],

        [
            'CopyFilesFromBuild' => {
                copy => [ $self->readme, 'cpanfile', $self->skipfile ],    # FIXME

            }
        ],

        [
            'Metadata' => {
                x_authority => $self->authority,

                # FIXME
            },
        ],
        ['MetaProvides::Package'],
        ['MetaJSON'],
        ['MetaYAML'],

        ['CheckMetaResources'],
        ['MetaTests'],
        [
            'MetaNoIndex' => {
                directory => [ qw(t xt), qw(inc local perl5 fatlib examples share devel) ],
            }
        ],
        ['PodSyntaxTests'],
        ['Test::Pod::Coverage::Configurable'],
        ['Test::Pod::LinkCheck'],
        ['Test::ChangesHasContent'],
        ['Test::DistManifest'],
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
        [
            'Test::PodSpelling' => {
                ':version' => '2.006003'
            }
        ],
        [
            'PodCoverageTests'

            # Test::Pod::Coverage::Configurable uses Perl v5.13.1 syntax
        ],
        ['Test::Fixme'],
        [
            'Test::Kwalitee' => {
                ':version' => '2.10',
                filename   => 'xt/author/kwalitee.t'
            }
        ],
        [
            'Test::ReportPrereqs' => {
                ':version'        => '0.022',
                version_extractor => 'Module::Metadata',
                verify_prereqs    => 1,
            }
        ],

        [
            'Test::Perl::Critic',
            {
                # FIXME configurable but only set if file exists
                critic_config => 'xt/etc/perlcritic.rc'
            }
        ],
        ['MojibakeTests'],
        ['Test::MixedScripts'],
        ['Test::CPAN::Changes'],
        ['Test::UnusedVars'],
        ['MetaTests'],
        ['Test::Version'],
        [ 'Test::Compile', { filename => 'xt/00-compile.t' } ],
        ['Test::CVE'],

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

        ['GitHub::Meta'],
        [
            'Git::Contributors' => {
                ':version' => '0.029',
                order_by   => 'name'
            }
        ],
    );

}

1;
