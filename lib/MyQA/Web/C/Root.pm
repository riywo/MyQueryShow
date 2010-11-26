package MyQA::Web::C::Root;
use strict;
use warnings;

sub index {
    my ($class, $c) = @_;

    my $msg = '';

    my $start_date = '2010-11-23 00:00:00';
    my $end_date = '2010-11-26 00:00:00';
#    my $time_diff = $end_date - $start_date; #こんな感じ

    my $order_by = 'count';
#    my $order_by = 'alltime';

    my $dbh = $c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
select r.checksum, avg(ts_cnt) count, avg(Query_time_sum*1000) alltime, avg(Query_time_sum/ts_cnt*1000) avg_time, avg(Query_time_pct_95*1000) pct95_time, fingerprint
from query_review r, query_review_history h where r.checksum = h.checksum and ts_min >= ? and ts_min < ?
group by checksum
    ", { Columns => {} }, $start_date, $end_date);

    my $query_list;
    my $count_sum = 0;
    my $time_sum = 0;
    if(!$rows){
        $msg = "rows not found on '$start_date' to '$end_date'";
    }else{
        my $rank = 0;
        foreach my $row ( sort { $b->{$order_by} <=> $a->{$order_by} } @{$rows} ){
            $count_sum += $row->{'count'};
            $time_sum += $row->{'alltime'};
            $rank ++;

            $row->{'rank'} = $rank;
            map { $row->{$_} = sprintf("%-.2f", $row->{$_}) } qw/count alltime avg_time pct95_time/;
            push @{$query_list}, $row;
        }
    }

    $c->render("index.tt", { 
        query_list => $query_list,
        count_sum => $count_sum,
        time_sum => $time_sum,
        order_by => $order_by,
        msg => $msg,
    });
}

sub test {
    my ($class, $c) = @_;

    my $dbh = $c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
    select r.checksum,sum(ts_cnt) num, sum(Query_time_sum*1000) time, avg(Query_time_sum*1000/ts_cnt) ave, avg(Query_time_pct_95*1000) pct, r.sample fingerprint
    from query_review r,query_review_history h where r.checksum = h.checksum
    group by checksum order by time desc limit 5
    ", { Columns => {} });

    foreach my $row (@{$rows}){
        $row->{$_} = sprintf("%-.2f", $row->{$_}) foreach (qw/time ave pct/);
    }

    $c->render("test.tt", { rows => $rows });
}

1;
