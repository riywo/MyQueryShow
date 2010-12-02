package MyQueryShow::M::Query;
use strict;
use warnings;
use Amon2::Declare;
use DateTime::Format::HTTP;
use Data::Dumper;

sub get_queries {
    my ($self, $date) = @_;

    my $end = $date->clone->add(seconds => 60);

    my $dbh = c->db->dbh;
    my $queries = $dbh->selectall_arrayref("
select r.checksum, r.fingerprint, r.sample
from query_review r, query_review_history h where r.checksum = h.checksum and ts_min >= ? and ts_min < ?
group by checksum
    ", { Columns => {} }, $date, $end);

    return $queries;
}

sub get_query_time {
    my ($self, $query, $date) = @_;

    my $end = $date->clone->add(seconds => 60);

    my $dbh = c->db->dbh;
    my $query_times = $dbh->selectall_arrayref("
select checksum, ts_cnt count, query_time_sum*1000 sum_time, 
query_time_min*1000 min_time, query_time_max*1000 max_time, query_time_pct_95*1000 pct95_time 
from query_review_history where checksum = ? and ts_min >= ? and ts_min < ?
    ", { Columns => {} }, $query->{'checksum'}, $date, $end);

    return $query_times->[0];
}

sub get_query_list_with_time {
    my ($self, $start_dt, $end_dt) = @_;

    my $sec_diff = ($end_dt->epoch - $start_dt->epoch)/60 * c->config->{'tcpdump'}->{'time_span'};

    my $dbh = c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
select r.checksum, sum(ts_cnt)/$sec_diff qps, sum(Query_time_sum*1000) all_time, sum(ts_cnt) count, sum(Query_time_sum*1000)/sum(ts_cnt) avg_time, avg(Query_time_pct_95*1000) pct95_time, fingerprint
from query_review r, query_review_history h where r.checksum = h.checksum and ts_min >= ? and ts_min < ?
group by checksum
    ", { Columns => {} }, $start_dt, $end_dt);

    return $rows;
}

sub get_query_detail {
    my ($self, $checksum, $start_dt, $end_dt) = @_;
    my $time_span = c->config->{'tcpdump'}->{'time_span'};

    my $dbh = c->db->dbh;
    my $rows = $dbh->selectall_arrayref("
select date_format(ts_min,'%Y-%m-%d %H:%i') time, ts_cnt/$time_span qps, Query_time_min*1000 min_time, Query_time_sum/ts_cnt*1000 avg_time, Query_time_pct_95*1000 pct95_time, Query_time_max*1000 max_time from query_review_history
where checksum = ? and ts_min >= ? and ts_min < ? order by ts_min;
    ", { Columns => {} }, $checksum, $start_dt, $end_dt); 

    return $rows;
}


1;
