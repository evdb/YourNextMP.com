{

    email => {
        from        => 'hello@yournextmp.com',
        mailer_args => [
            username => 'foo@gmail.com',
            password => 'XXX',
        ]
    },

    # where should the files be stored? ('local' or 's3')
    file_store => 's3',

    # if there is a Google analytics key here then the analytics gets loaded
    google_analytics_code => '',
    show_google_ads => 1,

    javascript_source => 'local',

    # should we display the warning banner?
    show_dev_warning => 1,

    'Plugin::Cache' =>
      { backend => { namespace => die('choose a namespace'), } },

    aws => {
        aws_access_key_id     => die('need aws_access_key_id'),
        aws_secret_access_key => die('need aws_secret_access_key'),
        public_bucket_name    => 'yournextmp-dev',
        private_bucket_name   => 'yournextmp-private-dev',
    },

    pageglimpse_api_key => die('need pageglimpse api key'),

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

    democracy_club => {    #
        login_secret => die('set the login signature'),
    },

    # Leave this for testing
    local_test_key => 'local_test_value',

};

