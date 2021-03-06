require 'spec_helper'
require 'compo'

# Mock implementation of a ParentTracker
class MockParentTracker
  include Compo::Mixins::ParentTracker

  # Initialises a MockParentTracker
  #
  # @api  private
  def initialize(parent, id_function)
    update_parent(parent, id_function)
  end
end

RSpec.describe MockParentTracker do
  subject { MockParentTracker.new(parent, id_function) }
  let(:parent) { double(:parent) }
  let(:id_function) { double(:id_function) }

  describe '#parent' do
    it 'returns the current parent' do
      expect(subject.parent).to eq(parent)
    end
  end

  describe '#id' do
    it 'calls the current ID function and returns its result' do
      allow(id_function).to receive(:call).and_return(:id)
      expect(id_function).to receive(:call).once.with(no_args)

      expect(subject.id).to eq(:id)
    end
  end

  describe '#update_parent' do
    let(:new_parent) { double(:new_parent) }
    let(:new_id_function) { double(:new_id_function) }

    it 'sets the parent to the new value' do
      subject.update_parent(new_parent, new_id_function)
      expect(subject.parent).to eq(new_parent)
    end

    it 'sets the ID function to the new ID function' do
      allow(new_id_function).to receive(:call).and_return(:new_id)
      expect(new_id_function).to receive(:call).once

      subject.update_parent(new_parent, new_id_function)
      expect(subject.id).to eq(:new_id)
    end
  end
end
