local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
	local Stack = require(script.Parent.Stack)

	describe('create empty stack', function()
		it('should start off as empty', function()
			local stack = Stack.new()
			
			expect(#stack:get()).to.be.equal(0)
		end)
		
		it('should be capable of pushing', function()
			local stack = Stack.new()
			
			expect(#stack:get()).to.be.equal(0)
			
			stack:push('hello')
			stack:push('world')
			
			expect(#stack:get()).to.be.equal(2)
			expect(stack:get()[1]).to.be.equal('hello')
			expect(stack:get()[2]).to.be.equal('world')
		end)
		
		it('should be capable of popping', function()
			local stack = Stack.new()

			expect(#stack:get()).to.be.equal(0)

			stack:push('hello')
			stack:push('world')

			expect(#stack:get()).to.be.equal(2)
			expect(stack:get()[1]).to.be.equal('hello')
			expect(stack:get()[2]).to.be.equal('world')
			
			stack:pop()
			
			expect(#stack:get()).to.be.equal(1)
			expect(stack:get()[1]).to.be.equal('hello')
		end)
		
	end)
end