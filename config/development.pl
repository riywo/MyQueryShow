use Cwd 'abs_path';

+{
    'DB' => {
            'dsn' => 'dbi:mysql:database=test:host=localhost',
            username => 'test',
            password => '',
    },
    'Text::Xslate' => {
        path => ['tmpl/'],
    },
    'Log::Dispatch' => {
        outputs => [
            ['Screen',
            min_level => 'debug',
            stderr => 1,
            newline => 1],
        ],
    },
    'tcpdump' => {
        'time_span' => 30,
    },
    'list' => {
        'default_timespan' => { hours => 24 },
        'order_colmuns' => [ qw/qps all_time avg_time pct95_time/ ],
        'default_order' => 'all_time',
        'limit' => 20,
        'rrd_size' => { height => 40, width => 250 },
    },
    'detail' => {
        'default_timespan' => { days => 1 },
    },
    'RRD' => {
        step => 60,
        DS => {
            count => 'GAUGE:300:0:U',
            sum_time => 'GAUGE:300:0:U',
            min_time => 'GAUGE:300:0:U',
            max_time => 'GAUGE:300:0:U',
            pct95_time => 'GAUGE:300:0:U',
        },
        RRA => {
            AVERAGE => [ qw(dayly weekly monthly yearly) ],
            MAX => [ qw(dayly weekly monthly yearly) ],
        },
        RRA_RANGE => {
            dayly => '0.5:1:1440',
            weekly => '0.5:10:1008',
            monthly => '0.5:30:1488',
            yearly => '0.5:360:1460',
        },
        RRD_PATH => 'rrd', # /MyQueryShow/rrd
        IMG_PATH => 'static/img/rrd', #/MyQueryShow/htdocs/static/img/rrd
        IMG => {
            mini_qps => {
                DEF => { count => 'MAX' },
                CDEF => [ qw(qps=count,30,/) ],
                OPTION => {
                    'no-legend' => '',
                },
                DROW => [ qw(qps) ],
                DROWDETAIL => {
                    qps => {
                        AREA => '#00CF00:qps',
                    },
                },
            },
            mini_pct => {
                DEF => { pct95_time => 'MAX' },
                OPTION => {
                    'no-legend' => '',
                },
                DROW => [ qw(pct95_time) ],
                DROWDETAIL => {
                    pct95_time => {
                        LINE => '#FFD700:95%',
                    },
                },
            },
            qps => {
                DEF => { count => 'MAX' },
                CDEF => [ qw(qps=count,30,/) ],
                OPTION => {
                    title => 'query count',
                    'vertical-label' => 'qps',
                },
                DROW => [ qw(qps) ],
                DROWDETAIL => {
                    qps => {
                        AREA => '#00CF00:qps',
                        LINE => '#CF0000',
                        GPRINT => '%7.3lf',
                    },
                }
            },
            querytime => {
                DEF => { 
                    count => 'MAX',
                    sum_time => 'MAX',
                    min_time => 'MAX',
                    max_time => 'MAX',
                    pct95_time => 'MAX',
                },
                CDEF => [ qw(avg_time=sum_time,count,/) ],
                OPTION => { 
                    title => 'query time',
                    'vertical-label' => 'msec',
                },
                DROW => [ qw(min_time avg_time pct95_time max_time) ],
                DROWDETAIL => {
                    min_time => {
                      LINE => '#00BBFF:min',
                      GPRINT => '%7.3lf',  
                    },
                    avg_time => {
                      LINE => '#32CD32:avg',
                      GPRINT => '%7.3lf',  
                    },
                    pct95_time => {
                      LINE => '#FFD700:95%',
                      GPRINT => '%7.3lf',  
                    },
#                    max_time => {
#                      LINE => '#FF0000:max',
#                      GPRINT => '%7.3lf',  
#                    },
                },
            },
        },
    },
};
