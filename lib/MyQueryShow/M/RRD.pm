package MyQueryShow::M::RRD;
use strict;
use warnings;
use Amon2::Declare;
use RRDs;
use Data::Dumper;

sub create_rrd {
    my ($self, $checksum, $start) = @_;
    my $conf = c->config->{'RRD'};

    $start = DateTime->now(time_zone => c->tz) unless($start);
    $start --;

    my $rrd_path = c->base_dir."/$conf->{'RRD_PATH'}/$checksum";
    mkdir $rrd_path unless(-d $rrd_path);

    my @rra_options = ();
    for my $rra (sort keys(%{$conf->{'RRA'}})){
        for my $rra_range (@{$conf->{'RRA'}->{$rra}}){
            push @rra_options, "RRA:$rra:".$conf->{'RRA_RANGE'}->{$rra_range};
        }
    }

    my $err = '';
    for my $ds (keys(%{$conf->{'DS'}})){
        my $rrd_file = "$rrd_path/$checksum-$ds.rrd";
        next if(-e $rrd_file);
        my @options = ();
        push @options, ('--start', $start);
        push @options, ('--step', $conf->{'step'});
        push @options, "DS:$ds:".$conf->{'DS'}->{$ds};
        push @options, @rra_options;

        RRDs::create($rrd_file, @options);
        if(my $ERR = RRDs::error){
            $err .= $ERR."\n";
        }
    }

    if($err){
        return $err;
    }else{
        return 0;
    }
}

sub update_rrd {
    my ($self, $checksum, $time, $data) = @_;
    my $conf = c->config->{'RRD'};

    my $rrd_path = c->base_dir."/$conf->{'RRD_PATH'}/$checksum";

    my $err = '';
    for my $ds (keys(%{$conf->{'DS'}})){
        unless($data->{$ds}){
            $err .= "no data for $ds\n";
            next;
        }

        my $rrd_file = "$rrd_path/$checksum-$ds.rrd";
        my $option = "$time:$data->{$ds}";
        RRDs::update($rrd_file, $option);
        if(my $ERR = RRDs::error){
            $err .= $ERR."\n";
        }
    }

    if($err){
        return $err;
    }else{
        return 0;
    }
}

sub make_graph {
    my ($self, $checksum, $start, $end, $type) = @_;
    my $conf = c->config->{'RRD'};

    my $img_path = c->base_dir."/$conf->{'IMG_PATH'}";
    my ($img_file, @options);
    eval{
        ($img_file, @options) = _make_graph_options($checksum, $type);
    };
    if($@){
        return $@;
    }

    RRDs::graph("$img_path/$img_file",
        "--imgformat=PNG",
        "--start=$start",
        "--end=$end",
        "--height=120",
        "--width=500",
        @options);
    if(my $ERR = RRDs::error){
        return $ERR;
    }

    return $img_file;
}
	
sub _make_graph_options {
    my ($checksum, $type) = @_;
    my $conf = c->config->{'RRD'};

    die "no type: $type" unless($conf->{'IMG'}->{$type});
    my $img_conf = $conf->{'IMG'}->{$type};

    my $rrd_path = c->base_dir."/$conf->{'RRD_PATH'}/$checksum";
    my ($img_file, @options);
    $img_file = "$checksum-$type.png";

    for my $def (keys(%{$img_conf->{'DEF'}})){
        push @options, "DEF:$def=$rrd_path/$checksum-$def.rrd:$def:$img_conf->{'DEF'}->{$def}";
    }

    push @options, "AREA:count#00CF00:COUNT";

    return ($img_file, @options);
}

1;

