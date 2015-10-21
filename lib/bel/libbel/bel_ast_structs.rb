require_relative 'node_traversal'
require_relative 'node_composition'
require_relative 'node_transformation'
require_relative 'node_test'

module BEL
  module LibBEL
    class AstNodeTypeUnion < FFI::Union
      layout(
        :ttype, BEL::LibBEL::BelAstTokenType,
        :vtype, BEL::LibBEL::BelAstValueType
      )

      def token_type
        self[:ttype]
      end

      def value_type
        self[:vtype]
      end
    end

    class BelAstNodeTypeInfo < FFI::Struct
      layout(
        :type,      BEL::LibBEL::BelAstNodeType,
        :union,     AstNodeTypeUnion
      )

      def type
        self[:type]
      end

      def union
        self[:union]
      end
    end

    class BelAstNode < FFI::Union
      include BEL::LibBEL::NodeTraversal
      include BEL::LibBEL::NodeComposition
      include BEL::LibBEL::NodeTransformation
      include BEL::LibBEL::NodeTest

      layout(
        :type_info, BelAstNodeTypeInfo.ptr,
        :token,     :pointer,
        :value,     :pointer
      )

      def type_info
        self[:type_info]
      end

      def type_info=(type_info)
        self[:type_info] = type_info
      end

      def token
        self[:token]
      end

      def token=(token)
        self[:token] = token
      end

      def value
        self[:value]
      end

      def value=(value)
        self[:value] = value
      end

      def to_typed_node
        LibBEL.typed_node(self)
      end

      def to_s
        LibBEL.bel_ast_node_as_string(self)
      end
    end

    class BelAstNodeToken < FFI::Struct
      layout(
        :type,      BEL::LibBEL::BelAstNodeType,
        :ttype,     BEL::LibBEL::BelAstTokenType,
        :left,      BEL::LibBEL::BelAstNode.ptr,
        :right,     BEL::LibBEL::BelAstNode.ptr
      )

      attr_accessor :bel_ast_node

      def type
        self[:type]
      end

      def token_type
        self[:ttype]
      end

      def left
        self[:left]
      end

      def left=(left)
        self[:left] = left
      end

      def right
        self[:right]
      end

      def right=(right)
        self[:right] = right
      end

      def to_s
        LibBEL.bel_ast_node_as_string(@bel_ast_node)
      end
    end

    class BelAstNodeValue < FFI::Struct
      layout(
        :type,      BEL::LibBEL::BelAstNodeType,
        :vtype,     BEL::LibBEL::BelAstValueType,
        :value,     :string
      )

      attr_accessor :bel_ast_node

      def type
        self[:type]
      end

      def value_type
        self[:vtype]
      end

      def value
        self[:value]
      end
    end

    class BelAst < FFI::ManagedStruct
      include BEL::LibBEL::NodeTraversal
      include BEL::LibBEL::NodeComposition
      include BEL::LibBEL::NodeTransformation
      include BEL::LibBEL::NodeTest

      layout(
        :root, BEL::LibBEL::BelAstNode.ptr
      )

      def root
        self[:root]
      end

      def root=(root)
        self[:root] = root
      end

      # overrides {NodeTraversal#each_depth_first}
      def each_depth_first(callable = nil, &block)
        root.each_depth_first(callable, &block)
      end

      # overrides {NodeTraversal#each_breadth_first}
      def each_breadth_first(callable = nil, queue = [], &block)
        root.each_breadth_first(callable, queue, &block)
      end

      def transform(transforms)
        self.send(:transform_tree, transforms, :depth_first)
      end

      def transform!(transforms)
        self.send(:transform_tree!, transforms, :depth_first)
      end

      def transform_tree(transforms, traversal = :depth_first)
        copy_ast = LibBEL.copy_ast(self)
        copy_ast.root.transform_tree(transforms, traversal)
        copy_ast
      end

      def transform_tree!(transforms, traversal = :depth_first)
        self.root.transform_tree!(transforms, traversal)
        self
      end

      def any?(predicates)
        self.root.any_in_tree?(predicates)
      end

      def all?(predicates)
        self.root.all_in_tree?(predicates)
      end

      def self.release(ptr)
        if !ptr.null?
          LibBEL.bel_free_ast(ptr)
        end
      end

      def to_s
        LibBEL.bel_ast_as_string(self)
      end
    end

    private

    def self.typed_node(bel_ast_node)
      if bel_ast_node.type_info.type == :BEL_TOKEN
        token = BelAstNodeToken.new(bel_ast_node.token)
        token.bel_ast_node = bel_ast_node
        token
      else
        value = BelAstNodeValue.new(bel_ast_node.value)
        value.bel_ast_node = bel_ast_node
        value
      end
    end
  end
end
