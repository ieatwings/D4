# frozen_string_literal: true

# class to verify blocks
class BlockVerifier
  attr_accessor :curr_count
  attr_accessor :prev_timestamp
  attr_accessor :actual_prev_hash
  attr_accessor :addresses
  attr_accessor :hash_array
  attr_accessor :prev_hash_error
  attr_accessor :prev_timestamp_error
  attr_accessor :block_num_error
  attr_accessor :transactions_error
  attr_accessor :block_hash_error
  attr_accessor :balance_error

  def initialize
    @curr_count = 0
    @prev_timestamp = []
    @actual_prev_hash = 0
    @addresses = Addresses.new
    @hash_array = []
    @prev_hash_error = false
    @prev_timestamp_error = false
    @block_num_error = false
    @transactions_error = false
    @block_hash_error = false
    @balance_error = false
  end

  # Class that creates a hash map of addresses and their respective balances
  class Addresses
    attr_reader :addresses
    @addresses = {}

    def initialize
      @addresses = {}
    end

    # function to handle the Billcoin transactions
    def handle_billcoins(name, coins)
      # if coins are from the system, ignore it
      return unless name != 'SYSTEM'

      # if the address exists in the hash
      if @addresses.key?(name)
        @addresses[name] += coins
      else
        @addresses[name] = coins
      end
    end

    def check_balance(curr_count)
      @addresses.each do |name, coins|
        next unless coins.negative?

        @balance_error = true
        puts "Line #{curr_count}: Invalid block, address #{name} has #{coins} billcoins!"
        puts 'BLOCKCHAIN INVALID'
        exit 1
      end
    end

    def print
      @addresses = @addresses.sort_by { |name, _coins| name }
      @addresses.each do |name, coins|
        puts "#{name}: #{coins} billcoins" unless coins.zero?
      end
    end
  end

  # Class for Block object
  class Block
    attr_accessor :block_number
    attr_accessor :prev_block_hash
    attr_accessor :raw_transactions
    attr_accessor :transactions
    attr_accessor :timestamp
    attr_accessor :block_hash

    def initialize(number, prev_hash, transactions, timestamp, block_hash)
      @block_number = number
      @prev_block_hash = prev_hash
      @raw_transactions = transactions
      @transactions = transactions.split(':')
      @timestamp = timestamp
      @block_hash = block_hash
    end
  end

  def check_input(blocks)
    blocks.each do |b|
      check_block(b)
      @curr_count += 1
    end
    @addresses.print
  end

  def check_block(block)
    block_attributes = block.split('|')
    curr_block = Block.new(block_attributes[0], block_attributes[1], block_attributes[2], block_attributes[3].split('.'), block_attributes[4].strip)

    check_block_num(curr_block)
    check_block_transactions(curr_block)
    check_block_hash(curr_block)

    # check that previous hash == current hash
    if @actual_prev_hash != 0 && @actual_prev_hash != curr_block.prev_block_hash
      @prev_hash_error = true
      puts "Line #{@curr_count}: Previous hash was #{curr_block.prev_block_hash}, should be #{@actual_prev_hash}"
      puts 'BLOCKCHAIN INVALID'
      exit 1
    end
    @actual_prev_hash = curr_block.block_hash

    # check that timestamp is correct and in order of increasing time
    # FORMAT:
    # 100.8 (100 seconds + 8 nanoseconds)
    # 100.1000 (100 seconds + 1000 nanoseconds)
    # 100.1000 > 100.8
    # curr_timestamp > prev_timestamp
    if @prev_timestamp != 0 && curr_block.timestamp[0].to_i <= @prev_timestamp[0].to_i && curr_block.timestamp[1].to_i < @prev_timestamp[1].to_i
      @prev_timestamp_error = true
      puts "Line #{@curr_count}: Previous timestamp #{@prev_timestamp[0]}.#{@prev_timestamp[1]} >= new timestamp #{curr_block.timestamp[0]}.#{curr_block.timestamp[1]}"
      puts 'BLOCKCHAIN INVALID'
      exit 1
    end
    # set the new "previous timestamp" to be current timestamp before moving on to next block
    @prev_timestamp = curr_block.timestamp
    # check that balances are not negative
    @addresses.check_balance(@curr_count)
  end

  # function to check the numbering of blocks
  def check_block_num(curr_block)
    # make sure number of blocks is in order starting at 0
    return unless curr_block.block_number.to_i != @curr_count

    @block_num_error = true
    puts "Line #{curr_count}: Invalid block number #{curr_block.block_number}, should be #{curr_count} "
    puts 'BLOCKCHAIN INVALID'
    exit 1
  end

  # function to check sequence of transaction
  def check_block_transactions(curr_block)
    # FORMAT:
    # FROM_ADDR > TO_ADDR(NUM_BILLCOINS_SENT)
    curr_block.transactions.each do |transaction|
      if transaction.include? ' '
        @transactions_error = true
        puts "Line #{@curr_count}: Could not parse transactions list '#{transaction}'"
        puts 'BLOCKCHAIN INVALID'
        exit 1
      end

      # split transaction line to sending/receiving addresses
      transaction_senders = transaction.split(/[>()]/)
      from_addr = transaction_senders[0]
      to_addr = transaction_senders[1]
      coins = transaction_senders[2].to_i

      # calculate balance results
      @addresses.handle_billcoins(from_addr, -coins)
      @addresses.handle_billcoins(to_addr, coins)
    end
  end

  # unpack each character via U* (string_to_hash.unpack('U*')) to convert to UTF-8
  # for each string x, perform calculation ((x**3000) + (x**x) - (3**x) * (7**x))
  # sum up values
  # determine that value modulo 65536
  # return resulting value as a strign version of number in base-16 (hex)
  # NOTE: hash will include FIRST FOUR elements of the string INCLUDING the pipe delimiters
  # function to check hash of first 4 elements
  def check_block_hash(curr_block)
    block_hash_string = curr_block.block_number + '|' + curr_block.prev_block_hash + '|' + curr_block.raw_transactions + '|' + curr_block.timestamp[0] + '.' + curr_block.timestamp[1]
    block_hash_string.unpack('U*')

    # splits the string into each character
    hash_parts = block_hash_string.split('')

    res = 0
    # OPTIMIZATION: store the hashes of characters so we can reuse them
    hash_parts.each do |x|
      # this returns the integer ordinal after we converted to UTF-8
      x = x.ord
      hash_array[x] = ((x**3000) + (x**x) - (3**x)) * (7**x) if hash_array[x].nil?
      res += hash_array[x]
    end

    # module result by constant 65536
    res = res % 65_536
    # resulting hash string in base-16
    resulting_hash = res.to_s(16)
    return unless resulting_hash != curr_block.block_hash

    @block_hash_error = true
    puts "Line #{@curr_count}: String '#{block_hash_string}' hash set to #{curr_block.block_hash}, should be #{resulting_hash}"
    puts 'BLOCKCHAIN INVALID'
    exit 1
  end
end
