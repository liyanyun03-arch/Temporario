#ifndef CONFIG_H
#define CONFIG_H

#include "types.h"

#define ALL_POKES       1301     //number of all pokemon
#define ALL_ITEMS       1000     //number of all items
#define NUM_OF_EVOS     5       //number of evolutions per pokemon
#define KEYSTONE        111     //mega item that the player has to posses in order to mega evolve

#define BUILD_LEARNSETS true        //set to false if you modified the learnsets and dont want them to get changed
#define GEN4_LEARNSETS  true //set to true if you want to have learnsets for pokemon up to genIV
#define GEN5_LEARNSETS  true         //set to true if you want to have learnsets for pokemon up to genV
#define GEN6_LEARNSETS  true          //set to true if you want to have learnsets for pokemon up to genVI
#define GEN7_LEARNSETS  true          //set to true if you want to have learnsets for pokemon up to genVII

#define EXP_CAPTURE         true    //set to false if you don't want to receive exp from catching pokes
#define STAT_RECALC         true   //set to true if you want all pokemon having their stats recalculated at the end of the battle
#define ITEM_STEAL          true   //if true player is able to steal other trainers' items, if false the stolen item will disappear at the end of the battle
#define ITEM_SWAP           true   //if true player's item will be that that was switched, if false the switched item that a pokemon originally had returns to it
#define MAX_LEVEL           255     //highest possible level
#define MAX_EVS             510     //maximum amount of EV points per pokemon
#define EXP_DIVIDE          true    //if true exp will be divided among pokemon(if two pokemon participate they'll get 50 % each), set to false if you want gen6-style exp
#define GENVI_EXPSHARE      true    //set to true if you want EXPSHARE to act like in gen6
#define EXPSHARE_FLAG       0x4E8   //flag that must be set for GENVI expshare to work
#define DISABLED_EXP_FLAG   0x4E9   //if that flag is set, receiving exp is disabled, if flag is 0 it has no effect
#define DISABLED_EVS_FLAG   0x4EA     //if that flag is set, receiving EVS points is disabled, if flag is 0 it has no effect; this and above flag can be the same
#define DOUBLE_WILD_BATTLES true    //set to false if you don't want have them in your hack at all
#define DOUBLE_WILD_TILES   4      //amount of tiles double wild battles are possible on
#define EXPANDED_POKEBALLS  true  //set to true if your hack uses pokeball expansion
#define INVERSE_FLAG        0x4EB   //if that flag is set, the battle is inverse
#define FISHING_FLAG        0x4EC   //if that flag is set, it's a battle against a hooked up pokemon
#define CANT_CATCH_FLAG     0x4ED   //if that flag is set, you can't catch any pokemon, if flag is 0 you always can catch any pokemon
#define ALLOW_LOSE_FLAG     0x4EE   //if that flag is set, you can lose a battle and the script will continue
#define FORCE_SET_FLAG      0x4EF   //if that flag is set, the player cannot switch a pokemon when opponent faints
#define NO_OF_SLIDING_MSG_TRAINERS 10 //number of trainers that say things in the middle of a battle
#define SCHOOLING_LEVEL 20
#define BALL_MASTER_COUNT   0x40FA

//form indexes
#define POKE_CHERRIM                474
#define POKE_CHERRIM_SUNSHINE       1093
#define POKE_DARMANITAN             608
#define POKE_ZEN_MODE               1094
#define POKE_DARMANITAN_GALAR       895
#define POKE_ZEN_MODE_GALAR         896
#define POKE_AEGISLASH_BLADE        1095
#define POKE_AEGISLASH_SHIELD       734
#define POKE_MELOETTA_ARIA          701
#define POKE_MELOETTA_PIROUETTE     1096
#define POKE_BURMY_PLANT            465
#define POKE_BURMY_SAND             1097
#define POKE_BURMY_TRASH            1098
#define POKE_GRENJA                 711
#define POKE_ASH_GRENJA             1101
#define POKE_WISHIWASHI             799
#define POKE_WISHIWASHI_SCHOOL      1102
#define POKE_ZYGARDE_10             1103
#define POKE_ZYGARDE_50             771
#define POKE_ZYGARDE_100            1104
#define POKE_MINIOR_CORE            1076
#define POKE_MINIOR_METEOR          827
#define POKE_MIMIKYU                831
#define POKE_MIMIKYU_BUSTED         1083
#define POKE_MAGEARNA               854
#define POKE_MAGEARNA_ORIGINAL      1084
#define POKE_MARSHADOW				855
#define POKE_MARSHADOW_ZENIT		1089
#define POKE_LUNALA					845
#define POKE_LUNALA_FULL_MOON		1090
#define POKE_SOLGALEON				844
#define POKE_SOLGALEON_RADIANT_SUN	1091
#define POKE_XERNEAS				769
#define POKE_XERNEAS_ACTIVE			1092
#define EVO_PRIMAL_REVERSION              0xFD // Not an actual evolution, used to undergo primal reversion in battle.

//only change these if you want to adjust the position of mega icons or if you want to change the HP bars
#define SINGLES_HEALTHBOX_X 120
#define DBL_HB_0_X 120
#define DBL_HB_2_X 132
#define SINGLES_HEALTHBOX_Y 90
#define DBL_HB_0_Y 75
#define DBL_HB_2_Y 100

#endif /* CONFIG_H */
