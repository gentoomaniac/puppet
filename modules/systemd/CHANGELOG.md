# Changelog

## [2.9.0](https://github.com/camptocamp/puppet-systemd/tree/2.9.0) (2020-03-09)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.8.0...2.9.0)

**Implemented enhancements:**

- Add EL8 Support [\#144](https://github.com/camptocamp/puppet-systemd/pull/144) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Add Fedora 30/31 compatibility [\#141](https://github.com/camptocamp/puppet-systemd/pull/141) ([bastelfreak](https://github.com/bastelfreak))
- New systemd::timer define type [\#138](https://github.com/camptocamp/puppet-systemd/pull/138) ([mmoll](https://github.com/mmoll))
- Add SLES 12/15 support [\#137](https://github.com/camptocamp/puppet-systemd/pull/137) ([msurato](https://github.com/msurato))

**Closed issues:**

- Discussion: use class instead of exec for notification [\#2](https://github.com/camptocamp/puppet-systemd/issues/2)

**Merged pull requests:**

- fix Issue 113 [\#140](https://github.com/camptocamp/puppet-systemd/pull/140) ([schlitzered](https://github.com/schlitzered))

## [2.8.0](https://github.com/camptocamp/puppet-systemd/tree/2.8.0) (2020-01-08)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.7.0...2.8.0)

**Implemented enhancements:**

- Rubocop [\#135](https://github.com/camptocamp/puppet-systemd/pull/135) ([raphink](https://github.com/raphink))
- Update types to avoid / in unit or drop file name [\#130](https://github.com/camptocamp/puppet-systemd/pull/130) ([traylenator](https://github.com/traylenator))
- Add OOMScoreAdjust to Systemd::ServiceLimits type [\#128](https://github.com/camptocamp/puppet-systemd/pull/128) ([jlutran](https://github.com/jlutran))

**Fixed bugs:**

- Correct CPUQuota service limit regex [\#92](https://github.com/camptocamp/puppet-systemd/pull/92) ([matt6697](https://github.com/matt6697))

**Merged pull requests:**

- Release 2.8.0 [\#134](https://github.com/camptocamp/puppet-systemd/pull/134) ([raphink](https://github.com/raphink))
- Convert to PDK [\#132](https://github.com/camptocamp/puppet-systemd/pull/132) ([raphink](https://github.com/raphink))
- Add loginctl\_user type/provider [\#131](https://github.com/camptocamp/puppet-systemd/pull/131) ([raphink](https://github.com/raphink))
- Force tmpfiles.d drop file to end in .conf [\#129](https://github.com/camptocamp/puppet-systemd/pull/129) ([traylenator](https://github.com/traylenator))
- allow puppetlabs/inifile 4.x [\#126](https://github.com/camptocamp/puppet-systemd/pull/126) ([bastelfreak](https://github.com/bastelfreak))

## [2.7.0](https://github.com/camptocamp/puppet-systemd/tree/2.7.0) (2019-10-29)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.6.0...2.7.0)

**Implemented enhancements:**

- add support for 'VirtuozzoLinux 7' [\#121](https://github.com/camptocamp/puppet-systemd/pull/121) ([kBite](https://github.com/kBite))
- Manage logind service and configuration [\#120](https://github.com/camptocamp/puppet-systemd/pull/120) ([fraenki](https://github.com/fraenki))

**Fixed bugs:**

- Correct order when ensuring unit files are absent [\#122](https://github.com/camptocamp/puppet-systemd/pull/122) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- vacuum as routine task [\#123](https://github.com/camptocamp/puppet-systemd/issues/123)
- Manage dropin\_file for target type systemd unit  [\#117](https://github.com/camptocamp/puppet-systemd/issues/117)
- Allow Sensitive type for systemd::dropin\_file::content [\#114](https://github.com/camptocamp/puppet-systemd/issues/114)

**Merged pull requests:**

- allow Sensitive type for content param [\#115](https://github.com/camptocamp/puppet-systemd/pull/115) ([TheMeier](https://github.com/TheMeier))

## [2.6.0](https://github.com/camptocamp/puppet-systemd/tree/2.6.0) (2019-06-17)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.5.1...2.6.0)

**Implemented enhancements:**

- Allow for lazy/eager systemctl daemon reloading [\#111](https://github.com/camptocamp/puppet-systemd/pull/111) ([JohnLyman](https://github.com/JohnLyman))

**Merged pull requests:**

- Remove stray `v` from Changelog `config.future\_release` [\#110](https://github.com/camptocamp/puppet-systemd/pull/110) ([alexjfisher](https://github.com/alexjfisher))

## [2.5.1](https://github.com/camptocamp/puppet-systemd/tree/2.5.1) (2019-05-29)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.5.0...2.5.1)

**Merged pull requests:**

- Pin `public\_suffix` to `3.0.3` on rvm 2.1.9 builds [\#108](https://github.com/camptocamp/puppet-systemd/pull/108) ([alexjfisher](https://github.com/alexjfisher))
- run CI jobs on xenial instead of trusty [\#107](https://github.com/camptocamp/puppet-systemd/pull/107) ([bastelfreak](https://github.com/bastelfreak))

## [2.5.0](https://github.com/camptocamp/puppet-systemd/tree/2.5.0) (2019-05-29)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.4.0...2.5.0)

**Merged pull requests:**

- Allow `puppetlabs/stdlib` 6.x [\#103](https://github.com/camptocamp/puppet-systemd/pull/103) ([alexjfisher](https://github.com/alexjfisher))

## [2.4.0](https://github.com/camptocamp/puppet-systemd/tree/2.4.0) (2019-04-29)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.3.0...2.4.0)

**Merged pull requests:**

- Allow `puppetlabs/inifile` 3.x [\#101](https://github.com/camptocamp/puppet-systemd/pull/101) ([alexjfisher](https://github.com/alexjfisher))

## [2.3.0](https://github.com/camptocamp/puppet-systemd/tree/2.3.0) (2019-04-10)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.2.0...2.3.0)

**Implemented enhancements:**

- Add parameter to enable/disable the management of journald [\#99](https://github.com/camptocamp/puppet-systemd/pull/99) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- Puppet version compatibility [\#34](https://github.com/camptocamp/puppet-systemd/issues/34)

## [2.2.0](https://github.com/camptocamp/puppet-systemd/tree/2.2.0) (2019-02-25)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.1.0...2.2.0)

**Implemented enhancements:**

- Puppet 6 support [\#96](https://github.com/camptocamp/puppet-systemd/pull/96) ([ekohl](https://github.com/ekohl))
- Manage journald service and configuration [\#89](https://github.com/camptocamp/puppet-systemd/pull/89) ([treydock](https://github.com/treydock))
- Add support for DNSoverTLS [\#88](https://github.com/camptocamp/puppet-systemd/pull/88) ([shibumi](https://github.com/shibumi))
- unit.d directory should be purged of unmanaged dropin files [\#41](https://github.com/camptocamp/puppet-systemd/pull/41) ([treydock](https://github.com/treydock))
- Add Journald support [\#14](https://github.com/camptocamp/puppet-systemd/pull/14) ([duritong](https://github.com/duritong))

**Closed issues:**

- Hiera usage for systemd::unit\_file [\#86](https://github.com/camptocamp/puppet-systemd/issues/86)
- Please push a new module to the forge that includes service\_limits [\#25](https://github.com/camptocamp/puppet-systemd/issues/25)

**Merged pull requests:**

- Allow specifying owner/group/mode/show\_diff [\#94](https://github.com/camptocamp/puppet-systemd/pull/94) ([simondeziel](https://github.com/simondeziel))

## [2.1.0](https://github.com/camptocamp/puppet-systemd/tree/2.1.0) (2018-08-31)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/2.0.0...2.1.0)

**Implemented enhancements:**

- Modify service limit type [\#81](https://github.com/camptocamp/puppet-systemd/pull/81) ([bastelfreak](https://github.com/bastelfreak))
- Add parameter to select resolver [\#79](https://github.com/camptocamp/puppet-systemd/pull/79) ([amateo](https://github.com/amateo))

**Fixed bugs:**

- Handle ensuring service\_limits to be absent [\#80](https://github.com/camptocamp/puppet-systemd/pull/80) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- do not access facts as top scope variable [\#85](https://github.com/camptocamp/puppet-systemd/pull/85) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#83](https://github.com/camptocamp/puppet-systemd/pull/83) ([bastelfreak](https://github.com/bastelfreak))
- Fix CHANGELOG.md duplicate footer [\#78](https://github.com/camptocamp/puppet-systemd/pull/78) ([alexjfisher](https://github.com/alexjfisher))

## [2.0.0](https://github.com/camptocamp/puppet-systemd/tree/2.0.0) (2018-07-11)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/1.1.1...2.0.0)

**Breaking changes:**

- move params to data-in-modules [\#67](https://github.com/camptocamp/puppet-systemd/pull/67) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- add ubuntu 18.04 support [\#72](https://github.com/camptocamp/puppet-systemd/pull/72) ([bastelfreak](https://github.com/bastelfreak))
- bump facter to latest 2.x version [\#71](https://github.com/camptocamp/puppet-systemd/pull/71) ([bastelfreak](https://github.com/bastelfreak))
- Add enable and active parameters to unit\_file [\#69](https://github.com/camptocamp/puppet-systemd/pull/69) ([jcharaoui](https://github.com/jcharaoui))
- Add support for Resource Accounting via systemd [\#65](https://github.com/camptocamp/puppet-systemd/pull/65) ([bastelfreak](https://github.com/bastelfreak))
- Allow resolved class to configure DNS settings [\#59](https://github.com/camptocamp/puppet-systemd/pull/59) ([hfm](https://github.com/hfm))
- Replace iterator with stdlib function [\#58](https://github.com/camptocamp/puppet-systemd/pull/58) ([jfleury-at-ovh](https://github.com/jfleury-at-ovh))

**Closed issues:**

- Better test for systemd \(and other init systems\) [\#37](https://github.com/camptocamp/puppet-systemd/issues/37)

**Merged pull requests:**

- fix puppet-linter warnings in README.md [\#75](https://github.com/camptocamp/puppet-systemd/pull/75) ([bastelfreak](https://github.com/bastelfreak))
- Update the documentation of facts [\#68](https://github.com/camptocamp/puppet-systemd/pull/68) ([ekohl](https://github.com/ekohl))
- purge legacy puppet-lint checks [\#66](https://github.com/camptocamp/puppet-systemd/pull/66) ([bastelfreak](https://github.com/bastelfreak))
- Reuse the systemd::dropin\_file in service\_limits [\#61](https://github.com/camptocamp/puppet-systemd/pull/61) ([ekohl](https://github.com/ekohl))
- cleanup README.md [\#60](https://github.com/camptocamp/puppet-systemd/pull/60) ([bastelfreak](https://github.com/bastelfreak))
- implement github changelog generator [\#45](https://github.com/camptocamp/puppet-systemd/pull/45) ([bastelfreak](https://github.com/bastelfreak))

## [1.1.1](https://github.com/camptocamp/puppet-systemd/tree/1.1.1) (2017-11-29)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/1.1.0...1.1.1)

**Fixed bugs:**

- fact systemd\_internal\_services is empty [\#47](https://github.com/camptocamp/puppet-systemd/issues/47)
- Use the correct type on $service\_limits [\#52](https://github.com/camptocamp/puppet-systemd/pull/52) ([ekohl](https://github.com/ekohl))
- Fix issue \#47 [\#48](https://github.com/camptocamp/puppet-systemd/pull/48) ([axxelG](https://github.com/axxelG))

**Closed issues:**

- Not able to set limits via systemd class [\#49](https://github.com/camptocamp/puppet-systemd/issues/49)

**Merged pull requests:**

- Clean up test tooling [\#54](https://github.com/camptocamp/puppet-systemd/pull/54) ([ekohl](https://github.com/ekohl))
- Correct parameter documentation [\#53](https://github.com/camptocamp/puppet-systemd/pull/53) ([ekohl](https://github.com/ekohl))
- Use a space-separated in timesyncd.conf [\#50](https://github.com/camptocamp/puppet-systemd/pull/50) ([hfm](https://github.com/hfm))
- Use the same systemd drop-in file for different units [\#46](https://github.com/camptocamp/puppet-systemd/pull/46) ([countsudoku](https://github.com/countsudoku))

## [1.1.0](https://github.com/camptocamp/puppet-systemd/tree/1.1.0) (2017-10-24)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/1.0.0...1.1.0)

**Closed issues:**

- Add explicit ordering to README.md [\#24](https://github.com/camptocamp/puppet-systemd/issues/24)
- Manage drop-in files [\#15](https://github.com/camptocamp/puppet-systemd/issues/15)

**Merged pull requests:**

- Add systemd-timesyncd support [\#43](https://github.com/camptocamp/puppet-systemd/pull/43) ([bastelfreak](https://github.com/bastelfreak))
- Reuse the service\_provider fact from stdlib [\#42](https://github.com/camptocamp/puppet-systemd/pull/42) ([ekohl](https://github.com/ekohl))
- \(doc\) Adds examples of running the service created [\#29](https://github.com/camptocamp/puppet-systemd/pull/29) ([petems](https://github.com/petems))
- Quote hash keys in example of service limits [\#20](https://github.com/camptocamp/puppet-systemd/pull/20) ([stbenjam](https://github.com/stbenjam))

## [1.0.0](https://github.com/camptocamp/puppet-systemd/tree/1.0.0) (2017-09-04)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.4.0...1.0.0)

**Implemented enhancements:**

- Add support for drop-in files [\#39](https://github.com/camptocamp/puppet-systemd/pull/39) ([countsudoku](https://github.com/countsudoku))
- Adds control group limits to ServiceLimits [\#36](https://github.com/camptocamp/puppet-systemd/pull/36) ([trevor-vaughan](https://github.com/trevor-vaughan))

**Closed issues:**

- PR\#18 broke service limits capacity [\#35](https://github.com/camptocamp/puppet-systemd/issues/35)
- stdlib functions are used, but no stdlib requirement in metadata.json [\#28](https://github.com/camptocamp/puppet-systemd/issues/28)
- investigate update to camptocamp/systemd module  [\#21](https://github.com/camptocamp/puppet-systemd/issues/21)
- Module should be updated to use the new Puppet 4 goodness [\#17](https://github.com/camptocamp/puppet-systemd/issues/17)

**Merged pull requests:**

- it's systemd not SystemD [\#33](https://github.com/camptocamp/puppet-systemd/pull/33) ([shibumi](https://github.com/shibumi))
- General cleanup + add Puppet4 datatypes [\#32](https://github.com/camptocamp/puppet-systemd/pull/32) ([bastelfreak](https://github.com/bastelfreak))
- add management for systemd-resolved [\#31](https://github.com/camptocamp/puppet-systemd/pull/31) ([bastelfreak](https://github.com/bastelfreak))
- Add a network defined resource [\#30](https://github.com/camptocamp/puppet-systemd/pull/30) ([bastelfreak](https://github.com/bastelfreak))
- Add seltype to systemd directory [\#27](https://github.com/camptocamp/puppet-systemd/pull/27) ([petems](https://github.com/petems))
- Add MemoryLimit to limits template [\#23](https://github.com/camptocamp/puppet-systemd/pull/23) ([pkilambi](https://github.com/pkilambi))
- Update to support Puppet 4 [\#18](https://github.com/camptocamp/puppet-systemd/pull/18) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Manage resource limits of services [\#13](https://github.com/camptocamp/puppet-systemd/pull/13) ([ruriky](https://github.com/ruriky))
- Refactor systemd facts [\#12](https://github.com/camptocamp/puppet-systemd/pull/12) ([petems](https://github.com/petems))

## [0.4.0](https://github.com/camptocamp/puppet-systemd/tree/0.4.0) (2016-08-18)

[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.3.0...0.4.0)

**Implemented enhancements:**

- Add target param for the unit file [\#10](https://github.com/camptocamp/puppet-systemd/pull/10) ([tampakrap](https://github.com/tampakrap))
- only use awk, instead of grep and awk [\#9](https://github.com/camptocamp/puppet-systemd/pull/9) ([igalic](https://github.com/igalic))

**Closed issues:**

- No LICENSE file [\#11](https://github.com/camptocamp/puppet-systemd/issues/11)
- Forge update  [\#7](https://github.com/camptocamp/puppet-systemd/issues/7)

## [0.3.0](https://forge.puppetlabs.com/camptocamp/systemd/0.3.0) (2016-05-16)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.2.2...0.3.0)

**Implemented enhancements:**

- Shortcut for creating unit files / tmpfiles [\#4](https://github.com/camptocamp/puppet-systemd/pull/4) ([felixb](https://github.com/felixb))
- Add systemd facts [\#6](https://github.com/camptocamp/puppet-systemd/pull/6) ([roidelapluie](https://github.com/roidelapluie))


## [0.2.2](https://forge.puppetlabs.com/camptocamp/systemd/0.2.2) (2015-08-25)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.2.1...0.2.2)

**Implemented enhancements:**

- Add 'systemd-tmpfiles-create' [\#1](https://github.com/camptocamp/puppet-systemd/pull/1) ([roidelapluie](https://github.com/roidelapluie))


## [0.2.1](https://forge.puppetlabs.com/camptocamp/systemd/0.2.1) (2015-08-21)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.2.0...0.2.1)

- Use docker for acceptance tests

## [0.1.15](https://forge.puppetlabs.com/camptocamp/systemd/0.1.15) (2015-06-26)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.14...0.1.15)

- Fix strict_variables activation with rspec-puppet 2.2

## [0.1.14](https://forge.puppetlabs.com/camptocamp/systemd/0.1.14) (2015-05-28)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.13...0.1.14)

- Add beaker_spec_helper to Gemfile

## [0.1.13](https://forge.puppetlabs.com/camptocamp/systemd/0.1.13) (2015-05-26)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.12...0.1.13)

- Use random application order in nodeset

## [0.1.12](https://forge.puppetlabs.com/camptocamp/systemd/0.1.12) (2015-05-26)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.11...0.1.12)

- Add utopic & vivid nodesets

## [0.1.11](https://forge.puppetlabs.com/camptocamp/systemd/0.1.11) (2015-05-25)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.10...0.1.11)

- Don't allow failure on Puppet 4

## [0.1.10](https://forge.puppetlabs.com/camptocamp/systemd/0.1.10) (2015-05-13)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.9...0.1.10)

- Add puppet-lint-file_source_rights-check gem

## [0.1.9](https://forge.puppetlabs.com/camptocamp/systemd/0.1.9) (2015-05-12)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.8...0.1.9)

- Don't pin beaker

## [0.1.8](https://forge.puppetlabs.com/camptocamp/systemd/0.1.8) (2015-04-27)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.7...0.1.8)

- Add nodeset ubuntu-12.04-x86_64-openstack

## [0.1.7](https://forge.puppetlabs.com/camptocamp/systemd/0.1.7) (2015-04-03)
[Full Changelog](https://github.com/camptocamp/puppet-systemd/compare/0.1.6...0.1.7)

- Confine rspec pinning to ruby 1.8


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
