require "yaml"

def git_root()
  `git rev-parse --show-toplevel`.strip!
end

def load_manifest()
  File.open(File.join(git_root, "build", "manifest.yaml")) { |f| YAML.load(f) }
end
