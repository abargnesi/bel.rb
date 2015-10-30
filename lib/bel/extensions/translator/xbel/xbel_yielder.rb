require 'bel'
require 'rexml/document'

module BEL::Extension

  module XBEL

    class XBELYielder

      FUNCTIONS = ::BEL::Language::FUNCTIONS

      def initialize(data, options = {})
        @data         = data
      end

      def each
        if block_given?
          header_flag = true

          # yield <document>
          el_document = XBELYielder.document
          yield start_element_string(el_document)

          el_statement_group = nil
          evidence_count = 0
          @data.each { |evidence|
            if header_flag
              # document header
              el_statement_group = XBELYielder.statement_group

              yield element_string(
                XBELYielder.header(evidence.metadata.document_header)
              )
              yield element_string(
                XBELYielder.namespace_definitions(evidence.references.namespaces)
              )
              yield element_string(
                XBELYielder.annotation_definitions(evidence.references.annotations)
              )

              yield start_element_string(el_statement_group)

              header_flag = false
            end

            yield element_string(XBELYielder.evidence(evidence))
            evidence_count += 1
          }

          if evidence_count > 0
            yield end_element_string(el_statement_group)
          else
            # empty head sections; required for XBEL schema

            empty_header = Hash[%w(name description version).map { |element|
              [element, ""]
            }]
            yield element_string(XBELYielder.header(empty_header))
            yield element_string(XBELYielder.namespace_definitions({}))
            yield element_string(XBELYielder.annotation_definitions({}))
            yield element_string(XBELYielder.statement_group)
          end
          yield end_element_string(el_document)
        else
          to_enum(:each)
        end
      end

      def self.evidence(evidence)
        statement    = evidence.bel_statement
        el_statement = REXML::Element.new('bel:statement')

        el_statement.add_element(self.annotation_group(evidence))
        self.statement(statement, el_statement)

        el_statement
      end

      def self.statement(statement, el_statement)
        if statement.relationship
          el_statement.add_attribute 'bel:relationship', statement.relationship
        end

        el_subject = self.subject(statement.subject)
        el_statement.add_element(el_subject)

        if statement.object
          el_object = self.object(statement.object)
          el_statement.add_element(el_object)
        end

        el_statement
      end

      def self.subject(subject)
        el_subject = REXML::Element.new('bel:subject')
        el_subject.add_element(self.term(subject))

        el_subject
      end

      def self.object(object)
        el_object = REXML::Element.new('bel:object')

        case object
        when ::BEL::Model::Term
          el_object.add_element(self.term(object))
        when ::BEL::Model::Statement
          el_statement = REXML::Element.new('bel:statement')
          el_object.add_element(el_statement)
          self.statement(object, el_statement)
        end
        el_object
      end

      def self.term(term)
        el_term    = REXML::Element.new('bel:term')
        term_fx    = term.fx.to_s
        term_fx    = (
                       FUNCTIONS.fetch(term_fx.to_sym, {}).
                                 fetch(:long_form, nil) || term_fx
                     ).to_s

        el_term.add_attribute 'bel:function', term_fx

        term.arguments.each do |arg|
          case arg
          when ::BEL::Model::Term
            el_term.add_element(self.term(arg))
          when ::BEL::Model::Parameter
            el_term.add_element(self.parameter(arg))
          end
        end
        el_term
      end

      def self.parameter(parameter)
        el_parameter      = REXML::Element.new('bel:parameter')
        el_parameter.text = parameter.value
        el_parameter.add_attribute 'bel:ns', parameter.ns
        el_parameter
      end

      def self.annotation_group(evidence)
        el_ag = REXML::Element.new('bel:annotationGroup')

        # XBEL citation
        if evidence.citation && evidence.citation.valid?
          el_ag.add_element(self.citation(evidence.citation))
        end

        # XBEL evidence (::BEL::Model::SummaryText)
        if evidence.summary_text && evidence.summary_text.value
          xbel_evidence      = REXML::Element.new('bel:evidence')
          xbel_evidence.text = evidence.summary_text.value
          el_ag.add_element(xbel_evidence)
        end

        evidence.experiment_context.each do |annotation|
          name, value = annotation.values_at(:name, :value)

          if value.respond_to?(:each)
            value.each do |v|
              el_anno      = REXML::Element.new('bel:annotation')
              el_anno.text = v
              el_anno.add_attribute 'bel:refID', name.to_s

              el_ag.add_element(el_anno)
            end
          else
              el_anno      = REXML::Element.new('bel:annotation')
              el_anno.text = value
              el_anno.add_attribute 'bel:refID', name.to_s

              el_ag.add_element(el_anno)
          end
        end

        metadata_keys = evidence.metadata.keys - [:document_header]
        metadata_keys.each do |k|
          v = evidence.metadata[k]
          if v.respond_to?(:each)
            v.each do |value|
              el_anno      = REXML::Element.new('bel:annotation')
              el_anno.text = value
              el_anno.add_attribute 'bel:refID', k.to_s

              el_ag.add_element(el_anno)
            end
          else
            el_anno      = REXML::Element.new('bel:annotation')
            el_anno.text = v
            el_anno.add_attribute 'bel:refID', k.to_s

            el_ag.add_element(el_anno)
          end
        end

        el_ag
      end

      def self.citation(citation)
        el_citation  = REXML::Element.new('bel:citation')

        if citation.type && !citation.type.to_s.empty?
          el_citation.add_attribute 'bel:type', citation.type
        end

        if citation.id && !citation.id.to_s.empty?
          el_reference      = REXML::Element.new('bel:reference')
          el_reference.text = citation.id
          el_citation.add_element(el_reference)
        end

        if citation.name && !citation.name.to_s.empty?
          el_name         = REXML::Element.new('bel:name')
          el_name.text    = citation.name
          el_citation.add_element(el_name)
        end

        if citation.date && !citation.date.to_s.empty?
          el_date         = REXML::Element.new('bel:date')
          el_date.text    = citation.date
          el_citation.add_element(el_date)
        end

        if citation.comment && !citation.comment.to_s.empty?
          el_comment      = REXML::Element.new('bel:comment')
          el_comment.text = citation.comment
          el_citation.add_element(el_comment)
        end

        if citation.authors && !citation.authors.to_s.empty?
          el_author_group = REXML::Element.new('bel:authorGroup')
          citation.authors.each do |author|
            el_author      = REXML::Element.new('bel:author')
            el_author.text = author
            el_author_group.add_element(el_author)
          end
          el_citation.add_element(el_author_group)
        end

        el_citation
      end

      def self.document
        el = REXML::Element.new('bel:document')
        el.add_namespace('bel', 'http://belframework.org/schema/1.0/xbel')
        el.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        el.add_attribute('xsi:schemaLocation', 'http://belframework.org/schema/1.0/xbel http://resource.belframework.org/belframework/1.0/schema/xbel.xsd')

        el
      end

      def self.statement_group(declare_namespaces = false)
        el = REXML::Element.new('bel:statementGroup')

        if declare_namespaces
          el.add_namespace('bel', 'http://belframework.org/schema/1.0/xbel')
          el.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          el.add_attribute('xsi:schemaLocation', 'http://belframework.org/schema/1.0/xbel http://resource.belframework.org/belframework/1.0/schema/xbel.xsd')
        end

        el
      end

      def self.header(hash)
        el_header = REXML::Element.new('bel:header')

        # normalize hash keys
        hash = Hash[
          hash.map { |k, v|
            k = k.to_s.dup
            k.downcase!
            k.gsub!(/[-_ .]/, '')
            [k, v]
          }
        ]

        (%w(name description version copyright) & hash.keys).each do |field|
          el      = REXML::Element.new("bel:#{field}")
          el.text = hash[field]
          el_header.add_element(el)
        end

        # add contactinfo with different element name (contactInfo)
        if hash.has_key?('contactinfo')
          el      = REXML::Element.new('bel:contactInfo')
          el.text = hash['contactinfo']
          el_header.add_element(el)
        end

        # handle grouping for authors and licenses
        if hash.has_key?('authors')
          authors  = hash['authors']
          el_group = REXML::Element.new('bel:authorGroup')

          [authors].flatten.each do |author|
            el      = REXML::Element.new('bel:author')
            el.text = author.to_s
            el_group.add_element(el)
          end
          el_header.add_element(el_group)
        end
        if hash.has_key?('licenses')
          licenses = hash['licenses']
          el_group = REXML::Element.new('bel:licenseGroup')

          [licenses].flatten.each do |license|
            el      = REXML::Element.new('bel:license')
            el.text = license.to_s
            el_group.add_element(el)
          end
          el_header.add_element(el_group)
        end

        el_header
      end

      def self.namespace_definitions(hash)
        el_nd = REXML::Element.new('bel:namespaceGroup')
        hash.each do |k, v|
          el               = REXML::Element.new('bel:namespace')
          el.add_attribute 'bel:prefix', k.to_s

          resourceLocation = v.respond_to?(:url) ? v.url : v
          el.add_attribute 'bel:resourceLocation', "#{resourceLocation}"

          el_nd.add_element(el)
        end

        el_nd
      end

      def self.annotation_definitions(hash)
        el_ad = REXML::Element.new('bel:annotationDefinitionGroup')
        internal = []
        external = []
        hash.each do |k, v|
          type, domain = v.values_at(:type, :domain)
          case type.to_sym
          when :url
            el = REXML::Element.new('bel:externalAnnotationDefinition')
            el.add_attribute 'bel:url', domain.to_s
            el.add_attribute 'bel:id',  k.to_s
            external << el
          when :pattern
            el = REXML::Element.new('bel:internalAnnotationDefinition')
            el.add_attribute 'bel:id', k.to_s
            el.add_element(REXML::Element.new('bel:description'))
            el.add_element(REXML::Element.new('bel:usage'))

            el_pattern      = REXML::Element.new('bel:patternAnnotation')
            el_pattern.text =
              domain.respond_to?(:source) ? domain.source : domain.to_s

            el.add_element(el_pattern)
            internal << el
          when :list
            el = REXML::Element.new('bel:internalAnnotationDefinition')
            el.add_attribute 'bel:id', k.to_s
            el.add_element(REXML::Element.new('bel:description'))
            el.add_element(REXML::Element.new('bel:usage'))

            el_list = REXML::Element.new('bel:listAnnotation')
            if domain.respond_to?(:each)
              domain.each do |value|
                el_list_value      = REXML::Element.new('bel:listValue')
                el_list_value.text = value.to_s
                el_list.add_element(el_list_value)
              end
            else
              el_list_value      = REXML::Element.new('bel:listValue')
              el_list_value.text = domain.to_s
              el_list.add_element(el_list_value)
            end

            el.add_element(el_list)
            internal << el
          else
            el = nil
          end
        end

        # first add internal annotation definitions
        internal.each do |internal_element|
          el_ad.add_element(internal_element)
        end

        # second add external annotation definitions
        external.each do |external_element|
          el_ad.add_element(external_element)
        end

        el_ad
      end

      def start_element_string(element)
        element.to_s.gsub(%r{(/>)}, '>')
      end
      private :start_element_string

      def end_element_string(element)
        "</#{element.expanded_name}>"
      end
      private :end_element_string

      def element_string(element)
        element.to_s
      end
      private :element_string
    end
  end
end
