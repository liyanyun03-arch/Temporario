.text
.thumb
.thumb_func


.align 1
    .global change_animation_bank_target
change_animation_bank_target:
    ldr r2,=animation_bank_attacker
    ldrb r0,[r2]
    strb r0,[r2,#1]
    bx lr

    .global change_animation_bank_attacker
change_animation_bank_attacker:
    ldr r2,=animation_bank_attacker
    ldrb r0,[r2,#1]
    strb r0,[r2]
    bx lr
	
.global toxic_thread_task
toxic_thread_task:
    push {r0,r4-r5,lr}
    ldr r4,=toxic_thread_task_data
    ldrh r0,[r4]
    bl get_particle_pal
    ldrh r5,[r4,#2]
    strh r5,[r0,#8]
    ldrh r0,[r4]
    add r0, #1
    bl get_particle_pal
    strh r5,[r0,#8]
    ldr r0,[sp]
    bl move_anim_task_delete
    pop {r0,r4-r5,pc}
	
toxic_thread_task_data:
.hword 0x27C3, 0x7C1E

wildbattle_clear_battleflags:
    ldr r4, =battle_flags
    ldr r0, [r4]
    lsl r0,  #31
    lsr r0,  #31
    str r0, [r4]
    bx  lr
