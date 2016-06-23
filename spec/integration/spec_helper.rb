# Convenience function to create a {BEL::Nanopub::Nanopub nanopub}
# for test usage.
def make_nanopub(bel_statement, bel_version)
  nanopub                      = BEL::Nanopub::Nanopub.new
  nanopub.references.add_namespace(
    'HGNC',
    :url,
    'http://resource.belframework.org/belframework/20150611/namespace/hgnc-human-genes.belns')

  nanopub.bel_statement        = bel_statement
  nanopub.citation             =
    BEL::Nanopub::Citation.new('PubMed', 'LsJournal', '101101')
  nanopub.support              =
    BEL::Nanopub::Support.new('Quotation example taken from citation')
  nanopub.metadata.bel_version = bel_version
  nanopub
end
