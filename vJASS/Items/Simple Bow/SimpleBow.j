scope SimpleBow
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I01T'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SimpleBow extends Item
        implement Configuration

        real agility = 5

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope