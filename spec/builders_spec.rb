require 'spec_helper'

describe Tradesman::Builders do
  context '#builder_for_method' do
    context 'Create' do
      it 'returns Create class' do
        expect(Tradesman::Builders.builder_for_method(:create, nil)).to eq Tradesman::Builders::Create
      end
    end

    context 'Create with Parent' do
      it 'returns Create class' do
        expect(Tradesman::Builders.builder_for_method(:create, :user)).to eq Tradesman::Builders::CreateForParent
      end
    end

    context 'Update' do
      it 'returns Create class' do
        expect(Tradesman::Builders.builder_for_method(:update, nil)).to eq Tradesman::Builders::Update
      end
    end

    context 'Delete' do
      it 'returns Create class' do
        expect(Tradesman::Builders.builder_for_method(:delete, nil)).to eq Tradesman::Builders::Delete
      end
    end
  end
end
