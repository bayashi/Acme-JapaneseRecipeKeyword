package Acme::JapaneseRecipeKeyword;

use warnings;
use strict;
use utf8;
use Carp;

use URI;
use Web::Scraper;

use version; our $VERSION = qv('0.0.1');

# scraping targets
our $site_info = [
    {
        url    => 'http://recipe.gourmet.yahoo.co.jp/dish/',
        scrape => '.detail-genre li a',
    },
    {
        url    => 'http://recipe.gourmet.yahoo.co.jp/sweets/',
        scrape => '.detail-genre li a',
    },
    {
        url    => 'http://recipe.gourmet.yahoo.co.jp/materials/',
        scrape => '.ingredients-list li a',
    },
    {
        url    => 'http://cookpad.com/category/list',
        scrape => '.categories .sub-category a',
        regex  => '（[\d,]+）$',
    },
];


sub new {
    my $class = shift;
    my %opt   = @_;

    my $self = bless \%opt, $class;

    $self->crawl if $self->_crawl;

    return $self;
}

sub crawl {
    my $self = shift;

    my %keywords;
    for my $info ($self->site_info) {
        my $scraper = scraper {
            process $info->{scrape}, 'categories[]' => {
                label => 'TEXT',
            };
        };
        my $list = $scraper->scrape( URI->new($info->{url}) );
        if (ref $list->{categories} eq 'ARRAY') {
            for my $category ( @{$list->{categories}} ) {
                my $label = $category->{label};
                $label =~ s/$info->{regex}// if $info->{regex};
                $self->{keywords}->{$label}++;
            }
        }
    }

    return $self;
}

sub get_keywords {
    my $self = shift;
    my %opt  = @_;

    if ($opt{sort}) {
        return sort { $self->{keywords}->{$b} <=> $self->{keywords}->{$a} }
                                                    keys %{$self->{keywords}};
    }
    else {
        return keys %{$self->{keywords}};
    }
}

sub site_info {
    my $self = shift;
    my $info = shift;

    unless ($info) {
        return @{$site_info};
    }
    else {
        push @{$site_info}, $info if ref $info eq 'HASH';
    }
}

sub _crawl {
    my $self = shift;

    return $self->{crawl};
}

1;

__END__


=head1 NAME

Acme::JapaneseRecipeKeyword - collect words, related cooking


=head1 SYNOPSIS

    use Data::Dumper;
    use Acme::JapaneseRecipeKeyword;

    my $recipe_keyword = Acme::JapaneseRecipeKeyword->new;
    $recipe_keyword->crawl;
    print Dumper $recipe_keyword->get_keywords;


=head1 METHOD

=head2 new(I<%arg>)

This constructor will create a Acme::JapaneseRecipeKeyword object.
The following arguments are accepted:

=over 4

=item crawl

construct and call crawl method

    my $recipe_keyword = Acme::JapaneseRecipeKeyword->new('crawl' => 1);

same as

    my $recipe_keyword = Acme::JapaneseRecipeKeyword->new;
    $recipe_keyword->crawl;

=head2 crawl

crawl sites and set keywords

=head2 get_keywords

return keywords

=head2 site_info

return scraping targets data, or set site_info

=back


=head1 AUTHOR

Copyright (c) 2009, Dai Okabayashi C<< <bayashi@cpan.org> >>


=head1 LICENCE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

