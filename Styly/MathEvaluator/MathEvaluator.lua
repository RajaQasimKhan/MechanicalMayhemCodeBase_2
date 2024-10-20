local MathEvaluator = {}

local Lexer = require(script.Lexer)
local RDParser = require(script.RDParser)
local SYParser = require(script.SYParser)
local RDInterpreter = require(script.RDInterpreter)
local SYInterpreter = require(script.SYInterpreter)

MathEvaluator.RDParser = RDParser
MathEvaluator.SYParser = SYParser

--[[
    Evaluate a mathematical
    expression
]]
return setmetatable(MathEvaluator, {
	__call = function(_, expression: string, parser: RDParser | SYParser)
		parser = parser or SYParser
		
	    local lexer = Lexer.new(expression)
		lexer:tokenize()
		local AST = parser.new(lexer):parse()
		
	    return parser == RDParser and RDInterpreter:visit(AST) or SYInterpreter.evaluate(AST)
	end
})