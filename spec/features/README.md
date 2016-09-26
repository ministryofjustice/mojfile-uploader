The specs in this directory are pseudo-features (or duck-features, if
you like)–they test the full using Rack::Test, but do not rely on the
Capybara features functionality. This is because they need to make
requests using something other than `visit|get`.

They are described using the class names of the underlying classed in
order to ensure that mutation testing can find all of them. If they are
named in a more feature-esq way (i.e. `RSpec.feature 'Add a file'` or
`RSpec.describe 'Add a file'`), then mutant does not use all of them
when killing mutants. See [the explaination of mutant test
selection](https://github.com/mbj/mutant#test-selection) for more
details.
