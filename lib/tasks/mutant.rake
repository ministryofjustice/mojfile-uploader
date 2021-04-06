# frozen_string_literal: true

task :mutant do
  vars = 'NOCOVERAGE=true'
  flags = '--include lib --require moj_file --use rspec --fail-fast'
  raise 'mutation testing failed' unless system("#{vars} mutant run #{flags} MojFile*")
end

task(:default).prerequisites # << task(:mutant)
