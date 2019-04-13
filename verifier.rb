# Brandon La - bnl22 & Sarah Eyler
# CS1632
# D4 

require_relative 'arg_check'
require_relative 'block_verifier'

def arg_error
  puts 'Usage: ruby verifier.rb <name_of_file>'
  exit 1
end

# EXECUTION STARTS HERE
# ----------------------
# Verify valid arguments
args = ArgumentCheck.new
valid_args = args.arg_check ARGV

# If valid, begin Rubyist's Ruby Hunt simulator. Else, display usage syntax and exit
if valid_args
  @verify_block = Block_Verifier.new
  file = File.open(ARGV[0])
  blocks = file.read.split("\n")
  @verify_block.check_block(blocks)
else
  arg_error
end
