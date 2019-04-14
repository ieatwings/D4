# Brandon La(bnl22) & Sarah Eyler(sae54)
# CS1632 - D4
require 'flamegraph'
require_relative 'arg_check'
require_relative 'blockverifier'

def arg_error
  puts 'Usage: ruby verifier.rb <name_of_file>'
  exit 1
end

# EXECUTION STARTS HERE
# ----------------------
# Verify valid arguments
args = ArgumentCheck.new
valid_args = args.arg_check ARGV

# If arguments are valid, create an instance of a Block_Verifier and begin checking
if valid_args
  # Begin Flamegraph to locate bottlenecks
  Flamegraph.generate('final_verifier.html') do
    @verify_blockchain = BlockVerifier.new

    file = File.open(ARGV[0], 'r')

    @verify_blockchain.check_input(file)
  end
else
  arg_error
end
