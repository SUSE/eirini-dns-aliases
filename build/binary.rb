# frozen_string_literal: true

require_relative '_build_utils.rb'

manifest = load_manifest
output_path = File.join(manifest.binary.output.directory,
                        manifest.binary.output.name)

version = `git describe --tag --always --long`

exec({ 'GOOS' => 'linux', 'GOARCH' => 'amd64' },
     'go', 'build', "-ldflags=-s -w -X main.appVersion=#{version}",
     '-o', output_path, 'main.go')
