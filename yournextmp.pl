{
    name => 'YourNextMP',

    general_email_address => 'hello@yournextmp.com',

    # use 'local' to serve from '/root/js', or 'cdn' for Google etc CDN
    javascript_source => 'cdn',

    'Plugin::Cache' => {
        backend => {
            class   => "Cache::Memcached::libmemcached",
            servers => ['127.0.0.1:11211'],
            namespace => 'default:',
        },
    },

    'Plugin::Session' => {
        dbic_class   => 'DB::Session',
        expires      => 3600 * 24 * 365,    # 1 year
        max_lifetime => 3600 * 24 * 2,      # 2 days
        min_lifetime => 3600 * 24 * 1,      # 1 day
    },

    authentication => {
        realm => {
            auto_create_user => 1,
            auto_update_user => 1,
        },
        default_realm => 'default',
        realms        => {
            default => {
                credential => {             #
                    class         => 'Password',
                    password_type => 'none',
                },
                store => {
                    class       => 'DBIx::Class',
                    user_model  => 'DB::User',
                    role_column => 'roles',
                }
            },
            openid => {
                credential => {
                    debug => $ENV{CATALYST_DEBUG} || 0,
                    class => 'OpenIDPatched',
                    trust_root_path => '/',

                    # extensions => [
                    #     'http://openid.net/srv/ax/1.0' => {
                    #         required => 'email',
                    #         mode     => 'fetch_request',
                    #         'type.email' =>
                    #           'http://schema.openid.net/contact/email',
                    #     },
                    # ],
                },
                store => { class => 'Null', },
            },
        }
    },

    # Leave this is for testing
    general_test_key => 'general_test_value',
};
