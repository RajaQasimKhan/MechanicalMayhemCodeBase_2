local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
	local Queue = require(script.Parent.Queue)

	describe('create empty queue', function()
		it('should start off as empty', function()
			local queue = Queue.new()
			
			expect(#queue:get()).to.be.equal(0)
		end)
		
		it('should be capable of pushing', function()
			local queue = Queue.new()
			
			expect(#queue:get()).to.be.equal(0)
			
			queue:enqueue('hello')
			queue:enqueue('world')
			
			expect(#queue:get()).to.be.equal(2)
			expect(queue:get()[1]).to.be.equal('hello')
			expect(queue:get()[2]).to.be.equal('world')
		end)
		
		it('should be capable of popping', function()
			local queue = Queue.new()

			expect(#queue:get()).to.be.equal(0)

			queue:enqueue('hello')
			queue:enqueue('world')

			expect(#queue:get()).to.be.equal(2)
			expect(queue:get()[1]).to.be.equal('hello')
			expect(queue:get()[2]).to.be.equal('world')
			
			queue:dequeue()
			
			expect(#queue:get()).to.be.equal(1)
			expect(queue:get()[1]).to.be.equal('world')
		end)
	end)
end