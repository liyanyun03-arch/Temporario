#include "defines.h"
#include "static_references.h"
#include "defines/get_attr.h"

u16 get_transform_species(u8 bank);
u16 get_airborne_state(u8 bank, u8 mode, u8 check_levitate);
bool is_of_type(u8 bank, u8 type);
bool check_ability(u8 bank, u8 ability);
bool is_bank_present(u32 bank);
u8 learnsanydamagingmove(u16 poke);
u16 type_effectiveness_calc(u16 move, u8 move_type, u8 atk_bank, u8 def_bank, u8 effects_handling_and_recording);
u8 calculate_move_type(u8 bank, u16 move, u8 set_bonus);
void atk04_critcalc(void);
void damage_calc(u16 move, u8 move_type, u8 atk_bank, u8 def_bank, u16 chained_effectiveness,bool setflag);
void damagecalc2();
u8 affected_by_substitute(u8 substitute_bank);
u8 find_move_in_table(u16 move, const u16* table_ptr);
u8 get_first_to_strike(u8 bank1, u8 bank2, u8 ignore_priority);
u8 get_item_effect(u8 bank, u8 check_negating_effects);
u8 has_ability_effect(u8 bank, u8 mold_breaker);
u8 ability_battle_effects(u8 switch_id, u8 bank, u8 ability_to_check, u8 special_cases_argument, u16 move);
void canuselastresort();
void belch_canceler();
void can_magneticflux_work();
bool is_poke_usable(struct pokemon* poke);
struct pokemon* get_bank_poke_ptr(u8 bank);
u8 get_bank_side(u8 bank);
u8 get_move_table_target(u16 move,u8 atk_bank);
u16 get_poke_weight(u8 bank);
u16 get_speed(u8 bank);

#define AI_STATE battle_resources->tai_state

static u8 get_ai_bank(u8 bank)
{
    switch (bank)
    {
    case 0: //target
        return bank_target;
    case 1: //ai
        return tai_bank;
    case 2: //target partner
        return bank_target ^ 2;
    case 3: //tai partner
    default:
        return tai_bank ^ 2;
    }
}

static bool is_bank_ai(u8 bank)
{
    if ((tai_bank & 1) == (bank & 1))
        return 1;
    return 0;
}

static u8 tai_getmovetype(u8 atk_bank, u16 move)
{
    u8 dynamic_type = calculate_move_type(atk_bank, move, 0);
    if (dynamic_type != TYPE_EGG)
        return dynamic_type;
    else
        return move_table[move].type;
}

bool was_impossible_used(/*u8 bank*/)
{
    return 0;
}

u16 ai_get_species(u8 bank)
{
    if (new_battlestruct->bank_affecting[bank].illusion_on && !is_bank_ai(bank) && was_impossible_used(bank))
        return get_transform_species(bank);
    else
        return battle_participants[bank].species;
}

u16 ai_get_move(u8 bank, u8 slot)
{
    if (is_bank_ai(bank))
        return battle_participants[bank].moves[slot];
    else
        return battle_resources->battle_history->used_moves[bank].moves[slot];
}

bool has_poke_hidden_ability(/*u16 species*/)
{
    return 0;
}

bool is_ability_preventing_switching(u8 preventing_bank, u8 prevented_bank)
{
    if (is_bank_present(prevented_bank) && get_item_effect(prevented_bank, 1) != ITEM_EFFECT_SHEDSHELL)
    {
        if ((ability_battle_effects(13, preventing_bank, ABILITY_SHADOW_TAG, 1, 0) && !check_ability(prevented_bank, ABILITY_SHADOW_TAG) && !is_of_type(prevented_bank, TYPE_GHOST))
        || (ability_battle_effects(13, preventing_bank, ABILITY_MAGNET_PULL, 1, 0) && is_of_type(prevented_bank, TYPE_STEEL))
        || (ability_battle_effects(13, preventing_bank, ABILITY_ARENA_TRAP, 1, 0) && GROUNDED(prevented_bank)))
        {
            return 1;
        }
    }
    return 0;
}

u8 ai_get_ability(u8 bank, u8 gastro)
{
    u8 ability;
    if (is_bank_ai(bank))
        ability = battle_participants[bank].ability_id;
    else
    {
        u8 recorded_ability = battle_resources->battle_history->ability[bank];
        u16 species = ai_get_species(bank);
        if (recorded_ability)
            ability = recorded_ability;
        else if (!has_poke_hidden_ability(species) && !(*basestat_table)[species].ability2) //poke has only one ability
            ability = (*basestat_table)[species].ability1;
        else if (is_ability_preventing_switching(bank, bank ^ 1) || is_ability_preventing_switching(bank, bank ^ 1 ^ 2)) //check if bank prevents escape
            ability = battle_participants[bank].ability_id;
        else
            ability = 0;
    }
    if (gastro && new_battlestruct->bank_affecting[bank].gastro_acided)
        ability = 0;
    return ability;
}

u8 ai_get_item_effect(u8 bank, u8 negating_effect)
{
    if (is_bank_ai(bank))
        return get_item_effect(bank, negating_effect);
    else
    {
        u8 item_effect = battle_resources->battle_history->item[bank];
        if (negating_effect)
        {
            if (new_battlestruct->field_affecting.magic_room || new_battlestruct->bank_affecting[bank].embargo || ai_get_ability(bank, 1) == ABILITY_KLUTZ)
                item_effect = 0;
        }
        return item_effect;
    }
}

u8 does_bank_know_move(u8 bank, u16 move)
{
    for (u8 i = 0; i < 4; i++)
    {
        if (ai_get_move(bank, i) == move)
            return 1;
    }
    return 0;
}

void save_bank_stuff(u8 bank)
{
    u16* item = &battle_participants[bank].held_item;
    new_battlestruct->trainer_AI.saved_item[bank] = *item;
    if (!get_item_effect(bank, 0)) //ai doesn't know an item the target has
        *item = 0;
    u8* ability = &battle_participants[bank].ability_id;
    new_battlestruct->trainer_AI.saved_ability[bank] = *ability;
    if (!ai_get_ability(bank, 0)) //ai doesn't know an ability the target has
        *ability = 0;
    u16* species = &battle_participants[bank].species;
    new_battlestruct->trainer_AI.saved_species[bank] = *species;
    *species = ai_get_species(bank); //make illusion trick AI
}

void restore_bank_stuff(u8 bank)
{
    battle_participants[bank].held_item = new_battlestruct->trainer_AI.saved_item[bank];
    battle_participants[bank].ability_id = new_battlestruct->trainer_AI.saved_ability[bank];
    battle_participants[bank].species = new_battlestruct->trainer_AI.saved_species[bank];
}

u8 tai_get_move_effectiveness(void)
{
    save_bank_stuff(bank_target);
    u16 move = AI_STATE->curr_move;
    u16 effectiveness = type_effectiveness_calc(move, tai_getmovetype(tai_bank, move), tai_bank, bank_target, 0);
    restore_bank_stuff(bank_target);
    if (effectiveness == 0)
        return 0;
    else if (effectiveness < 64)
        return 1;
    else if (effectiveness == 64)
        return 2;
    else
        return 3;
}

u32 random_value(u32 limit);
u32 ai_calculate_damage(u8 atk_bank, u8 def_bank, u16 move)
{
    u8 saved_target_bank = bank_target;
    *(u8*)(&move_outcome) = 0;
    save_bank_stuff(atk_bank);
    save_bank_stuff(def_bank);
    void* bs_inst = battlescripts_curr_instruction;
    current_move = move;
    bank_attacker = atk_bank;
    bank_target = def_bank;
    atk04_critcalc();
    u8 move_type = tai_getmovetype(atk_bank, move);
    u8 script_ID = move_table[move].script_id;
    if (move_type != TYPE_EGG)
        battle_stuff_ptr->dynamic_move_type=move_type + 0x80;
    else
        battle_stuff_ptr->dynamic_move_type = 0;
    if (script_ID == 1) //fixed damage
        damagecalc2();
    else
    {
        u16 chained_effectiveness=type_effectiveness_calc(move, move_type, atk_bank,def_bank,0);
        damage_calc(move, move_type, atk_bank, def_bank, chained_effectiveness,0);
    }
    battlescripts_curr_instruction = bs_inst;
    u8 no_of_hits = 1;
    if (script_ID == 67) //hits two times
        no_of_hits = 2;
    else if (script_ID == 66) //hits multiple times
    {
        if (check_ability(atk_bank, ABILITY_SKILL_LINK))
            no_of_hits = 5;
        else
            no_of_hits = 2 + __umodsi3(rng(), 3) + __umodsi3(rng(), 2); //2 + 0/1/2 + 0/1 = 2/3/4/5
    }
    u32 damage = damage_loc * no_of_hits;
    if (no_of_hits == 1 && has_ability_effect(def_bank, 1) && battle_participants[def_bank].ability_id == ABILITY_STURDY && battle_participants[def_bank].current_hp == battle_participants[def_bank].max_hp)
        damage = battle_participants[def_bank].max_hp - 1;
    if (affected_by_substitute(def_bank))
    {
        u32 substitute_hp = disable_structs[def_bank].substitute_hp;
        if (no_of_hits == 1 && damage > substitute_hp)
            damage = substitute_hp;
        else if (no_of_hits > 1)
        {
            damage -= damage_loc;
        }
    }
    restore_bank_stuff(atk_bank);
    restore_bank_stuff(def_bank);
    bank_target = saved_target_bank;
    return damage;
}

static bool ai_is_fatal(u8 atk_bank, u8 def_bank, u16 move)
{
    if (ai_calculate_damage(atk_bank, def_bank, move) >= battle_participants[def_bank].max_hp)
        return 1;
    return 0;
}

//switch functions
/*u8 tai_find_best_to_switch(void)
{
    u8 bank = active_bank;
    if (battle_stuff_ptr->field_5C[bank] == 6) {return 6;}
    if (battle_flags.battle_arena) {return battle_team_id_by_side[bank] + 1;}
    u8 from = 0, to = 5, partner = bank;
    if (battle_flags.double_battle && is_bank_present(bank ^ 2))
        partner = bank ^ 2;
    if (battle_flags.multibattle && get_bank_side(bank))
    {
        if (bank == 1)
            to = 2;
        else if (bank == 3)
            from = 3;
    }
    else if ((battle_flags.player_ingame_partner || battle_flags.player_partner) && !get_bank_side(bank))
    {
        if (bank == 0)
            to = 2;
        else if (bank == 2)
            from = 3;
    }
    u32 candidates = 0;
    struct pokemon* poke = get_bank_poke_ptr(bank);
    for (u8 i = from; i < to; i++)
    {
        struct pokemon* curr_poke = &poke[i];
        if (battle_team_id_by_side[bank] != i && battle_team_id_by_side[partner] != i && is_poke_usable(curr_poke))
            candidates |= bits_table[i];
    }
    if (candidates == 0) {return 0;}
    u8 to_ret;
    do
    {
        to_ret = __umodsi3(rng(), 6);
    } while(!(candidates & bits_table[to_ret]));
    return to_ret;
}*/

void tai24_ismostpowerful(void) //no args, returns 1 if it's the most powerful move, otherwise 0
{
    u32 most_damage = 0;
    u8 most_powerful_id = 4;
    for (u8 i = 0; i < 4; i++)
    {
        u16 checking_move = ai_get_move(tai_bank, i);
        if (checking_move && DAMAGING_MOVE(checking_move))
        {
            u32 damage = ai_calculate_damage(tai_bank, bank_target, checking_move);
            if (damage > most_damage)
            {
                most_damage = damage;
                most_powerful_id = i;
            }
        }
    }
    u32* var = &AI_STATE->var;
    if (most_powerful_id == AI_STATE->moveset_index)
	{
		AI_STATE->score[AI_STATE->moveset_index] += 1;
		*var = 1;
	}        
    else
        *var = 0;
    tai_current_instruction++;
}

void tai2F_getability(void) //u8 bank, u8 gastro
{
    AI_STATE->var = ai_get_ability(get_ai_bank(read_byte(tai_current_instruction + 1)), read_byte(tai_current_instruction + 2));
    tai_current_instruction += 3;
}

void tai31_jumpifeffectiveness_EQ(void) //u8 effectiveness, void* ptr
{
    if (tai_get_move_effectiveness() == (read_byte(tai_current_instruction + 1)))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 2);
    else
        tai_current_instruction += 6;
}

void tai32_jumpifeffectiveness_NE() //u8 effectiveness, void* ptr
{
    if (tai_get_move_effectiveness() != read_byte(tai_current_instruction + 1))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 2);
    else
        tai_current_instruction += 6;
}

