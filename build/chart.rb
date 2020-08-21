# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'yaml'
require_relative '_build_utils.rb'

PROJECT = 'eirini-dns-aliases'
SRC_DIR = "deploy/helm/#{PROJECT}"

manifest = load_manifest

Dir.mktmpdir("#{PROJECT}-helm-") do |dir|
  # Make a temporary copy and edit the values.yaml
  FileUtils.cp_r(SRC_DIR, dir, verbose: true)

  # Ensure the image repository / tag is what we built
  values = YAML.load_file File.join(SRC_DIR, 'values.yaml')
  values['image']['repository'] = ENV['DOCKER_REPOSITORY'] || manifest.image.repository
  values['image']['tag'] = ENV['DOCKER_TAG'] || manifest.image.tag
  File.open(File.join(dir, PROJECT, 'values.yaml'), 'w') do |values_file|
    YAML.dump(values, values_file)
  end

  cmd = [
    'helm', 'package', File.join(dir, PROJECT),
    '--destination', manifest.binary.output.directory
  ]

  # Update versions, if applicable
  cmd += ['--app-version', ENV['HELM_APP_VERSION']] if ENV['HELM_APP_VERSION']
  cmd += ['--version', ENV['HELM_VERSION']] if ENV['HELM_VERSION']

  exec(*cmd)
end
