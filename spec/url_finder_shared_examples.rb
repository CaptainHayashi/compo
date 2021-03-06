require 'compo'

RSpec.shared_examples 'a URL finding' do
  let(:target) { Compo::Branches::Leaf.new }

  context 'when given a nil URL' do
    specify { expect { |b| proc.call(nil, &b) }.to raise_error }
  end

  shared_examples 'a successful finding' do
    it 'returns the correct resource' do
      expect { |b| proc.call(url, &b) }.to yield_with_args(target)
    end
  end

  shared_examples 'an unsuccessful finding' do
    specify do
      expect { |b| proc.call(url, &b) }.to raise_error(
        "Could not find resource: #{url}"
      )
    end
  end

  shared_examples 'an unsuccessful finding with custom error' do
    specify do
      mp = ->(_) { :a }
      expect { |b| proc.call(url, missing_proc: mp,  &b) }
        .to yield_with_args(:a)
    end
  end

  context 'when given a correct root but incorrect URL' do
    context 'using the default missing resource handler' do
      context 'when the URL has a leading slash' do
        it_behaves_like 'an unsuccessful finding' do
          let(:url) { "/#{incorrect_url}" }
        end
      end
      context 'when the URL has a trailing slash' do
        it_behaves_like 'an unsuccessful finding' do
          let(:url) { "#{incorrect_url}/" }
        end
      end
      context 'when the URL has a leading and trailing slash' do
        it_behaves_like 'an unsuccessful finding' do
          let(:url) { "/#{incorrect_url}/" }
        end
      end
      context 'when the URL has neither leading nor trailing slash' do
        it_behaves_like 'an unsuccessful finding' do
          let(:url) { "#{incorrect_url}" }
        end
      end
    end

    context 'using a custom error handler' do
      context 'when the URL has a leading slash' do
        it_behaves_like 'an unsuccessful finding with custom error' do
          let(:url) { "/#{incorrect_url}" }
        end
      end
      context 'when the URL has a trailing slash' do
        it_behaves_like 'an unsuccessful finding with custom error' do
          let(:url) { "#{incorrect_url}/" }
        end
      end
      context 'when the URL has a leading and trailing slash' do
        it_behaves_like 'an unsuccessful finding with custom error' do
          let(:url) { "/#{incorrect_url}/" }
        end
      end
      context 'when the URL has neither leading nor trailing slash' do
        it_behaves_like 'an unsuccessful finding with custom error' do
          let(:url) { "#{incorrect_url}" }
        end
      end
    end
  end

  context 'when given a correct root and URL' do
    context 'when the URL leads to a resource' do
      context 'when the URL has a leading slash' do
        it_behaves_like 'a successful finding' do
          let(:url) { "/#{correct_url}" }
        end
      end
      context 'when the URL has a trailing slash' do
        it_behaves_like 'a successful finding' do
          let(:url) { "#{correct_url}/" }
        end
      end
      context 'when the URL has a leading and trailing slash' do
        it_behaves_like 'a successful finding' do
          let(:url) { "/#{correct_url}/" }
        end
      end
      context 'when the URL has neither leading nor trailing slash' do
        it_behaves_like 'a successful finding' do
          let(:url) { "#{correct_url}" }
        end
      end
    end
  end
end
