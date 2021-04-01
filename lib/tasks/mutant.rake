# frozen_string_literal: true

task :mutant do
  vars = 'NOCOVERAGE=true'
  flags = '--include lib --use rspec --fail-fast'
  raise 'mutation testing failed' unless system("#{vars} mutant #{flags} MojFile*")
end

task(:default).prerequisites << task(:mutant)
