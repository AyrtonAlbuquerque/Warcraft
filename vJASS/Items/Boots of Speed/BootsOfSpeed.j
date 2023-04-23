scope BootsOfSpeed
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I00A'
    endmodule

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfSpeed extends Item
        implement Configuration

        real movementSpeed = 25

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
        endmethod
    endstruct
endscope