# frozen_string_literal: true

require '/Users/alex/src/github.com/rubocop/rubocop-performance/lib/rubocop/cop/performance/fast_block_given.rb'

# TODO: Check all these cases still work in class methods

RSpec.describe RuboCop::Cop::Performance::FastBlockGiven, :config do
  context 'when a block is checked via block_given?' do
    context 'when EnforcedStyle is check_if_block_given' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_given', 'AutoCorrect' => true } }

      it 'does not register an offense in an instance method' do
        expect_no_offenses(<<~RUBY)
          def method(x, &block)
            do_something if block_given?
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_defined_yield' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_defined_yield', 'AutoCorrect' => true } }

      it 'registers an offense and corrects in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if block_given?
                            ^^^^^^^^^^^^ Check `defined?(yield)` instead of using `block_given?`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if defined?(yield)
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_block_truthy' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_truthy', 'AutoCorrect' => true } }

      # TODO: Check that this is only applied if the block isn't reassigned
      # TODO: Check that this is only applied if the method has an explicit block arg

      it 'registers an offense and corrects in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if block_given?
                            ^^^^^^^^^^^^ Check `block`'s truthiness instead of using `block_given?`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if block
          end
        RUBY
      end
    end
  end

  context 'when a block is checked via defined?(yield)' do
    context 'when EnforcedStyle is check_if_block_given' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_given', 'AutoCorrect' => true } }

      it 'registers an offense and corrects when using `defined?(yield)` in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if defined?(yield)
                            ^^^^^^^^^^^^^^^ Check `block_given?` instead of using `defined?(yield)`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if block_given?
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_defined_yield' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_defined_yield', 'AutoCorrect' => true } }

      it 'does not register an offense in an instance method' do
        expect_no_offenses(<<~RUBY)
          def method(x, &block)
            do_something if defined?(yield)
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_block_truthy' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_truthy', 'AutoCorrect' => true } }

      # TODO: Check that this is only applied if the block isn't reassigned
      # TODO: Check that this is only applied if the method has an explicit block arg

      it 'registers an offense and corrects in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if defined?(yield)
                            ^^^^^^^^^^^^^^^ Check `block`'s truthiness instead of using `defined?(yield)`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if block
          end
        RUBY
      end
    end
  end

  context 'when a block is checked via its truthiness' do
    context 'when EnforcedStyle is check_if_block_given' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_given', 'AutoCorrect' => true } }

      it 'registers an offense and corrects in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if block
                            ^^^^^ Check `block_given?` instead of checking the `block`'s truthiness.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if block_given?
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_defined_yield' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_defined_yield', 'AutoCorrect' => true } }

      it 'registers an offense and corrects in an instance method' do
        expect_offense(<<~RUBY)
          def method(x, &block)
            do_something if block
                            ^^^^^ Check `defined?(yield)` instead of checking the `block`'s truthiness.
          end
        RUBY

        expect_correction(<<~RUBY)
          def method(x, &block)
            do_something if defined?(yield)
          end
        RUBY
      end
    end

    context 'when EnforcedStyle is check_if_block_truthy' do
      let(:cop_config) { { 'EnforcedStyle' => 'check_if_block_truthy', 'AutoCorrect' => true } }

      # TODO: Check that this is only applied if the block isn't reassigned
      # TODO: Check that this is only applied if the method has an explicit block arg

      it 'does not register an offense in an instance method' do
        expect_no_offenses(<<~RUBY)
          def method(x, &block)
            do_something if block
          end
        RUBY
      end
    end
  end
end
