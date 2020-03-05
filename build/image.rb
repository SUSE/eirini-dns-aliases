require "open3"
require_relative "_build_utils.rb"

manifest = load_manifest
base = manifest["image"]["output"]["base"]
repository = manifest["image"]["output"]["repository"]
tag = manifest["image"]["output"]["tag"]
binary_output_directory = manifest["binary"]["output"]["directory"]
binary_output_name = manifest["binary"]["output"]["name"]
binary_path = File.join(binary_output_directory, binary_output_name)

cmd = "docker build --build-arg base='#{base}' --build-arg binary_path='#{binary_path}' --tag '#{repository}:#{tag}' '#{git_root}'"

status = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
  stdout.each_line {|l| STDOUT.puts l }
  stderr.each_line {|l| STDERR.puts l }
  wait_thread.value
end

exit status.success?
