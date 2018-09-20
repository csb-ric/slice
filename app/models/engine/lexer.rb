# frozen_string_literal: true

module Engine
  class Lexer
    attr_accessor :tokens

    def initialize(verbose: false)
      @tokens = []
      @mode = :single
      @buffer = []
      @verbose = verbose
    end

    # Return list of tokens.
    def lexer(input)
      puts input if @verbose
      input.split("").each do |letter|
        case @mode
        when :single
          single_mode(letter)
        when :word
          word_mode(letter)
        when :number
          number_mode(letter)
        when :decimal
          decimal_mode(letter)
        when :operator
          operator_mode(letter)
        end
      end

      evaluate_buffer # Handle any letters that may still be in buffer
      puts "\n" if @verbose
    end

    private

    def single_mode(letter)
      case letter
      when /[!=<>]/
        @mode = :operator
        @buffer << letter
        print letter.yellow.bold if @verbose
      when "("
        @tokens << ::Engine::Token.new(:left_paren)
        print letter.white.bold if @verbose
      when ")"
        @tokens << ::Engine::Token.new(:right_paren)
        print letter.white.bold if @verbose
      when "-"
        @tokens << ::Engine::Token.new(:minus)
        print letter.yellow.bold if @verbose
      when "+"
        @tokens << ::Engine::Token.new(:plus)
        print letter.yellow.bold if @verbose
      when "*"
        @tokens << ::Engine::Token.new(:star)
        print letter.yellow.bold if @verbose
      when "/"
        @tokens << ::Engine::Token.new(:slash)
        print letter.yellow.bold if @verbose
      when "^"
        @tokens << ::Engine::Token.new(:power)
        print letter.yellow.bold if @verbose
      when "@"
        @tokens << ::Engine::Token.new(:at)
        print letter.yellow.bold if @verbose
      when /[a-z]/i
        @mode = :word
        @buffer << letter
        print letter.blue.bg_gray if @verbose
      when /\./
        @mode = :decimal
        @buffer << letter
        print letter.green if @verbose
      when /[\d]/
        @mode = :number
        @buffer << letter
        print letter.green if @verbose
      else
        print letter.bg_black if @verbose
      end
    end

    def word_mode(letter)
      case letter
      when /[a-z0-9\_\-]/i
        @buffer << letter
        print letter.blue.bg_gray if @verbose
      else
        reserved_word_or_identifier(@buffer.join)
        @buffer = []
        @mode = :single
        single_mode(letter)
      end
    end

    def reserved_word_or_identifier(word)
      case word
      when "is"
        @tokens << ::Engine::Token.new(:equal, raw: word)
      when "between"
        @tokens << ::Engine::Token.new(:between, raw: word)
      when "and"
        @tokens << ::Engine::Token.new(:and, raw: word)
      when "or"
        @tokens << ::Engine::Token.new(:or, raw: word)
      when "xor"
        @tokens << ::Engine::Token.new(:xor, raw: word)
      when "at"
        @tokens << ::Engine::Token.new(:at, raw: word)
      when "true"
        @tokens << ::Engine::Token.new(:true, raw: word)
      when "false"
        @tokens << ::Engine::Token.new(:false, raw: word)
      when "nil", "null"
        @tokens << ::Engine::Token.new(:nil, raw: word)
      else
        @tokens << ::Engine::Token.new(:identifier, raw: word)
      end
    end

    def number_mode(letter)
      case letter
      when /\d/
        @buffer << letter
        print letter.green if @verbose
      when /\./
        @buffer << letter
        print letter.green if @verbose
        @mode = :decimal
      else
        word = @buffer.join
        @tokens << ::Engine::Token.new(:number, raw: Integer(word))
        @buffer = []
        @mode = :single
        single_mode(letter)
      end
    end

    def decimal_mode(letter)
      case letter
      when /\d/
        @buffer << letter
        print letter.green if @verbose
      else
        word = @buffer.join
        @tokens << ::Engine::Token.new(:number, raw: Float(word))
        @buffer = []
        @mode = :single
        single_mode(letter)
      end
    end

    # @tokens << ::Engine::Token.new(:operator, raw: letter)
    def operator_mode(letter)
      case letter
      when "="
        @buffer << letter
        print letter.yellow.bold if @verbose
      end

      word = @buffer.join
      case word
      when "!="
        @tokens << ::Engine::Token.new(:bang_equal, raw: word)
      when ">="
        @tokens << ::Engine::Token.new(:greater_equal, raw: word)
      when "<="
        @tokens << ::Engine::Token.new(:less_equal, raw: word)
      when "==", "="
        @tokens << ::Engine::Token.new(:equal, raw: word)
      when ">"
        @tokens << ::Engine::Token.new(:greater, raw: word)
      when "<"
        @tokens << ::Engine::Token.new(:less, raw: word)
      else
        print letter.bg_black if @verbose
      end
      @buffer = []
      @mode = :single
    end

    def evaluate_buffer
      return if @buffer.empty?
      word = @buffer.join
      case @mode
      when :word
        reserved_word_or_identifier(word)
      when :number
        @tokens << ::Engine::Token.new(:number, raw: Integer(word))
      when :decimal
        @tokens << ::Engine::Token.new(:number, raw: Float(word))
      end
      @buffer = []
      @mode = :single
    end
  end
end
