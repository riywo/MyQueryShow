package MyQueryShow::M::Query;
use strict;
use warnings;
use Amon2::Declare;
use DateTime;
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

1;

