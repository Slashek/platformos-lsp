# frozen_string_literal: true

module PlatformosCheck
  module Tags
    class Graphql < Base
      QUERY_NAME_SYNTAX = /(#{Liquid::VariableSignature}+)\s*=\s*(.*)\s*/om
      INLINE_SYNTAX = /(#{Liquid::QuotedFragment}+)(\s*(#{Liquid::QuotedFragment}+))?/o
      CLOSE_TAG_SYNTAX = /\A(.*)(?-mix:\{%-?)\s*(\w+)\s*(.*)?(?-mix:%\})\z/m # based on Liquid::Raw::FullTokenPossiblyInvalid

      attr_reader :to, :from, :inline_query, :value_expr, :partial_name

      def initialize(tag_name, markup, options)
        if markup =~ QUERY_NAME_SYNTAX
          super
          @to = Regexp.last_match(1)
          @inline_query = false

          # inline query looks like this:
          # {% graph res = "my_query", id: "1" | dig: 'my_query' %}
          # we want to first process "my_query, id: "1" , store it in "res" and then process
          # it with filters like this:
          # res | dig: 'my_query'
          after_assign_markup = Regexp.last_match(2).split('|')
          parse_markup(tag_name, after_assign_markup.shift)
          after_assign_markup.unshift(@to)
          @partial_name = value_expr
          @from = Liquid::Variable.new(after_assign_markup.join('|'), options)
        elsif INLINE_SYNTAX.match?(markup)
          @inline_query = true
          parse_markup(tag_name, markup)
          @to = @value_expr.name
        else
          raise Liquid::SyntaxError, 'Invalid syntax for graphql tag'
        end
        super
      end

      def parse(tokens)
        return super unless @inline_query

        @body = +''
        while (token = tokens.send(:shift))
          if token =~ CLOSE_TAG_SYNTAX && block_delimiter == Regexp.last_match(2)
            @body << Regexp.last_match(1) if Regexp.last_match(1) != ''
            return
          end
          @body << token unless token.empty?
        end

        raise Liquid::SyntaxError, parse_context.locale.t('errors.syntax.tag_never_closed', block_name:)
      end

      def block_name
        @tag_name
      end

      def block_delimiter
        @block_delimiter = "end#{block_name}"
      end

      class ParseTreeVisitor < Liquid::ParseTreeVisitor
        def children
          [
            @node.to
          ].compact + @node.attributes_expr.values
        end
      end
    end
  end
end