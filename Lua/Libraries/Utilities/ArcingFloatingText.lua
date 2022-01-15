-- Arcing Text Tag v1.0.0.3 by Maker encoded to Lua

DEFINITION      = 1.0/32.0
SIZE_MIN        = 0.013         -- Minimum size of text
SIZE_BONUS      = 0.005         -- Text size increase
TIME_LIFE       = 0.5           -- How long the text lasts
TIME_FADE       = 0.3           -- When does the text start to fade
Z_OFFSET        = 50            -- Height above unit
Z_OFFSET_BON    = 50            -- How much extra height the text gains
VELOCITY        = 2.0           -- How fast the text move in x/y plane
TMR             = CreateTimer()

ANGLE_RND       = true          -- Is the angle random or fixed
if not ANGLE_RND then
    ANGLE       = bj_PI/2.0     -- If fixed, specify the Movement angle of the text.
end

tt   = {}
as   = {} -- angle, sin component
ac   = {} -- angle, cos component
ah   = {} -- arc height
t    = {} -- time
x    = {} -- origin x
y    = {} -- origin y
str  = {} -- text

ic   = 0  -- Instance count   
rn   = {} ; rn[0] = 0
next = {} ; next[0] = 0
prev = {} ; prev[0] = 0 --Needed due to Lua not initializing them.

function ArcingTextTag(s, u)
    local this = rn[0]
    if this == 0 then
        ic = ic + 1
        this = ic
    else
        rn[0] = rn[this]
    end
    
    next[this] = 0
    prev[this] = prev[0]
    next[prev[0]] = this
    prev[0] = this
    
    str[this] = s
    x[this] = GetUnitX(u)
    y[this] = GetUnitY(u)
    t[this] = TIME_LIFE
    
    local a
    if ANGLE_RND then
        a = GetRandomReal(0, 2*bj_PI)
    else
        a = ANGLE
    end
    as[this] = Sin(a)*VELOCITY
    ac[this] = Cos(a)*VELOCITY
    ah[this] = 0.
    
    if IsUnitVisible(u, GetLocalPlayer()) then
        tt[this] = CreateTextTag()
        SetTextTagPermanent(tt[this], false)
        SetTextTagLifespan(tt[this], TIME_LIFE)
        SetTextTagFadepoint(tt[this], TIME_FADE)
        SetTextTagText(tt[this], s, SIZE_MIN)
        SetTextTagPos(tt[this], x[this], y[this], Z_OFFSET)
    end
    
    if prev[this] == 0 then
        TimerStart(TMR, DEFINITION, true, function()
            local this = next[0]
            local p
            while (this ~= 0) do
                p = Sin(bj_PI*t[this])
                t[this] = t[this] - DEFINITION
                x[this] = x[this] + ac[this]
                y[this] = y[this] + as[this]
                SetTextTagPos(tt[this], x[this], y[this], Z_OFFSET + Z_OFFSET_BON * p)
                SetTextTagText(tt[this], str[this], SIZE_MIN + SIZE_BONUS * p)
                if t[this] <= 0.0 then
                    tt[this] = null
                    next[prev[this]] = next[this]
                    prev[next[this]] = prev[this]
                    rn[this] = rn[0]
                    rn[0] = this
                    if next[0] == 0 then
                        PauseTimer(TMR)
                    end
                end
                this = next[this]
            end
        end)
    end
    return this
end