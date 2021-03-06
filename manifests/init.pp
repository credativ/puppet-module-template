# = Class: __module__
#
# Module to manage __module__
#
# == Requirements:
#
# - This module makes use of the example42 functions in the puppi module
#   (https://github.com/credativ/puppet-example42lib)
#
# == Parameters:
#
# [* ensure *]
#   What state to ensure for the package. Accepts the same values
#   as the parameter of the same name for a package type.
#   Default: present
#   
# [* ensure_running *]
#   Weither to ensure running __module__ or not.
#   Default: running
#
# [* ensure_enabled *]
#   Weither to ensure that __module__ is started on boot or not.
#   Default: true
#
# [* config_source *]
#   Specify a configuration source for the configuration. If this
#   is specified it is used instead of a template-generated configuration
#
# [* config_template *]
#   Override the default choice for the configuration template
#
# [* disabled_hosts *]
#   A list of hosts whose __module__ will be disabled, if their
#   hostname matches a name in the list.
#

class __module__ (
    $ensure             = params_lookup('ensure'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
    $manage_config      = params_lookup('manage_config'),
    $config_file        = params_lookup('config_file'),
    $config_source      = params_lookup('config_source'),
    $config_template    = params_lookup('config_template'),
    $disabled_hosts     = params_lookup('disabled_hosts'),
    ) inherits __module__::params {

    package { '__module__':
        ensure => $ensure
    }

    service { '__module__':
        ensure      => $ensure_running,
        enable      => $ensure_enabled,
        hasrestart  => true,
        hasstatus   => true,
        require     => Package['__module__']
    }

    file { $config_file:
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        tag     => '__module___config',
        notify  => Service['__module__']
    }

    # Disable service on this host, if hostname is in disabled_hosts
    if $::hostname in $disabled_hosts {
        Service <| title == '__module__' |> {
            ensure  => 'stopped',
            enabled => false,
        }
    }

    if $config_source {
        File <| tag == '__module___config' |> {
            source  => $config_source
        }
    } elsif $config_template {
        File <| tag == '__module___config' |> {
            content => $config_template
        }
    }
}

