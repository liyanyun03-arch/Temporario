#include "defines.h"
#include "static_references.h"

#define ALPHA_REVERSION 1
#define OMEGA_REVERSION 2

u16 get_mega_species(u8 bank, u8 chosen_method);
u8 get_bank_side(u8 bank);
void bs_execute(void* bs);
struct pokemon* get_bank_poke_ptr(u8 bank);

u8 get_reversion_type(u8 bank, u16 target_species)
{
	u16 species = battle_participants[bank].species;
	u8 reversion_type = 0;
	const struct evolution_sub* evos = GET_EVO_TABLE(species);
	for (u8 i = 0; i < NUM_OF_EVOS; i++)
	{
		if (evos[i].method == EVO_PRIMAL_REVERSION && evos[i].poke == target_species)
		{
			reversion_type = evos[i].paramter;
			break;
		}
	}
	return reversion_type;
}

bool handle_primal_reversion(u8 bank)
{
    bool perform_reversion = false;
    u16 primal_species = get_mega_species(bank, EVO_PRIMAL_REVERSION);

    if (primal_species)
    {
        u8 reversion_mode = get_reversion_type(bank, primal_species);
        if (reversion_mode != 0)
        {
            perform_reversion = true;
            struct battle_participant* bank_struct = &battle_participants[bank];
            struct pokemon* poke_address = get_bank_poke_ptr(bank);
            u8 banks_side = get_bank_side(bank);
            u8 objid = new_battlestruct->mega_related.indicator_id_pbs[bank];

            if (reversion_mode == ALPHA_REVERSION)
            {
                objects[objid].final_oam.attr2 += 2;
                bs_execute(BS_ALPHA_PRIMAL);
            }
            else if (reversion_mode == OMEGA_REVERSION)
            {
                objects[objid].final_oam.attr2 += 1;
                bs_execute(BS_OMEGA_PRIMAL);
            }

            if (banks_side == 1)
            {
                new_battlestruct->mega_related.ai_party_mega_check |= bits_table[battle_team_id_by_side[bank]];
            }
            else
            {
                new_battlestruct->mega_related.party_mega_check |= bits_table[battle_team_id_by_side[bank]];
            }

            objects[objid].private[PRIMAL_CHECK_COMPLETE] = true;
            set_attributes(poke_address, ATTR_SPECIES, &primal_species);
            calculate_stats_pokekmon(poke_address);
            bank_struct->species = primal_species;
            new_battlestruct->various.active_bank = bank;
            bank_attacker = bank;
        }
    }
    return perform_reversion;
}
