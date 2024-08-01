# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`cron`](#cron): This class wraps *cron::install* for ease of use
* [`cron::install`](#cron--install): This class ensures that the distro-appropriate cron package is installed. This class should not be used directly under normal circumstances. Instead, use the *cron* class.
* [`cron::service`](#cron--service): This class managed the cron service. This class should not be used directly under normal circumstances. Instead, use the *cron* class.

### Defined types

* [`cron::daily`](#cron--daily): This type creates a daily cron job via a file in /etc/cron.d
* [`cron::hourly`](#cron--hourly): This type creates an hourly cron job via a file in /etc/cron.d
* [`cron::job`](#cron--job): This type creates a cron job via a file in /etc/cron.d
* [`cron::job::multiple`](#cron--job--multiple): This type creates multiple cron jobs via a single file in /etc/cron.d/
* [`cron::monthly`](#cron--monthly): This type creates a monthly cron job via a file in /etc/cron.d
* [`cron::weekly`](#cron--weekly): This type creates a cron job via a file in /etc/cron.d

### Data types

* [`Cron::Date`](#Cron--Date): Valid $date (day of month) parameter to Cron::Job.
* [`Cron::Deb_version`](#Cron--Deb_version): Valid .deb version string. See https://www.debian.org/doc/debian-policy/#s-f-version
* [`Cron::Environment`](#Cron--Environment): Valid $environment parameter to Cron::Job.
* [`Cron::Hour`](#Cron--Hour): Valid $hour parameter to Cron::Job.
* [`Cron::Job_ensure`](#Cron--Job_ensure): Valid $ensure parameter to Cron::Job.
* [`Cron::Jobname`](#Cron--Jobname): Valid $title parameter to Cron::Job. This is the name of the /etc/cron.d/ file. The Ubuntu run-parts manpage specifies (^[a-zA-Z0-9_-]+$). Fo
* [`Cron::Minute`](#Cron--Minute): Valid $minute parameter to Cron::Job.
* [`Cron::Month`](#Cron--Month): Valid $month parameter to Cron::Job.
* [`Cron::Monthname`](#Cron--Monthname): Short-names for each month.
* [`Cron::Package_ensure`](#Cron--Package_ensure): Valid $service_ensure parameter to Cron.
* [`Cron::Package_state`](#Cron--Package_state): Valid $ensure parameter to Package resource. Excludes version numbers.
* [`Cron::Rpm_version`](#Cron--Rpm_version): Valid .rpm version string. See http://www.perlmonks.org/?node_id=237724
* [`Cron::Run_parts`](#Cron--Run_parts): Valid element of $crontab_run_parts parameter to Class['cron'].
* [`Cron::Second`](#Cron--Second): Valid $second parameter to Cron::Job.
* [`Cron::Service_Enable`](#Cron--Service_Enable): Valid $service_enable parameter to Cron.
* [`Cron::Service_ensure`](#Cron--Service_ensure): Valid $service_ensure parameter to Cron.
* [`Cron::Special`](#Cron--Special): Valid $special parameter to Cron::Job.
* [`Cron::User`](#Cron--User): Valid $user parameter to Cron::Job.
* [`Cron::Weekday`](#Cron--Weekday): Valid $weekday parameter to Cron::Job.
* [`Cron::Weekdayname`](#Cron--Weekdayname): Short names for each day of the week.

## Classes

### <a name="cron"></a>`cron`

This class wraps *cron::install* for ease of use

#### Examples

##### simply include the module

```puppet
include cron
```

##### include it but don't manage the cron package

```puppet
class { 'cron':
  manage_package => false,
}
```

#### Parameters

The following parameters are available in the `cron` class:

* [`service_name`](#-cron--service_name)
* [`package_name`](#-cron--package_name)
* [`manage_package`](#-cron--manage_package)
* [`manage_service`](#-cron--manage_service)
* [`service_ensure`](#-cron--service_ensure)
* [`service_enable`](#-cron--service_enable)
* [`users_allow`](#-cron--users_allow)
* [`users_deny`](#-cron--users_deny)
* [`manage_users_allow`](#-cron--manage_users_allow)
* [`manage_users_deny`](#-cron--manage_users_deny)
* [`allow_deny_mode`](#-cron--allow_deny_mode)
* [`merge`](#-cron--merge)
* [`manage_crontab`](#-cron--manage_crontab)
* [`crontab_shell`](#-cron--crontab_shell)
* [`crontab_path`](#-cron--crontab_path)
* [`crontab_mailto`](#-cron--crontab_mailto)
* [`crontab_home`](#-cron--crontab_home)
* [`crontab_run_parts`](#-cron--crontab_run_parts)
* [`file_mode`](#-cron--file_mode)
* [`dir_mode`](#-cron--dir_mode)
* [`package_ensure`](#-cron--package_ensure)

##### <a name="-cron--service_name"></a>`service_name`

Data type: `String[1]`

Can be set to define a different cron service name.

##### <a name="-cron--package_name"></a>`package_name`

Data type: `String[1]`

Can be set to install a different cron package.

##### <a name="-cron--manage_package"></a>`manage_package`

Data type: `Boolean`

Can be set to disable package installation.

Default value: `true`

##### <a name="-cron--manage_service"></a>`manage_service`

Data type: `Boolean`

Defines if puppet should manage the service.

Default value: `true`

##### <a name="-cron--service_ensure"></a>`service_ensure`

Data type: `Cron::Service_ensure`

Defines if the service should be running.

Default value: `'running'`

##### <a name="-cron--service_enable"></a>`service_enable`

Data type: `Cron::Service_enable`

Defines if the service should be enabled at boot.

Default value: `true`

##### <a name="-cron--users_allow"></a>`users_allow`

Data type: `Array[Cron::User]`

A list of users which are exclusively able to create, edit, display, or remove crontab files. Only used if manage_users_allow == true.

Default value: `[]`

##### <a name="-cron--users_deny"></a>`users_deny`

Data type: `Array[Cron::User]`

A list of users which are prohibited from create, edit, display, or remove crontab files. Only used if manage_users_deny == true.

Default value: `[]`

##### <a name="-cron--manage_users_allow"></a>`manage_users_allow`

Data type: `Boolean`

If the /etc/cron.allow should be managed.

Default value: `false`

##### <a name="-cron--manage_users_deny"></a>`manage_users_deny`

Data type: `Boolean`

If the /etc/cron.deny should be managed.

Default value: `false`

##### <a name="-cron--allow_deny_mode"></a>`allow_deny_mode`

Data type: `Stdlib::Filemode`

Specify the cron.allow/deny file mode.

Default value: `'0644'`

##### <a name="-cron--merge"></a>`merge`

Data type: `Enum['deep', 'first', 'hash', 'unique']`

The `lookup()` merge method to use with cron job hiera lookups.

Default value: `'hash'`

##### <a name="-cron--manage_crontab"></a>`manage_crontab`

Data type: `Boolean`

Whether to manage /etc/crontab

Default value: `false`

##### <a name="-cron--crontab_shell"></a>`crontab_shell`

Data type: `Stdlib::Absolutepath`

The value for SHELL in /etc/crontab

Default value: `'/bin/bash'`

##### <a name="-cron--crontab_path"></a>`crontab_path`

Data type: `String[1]`

The value for PATH in /etc/crontab

Default value: `'/sbin:/bin:/usr/sbin:/usr/bin'`

##### <a name="-cron--crontab_mailto"></a>`crontab_mailto`

Data type: `String[1]`

The value for MAILTO in /etc/crontab

Default value: `'root'`

##### <a name="-cron--crontab_home"></a>`crontab_home`

Data type: `Optional[Stdlib::Absolutepath]`

The value for HOME in /etc/crontab

Default value: `undef`

##### <a name="-cron--crontab_run_parts"></a>`crontab_run_parts`

Data type: `Cron::Run_parts`

Define sadditional cron::run_parts resources

Default value: `{}`

##### <a name="-cron--file_mode"></a>`file_mode`

Data type: `Stdlib::Filemode`

The file mode for the system crontab file

Default value: `'0644'`

##### <a name="-cron--dir_mode"></a>`dir_mode`

Data type: `Stdlib::Filemode`

The file mode for the cron directories

Default value: `'0755'`

##### <a name="-cron--package_ensure"></a>`package_ensure`

Data type: `Cron::Package_ensure`



Default value: `'installed'`

### <a name="cron--install"></a>`cron::install`

This class ensures that the distro-appropriate cron package is installed. This class should not be used directly under normal circumstances. Instead, use the *cron* class.

### <a name="cron--service"></a>`cron::service`

This class managed the cron service. This class should not be used directly under normal circumstances. Instead, use the *cron* class.

## Defined types

### <a name="cron--daily"></a>`cron::daily`

This type creates a daily cron job via a file in /etc/cron.d

#### Examples

##### create a daily cron job with custom PATH environment variable

```puppet
cron::daily { 'mysql_backup':
  minute      => '1',
  hour        => '3',
  environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
  command     => 'mysqldump -u root my_db >/backups/my_db.sql',
}
```

#### Parameters

The following parameters are available in the `cron::daily` defined type:

* [`command`](#-cron--daily--command)
* [`ensure`](#-cron--daily--ensure)
* [`minute`](#-cron--daily--minute)
* [`hour`](#-cron--daily--hour)
* [`environment`](#-cron--daily--environment)
* [`user`](#-cron--daily--user)
* [`mode`](#-cron--daily--mode)
* [`description`](#-cron--daily--description)

##### <a name="-cron--daily--command"></a>`command`

Data type: `Optional[String[1]]`

The command to execute.

Default value: `undef`

##### <a name="-cron--daily--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--daily--minute"></a>`minute`

Data type: `Cron::Minute`

The minute the cron job should fire on. Can be any valid cron.

Default value: `0`

##### <a name="-cron--daily--hour"></a>`hour`

Data type: `Cron::Hour`

The hour the cron job should fire on. Can be any valid cron hour value.

Default value: `0`

##### <a name="-cron--daily--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--daily--user"></a>`user`

Data type: `Cron::User`

The user the cron job should be executed as.

Default value: `'root'`

##### <a name="-cron--daily--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

##### <a name="-cron--daily--description"></a>`description`

Data type: `Optional[String]`

Optional short description, which will be included in the cron job file.

Default value: `undef`

### <a name="cron--hourly"></a>`cron::hourly`

This type creates an hourly cron job via a file in /etc/cron.d

#### Examples

##### create a daily cron job with custom PATH environment variable

```puppet
cron::hourly { 'generate_puppetdoc':
  minute      => '1',
  environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
  command     => 'puppet doc >/var/www/puppet_docs.mkd',
}
```

#### Parameters

The following parameters are available in the `cron::hourly` defined type:

* [`command`](#-cron--hourly--command)
* [`ensure`](#-cron--hourly--ensure)
* [`minute`](#-cron--hourly--minute)
* [`environment`](#-cron--hourly--environment)
* [`user`](#-cron--hourly--user)
* [`mode`](#-cron--hourly--mode)
* [`description`](#-cron--hourly--description)

##### <a name="-cron--hourly--command"></a>`command`

Data type: `Optional[String[1]]`

The command to execute.

Default value: `undef`

##### <a name="-cron--hourly--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--hourly--minute"></a>`minute`

Data type: `Cron::Minute`

The minute the cron job should fire on. Can be any valid cron.

Default value: `0`

##### <a name="-cron--hourly--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--hourly--user"></a>`user`

Data type: `Cron::User`

The user the cron job should be executed as.

Default value: `'root'`

##### <a name="-cron--hourly--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

##### <a name="-cron--hourly--description"></a>`description`

Data type: `Optional[String]`

Optional short description, which will be included in the cron job file.

Default value: `undef`

### <a name="cron--job"></a>`cron::job`

This type creates a cron job via a file in /etc/cron.d

#### Examples

##### create a cron job

```puppet
cron::job { 'generate_puppetdoc':
  minute      => '01',
  environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
  command     => 'puppet doc /etc/puppet/modules >/var/www/puppet_docs.mkd',
}
```

#### Parameters

The following parameters are available in the `cron::job` defined type:

* [`command`](#-cron--job--command)
* [`ensure`](#-cron--job--ensure)
* [`minute`](#-cron--job--minute)
* [`hour`](#-cron--job--hour)
* [`date`](#-cron--job--date)
* [`month`](#-cron--job--month)
* [`weekday`](#-cron--job--weekday)
* [`special`](#-cron--job--special)
* [`environment`](#-cron--job--environment)
* [`user`](#-cron--job--user)
* [`group`](#-cron--job--group)
* [`mode`](#-cron--job--mode)
* [`description`](#-cron--job--description)

##### <a name="-cron--job--command"></a>`command`

Data type: `Optional[String[1]]`

The command to execute.

Default value: `undef`

##### <a name="-cron--job--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--job--minute"></a>`minute`

Data type: `Cron::Minute`

The minute the cron job should fire on. Can be any valid cron.

Default value: `'*'`

##### <a name="-cron--job--hour"></a>`hour`

Data type: `Cron::Hour`

The hour the cron job should fire on. Can be any valid cron hour.

Default value: `'*'`

##### <a name="-cron--job--date"></a>`date`

Data type: `Cron::Date`

The date the cron job should fire on. Can be any valid cron date.

Default value: `'*'`

##### <a name="-cron--job--month"></a>`month`

Data type: `Cron::Month`

The month the cron job should fire on. Can be any valid cron month.

Default value: `'*'`

##### <a name="-cron--job--weekday"></a>`weekday`

Data type: `Cron::Weekday`

The day of the week the cron job should fire on. Can be any valid cron weekday value.

Default value: `'*'`

##### <a name="-cron--job--special"></a>`special`

Data type: `Cron::Special`

A crontab specific keyword like 'reboot'.

Default value: `undef`

##### <a name="-cron--job--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--job--user"></a>`user`

Data type: `Cron::User`

The user the cron job should be executed as.

Default value: `'root'`

##### <a name="-cron--job--group"></a>`group`

Data type: `Variant[String[1],Integer[0]]`

the group the cron job file should by owned by.

Default value: `0`

##### <a name="-cron--job--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

##### <a name="-cron--job--description"></a>`description`

Data type: `Optional[String]`

Optional short description, which will be included in the cron job file.

Default value: `undef`

### <a name="cron--job--multiple"></a>`cron::job::multiple`

This type creates multiple cron jobs via a single file in /etc/cron.d/

#### Examples

##### create multiple cron jobs at once

```puppet
cron::job::multiple { 'test':
  jobs => [
    {
      minute      => '55',
      hour        => '5',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'rmueller',
      command     => '/usr/bin/uname',
    },
    {
      command     => '/usr/bin/sleep 1',
    },
    {
      command     => '/usr/bin/sleep 10',
      special     => 'reboot',
    },
  ],
  environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
}
```

#### Parameters

The following parameters are available in the `cron::job::multiple` defined type:

* [`jobs`](#-cron--job--multiple--jobs)
* [`ensure`](#-cron--job--multiple--ensure)
* [`environment`](#-cron--job--multiple--environment)
* [`mode`](#-cron--job--multiple--mode)

##### <a name="-cron--job--multiple--jobs"></a>`jobs`

Data type:

```puppet
Array[Struct[{
        Optional['command']     => String[1],
        Optional['minute']      => Cron::Minute,
        Optional['hour']        => Cron::Hour,
        Optional['date']        => Cron::Date,
        Optional['month']       => Cron::Month,
        Optional['weekday']     => Cron::Weekday,
        Optional['special']     => Cron::Special,
        Optional['user']        => Cron::User,
        Optional['description'] => String,
  }]]
```

A hash of multiple cron jobs using the same structure as cron::job and using the same defaults for each parameter.

##### <a name="-cron--job--multiple--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--job--multiple--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--job--multiple--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

### <a name="cron--monthly"></a>`cron::monthly`

This type creates a monthly cron job via a file in /etc/cron.d

#### Examples

##### create a cron job that runs monthly on a 28. day at 7 am and 1 minute

```puppet
cron::monthly { 'delete_old_log_files':
  minute      => '1',
  hour        => '7',
  date        => '28',
  environment => [ 'MAILTO="admin@example.com"' ],
  command     => 'find /var/log -type f -ctime +30 -delete',
}
```

#### Parameters

The following parameters are available in the `cron::monthly` defined type:

* [`command`](#-cron--monthly--command)
* [`ensure`](#-cron--monthly--ensure)
* [`minute`](#-cron--monthly--minute)
* [`hour`](#-cron--monthly--hour)
* [`date`](#-cron--monthly--date)
* [`environment`](#-cron--monthly--environment)
* [`user`](#-cron--monthly--user)
* [`mode`](#-cron--monthly--mode)
* [`description`](#-cron--monthly--description)

##### <a name="-cron--monthly--command"></a>`command`

Data type: `Optional[String[1]]`

The command to execute.

Default value: `undef`

##### <a name="-cron--monthly--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--monthly--minute"></a>`minute`

Data type: `Cron::Minute`

The minute the cron job should fire on. Can be any valid cron value.

Default value: `0`

##### <a name="-cron--monthly--hour"></a>`hour`

Data type: `Cron::Hour`

The hour the cron job should fire on. Can be any valid cron hour value.

Default value: `0`

##### <a name="-cron--monthly--date"></a>`date`

Data type: `Cron::Date`

The date the cron job should fire on. Can be any valid cron date value.

Default value: `1`

##### <a name="-cron--monthly--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--monthly--user"></a>`user`

Data type: `Cron::User`

The user the cron job should be executed as.

Default value: `'root'`

##### <a name="-cron--monthly--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

##### <a name="-cron--monthly--description"></a>`description`

Data type: `Optional[String]`

Optional short description, which will be included in the cron job file.

Default value: `undef`

### <a name="cron--weekly"></a>`cron::weekly`

This type creates a cron job via a file in /etc/cron.d

#### Examples

##### create a weekly cron that runs on the 7th day at 4 am and 1 minute

```puppet
cron::weekly { 'delete_old_temp_files':
  minute      => '1',
  hour        => '4',
  weekday     => '7',
  environment => [ 'MAILTO="admin@example.com"' ],
  command     => 'find /tmp -type f -ctime +7 -delete',
}
```

#### Parameters

The following parameters are available in the `cron::weekly` defined type:

* [`command`](#-cron--weekly--command)
* [`ensure`](#-cron--weekly--ensure)
* [`minute`](#-cron--weekly--minute)
* [`hour`](#-cron--weekly--hour)
* [`weekday`](#-cron--weekly--weekday)
* [`user`](#-cron--weekly--user)
* [`mode`](#-cron--weekly--mode)
* [`environment`](#-cron--weekly--environment)
* [`description`](#-cron--weekly--description)

##### <a name="-cron--weekly--command"></a>`command`

Data type: `Optional[String[1]]`

The command to execute.

Default value: `undef`

##### <a name="-cron--weekly--ensure"></a>`ensure`

Data type: `Cron::Job_ensure`

The state to ensure this resource exists in. Can be absent, present.

Default value: `'present'`

##### <a name="-cron--weekly--minute"></a>`minute`

Data type: `Cron::Minute`

The minute the cron job should fire on. Can be any valid cron.

Default value: `0`

##### <a name="-cron--weekly--hour"></a>`hour`

Data type: `Cron::Hour`

The hour the cron job should fire on. Can be any valid cron hour value.

Default value: `0`

##### <a name="-cron--weekly--weekday"></a>`weekday`

Data type: `Cron::Weekday`

The day of the week the cron job should fire on. Can be any valid cron weekday value.

Default value: `0`

##### <a name="-cron--weekly--user"></a>`user`

Data type: `Cron::User`

The user the cron job should be executed as.

Default value: `'root'`

##### <a name="-cron--weekly--mode"></a>`mode`

Data type: `Stdlib::Filemode`

The mode to set on the created job file.

Default value: `'0600'`

##### <a name="-cron--weekly--environment"></a>`environment`

Data type: `Cron::Environment`

An array of environment variable settings.

Default value: `[]`

##### <a name="-cron--weekly--description"></a>`description`

Data type: `Optional[String]`

Optional short description, which will be included in the cron job file.

Default value: `undef`

## Data types

### <a name="Cron--Date"></a>`Cron::Date`

Valid $date (day of month) parameter to Cron::Job.

Alias of

```puppet
Variant[Integer[1,31], Pattern[/(?x)\A(
    \* ( \/ ( [12][0-9]?|3[01]?|[4-9] ) )?
    |       ( [12][0-9]?|3[01]?|[4-9] ) ( - ( [12][0-9]?|3[01]?|[4-9] ) ( \/ ( [12][0-9]?|3[01]?|[4-9] ) )? )?
       ( ,  ( [12][0-9]?|3[01]?|[4-9] ) ( - ( [12][0-9]?|3[01]?|[4-9] ) ( \/ ( [12][0-9]?|3[01]?|[4-9] ) )? )? )*
  )\z/]]
```

### <a name="Cron--Deb_version"></a>`Cron::Deb_version`

Valid .deb version string.
See https://www.debian.org/doc/debian-policy/#s-f-version

Alias of `Pattern[/(?i:\A(((0|[1-9][0-9]*):)?[0-9]([a-z0-9.+-~]*|[a-z0-9.+~]*-[a-z0-9+.~]+))\z)/]`

### <a name="Cron--Environment"></a>`Cron::Environment`

Valid $environment parameter to Cron::Job.

Alias of `Array[Pattern[/(?i:\A[a-z_][a-z0-9_]*=[^\0]*\z)/]]`

### <a name="Cron--Hour"></a>`Cron::Hour`

Valid $hour parameter to Cron::Job.

Alias of

```puppet
Variant[Integer[0,23], Pattern[/(?x)\A(
    \* ( \/ ( 1[0-9]|2[0-3]|[1-9] ) )?
    |       ( 1?[0-9]|2[0-3] ) ( - ( 1?[0-9]|2[0-3] ) ( \/ ( 1[0-9]|2[0-3]|[1-9] ) )? )?
        ( , ( 1?[0-9]|2[0-3] ) ( - ( 1?[0-9]|2[0-3] ) ( \/ ( 1[0-9]|2[0-3]|[1-9] ) )? )? )*
  )\z/]]
```

### <a name="Cron--Job_ensure"></a>`Cron::Job_ensure`

Valid $ensure parameter to Cron::Job.

Alias of `Enum['absent', 'present']`

### <a name="Cron--Jobname"></a>`Cron::Jobname`

Valid $title parameter to Cron::Job.
This is the name of the /etc/cron.d/ file.
The Ubuntu run-parts manpage specifies (^[a-zA-Z0-9_-]+$).
For Cronie, the documentation is (unfortunately) in the code:
- Ignore files starting with "." or "#"
- Ignore the CRON_HOSTNAME file (default ".cron.hostname").
- Ignore files whose length is zero or greater than NAME_MAX (default 255).
- Ignore files whose name ends in "~".
- Ignore files whose name ends in ".rpmsave", ".rpmorig", or ".rpmnew".
We will use the most restrictive combination.
See http://manpages.ubuntu.com/manpages/zesty/en/man8/run-parts.8.html
See https://github.com/cronie-crond/cronie/blob/master/src/database.c#L625

Alias of `Pattern[/(?i:\A[a-z0-9_-]{1,255}\z)/]`

### <a name="Cron--Minute"></a>`Cron::Minute`

Valid $minute parameter to Cron::Job.

Alias of

```puppet
Variant[Integer[0,59], Pattern[/(?x)\A(
    \* ( \/ ( [1-5][0-9]?|[6-9] ) )?
    |         [1-5]?[0-9] ( - [1-5]?[0-9] ( \/ ( [1-5][0-9]?|[6-9] ) )? )?
        ( ,   [1-5]?[0-9] ( - [1-5]?[0-9] ( \/ ( [1-5][0-9]?|[6-9] ) )? )? )*
  )\z/]]
```

### <a name="Cron--Month"></a>`Cron::Month`

Valid $month parameter to Cron::Job.

Alias of

```puppet
Variant[Cron::Monthname, Integer[1,12], Pattern[/(?x)\A(
    \* ( \/ ( 1[012]?|[2-9] ) )?
    |       ( 1[012]?|[2-9] ) ( - ( 1[012]?|[2-9] ) ( \/ ( 1[012]?|[2-9] ) )? )?
        ( , ( 1[012]?|[2-9] ) ( - ( 1[012]?|[2-9] ) ( \/ ( 1[012]?|[2-9] ) )? )? )*
  )\z/]]
```

### <a name="Cron--Monthname"></a>`Cron::Monthname`

Short-names for each month.

Alias of `Enum['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']`

### <a name="Cron--Package_ensure"></a>`Cron::Package_ensure`

Valid $service_ensure parameter to Cron.

Alias of `Variant[Cron::Package_state, Cron::Deb_version, Cron::Rpm_version]`

### <a name="Cron--Package_state"></a>`Cron::Package_state`

Valid $ensure parameter to Package resource. Excludes version numbers.

Alias of `Enum['absent', 'installed', 'held', 'latest', 'present', 'purged']`

### <a name="Cron--Rpm_version"></a>`Cron::Rpm_version`

Valid .rpm version string.
See http://www.perlmonks.org/?node_id=237724

Alias of `Pattern[/\A[^-]+(-[^-])?\z/]`

### <a name="Cron--Run_parts"></a>`Cron::Run_parts`

Valid element of $crontab_run_parts parameter to Class['cron'].

Alias of

```puppet
Hash[Cron::Jobname, Struct[{
    NotUndef['user']       => Cron::User,
    Optional['minute']     => Cron::Minute,
    Optional['hour']       => Cron::Hour,
    Optional['dayofmonth'] => Cron::Date,
    Optional['month']      => Cron::Month,
    Optional['dayofweek']  => Cron::Weekday,
  }]]
```

### <a name="Cron--Second"></a>`Cron::Second`

Valid $second parameter to Cron::Job.

Alias of `Cron::Minute`

### <a name="Cron--Service_Enable"></a>`Cron::Service_Enable`

Valid $service_enable parameter to Cron.

Alias of `Variant[Boolean, Enum['manual','mask']]`

### <a name="Cron--Service_ensure"></a>`Cron::Service_ensure`

Valid $service_ensure parameter to Cron.

Alias of `Variant[Boolean, Enum['running','stopped']]`

### <a name="Cron--Special"></a>`Cron::Special`

Valid $special parameter to Cron::Job.

Alias of

```puppet
Optional[Enum['annually',
    'daily',
    'hourly',
    'midnight',
    'monthly',
    'reboot',
    'weekly',
    'yearly',
  ]]
```

### <a name="Cron--User"></a>`Cron::User`

Valid $user parameter to Cron::Job.

Alias of `Pattern[/(?i:\A\w[a-z0-9_\.-]{0,30}[a-z0-9_$-]\z)/]`

### <a name="Cron--Weekday"></a>`Cron::Weekday`

Valid $weekday parameter to Cron::Job.

Alias of

```puppet
Variant[Cron::Weekdayname, Integer[0,7], Pattern[/(?x)\A(
    \* ( \/ [1-7] )?
    |       [0-7] ( - [0-7] ( \/ [1-7] )? )?
        ( , [0-7] ( - [0-7] ( \/ [1-7] )? )? )*
  )\z/]]
```

### <a name="Cron--Weekdayname"></a>`Cron::Weekdayname`

Short names for each day of the week.

Alias of `Enum['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']`
