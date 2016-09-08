require 'spec_helper'
require 'baby_squeel/association'
require 'shared_examples/table'

describe BabySqueel::Association do
  let(:relation)   { BabySqueel::Relation.new(Author) }
  let(:reflection) { Author.reflect_on_association(:posts) }

  subject(:association) {
    BabySqueel::Association.new(relation, reflection)
  }

  it_behaves_like 'a table' do
    let(:table) { association }
  end

  describe '#add_to_tree' do
    def make_tree(tree_node)
      hash = {}
      tree_node.add_to_tree(hash)
      hash.keys.first
    end

    it 'builds a Polyamorous::Join' do
      join = make_tree(association)
      expect(join.name).to eq(:posts)
      expect(join.type).to eq(Arel::Nodes::InnerJoin)
    end

    it 'builds a Polyamorous::Join (for outer)' do
      join = make_tree(association.outer)
      expect(join.name).to eq(:posts)
      expect(join.type).to eq(Arel::Nodes::OuterJoin)
    end
  end

  describe '#_arel' do
    context 'when explicitly joining' do
      let(:condition) { association.author_id == association.author.id }
      let(:assoc)     { association.author.on(condition) }

      it 'resolves to an Arel join node' do
        expect(assoc._arel).to be_an(Arel::Nodes::InnerJoin)
      end

      it 'sets an on clause on the JoinExpression' do
        expect(assoc._on).not_to be_nil
      end

      it 'lets you alias' do
        expect(assoc.alias('fun')._arel.left).to be_an(Arel::Nodes::TableAlias)
      end
    end

    context 'when implicitly joining' do
      context 'when inner joining' do
        it 'resolves to a hash' do
          expect(association._arel).to eq(posts: {})
        end

        it 'throws a fit when an alias is attempted' do
          expect {
            association.alias('naughty')._arel
          }.to raise_error(BabySqueel::AssociationAliasingError)
        end
      end

      context 'when outer joining' do
        it 'resolves to a JoinExpression' do
          expect(association.outer._arel).to be_a(BabySqueel::JoinExpression)
        end

        it 'throws a fit when an alias is attempted' do
          expect {
            association.alias('naughty')._arel
          }.to raise_error(BabySqueel::AssociationAliasingError)
        end
      end
    end
  end
end
