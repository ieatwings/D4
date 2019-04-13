class Block_Verifier

	attr_accessor :currCount

	class Block

	    attr_accessor :number
	    attr_accessor :prev_block_hash
	    attr_accessor :raw_transactions
	    attr_accessor :transactions
	    attr_accessor :timestamp
	    attr_accessor :block_hash


		def initialize
			number = 0
			prev_block_hash = 0
      		raw_transactions = 0
      		transactions = []
			timestamp = 0
			block_hash = 0
		end
	end

	def check_block(blocks)
		@currCount = 0
		blocks.each do |b|
        	block = Block.new
	        attributes = b.split('|')

	        block.number = attributes[0]
	        block.prev_block_hash = attributes[1]
	        block.raw_transactions = attributes[2]

	        block.transactions = block.raw_transactions.split(':')

	        block.timestamp = attributes[3]
	        block.block_hash = attributes[4]

	        # call functions to validate portions
	        check_block_num(block)
	        # print tests
	        puts block.number
	        puts block.prev_block_hash
	        puts block.raw_transactions
	        puts block.transactions
	        puts block.timestamp
	        puts block. block_hash
	    end
    end

	def check_invalid_characters
		# checks for any invalid characters/strings
		# additional pipes
		# incorrect text
		# etc.
	end


	# function to check the numbering of blocks
	def check_block_num(block)
		# make sure number of blocks is in order starting at 0
		if (block.number.to_i != @currCount.to_i)
			puts "Line #{currCount}: Invalid block number #{block.number}, should be #{currCount} "
			puts "BLOCKCHAIN INVALID"
			exit 1
		else
			@currCount += 1
			@currCount
		end
	end


	def hash_block(block)

	end


	# function to check previous hash is valid
	def check_prev_hash(block)
		# first block's prev_hash is always 0
		if(@currCount.to_i == 0 and block.number.to_i == 0)
			if(block.prev_block_hash != 0)
				puts "Previous hash for Genesis Block should be 0"
			end
		end
		# call hash function to create a new hash to compare to prev_block's hash
		# if valid, continue
		# else, exit
	end


	# function to check sequence of transaction
	def check_transactions
		# FORMAT:
		# FROM_ADDR > TO_ADDR(NUM_BILLCOINS_SENT)

		# first addresss is the FROM address
		# second address is the TO address

		# BLOCK 0 SHOULD ONLY HAVE ONE TRANSACTION

		# last transaction should ALWAYS be from SYSTEM

	end


	# function to check timestamp is always moving forward
	def check_timestamp
		# FORMAT:
		# 100.8 (100 seconds + 8 nanoseconds)
		# 100.1000 (100 seconds + 1000 nanoseconds)
		# 100.1000 > 100.8
		# curr_timestamp > prev_timestamp
	end


	# function to check hash of first 4 elements
	def check_block_hash
		# unpack each character via U* (string_to_hash.unpack('U*')) to convert to UTF-8
		# for each string x, perform calculation ((x**300) + (x**x) - (3**x) * (7**x))
		# sum up values
		# determine that value modulo 65536
		# return resulting value as a strign version of number in base-16 (hex)

		# NOTE: hash will include FIRST FOUR elements of the string INCLUDING the pipe delimiters
	end


	# function to check transaction balances
	def balance_check
		# by the end of the program, ALL addresses should have positive balance
		# having negative between transactions is okay
	end
end