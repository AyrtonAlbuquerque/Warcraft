scope MaskOfDeath
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I00U'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct MaskOfDeath extends Item
        implement Configuration

        real lifeSteal = 0.05

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope