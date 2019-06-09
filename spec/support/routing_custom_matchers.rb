# frozen_string_literal: true

#
# = CustomMatchers
#
#   - version:  1.00.001
#   - author:   Steve A.
#
#   Support/container module for RSpec custom matchers.
module CustomMatchers
  # RSpec support module for defining additional Routing custom matchers.
  module Routing
    # Helper to check named routes existance.
    #
    # === Sample usage:
    #
    #   describe '#about'
    #     it { should have_named_route :root_about, '/about' }
    #     it { should route(:get, '/about').to :action => 'about' }
    #   end
    #
    def have_named_route(name, *args)
      HaveNamedRoute.new(self, name, *args)
    end
    #-- -----------------------------------------------------------------------
    #++

    # == Custom matcher implementation for named routes.
    #
    class HaveNamedRoute

      def initialize(context, name, *args)
        @context = context
        @name = name
        @path = "#{name}_path"
        @args = args
        raise ArgumentError, 'The last argument must be the expected uri' unless args.last

        @expected_uri = args.pop
      end
      #-- ---------------------------------------------------------------------
      #++

      # @override
      def description
        "have a route named #{@name}, where e.g. #{example_call} == #{@expected_uri}"
      end

      # @override
      def matches?(_subject)
        @actual_uri = @context.send("#{@name}_path", *@args)
        @actual_uri == @expected_uri
      end

      # @override
      def failure_message_for_should
        "expected #{example_call} to equal #{@expected_uri}, but got #{@actual_uri}"
      end

      # @override
      def failure_message_for_should_not
        "expected #{example_call} to not equal #{@expected_uri}, but it did"
      end

      # Expectation result
      def example_call
        call = "#{@name}_path"
        call << "(#{@args.map(&:to_s).join(', ')})" unless @args.empty?
        call
      end

    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
