local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
    local Token = require(script.Parent.Token)
    local Lexer = require(script.Parent.Lexer)

    describe('tokenize', function()
        it('should tokenize whitespace', function()
			local lexer = Lexer.new('\t \n \t   \n'):tokenize()
			local tokens = lexer.tokens

            expect(#tokens).to.be.equal(0)
        end)

        it('should tokenize numbers', function()
			local lexer = Lexer.new('0.2 2.9 20.63 51'):tokenize()
			local tokens = lexer.tokens

            local expectedTokens = {
                Token.new(Token.Type.NUMBER, 0.2),
                Token.new(Token.Type.NUMBER, 2.9),
                Token.new(Token.Type.NUMBER, 20.63),
                Token.new(Token.Type.NUMBER, 51),
            }

            expect(#tokens).to.be.equal(#expectedTokens)

            for i = 1, #expectedTokens, 1 do
                expect(tokens[i]).to.be.ok()
                expect(tokens[i].type).to.be.equal(expectedTokens[i].type)
                expect(tokens[i].value).to.be.equal(expectedTokens[i].value)
            end
        end)

        it('should tokenize operators', function()
			local lexer = Lexer.new('+ - * / ^'):tokenize()
			local tokens = lexer.tokens

            local expectedTokens = {
                Token.new(Token.Type.PLUS),
                Token.new(Token.Type.MINUS),
                Token.new(Token.Type.ASTERIK),
                Token.new(Token.Type.SLASH),
                Token.new(Token.Type.CARET)
            }

            expect(#tokens).to.be.equal(#expectedTokens)

            for i = 1, #expectedTokens, 1 do
                expect(tokens[i]).to.be.ok()
                expect(tokens[i].type).to.be.equal(expectedTokens[i].type)
                expect(tokens[i].value).to.be.equal(expectedTokens[i].value)
            end
        end)

        it('should tokenize parentheses', function()
			local lexer = Lexer.new('( )'):tokenize()
			local tokens = lexer.tokens

            local expectedTokens = {
                Token.new(Token.Type.LPAREN),
                Token.new(Token.Type.RPAREN),
            }

            expect(#tokens).to.be.equal(#expectedTokens)

            for i = 1, #expectedTokens, 1 do
                expect(tokens[i]).to.be.ok()
                expect(tokens[i].type).to.be.equal(expectedTokens[i].type)
                expect(tokens[i].value).to.be.equal(expectedTokens[i].value)
            end
        end)

        it('should tokenize sqrt[] operations', function()
			local lexer = Lexer.new('sqrt[25] sqrt[49] sqrt[9 * 9]'):tokenize()
			local tokens = lexer.tokens

			local expectedTokens = {
				Token.new(Token.Type.ID, Token.Value.SQRT),
				Token.new(Token.Type.LBRACKET),
				Token.new(Token.Type.NUMBER, 25),
				Token.new(Token.Type.RBRACKET),
				Token.new(Token.Type.ID, Token.Value.SQRT),
				Token.new(Token.Type.LBRACKET),
				Token.new(Token.Type.NUMBER, 49),
				Token.new(Token.Type.RBRACKET),
				Token.new(Token.Type.ID, Token.Value.SQRT),
				Token.new(Token.Type.LBRACKET),
				Token.new(Token.Type.NUMBER, 9),
				Token.new(Token.Type.ASTERIK),
				Token.new(Token.Type.NUMBER, 9),
				Token.new(Token.Type.RBRACKET),
			}

			expect(#tokens).to.be.equal(#expectedTokens)

			for i = 1, #expectedTokens, 1 do
				expect(tokens[i]).to.be.ok()
				expect(tokens[i].type).to.be.equal(expectedTokens[i].type)
				expect(tokens[i].value).to.be.equal(expectedTokens[i].value)
			end
        end)

        it('should tokenize any valid expression', function()
			local lexer = Lexer.new('2 / (4.8 * 6)^(sqrt[100])'):tokenize()
			local tokens = lexer.tokens

            local expectedTokens = {
                Token.new(Token.Type.NUMBER, 2),
                Token.new(Token.Type.SLASH),
                Token.new(Token.Type.LPAREN),
                Token.new(Token.Type.NUMBER, 4.8),
                Token.new(Token.Type.ASTERIK),
                Token.new(Token.Type.NUMBER, 6),
                Token.new(Token.Type.RPAREN),
                Token.new(Token.Type.CARET),
                Token.new(Token.Type.LPAREN),
				Token.new(Token.Type.ID, Token.Value.SQRT),
				Token.new(Token.Type.LBRACKET),
				Token.new(Token.Type.NUMBER, 100),
				Token.new(Token.Type.RBRACKET),
                Token.new(Token.Type.RPAREN)
            }

            expect(#tokens).to.be.equal(#expectedTokens)

            for i = 1, #expectedTokens, 1 do
                expect(tokens[i]).to.be.ok()
                expect(tokens[i].type).to.be.equal(expectedTokens[i].type)
                expect(tokens[i].value).to.be.equal(expectedTokens[i].value)
            end
        end)

        it('should throw error for untokenizable expressions', function()
            local lexer = Lexer.new('! + ? *')
            
			expect(function()
				lexer:tokenize()
			end).to.be.throw()
        end)
    end)
end