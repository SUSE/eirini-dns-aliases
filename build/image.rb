# frozen_string_literal: true

require_relative '_build_utils.rb'

manifest = load_manifest
binary_path = File.join(manifest.binary.output.directory,
                        manifest.binary.output.name)

exec('docker',
     'build',
     '--build-arg',
     "base=#{manifest.image.output.base}",
     '--build-arg',
     "binary_path=#{binary_path}",
     '--tag',
     "#{manifest.image.output.repository}:#{manifest.image.output.tag}",
     git_root)
