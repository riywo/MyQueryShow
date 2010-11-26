package MyQueryShow::Web::C::Root;
use strict;
use warnings;
use DateTime::Format::HTTP;

sub index {
    my ($class, $c) = @_;
    
    $c->render("index.tt");
}

sub queryList {
    my ($class, $c) = @_;

    my $msg = '';

    my $start_date = $c->req->param('start');
    my $end_date = $c->req->param('end');

    my $start_dt = $start_date ? DateTime::Format::HTTP->parse_datetime($start_date) : DateTime->n;
    my $end_dt = DateTime::Format::HTTP->parse_datetime($end_date);
    my $order_by = $c->req->param('order') || 'all_time';

#    my $time_diff = $end_date - $start_date; #こんな感じ

    my $dbh = $c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
select r.checksum, avg(ts_cnt) count, avg(Query_time_sum*1000) all_time, avg(Query_time_sum/ts_cnt*1000) avg_time, avg(Query_time_pct_95*1000) pct95_time, fingerprint
from query_review r, query_review_history h where r.checksum = h.checksum and ts_min >= ? and ts_min < ?
group by checksum
    ", { Columns => {} }, $start_dt, $end_dt);

    my $query_list;
    my $count_sum = 0;
    my $time_sum = 0;
    if($#{$rows} <= 1){
        $msg = "rows not found on '$start_date' to '$end_date'";
    }else{
        my $rank = 0;
        foreach my $row ( sort { $b->{$order_by} <=> $a->{$order_by} } @{$rows} ){
            $count_sum += $row->{'count'};
            $time_sum += $row->{'all_time'};
            $rank ++;

            $row->{'rank'} = $rank;
            push @{$query_list}, $row;
        }
    }

    $c->render("q_list.tt", { 
        query_list => $query_list,
        count_sum => $count_sum,
        time_sum => $time_sum,
        order_by => $order_by,
        start_date => $start_date,
        end_date => $end_date,
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
