use 5.036;
use Module::Build;
Module::Build->VERSION('0.4004');

my $builder = Module::Build->new(
    module_name         => 'Seq',
    license             => 'mit',
    dist_author         => q{David Raab <davidraab83@gmail.com>},
    dist_version_from   => 'lib/Seq.pm',
    release_status      => 'unstable',
    configure_requires => {
        'Module::Build' => '0.4004',
    },
    test_requires => {
        'Test2::Suite' => '0',
    },
    requires => {
        #'ABC'              => '1.6',
        #'Foo::Bar::Module' => '5.0401',
    },
    add_to_cleanup     => [ 'Seq-*' ],
);

$builder->create_build_script();