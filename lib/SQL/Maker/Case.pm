package SQL::Maker::Case;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use SQL::Maker::Condition;

sub _new_condition {
    my $self = shift;
    return SQL::Maker::Condition->new(
        name_sep   => $self->{name_sep},
        quote_char => $self->{quote_char},
    );
}

sub new {
    my ($class, %args) = @_;
    return bless \%args => $class;
}

sub when {
    my ($self, $when, $value) = @_;
    $when = $$when if ref $when eq 'REF';

    my ($when_cond_sql, @bind);
    if (ref $when eq 'HASH') {
        my $cond = $self->_new_condition;
        for my $key (keys %$when) {
            $cond->add($key, $when->{$key});
        }
        $when_cond_sql = $cond->as_sql;
        @bind          = $cond->bind;
    }
    elsif (ref $when eq 'ARRAY') {
        ($when_cond_sql, @bind) = @$when;
    }
    elsif (ref $when eq 'SCALAR') {
        $when_cond_sql = $$when;
    }
    else {
        require Carp;
        Carp::croak("invalid args.");
    }

    my ($val_sql, $val_bind) = $self->_val($value);
    my $sql = sprintf 'WHEN %s THEN %s', $when_cond_sql, $val_sql;

    push @{ $self->{sql}  } => $sql;
    push @{ $self->{bind} } => @bind, @$val_bind;

    return $self;
}

sub else {
    my ($self, $value) = @_;

    my ($val_sql, $val_bind) = $self->_val($value);
    $self->{else} = +{
        sql  => $val_sql,
        bind => $val_bind,
    };

    return $self;
}

sub _val {
    my ($self, $val) = @_;

    my ($query, @v);
    if (ref $val eq 'SCALAR' ) {
        $query = $$val;
    }
    elsif (ref $val eq 'REF') {
        ($query, @v) = @{ $$val };
    }
    else {
        if (defined $val) {
            $query = '?';
            @v     = $val;
        }
        else {
            $query = 'NULL';
        }
    }

    return ($query, \@v);
}

sub as_sql {
    my ($self) = @_;
    my @sql = @{ $self->{sql} };
    if ($self->{else}) {
        push @sql => "ELSE $self->{else}->{sql}";
    }
    return join ' ', 'CASE', @sql, 'END';
}

sub bind {
    my $self = shift;
    my @bind = @{ $self->{bind} };
    if ($self->{else}) {
        push @bind => @{ $self->{else}->{bind} };
    }
    return wantarray ? @bind : \@bind;
}

1;
__END__

=encoding utf-8

=head1 NAME

SQL::Maker::Case - It's new $module

=head1 SYNOPSIS

    use SQL::Maker::Case;

    my $case = SQL::Maker::Case->new(
        name_sep   => '.',
        quote_char => '`',
    );
    $case->when({ foo => { '>' => 4 } },   3);
    $case->when([ "ABS(foo) > ABS(?)", 5], \"ABS(foo)");
    $case->when({ foo => 1 },              0);
    $case->else(2);

    my $sql  = $case->as_sql;
    my @bind = $case->bind();
    # $sql:  "CASE WHEN foo < ? THEN ? WHEN ABS(foo) = ABS(?) THEN ABS(foo) WHEN foo = ? THEN ? ELSE ? END"
    # @bind: (4, 3, 5, 1, 0, 2)

=head1 DESCRIPTION

SQL::Maker::Case is ...

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

