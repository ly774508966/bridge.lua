local System = System
local throw = System.throw
local div = System.div
local ArgumentException = System.ArgumentException

local getmetatable = getmetatable
local select = select
local format = string.format
local tostring = tostring

local TimeSpan = {}

local function compare(t1, t2)
    if t1.ticks > t2.ticks then return 1 end
    if t1.ticks < t2.ticks then return -1 end
    return 0
end

TimeSpan.Compare = compare
TimeSpan.CompareTo = compare

function TimeSpan.CompareToObj(this, t)
   if t == null then return 1 end
   if getmetatable(t) ~= TimeSpan then
       throw(ArgumentException("Arg_MustBeTimeSpan"))
   end
   compare(this, t)
end

function TimeSpan.Equals(t1, t2)
    return t1.ticks == t2.ticks
end

function TimeSpan.EqualsObj(this, t)
    if getmetatable(t) == TimeSpan then
        return this.ticks == t.ticks
    end
    return false
end

function TimeSpan.GetHashCode(this)
    return this.ticks
end

function TimeSpan.__ctor__(this, ...)
    local ticks
    local length = select("#", ...)
    if length == 1 then
        ticks = ...
    elseif length == 3 then
        local hours, minutes, seconds = ...
        ticks = (((hours * 60 + minutes) * 60) + seconds) * 1e7
    elseif length == 4 then
        local days, hours, minutes, seconds = ...
        ticks = ((((days * 24 + hours) * 60 + minutes) * 60) + seconds) * 1e7
    elseif length == 5 then
        local days, hours, minutes, seconds, milliseconds = ...
        ticks = (((((days * 24 + hours) * 60 + minutes) * 60) + seconds) * 1e3 + milliseconds) * 1e4
    end
    assert(ticks)
    this.ticks = ticks
end

function TimeSpan.getTicks(this) 
    return this.ticks
end

function TimeSpan.getDays(this) 
    return div(this.ticks, 864e9)
end

function TimeSpan.getHours(this) 
    return div(this.ticks, 36e9) % 24
end

function TimeSpan.getMinutes(this) 
   return div(this.ticks, 6e8) % 60
end

function TimeSpan.getSeconds(this) 
    return div(this.ticks, 1e7) % 60
end

function TimeSpan.getMilliseconds(this) 
    return div(this.ticks, 1e4) % 1000
end

function TimeSpan.getTotalDays(this) 
    return this.ticks / 864e9
end

function TimeSpan.getTotalHours(this) 
    return this.ticks / 36e9
end

function TimeSpan.getTotalMilliseconds(this) 
    return this.ticks / 1e4
end

function TimeSpan.getTotalMinutes(this) 
    return this.ticks / 6e8
end

function TimeSpan.getTotalSeconds(this) 
    return this.ticks / 1e7
end

function TimeSpan.Add(this, ts) 
    return TimeSpan(this.ticks + ts.ticks)
end

function TimeSpan.Subtract(this, ts) 
    return TimeSpan(this.ticks - ts.ticks)
end

function TimeSpan.Duration(this) 
    return TimeSpan(math.abs(this.ticks))
end

function TimeSpan.Negate(this) 
    return TimeSpan(-this.ticks)
end

function TimeSpan.ToString(this) 
    local day = this:getDays()
    local daysStr = day == 0 and "" or (tostring(day) .. ".")
    return format("%s%02d:%02d:%02d.%03d", daysStr, this:getHours(), this:getMinutes(), this:getSeconds(), this:getMilliseconds())
end

TimeSpan.__add = TimeSpan.Add
TimeSpan.__sub = TimeSpan.Subtract

function TimeSpan.__eq(t1, t2)
    return t1.ticks == t2.ticks
end

function TimeSpan.__lt(t1, t2)
    return t1.ticks < t2.ticks
end

function TimeSpan.__le(t1, t2)
    return t1.ticks <= t2.ticks
end

function TimeSpan.FromDays(value) 
    return TimeSpan(value * 864e9)
end

function TimeSpan.FromHours(value) 
    return TimeSpan(value * 36e9)
end

function TimeSpan.FromMilliseconds(value) 
    return TimeSpan(value * 1e4)
end

function TimeSpan.FromMinutes(value) 
    return TimeSpan(value * 6e8)
end

function TimeSpan.FromSeconds(value) 
    return TimeSpan(value * 1e7)
end

function TimeSpan.FromTicks(value) 
    return TimeSpan(value)
end

System.defStc("System.TimeSpan", TimeSpan)
TimeSpan.__inherits__ = { System.IComparable, System.IComparable_1(TimeSpan), System.IEquatable_1(TimeSpan) }

local zero = TimeSpan(0)
TimeSpan.zero = zero
TimeSpan.maxValue = TimeSpan(864e13)
TimeSpan.minValue = TimeSpan(-864e13)

function TimeSpan.__default__()
    return zero
end