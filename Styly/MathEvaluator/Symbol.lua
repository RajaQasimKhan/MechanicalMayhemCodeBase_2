--[[

    Symbol

    Responsible for creating
    unique userdata values
    used in token types.

]]

local Symbol = {}

function Symbol.new(name)
    local self = newproxy(true)

    getmetatable(self).__tostring = function(t)
        return string.format('Symbol(%s)', t.name or '?')
    end

    getmetatable(self).__index = function(t, k)
        if (k == 'name') then
            return name
        end
    end

    return self
end

return Symbol