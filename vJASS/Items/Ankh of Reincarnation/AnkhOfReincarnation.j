scope AnkhOfReincarnation
    struct AnkhOfReincarnation extends Item
        static constant integer code = 'I00N'

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope