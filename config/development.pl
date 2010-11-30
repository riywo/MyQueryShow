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
    'list' => {
        'default_timespan' => {
            hours => 24,
        },
        'order_colmuns' => [ qw/count all_time avg_time pct95_time/ ],
        'default_order' => 'all_time',
    },
    'detail' => {
        'default_timespan' => {
            days => 1,
        },
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
        IMG_PATH => 'htdocs/rrd', #/MyQueryShow/htdocs/rrd
        IMG => {
            count => {
                DEF => { count => 'MAX' },
            },
        },
    },
};
