if ENV["SKIP_INTEGRATION"]
  STDERR.puts "Skipping integration tests, as SKIP_INTEGRATION has been defined in the environment"
else
  STDERR.puts "Running integration tests. Set SKIP_INTEGRATION=true to skip them."
end

def run_integration_specs?
  ENV["SKIP_INTEGRATION"].nil?
end
