# encoding: UTF-8

require 'parslet'

module Lambda

  require 'lambda/ast'
  require 'lambda/bitfield'
  require 'lambda/builder'
  require 'lambda/berre_parser'
  require 'lambda/parsers'

  # Combinators:
  ID = parse('&0')
  K  = parse('&&1')
  S  = parse('&&&((2|0)|(1|0))')

  # John Tromp's tiny interpreter:
  U  = parse_blc(%{01010001101000010000000110000001100001
       01111001111111000010111001111111000000111100001011
       01101110011111111000011111111000010111101001110100
       10110011111100001101100001011111111000011111111000
       011100110111101110011010000110010001101000011010})

  # And his brainfuck interpreter:
  BF = parse_blc(%{01000100010100011010000100000001100001
       10000001100000010101100000100000100000010001011110
       01100101111111100101111110000000000001100001010101
       11111100010101111011100000010111000000101101110110
       10000001011100010010101000110100000010000010110000
       00000010111110010110000010010101111111101111110001
       01110010110000011001010111111110001011111101110100
       10111011010111111101001011111111001100101111110000
       00000011100000010101011111110001011010000101101111
       11011110000000000110000101011111100010100001011011
       11101111001011111100111111111110000110001001111111
       11111000011100101000110100000000001010101010001101
       00000010110000000010111100101111110111110110000011
       01010011110000101011111101111101111000011111000011
       11001110100111000101010000111111111111000011111111
       11110000111100001111000011110000111100111010011010
       00010101011000000000000111111000001011101101100101
       00011010000000010110110010111101110110100101010000
       01110011100111010000001110011101000000101100000110
       110000010})
end



def Lambda(*args)
  Lambda.parse(*args)
end

