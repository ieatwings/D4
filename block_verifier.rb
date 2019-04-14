class Block_Verifier

	attr_accessor :curr_count
	attr_accessor :prev_timestamp
	attr_accessor :actual_prev_hash

	def initialize
		@curr_count = 0
		@prev_timestamp = []
		@actual_prev_hash = 0
		@addresses = Addresses.new
	end

	# Class that creates a hash map of the addresses and their respective balances
	class Addresses
		@addresses = {}

		def initialize
			@addresses = {}
		end

		# function to handle the Billcoin transactions
		def handle_billcoins(name, coins)
			# if coins are from the system, ignore it
			if(name == 'SYSTEM')
				return
			end

			# if the address exists in the hash
			if(@addresses.key?(name))
				@addresses[name] += coins
			else
				@addresses[name] = coins
			end
		end

		def check_balance(curr_count)
			@addresses.each do |name, coins|
				if(coins < 0)
					puts "Line #{curr_count}: Invalid block, address #{name} has #{coins} billcoins!"
					puts "BLOCKCHAIN INVALID"
					exit 1
				end
			end
		end

		def print
			@addresses = @addresses.sort_by {|name, coins| name}
			@addresses.each do |name, coins|
				if(coins != 0)
					puts "#{name}: #{coins} billcoins"
				end
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
    	if(@actual_prev_hash != 0 && @actual_prev_hash != curr_block.prev_block_hash)
    		puts "Line #{@curr_count}: Previous hash was #{curr_block.prev_block_hash}, should be #{@actual_prev_hash}"
    		puts "BLOCKCHAIN INVALID"
    		exit 1
    	end
    	@actual_prev_hash = curr_block.block_hash

    	# check that timestamp is correct and in order of increasing time
    	# FORMAT:
		# 100.8 (100 seconds + 8 nanoseconds)
		# 100.1000 (100 seconds + 1000 nanoseconds)
		# 100.1000 > 100.8
		# curr_timestamp > prev_timestamp
    	if(@prev_timestamp != 0 && curr_block.timestamp[0].to_i <= @prev_timestamp[0].to_i && curr_block.timestamp[1].to_i < @prev_timestamp[1].to_i)
    		puts "Line #{@curr_count}: Previous timestamp #{@prev_timestamp[0]}.#{@prev_timestamp[1]} >= new timestamp #{curr_block.timestamp[0]}.#{curr_block.timestamp[1]}"
    		puts "BLOCKCHAIN INVALID"
    		exit 1
    	end
    	# set the new "previous timestamp" to be current timestamp before moving on to next block
    	@prev_timestamp = curr_block.timestamp
    	# check that balances are not negative
    	@addresses.check_balance(@curr_count)
    end

	def check_invalid_characters
		# checks for any invalid characters/strings
		# additional pipes
		# incorrect text
		# etc.
	end


	# function to check the numbering of blocks
	def check_block_num(curr_block)
		# make sure number of blocks is in order starting at 0
		if (curr_block.block_number.to_i != @curr_count)
			puts "Line #{curr_count}: Invalid block number #{curr_block.block_number}, should be #{curr_count} "
			puts "BLOCKCHAIN INVALID"
			exit 1
		end
	end


	# function to check sequence of transaction
	def check_block_transactions(curr_block)
		# FORMAT:
		# FROM_ADDR > TO_ADDR(NUM_BILLCOINS_SENT)
		curr_block.transactions.each do |transaction|
			if(transaction.include? " ")
				puts "Line #{@curr_count}: Could not parse transactions list '#{transaction}'"
				puts "BLOCKCHAIN INVALID"
				exit 1
			end

			# split transaction line to sending/receiving addresses
			transaction_senders = transaction.split(/[>()]/)
			from_addr = transaction_senders[0]
			to_addr = transaction_senders[1]
			coins = transaction_senders[2].to_i

			# calculate balance results
			@addresses.handle_billcoins(from_addr, -(coins))
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
		hash_parts = block_hash_string.split('')

		res = 0
		hash_parts.each do |x|
			# this returns the integer ordinal after we converted to UTF-8
			x = x.ord
			res += ((x**3000) + (x**x) - (3**x)) * (7**x)
		end

		# module result by constant 65536
		res = res % 65536
		# resulting hash string in base-16
		resulting_hash = res.to_s(16)
		if(resulting_hash != curr_block.block_hash)
			puts "Line #{@curr_count}: String '#{block_hash_string}' hash set to #{curr_block.block_hash}, should be #{resulting_hash}"
			puts "BLOCKCHAIN INVALID"
			exit 1
		end
	end
end
