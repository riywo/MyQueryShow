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
};
