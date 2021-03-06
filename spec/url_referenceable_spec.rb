require 'spec_helper'
require 'compo'
require 'url_referenceable_shared_examples'

# Mock implementation of UrlReferenceable.
class MockUrlReferenceable
  include Compo::Mixins::UrlReferenceable
end

RSpec.describe MockUrlReferenceable do
  it_behaves_like 'a URL referenceable object'
end
