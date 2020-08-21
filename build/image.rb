# frozen_string_literal: true

require 'fileutils'
require 'open3'
require_relative '_build_utils.rb'

manifest = load_manifest

cmd = [
  'docker',
  'build',
  '--build-arg', "build_base=#{manifest.image.builder}",
  '--build-arg', "base=#{manifest.image.base}",
  '--tag', "#{manifest.image.repository}:#{manifest.image.tag}",
  git_root
]

# _If_ we have any `replace` lines in go.mod, assume we're doing local
# development.

if File.read('go.mod').lines.any? { |l| l.start_with? 'replace' }
  puts "\e[0;1;31mUsing local modules\e[0m"
  exit 1 unless Open3.pipeline(%w[go mod vendor]).first.success?
  cmd += %w[--build-arg GO111MODULE=off]
  exit 1 unless Open3.pipeline(cmd).first.success?
  FileUtils.rm_r 'vendor'
  exit 0
end

exec(*cmd)
