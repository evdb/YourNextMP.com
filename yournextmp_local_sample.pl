{

    'Model::DB' => {
        connect_info => {

            # "dbi:Pg:dbname=$dbname;host=$host;port=$port;options=$options",
            dsn      => 'dbi:Pg:dbname=yournextmp_dev',
            user     => '',
            password => '',

            # Database options
            pg_enable_utf8 => 1,
            AutoCommit     => 1,

        },
    },

    # Leave this is for testing
    local_test_key => 'local_test_value',

};

