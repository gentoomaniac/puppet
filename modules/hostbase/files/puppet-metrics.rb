#!/usr/bin/env ruby
# frozen_string_literal: true

# ExecStopPost of run-puppet: turns Puppet's last_run_summary.yaml and
# /etc/puppet_branch into metrics for node-exporter's textfile collector.
# Usage: puppet-metrics <last_run_summary.yaml> <output .prom file>

require 'yaml'

summary_file, output = ARGV
abort 'usage: puppet-metrics <last_run_summary.yaml> <output .prom file>' unless summary_file && output

summary = YAML.safe_load_file(summary_file) || {}
# sections can be missing or empty, e.g. after a failed catalog compile
section = ->(name) { summary[name] || {} }
times = section.call('time').dup
last_run = times.delete('last_run')
branch = File.exist?('/etc/puppet_branch') ? File.read('/etc/puppet_branch').lines.first.to_s.strip : ''
branch = 'unknown' if branch.empty?

# Label values like the branch come from files, so escape what would break the format
def escape(value)
  value.to_s.gsub('\\') { '\\\\' }.gsub('"', '\\"')
end

# HELP/TYPE header and one line per [labels, value] sample; nothing without samples
def metric(name, help, samples)
  return [] if samples.empty?

  lines = ["# HELP #{name} #{help}", "# TYPE #{name} gauge"]
  samples.each do |labels, value|
    label_text = labels.map { |key, label_value| "#{key}=\"#{escape(label_value)}\"" }.join(',')
    lines << "#{name}#{"{#{label_text}}" unless labels.empty?} #{value}"
  end
  lines
end

changes = summary.dig('changes', 'total')
config_version = summary.dig('version', 'config')
puppet_version = summary.dig('version', 'puppet')

metrics = [
  metric('puppet_last_run_timestamp_seconds', 'End of the last Puppet run.',
         last_run ? [[{}, last_run]] : []),
  metric('puppet_last_run_duration_seconds', 'Time of the last Puppet run, total and per phase or resource type.',
         times.map { |type, seconds| [{ type: type }, seconds] }),
  metric('puppet_last_run_resources', 'Resources of the last Puppet run by state (changed, failed, ...).',
         section.call('resources').map { |state, count| [{ state: state }, count] }),
  metric('puppet_last_run_events', 'Events of the last Puppet run by result.',
         section.call('events').map { |state, count| [{ state: state }, count] }),
  metric('puppet_last_run_changes', 'Changes made by the last Puppet run.',
         changes ? [[{}, changes]] : []),
  metric('puppet_last_run_config_version', 'Catalog version applied by the last Puppet run.',
         config_version ? [[{}, config_version]] : []),
  metric('puppet_version_info', 'Puppet version, value is always 1.',
         puppet_version ? [[{ version: puppet_version }, 1]] : []),
  metric('puppet_branch_info', 'Branch of this repo the host applies (/etc/puppet_branch), value is always 1.',
         [[{ branch: branch }, 1]]),
].flatten

# Write next to the target and rename, so node-exporter never reads a half-written file
tmp = "#{output}.#{Process.pid}"
begin
  File.write(tmp, metrics.join("\n") + "\n")
  # node-exporter runs as nobody
  File.chmod(0o644, tmp)
  File.rename(tmp, output)
ensure
  File.unlink(tmp) if File.exist?(tmp)
end
