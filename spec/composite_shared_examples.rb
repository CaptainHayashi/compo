require 'compo'

RSpec.shared_examples 'a removal of a child from its parent' do
  it 'calls #update_parent on the child with a Parentless' do
    expect(child).to receive(:update_parent).once do |parent, _|
      expect(parent).to be_a(Compo::Composites::Parentless)
    end
    op.call
  end

  it 'calls #update_parent on the child with a nil-returning ID proc' do
    expect(child).to receive(:update_parent).once do |_, idp|
      expect(idp.call).to be_nil
    end
    op.call
  end
end

RSpec.shared_examples 'a composite' do
  let(:id) { double(:id) }
  let(:child) { double(:child) }

  describe '#each' do
    it 'delegates to the #each implementation of the hash from #children' do
      children = double(:children)

      allow(subject).to receive(:children).and_return(children)
      expect(subject).to receive(:children).once.with(no_args)
      expect(children).to receive(:each).once

      subject.each
    end
  end

  describe '#on_node' do
    it 'calls the block given with the subject' do
      expect { |block| subject.on_node(&block) }.to yield_with_args(subject)
    end

    it 'returns the result of the block' do
      expect(subject.on_node { |subject| subject }).to eq(subject)
      expect(subject.on_node { 3 }).to eq(3)
    end
  end

  describe '#add' do
    let(:idf) { double(:id_function) }
    before(:each) { allow(subject).to receive(:add!) }

    context 'when #add! returns nil' do
      before(:each) { allow(subject).to receive(:add!).and_return(nil) }

      specify { expect(subject.add(id, child)).to be_nil }

      it 'calls #add! with the ID and child given' do
        expect(subject).to receive(:add!).once.with(id, child)
        subject.add(id, child)
      end
    end

    context 'when #add! returns the child' do
      before(:each) do
        allow(subject).to receive_messages(add!: child, id_function: nil)
        allow(child).to receive(:update_parent)
      end

      it 'calls #add! with the ID and child given' do
        subject.add(id, child)
        expect(subject).to have_received(:add!).once.with(id, child)
      end

      it 'calls #id_function with the child given' do
        subject.add(id, child)
        expect(subject).to have_received(:id_function).once.with(child)
      end

      it 'calls #update_parent on the child with the parent and ID function' do
        allow(subject).to receive(:id_function).and_return(idf)
        subject.add(id, child)
        expect(child).to have_received(:update_parent).once.with(subject, idf)
      end

      it 'returns the given child' do
        expect(subject.add(id, child)).to eq(child)
      end
    end
  end

  describe '#get_child' do
    let(:child) { double(:child) }

    before(:each) do
      allow(subject).to receive(:children).and_return(in_children: child)
    end

    context 'when the argument is in #children' do
      it 'returns the child' do
        expect(subject.get_child(:in_children)).to eq(child)
      end
    end

    context 'when the argument is not in #children' do
      specify { expect(subject.get_child(:not_in_children)).to be_nil }
    end
  end
end

