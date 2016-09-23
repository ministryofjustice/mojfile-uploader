# frozen_string_literal: true
task :mutant do
  vars = 'NOCOVERAGE=true'
  flags = '--include lib --use rspec --fail-fast'
  unless system("#{vars} mutant #{flags} MojFile*")
    raise 'mutation testing failed'
  end
end

task(:default).prerequisites << task(:mutant)
