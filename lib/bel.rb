require_relative 'bel/version'
require_relative 'bel/language'
require_relative 'bel/namespace'
require_relative 'bel/util'

require_relative 'bel/extension'
require_relative 'bel/extension_translator'
require_relative 'bel/extension_rdf_repository'
require_relative 'bel/evidence_model'
require_relative 'bel/format'

require_relative 'bel/resource/namespaces'

require_relative 'bel/script'

require_relative 'bel/libbel.rb'
require_relative 'bel/parser'
require_relative 'bel/completion'

include BEL::Language
include BEL::Namespace

#puts BEL::Extension.system.each(:translator).to_a

# vim: ts=2 sw=2:
# encoding: utf-8
