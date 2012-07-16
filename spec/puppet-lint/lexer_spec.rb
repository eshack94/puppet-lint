require 'spec_helper'

describe PuppetLint::Lexer do
  before do
    @lexer = PuppetLint::Lexer.new
  end

  context '#new_token' do
    it 'should calculate the line number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', '')
      token.line.should == 1
    end

    it 'should calculate the line number for a multi line string' do
      token = @lexer.new_token(:TEST, 'test', "foo\nbar")
      token.line.should == 2
    end

    it 'should calculate the column number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', '')
      token.column.should == 1
    end

    it 'should calculate the column number for a single line string' do
      token = @lexer.new_token(:TEST, 'test', 'this is a test')
      token.column.should == 14
    end

    it 'should calculate the column number for a multi line string' do
      token = @lexer.new_token(:TEST, 'test', "foo\nbar\nbaz\ngronk")
      token.column.should == 5
    end
  end

  context '#get_string_segment' do
    it 'should get a segment with a single terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '"')
      value.should == 'foo'
      terminator.should == '"'
    end

    it 'should get a segment with multiple terminators' do
      data = StringScanner.new('foo"bar$baz')
      value, terminator = @lexer.get_string_segment(data, "'$")
      value.should == 'foo"bar'
      terminator.should == '$'
    end

    it 'should not get a segment with an escaped terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '$')
      value.should be_nil
      terminator.should be_nil
    end
  end

  context '#interpolate_string' do
  end

  [
    'case',
    'class',
    'default',
    'define',
    'import',
    'if',
    'elsif',
    'else',
    'inherits',
    'node',
    'and',
    'or',
    'undef',
    'true',
    'false',
    'in',
    'unless',
  ].each do |keyword|
    it "should handle '#{keyword}' as a keyword" do
      token = @lexer.tokenise(keyword).first
      token.type.should == keyword.upcase.to_sym
      token.value.should == keyword
    end
  end

  [
    [:LBRACK, '['],
    [:RBRACK, ']'],
    [:LBRACE, '{'],
    [:RBRACE, '}'],
    [:LPAREN, '('],
    [:RPAREN, ')'],
    [:EQUALS, '='],
    [:ISEQUAL, '=='],
    [:GREATEREQUAL, '>='],
    [:GREATERTHAN, '>'],
    [:LESSTHAN, '<'],
    [:LESSEQUAL, '<='],
    [:NOTEQUAL, '!='],
    [:NOT, '!'],
    [:COMMA, ','],
    [:DOT, '.'],
    [:COLON, ':'],
    [:AT, '@'],
    [:LLCOLLECT, '<<|'],
    [:RRCOLLECT, '|>>'],
    [:LCOLLECT, '<|'],
    [:RCOLLECT, '|>'],
    [:SEMIC, ';'],
    [:QMARK, '?'],
    [:BACKSLASH, '\\'],
    [:FARROW, '=>'],
    [:PARROW, '+>'],
    [:APPENDS, '+='],
    [:PLUS, '+'],
    [:MINUS, '-'],
    [:DIV, '/'],
    [:TIMES, '*'],
    [:LSHIFT, '<<'],
    [:RSHIFT, '>>'],
    [:MATCH, '=~'],
    [:NOMATCH, '!~'],
    [:IN_EDGE, '->'],
    [:OUT_EDGE, '<-'],
    [:IN_EDGE_SUB, '~>'],
    [:OUT_EDGE_SUB, '<~'],
  ].each do |name, string|
    it "should have a token named '#{name.to_s}'" do
      token = @lexer.tokenise(string).first
      token.type.should == name
      token.value.should == string
    end
  end

  context ':CLASSREF' do
    it 'should match single capitalised alphanumeric term' do
      token = @lexer.tokenise('One').first
      token.type.should == :CLASSREF
      token.value.should == 'One'
    end

    it 'should match two capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two').first
      token.type.should == :CLASSREF
      token.value.should == 'One::Two'
    end

    it 'should match many capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two::Three::Four::Five').first
      token.type.should == :CLASSREF
      token.value.should == 'One::Two::Three::Four::Five'
    end

    it 'should match capitalised terms prefixed by ::' do
      token = @lexer.tokenise('::One').first
      token.type.should == :CLASSREF
      token.value.should == '::One'
    end
  end
  
  context ':NAME' do
    it 'should match lowercase alphanumeric terms' do
      token = @lexer.tokenise('one-two').first
      token.type.should == :NAME
      token.value.should == 'one-two'
    end

    it 'should match lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two').first
      token.type.should == :NAME
      token.value.should == 'one::two'
    end

    it 'should match many lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two::three::four::five').first
      token.type.should == :NAME
      token.value.should == 'one::two::three::four::five'
    end

    it 'should match lowercase alphanumeric terms prefixed by ::' do
      token = @lexer.tokenise('::1one::2two::3three').first
      token.type.should == :NAME
      token.value.should == '::1one::2two::3three'
    end
  end

  context ':NUMBER' do
    it 'should match numeric terms' do
      token = @lexer.tokenise('1234567890').first
      token.type.should == :NUMBER
      token.value.should == '1234567890'
    end

    it 'should match float terms' do
      token = @lexer.tokenise('12345.6789').first
      token.type.should == :NUMBER
      token.value.should == '12345.6789'
    end

    it 'should match hexadecimal terms' do
      token = @lexer.tokenise('0xCAFE1029').first
      token.type.should == :NUMBER
      token.value.should == '0xCAFE1029'
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('10e23').first
      token.type.should == :NUMBER
      token.value.should == '10e23'
    end

    it 'should match float with negative exponent terms' do
      token = @lexer.tokenise('10e-23').first
      token.type.should == :NUMBER
      token.value.should == '10e-23'
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('1.234e5').first
      token.type.should == :NUMBER
      token.value.should == '1.234e5'
    end
  end

  context ':COMMENT' do
    it 'should match everything on a line after #' do
      token = @lexer.tokenise('foo # bar baz')[2]
      token.type.should == :COMMENT
      token.value.should == 'bar baz'
    end
  end

  context ':MLCOMMENT' do
    it 'should match comments on a single line' do
      token = @lexer.tokenise('/* foo bar */').first
      token.type.should == :MLCOMMENT
      token.value.should == 'foo bar'
    end

    it 'should match comments on multiple lines' do
      token = @lexer.tokenise("/*\n * foo bar\n*/").first
      token.type.should == :MLCOMMENT
      token.value.should == 'foo bar'
    end
  end

  context ':SLASH_COMMENT' do
    it 'should match everyone on a line after //' do
      token = @lexer.tokenise('foo // bar baz')[2]
      token.type.should == :SLASH_COMMENT
      token.value.should == 'bar baz'
    end
  end

  context ':SSTRING' do
    it 'should match a single quoted string' do
      token = @lexer.tokenise("'single quoted string'").first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string'
    end

    it "should match a single quoted string with an escaped '" do
      token = @lexer.tokenise(%q{'single quoted string with "\\'"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\\'"'
    end

    it "should match a single quoted string with an escaped $" do
      token = @lexer.tokenise(%q{'single quoted string with "\$"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\$"'
    end

    it "should match a single quoted string with an escaped ." do
      token = @lexer.tokenise(%q{'single quoted string with "\."'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\."'
    end

    it "should match a single quoted string with an escaped \\n" do
      token = @lexer.tokenise(%q{'single quoted string with "\n"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\n"'
    end

    it "should match a single quoted string with an escaped \\" do
      token = @lexer.tokenise(%q{'single quoted string with "\\\\"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\\\"'
    end

    it "should match an empty string" do
      token = @lexer.tokenise("''").first
      token.type.should == :SSTRING
      token.value.should == ''
    end
  end
end