# frozen_string_literal: true

require 'json'
require 'ostruct'
require 'yaml'

def git_root
  `git rev-parse --show-toplevel`.strip
end

def load_manifest
  manifest_path = File.join(git_root, 'build', 'manifest.yaml')
  JSON.parse(YAML.load_file(manifest_path).to_json, object_class: OpenStruct)
end
