scope InfusedManaCrystal
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I027'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct InfusedManaCrystal extends Item
        implement Configuration

        real mana = 350

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope