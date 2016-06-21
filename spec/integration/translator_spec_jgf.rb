require 'bel'
require 'bel/translator/plugins/jgf/translator'

describe BEL::Translator::Plugins::Jgf::JgfTranslator do
  let(:jgf_translator) do
    BEL.translator(:jgf)
  end

  context 'Empty graph' do
    let(:jgf_file) do
      StringIO.new(<<-JGF)
        {
          "graph": {}
        }
      JGF
    end

    it 'translates to zero nanopubs' do
      nanopubs = jgf_translator.read(jgf_file).to_a
      expect(nanopubs).to be_empty
    end
  end

  context 'Node/Edge graph' do
    let(:jgf_file) do
      StringIO.new(<<-JGF)
        {
          "graph": {
            "type": "BEL-V1.0",
            "metadata": {
              "description": "Test graph using BEL, version 2.0",
              "bel_version": "2.0"
            },
            "nodes": [
              {
                "id": "p(HGNC:TP63)",
                "label": "p(HGNC:TP63)"
              },
              {
                "id": "bp(GOBP:\\"apoptotic process\\")",
                "label": "bp(GOBP:\\"apoptotic process\\")"
              }
            ],
            "edges": [
              {
                "source": "p(HGNC:TP63)",
                "relation": "decreases",
                "target": "bp(GOBP:\\"apoptotic process\\")"
              }
            ]
          }
        }
      JGF
    end

    it 'Preserves graph.metadata.bel_version in each nanopub' do
      nanopubs = jgf_translator.read(jgf_file)

      nanopubs.each do |nanopub|
        expect(nanopub.metadata.bel_version).to eql('2.0')
      end
    end
  end
end
# vim: ts=2 sw=2
# encoding: utf-8
