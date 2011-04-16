def run(cmd)
  puts cmd
  system(cmd)
end

def spec(file)
  if File.exists?(file)
    run("rspec #{file}")
  else
    puts("Spec: #{file} does not exist.")
  end
end

def run_all_specs
  run "rake spec"
end

def run_suite
  system "clear"
  run_all_specs
end

watch("spec/.*/*_spec\.rb") do |match|
  puts(match[0])
  spec(match[0])
end

watch("lib/(.*/.*)\.rb") do |match|
  puts(match[1])
  spec("spec/#{match[1]}_spec.rb")
end

# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_suite
end

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
    @interrupted = false
  end
end
