<?php

return [
    'default' => 'json',

    'connections' => [
        'json' => [
            'driver' => 'json',
            'options' => [
                'json_encode_options' => JSON_UNESCAPED_UNICODE,
                'wrap' => false,
            ],
        ],
    ],
];