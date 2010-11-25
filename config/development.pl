+{

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