void tai3D_jumpiffatal() //void* ptr
{
    if (ai_is_fatal(tai_bank, bank_target, AI_STATE->curr_move))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 1);
    else
        tai_current_instruction += 5;
}

void tai3E_jumpifnotfatal() //void* ptr
{
    if (!ai_is_fatal(tai_bank, bank_target, AI_STATE->curr_move))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 1);
    else
        tai_current_instruction += 5;
}

void tai48_getitemeffect() //u8 bank, u8 check negating effects
{
    AI_STATE->var = ai_get_item_effect(get_ai_bank(read_byte(tai_current_instruction + 1)), read_byte(tai_current_instruction + 2));
    tai_current_instruction += 3;
}

void tai5F_is_of_type() //u8 bank, u8 type
{
    AI_STATE->var = is_of_type(get_ai_bank(read_byte(tai_current_instruction + 1)), read_byte(tai_current_instruction + 2));
    tai_current_instruction += 3;
}

void tai60_checkability() //u8 bank, u8 ability, u8 gastro
{
    u32* var = &AI_STATE->var;
    if (ai_get_ability(get_ai_bank(read_byte(tai_current_instruction + 1)), read_byte(tai_current_instruction + 3)) == read_byte(tai_current_instruction + 2))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 4;
}

u8 is_stat_change_positive(u16 move)
{
    u8 script_id = move_table[move].script_id;
    s8 value;
    if (script_id  == 6 || script_id == 7)
        value = (s8) (move_table[move].arg2);
    else
        value = (s8) (move_table[move].arg1);
    if (value >= 0)
        return 1;
    else
        return 0;
}

u8 tai_does_flower_veil_negate(u16 move)
{
    u8 script_id = move_table[move].script_id;
    if (is_of_type(bank_target, TYPE_GRASS))
    {
        if (script_id == 12 || script_id == 13 || script_id == 14 || script_id == 15 || script_id == 16 || script_id == 131)
            return 1;
        if (get_move_table_target(move,tai_bank) != move_target_user && !is_stat_change_positive(move))
            return 1;
    }
    return 0;
}

u8 does_move_lower_target_stat(u16 move, u8 atk_bank, u8 def_bank)
{
    u8 script_id = move_table[move].script_id;
    if (script_id == 3 || script_id == 7 || script_id == 38) //one stat target, multiple stats target, captivate
    {
        u8 lowers_stat = !is_stat_change_positive(move);
        u8 atk_ability = ai_get_ability(atk_bank, 1);
        u8 moldbreaker = 0;
        if ((atk_ability == ABILITY_MOLD_BREAKER || atk_ability == ABILITY_TURBOBLAZE || atk_ability == ABILITY_TERAVOLT))
            moldbreaker = 1;
        u8 contrary = 0;
        if (ai_get_ability(def_bank, 1) == ABILITY_CONTRARY && !moldbreaker)
            contrary = 1;
        if (lowers_stat && !contrary)
            return 1;
        if (!lowers_stat && contrary)
            return 1;
    }
    return 0;
}

u8 does_move_raise_attacker_stat(u16 move, u8 atk_bank)
{
    u8 script_id = move_table[move].script_id;
    if (script_id == 2 || script_id == 6 || script_id == 27 || script_id == 56 || script_id == 82 || script_id == 83) //one stat user, multiple stats user, charge, autonomize, minimize, defense curl
    {
        u8 raises_stat = is_stat_change_positive(move);
        u8 contrary = 0;
        if (ai_get_ability(atk_bank, 1) == ABILITY_CONTRARY)
            contrary = 1;
        if (raises_stat && !contrary)
            return 1;
        if (!raises_stat && contrary)
            return 1;
    }
    return 0;
}

u8 get_stat_move_changes(u16 move)
{
    u8 script_id = move_table[move].script_id;
    if (script_id == 2 || script_id == 3 || script_id == 27 || script_id == 38 || script_id == 56 || script_id == 82 || script_id == 83)
        return move_table[move].arg1 & 7;
	else if(script_id==9)
		return STAT_CONFUSION;
	else if(script_id==12)
		return STAT_SLEEP;
	else if(script_id==13 || script_id==14)
		return STAT_POISON;	
	else if(script_id==15)
		return STAT_PARALYSIS;
	else if(script_id==16)
		return STAT_BURN;
	//else if(script_id==17)
		//return STAT_FREEZE;
    return 0;
}

bool is_shields_down_protected(u8 bank)
{
    u16 species = battle_participants[bank].species;
    return (ai_get_ability(bank, 0) == ABILITY_SHIELDS_DOWN && species >= POKE_MINIOR_CORE && species <= POKE_MINIOR_METEOR);
}

bool can_partner_ability_block_move(u8 atk_bank, u8 def_bank, u16 move, u8 ability)
{
    if (is_bank_ai(atk_bank) == is_bank_ai(def_bank)) // São aliados?
        return false;
        
    switch (ability)
    {
        case ABILITY_DAZZLING:
        case ABILITY_QUEENLY_MAJESTY:
            return (move_table[move].priority > 0); // Acesso direto à tabela de movimentos
            
        default:
            return false;
    }
}

void tai2A_discourage_moves_based_on_abilities()
{
    u16 move = AI_STATE->curr_move;
    u8 script_id = move_table[move].script_id;
    u8 move_type = tai_getmovetype(tai_bank, move);
    u8 tai_ability = ai_get_ability(tai_bank, 1);
    u8 discourage = 0;

    /* --- Verificação Universal (independente de habilidades do alvo) --- */
    // Gen7+: Dark types vs Prankster (ANTES do switch principal)
    if (is_of_type(bank_target, TYPE_DARK) && tai_ability == ABILITY_PRANKSTER && move_table[move].split == MOVE_STATUS &&
        !(get_move_table_target(move, tai_bank) & (move_target_opponent_field | move_target_user)))
    {
        discourage += 10;
    }

    // 2. Electric Terrain: bloqueia sleep/yawn
    if (new_battlestruct->field_affecting.electic_terrain &&
        (script_id == 12 || script_id == 131)) // SLEEP (12) ou YAWN (131)
    {
        discourage += 20; // Penalização maior que o padrão
    }
    // 3. Misty Terrain: bloqueia status
	if (new_battlestruct->field_affecting.misty_terrain)
	{
		// Verifica efeitos de status (usando a mesma lógica do Flower Veil)
		if (script_id == 12 ||  // SLEEP
			script_id == 13 ||  // POISON
			script_id == 14 ||  // TOXIC
			script_id == 15 ||  // PARALYSIS
			script_id == 16 ||  // BURN
			script_id == 131 || // YAWN
			script_id == 9)     // CONFUSION (adicionado)
		{
			discourage += 20;
		}
	}
    // 4. Psychic Terrain: bloqueia golpes de prioridade
    if (new_battlestruct->field_affecting.psychic_terrain && 
    move_table[move].priority > 0)
    {
        discourage += 20; // Penalização maior que o padrão
    }

    /* --- Verificação Específica por Habilidade --- */
    if (tai_ability != ABILITY_MOLD_BREAKER && 
        tai_ability != ABILITY_TURBOBLAZE && 
        tai_ability != ABILITY_TERAVOLT)
    {
        switch (ai_get_ability(bank_target, 1))
        {
        case ABILITY_IMMUNITY:
        case ABILITY_PASTEL_VEIL:
            if (script_id == 13 || script_id == 14 || script_id == 18 || script_id == 19 || move_type == TYPE_POISON)
                discourage = 10;
            break;
		case ABILITY_MAGIC_GUARD:
			if (script_id == 13 || script_id == 14 || script_id == 16 || script_id == 18 || script_id == 19 || script_id == 78)
				discourage = 5;
			else if (script_id == 104) // EFFECT_CURSE (104 é o script_id para Curse)
			{
				// Verifica se o usuário é do tipo Ghost
				if (is_of_type(tai_bank, TYPE_GHOST))
					discourage = 5;
			}
			break;
		case ABILITY_JUSTIFIED:
			if (move_type == TYPE_DARK)
				discourage = 10;
			break;
		case ABILITY_RATTLED:
			if (move_type == TYPE_DARK || move_type == TYPE_GHOST || move_type == TYPE_BUG)
				discourage = 10;
			break;
        case ABILITY_OWN_TEMPO:
            if (script_id == 9 || script_id == 10)
                discourage = 10;
            break;
        case ABILITY_VITAL_SPIRIT:
        case ABILITY_INSOMNIA:
            if (script_id == 12 || script_id == 107)
                discourage = 10;
            break;
        case ABILITY_FLASH_FIRE:
			if (move_type == TYPE_FIRE)
			{
				u8 partner = tai_bank ^ 2;
				if (!is_bank_present(partner) || bank_target != partner) // Se não for parceiro
					discourage = 20; // Penalidade maior
				else
					discourage = 10; // Penalidade normal se for parceiro
			}
			break;
		case ABILITY_WATER_ABSORB:
		case ABILITY_DRY_SKIN:
		case ABILITY_STORM_DRAIN:
			if (move_type == TYPE_WATER)
			{
				u8 partner = tai_bank ^ 2;
				if (!is_bank_present(partner) || bank_target != partner) // Se não for parceiro
					discourage = 20; // Penalidade maior
				else
					discourage = 10; // Penalidade normal se for parceiro
			}
			break;

        case ABILITY_SHIELD_DUST:
            if (move_table[move].effect_chance || script_id == 9 || script_id == 10 || script_id == 11 || script_id == 12 || 
				script_id == 13 || script_id == 14 || script_id == 15 || script_id == 16 || script_id == 17 || script_id == 18 || 
				script_id == 19 || does_move_lower_target_stat(move, tai_bank, bank_target))
                discourage = 8; // Slightly less discourage than complete immunities
            break;
        case ABILITY_CONTRARY:
            if (does_move_raise_attacker_stat(move, tai_bank)) // Move raises attacker's stat
                discourage = 8; // Discourage if move would benefit the target
            else if (does_move_lower_target_stat(move, tai_bank, bank_target)) // Move lowers target's stat
                discourage = 8; // Discourage if move would harm the target
            break;
        case ABILITY_STURDY:
            if (move_table[move].script_id == 70 && // OHKO move
                battle_participants[bank_target].current_hp == battle_participants[bank_target].max_hp)
                discourage = 9; // Discourage OHKO moves
            break;
        case ABILITY_MOTOR_DRIVE:
        case ABILITY_VOLT_ABSORB:
        case ABILITY_LIGHTNING_ROD:
			if (move_type == TYPE_ELECTRIC)
			{
				u8 partner = tai_bank ^ 2;
				if (!is_bank_present(partner) || bank_target != partner) // Se não for parceiro
					discourage = 20; // Penalidade maior
				else
					discourage = 10; // Penalidade normal se for parceiro
			}
			break;
        case ABILITY_SAP_SIPPER:
			if (move_type == TYPE_GRASS)
			{
				u8 partner = tai_bank ^ 2;
				if (!is_bank_present(partner) || bank_target != partner) // Se não for parceiro
					discourage = 20; // Penalidade maior
				else
					discourage = 10; // Penalidade normal se for parceiro
			}
			break;
        case ABILITY_LEVITATE:
            if (move_type == TYPE_GROUND && !new_battlestruct->various.inverse_battle)
                discourage = 10;
            break;
		case ABILITY_WONDER_GUARD:
			if (DAMAGING_MOVE(move) && tai_get_move_effectiveness() == 0 &&
				!(tai_ability == ABILITY_MOLD_BREAKER || 
				  tai_ability == ABILITY_TERAVOLT || 
				  tai_ability == ABILITY_TURBOBLAZE))
				discourage = 20;
			break;
        case ABILITY_SOUNDPROOF:
            if (find_move_in_table(move, &sound_moves[0]))
                discourage = 10;
            break;
        case ABILITY_OVERCOAT:
            if (find_move_in_table(move, &powder_moves[0]))
                discourage = 10;
            break;
        case ABILITY_BULLETPROOF:
            if (find_move_in_table(move, &ball_bomb_moves[0]))
                discourage = 10;
            break;
        case ABILITY_AROMA_VEIL:
            if (move == MOVE_ATTRACT || move == MOVE_DISABLE || move == MOVE_ENCORE || move == MOVE_HEAL_BLOCK || move == MOVE_TAUNT || move == MOVE_TORMENT)
                discourage = 10;
            break;
		case ABILITY_SWEET_VEIL:
			if (script_id == 12 || script_id == 131 || move == MOVE_RELIC_SONG)
				discourage = 10;
			break;
        case ABILITY_FLOWER_VEIL:
            if (tai_does_flower_veil_negate(move))
                discourage = 10;
            break;
        case ABILITY_CLEAR_BODY:
        case ABILITY_WHITE_SMOKE:
		case ABILITY_FULL_METAL_BODY:
            if (does_move_lower_target_stat(move, tai_bank, bank_target))
                discourage = 10;
            break;
        case ABILITY_BIG_PECKS:
            if (does_move_lower_target_stat(move, tai_bank, bank_target) && get_stat_move_changes(move) == STAT_DEFENCE)
                discourage = 10;
            break;
		case ABILITY_HYPER_CUTTER:
			if (does_move_lower_target_stat(move, tai_bank, bank_target) && 
				get_stat_move_changes(move) == STAT_ATTACK)
			{
				// Verifica as exceções específicas
				if (move != MOVE_PLAY_NICE && 
					move != MOVE_NOBLE_ROAR && 
					move != MOVE_TEARFUL_LOOK && 
					move != MOVE_VENOM_DRENCH)
				{
					discourage = 10;
				}
			}
			break;
        case ABILITY_KEEN_EYE:
            if (does_move_lower_target_stat(move, tai_bank, bank_target) && get_stat_move_changes(move) == STAT_ACCURACY)
                discourage = 10;
            break;
		case ABILITY_DEFIANT:  // Só reage a redução de Ataque
			if (does_move_lower_target_stat(move, tai_bank, bank_target) && !is_bank_ai(bank_target) && get_stat_move_changes(move) == STAT_ATTACK)
			{
				discourage = 8;
			}
			break;
		case ABILITY_COMPETITIVE:  // Só reage a redução de Ataque Especial
			if (does_move_lower_target_stat(move, tai_bank, bank_target) && !is_bank_ai(bank_target) && get_stat_move_changes(move) == STAT_SP_ATK)
			{
				discourage = 8;
			}
			break;
        case ABILITY_COMATOSE:
            if (tai_does_flower_veil_negate(move))
                discourage = 10;
            break;
		case ABILITY_SHIELDS_DOWN:
			if (is_shields_down_protected(bank_target) && tai_does_flower_veil_negate(move))
			{
				discourage = 10;
			}
			break;
		case ABILITY_LEAF_GUARD:
			if ((battle_weather.int_bw & (weather_sun | weather_harsh_sun)) &&  // Parênteses ESSENCIAIS
				ai_get_item_effect(bank_target, 1) != ITEM_EFFECT_UTILITYUMBRELLA &&  // Não tem guarda-chuva
				tai_does_flower_veil_negate(move))  // Usa a função existente para verificar efeitos
			{
				discourage = 10;
			}
			break;
        case ABILITY_MAGIC_BOUNCE:
            if (move_table[move].move_flags.flags.affected_by_magic_coat)
                discourage = 20;
            break;
        }
		// Check target's partner abilities
		u8 targets_ally = bank_target ^ 2;
		if (is_bank_present(targets_ally) && !discourage)
		{
			u8 partner_ability = ai_get_ability(targets_ally, 1);
			// Primeiro verifica bloqueios genéricos
			if (can_partner_ability_block_move(tai_bank, bank_target, move, partner_ability))
			{
				discourage = 20;
			}
			else // Depois verifica habilidades específicas
			{
				switch (partner_ability)
				{
					case ABILITY_STORM_DRAIN:
						if (move_type == TYPE_WATER)
							discourage = 20;
						break;
						
					case ABILITY_LIGHTNING_ROD:
						if (move_type == TYPE_ELECTRIC)
							discourage = 20;
						break;
						
					case ABILITY_MAGIC_BOUNCE:
						if (move_table[move].move_flags.flags.affected_by_magic_coat && 
						   (get_move_table_target(move, tai_bank) & (move_target_both | move_target_foes_and_ally | move_target_opponent_field)))
							discourage = 20;
						break;
						
					case ABILITY_AROMA_VEIL:
						if (move == MOVE_ATTRACT || move == MOVE_DISABLE || move == MOVE_ENCORE || 
							move == MOVE_HEAL_BLOCK || move == MOVE_TAUNT || move == MOVE_TORMENT)
							discourage = 10;
						break;
						
					case ABILITY_SWEET_VEIL:
						if (script_id == 12 || script_id == 131) // SLEEP ou YAWN
							discourage = 10;
						break;
						
					case ABILITY_FLOWER_VEIL:
						if (tai_does_flower_veil_negate(move))
							discourage = 10;
						break;
						
					case ABILITY_DAZZLING:
					case ABILITY_QUEENLY_MAJESTY:
						if (move_table[move].priority > 0)
							discourage = 10;
						break;
				}
			}
		}
    }
    AI_STATE->score[AI_STATE->moveset_index] -= discourage;
    tai_current_instruction++;
}

