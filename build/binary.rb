require "open3"
require_relative "_build_utils.rb"

manifest = load_manifest
output_directory = manifest["binary"]["output"]["directory"]
output_name = manifest["binary"]["output"]["name"]

cmd = "go build -ldflags='-s -w' -o #{File.join(output_directory, output_name)} main.go"

env = {
  "GOOS" => "linux",
  "GOARCH" => "amd64",
}

status = Open3.popen3(env, cmd) do |stdin, stdout, stderr, wait_thread|
  stdout.each_line {|l| STDOUT.puts l }
  stderr.each_line {|l| STDERR.puts l }
  wait_thread.value
end

exit status.success?
