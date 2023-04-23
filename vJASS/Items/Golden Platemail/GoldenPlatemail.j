scope GoldenPlatemail
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I01D'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GoldenPlatemail extends Item
        implement Configuration

        real armor = 3
        real health = 225

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope