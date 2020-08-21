#!/usr/bin/env ruby

# This script rebuilds the helm repository index.yaml to add a new entry (or
# update, if the version already exists), such that the download URL points to
# GitHub releases.  The changes will be comitted to git.
# This is expected to run from a GitHub action.

# Usage:
#  REPO=<repo> GITHUB_TOKEN=<token> GITHUB_REF=<ref> $0

# The working directory must be a git repository for the helm repository.  If a
# "index.yaml" exists in the working directory, it will be updated; otherwise, a
# new file is created.

# Required environment variables:
#   REPO:         The path of the GitHub repository, such as "SUSE/eirinix-helm-release"
#   GITHUB_TOKEN: OAuth token to use for authentication
#   GITHUB_REF:   GitHub release tag, possiby prefixed by "refs/tags/"

# Optional environment variables:
#   GIT_AUTHOR_NAME:   If set, git will use this as the author name.
#   GIT_AUTHOR_EMAIL:  If set, git will use this as the author email.
#   CHART_URL:         If set, use this for the chart URL rather than ask GitHub

require 'date'
require 'digest'
require 'erb'
require 'json'
require 'rubygems/package'
require 'tempfile'
require 'yaml'
require 'zlib'

# Given a path to a helm chart (tgz bundle), return its Charts.yaml contents
# as a hash.
def read_chart(path)
    file = Gem::Package::TarReader.new(Zlib::GzipReader.open(path))
    entry = file.find { |entry| entry.full_name =~ /^[^\/]+\/Chart\.yaml$/ }
    YAML.load(entry.read)
end

def repo
    fail 'Environment variable REPO is missing' unless ENV['REPO']
    ENV['REPO']
end

def tag
    fail 'Environment variable GITHUB_REF is missing' unless ENV['GITHUB_REF']
    ENV['GITHUB_REF'].delete_prefix 'refs/tags/'
end

def curl
    %Q<curl --header 'Authorization: #{ENV['GITHUB_TOKEN']}'>
end

def release
    url = "https://api.github.com/repos/#{repo}/releases/tags/#{tag}"
    JSON.load(`#{curl} '#{url}'`)
end

def chart_url
    ENV['CHART_URL'] || release['assets'].first['browser_download_url']
end

# Path to the chart bundle (*.tgz)
def tar_file_path
    return $tar_file.path unless $tar_file.nil?
    $tar_file = Tempfile.new(['eirinix-chart-', '.tgz']).tap(&:close)
    Process.wait Process.spawn('curl', '-L', '-o', $tar_file.path, chart_url)
    fail "Could not download file" unless $?.success?
    $tar_file.path
end

# The entry in index.yaml for this chart version
def build_entry
    wanted_keys = %w(apiVersion description name version)
    chart_info = read_chart(tar_file_path).select { |k, v| wanted_keys.include? k }
    digest = Digest::SHA256.file(tar_file_path).hexdigest
    result = chart_info.merge(
        created: File.ctime(tar_file_path).to_datetime.rfc3339,
        digest: digest,
        urls: [ chart_url ],
    )
    # Do a sort on the keys to match output of the official helm CLI
    Hash[result.transform_keys(&:to_s).to_a.sort]
end

index = begin
    YAML.load_file('index.yaml')
rescue Errno::ENOENT
    {
        apiVersion: 'v1',
        entries: {},
    }.transform_keys(&:to_s)
end
entry = build_entry
entries = index['entries'][entry['name']] ||= []
old_entry = entries.find { |e| e['version'] == entry['version']}
if old_entry.nil?
    entries << entry
    message = "Add version #{entry['version']}"
else
    old_entry.merge! entry
    message = "Update version #{entry['version']}"
end
puts "#{message} with #{entry['urls'].first}"
index['generated'] = DateTime.now.rfc3339

File.open('index.yaml', 'w') { |f| YAML.dump(index, f) }

Process.wait Process.spawn('git', 'add', 'index.yaml')
fail "Git add returned #{$?.exitstatus}" unless $?.success?
git_command = %w(git)
ENV['GIT_AUTHOR_NAME'].tap { |n| git_command += ['-c', "user.name=#{n}"] if n }
ENV['GIT_AUTHOR_EMAIL'].tap { |e| git_command += ['-c', "user.email=#{e}"] if e }
git_command += [ 'commit', '-m', message ]

exec *git_command
