# NAME

SQL::Maker::Plugin::Case - It's new $module

# SYNOPSIS

    use SQL::Maker;
    SQL::Maker->load_plugin('Case');

    my $maker  = SQL::Maker->new(driver => 'mysql');
    my $select = $maker->new_select();
    my $cond   = $maker->new_condition();
    my $case   = $maker->new_case();
    $case->when({ bar => 1 }, 3)
         ->when({ bar => 2 }, 0)
         ->when({ bar => 3 }, 2);
    $cond->add(foo => [$case->as_sql, $case->bind]);
         ->add(baz => 1);

    $select->add_select('*')
           ->add_from('hoge')
           ->set_where($cond);

    my $sql  = $select->as_sql;
    my @bind = $select->bind;
    # sql:  "SELECT * FROM hoge WHERE foo CASE WHEN bar = ? THEN ? WHEN bar = ? THEN ? WHEN bar = ? THEN ? END AND baz = ?"
    # bind: (1, 3, 2, 0, 3, 2, 1)

# DESCRIPTION

SQL::Maker::Plugin::Case is ...

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
