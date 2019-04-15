require 'minitest/autorun'
require_relative 'blockverifier'

# Class to test Block_Verifier Class
class Block_Verifier_Test < Minitest::Test
  
  # test Block initialize method
  def test_block_init_block
    b = BlockVerifier::Block.new(0,0,'',0,0)
    assert_equal(0, b.block_number)
    assert_equal(0, b.prev_block_hash)
    assert_equal('', b.raw_transactions)
    assert_equal([], b.transactions)
    assert_equal(0, b.timestamp)
    assert_equal(0, b.block_hash)
  end

  # test that Block_Verifier initializes correctly
  def test_block_verifier_init
    b = BlockVerifier.new
    assert_equal(0, b.curr_count)
    assert_equal([], b.prev_timestamp)
    assert_equal(0, b.actual_prev_hash)
    assert_equal(false, b.prev_hash_error)
    assert_equal(false, b.prev_timestamp_error)
    assert_equal(false, b.block_num_error)
    assert_equal(false, b.transactions_error)
    assert_equal(false, b.block_hash_error)
    assert_equal(false, b.balance_error)
    #assert_equal({}, b.addresses)
  end

  # test to check block_num function for valid block num
  def test_check_block_num_good
    bv = BlockVerifier.new
    file = File.open('sample.txt','r')
    blocks = file.read.split("\n")
    attributes = blocks[0].split('|')
    b = BlockVerifier::Block.new(attributes[0], attributes[1], attributes[2], attributes[3], attributes[4])
    bv.check_block_num(b)
    assert_equal(false, bv.block_num_error)
  end

  # test to check block_num function for invalid block num
  def test_check_block_num_bad
    bv = BlockVerifier.new
    file = File.open('bad_number.txt', 'r')
    blocks = file.read.split("\n")
    attributes = blocks[8].split('|')
    bv.curr_count = 8
    b = BlockVerifier::Block.new(attributes[0], attributes[1], attributes[2], attributes[3], attributes[4])
    assert_raises(SystemExit) {bv.check_block_num(b)}
    assert_equal(true, bv.block_num_error)
  end

  # test to check block_transactions function for valid transactions list
  def test_check_block_transactions
    bv = BlockVerifier.new
    b = BlockVerifier::Block.new(0, 0, 'SYSTEM>569274(100)', '1553184699.650220000', '288d')
    bv.check_block_transactions(b)
    assert_equal(false, bv.transactions_error)
  end

  # test to check block_transactions function for invalid transactions list
  def test_check_block_transactions_incorrect_format
    bv = BlockVerifier.new
    b = BlockVerifier::Block.new(0, 0, 'SYSTEM > 569274(100)', '1553184699.650220000', '288d')
    assert_raises(SystemExit) {bv.check_block_transactions(b)}
    assert_equal(true, bv.transactions_error)
  end

  # test to check block_hash function for valid hashes
  def test_check_block_hash
    bv = BlockVerifier.new
    block = '1|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000|92a2'
    attributes = block.split('|')
    b = BlockVerifier::Block.new(attributes[0], attributes[1], attributes[2], attributes[3].split('.'), attributes[4])
    bv.check_block_hash(b)
    assert_equal(false, bv.block_hash_error)
  end

  # test to check block_hash function for invalid hashes  
  def test_check_block_hash_invalid
    bv = BlockVerifier.new
    block = '1|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000|abcd'
    attributes = block.split('|')
    b = BlockVerifier::Block.new(attributes[0], attributes[1], attributes[2], attributes[3].split('.'), attributes[4])
    assert_raises(SystemExit) {bv.check_block_hash(b)}
    assert_equal(true, bv.block_hash_error)
  end

  # test to check check_block function for valid blocks
  def test_check_block
    bv = BlockVerifier.new
    block_string = '0|0|SYSTEM>569274(100)|1553184699.650330000|288d'
    bv.check_block(block_string)
    assert_equal(false, bv.prev_hash_error)
    assert_equal(false, bv.prev_timestamp_error)
  end

  # test to check check_block function for invalid previous hash of block
  def test_check_block_bad_prev_hash
    bv = BlockVerifier.new
    file = File.open('bad_prev_hash.txt', 'r')
    blocks = file.read.split("\n")
    assert_raises(SystemExit) {bv.check_input(blocks)}
    assert_equal(true, bv.prev_hash_error)
  end

  # test the initialization of addresses
  def test_addresses_init
    a = BlockVerifier::Addresses.new
    assert_equal({}, a.addresses)
  end

  # test when any account balances are negative
  def test_check_balance_negative
    bv = BlockVerifier.new
    b = BlockVerifier::Block.new(block_attributes[0], block_attributes[1], block_attributes[2], block_attributes[3].split('.'), block_attributes[4])
    bv.curr_count = 1
    assert_raises(SystemExit) {bv.check_balance(curr_count)}
    assert_equal(true, bv.balance_error)
  end

  # test for invalid block timestamps
  def test_check_timestamp_invalid
    bv = BlockVerifier.new
    file = File.open('bad_timestamp.txt', 'r')
    blocks = file.read.split("\n")
    assert_raises(SystemExit) {bv.check_input(blocks)}
    assert_equal(true, bv.prev_timestamp_error)
  end

  def test_blockverifier
    bv = BlockVerifier.new
    refute_nil(bv)
    assert_kind_of(BlockVerifier, bv)
  end

end