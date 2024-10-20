local TestEZ = require(script.Parent.Parent.TestEZ)

return function()
    local Node = require(script.Parent.Node)
    local Token = require(script.Parent.Token)
    local Lexer = require(script.Parent.Lexer)
    local Parser = require(script.Parent.RDParser)

    describe('parse', function()
        it('should reject an empty lexer', function()
            local lexer = Lexer.new('')
            lexer:tokenize()
            expect(function()
                Parser.new(lexer):parse()
            end).to.be.throw()
        end)

        it('should parse numbers', function()
            local lexer = Lexer.new('42.8')
            lexer:tokenize()
            local node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('Number')
            expect(node.value).to.be.equal(42.8)
        end)

        it('should parse binary operations', function()
            local lexer = Lexer.new('12 + 9')
            lexer:tokenize()
            local node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.PLUS)

            expect(node.nodes[1].name).to.be.equal('Number')
            expect(node.nodes[2].name).to.be.equal('Number')

            expect(node.nodes[1].value).to.be.equal(12)
            expect(node.nodes[2].value).to.be.equal(9)

            lexer = Lexer.new('12 - 9')
            lexer:tokenize()
            node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.MINUS)

            expect(node.nodes[1].name).to.be.equal('Number')
            expect(node.nodes[2].name).to.be.equal('Number')

            expect(node.nodes[1].value).to.be.equal(12)
            expect(node.nodes[2].value).to.be.equal(9)

            lexer = Lexer.new('12 * 9')
            lexer:tokenize()
            node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.ASTERIK)

            expect(node.nodes[1].name).to.be.equal('Number')
            expect(node.nodes[2].name).to.be.equal('Number')

            expect(node.nodes[1].value).to.be.equal(12)
            expect(node.nodes[2].value).to.be.equal(9)

            lexer = Lexer.new('12 / 9')
            lexer:tokenize()
            node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.SLASH)

            expect(node.nodes[1].name).to.be.equal('Number')
            expect(node.nodes[2].name).to.be.equal('Number')

            expect(node.nodes[1].value).to.be.equal(12)
            expect(node.nodes[2].value).to.be.equal(9)

            lexer = Lexer.new('12 ^ 9')
            lexer:tokenize()
            node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.CARET)

            expect(node.nodes[1].name).to.be.equal('Number')
            expect(node.nodes[2].name).to.be.equal('Number')

            expect(node.nodes[1].value).to.be.equal(12)
            expect(node.nodes[2].value).to.be.equal(9)
        end)

        it('should parse unary operations', function()
            local lexer = Lexer.new('-3')
            lexer:tokenize()
            local node = Parser.new(lexer):parse()

            expect(node.name).to.be.equal('UnaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.MINUS)

            expect(node.node.name).to.be.equal('Number')
            expect(node.node.value).to.be.equal(3)
        end)

        it('should parse any valid expression', function()
            local lexer = Lexer.new('(9 * 3) ^ 8')
            lexer:tokenize()
            local node = Parser.new(lexer):parse()
            
            expect(node.name).to.be.equal('BinaryOperation')
            expect(node.token.type).to.be.equal(Token.Type.CARET)

            expect(node.nodes[1].name).to.be.equal('BinaryOperation')
            expect(node.nodes[1].token.type).to.be.equal(Token.Type.ASTERIK)
            expect(node.nodes[1].nodes[1].name).to.be.equal('Number')
            expect(node.nodes[1].nodes[1].value).to.be.equal(9)
            expect(node.nodes[1].nodes[2].name).to.be.equal('Number')
            expect(node.nodes[1].nodes[2].value).to.be.equal(3)

            expect(node.nodes[2].name).to.be.equal('Number')
            expect(node.nodes[2].value).to.be.equal(8)

        end)
    end)
end