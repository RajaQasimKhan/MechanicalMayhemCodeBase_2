local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
	local Token = require(script.Parent.Token)
	local Lexer = require(script.Parent.Lexer)
	local Parser = require(script.Parent.SYParser)
	local Interpreter = require(script.Parent.SYInterpreter)

	describe('evaluate', function()
		it('should evaluate unary operation postfix', function()
			local lexer = Lexer.new('-2'):tokenize()
			local tree = Parser.new(lexer):parse()
			local value = Interpreter.evaluate(tree)

			expect(value).to.be.equal(-2)
		end)

		it('should evaluate binary operation postfix', function()
			local lexer = Lexer.new('0.38 + 1.83'):tokenize()
			local tree = Parser.new(lexer):parse()
			local value = Interpreter.evaluate(tree)

			expect(value).to.be.equal(2.21)
		end)
	end)
end