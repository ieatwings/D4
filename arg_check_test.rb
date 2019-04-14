require 'minitest/autorun'
require_relative 'arg_check'

# Class to test ArgumentCheck class
class ArgCheckTest < Minitest::Test

  # UNIT TESTS FOR METHOD arg_check(args)

  # Test: zero command line arguments
  def test_arg_check_noArgs
  	@args = ArgumentCheck.new
    assert_equal(false, @args.arg_check([]))
  end

  # Test: one command line arguments
  def test_arg_check_oneArg
  	@args = ArgumentCheck.new
  	assert_equal(true, @args.arg_check([1]))
  end

  # Test: string argument
  def test_arg_check_1string
  	@args = ArgumentCheck.new
  	assert_equal(true, @args.arg_check(['poop']))
  end

  # EDGE CASE
  # Test: two string arguments
  def test_arg_check_2string
  	@args = ArgumentCheck.new
  	assert_equal(false, @args.arg_check(['poop', 'poopy']))
  end

  # EDGE CASE
  # Test: three string arguments
  def test_arg_check_3string
  	@args = ArgumentCheck.new
  	assert_equal(false, @args.arg_check(['poop', 'poopy', 'poopypoop']))
  end

  # Test: valid arguments
  def test_arg_check_validArgs
  	@args = ArgumentCheck.new
  	assert_equal(true, @args.arg_check(['sample.txt']))
  end
end
