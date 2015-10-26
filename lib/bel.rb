require_relative 'bel/version'
require_relative 'bel/language'
require_relative 'bel/namespace'
require_relative 'bel/util'

require_relative 'bel/extension'
require_relative 'bel/extension_format'
require_relative 'bel/evidence_model'
require_relative 'bel/format'

require_relative 'bel/script'

require_relative 'bel/libbel.rb'
require_relative 'bel/parser'
require_relative 'bel/completion'

include BEL::Language
include BEL::Namespace

BEL::Extension.load_extension(
  'format/bel',       # BEL Script support
  'format/xbel',      # XBEL (XML) support
  'format/rdf/rdf',   # BEL RDF support
  'format/json/json', # JSON Evidence support
  'format/jgf',       # BEL JSON Graph Format support
)

# vim: ts=2 sw=2:
# encoding: utf-8
