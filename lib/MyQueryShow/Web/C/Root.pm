package MyQueryShow::Web::C::Root;
use strict;
use warnings;
use MyQueryShow::M::RRD;
use MyQueryShow::M::Query;
use DateTime::Format::HTTP;
use DateTime::Format::MySQL;

#sub index {
#    my ($class, $c) = @_;
#    
#    $c->render("index.tt");
#}

sub list {
    my ($class, $c) = @_;
    my $msg = '';
    my $conf = $c->config->{'list'};

    my $start_date = $c->req->param('start');
    my $end_date = $c->req->param('end');

    my $start_dt = $start_date ? DateTime::Format::HTTP->parse_datetime($start_date, $c->tz)
        : DateTime->now( time_zone => $c->tz)->subtract(%{$conf->{'default_timespan'}});
    my $end_dt = $end_date ? DateTime::Format::HTTP->parse_datetime($end_date, $c->tz)
        : DateTime->now(time_zone => $c->tz);
    my $order_by = $c->req->param('order') || $conf->{'default_order'};

    my $rows = MyQueryShow::M::Query->get_query_list_with_time($start_dt, $end_dt);

    my $query_list;
    my ($count_sum, $time_sum) = (0, 0);
    my ($rrd_height, $rrd_width) = ($conf->{'rrd_size'}->{'height'}, $conf->{'rrd_size'}->{'width'});
    if($#{$rows} <= 1){
        $msg = "rows not found on '$start_dt' to '$end_dt'";
    }else{
        my $rank = 0;
        my $opt = { end => $end_dt->epoch };
        foreach my $row ( sort { $b->{$order_by} <=> $a->{$order_by} } @{$rows} ){
            $rank ++;
            $count_sum += $row->{'count'};
            $time_sum += $row->{'all_time'};

            next if($rank > $conf->{'limit'});
            $row->{'rank'} = $rank;

            my ($qps_rrd, $qps_width, $qps_height) = MyQueryShow::M::RRD->make_graph($row->{'checksum'}, 'mini_qps', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
            $row->{'qps_rrd'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$qps_rrd";
            $row->{'qps_rrd_width'} = $qps_width;
            $row->{'qps_rrd_height'} = $qps_height;

            my ($avg_rrd, $avg_width, $avg_height) = MyQueryShow::M::RRD->make_graph($row->{'checksum'}, 'mini_avg', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
            $row->{'avg_rrd'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$avg_rrd";
            $row->{'avg_rrd_width'} = $avg_width;
            $row->{'avg_rrd_height'} = $avg_height;

            my ($pct_rrd, $pct_width, $pct_height) = MyQueryShow::M::RRD->make_graph($row->{'checksum'}, 'mini_pct', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
            $row->{'pct_rrd'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$pct_rrd";
            $row->{'pct_rrd_width'} = $pct_width;
            $row->{'pct_rrd_height'} = $pct_height;

            push @{$query_list}, $row;
        }
    }

    $c->render("list.tt", { 
        query_list => $query_list,
        count_sum => $count_sum,
        time_sum => $time_sum,
        order_column => $c->config->{'list'}->{'order_colmuns'},
        order_by => $order_by,
        start_date => DateTime::Format::MySQL->format_datetime($start_dt),
        end_date => DateTime::Format::MySQL->format_datetime($end_dt),
        msg => $msg,
    });
}

sub detail {
    my ($class, $c, $args) = @_;
    my $msg = '';
    my $conf = $c->config->{'detail'};

    my $checksum = $args->{checksum};
    my $start_date = $c->req->param('start');
    my $end_date = $c->req->param('end');

    my $start_dt = $start_date ? DateTime::Format::HTTP->parse_datetime($start_date, $c->tz)
        : DateTime->now(time_zone => $c->tz)->subtract(%{$conf->{'default_timespan'}});
    my $end_dt = $end_date ? DateTime::Format::HTTP->parse_datetime($end_date, $c->tz)
        : DateTime->now(time_zone => $c->tz);

    my $dbh = $c->db->dbh;
    my $fingerprint = shift @{shift @{$dbh->selectall_arrayref("select fingerprint from query_review where checksum = ?", {}, $checksum)}};

    my ($rrd_height, $rrd_width) = ($conf->{'rrd_size'}->{'height'}, $conf->{'rrd_size'}->{'width'});
    my $opt = { end => $end_dt->epoch };
    my $rrd;
    my ($rrd_qps, $rrd_qps_width, $rrd_qps_height) = MyQueryShow::M::RRD->make_graph($checksum, 'qps', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
    $rrd->{'qps'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$rrd_qps";
    $rrd->{'qps_width'} = $rrd_qps_width;
    $rrd->{'qps_height'} = $rrd_qps_height;
    my ($rrd_min, $rrd_min_width, $rrd_min_height) = MyQueryShow::M::RRD->make_graph($checksum, 'min', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
    $rrd->{'min'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$rrd_min";
    $rrd->{'min_width'} = $rrd_min_width;
    $rrd->{'min_height'} = $rrd_min_height;
    my ($rrd_avg, $rrd_avg_width, $rrd_avg_height) = MyQueryShow::M::RRD->make_graph($checksum, 'avg', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
    $rrd->{'avg'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$rrd_avg";
    $rrd->{'avg_width'} = $rrd_avg_width;
    $rrd->{'avg_height'} = $rrd_avg_height;
    my ($rrd_pct95, $rrd_pct95_width, $rrd_pct95_height) = MyQueryShow::M::RRD->make_graph($checksum, 'pct95', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
    $rrd->{'pct95'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$rrd_pct95";
    $rrd->{'pct95_width'} = $rrd_pct95_width;
    $rrd->{'pct95_height'} = $rrd_pct95_height;
    my ($rrd_max, $rrd_max_width, $rrd_max_height) = MyQueryShow::M::RRD->make_graph($checksum, 'max', $rrd_height, $rrd_width, $start_dt->epoch, $opt);
    $rrd->{'max'} = $c->config->{'RRD'}->{'IMG_PATH'}."/$rrd_max";
    $rrd->{'max_width'} = $rrd_max_width;
    $rrd->{'max_height'} = $rrd_max_height;


    my $rows = MyQueryShow::M::Query->get_query_detail($checksum, $start_dt, $end_dt);

    if($#{$rows} < 0){
        $msg = "data not found on '$start_dt' to '$end_dt'";
    }

    $c->render("detail.tt", { 
        fingerprint => $fingerprint,
        rrd => $rrd,
        rows => $rows,
        start_date => DateTime::Format::MySQL->format_datetime($start_dt),
        end_date => DateTime::Format::MySQL->format_datetime($end_dt),
        msg => $msg,
    });
}


=pod 

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

=cut

1;
