API = {}

function API.round(num)
    t = vector.new(num)
    t = t:round()
    return t.x
end

return API

