local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
    local Token = require(script.Parent.Token)
    local Lexer = require(script.Parent.Lexer)
    local Parser = require(script.Parent.SYParser)

    describe('parse', function()
        it('should reject an empty lexer', function()
            local lexer = Lexer.new(''):tokenize()
            expect(function()
                Parser.new(lexer):parse()
            end).to.be.throw()
        end)

        it('should parse numbers', function()
            local lexer = Lexer.new('42.8'):tokenize()
			local node = Parser.new(lexer):parse()

            expect(node:get()[1]).to.be.equal(42.8)
        end)

        it('should parse binary operations', function()
            local lexer = Lexer.new('12 + 9 * 4'):tokenize()
            local node = Parser.new(lexer):parse()

			expect(node:get()[1]).to.be.equal(12)
			expect(node:get()[2]).to.be.equal(9)
			expect(node:get()[3]).to.be.equal(4)
			expect(node:get()[4].type).to.be.equal(Token.Type.ASTERIK)
			expect(node:get()[5].type).to.be.equal(Token.Type.PLUS)
        end)

        it('should parse unary operations', function()
            local lexer = Lexer.new('-3'):tokenize()
            local node = Parser.new(lexer):parse()
			
			expect(node:get()[1]).to.be.equal(3)
			expect(node:get()[2].type).to.be.equal(Token.Type.UMINUS)
        end)
    end)
end