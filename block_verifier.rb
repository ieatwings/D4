class Block_Verifier
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

		# TEST #
		def check_block(blocks)
			blocks.each do |b|
        block = Block.new
        attributes = b.split('|')
        block.number = attributes[0]
        block.prev_block_hash = attributes[1]
        block.raw_transactions = attributes[2]
        block.transactions = block.raw_transactions.split(':')
        block.timestamp = attributes[3]
        block.block_hash = attributes[4]
        puts block.number
        puts block.prev_block_hash
        puts block.raw_transactions
        puts block.transactions
        puts block.timestamp
        puts block. block_hash
      end
		end
end
