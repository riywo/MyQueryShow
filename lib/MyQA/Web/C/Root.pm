package MyQA::Web::C::Root;
use strict;
use warnings;

sub index {
    my ($class, $c) = @_;
    $c->render("index.tt");
}

sub test {
    my ($class, $c) = @_;

    my $dbh = $c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
    select r.checksum,sum(ts_cnt) num, sum(Query_time_sum*1000) time, avg(Query_time_sum*1000/ts_cnt) ave, avg(Query_time_pct_95*1000) pct, fingerprint
    from query_review r,query_review_history h where r.checksum = h.checksum
    group by checksum order by time desc limit 5
    ", { Columns => {} });

    foreach my $row (@{$rows}){
        $row->{$_} = sprintf("%-.2f", $row->{$_}) foreach (qw/time ave pct/);
    }

    $c->render("test.tt", { rows => $rows });
}

1;
