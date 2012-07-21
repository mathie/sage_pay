def run_integration_specs?
  ENV["VENDOR_NAME"].present?
end

if run_integration_specs?
  STDERR.puts "Running integration tests with vendor name #{ENV["VENDOR_NAME"]}."
else
  STDERR.puts "Skipping integration tests, re-run with VENDOR_NAME set to a simulator account to enable them."
end
