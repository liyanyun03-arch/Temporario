#include "defines.h"

struct trainer_slide_info{
    u16 trainerID;
    u16 padd_for_now;
    u8* txt_last_switchin;
    u8* txt_last_lowHP;
    u8* txt_first_down;
};

struct trainer_slide_info sliding_trainers[NO_OF_SLIDING_MSG_TRAINERS] = {
    {0, 0, NULL, NULL, NULL},
};

u8 get_trainer_opponent_A_class()
{
	return (*trainer_table)[var_8015_trainer_opponent_A].class;
}
/*
u8 get_trainer_class_by_bank(u8 bank){
	u16* trainerID = &var_8015_trainer_opponent_A;
	if(bank == 1)
		return trainerID[0];
	else if(bank == 2)
		return trainerID[2];
	else if(bank == 3)
		return trainerID[1];
	return 0;
}
*/
/*
void* trainer_callback(u8 caseID)
{
	
	if(caseID==1)
	{
		u16 value=0xffff;
		for (u8 i=0; i<6; i++)
			set_attributes(party_oppenent+i, ATTR_ATTACK+i, &value);
	}
}
*/

u8* get_slide_msg(u16 trainerID, u8 caseID)
{
    u8* txt_ptr = NULL;
    if (!battle_flags.multibattle)
    {
        for (u16 i = 0; i < NO_OF_SLIDING_MSG_TRAINERS; i++)
        {
            struct trainer_slide_info* curr_trainer = &sliding_trainers[i];
            if (trainerID == curr_trainer->trainerID)
            {
                u8** txt_ptrs = &curr_trainer->txt_last_switchin;
                return txt_ptrs[caseID];
            }
        }

    }
    return txt_ptr;
}
