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
};
