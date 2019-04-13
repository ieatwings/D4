# Brandon La - bnl22 & Sarah Eyler
# CS1632
# D3

require_relative 'arg_check'

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
case valid_args
when true
puts 'Good Argument'
when false
  arg_error
end