void tai2B_affected_by_substitute()
{
    u32* var = &AI_STATE->var;
    bank_attacker = tai_bank;
    current_move = AI_STATE->curr_move;
    if (affected_by_substitute(bank_target))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction++;
}

void tai33_is_in_semiinvulnerable_state() //u8 bank
{
    u32* var = &AI_STATE->var;
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    if (SEMI_INVULNERABLE(bank))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 2;
}

void tai36_jumpifweather() //u32 weather, void* ptr
{
    if (battle_weather.int_bw & (read_word(tai_current_instruction + 1)))
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 5));
    else
        tai_current_instruction += 9;
}

void tai3F_jumpifhasmove() //u8 bank, u16 move, void* ptr
{

    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u16 move = read_hword(tai_current_instruction + 2);
    for (u8 i = 0; i < 4; i++)
    {
        if (ai_get_move(bank, i) == move)
        {
            tai_current_instruction = (void*) (read_word(tai_current_instruction + 4));
            return;
        }
    }
    tai_current_instruction += 8;
    return;
}

u8 ai_strikesfirst(u8 bank1, u8 bank2)
{
    save_bank_stuff(bank1);
    save_bank_stuff(bank2);
    u8 strikes_first;
    if (get_first_to_strike(bank1, bank2, 0) == 0)
        strikes_first = 1;
    else
        strikes_first = 0;
    restore_bank_stuff(bank1);
    restore_bank_stuff(bank2);
    return strikes_first;
}

void tai28_jumpifstrikesfirst(void) //u8 bank1, u8 bank2, void* ptr
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    if (ai_strikesfirst(bank1, bank2))
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
    else
        tai_current_instruction += 7;
}

void tai29_jumpifstrikessecond(void)
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    if (!ai_strikesfirst(bank1, bank2))
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
    else
        tai_current_instruction += 7;
}

void tai51_getprotectuses(void) //u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u32* var = &AI_STATE->var;
    if (move_table[last_used_moves[bank]].script_id == 34)
        *var = disable_structs[bank].protect_uses;
    else
        *var = 0;
    tai_current_instruction += 2;
}

void tai52_movehitssemiinvulnerable(void) //u8 bank, u16 move
{
    u8 hits = 0;
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u16 move = read_hword(tai_current_instruction + 2);
    if (move == 0 || move == 0xFFFF)
        move = AI_STATE->var;
    if ((status3[bank].on_air || new_battlestruct->bank_affecting[bank].sky_drop_target || new_battlestruct->bank_affecting[bank].sky_drop_attacker) && (find_move_in_table(move, &moveshitting_onair[0]) || (is_of_type(tai_bank, TYPE_POISON) && current_move == MOVE_TOXIC)))
        hits = 1;
    else if (status3[bank].underground && (find_move_in_table(move, &moveshitting_underground[0]) || (is_of_type(tai_bank, TYPE_POISON) && current_move == MOVE_TOXIC)))
        hits = 1;
    else if (status3[bank].underwater && (find_move_in_table(move, &moveshitting_underwater[0]) || (is_of_type(tai_bank, TYPE_POISON) && current_move == MOVE_TOXIC)))
        hits = 1;
    AI_STATE->var = hits;
    tai_current_instruction += 4;
}

void tai53_getmovetarget(void)
{
    AI_STATE->var = get_move_table_target(AI_STATE->curr_move,tai_bank);
    tai_current_instruction++;
}

void tai54_getvarmovetarget(void)
{
    AI_STATE->var = get_move_table_target(AI_STATE->var,tai_bank);
    tai_current_instruction++;
}

void tai55_isstatchangepositive(void)
{
    u16 move = AI_STATE->curr_move;
    u8 positive;
    if (get_move_table_target(move,tai_bank) == move_target_user)
        positive = does_move_raise_attacker_stat(move, tai_bank);
    else
        positive = !does_move_lower_target_stat(move, tai_bank, bank_target);
    AI_STATE->var = positive;
    tai_current_instruction++;
}

void tai56_getstatvaluemovechanges(void) //u8 bank
{
    u8 stat = get_stat_move_changes(AI_STATE->curr_move);
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    AI_STATE->var = *((&battle_participants[bank].hp_buff) + stat);
    tai_current_instruction += 2;
}

void tai57_jumpifbankaffecting(void) //u8 bank, u8 case, void* ptr
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 value = 0;
    struct bank_affecting* bank_aff = &new_battlestruct->bank_affecting[bank];
    switch (read_byte(tai_current_instruction + 2))
    {
    case 0: //heal block
        value = bank_aff->heal_block;
        break;
    case 1: //embargo
        value = bank_aff->embargo;
        break;
    case 2: //gastro acid
        value = bank_aff->gastro_acided;
        break;
    case 3: //miracle eye
        value = bank_aff->miracle_eyed;
        break;
    case 4: //aqua ring
        value = bank_aff->aqua_ring;
        break;
    case 5: //magnet rise
        value = bank_aff->magnet_rise;
        break;
    case 6: //telekinesis
        value = bank_aff->telekinesis;
        break;
    case 7: //laser focus
        value = bank_aff->always_crit;
        break;
    case 8: //power trick
        value = bank_aff->powertrick;
        break;
    case 9: //smacked own
        value = bank_aff->smacked_down;
        break;
    case 10: //smacked own
        value = bank_aff->baneful_bunker;
        break;
    case 11: //smacked own
        value = bank_aff->obstruct;
        break;
    }
    if (value)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
    else
        tai_current_instruction += 7;
}

void tai63_jumpiffieldaffecting(void) //u8 case, void* ptr
{
    u8 value = 0;
    struct field_affecting* Field = &new_battlestruct->field_affecting;
    switch (read_byte(tai_current_instruction + 1))
    {
    case 0: //gravity
        value =Field->gravity;
        break;
    case 1: //trick room
        value = Field->trick_room;
        break;
    case 2: //wonder room
        value = Field->wonder_room;
        break;
    case 3: //magic room
        value = Field->magic_room;
        break;
    case 4: //terrains
        switch (AI_STATE->curr_move)
        {
        case MOVE_ELECTRIC_TERRAIN:
            value = Field->electic_terrain;
            break;
        case MOVE_GRASSY_TERRAIN:
            value = Field->grassy_terrain;
            break;
        case MOVE_MISTY_TERRAIN:
            value = Field->misty_terrain;
            break;
        case MOVE_PSYCHIC_TERRAIN:
            value = Field->psychic_terrain;
            break;
        }
        break;
	case 5: //Misty Terrain
		value = Field->misty_terrain;
			break;
	case 6: //Grassy Terrain
		value = Field->grassy_terrain;
			break;
	case 7: //Electic Terrain
		value = Field->electic_terrain;
			break;
	case 8: //Psychic Terrain
		value = Field->psychic_terrain;
			break;
	case 9: //Fairy Lock
		value = Field->fairy_lock;
			break;
	case 10: //Ion Deluge
		value = Field->ion_deluge;
			break;
    }
    if (value)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 2));
    else
        tai_current_instruction += 6;
}

void tai64_isbankinlovewith(void) //u8 bank1, u8 bank2
{
    u32* var = &AI_STATE->var;
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    if (battle_participants[bank1].status2.in_love & (bits_table[bank2]))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 3;
}

void tai65_vartovar2(void)
{
    new_battlestruct->trainer_AI.var2 = AI_STATE->var;
    tai_current_instruction++;
}

void tai66_jumpifvarsEQ(void) //void* ptr
{
    if (new_battlestruct->trainer_AI.var2 == AI_STATE->var)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 1));
    else
        tai_current_instruction += 5;
}

void tai67_jumpifcantaddthirdtype(void) //u8 bank, void* ptr
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    if (is_of_type(bank, move_table[AI_STATE->curr_move].arg1))
        tai_current_instruction += 6;
    else
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 2));
}

