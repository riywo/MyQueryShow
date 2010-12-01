use strict;
use warnings;
use MyQueryShow;
use MyQueryShow::M::RRD;
use MyQueryShow::M::Query;
use DateTime::Format::HTTP;
use Data::Dumper;

my $c = MyQueryShow->bootstrap;

my $dbh = $c->db->dbh;

my $sth = $dbh->prepare("
select distinct checksum from query_review
");
$sth->execute;

while(my $ref = $sth->fetchrow_arrayref){
    my ($checksum) = @{$ref};
print "$checksum\n";

    my $rows = $dbh->selectall_arrayref("
select date_format(ts_min,'%Y-%m-%d %H:%i:00') ts_min, ts_cnt count, query_time_sum*1000 sum_time, query_time_min*1000 min_time, query_time_max*1000 max_time, query_time_pct_95*1000 pct95_time
from query_review_history where checksum = ? order by ts_min
    ", { Columns => {} }, $checksum);

    my $start = DateTime::Format::HTTP->parse_datetime($rows->[0]->{'ts_min'}, $c->tz);
    my $ret = MyQueryShow::M::RRD->create_rrd($checksum, $start->epoch);
    print $ret if($ret ne 0);

    foreach my $row (@{$rows}){
        my $date = DateTime::Format::HTTP->parse_datetime($row->{'ts_min'});
        $ret = MyQueryShow::M::RRD->update_rrd($checksum, $date->epoch, $row);
        print $ret if($ret ne 0);
print "$date\n";
    }
}