RSpec.shared_examples 'a composite with default #remove!' do
  let(:child) { double(:child) }
  let(:id) { double(:id) }

  describe '#remove' do
    context 'when #remove! is defined' do
      before(:each) do
        allow(subject).to receive(:remove!).and_return(remove_result)
      end

      context 'when #remove! returns nil' do
        let(:remove_result) { nil }

        specify { expect(subject.remove(child)).to be_nil }

        it 'calls #remove! with the child given' do
          expect(subject).to receive(:remove!).once.with(child)
          subject.remove(child)
        end
      end

      context 'when #remove! returns the child' do
        let(:remove_result) { child }
        before(:each)       { allow(child).to receive(:update_parent) }

        it 'calls #remove! with the child given' do
          expect(subject).to receive(:remove!).once.with(child)
          subject.remove(child)
        end

        it_behaves_like 'a removal of a child from its parent' do
          let(:op) { -> { subject.remove(child) } }
        end

        it 'returns the given child' do
          expect(subject.remove(child)).to eq(child)
        end
      end
    end

    context 'when #remove_id! is defined but #remove! is not' do
      before(:each) do
        allow(subject).to receive_messages(remove_id!: remove_id_result,
                                           children:   { id => child })
      end

      context 'when #remove_id! returns nil' do
        let(:remove_id_result) { nil }

        specify { expect(subject.remove(child)).to be_nil }

        it 'calls #remove! with the child given' do
          # Note: #remove! is not a stub, so we must use this form of
          # expectation.
          expect(subject).to receive(:remove!).once.with(child)
          subject.remove(child)
        end

        it 'calls #remove_id! with the ID of the child' do
          subject.remove(child)
          expect(subject).to have_received(:remove_id!).once.with(id)
        end

        it 'calls #children' do
          subject.remove(child)
          expect(subject).to have_received(:children).once
        end
      end

      context 'when #remove_id! returns the child' do
        let(:remove_id_result) { child }
        before(:each)          { allow(child).to receive(:update_parent) }

        it 'calls #remove! with the child given' do
          # Note: #remove! is not a stub, so we must use this form of
          # expectation.
          expect(subject).to receive(:remove!).once.with(child)
          subject.remove(child)
        end

        it_behaves_like 'a removal of a child from its parent' do
          let(:op) { -> { subject.remove(child) } }
        end

        it 'returns the given child' do
          expect(subject.remove(child)).to eq(child)
        end
      end
    end
  end
end

RSpec.shared_examples 'a composite with default #remove_id!' do
  let(:child) { double(:child) }
  let(:id)    { double(:id) }

  describe '#remove_id' do
    context 'when #remove_id! is defined' do
      before(:each) do
        allow(subject).to receive(:remove_id!).and_return(remove_id_result)
      end

      context 'and #remove_id! returns nil' do
        let(:remove_id_result) { nil }

        specify { expect(subject.remove_id(id)).to be_nil }

        it 'calls #remove_id! with the ID given' do
          subject.remove_id(id)
          expect(subject).to have_received(:remove_id!).once.with(id)
        end
      end

      context 'and #remove_id! returns the child' do
        let(:remove_id_result) { child }
        before(:each)          { allow(child).to receive(:update_parent) }

        it 'calls #remove_id! with the ID given' do
          subject.remove_id(id)
          expect(subject).to have_received(:remove_id!).once.with(id)
        end

        it_behaves_like 'a removal of a child from its parent' do
          let(:op) { -> { subject.remove_id(id) } }
        end

        it 'returns the child' do
          expect(subject.remove_id(id)).to eq(child)
        end
      end
    end

    context 'when #remove! is defined but #remove_id! is not' do
      before(:each) do
        allow(subject).to receive(:remove!).and_return(remove_result)
      end

      context 'and #remove! returns nil' do
        let(:remove_result) { nil }
        before(:each) do
          allow(subject).to receive(:get_child).and_return(child)
        end

        specify { expect(subject.remove_id(id)).to be_nil }

        it 'calls #remove_id! with the ID given' do
          # Note: #remove_id! is not a stub, so we must use this form of
          # expectation.
          expect(subject).to receive(:remove_id!).once.with(id)
          subject.remove_id(id)
        end

        it 'calls #get_child with the ID given' do
          subject.remove_id(id)
          expect(subject).to have_received(:get_child).once.with(id)
        end

        it 'calls #remove! with the child given' do
          subject.remove_id(id)
          expect(subject).to have_received(:remove!).once.with(child)
        end
      end

      context 'and #remove! returns the child' do
        let(:remove_result) { child }
        before(:each) do
          allow(subject).to receive(:get_child).and_return(child)
          allow(child).to receive(:update_parent)
        end

        it 'calls #remove_id! with the ID given' do
          # Note: #remove_id! is not a stub, so we must use this form of
          # expectation.
          expect(subject).to receive(:remove_id!).once.with(id)
          subject.remove_id(id)
        end

        it 'calls #remove! with the child given' do
          subject.remove_id(id)
          expect(subject).to have_received(:remove!).once.with(child)
        end

        it_behaves_like 'a removal of a child from its parent' do
          let(:op) { -> { subject.remove_id(id) } }
        end

        it 'returns the given child' do
          expect(subject.remove_id(id)).to eq(child)
        end
      end
    end
  end
end