void tai68_canchangeability(void) //u8 bank1, u8 bank2
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    u8 ability1 = ai_get_ability(bank1, 0);
    u8 ability2 = ai_get_ability(bank2, 0);
    u8 can = 1;
    u16 move = AI_STATE->curr_move;
    switch (move_table[move].arg1)
    {
        case 0:
        case 1:
        case 2:
            if (ability1 == ability2)
                can = 0;
            break;
        case 3:
            if (ability2 == move_table[move].arg2)
                can = 0;
            break;
    }
    AI_STATE->var = can;
    tai_current_instruction += 3;
}

void tai69_getitempocket(void) //u8 bank
{
    u16 item = 0;
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    if (is_bank_ai(bank) || get_item_effect(bank, 0))
        item = battle_participants[bank].held_item;
    AI_STATE->var = get_item_pocket_id(item);
    tai_current_instruction += 2;
}

void tai6A_discouragehazards(void)
{
    u8 to_sub = 0;
    u8 side = get_bank_side(bank_target);

    // Obtém o movimento atual
    u16 move = AI_STATE->curr_move;

    // Recupera o movimento escolhido pelo parceiro (var2)
    u16 partner_move = 0;
    if (tai_bank == 3)
        partner_move = battle_participants[1].moves[battle_stuff_ptr->chosen_move_position[1]];

    switch (move)
    {
    case MOVE_STICKY_WEB:
        // Penaliza se já foi usado
        if (new_battlestruct->side_affecting[side].sticky_web)
            to_sub = 10;
        // Se o parceiro também escolheu Sticky Web, evita redundância
        else if (partner_move == MOVE_STICKY_WEB && new_battlestruct->side_affecting[side].sticky_web)
            to_sub = 10;
        break;

    case MOVE_SPIKES:
        // 3 camadas já no campo
        if (side_timers[side].spikes_amount >= 3 && side_affecting_halfword[side].spikes_on)
            to_sub = 10;
        // Parceiro tentando aplicar a 3ª camada (já temos 2)
        else if (partner_move == MOVE_SPIKES && side_timers[side].spikes_amount == 2)
            to_sub = 10;
        break;

    case MOVE_TOXIC_SPIKES:
        // 2 camadas = máximo
        if (new_battlestruct->side_affecting[side].toxic_spikes_badpsn)
            to_sub = 10;
        // Parceiro tentando aplicar a 2ª camada (já temos 1)
        else if (partner_move == MOVE_TOXIC_SPIKES && new_battlestruct->side_affecting[side].toxic_spikes_psn)
            to_sub = 10;
        break;

    case MOVE_STEALTH_ROCK:
        // Se já está no campo
        if (new_battlestruct->side_affecting[side].stealthrock)
            to_sub = 10;
        // Se o parceiro também está tentando usar Stealth Rock
        else if (partner_move == MOVE_STEALTH_ROCK)
            to_sub = 10;
        break;
    }

    AI_STATE->score[AI_STATE->moveset_index] -= to_sub;
    tai_current_instruction++;
}

void tai6B_sharetype(void) //u8 bank1, u8 bank2
{
    u8 banks[2];
    banks[0] = get_ai_bank(read_byte(tai_current_instruction + 1));
    banks[1] = get_ai_bank(read_byte(tai_current_instruction + 2));
    u8 types[2][3];
    for (u8 i = 0; i < 2; i++)
    {
        types[i][0] = battle_participants[banks[i]].type1;
        types[i][1] = battle_participants[banks[i]].type2;
        types[i][2] = new_battlestruct->bank_affecting[banks[i]].type3;
    }
    u8 same_type = 0;
    for (u8 i = 0; i < 3; i++)
    {
        u8 curr_type = types[0][i];
        if (curr_type != TYPE_EGG && (curr_type == types[1][0] || curr_type == types[1][1] || curr_type == types[1][2]))
        {
            same_type = 1;
            break;
        }
    }
    AI_STATE->var = same_type;
    tai_current_instruction += 3;
}

void tai6C_isbankpresent(void) //u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u32* var = &AI_STATE->var;
    if (is_bank_present(bank))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 2;
}

void tai6D_jumpifwordvarEQ() //u32 word, void* ptr
{
    u32 word = read_word(tai_current_instruction + 1);
    if (word == AI_STATE->var)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 5));
    else
        tai_current_instruction += 9;
}

void tai6E_islockon_on() //u8 bankattacker, u8 banktarget
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    u32* var = &AI_STATE->var;
    if (status3[bank2].always_hits && disable_structs[bank2].always_hits_bank == bank1)
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 3;
}

void tai6F_discouragesports()
{
    u8 discourage = 0;
    switch (AI_STATE->curr_move)
    {
    case MOVE_WATER_SPORT:
        discourage = new_battlestruct->field_affecting.watersport;
        break;
    case MOVE_MUD_SPORT:
        discourage = new_battlestruct->field_affecting.mudsport;
        break;
    }
    if (discourage)
        AI_STATE->score[AI_STATE->moveset_index] -= 10;
    tai_current_instruction++;
}

void tai70_jumpifnewsideaffecting(void) //u8 bank, u8 case, void* ptr
{
    u8 side = get_bank_side(get_ai_bank(read_byte(tai_current_instruction + 1)));
    u8 value = 0;
    struct side_affecting* SideAff = &new_battlestruct->side_affecting[side];
    switch (read_byte(tai_current_instruction + 2))
    {
    case 0: //tailwind
        value = SideAff->tailwind;
        break;
    case 1: //lucky chant
        value = SideAff->lucky_chant;
        break;
    case 2: //aurora veil
        value = SideAff->aurora_veil;
        break;
    case 3: //grass pledge (swamp effect: reduce Speed)
        value = SideAff->swamp_spd_reduce;
        break;
    case 4: //fire pledge (sea of fire effect: damage at end of turn)
        value = SideAff->sea_of_fire;
        break;
    case 5: //water pledge (rainbow effect: boosts secondary effect chances)
        value = SideAff->rainbow;
        break;
    case 6: //mat block
        value = SideAff->mat_block;
        break;
    case 7: //wide guard
        value = SideAff->wide_guard;
        break;
    case 8: //quick guard
        value = SideAff->quick_guard;
        break;
    }
    if (value)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
    else
        tai_current_instruction += 7;
}

void tai71_getmovesplit()
{
    AI_STATE->var = move_table[AI_STATE->curr_move].split;
    tai_current_instruction++;
}

void tai72_cantargetfaintuser() // u8 amount of hits
{
    bool can = 0;
    u8 amount_of_hits = read_byte(tai_current_instruction + 1);
    if (amount_of_hits == 0)
        amount_of_hits = 1;
    u8 target_bank = bank_target;
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank_target, i);
        if (move && DAMAGING_MOVE(move))
        {
            u32 damage = ai_calculate_damage(target_bank, tai_bank, move) * amount_of_hits;
            if (battle_participants[tai_bank].current_hp <= damage)
            {
                can = 1;
                break;
            }
        }
    }
    AI_STATE->var = can;
    tai_current_instruction += 2;
}

void tai73_hashighcriticalratio()
{
    AI_STATE->var = move_table[AI_STATE->curr_move].move_flags.flags.raised_crit_ratio;
    tai_current_instruction++;
}

u8 get_move_accuracy(u16 move)
{
    return move_table[move].accuracy;
}

void tai74_getmoveaccuracy()
{
    AI_STATE->var = get_move_accuracy(AI_STATE->curr_move);
    tai_current_instruction++;
}

u8 has_any_move_with_split(u8 bank, u8 split)
{
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move && move_table[move].split == split)
            return 1;
    }
    return 0;
}

u8 get_base_stat(u8 bank, u8 stat)
{
    u16 species = ai_get_species(bank);
    const u8* stat_value = stat + &((*basestat_table)[species].base_hp);
    return *stat_value;
}

u8 get_attacker_type(u8 bank) //0 = physical attacker, 1 = special attacker, 2 = mixed
{
    u8 physical_points = 0;
    u8 special_points = 0;
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move)
        {
            u8 split = move_table[move].split;
            if (split == MOVE_PHYSICAL)
                physical_points++;
            else if (split == MOVE_SPECIAL)
                special_points++;
        }
    }
    u8 atk_value = get_base_stat(bank, STAT_ATTACK);
    u8 spatk_value = get_base_stat(bank, STAT_SP_ATK);
    s8 atk_spatk_difference = atk_value - spatk_value;
    if (atk_spatk_difference > 40)
        physical_points += 3;
    else if (atk_spatk_difference > 20)
        physical_points++;
    else if (atk_spatk_difference < -40)
        special_points += 3;
    else if (atk_spatk_difference < -20)
        special_points++;
    if (physical_points > special_points)
        return 0;
    else if (special_points > physical_points)
        return 1;
    else
        return 2;
}

s8 get_defraise_worth(u8 stat) //def raising, atk lowering
{
    s8 value = 0;
    switch (get_attacker_type(bank_target))
    {
    case 0:
        if (stat == STAT_DEFENCE)
            value = 2;
        else
            value = -1;
        break;
    case 1:
        if (stat == STAT_DEFENCE)
            value = -1;
        else
            value = 2;
        break;
    case 2:
        value = 1;
        break;
    }
    u8 ally_bank = bank_target ^ 2;
    if (is_bank_present(ally_bank))
    {
        switch (get_attacker_type(ally_bank))
        {
            case 0:
                if (stat == STAT_DEFENCE)
                    value += 1;
                else
                    value += -1;
                break;
            case 1:
                if (stat == STAT_DEFENCE)
                    value += -1;
                else
                    value += 1;
                break;
            case 2:
                value = 1;
                break;
        }
    }
    return value;
}

s8 get_atklower_worth(u8 stat)
{
    s8 value = 0;
    switch (get_attacker_type(bank_target))
    {
        case 0:
            if (stat == STAT_ATTACK)
                value = 2;
            else
                value = -1;
            break;
        case 1:
            if (stat == STAT_ATTACK)
                value = -1;
            else
                value = 2;
            break;
        case 2:
            value = 1;
            break;
    }
    return value;
}

u8 is_poke_identified(u8 bank)
{
    if (new_battlestruct->bank_affecting[bank].miracle_eyed || battle_participants[bank].status2.foresight)
        return 1;
    return 0;
}

u8 has_move_with_accuracy_lower(u8 bank, u8 acc)
{
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        u8 move_acc = get_move_accuracy(move);
        if (move_acc <= 1)
            move_acc = 100;
        if (move && move_acc < acc)
            return 1;
    }
    return 0;
}

u8 cant_become_confused(u8 bank);
u8 cant_fall_asleep(u8 bank, u8 self_inflicted);
u8 cant_become_burned(u8 bank, u8 self_inflicted);
u8 cant_become_freezed(u8 bank, u8 self_inflicted);
u8 cant_become_paralyzed(u8 bank, u8 self_inflicted);
u8 cant_poison(u8 atk_bank, u8 def_bank, u8 self_inflicted);
void tai75_logiconestatuser()
{
    s8 value = 0;
    u16 move = AI_STATE->curr_move;
    switch (get_stat_move_changes(move))
    {
        case STAT_ATTACK:
            if (has_any_move_with_split(tai_bank, MOVE_PHYSICAL))
                value = 2;
            else
                value = -2;
            break;
        case STAT_SP_ATK:
            if (has_any_move_with_split(tai_bank, MOVE_SPECIAL))
                value = 2;
            else
                value = -2;
            break;
        case STAT_DEFENCE:
            value = get_defraise_worth(STAT_DEFENCE);
            break;
        case STAT_EVASION:
            if (is_poke_identified(tai_bank) || ai_get_ability(tai_bank, 1) == ABILITY_NO_GUARD || ai_get_ability(bank_target, 1) == ABILITY_NO_GUARD)
                value = -2;
            break;
        case STAT_SPD:
            if (ai_strikesfirst(tai_bank, bank_target) || ai_get_ability(tai_bank, 1) == ABILITY_SPEED_BOOST)
                value = -1;
            else
                value = 2;
            break;
        case STAT_SP_DEF:
            value = get_defraise_worth(STAT_SP_DEF);
            break;
    }
    tai_current_instruction++;
    AI_STATE->score[AI_STATE->moveset_index] += value;
}

void tai76_logiconestattarget()
{
    s8 value = 0;
    u16 move = AI_STATE->curr_move;
    switch (get_stat_move_changes(move))
    {
        case STAT_ATTACK:
            value = get_atklower_worth(STAT_ATTACK);
            break;
        case STAT_SP_ATK:
            value = get_atklower_worth(STAT_SP_ATK);
            break;
        case STAT_DEFENCE:
            if (has_any_move_with_split(tai_bank, MOVE_PHYSICAL))
                value = 2;
            else
            {
                u8 ally_bank = tai_bank ^ 2;
                if (is_bank_present(tai_bank) && has_any_move_with_split(ally_bank, MOVE_PHYSICAL))
                    value = 1;
                else
                    value = -2;
            }
            break;
        case STAT_SP_DEF:
            if (has_any_move_with_split(tai_bank, MOVE_SPECIAL))
                value = 2;
            else
            {
                u8 ally_bank = tai_bank ^ 2;
                if (is_bank_present(tai_bank) && has_any_move_with_split(ally_bank, MOVE_SPECIAL))
                    value = 1;
                else
                    value = -2;
            }
            break;
        case STAT_EVASION:
            if (is_poke_identified(bank_target) || ai_get_ability(tai_bank, 1) == ABILITY_NO_GUARD || ai_get_ability(bank_target, 1) == ABILITY_NO_GUARD)
                value = -2;
            else if (has_move_with_accuracy_lower(tai_bank, 90))
                value = 1;;
            break;
        case STAT_SPD:
            if (ai_strikesfirst(bank_target, tai_bank) || ai_get_ability(bank_target, 1) == ABILITY_SPEED_BOOST)
                value = -1;
            else
                value = 2;
            break;
		case STAT_CONFUSION:
			if(cant_become_confused(bank_target))
				value=-1;
			else
				value=3;
    }
    tai_current_instruction++;
	AI_STATE->score[AI_STATE->moveset_index] += value;
}

void tai77_abilitypreventsescape() //u8 bank1, u8 bank2
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    AI_STATE->var = is_ability_preventing_switching(bank1, bank2);
    tai_current_instruction += 3;
}

void tai78_setbytevar() //u8 value
{
    AI_STATE->var = (read_byte(tai_current_instruction + 1));
    tai_current_instruction += 2;
}

void tai79_arehazardson() //u8 bank
{
    u32* var = &AI_STATE->var;
    u8 side = get_bank_side(get_ai_bank(read_byte(tai_current_instruction + 1)));
    if (new_battlestruct->side_affecting[side].sticky_web ||
        (side_timers[side].spikes_amount && side_affecting_halfword[side].spikes_on) ||
        new_battlestruct->side_affecting[side].stealthrock ||
        (new_battlestruct->side_affecting[side].toxic_spikes_psn || new_battlestruct->side_affecting[side].toxic_spikes_badpsn))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 2;
}

void tai7A_gettypeofattacker() //u8 bank;
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    AI_STATE->var = get_attacker_type(bank);
    tai_current_instruction += 2;
}

void tai7B_hasanymovewithsplit() //u8 bank, u8 split
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 split = read_byte(tai_current_instruction + 2);
    AI_STATE->var = has_any_move_with_split(bank, split);
    tai_current_instruction += 3;
}

void tai7C_hasprioritymove() //u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 ability = ai_get_ability(bank, 1);
    u8 has = 0;
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move)
        {
            if (move_table[move].priority > 0 ||
                (ability == ABILITY_GALE_WINGS && tai_getmovetype(tai_bank, move) == TYPE_FLYING) ||
                (ability == ABILITY_PRANKSTER && move_table[move].split == 2))
            {
                has = 1;
                break;
            }
        }
    }
    AI_STATE->var = has;
    tai_current_instruction += 2;
}

void tai7D_getbestdamage_lefthp() //u8 attacker, u8 target
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    u32 best_damage = 0;
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank1, i);
        if (move && DAMAGING_MOVE(move))
        {
            u32 dmg = ai_calculate_damage(bank1, bank2, move);
            if (dmg > best_damage)
                best_damage = dmg;
        }
    }
    u16 curr_hp = battle_participants[bank2].current_hp;
    if (best_damage > curr_hp)
        best_damage = curr_hp;
    AI_STATE->var = ((curr_hp - best_damage) * 100) / battle_participants[bank2].max_hp;
    tai_current_instruction += 3;
}

void tai7E_isrecoilmove_necessary()
{
    u8 no_of_dmg_move = 0;
    u8 not_recoil_ids[4] = {0};
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(tai_bank, i);
        u8 script_id = move_table[move].script_id;
        if (move && battle_participants[tai_bank].current_pp[i] && DAMAGING_MOVE(move) && script_id != 19)
        {
            no_of_dmg_move++;
            not_recoil_ids[i] = 1;
        }
    }
    u32 RecoilMoveDMG = 0;
    u32 BestNotRecoilMoveDmg = 0;
    u8 is_neccessary = 1;
    if (no_of_dmg_move)
    {
        for (u8 i = 0; i < 4; i++)
        {
            if (not_recoil_ids[i])
            {
                u32 damage = ai_calculate_damage(tai_bank, bank_target, ai_get_move(tai_bank, i));
                if (damage > BestNotRecoilMoveDmg)
                    BestNotRecoilMoveDmg = damage;
            }
            else if (i == AI_STATE->moveset_index)
            {
                RecoilMoveDMG = ai_calculate_damage(tai_bank, bank_target, AI_STATE->curr_move);
            }
        }
        u16 target_HP = battle_participants[bank_target].current_hp;
        if (BestNotRecoilMoveDmg > RecoilMoveDMG || BestNotRecoilMoveDmg >= target_HP)
            is_neccessary = 0;
        else if (BestNotRecoilMoveDmg && RecoilMoveDMG < target_HP) //recoil move doesn't faint
        {
            u32 RecoilMoveHitsToFaint = 0;
            u32 NotRecoilMoveHitsToFaint = 0;
            while (RecoilMoveDMG * RecoilMoveHitsToFaint < target_HP)
                RecoilMoveHitsToFaint++;
            while (BestNotRecoilMoveDmg * NotRecoilMoveHitsToFaint < target_HP)
                NotRecoilMoveHitsToFaint++;
            if (RecoilMoveHitsToFaint == NotRecoilMoveHitsToFaint)
                is_neccessary = 0;
        }
    }
    AI_STATE->var = is_neccessary;
    tai_current_instruction++;
}

void tai7F_isintruantturn() //u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u32* var = &AI_STATE->var;
    if (check_ability(bank, ABILITY_TRUANT) && !(disable_structs[bank].truant_counter & 1))
    {
        *var = 1;
    }
    else
    {
        *var = 0;
    }
    tai_current_instruction += 2;
}

void tai80_getmoveeffectchance()
{
    AI_STATE->var = move_table[AI_STATE->curr_move].effect_chance;
    tai_current_instruction++;
}

void tai81_hasmovewithaccuracylower() //u8 bank, u8 acc
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 acc = read_byte(tai_current_instruction + 2);
    u32* var = &AI_STATE->var;
    if (has_move_with_accuracy_lower(bank, acc))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 3;
}

void tai82_getpartnerchosenmove()
{
    u16 move = 0;
    if (tai_bank == 3)
        move = battle_participants[1].moves[battle_stuff_ptr->chosen_move_position[1]];
    AI_STATE->var = move;
    tai_current_instruction++;
}

void tai83_hasanydamagingmoves() //u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 has = 0;
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move && DAMAGING_MOVE(move))
        {
            has = 1;
            break;
        }
    }
    AI_STATE->var = has;
    tai_current_instruction += 2;
}

#define min_stat_stage 0
#define default_stat_stage 6
#define max_stat_stage 12

// Adicione esta função se não existir
static bool BattlerStatCanRise(u8 bank, u8 ability, u8 stat) {
    u8* stat_val = &battle_participants[bank].atk_buff + stat;
    if (*stat_val >= max_stat_stage) // max_stat_stage deve ser definido como 12
        return false;
    
    // Verifica habilidades como Contrary
    if (ability == ABILITY_CONTRARY) {
        return (*stat_val > min_stat_stage); // min_stat_stage deve ser 0
    }
    return (*stat_val < max_stat_stage);
}

// Adicionar estas novas funções auxiliares
static bool tai_can_use_magnetic_flux(u8 bank)
{
    u8 partner = bank ^ 2;
    u8 ability = ai_get_ability(bank, 1);
    
    if (ability == ABILITY_PLUS || ability == ABILITY_MINUS)
    {
        if (BattlerStatCanRise(bank, ability, STAT_DEFENCE) &&
           BattlerStatCanRise(bank, ability, STAT_SP_DEF))
            return true;
    }
    
    if (is_bank_present(partner))
    {
        u8 partner_ability = ai_get_ability(partner, 1);
        if (partner_ability == ABILITY_PLUS || partner_ability == ABILITY_MINUS)
        {
            if (BattlerStatCanRise(partner, partner_ability, STAT_DEFENCE) &&
               BattlerStatCanRise(partner, partner_ability, STAT_SP_DEF))
                return true;
        }
    }
    
    return false;
}

static bool tai_can_use_gear_up(u8 bank)
{
    u8 partner = bank ^ 2;
    bool has_physical = has_any_move_with_split(bank, MOVE_PHYSICAL);
    bool has_special = has_any_move_with_split(bank, MOVE_SPECIAL);
    
    if (ai_get_ability(bank, 1) == ABILITY_PLUS || ai_get_ability(bank, 1) == ABILITY_MINUS)
    {
        if ((!BattlerStatCanRise(bank, ai_get_ability(bank, 1), STAT_ATTACK) || !has_physical) &&
            (!BattlerStatCanRise(bank, ai_get_ability(bank, 1), STAT_SP_ATK) || !has_special))
            return false;
    }
    else if (is_bank_present(partner) && 
            (ai_get_ability(partner, 1) == ABILITY_PLUS || 
             ai_get_ability(partner, 1) == ABILITY_MINUS))
    {
        if ((!BattlerStatCanRise(partner, ai_get_ability(partner, 1), STAT_ATTACK) || !has_physical) &&
            (!BattlerStatCanRise(partner, ai_get_ability(partner, 1), STAT_SP_ATK) || !has_special))
            return false;
    }
    else
    {
        return false;
    }
    return true;
}

// Atualizar a função existente
void tai84_jumpifcantusemove()
{
    u8 can = 1;
    bank_attacker = tai_bank;
    void* saved_battlescript_ptr = battlescripts_curr_instruction;
    void* ptr = (void*) 0x08000000;
    battlescripts_curr_instruction = ptr;
    u16 move = AI_STATE->curr_move;
    
    switch (move) {
        case MOVE_LAST_RESORT:
            current_move = move;
            canuselastresort();
            if (battlescripts_curr_instruction != (ptr + 4)) can = 0;
            break;
        case MOVE_BELCH:
            belch_canceler();
            if (battlescripts_curr_instruction != ptr) can = 0;
            break;
        case MOVE_MAGNETIC_FLUX:
            if (!tai_can_use_magnetic_flux(tai_bank)) can = 0;
            break;
        case MOVE_GEAR_UP:
            if (!tai_can_use_gear_up(tai_bank)) can = 0;
            break;
        case MOVE_ENDEAVOR:
            if ((s16)(battle_participants[bank_target].current_hp - 
                     battle_participants[bank_attacker].current_hp) <= 0)
                can = 0;
            break;
    }
    
    battlescripts_curr_instruction = saved_battlescript_ptr;
    if (can)
        tai_current_instruction += 5;
    else
        tai_current_instruction = (void*)(read_word(tai_current_instruction + 1));
}

void tai85_canmultiplestatwork(void)
{
    u8 bank;
    u8 max;
    u16 move = AI_STATE->curr_move;
    if (get_move_table_target(move,tai_bank) == move_target_user)
        bank = bank_attacker;
    else
        bank = bank_target;
    if (move_table[move].arg2 >= 0x90)
        max = 0;
    else
        max = 0xC-2;
    u8 can = 0;
    u8 stats_to_change = move_table[move].arg1;
    for (u8 i = 0; i < 7; i++)
    {
        if (stats_to_change & bits_table[i])
        {
            u8* stat = &battle_participants[bank].atk_buff + i;
            if (*stat < max)
            {
                can = 1;
                break;
            }
        }
    }
    AI_STATE->var = can;
    tai_current_instruction++;
}

void tai86_jumpifhasattackingmovewithtype(void) //u8 bank, u8 type, void* ptr
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 type = read_byte(tai_current_instruction + 2);
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move && move_table[move].type == type && DAMAGING_MOVE(move))
        {
            tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
            return;
        }
    }
    tai_current_instruction += 7;
}

void tai87_jumpifhasnostatusmoves() //u8 bank, void* ptr
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move && !DAMAGING_MOVE(move))
        {
            tai_current_instruction += 6;
            return;
        }
    }
    tai_current_instruction = (void*) (read_word(tai_current_instruction + 2));
}

