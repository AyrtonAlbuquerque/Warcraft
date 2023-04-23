scope AssassinsDagger
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I01R'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct AssassinsDagger extends Item
        implement Configuration

        real evasionChance = 10
        real damage = 5

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope