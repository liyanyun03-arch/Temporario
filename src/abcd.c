#include "defines.h"

u8 get_item_effect(u8 bank, u8 check_negating_effects);
u16 get_item_extra_param(u16 item);
struct task* get_task(u8 taskID);
void* get_particle_pal(u16 ID);
void move_anim_task_delete(u8 taskID);
void change_animation_bank_attacker();
void change_animation_bank_target();

struct template rain_template = 
{
	0x27a6, 0x27a6, (struct sprite*) 0x852496c, (struct frame**) 0x8596BF8, 0, (struct rotscale_frame**) 0x85961a4,
	(void*) 0x810721d
};
struct template eletric_template = 
{
	0x2711, 0x2711, (struct sprite*) 0x8524904, (struct frame**) 0x82ec69c, 0, (struct rotscale_frame**) 0x82ec6a8,
	(void*) 0x810a9dd
};//0x810a9dd

struct template gsnowflakesspritetemplate =
{
	0x27a6, 0x27a6, (struct sprite*) 0x852496c, (struct frame**) 0x8596BF8, 0, (struct rotscale_frame**) 0x85961a4,
	(void*) 0x810721d
};

const struct coords8 v_creator_pos[] = {{-65, -35}, {23, -35}, {-65, 1}};
const u16 DRIVER_PALS[] = {0x7EEC, 0x1F, 0x7f75, 0x277f};

/*void change_animation_bank_target()
{
	u8* bank= &animation_bank_attacker;
	bank[1] = bank[0];
}

void change_animation_bank_attacker()
{
	u8* bank= &animation_bank_attacker;
	bank[0] = bank[1];
}*/
void coil_callback(struct object* self)
{
    self->callback = (void*) 0x81105b5;
    change_animation_bank_target();
}

void foul_play_task(u8 taskID)
{
    get_task(taskID)->function = (void*) 0x8117755;
    change_animation_bank_attacker();
}

void AnimTask_HideShow_Sprite0(u8 bank)
{
    struct object* poke_obj = &objects[objID_pbs_moveanimations[bank]];
    poke_obj->private[7] = poke_obj->pos1.x;
    poke_obj->pos1.x = -64;
}


void AnimTask_HideShow_Sprite(u8 taskID)
{
    /*u8 objID = objID_pbs_moveanimations[animation_bank_target];
    struct object* poke_obj = &objects[objID];
    poke_obj->private[7] = poke_obj->pos1.x;
    poke_obj->pos1.x = -64;

    objID = objID_pbs_moveanimations[animation_bank_attacker];
    poke_obj = &objects[objID];
    poke_obj->private[7] = poke_obj->pos1.x;
    poke_obj->pos1.x = -64;*/
    AnimTask_HideShow_Sprite0(animation_bank_target);
    AnimTask_HideShow_Sprite0(animation_bank_attacker);
    move_anim_task_delete(taskID);
}

void hex_task(u8 taskID)
{
    if (!battle_participants[animation_bank_target].status.int_status)
    {
        anim_arguments[7] = 5;
    }
    move_anim_task_delete(taskID);
}

void GEAR_GRIND_callback(struct object* obj)
{
    obj->pos1.x += (s16) anim_arguments[0];
    obj->pos1.y += (s16) anim_arguments[1];
    obj->callback = (void*) 0x815a1b1;
}

void Techno_Blast_change_pal(u8 taskID)
{
    u16 item_effect = get_item_extra_param(animation_bank_attacker);
    if (get_item_effect(animation_bank_attacker, 1) == ITEM_EFFECT_DRIVES && item_effect <= 4)
    {
        u16* pal = get_particle_pal(0x27e4);
        pal[1] = DRIVER_PALS[item_effect - 1];
    }
    move_anim_task_delete(taskID);
}

void v_creator_callback(struct object* self)
{
    /*switch(anim_arguments[5])
    {
        case 1:
            pos_neg_center->y = -35;
            pos_neg_center->x = -65;
            break;
        case 2:
            pos_neg_center->y = -35;
            pos_neg_center->x = 23;
            break;
        case 3:
            pos_neg_center->y = 1;
            pos_neg_center->x = -65;
            break;
        default:
            pos_neg_center->y = 1;
    }*/
    u16 arg = anim_arguments[5];
    if (arg >= 1 && arg <= 3)
    {
        self->pos_neg_center = v_creator_pos[arg - 1];
    }
    else
    {
        self->pos_neg_center.y = 1;
    }
    self->callback = (void*) 0x8109365;
}

void STICKY_WEB_callback(struct object* obj)
{
    obj->pos1.x += (s16) anim_arguments[0];
    obj->pos1.y += (s16) anim_arguments[1];
    obj->callback = (void*) 0x811067d;
}

void rain_task(u8 taskID)
{
    u16* state_tracker = get_task(taskID)->private;
    if (*state_tracker == 0)
    {
        memcpy(state_tracker + 1, anim_arguments, 6);
        /**(state_tracker + 1) = anim_arguments[0];
        *(state_tracker + 2) = anim_arguments[1];
        *(state_tracker + 3) = anim_arguments[2];*/
    }
    (*state_tracker)++;
    if (__modsi3(*state_tracker, *(state_tracker + 2)))
    {
        u16 x = task_0x82E7BE1(task_0x806f621(), 0xF0);
        u16 y = task_0x82E7BE1(task_0x806f621(), 0x50);
        struct template* template = &rain_template;
        if (anim_arguments[3] == 0x15)
            template = &eletric_template;
        template_instanciate_forward_search(template, x, y, 4);
    }
    if (*state_tracker == *(state_tracker + 3))
        move_anim_task_delete(taskID);
}

/* // Dimensions of the GBA screen in pixels
#define DISPLAY_WIDTH  240
#define DISPLAY_HEIGHT 160

void AnimTask_CreateSnowflakes(u8 taskId)
{
    u8 x, y;

    if (tasks[taskId].private[0] == 0)
    {
        tasks[taskId].private[1] = anim_arguments[0];
        tasks[taskId].private[2] = anim_arguments[1];
        tasks[taskId].private[3] = anim_arguments[2];
    }
    tasks[taskId].private[0]++;
    if (tasks[taskId].private[0] % tasks[taskId].private[2] == 1)
    {
       x = task_0x806f621() % DISPLAY_WIDTH;
        y = task_0x806f621() % (DISPLAY_HEIGHT / 2);
        template_instanciate_forward_search(&gsnowflakesspritetemplate, x, y, 4);
    }
    if (tasks[taskId].private[0] == tasks[taskId].private[3])
        move_anim_task_del(taskId);
}*/