void tai88_jumpifstatusmovesnotworthusing() //u8 bank, void* ptr
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i);
        if (move && !DAMAGING_MOVE(move) && AI_STATE->score[i] >= 100)
        {
            tai_current_instruction += 6;
            return;
        }
    }
    tai_current_instruction = (void*) (read_word(tai_current_instruction + 2));
}

void tai89_jumpifsamestatboosts(void) //u8 bank1, u8 bank2, void* ptr
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    u8* boosts1 = &battle_participants[bank1].atk_buff;
    u8* boosts2 = &battle_participants[bank2].atk_buff;
    for (u8 i = 0; i < 7; i++)
    {
        if (boosts1[i] != boosts2[i])
        {
            tai_current_instruction += 7;
            return;
        }
    }
    tai_current_instruction = (void*) (read_word(tai_current_instruction + 3));
}

bool can_drain_attack(u8 attacker, u8 target, u16 move)
{
    bool drains = 0;
    u8 move_type = tai_getmovetype(attacker, move);
    u8 ability_target = ai_get_ability(target, 1);
    if (ability_target == ABILITY_SOUNDPROOF && find_move_in_table(move, sound_moves))
        drains = 1;
    else
    {
        switch (move_type)
        {
        case TYPE_FIRE:
            if (ability_target == ABILITY_FLASH_FIRE)
                drains = 1;
            break;
        case TYPE_WATER:
            if (ability_target == ABILITY_WATER_ABSORB || ability_target == ABILITY_STORM_DRAIN || ability_target == ABILITY_DRY_SKIN)
                drains = 1;
            break;
        case TYPE_ELECTRIC:
            if (ability_target == ABILITY_VOLT_ABSORB || ability_target == ABILITY_LIGHTNING_ROD)
                drains = 1;
            break;
        case TYPE_GRASS:
            if (ability_target == ABILITY_SAP_SIPPER)
                drains = 1;
            break;
        }
    }
    return drains;
}

void tai8A_can_use_multitarget_move(void)
{
    bool can = 1;
    u8 partner = tai_bank ^ 2;
    u16 curr_move = AI_STATE->curr_move;
    if (is_bank_present(partner) && move_table[curr_move].target == move_target_foes_and_ally && !can_drain_attack(tai_bank, partner, curr_move))
    {
        u32 partner_dmg = ai_calculate_damage(tai_bank, partner, curr_move);
        u16 partner_hp = battle_participants[partner].current_hp;
        if (partner_dmg >= partner_hp || (partner_dmg * 100 / battle_participants[partner].max_hp) > 15) //deals more than 15% of partner's HP
        {
             can = 0;
        }
    }
    AI_STATE->var = can;
    tai_current_instruction++;
}

/* Adicione esta função ao TrainerAi.c */
void tai8B_getmovetype(void) // u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u16 move = AI_STATE->curr_move;
    
    /* Considera: 
     * - Tipo base do movimento
     * - Efeitos que modificam tipo (ex: Ion Deluge)
     * - Habilidades que modificam tipo (ex: Aerilate)
     */
    u8 move_type = calculate_move_type(bank, move, 0);
    
    /* Se for tipo dinâmico (não padrão) */
    if (move_type == TYPE_EGG) 
	{
        move_type = move_table[move].type;
    }
    
    AI_STATE->var = move_type;
    tai_current_instruction += 2;
}

void tai8C_comparehp(void) //u8 bank1, u8 bank2
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));
    
    u16 hp1 = battle_participants[bank1].current_hp;
    u16 hp2 = battle_participants[bank2].current_hp;
    
    // Retorna:
    // 0 se hp1 == hp2
    // 1 se hp1 > hp2
    // 2 se hp1 < hp2
    if (hp1 == hp2)
        AI_STATE->var = 0;
    else if (hp1 > hp2)
        AI_STATE->var = 1;
    else
        AI_STATE->var = 2;
    
    tai_current_instruction += 3;
}

void tai8D_getmoveidbyindex(void)
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 slot = read_byte(tai_current_instruction + 2);
    AI_STATE->var = ai_get_move(bank, slot);
    tai_current_instruction += 3;
}

void tai8E_getform(void)
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    // Chama diretamente a função já existente!
    bool result = is_shields_down_protected(bank);
    AI_STATE->var = result ? 1 : 0;
    tai_current_instruction += 2;
}

// Supondo que os parâmetros sejam:
// - bank1: banco a ser comparado (ex: bank_target)
// - bank2: banco do AI (ex: bank_ai)
// - addr: endereço/script para saltar se forem aliados

// Adicione antes, se quiser, para clareza:
#define BANKS_ARE_ALLIES(b1, b2) (((b1) & 2) == ((b2) & 2))

void tai8F_jumpifally(void)
{
    u8 arg1 = read_byte(tai_current_instruction + 1);
    u8 arg2 = read_byte(tai_current_instruction + 2);
    u32 addr = read_hword(tai_current_instruction + 3);

    u8 bank1 = get_ai_bank(arg1);
    u8 bank2 = get_ai_bank(arg2);

    if (BANKS_ARE_ALLIES(bank1, bank2))
    {
        // ATENÇÃO: adapte para o tipo correto do ponteiro do seu sistema de scripts!
        // Se addr é offset relativo ao começo do script:
        tai_current_instruction = (typeof(tai_current_instruction))addr;
        return;
    }

    tai_current_instruction += 5; // opcode + 2 args + hword = 5 bytes
}

void tai90_arehazardson2() //u8 bank
{
    u32* var = &AI_STATE->var;
    u8 side = get_bank_side(get_ai_bank(read_byte(tai_current_instruction + 1)));
    if ((side_timers[side].spikes_amount && side_affecting_halfword[side].spikes_on)||
        (new_battlestruct->side_affecting[side].toxic_spikes_psn || new_battlestruct->side_affecting[side].toxic_spikes_badpsn))
        *var = 1;
    else
        *var = 0;
    tai_current_instruction += 2;
}

void tai91_hascontactmove(void)
{
    // Obtém o banco a partir do script
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    
    // Inicializa a variável indicando se possui golpe de contato
    u8 has_contact_move = 0;

    // Itera pelos movimentos do banco especificado
    for (u8 i = 0; i < 4; i++) // Cada banco tem até 4 movimentos
    {
        u16 move = ai_get_move(bank, i);
        if (move && move_table[move].move_flags.flags.makes_contact)
        {
            has_contact_move = 1; // Encontrou um golpe de contato, define como verdadeiro
            break;
        }
    }

    // Armazena o resultado em AI_STATE->var
    AI_STATE->var = has_contact_move;

    // Avança a instrução no script
    tai_current_instruction += 2; // Avança 2 bytes: comando + argumento do banco
}

void tai92_ishazardmove(void) // Verifica se o movimento do parceiro é um movimento de hazard
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Banco do parceiro
    u8 is_hazard = 0;

    // Lista de movimentos de hazard
    const u16 hazard_moves[] = 
	{
        MOVE_STEALTH_ROCK,
        MOVE_SPIKES,
        MOVE_TOXIC_SPIKES,
        MOVE_STICKY_WEB
    };

    // Loop para verificar os movimentos do banco
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i); // Obtem o ID do movimento no slot "i"
        if (find_move_in_table(move, hazard_moves)) // Verifica se o movimento está na tabela de hazard
        {
            is_hazard = 1;
            break;
        }
    }

    // Define o resultado na variável de estado
    AI_STATE->var = is_hazard;
    tai_current_instruction += 2;
}

void tai93_jumpifauroraveiltimer(void)
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Banco especificado
    u8 side = get_bank_side(bank); // Obtém o lado correspondente (aliado ou oponente)

    // Verifica se o Aurora Veil está ativo (timer > 0)
    if (new_battlestruct->side_affecting[side].aurora_veil > 0)
        tai_current_instruction = (void*)read_word(tai_current_instruction + 2); // Salta para o endereço fornecido
    else
        tai_current_instruction += 6; // Avança para o próximo comando
}

/* Função refinada para verificar se um Pokémon desmaiará devido ao clima */
void tai94_check_weather_faint(void)
{
    u8 battler = get_ai_bank(read_byte(tai_current_instruction + 1)); // Obtém o banco do Pokémon
    u8 ability = ai_get_ability(battler, 1); // Obtém a habilidade do Pokémon
    u16 current_hp = battle_participants[battler].current_hp;

    // Verifica se o clima ativo é Tempestade de Areia ou Granizo
    bool sandstorm_active = (battle_weather.int_bw & weather_sandstorm) != 0;
    bool hail_active = (battle_weather.int_bw & weather_hail) != 0;

    // Verifica imunidade a Tempestade de Areia
    bool affected_by_sandstorm = sandstorm_active &&
        !is_of_type(battler, TYPE_ROCK) &&
        !is_of_type(battler, TYPE_GROUND) &&
        !is_of_type(battler, TYPE_STEEL) &&
        ability != ABILITY_SAND_VEIL &&
        ability != ABILITY_SAND_FORCE &&
        ability != ABILITY_SAND_RUSH &&
        ability != ABILITY_OVERCOAT;

    // Verifica imunidade a Granizo
    bool affected_by_hail = hail_active &&
        !is_of_type(battler, TYPE_ICE) &&
        ability != ABILITY_SNOW_CLOAK &&
        ability != ABILITY_OVERCOAT &&
        ability != ABILITY_ICE_BODY;

    // Calcula o limite de dano como 1/16 do HP máximo
    u16 damage_threshold = get_1_16_of_max_hp(battler);

    // Verifica se o Pokémon desmaiará
    if ((affected_by_sandstorm || affected_by_hail) && current_hp <= damage_threshold)
    {
        AI_STATE->var = 1; // O Pokémon desmaiará
    }
    else
    {
        AI_STATE->var = 0; // O Pokémon não desmaiará
    }

    tai_current_instruction += 2; // Avança o ponteiro para o próximo comando
}

void tai95_get_wish_duration(void) 
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Obtém o banco baseado no argumento
    AI_STATE->var = battle_effects_duration.wish_duration[bank];   // Carrega a duração do Wish no banco especificado
    tai_current_instruction += 2;                                 // Avança o ponteiro da instrução
}

void tai96_jumpifmoveflag(void) // u8 flag, void* ptr
{
    u8 value = 0;
    u16 move = AI_STATE->curr_move;
    switch (read_byte(tai_current_instruction + 1))
    {
    case 0: // makes_contact
        value = move_table[move].move_flags.flags.makes_contact;
        break;
    case 1: // affected_by_protect
        value = move_table[move].move_flags.flags.affected_by_protect;
        break;
    case 2: // affected_by_magic_coat
        value = move_table[move].move_flags.flags.affected_by_magic_coat;
        break;
    case 3: // affected_by_snatch
        value = move_table[move].move_flags.flags.affected_by_snatch;
        break;
    case 4: // affected_by_mirrormove
        value = move_table[move].move_flags.flags.affected_by_mirrormove;
        break;
    case 5: // affected_by_kingsrock
        value = move_table[move].move_flags.flags.affected_by_kingsrock;
        break;
    case 6: // raised_crit_ratio
        value = move_table[move].move_flags.flags.raised_crit_ratio;
        break;
    }
    if (value)
        tai_current_instruction = (void*)read_word(tai_current_instruction + 2);
    else
        tai_current_instruction += 6;
}

void tai97_comparestats(void) //u8 bank, u8 stat
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));  // Lê o banco
    u8 stat1 = read_byte(tai_current_instruction + 2);              // Lê a 1ª estatística
    u8 stat2 = read_byte(tai_current_instruction + 3);              // Lê a 2ª estatística

    u8 value1 = *((&battle_participants[bank].hp_buff) + stat1);    // Obtém o valor de stat1
    u8 value2 = *((&battle_participants[bank].hp_buff) + stat2);    // Obtém o valor de stat2

    AI_STATE->var = (value1 > value2) ? 1 : 0;  // Retorna 1 se stat1 > stat2, caso contrário 0

    tai_current_instruction += 4;  // Avança 4 bytes (opcode + bank + stat1 + stat2)
}

void tai98_comparestatsboth(void) // u8 bank1, u8 bank2, u8 stat
{
    u8 bank1 = get_ai_bank(read_byte(tai_current_instruction + 1));  // Lê o primeiro banco
    u8 bank2 = get_ai_bank(read_byte(tai_current_instruction + 2));  // Lê o segundo banco
    u8 stat = read_byte(tai_current_instruction + 3);               // Lê a estatística

    u8 value1 = *((&battle_participants[bank1].hp_buff) + stat);    // Obtém o valor de stat no bank1
    u8 value2 = *((&battle_participants[bank2].hp_buff) + stat);    // Obtém o valor de stat no bank2

    AI_STATE->var = (value1 > value2) ? 1 : 0;                      // Retorna 1 se stat no bank1 > stat no bank2, caso contrário 0

    tai_current_instruction += 4;                                   // Avança 4 bytes (opcode + bank1 + bank2 + stat)
}

void tai99_getpredictedmove(void) // u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Lê o banco
    u16 predictedMove = chosen_move_by_banks[bank];               // Obtém o movimento previsto

    AI_STATE->var = predictedMove;                               // Armazena o ID do movimento previsto em var
    tai_current_instruction += 2;                                // Avança 2 bytes (opcode + banco)
}

#define MAX_BATTLERS_COUNT 4
void tai9A_getbankspecies(u8 bank)
{
    if (bank < MAX_BATTLERS_COUNT) // Verifica se o banco é válido
        AI_STATE->var = battle_participants[bank].species;
    else
        AI_STATE->var = POKE_UNKNOW; // Retorna uma espécie inválida se o banco for inválido
}
#define PARTY_SIZE 4
// Função para verificar se todos os Pokémon (exceto o batalhador atual) estão completamente curados
static bool tai_is_party_fully_healed_except_self(u8 bank)
{
    struct pokemon *poke_address;
    u8 banks_side = get_bank_side(bank); // Determina se é o jogador (0) ou oponente (1)
    struct pokemon *party = (banks_side == 1) ? party_opponent : party_player;

    // Itera sobre os Pokémon da equipe
    for (u32 i = 0; i < PARTY_SIZE; i++)
    {
        poke_address = &party[i];

        // Ignora o batalhador atual
        if (i == battle_team_id_by_side[bank])
            continue;

        // Verifica se o Pokémon está vazio ou é um ovo
        if (get_attributes(poke_address, ATTR_SPECIES, NULL) == POKE_UNKNOW ||
            get_attributes(poke_address, ATTR_SPECIES, NULL) == POKE_EGG)
            continue;

        // Verifica se o Pokémon está desmaiado
        if (get_attributes(poke_address, ATTR_CURRENT_HP, NULL) == 0)
            continue;

        // Verifica se o HP do Pokémon está abaixo do máximo
        if (get_attributes(poke_address, ATTR_CURRENT_HP, NULL) < get_attributes(poke_address, ATTR_TOTAL_HP, NULL))
        {
            return false; // Pelo menos um Pokémon não está completamente curado
        }
    }

    return true; // Todo o time (exceto o atual) está completamente curado
}

// Função auxiliar chamada diretamente em tai_scripts.s
void tai9B_check_party_fully_healed(void)
{
    // Verifica se o time está curado usando a função principal
    if (tai_is_party_fully_healed_except_self(tai_bank))
    {
        AI_STATE->var = 1; // Time está completamente curado
    }
    else
    {
        AI_STATE->var = 0; // Nem todos estão completamente curados
    }
}

// Verifica se resta apenas 1 turno para Trick Room acabar e armazena o resultado
void tai9C_checkiftrickroomisending(void)
{
    if (new_battlestruct->field_affecting.trick_room == 1)
        AI_STATE->var = 1; // Trick Room está terminando
    else
        AI_STATE->var = 0; // Ainda não está terminando
}

void tai9D_checkpokeweight(void) // u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u16 weight = get_poke_weight(bank);

    // Define o limite de peso diretamente na função
    if (weight >= 2000) // 200.0 kg
        AI_STATE->var = 1; // True: peso excede o limite
    else
        AI_STATE->var = 0; // False: peso está abaixo do limite

    tai_current_instruction += 2;
}

void tai9E_jumpifwordvarNE() //u32 word, void* ptr
{
    u32 word = read_word(tai_current_instruction + 1);
    if (word != AI_STATE->var) // Inverte a lógica para "Not Equal"
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 5));
    else
        tai_current_instruction += 9;
}

void tai9F_jumpifwordvarLE() //u32 word, void* ptr
{
    u32 word = read_word(tai_current_instruction + 1);
    if (word <= AI_STATE->var) // Inverte a lógica para "Not Equal"
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 5));
    else
        tai_current_instruction += 9;
}

void taiA0_jumpifvarsNE(void) //void* ptr
{
    if (new_battlestruct->trainer_AI.var2 != AI_STATE->var)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 1)); // Salta se diferentes
    else
        tai_current_instruction += 5; // Avança se iguais
}

void taiA1_jumpifvarsLT(void) //void* ptr
{
    if ((s32)new_battlestruct->trainer_AI.var2 < (s32)AI_STATE->var)
        tai_current_instruction = (void*) (read_word(tai_current_instruction + 1)); // Salta se var2 < var
    else
        tai_current_instruction += 5; // Avança se var2 >= var
}

void taiA2_get_consecutive_move_count() 
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Get the bank from the script
    AI_STATE->var = disable_structs[bank].fury_cutter_timer; // Read the timer value
    tai_current_instruction += 2; // Move to the next instruction
}

u8 will_faint_after_attack(u8 atk_bank, u8 def_bank, u16 move) 
{
    // Obtenha o tipo do golpe (pode adaptar se necessário)
    u8 move_type = move_table[move].type;
    // Calcula a efetividade (pode ser necessário adaptar para o seu código)
    u16 chained_effectiveness = type_effectiveness_calc(move, move_type, atk_bank, def_bank, 1);

    // Simula o dano (preenche damage_loc)
    damage_calc(move, move_type, atk_bank, def_bank, chained_effectiveness, 1);

    // Compara o dano calculado com o HP do alvo
    if (damage_loc >= battle_participants[def_bank].current_hp)
        return 1; // Nocaute garantido
    else
        return 0; // Não causa nocaute
}

void taiA3_jumpifwillfaint() // u8 atk_bank, u8 def_bank, void* ptr
{
    u8 atk = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 def = get_ai_bank(read_byte(tai_current_instruction + 2));
    if (will_faint_after_attack(atk, def, AI_STATE->curr_move))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 3);
    else
        tai_current_instruction += 7;
}

void taiA4_gethappiness(void) // u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 happiness = battle_participants[bank].happiness;

    /*
     * Categorias:
     * 0 = Muito baixa felicidade (0–50)
     * 1 = Baixa (51–100)
     * 2 = Média (101–150)
     * 3 = Alta (151–200)
     * 4 = Máxima (201–255)
     */

    u8 level = 0;

    if (happiness > 200)
        level = 4;
    else if (happiness > 150)
        level = 3;
    else if (happiness > 100)
        level = 2;
    else if (happiness > 50)
        level = 1;
    // se for <= 50, permanece 0

    AI_STATE->var = level;
    tai_current_instruction += 2;
}

void taiA5_gyroballpowerlevel(void) // u8 user_bank, u8 target_bank
{
    u8 user = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 target = get_ai_bank(read_byte(tai_current_instruction + 2));

    // Obtenha a Speed final de cada um (já considerando boosts, paralisação, item, etc)
    // Substitua "get_final_speed" pela função do seu engine que retorna a velocidade efetiva
    u16 user_speed = get_speed(user);
    u16 target_speed = get_speed(target);

    // Regra de divisões por zero ou velocidade zero
    if (user_speed == 0)
        user_speed = 1;

    // Cálculo do poder base
    u16 base_power = (25 * target_speed) / user_speed + 1;
    if (base_power > 150)
        base_power = 150;
    if (base_power < 1)
        base_power = 1;

    // Categorize o poder para uso fácil no script
    // 0: base_power < 40      (fraco)
    // 1: 40 <= base_power < 70 (médio)
    // 2: 70 <= base_power < 110 (forte)
    // 3: base_power >= 110     (muito forte)
    u8 tier = 0;
    if (base_power >= 110)
        tier = 3;
    else if (base_power >= 70)
        tier = 2;
    else if (base_power >= 40)
        tier = 1;
    // tier permanece 0 se < 40

    AI_STATE->var = tier;
    tai_current_instruction += 3;
}

void taiA6_grassknotweighttier(void) // u8 bank
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u16 weight = get_poke_weight(bank); // em hectogramas (1 decimal, ou seja, 100 = 10.0kg, 2000 = 200.0kg)

    u8 tier;
    if (weight < 100)          // < 10.0 kg
        tier = 0;
    else if (weight < 250)     // 10.0–24.9 kg
        tier = 1;
    else if (weight < 500)     // 25.0–49.9 kg
        tier = 2;
    else if (weight < 1000)    // 50.0–99.9 kg
        tier = 3;
    else if (weight < 2000)    // 100.0–199.9 kg
        tier = 4;
    else                       // ≥ 200.0 kg
        tier = 5;

    AI_STATE->var = tier;
    tai_current_instruction += 2;
}

void taiA7_heavyslamweighttier(void) // u8 atk_bank, u8 def_bank
{
    u8 atk_bank = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 def_bank = get_ai_bank(read_byte(tai_current_instruction + 2));
    u16 atk_weight = get_poke_weight(atk_bank);
    u16 def_weight = get_poke_weight(def_bank);

    // Evita divisão por zero
    if (def_weight == 0)
        def_weight = 1;

    u16 weight_ratio = atk_weight / def_weight;
    u8 tier;
    if (weight_ratio >= 5)
        tier = 4; // Poder base 120
    else if (weight_ratio == 4)
        tier = 3; // Poder base 100
    else if (weight_ratio == 3)
        tier = 2; // Poder base 80
    else if (weight_ratio == 2)
        tier = 1; // Poder base 60
    else
        tier = 0; // Poder base 40

    AI_STATE->var = tier;
    tai_current_instruction += 3;
}

void taiA8_electroballpowerlevel(void) // u8 user_bank, u8 target_bank
{
    u8 user = get_ai_bank(read_byte(tai_current_instruction + 1));
    u8 target = get_ai_bank(read_byte(tai_current_instruction + 2));

    // Obtenha a Speed final de cada um (já considerando boosts, paralisação, item, etc)
    u16 user_speed = get_speed(user);
    u16 target_speed = get_speed(target);

    // Prevenir divisão por zero
    if (target_speed == 0)
        target_speed = 1;

    // Razão de Speed
    u16 ratio = user_speed / target_speed;

    // Tier de Electro Ball:
    // 4: >=4x mais rápido (poder 150)
    // 3: >=3x (poder 120)
    // 2: >=2x (poder 80)
    // 1: >=1x (poder 60)
    // 0: <1x (poder 40)
    u8 tier = 0;
    if (ratio >= 4)
        tier = 4;
    else if (ratio >= 3)
        tier = 3;
    else if (ratio >= 2)
        tier = 2;
    else if (ratio >= 1)
        tier = 1;
    // tier permanece 0 se < 1

    AI_STATE->var = tier;
    tai_current_instruction += 3;
}

void taiA9_jumpifattackboostmove(void) //u8 bank, void* ptr
{
    u8 arg1 = read_byte(tai_current_instruction + 1);
    u8 bank = get_ai_bank(arg1);
    u16 move = AI_STATE->curr_move;

    // Obtém as estatísticas alteradas pelo movimento
    u8 statChanges = get_stat_move_changes(move);

    // Verifica se é um movimento que aumenta o Ataque
    if (does_move_raise_attacker_stat(move, bank) && (statChanges & STAT_ATTACK))
        tai_current_instruction = (void*) read_word(tai_current_instruction + 2);
    else
        tai_current_instruction += 6;
}

void taiAA_jumpifmovealwayscrits(void) // u8 bank (ignored), void* ptr
{
    // Lê o parâmetro de banco, mas aqui usaremos só AI_STATE->var
    (void)get_ai_bank(read_byte(tai_current_instruction + 1));

    // Move previamente obtido por getpartnerchosenmove foi salvo em AI_STATE->var
    u16 move = AI_STATE->var;

    // Se for um dos golpes que sempre acerta crítico, salta para o label
    if (move == MOVE_FROST_BREATH ||
        move == MOVE_STORM_THROW  ||
        move == MOVE_ZIPPY_ZAP)
    {
        tai_current_instruction = (void*)read_word(tai_current_instruction + 2);
    }
    else
    {
        tai_current_instruction += 6; // opcode + bank + .word (4 bytes)
    }
}

