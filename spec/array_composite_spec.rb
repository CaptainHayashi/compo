require 'spec_helper'
require 'compo'
require 'array_composite_shared_examples'

RSpec.describe Compo::Composites::Array do
  it_behaves_like 'an array composite'
end
