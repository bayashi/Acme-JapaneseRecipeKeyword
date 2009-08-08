use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Acme::JapaneseRecipeKeyword',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/Acme/JapaneseRecipeKeyword.pm',
    requires => {
        'version'      => 0,
        'Test::More'   => 0,
        'Carp'         => 0,
        'URI'          => 0,
        'Web::Scraper' => 0,
    },
    add_to_cleanup      => [ 'Acme-JapaneseRecipeKeyword-*' ],
);

$builder->create_build_script();
