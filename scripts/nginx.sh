app_protect_enable on; # This is how you enable NGINX App Protect WAF in the relevant context/block
app_protect_policy_file "/etc/app_protect/conf/NginxDefaultPolicy.json"; # This is a reference to the policy file to use. If not defined, the default policy is used
app_protect_security_log_enable on; # This section enables the logging capability
app_protect_security_log "/etc/app_protect/conf/log_default.json" syslog:server=127.0.0.1:515; # This is where the remote logger is defined in terms of: logging options (defined in the referenced file), log server IP, log server port