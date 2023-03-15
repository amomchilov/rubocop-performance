# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Identifies unnecessary use of a `block_given?` where explicit check
      # of block argument would suffice.
      #
      # @example
      #   # bad
      #   def method(&block)
      #     do_something if block_given?
      #   end
      #
      #   # good
      #   def method(&block)
      #     do_something if block
      #   end
      #
      #   # good - block is reassigned
      #   def method(&block)
      #     block ||= -> { do_something }
      #     warn "Using default ..." unless block_given?
      #     # ...
      #   end
      #
      class FastBlockGiven < Base
        extend AutoCorrector

        RESTRICT_ON_SEND = %i[block_given?].freeze
        MSG = 'Check `defined?(yield)` instead of using `block_given?`.'

        def_node_matcher :reassigns_block_arg?, '`(lvasgn %1 ...)'

        def on_send(node)
          def_node = node.each_ancestor(:def, :defs).first
          return unless def_node # Only apply these corrections inside methods.

          case cop_config['EnforcedStyle']
          when 'check_if_block_truthy'
            block_arg_name = extract_explicit_block_param_name(def_node)

            # Block truthiness can only be checked when an explicit block param is given,
            # but other styles are possible even with an implicit block param.
            return unless block_arg_name

            return if reassigns_block_arg?(def_node, block_arg_name)

            add_offense(node, message:  "Check `#{block_arg_name}`'s truthiness instead of using `block_given?`.") do |corrector|
              corrector.replace(node, block_arg_name)
            end
          when 'check_if_block_given'
            return # No offense
          when 'check_if_defined_yield'
            add_offense(node) do |corrector|
              corrector.replace(node, 'defined?(yield)')
            end
          else raise "Unknown EnforcedStyle selected (#{cop_config['EnforcedStyle'].inspect})!"
          end
        end

        def on_defined?(node)
          def_node = node.each_ancestor(:def, :defs).first
          return unless def_node # Only apply these corrections inside methods.

          case cop_config['EnforcedStyle']
          when 'check_if_block_truthy'
            block_arg_name = extract_explicit_block_param_name(def_node)

            # Block truthiness can only be checked when an explicit block param is given,
            # but other styles are possible even with an implicit block param.
            return unless block_arg_name

            return if reassigns_block_arg?(def_node, block_arg_name)

            add_offense(node, message: "Check `#{block_arg_name}`'s truthiness instead of using `defined?(yield)`.") do |corrector|
              corrector.replace(node, block_arg_name)
            end
          when 'check_if_block_given'
            add_offense(node, message: 'Check `block_given?` instead of using `defined?(yield)`.') do |corrector|
              corrector.replace(node, 'block_given?')
            end
          when 'check_if_defined_yield'
            return # No offense
          else raise "Unknown EnforcedStyle selected (#{cop_config['EnforcedStyle'].inspect})!"
          end
        end

        private

        def extract_explicit_block_param_name(def_node)
          block_arg = def_node.arguments.find(&:blockarg_type?)
          return nil unless block_arg
          block_arg.children.first
        end
      end
    end
  end
end
