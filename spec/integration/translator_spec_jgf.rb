require 'bel'
require 'bel/translator/plugins/jgf/translator'

describe BEL::Translator::Plugins::Jgf::JgfTranslator do
  let(:jgf_translator) do
    BEL.translator(:jgf)
  end

  context 'empty graph' do
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

  context 'graph with only nodes' do
    let(:jgf_file) do
      StringIO.new(<<-JGF)
        {
          "graph": {
            "nodes": [
              {
                "id": "p(HGNC:TP63)",
                "label": "p(HGNC:TP63)"
              }
            ]
          }
        }
      JGF
    end

    it 'translates to one nanopub' do
      nanopubs = jgf_translator.read(jgf_file).to_a
      expect(nanopubs.size).to eql(1)
      expect(nanopubs.first.bel_statement.to_s).to eql("p(HGNC:TP63)")
    end
  end

  context 'graph with nodes and edges' do
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

    it 'graph.metadata.bel_version -> nanopub.metadata.bel_version' do
      nanopubs = jgf_translator.read(jgf_file)

      nanopubs.each do |nanopub|
        expect(nanopub.metadata.bel_version).to eql('2.0')
      end
    end

    it 'translates to one nanopub' do
      expect(jgf_translator.read(jgf_file).to_a.size).to eql(1)
    end
  end

  context 'graph with nodes, edges, and nanopubs' do
    let(:jgf_file) do
      StringIO.new(<<-JGF)
        {
          "graph": {
            "type": "BEL-V1.0",
            "directed": true,
            "metadata": {
              "description": "Test graph using BEL, version 2.0",
              "bel_version": "2.0"
            },
            "nodes": [
              {
                "id": "p(HGNC:CXCL12)",
                "label": "p(HGNC:CXCL12)"
              },
              {
                "id": "act(p(HGNC:RAC1), ma(default:gtp))",
                "label": "act(p(HGNC:RAC1), ma(default:gtp))"
              },
              {
                "id": "bp(MESHPP:Apoptosis)",
                "label": "bp(MESHPP:Apoptosis)"
              },
              {
                "id": "p(HGNC:TLR4)",
                "label": "p(HGNC:TLR4)"
              }
            ],
            "edges": [
              {
                  "source": "p(HGNC:CXCL12)",
                  "relation": "increases",
                  "target": "act(p(HGNC:RAC1), ma(default:gtp))",
                  "directed": true,
                  "label": "p(HGNC:CXCL12) increases act(p(HGNC:RAC1), ma(default:gtp))",
                  "metadata": {
                      "causal": true,
                      "nanopubs": [
                          {
                              "bel_statement": "p(HGNC:CXCL12) increases act(p(HGNC:RAC1), ma(default:gtp))",
                              "support": "Treatment of cells with CXCL12 caused activations of Rac1, Rho, ERK, and c-Jun.",
                              "experiment_context": [
                                {
                                  "name": "Species",
                                  "value": "human",
                                  "uri": "http://www.openbel.org/bel/namespace/ncbi-taxonomy/9606"
                                }
                              ],
                              "citation": {
                                  "type": "Other",
                                  "name": "cxcl12 induces connective tissue growth factor expression in human lung fibroblasts through the rac1/erk, jnk, and ap-1 pathways.",
                                  "id": "25121739"
                              }
                          },
                          {
                              "bel_statement": "p(HGNC:CXCL12) increases act(p(HGNC:RAC1), ma(default:gtp))",
                              "support": "CXCL12 triggers a Gαi2-dependent membrane translocation of ELMO1, which associates with Dock180 to activate small G-proteins Rac1 and Rac2.",
                              "experiment_context": [
                                {
                                  "name": "Species",
                                  "value": "human",
                                  "uri": "http://www.openbel.org/bel/namespace/ncbi-taxonomy/9606"
                                }
                              ],
                              "citation": {
                                  "type": "Other",
                                  "name": "Association between Gαi2 and ELMO1/Dock180 connects chemokine signalling with Rac activation and metastasis.",
                                  "id": "23591873"
                              }
                          },
                          {
                              "bel_statement": "p(HGNC:CXCL12) increases act(p(HGNC:RAC1), ma(default:gtp))",
                              "support": "Treatment of cells with CXCL12 caused activations of Rac1, Rho, ERK, and c-Jun.",
                              "experiment_context": [
                                {
                                  "name": "Species",
                                  "value": "human",
                                  "uri": "http://www.openbel.org/bel/namespace/ncbi-taxonomy/9606"
                                }
                              ],
                              "citation": {
                                  "type": "Other",
                                  "name": "CXCL12 induces connective tissue growth factor expression in human lung fibroblasts through the Rac1/ERK, JNK, and AP-1 pathways.",
                                  "id": "25121739"
                              }
                          }
                      ]
                  }
              },
              {
                  "source": "bp(MESHPP:Apoptosis)",
                  "relation": "positiveCorrelation",
                  "target": "p(HGNC:TLR4)",
                  "directed": true,
                  "label": "bp(MESHPP:Apoptosis) positiveCorrelation p(HGNC:TLR4)",
                  "metadata": {
                      "causal": true,
                      "nanopubs": [
                          {
                              "bel_statement": "bp(MESHPP:Apoptosis) positiveCorrelation p(HGNC:TLR4)",
                              "support": "Toll-like receptors 4 (TLR4) is induced in patients with an advanced stage of chronic obstructive lung disease (COPD) in parallel with increases in apoptosis",
                              "experiment_context": [
                                {
                                  "name": "Species",
                                  "value": "human",
                                  "uri": "http://www.openbel.org/bel/namespace/ncbi-taxonomy/9606"
                                },
                                {
                                  "name": "Disease",
                                  "value": "chronic obstructive pulmonary disease",
                                  "uri": "http://www.openbel.org/bel/namespace/disease-ontology/3083"
                                },
                                {
                                  "name": "Cell",
                                  "value": "type I pneumocyte",
                                  "uri": "http://www.openbel.org/bel/namespace/cell-ontology/0002062"
                                },
                                {
                                  "name": "Uberon",
                                  "value": "lung",
                                  "uri": "http://www.openbel.org/bel/namespace/uberon/0002048"
                                },
                              ],
                              "citation": {
                                  "type": "Other",
                                  "name": "",
                                  "id": "22983353"
                              }
                          },
                          {
                              "bel_statement": "bp(MESHPP:Apoptosis) positiveCorrelation p(HGNC:TLR4)",
                              "support": "Toll-like receptors 4 (TLR4) is induced in patients with an advanced stage of chronic obstructive lung disease (COPD) in parallel with increases in apoptosis.",
                              "experiment_context": [
                                {
                                  "name": "Species",
                                  "value": "human",
                                  "uri": "http://www.openbel.org/bel/namespace/ncbi-taxonomy/9606"
                                },
                                {
                                  "name": "Disease",
                                  "value": "chronic obstructive pulmonary disease",
                                  "uri": "http://www.openbel.org/bel/namespace/disease-ontology/3083"
                                },
                                {
                                  "name": "Cell",
                                  "value": "type I pneumocyte",
                                  "uri": "http://www.openbel.org/bel/namespace/cell-ontology/0002062"
                                },
                                {
                                  "name": "Uberon",
                                  "value": "lung",
                                  "uri": "http://www.openbel.org/bel/namespace/uberon/0002048"
                                },
                              ],
                              "citation": {
                                  "type": "Other",
                                  "name": "",
                                  "id": ""
                              }
                          }
                      ]
                  }
              }
            ]
          }
        }
      JGF
    end

  end
end
# vim: ts=2 sw=2
# encoding: utf-8