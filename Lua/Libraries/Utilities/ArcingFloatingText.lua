OnInit("ArcingFloatingText", function(requires)
    requires "Class"

    ArcingTextTag = Class()

    local SIZE_MIN       = 0.015        -- Minimum size of text (unused, kept for parity)
    local SIZE_BONUS     = 0            -- Text size increase
    local TIME_LIFE      = 1.0          -- How long the text lasts
    local TIME_FADE      = 0.8          -- When does the text start to fade
    local Z_OFFSET       = 50           -- Height above unit
    local Z_OFFSET_BONUS = 50           -- How much extra height the text gains
    local VELOCITY       = 2            -- How fast the text moves in the x/y plane
    local ANGLE          = bj_PI / 2    -- Movement angle of the text. Ignored if ANGLE_RND is true
    local ANGLE_RND      = true         -- Is the angle random or fixed

    local array = {}
    local timer = CreateTimer()

    function ArcingTextTag.onPeriod()
        for i = #array, 1, -1 do
            local this = array[i]
            local height = math.sin(this.duration * bj_PI)

            this.duration = this.duration - 0.03125
            this.x = this.x + this.cos
            this.y = this.y + this.sin

            SetTextTagPos(this.texttag, this.x, this.y, Z_OFFSET + Z_OFFSET_BONUS * height)
            SetTextTagText(this.texttag, this.text, this.size + SIZE_BONUS * height)

            if this.duration <= 0 then
                this.texttag = nil
                table.remove(array, i)

                if #array == 0 then
                    PauseTimer(timer)
                end
            end
        end
    end

    function ArcingTextTag.create(text, unit, size)
        local this = ArcingTextTag.allocate()
        local angle

        if ANGLE_RND then
            angle = GetRandomReal(0, 2 * bj_PI)
        else
            angle = ANGLE
        end

        this.text = text
        this.x = GetUnitX(unit)
        this.y = GetUnitY(unit)
        this.size = size
        this.duration = TIME_LIFE
        this.sin = math.sin(angle) * VELOCITY
        this.cos = math.cos(angle) * VELOCITY

        if IsUnitVisible(unit, GetLocalPlayer()) then
            this.texttag = CreateTextTag()

            SetTextTagPermanent(this.texttag, false)
            SetTextTagLifespan(this.texttag, TIME_LIFE)
            SetTextTagFadepoint(this.texttag, TIME_FADE)
            SetTextTagText(this.texttag, text, size)
            SetTextTagPos(this.texttag, this.x, this.y, Z_OFFSET)
        end

        table.insert(array, this)

        if #array == 1 then
            TimerStart(timer, 0.03125, true, ArcingTextTag.onPeriod)
        end

        return this
    end
end)