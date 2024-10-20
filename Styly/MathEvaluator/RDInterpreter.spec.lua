local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
    local Token = require(script.Parent.Token)
    local Node = require(script.Parent.Node)
    local Lexer = require(script.Parent.Lexer)
    local Parser = require(script.Parent.RDParser)
    local Interpreter = require(script.Parent.RDInterpreter)

    describe('visit', function()
        it('should visit independent number nodes', function()
            local value = Interpreter:visit(Node.Number(Token.new(Token.Type.Number, 19)))

            expect(value).to.be.equal(19)
        end)

        it('should visit unary operations', function()
            local lexer = Lexer.new('-2')
            lexer:tokenize()
            local tree = Parser.new(lexer):parse()
            local value = Interpreter:visit(tree)

            expect(value).to.be.equal(-2)
        end)

        it('should visit binary operations', function()
            local lexer = Lexer.new('3.2 + 3.8')
            lexer:tokenize()
            local tree = Parser.new(lexer):parse()
            local value = Interpreter:visit(tree)

            expect(value).to.be.equal(7)

            lexer = Lexer.new('4.2 - 3.8')
            lexer:tokenize()
            tree = Parser.new(lexer):parse()
            value = Interpreter:visit(tree)

            expect(value).to.be.near(0.4, 0.0000000001)

            lexer = Lexer.new('3.2 * 3.8')
            lexer:tokenize()
            tree = Parser.new(lexer):parse()
            value = Interpreter:visit(tree)

            expect(value).to.be.equal(12.16)

            lexer = Lexer.new('3.2 / 3.8')
            lexer:tokenize()
            tree = Parser.new(lexer):parse()
            value = Interpreter:visit(tree)

            expect(value).to.be.near(0.84, 0.003)

            lexer = Lexer.new('3.2 ^ 3.8')
            lexer:tokenize()
            tree = Parser.new(lexer):parse()
            value = Interpreter:visit(tree)

            expect(value).to.be.near(83, 0.1)
        end)

    end)
end