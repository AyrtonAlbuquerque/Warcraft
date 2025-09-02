OnInit("ArcingFloatingText", function(requires)
    requires "Class"

    ArcingTextTag = Class()

    local VELOCITY = 2
    local LIFE_TIME = 1
    local Z_OFFSET = 50
    local BONUS_SIZE = 0
    local Z_OFFSET_BONUS = 50

    local tags = {}
    local array = {}
    local timer = CreateTimer()

    function ArcingTextTag:destroy()
        table.insert(tags, self.texttag)

        SetTextTagVisibility(self.texttag, false)

        if #array == 0 then
            PauseTimer(timer)
        end
    end

    function ArcingTextTag.onPeriod()
        for i = #array, 1, -1 do
            local this = array[i]
            local height = math.sin(this.duration * bj_PI)

            this.duration = this.duration - 0.03125

            if this.duration > 0 then
                this.x = this.x + this.cos
                this.y = this.y + this.sin

                SetTextTagPos(this.texttag, this.x, this.y, Z_OFFSET + Z_OFFSET_BONUS * height)
                SetTextTagText(this.texttag, this.text, this.size + BONUS_SIZE * height)
            else
                table.remove(array, i)
                this:destroy()
            end
        end
    end

    function ArcingTextTag.create(text, unit, size)
        local this = ArcingTextTag.allocate()
        local angle = GetRandomReal(0, 2 * bj_PI)

        this.size = size
        this.text = text
        this.x = GetUnitX(unit)
        this.y = GetUnitY(unit)
        this.duration = LIFE_TIME
        this.sin = math.sin(angle) * VELOCITY
        this.cos = math.cos(angle) * VELOCITY

        table.insert(array, this)

        if #tags > 0 then
            this.texttag = table.remove(tags)

            SetTextTagVisibility(this.texttag, true)
        else
            this.texttag = CreateTextTag()

            SetTextTagPermanent(this.texttag, true)
        end

        SetTextTagText(this.texttag, this.text, this.size)
        SetTextTagPos(this.texttag, this.x, this.y, Z_OFFSET)

        if #array == 1 then
            TimerStart(timer, 0.03125, true, ArcingTextTag.onPeriod)
        end

        return this
    end

    function ArcingTextTag.onInit()
        for i = 0, 100 do
            local tag = CreateTextTag()

            SetTextTagPermanent(tag, true)
            SetTextTagVisibility(tag, false)

            table.insert(tags, tag)
        end
    end
end)