void taiAB_jumpifmovestatusmove(void) // u8 bank, void* ptr
{
    (void)get_ai_bank(read_byte(tai_current_instruction + 1));   // descartamos o valor de banco
    u16 move = AI_STATE->curr_move;                               // Golpe que está sendo considerado

    // Se não for um golpe de dano, ou seja, for de status:
    if (!DAMAGING_MOVE(move))                                     // citeturn2file12
        tai_current_instruction = (void*)read_word(tai_current_instruction + 2);
    else
        tai_current_instruction += 6;
}

void taiAC_isbattlergrounded(void) // Função principal para uso no script
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Obtém o banco do batalhador a ser analisado
    
    // Verifica se o batalhador está no chão
    u8 is_grounded = 1; // Assume inicialmente que o batalhador está no chão

    // Verifica se o batalhador está sob efeito de Levitate
    if (ai_get_ability(bank, 1) == ABILITY_LEVITATE)
        is_grounded = 0;

    // Verifica se o batalhador possui tipo Flying
    if (is_of_type(bank, TYPE_FLYING))
        is_grounded = 0;

    // Verifica se o batalhador está segurando Air Balloon
    if (ai_get_item_effect(bank, 1) == ITEM_EFFECT_AIRBALLOON)
        is_grounded = 0;

    // Verifica se o batalhador está sob efeito de Telekinesis
    if (new_battlestruct->bank_affecting[bank].telekinesis > 0)
        is_grounded = 0;

    // Verifica se o campo está sob efeito de Gravity
    if (new_battlestruct->field_affecting.gravity > 0)
        is_grounded = 1;

	// Grassy Terrain: verifica se o batalhador pode ser afetado por ele
	if (new_battlestruct->field_affecting.grassy_terrain) // Verifica se o campo está sob efeito de Grassy Terrain
	{
		if (!is_of_type(bank, TYPE_FLYING) && ai_get_ability(bank, 1) != ABILITY_LEVITATE)
		is_grounded = 1; // O batalhador é considerado no chão se não for do tipo Flying e não tiver Levitate
	}

    // Atualiza o ponteiro da instrução baseado no resultado
    if (is_grounded)
        tai_current_instruction = (void*)read_word(tai_current_instruction + 2); // Salta para o próximo label
    else
        tai_current_instruction += 6; // Avança para a próxima instrução
}

void taiAD_jumpifhasprioritymove() //u8 bank, u16 label
{
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Obtem o banco para verificação (ex: bank_aipartner)
    u8 ability = ai_get_ability(bank, 1); // Obtém a habilidade do Pokémon
    u8 has_priority_move = 0;

    // Itera pelos 4 movimentos do Pokémon para verificar se há um movimento prioritário
    for (u8 i = 0; i < 4; i++)
    {
        u16 move = ai_get_move(bank, i); // Obtém o movimento no slot atual
        if (move) // Verifica se o slot contém um movimento válido
        {
            // Verifica se o movimento é prioritário
            if (move_table[move].priority > 0 || // Movimentos com prioridade natural
                (ability == ABILITY_GALE_WINGS && tai_getmovetype(bank, move) == TYPE_FLYING) || // Gale Wings para movimentos voadores
                (ability == ABILITY_PRANKSTER && move_table[move].split == MOVE_STATUS)) // Prankster para movimentos de status
            {
                has_priority_move = 1;
                break; // Encontrou um movimento prioritário, encerra o loop
            }
        }
    }

    // Determina o próximo comportamento com base na presença de movimentos prioritários
    if (has_priority_move)
    {
        s16 jump_offset = read_hword(tai_current_instruction + 2); // Obtém o offset para o jump
        tai_current_instruction += jump_offset; // Realiza o jump
    }
    else
    {
        tai_current_instruction += 4; // Avança para a próxima instrução
    }
}

void taiAE_jumpifmove2(u8 bank, u16 move, u8 jump_label)
{
    u8 has_move = 0;

    // Itera pelos 4 slots de movimento disponíveis para o Pokémon no banco fornecido
    for (u8 i = 0; i < 4; i++)
    {
        u16 current_move = ai_get_move(bank, i); // Obtém o movimento no slot atual
        if (current_move == move)               // Verifica se o movimento corresponde ao especificado
        {
            has_move = 1;
            break;                              // Sai do loop se o movimento for encontrado
        }
    }

    // Realiza o salto se o movimento for encontrado
    if (has_move)
        tai_current_instruction += jump_label;  // Salta para o rótulo especificado
    else
        tai_current_instruction += 4;          // Avança para a próxima instrução se o movimento não for encontrado
}

void taiAF_discourage_moves_double(void)
{
    u16 move = AI_STATE->curr_move;
    u8  script_id    = move_table[move].script_id;
    u8  move_type    = tai_getmovetype(tai_bank, move);
    u8  tai_ability  = ai_get_ability(tai_bank, 1);
    u8  discourage   = 0;

    // — Verificação universal herdada —
    if ( is_of_type(bank_target, TYPE_DARK) && tai_ability == ABILITY_PRANKSTER && move_table[move].split == MOVE_STATUS
      && !(get_move_table_target(move, tai_bank) & (move_target_opponent_field | move_target_user)) )
    {
        discourage += 10;
    }

    // — Terrains —
    if ( new_battlestruct->field_affecting.electic_terrain && (script_id == 12 || script_id == 131) )  // SLEEP ou YAWN
    {
        discourage += 20;
    }

    // — Lógica específica de Double Battles —
    u8 partner_bank        = tai_bank ^ 2;       // parceiro do atacante
    u8 target_partner_bank = bank_target ^ 2;    // parceiro do alvo
    u8 move_target         = get_move_table_target(move, tai_bank);
    bool hits_partner      = (move_target & move_target_foes_and_ally) || (move_target == move_target_opponent_field);

    // 1) Checa habilidades do parceiro do atacante (se o movimento o afeta)
    if ( is_bank_present(partner_bank) && hits_partner )
    {
        u8 partner_ability = ai_get_ability(partner_bank, 1);
        switch (partner_ability)
        {
            // Habilidades que absorvem/negam dano
            case ABILITY_TELEPATHY: // Não é afetado por movimentos de aliados
                discourage += 15;
                break;
            case ABILITY_BULLETPROOF: // Imune a movimentos de projétil
                if (find_move_in_table(move, &ball_bomb_moves[0]))
                    discourage += 20;
                break;
            case ABILITY_FLASH_FIRE:
                if (move_type == TYPE_FIRE && !new_battlestruct->various.inverse_battle)
                    discourage += 25; // Penalidade maior para evitar buffear oponente
                break;
            case ABILITY_VOLT_ABSORB:
            case ABILITY_MOTOR_DRIVE:
                if (move_type == TYPE_ELECTRIC)
                    discourage += 20;
                break;
            case ABILITY_SAP_SIPPER:
                if (move_type == TYPE_GRASS)
                    discourage += 20;
                break;
            // Habilidades que ativam efeitos em contato
            case ABILITY_STATIC:
            case ABILITY_FLAME_BODY:
                if (move_table[move].move_flags.flags.makes_contact)
                    discourage += 10;
                break;
        }

        // Itens do parceiro do atacante
        u8 partner_item = ai_get_item_effect(partner_bank, 1);
        switch (partner_item) 
		{
            case ITEM_EFFECT_ASSAULTVEST:
                if (move_table[move].split == MOVE_SPECIAL)
                    discourage += 5;
                break;
            case ITEM_EFFECT_ABSORBBULB:
                if (move_type == TYPE_WATER)
                    discourage += 15;
                break;
            case ITEM_EFFECT_PROTECTIVEPADS:
                if (move_table[move].move_flags.flags.makes_contact)
                    discourage += 8;
                break;
        }
    }

    // 2) Checa habilidades do parceiro do alvo
    if ( is_bank_present(target_partner_bank) )
    {
        u8 targ_ability = ai_get_ability(target_partner_bank, 1);
        switch (targ_ability)
        {
            case ABILITY_LIGHTNING_ROD: // Redireciona mov. Elétricos
            case ABILITY_STORM_DRAIN:   // Redireciona mov. Água
                if ((targ_ability == ABILITY_LIGHTNING_ROD && move_type == TYPE_ELECTRIC) ||
                    (targ_ability == ABILITY_STORM_DRAIN && move_type == TYPE_WATER))
                {
                    discourage += 25; // Penaliza severamente (alvo errado)
                }
                break;
            case ABILITY_QUEENLY_MAJESTY: // Bloqueia mov. prioritários
                if (move_table[move].priority > 0)
                    discourage += 15;
                break;
        }
    }

    // 3) Verifica condições de campo
    if (new_battlestruct->field_affecting.psychic_terrain) 
	{
        if (move_table[move].priority > 0 && GROUNDED(tai_bank)) 
		{
            discourage += 20; // Bloqueia prioridade
        }
    }
    if (new_battlestruct->field_affecting.grassy_terrain) 
	{
        if (move == MOVE_EARTHQUAKE || move == MOVE_BULLDOZE) 
		{
            discourage += 10; // Reduz dano de certos movimentos
        }
    }

    // 4) Interações com Protect/Detect
    u8 protect_chance = 0;
    if (is_bank_present(target_partner_bank)) 
	{
        for (u8 i = 0; i < 4; i++) 
		{
            u16 partner_move = ai_get_move(target_partner_bank, i);
            if (partner_move == MOVE_PROTECT || partner_move == MOVE_DETECT) 
			{
                protect_chance = 30; // Chance estimada de uso
                break;
            }
        }
        if (protect_chance > 0 && move_table[move].split != MOVE_STATUS) 
		{
            discourage += (protect_chance / 3); // Penaliza se houver risco de Protect
        }
    }

    // 5) Efeitos de clima
    if (battle_weather.int_bw & (weather_rain | weather_heavy_rain)) 
	{
        if (move_type == TYPE_FIRE) discourage += 15;
        else if (move_type == TYPE_WATER) discourage -= 10;
    } else if (battle_weather.int_bw & (weather_sun | weather_harsh_sun)) 
	{
        if (move_type == TYPE_WATER) discourage += 15;
        else if (move_type == TYPE_FIRE) discourage -= 10;
    }

    // 6) Movimentos que afetam aliados (ex: Explosion)
    if (move == MOVE_EXPLOSION || move == MOVE_SELFDESTRUCT) 
	{
        u8 partner_hp = battle_participants[partner_bank].current_hp;
        if (partner_hp < (battle_participants[partner_bank].max_hp / 2)) 
		{
            discourage += 40; // Evita dano excessivo ao parceiro
        }
    }

    // — Aplica a penalização acumulada —
    AI_STATE->score[AI_STATE->moveset_index] -= discourage;
    tai_current_instruction++;
}

static bool ai_has_low_pp(u8 bank) 
{
    // Itera pelos movimentos do banco especificado
    for (int i = 0; i < 4; i++) 
	{
        // Verifica se o movimento tem 5 PP ou menos
        if (battle_participants[bank].current_pp[i] <= 5 && battle_participants[bank].current_pp[i] > 0) 
		{
            return 1; // Retorna True (1) se encontrar qualquer movimento com PP baixo
        }
    }
    return 0; // Retorna False (0) se não encontrar nenhum movimento com PP baixo
}

void taiB0_checklowpp() 
{
    // Salva o resultado da verificação de PP baixo em AI_STATE->var
    AI_STATE->var = ai_has_low_pp(tai_bank);
    tai_current_instruction++; // Avança para a próxima instrução no script
}

void taiB1_checkstab(void)
{
    // Obtém o banco do atacante e o movimento atual
    u8 bank = get_ai_bank(read_byte(tai_current_instruction + 1)); // Argumento 1: banco
    u16 move = AI_STATE->curr_move;                                // Movimento atual

    // Obtém os tipos do atacante
    u8 atk_type1 = battle_participants[bank].type1;
    u8 atk_type2 = battle_participants[bank].type2;
    u8 atk_type3 = new_battlestruct->bank_affecting[bank].type3; // Suporte a tipo adicional (ex: Forest's Curse)

    // Obtém o tipo do movimento
    u8 move_type = tai_getmovetype(bank, move);

    // Verifica se o tipo do movimento é o mesmo que algum dos tipos do atacante (STAB)
    bool is_stab = (move_type == atk_type1 || move_type == atk_type2 || move_type == atk_type3);

    // Calcula a efetividade do movimento no alvo
    u16 effectiveness = type_effectiveness_calc(move, move_type, bank, bank_target, 0);

    // Determina se o movimento é neutro ou super efetivo
    bool is_effective = (effectiveness >= 64); // 64 = dano neutro, > 64 = super efetivo

    // Salva o resultado na variável de estado
    AI_STATE->var = (is_stab && is_effective) ? 1 : 0;

    // Avança para a próxima instrução
    tai_current_instruction += 2;
}
