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
    my ($self, $checksum, $type, $height, $width, $start, $opt) = @_;
    my $conf = c->config->{'RRD'};

    my $img_path = c->base_dir."/htdocs/$conf->{'IMG_PATH'}";
    my ($img_file, @options1, @options2);
    push @options1, "--imgformat=PNG";
    push @options1, "--start=$start";
    push @options1, "--end=$opt->{'end'}" if($opt->{'end'});
    push @options1, "--height=$height";
    push @options1, "--width=$width";

    eval{
        ($img_file, @options2) = _make_graph_options($checksum, $type);
    };
    if($@){
        return $@;
    }
print join("\n", (@options1, @options2))."\n";
    my (undef, $width, $height) = RRDs::graph("$img_path/$img_file", @options1, @options2);
    if(my $ERR = RRDs::error){
        return $ERR;
    }

    return ($img_file, $width, $height);
}
	
sub _make_graph_options {
    my ($checksum, $type) = @_;
    my $conf = c->config->{'RRD'};

    die "no type: $type" unless($conf->{'IMG'}->{$type});
    my $img_conf = $conf->{'IMG'}->{$type};

    my $rrd_path = c->base_dir."/$conf->{'RRD_PATH'}/$checksum";
    my ($img_file, @options);
    $img_file = "$checksum-$type.png";

#    push @options, "--title=$img_conf->{'LABEL'}->{'title'}" if($img_conf->{'LABEL'}->{'title'});
#    push @options, "--vertical-label=$img_conf->{'LABEL'}->{'label'}" if($img_conf->{'LABEL'}->{'label'});

    while (my ($opt, $value) = each %{$img_conf->{'OPTION'}}){
        if($value eq ''){
            push @options, "--$opt";
        }else{
            push @options, "--$opt=$value";
        }
    }

    for my $def (keys(%{$img_conf->{'DEF'}})){
        push @options, "DEF:$def=$rrd_path/$checksum-$def.rrd:$def:$img_conf->{'DEF'}->{$def}";
    }
    for my $cdef (@{$img_conf->{'CDEF'}}){
        push @options, "CDEF:$cdef";
    }

    for my $drow (@{$img_conf->{'DROW'}}){
        my $detail = $img_conf->{'DROWDETAIL'}->{$drow};
        if($detail->{'AREA'}){
            push @options, "AREA:${drow}$detail->{'AREA'}";
        }
        if($detail->{'LINE'}){
            push @options, "LINE:${drow}$detail->{'LINE'}";
        }
        if($detail->{'GPRINT'}){
            my $format = $detail->{'GPRINT'};
            push @options, "GPRINT:$drow:LAST:cur\\:$format";
            push @options, "GPRINT:$drow:AVERAGE:avg\\:$format";
            push @options, "GPRINT:$drow:MAX:max\\:$format\\n";
        }
    }

    return ($img_file, @options);
}

1;

