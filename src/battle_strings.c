#include "defines.h"
#include "static_references.h"

struct pokemon* get_party_ptr(u8 bank);
struct pokemon* get_bank_poke_ptr(u8 bank);
struct pokemon* get_poke_to_illusion_into(struct pokemon* poke, u8 bank);
u8 get_bank_side(u8 bank);

/*0x17C*/const u8 firespintrap_text[] = {BuffCharac, 16, Space, f_, i_, c_, o_, u_, Space, p_, r_, e_, s_, o_, Space, n_, o_, Space, v_, 0x23, r_, t_, i_, c_, e_, Space, 0xFC, 0x01, 0x2, F_, l_, a_, m_, e_, j_, a_, n_, t_, e_, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x17D*/const u8 magmastormtrap_text[] = {BuffCharac, 16, Space, f_, i_, c_, o_, u_, Space, p_, r_, e_, s_, o_, Space, n_, a_, JumpLine, m_, a_, g_, m_, a_, Space, 0xFC, 0x01, 0x2, i_, n_, c_, a_, n_, d_, e_, s_, c_, e_, n_, t_, e_, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x17E*/const u8 extreme_sun_activation_text[] = {O_, Space, s_, o_, l_, Space, f_, i_, c_, o_, u_, Space, e_, x_, t_, r_, e_, m_, a_, m_, e_, n_, t_, e_, Space, i_, n_, t_, e_, n_, s_, o_, Exclam, Termin};
/*0x17F*/const u8 heavyrain_activation_text[] = {U_, m_, a_, Space, c_, h_, u_, v_, a_, Space, f_, o_, r_, t_, e_, Space, c_, o_, m_, e_, 0x19, o_, u_, Space, a_, Space, c_, a_, i_, r_, Exclam, Termin};
/*0x180*/const u8 mysticalaircurrent_activation_text[] = {U_, m_, a_, Space, c_, o_, r_, r_, e_, n_, t_, e_, Space, d_, e_, Space, a_, r_, Space, m_, i_, s_, t_, e_, r_, i_, o_, s_, a_, Space, e_, s_, t_, 0x17, JumpLine, p_, r_, o_, t_, e_, g_, e_, n_, d_, o_, Space, o_, s_, Space, P_, o_, k_, 0x1B, m_, o_, n_, Space, d_, o_, Space, t_, i_, p_, o_, Dash, F_, l_, y_, i_, n_, g_, Exclam, Termin};
/*0x181*/const u8 forewarn_text[] = {F_, o_, i_, Space, a_, l_, e_, r_, t_, a_, d_, o_, Space, s_, o_, b_, r_, e_, Space, o_, Space, 0xFC, 0x01, 0x2, BuffCharac, 0, Space , 0xFC, 0x01, 0x1, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 17, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x182*/const u8 slowstart_text[] = {0xFD, 0x13, 0x00, 0xE2, 0xF4, 0xE3, 0x00, 0xD7, 0xE3, 0xE2, 0xE7, 0xD9, 0xDB, 0xE9, 0xD9, 0xFE, 0xDA, 0xD5, 0xEE, 0xD9, 0xE6, 0x00, 0xDD, 0xE7, 0xE7, 0xE3, 0x00, 0xDA, 0xE9, 0xE2, 0xD7, 0xDD, 0xE3, 0xE2, 0xD5, 0xE6, 0xAB, 0xFF};
/*0x183*/const u8 anticipation_text[] = {BuffCharac, 19, Space, e_, s_, t_, r_, e_, m_, e_, c_, e_, u_, Exclam, 0xFF};
/*0x184*/const u8 infestationtrap_text[] = {0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Space, f_, o_, i_, Space, a_, f_, l_, i_, g_, i_, d_, o_, Space, p_, o_, r_, Space, u_, m_, a_, Space, i_, n_, f_, e_, s_, t_, a_, 0x19, 0xF4, o_, JumpLine, c_, a_, u_, s_, a_, d_, a_, Space, p_, o_, r_, Space, 0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x185*/const u8 airlock_text[] = {O_, s_, Space, e_, f_, e_, i_, t_, o_, s_, Space, c_, l_, i_, m_, 0x17, t_, i_, c_, o_, s_, JumpLine, f_, o_, r_, a_, m_, Space, s_, u_, p_, r_, i_, m_, i_, d_, o_, s_, Exclam, 0xFF};
/*0x186*/const u8 harvest_text[] = {BuffCharac, 15, Space, c_, o_, l_, h_, e_, u_, JumpLine, u_, m_, Space, BuffCharac, 22, Exclam, 0xFF};
/*0x187*/const u8 healer_text[] = {BuffCharac, 15, Space, c_, u_, r_, o_, u_, JumpLine, BuffCharac, 19, Apos, s_, Space, BuffCharac, Space, Exclam, 0xFF};
/*0x188*/const u8 empty_text5[] = {0xFF};
/*0x189*/const u8 moldbreaker_text[] = {0xFC, 0x01, 0x2, BuffCharac, 0x13, 0xFC, 0x01, 0x1, Space, q_, u_, e_, b_, r_, a_, Space, o_, Space, m_, o_, l_, d_, e_, Exclam, Termin};
/*0x18A*/const u8 turboblaze_text[] = {0xFC, 0x01, 0x2, BuffCharac, 0x13, 0xFC, 0x01, 0x1, Space, e_, s_, t_, 0x17, Space, i_, r_, r_, a_, d_, i_, a_, n_, d_, o_, JumpLine, u_, m_, a_, Space, a_, u_, r_, a_, Space, 0xFC, 0x01, 0x2, a_, r_, d_, e_, n_, t_, e_, 0xFC, 0x01, 0x1, Exclam, Termin};
/*0x18B*/const u8 terravolt_text[] = {0xFC, 0x01, 0x2, BuffCharac, 0x13, 0xFC, 0x01, 0x1, Space, e_, s_, t_, 0x17, Space, i_, r_, r_, a_, d_, i_, a_, n_, d_, o_, JumpLine, u_, m_, a_, Space, a_, u_, r_, a_, Space, e_, x_, p_, l_, o_, s_, i_, v_, a_, Exclam, Termin};
/*0x18C*/const u8 empty_text9[] = {0xFF};
/*0x18D*/const u8 empty_text10[] = {0xFF};
/*0x18E*/const u8 empty_text12[] = {0xFF};
/*0x18F*/const u8 absorbabilityimmune_text[] = {BuffCharac, 0x0A, Space, BuffCharac, 0x13, Space, o_, Space, t_, o_, r_, n_, a_, Space, i_, m_, u_, n_, e_, JumpLine, a_, Space, a_, t_, a_, q_, u_, e_, s_, Space, d_, o_, Space, t_, i_, p_, o_, Space, BuffCharac, 0x00, Exclam, Termin};
/*0x190*/const u8 userteam_text[] = {s_, u_, a_, Space, e_, q_, u_, i_, p_, e_, Termin};
/*0x191*/const u8 foeteam_text[] = {a_, Space, e_, q_, u_, i_, p_, e_, Space, d_, o_, Space, a_, d_, v_, e_, r_, s_, 0x17, r_, i_, o_, Termin};
/*0x192*/const u8 aftermath_text[] = {BuffCharac, 15, Space, e_, s_, t_, 0x17, Space, m_, a_, l_, Space, Exclam, 0xFF};
/*0x193*/const u8 pickpocket_text[] = {0xFC, 0x01, 0x2, BuffCharac, 6, 0xFC, 0x01, 0x1, Space, r_, o_, u_, b_, o_, u_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, JumpLine, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x194*/const u8 mummy_text[] = {A_, Space, a_, b_, i_, l_, i_, t_, y_, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, JumpLine, t_, o_, r_, n_, o_, u_, 0xAE, s_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 24, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x195*/ const u8 target_ability[] = {BuffCharac, 16, 0xB4, 0xE7, Space, BuffCharac, 25, 0xAB, 0xFF};
/*0x196*/ const u8 cursedbody_text[] = {0xFC, 0x01, 0x2, BuffCharac, 54, 0xFC, 0x01, 0x1, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, JumpLine, f_, o_, i_, Space, d_, e_, s_, a_, t_, i_, v_, a_, d_, o_, Exclam, 0xFF};
/*0x197*/ const u8 statchange_text[] = {BuffCharac, Space, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 19, 0xFC, 0x01, 0x1, JumpLine, f_, o_, i_, Space, b_, u_, f_, f_, a_, d_, o_, 0x5C, o_, 0x5D, Dot, 0xFF};
/*0x198*/ const u8 pressure_text[] = {A_, Space, p_, r_, e_, s_, e_, n_, 0x19, a_, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 0x13, 0xFC, 0x01, 0x1, Space, 0x1B, Space, s_, u_, f_, o_, c_, a_, n_, t_, e_, Exclam, Termin};
/*0x199*/ const u8 unnerve_text[] = {O_, Space, t_, e_, m_, o_, r_, Space, c_, a_, u_, s_, a_, d_, o_, Space, p_, o_, r_, Space, 0xFC, 0x01, 0x2, BuffCharac, 5, 0xFC, 0x01, 0x1, JumpLine, i_, m_, p_, e_, d_, e_, Space, o_, Space, u_, s_, o_, Space, d_, e_, Space, B_, e_, r_, r_, i_, e_, s_, Exclam, Termin};
/*0x19A*/ const u8 aurabreak_text[] = {BuffCharac, 0x13, Space, r_, e_, v_, e_, r_, t_, e_, u_, JumpLine, t_, o_, d_, a_, s_, Space, a_, s_, Space, a_, u_, r_, a_, s_, Space, e_, m_, Space, c_, a_, m_, p_, o_, Exclam, 0xFF};
/*0x19B*/ const u8 fairyaura_text[] = {E_, n_, e_, r_, g_, i_, a_, Space, m_, 0x17, g_, i_, c_, a_, Space, d_, o_, Space, t_, i_, p_, o_, Space, F_, a_, i_, r_, y_, JumpLine, p_, r_, e_, e_, n_, c_, h_, e_, Space, o_, Space, c_, a_, m_, p_, o_, Exclam, Termin};
/*0x19C*/ const u8 darkaura_text[] = {E_, n_, e_, r_, g_, i_, a_, Space, s_, o_, m_, b_, r_, i_, a_, Space, d_, o_, Space, t_, i_, p_, o_, Space, D_, a_, r_, k_, JumpLine, p_, r_, e_, e_, n_, c_, h_, e_, Space, o_, Space, c_, a_, m_, p_, o_, Exclam, Termin};
/*0x19D*/ const u8 frisk_text[] = {0xFC, 0x01, 0x2, BuffCharac, 0x13, 0xFC, 0x01, 0x1, Space, v_, a_, s_, c_, u_, l_, h_, o_, u_, Space, 0xFC, 0x01, 0x2, BuffCharac, 0x10, 0xFC, 0x01, 0x1, Space, e_, JumpLine, e_, n_, c_, o_, n_, t_, r_, o_, u_, Space, 0xFC, 0x01, 0x2, BuffCharac, 0x16, 0xFC, 0x01, 0x1, Exclam, Termin};
/*0x19E*/ const u8 hurtbyitem_text[] = {0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, s_, o_, f_, r_, e_, u_, Space, 0xFC, 0x01, 0x2, 0xA2, 0xBA, 0xA9, 0xFC, 0x01, 0x1, Space, d_, e_, Space, d_, a_, n_, o_, JumpLine, p_, o_, r_, Space, c_, o_, n_, t_, a_, Space, d_, o_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x19F*/ const u8 flameorb_text[] = {0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, f_, o_, i_, Space, q_, u_, e_, i_, m_, a_, d_, o_, JumpLine, p_, e_, l_, a_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1A0*/ const u8 toxicorb_text[] = {0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, f_, o_, i_, Space, g_, r_, a_, v_, e_, m_, e_, n_, t_, e_, JumpLine, e_, n_, v_, e_, n_, e_, n_, a_, d_, o_, Space, p_, e_, l_, a_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1A1*/ const u8 airballoon_text[] = {0xFC, 0x01, 0x2, BuffCharac, 62, 0xFC, 0x01, 0x1, Space, f_, l_, u_, t_, u_, a_, Space, n_, o_, Space, a_, r_, JumpLine, c_, o_, m_, Space, o_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1A2*/ const u8 bad_dreams_text[] = {BuffCharac, 0x10, Space, e_, s_, t_, a_, Space, s_, e_, n_, d_, o_, JumpLine, a_, t_, o_, r_, m_, e_, n_, a_, d_, o_, Space, p_, o_, r_, Space, p_, e_, s_, a_, d_, e_, l_, o_, s_, Exclam, Termin};
/*0x1A3*/ const u8 stickybarb_text[] = {0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, s_, o_, f_, r_, e_, Space, d_, a_, n_, o_, Space, p_, o_, r_, JumpLine, c_, o_, n_, t_, a_, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1A4*/ const u8 rockyhelmet_text[] = {0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, s_, o_, f_, r_, e_, Space, d_, a_, n_, o_, Space, p_, o_, r_, JumpLine, c_, o_, n_, t_, a_, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1A5*/ const u8 popped_text[] = {0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, Space, d_, e_, Space, 0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Space, e_, s_, t_, o_, u_, r_, o_, u_, Exclam, 0xFF};
/*0x1A6*/ const u8 destinyknot_text[] = {0xFC, 0x06, 0x02, 0xFC, 0x01, 0x2, BuffCharac, 15, 0xFC, 0x01, 0x1, Space, f_, o_, i_, Space, a_, r_, r_, a_, s_, t_, a_, d_, o_, Space, p_, e_, l_, o_, Space, 0xFC, 0x01, 0x2, BuffCharac, 22, 0xFC, 0x01, 0x1, JumpLine, p_, a_, r_, a_, Space, u_, m_, Space, a_, m_, o_, r_, Space, f_, o_, r_, 0x19, a_, d_, o_, Exclam, Termin};
/*0x1A7*/ const u8 healblockend_text[] = {B_, l_, o_, q_, u_, e_, i_, o_, Space, d_, e_, Space, c_, u_, r_, a_, Space, s_, o_, b_, r_, e_, JumpLine, o_, Space, 0xFC, 0x01, 0x2, BuffCharac, 18, 0xFC, 0x01, 0x1, Space, a_, c_, a_, b_, o_, u_, Exclam, 0xFF};
/*0x1A8*/ const u8 redcart_text[] = {0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Space, p_, u_, n_, i_, u_, Space, o_, Space, a_, d_, v_, e_, r_, s_, 0x17, r_, i_, o_, JumpLine, c_, o_, m_, Space, o_, Space, 0xFC, 0x01, 0x2, R_, e_, d_, Space, C_, a_, r_, d_, 0xFC, 0x01, 0x1, Exclam, Termin};
/*0x1A9*/ const u8 angerpoint_text[] = {0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Space, e_, n_, t_, r_, o_, u_, Space, e_, m_, Space, f_, 0x27, r_, i_, a_, Space, t_, o_, t_, a_, l_, JumpLine, p_, o_, r_, Space, c_, o_, n_, t_, a_, Space, d_, o_, Space, a_, t_, a_, q_, u_, e_, Space, c_, r_, 0x6F, t_, i_, c_, o_, Exclam, Termin};
/*0x1AA*/ const u8 stealhrock_text[] = {P_, e_, d_, r_, a_, s_, Space, p_, o_, n_, t_, i_, a_, g_, u_, d_, a_, s_, JumpLine, f_, e_, r_, i_, r_, a_, m_, Space, 0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Exclam, 0xFF};
/*0x1AB*/ const u8 stickyweb_text[] = {0xFC, 0x01, 0x2, BuffCharac, 16, 0xFC, 0x01, 0x1, Space, f_, i_, c_, o_, u_, JumpLine, n_, a_, Space, T_, e_, i_, a_, Space, P_, e_, g_, a_, j_, o_, s_, a_, Exclam, 0xFF};
/*0x1AC*/ const u8 ejectbutton_text[] = {BuffCharac, 16, Space, f_, o_, i_, Space, t_, r_, o_, c_, a_, d_, o_, JumpLine, p_, e_, l_, o_, Space, BuffCharac, 22, Exclam, 0xFF};
/*0x1AD*/ const u8 absorbed_spikes_text[] = {T_, o_, x_, i_, c_, Space, S_, p_, i_, k_, e_, s_, Space, f_, o_, r_, a_, m_, Space, a_, t_, r_, a_, v_, e_, s_, s_, a_, d_, o_, s_, JumpLine, p_, e_, l_, o_, Space, BuffCharac, 16, Exclam, 0xFF};
/*0x1AE*/ const u8 lost_some_hp_text[] = {BuffCharac, 15, Space, p_, e_, r_, d_, e_, u_, Space, u_, m_, Space, p_, o_, u_, c_, o_, Space, d_, o_, s_, Space, s_, u_, s_, H_, P_, Exclam, 0xFF};
/*0x1AF*/ const u8 tauntended_text[] = {BuffCharac, 18, Apos, s_, Space, t_, a_, u_, n_, t_, JumpLine, a_, c_, a_, b_, o_, u_, Space, E_, x_, c_, l_, u_, i_, d_, o_, Exclam, 0xFF};
/*0x1B0*/ const u8 tormentended_text[] = {BuffCharac, 18, Space, j_, 0x17, Space, n_, 0xF4, o_, Space, e_, s_, t_, 0x17, Space, T_, o_, r_, m_, e_, n_, t_, a_, d_, o_, Exclam, 0xFF};
/*0x1B1*/ const u8 healblockprevents_text[] = {H_, e_, a_, l_, Space, B_, l_, o_, c_, k_, Space, i_, m_, p_, e_, d_, e_, Space, o_, Space, u_, s_, o_, Space, d_, e_, JumpLine, BuffCharac, 54, Exclam, 0xFF};
/*0x1B2*/ const u8 gravityprevents_text[] = {G_, r_, a_, v_, i_, d_, a_, d_, e_, Space, i_, m_, p_, e_, d_, e_, Space, o_, Space, u_, s_, o_, Space, d_, e_, JumpLine, BuffCharac, 54, Exclam, 0xFF};
/*0x1B3*/ const u8 embargoprevents_text[] = {N_, 0xF4, o_, Space, p_, o_, d_, e_, Space, u_, s_, a_, r_, Space, BuffCharac, 54, Space, d_, u_, r_, a_, n_, t_, e_, Space, o_, s_, JumpLine, e_, f_, e_, i_, t_, o_, s_, Space, d_, o_, Space, E_, m_, b_, a_, r_, g_, o_, Exclam, 0xFF};
/*0x1B4*/ const u8 aromaveilprevents_text[] = {BuffCharac, 16, Space, e_, s_, t_, 0x17, Space, p_, r_, o_, t_, e_, g_, i_, d_, o_, JumpLine, p_, e_, l_, o_, Space, BuffCharac, 23, Exclam, 0xFF};
/*0x1B5*/ const u8 empty_text7[] = {0xFF};
/*0x1B6*/ const u8 symbiosispassing_text[] = {BuffCharac, 17, Space, p_, a_, s_, s_, o_, u_, Space, s_, e_, u_, JumpLine, i_, t_, e_, m_, Space, p_, a_, r_, a_, Space, BuffCharac, 19, Exclam, 0xFF};
/*0x1B7*/ const u8 restored_hp_text[] = {BuffCharac, 16, Space, r_, e_, c_, u_, p_, e_, r_, o_, u_, Space, s_, e_, u_, Space, H_, P_, Exclam, 0xFF};
/*0x1B8*/ const u8 replacement_healed_text[] = {O_, Space, s_, u_, b_, s_, t_, i_, t_, u_, t_, o_, Space, f_, o_, i_, Space, c_, u_, r_, a_, d_, o_, Space, c_, o_, m_, p_, l_, e_, t_, a_, m_, e_, n_, t_, e_, Exclam, 0xFF};
/*0x1B9*/ const u8 telekinesis_end_text[] = {BuffCharac, 15, Space, f_, i_, c_, o_, u_, Space, l_, i_, b_, e_, JumpLine, d_, a_, Space, T_, e_, l_, e_, q_, u_, i_, n_, e_, s_, e_, Exclam, 0xFF};
/*0x1BA*/ const u8 embargoend_text[] = {BuffCharac, 15, Space, p_, o_, d_, e_, Space, u_, s_, a_, r_, JumpLine, i_, t_, e_, n_, s_, Space, n_, o_, v_, a_, m_, e_, n_, t_, e_, Exclam, 0xFF};
/*0x1BB*/ const u8 magnetriseend_text[] = {O_, Space, m_, a_, g_, n_, e_, t_, i_, s_, m_, o_, Space, d_, e_, JumpLine, BuffCharac, 15, Exclam, Space, a_, c_, a_, b_, o_, u_, Exclam, 0xFF};
/*0x1BC*/ const u8 empty_text11[] = {0xFF};
/*0x1BD*/ const u8 nofiremoves_text[] = {O_, Space, a_, t_, a_, q_, u_, e_, Space, d_, o_, Space, t_, i_, p_, o_, Dash, F_, i_, r_, e_, JumpLine, s_, e_, Space, a_, p_, a_, g_, o_, u_, Exclam, Space, C_, h_, u_, v_, a_, Space, f_, o_, r_, t_, e_, Exclam, 0xFF};
/*0x1BE*/ const u8 nowatermoves_text[] = {O_, Space, a_, t_, a_, q_, u_, e_, Space, d_, o_, Space, t_, i_, p_, o_, Dash, W_, a_, t_, e_, r_, JumpLine, e_, v_, a_, p_, o_, r_, o_, u_, Space, n_, o_, Space, s_, o_, l_, Space, i_, n_, t_, e_, n_, s_, o_, Exclam, 0xFF};
/*0x1BF*/ const u8 trickroom_ends[] = {A_, s_, Space, d_, i_, m_, e_, n_, s_, 0xF5, e_, s_, Space, v_, o_, l_, t_, a_, r_, a_, m_, Space, a_, o_, Space, n_, o_, r_, m_, a_, l_, Exclam, 0xFF};
/*0x1C0*/ const u8 magicroom_ends[] = {M_, a_, g_, i_, c_, Space, R_, o_, o_, m_, Space, a_, c_, a_, b_, o_, u_, Space, e_, Space, s_, e_, u_, s_, Space, i_, t_, e_, n_, s_, JumpLine, v_, o_, l_, t_, a_, r_, a_, m_, Space, a_, o_, Space, n_, o_, r_, m_, a_, l_, Exclam, 0xFF};
/*0x1C1*/ const u8 wonderoom_ends[] = {W_, o_, n_, d_, e_, r_, Space, R_, o_, o_, m_, Space, a_, c_, a_, b_, o_, u_, Space, e_, Space, a_, Space, D_, e_, f_, Space, e_, JumpLine,S_, p_, Dot, Space, D_, e_, f_, Space, v_, o_, l_, t_, a_, r_, a_, m_, Space, a_, o_, Space, n_, o_, r_, m_, a_, l_, Exclam,0xFF};
/*0x1C2*/ const u8 gravity_ends_text[] = {A_, Space, g_, r_, a_, v_, i_, d_, a_, d_, e_, Space, v_, o_, l_, t_, o_, u_, Space, a_, o_, Space, n_, o_, r_, m_, a_, l_, Exclam, 0xFF}; 
/*0x1C3*/ const u8 grassyterainends_text[] = {O_, Space, g_, r_, a_, m_, a_, Space, d_, i_, s_, s_, i_, p_, o_, u_, Space, d_, o_, JumpLine,c_, a_, m_, p_, o_, Space, d_, e_, Space, b_, a_, t_, a_, l_, h_, a_, Exclam, 0xFF};
/*0x1C4*/ const u8 mistyterrainends_text[] = {T_, h_, e_, Space, m_, i_, s_, t_,  Space, d_, i_, s_, a_, p_, p_, e_, a_, r_, e_, d_, Space, f_, r_, o_, m_, JumpLine,t_, h_, e_, Space, b_, a_, t_, t_, l_, e_, f_, i_, e_, l_, d_, Exclam, 0xFF};
/*0x1C5*/ const u8 electrerrainends_text[] = {A_, Space, e_, l_, e_, t_, r_, i_, c_, i_, d_, a_, d_, e_, Space, d_, i_, s_, s_, i_, p_, o_, u_, Space, d_, o_, JumpLine,c_, a_, m_, p_, o_, Space, d_, e_, Space, b_, a_, t_, a_, l_, h_, a_, Dot, 0xFF};
/*0x1C6*/ const u8 grassyterrain_heal[] = {BuffCharac, 19, Space, r_, e_, c_, u_, p_, e_, r_, o_, u_, Space, u_, m_, Space, p_, o_, u_, c_, o_, Space, d_, e_, JumpLine, H_, P_, Space, c_, o_, m_, Space, o_, Space, T_, e_, r_, r_, e_, n_, o_, Space, G_, r_, a_, m_, a_, d_, o_, Exclam, 0xFF};
/*0x1C7*/ const u8 fogcontinues_text[] = {O_, Space, n_, e_, v_, o_, e_, i_, r_, o_, Space, e_, s_, t_, 0x17, Space, e_, s_, p_, e_, s_, s_, o_, Dot, Dot, Dot, 0xFF};
/*0x1C8*/ const u8 fogends_text[] = {O_, Space, n_, e_, v_, o_, e_, i_, r_, o_, Space, d_, i_, s_, s_, i_, p_, o_, u_, Exclam, 0xFF};
/*0x1C9*/ const u8 obtaineditem[] = {BuffCharac, 15, Space, o_, b_, t_, e_, v_, e_, Space, BuffCharac, 22, Exclam, 0xFF};
/*0x1CA*/ const u8 tailwind_begins_text[] = {U_, m_, Space, b_, r_, i_, s_, a_, Space, l_, e_, v_, e_, Space, s_, o_, p_, r_, o_, u_, Space, 0xFE, d_, e_, Space, t_, r_, 0x17, s_, Space, d_, o_, Space, BuffCharac, 0xF, Space, t_, i_, m_, e_, Exclam, 0xFF};
/*0x1CB*/ const u8 luckychant_begins_text[] = {O_, Space, L_, u_, c_, k_, y_, Space, C_, h_, a_, n_, t_, Space, p_, r_, o_, t_, e_, g_, e_, u_, JumpLine, o_, Space, t_, i_, m_, e_, Space, d_, o_, Space, BuffCharac, 0xF, Space, c_, o_, n_, t_, r_, a_, Space, g_, o_, l_, p_, e_, s_, Space, c_, r_, 0x6F, t_, i_, c_, o_, s_, Exclam, 0xFF};
/*0x1CC*/ const u8 magnetrise_begins_text[] = {BuffCharac, 0xF, Space, l_, e_, v_, i_, t_, o_, u_, 0xFE, u_, s_, a_, n_, d_, o_, Space, M_, a_, g_, n_, e_, t_, R_, i_, s_, e_, Exclam, 0xFF};
/*0x1CD*/ const u8 magicroom_start_text[] = {U_, m_, a_, Space, 0x17, r_, e_, a_, Space, e_, s_, t_, r_, a_, n_, h_, a_, Space, f_, o_, i_, Space, c_, r_, i_, a_, d_, a_, 0xFE, a_, n_, u_, l_, a_, n_, d_, o_, Space, e_, f_, e_, i_, t_, o_, s_, Space, d_, e_, Space, i_, t_, e_, n_, s_, Exclam, 0xFF};
/*0x1CE*/ const u8 trickroom_start_text[] = {BuffCharac, 0xF, Space, d_, i_, s_, t_, o_, r_, c_, e_, u_, 0xFE, a_, s_, Space, d_, i_, m_, e_, n_, s_, 0xF5, e_, s_, Exclam, 0xFF};
/*0x1CF*/ const u8 wonderroom_start_text[] = {U_, m_, a_, Space, 0x17, r_, e_, a_, Space, e_, s_, t_, r_, a_, n_, h_, a_, Space, f_, o_, i_, Space, c_, r_, i_, a_, d_, a_, Space, o_, n_, d_, e_, 0xFE, D_, e_, f_, Space, e_, Space, S_, p_, Dot, D_, e_, f_, Space, s_, 0xF4, o_, Space, t_, r_, o_, c_, a_, d_, o_, s_, Exclam, 0xFF};
/*0x1D0*/ const u8 gravitystarts_text[] = {G_, r_, a_, v_, i_, d_, a_, d_, e_, Space, Space, a_, u_, m_, e_, n_, t_, o_, u_, Exclam, 0xFF};
/*0x1D1*/ const u8 telekinesis_start_text[] = {BuffCharac, 16, Space, f_, o_, i_, Space, l_, a_, n_, 0x19, a_, d_, o_, JumpLine, n_, o_, Space, a_, r_, Exclam, 0xFF};
/*0x1D2*/ const u8 abilitychange_text[] = {BuffCharac, 16, Space, m_, u_, d_, o_, u_, Space, d_, e_, Space, a_, b_, i_, l_, i_, t_, y_, JumpLine, p_, a_, r_, a_, Space, BuffCharac, 0x19, Exclam, 0xFF};
/*0x1D3*/ const u8 statswap_text[] = {BuffCharac, 15, Space, t_, r_, o_, c_, o_, u_, Space, t_, o_, d_, o_, s_, Space, o_, s_, Space, a_, u_, m_, e_, n_, t_, o_, s_, JumpLine, d_, e_, Space, s_, t_, a_, t_, u_, s_, Space, c_, o_, m_, Space, s_, e_, u_, Space, BuffCharac, Space, e_, Space, BuffCharac, 1, 0xFA, a_, l_, v_, o_, Exclam, 0xFF};
/*0x1D4*/ const u8 heartswap_text[] = {BuffCharac, 15, Space, t_, r_, o_, c_, o_, u_, Space, a_, l_, t_, e_, r_, a_, 0x19, 0xF5, e_, s_, JumpLine, d_, e_, Space, s_, t_, a_, t_, u_, s_, Space, c_, o_, m_, Space, o_, Space, a_, l_, v_, o_, Exclam, 0xFF};
/*0x1D5*/ const u8 bugbite_text[] = {BuffCharac, 15, Space, r_, o_, u_, b_, o_, u_, Space, e_, Space, c_, o_, m_, e_, u_, JumpLine, o_, Space, BuffCharac, 22, Space, d_, e_, Space, BuffCharac, 16, Exclam, 0xFF};
/*0x1D6*/ const u8 incinerate_text[] = {O_, Space, BuffCharac, 22, Space, d_, e_, Space, BuffCharac, 16, JumpLine, f_, o_, i_, Space, q_, u_, e_, i_, m_, a_, d_, o_, Exclam, 0xFF};
/*0x1D7*/ const u8 gravitybringsdown_text[] = {BuffCharac, 15, Space, n_, 0xF4, o_, Space, p_, o_, d_, e_, u_, Space, p_, e_, r_, m_, a_, n_, e_, c_, e_, r_, JumpLine, n_, o_, Space, a_, r_, Space, d_, e_, v_, i_, d_, o_, Space, 0x16, Space, G_, r_, a_, v_, i_, t_, y_, Exclam, 0xFF};
/*0x1D8*/ const u8 fellforfeint[] = {BuffCharac, 16, Space, c_, a_, i_, u_, Space, n_, a_, Space, a_, r_, m_, a_, d_, i_, l_, h_, a_, Space, d_, o_, Space, F_, e_, i_, n_, t_, Exclam, 0xFF};
/*0x1D9*/ const u8 protection_broken[] = {BuffCharac, 15, Space, r_, o_, m_, p_, e_, u_, Space, a_, Space, JumpLine, p_, r_, o_, t_, e_, 0x19, 0xF4, o_, Space, d_, e_, Space, BuffCharac, 16, Exclam, 0xFF};
/*0x1DA*/ const u8 teamprotection[] = {BuffCharac, Space, p_, r_, o_, t_, e_, g_, e_, Space, JumpLine, o_, Space, t_, i_, m_, e_, Space, d_, e_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x1DB*/ const u8 becameatype[] = {O_, Space, t_, i_, p_, o_, Space, BuffCharac, Space, Space, f_, o_, i_, JumpLine, a_, d_, i_, c_, i_, o_, n_, a_, d_, o_, Space, a_, Space, BuffCharac, 16, Exclam, 0xFF};
/*0x1DC*/ const u8 targetsabilitybecameattacker[] = {BuffCharac, 16, Space, a_, d_, q_, u_, i_, r_, i_, u_, Space, a_, JumpLine, a_, b_, i_, l_, i_, t_, y_, Space, BuffCharac, 25, Exclam, 0xFF};
/*0x1DD*/ const u8 gastro_text[] = {A_, Space, a_, b_, i_, l_, i_, t_, y_, Space, d_, e_, Space, BuffCharac, 16, Space, f_, o_, i_, Space, s_, u_, p_, r_, i_, m_, i_, d_, a_, Exclam, 0xFF};
/*0x1DE*/ const u8 embargostart_text[] = {BuffCharac, 16, Space, n_, 0xF4, o_, Space, p_, o_, d_, e_, Space, u_, s_, a_, r_, JumpLine, i_, t_, e_, n_, s_, Space, a_, g_, o_, r_, a_, Exclam, 0xFF};
/*0x1DF*/ const u8 afteryout_text[] = {BuffCharac, 16, Space, a_, c_, e_, i_, t_, o_, u_, Space, a_, Space, p_, r_, o_, p_, o_, s_, t_, a_, Exclam, 0xFF};
/*0x1E0*/ const u8 powder_text[] = {BuffCharac, 16, Space, f_, o_, i_, JumpLine, e_, n_, v_, o_, l_, v_, i_, d_, o_, Space, e_, m_, Space, p_, 0x23, Exclam, 0xFF};
/*0x1E1*/ const u8 powderdamage_text[] = {O_, Space, p_, 0x23, Space, e_, m_, Space, BuffCharac, 15, Space, e_, x_, p_, l_, o_, d_, i_, u_, JumpLine, a_, o_, Space, t_, o_, c_, a_, r_, Space, n_, a_, Space, c_, h_, a_, m_, a_, Exclam, 0xFF};
/*0x1E2*/ const u8 statchangesremoved_text[] = {O_, s_, Space, a_, u_, m_, e_, n_, t_, o_, s_, Space, d_, e_, Space, s_, t_, a_, t_, u_, s_, Space, d_, e_, JumpLine, BuffCharac, 17, Space, f_, o_, r_, a_, m_, Space, r_, e_, m_, o_, v_, i_, d_, o_, s_, Exclam, 0xFF};
/*0x1E3*/ const u8 electify_text[] = {O_, s_, Space, g_, o_, l_, p_, e_, s_, Space, d_, e_, Space, BuffCharac, 16, JumpLine, f_, o_, r_, a_, m_, Space, e_, l_, e_, t_, r_, i_, f_, i_, c_, a_, d_, o_, s_, Exclam, 0xFF};
/*0x1E4*/ const u8 stealthrock2_text[] = {P_, e_, d_, r_, a_, s_, Space, p_, o_, n_, t_, i_, a_, g_, u_, d_, a_, s_, JumpLine, c_, i_, r_, c_, u_, n_, d_, a_, m_, Space, BuffCharac, 63, Exclam, 0xFF};
/*0x1E5*/ const u8 toxicspikes2_text[] = {E_, s_, p_, i_, n_, h_, o_, s_, Space, t_, 0x23, x_, i_, c_, o_, s_, Space, f_, o_, r_, a_, m_, Space, e_, s_, p_, a_, l_, h_, a_, d_, o_, s_, JumpLine, a_, o_, Space, r_, e_, d_, o_, r_, Space, d_, o_, s_, Space, p_, 0x1B, s_, Space, d_, e_, Space, BuffCharac, 63, Exclam, 0xFF};
/*0x1E6*/ const u8 stickyweb2_text[] = {U_, m_, a_, Space, t_, e_, i_, a_, Space, p_, e_, g_, a_, j_, o_, s_, a_, Space, s_, e_, Space, e_, s_, p_, a_, l_, h_, o_, u_, JumpLine, a_, o_, Space, r_, e_, d_, o_, r_, Space, d_, o_, s_, Space, p_, 0x1B, s_, Space, d_, e_, Space, BuffCharac, 63, Exclam, 0xFF};
/*0x1E7*/ const u8 nimble_text[] = {BuffCharac, 15, Space, f_, i_, c_, o_, u_, Space, 0x17, g_, i_, l_, Exclam, 0xFF};
/*0x1E8*/ const u8 iondelugeset_text[] = {U_, m_, Space, d_, i_, l_, 0x27, v_, i_, o_, Space, d_, e_, Space, i_, 0xF5, e_, s_, Space, i_, n_, v_, a_, d_, i_, u_, JumpLine, o_, Space, c_, a_, m_, p_, o_, Space, d_, e_, Space, b_, a_, t_, a_, l_, h_, a_, Exclam, 0xFF};
/*0x1E9*/ const u8 reflecttype_text[] = {O_, Space, t_, i_, p_, o_, Space, d_, e_, Space, BuffCharac, 15, Space, m_, u_, d_, o_, u_, Space, p_, a_, r_, a_, JumpLine, o_, Space, m_, e_, s_, m_, o_, Space, t_, i_, p_, o_, Space, d_, e_, Space, BuffCharac, 16, Termin};
/*0x1EA*/ const u8 healblock_start_text[] = {BuffCharac, 16, Space, f_, o_, i_, Space, i_, m_, p_, e_, d_, i_, d_, o_, Space, d_, e_, JumpLine, s_, e_, Space, c_, u_, r_, a_, r_, Exclam, 0xFF};
/*0x1EB*/ const u8 smackdown_text[] = {BuffCharac, 16, Space, f_, o_, i_, Space, a_, t_, i_, r_, a_, d_, o_, Space, a_, o_, Space, c_, h_, 0xF4, o_, Exclam, 0xFF};
/*0x1EC*/ const u8 rapidspinontoxicspikes_text[] = {O_, s_, Space, e_, s_, p_, i_, n_, h_, o_, s_, Space, t_, 0x23, x_, i_, c_, o_, s_, Space, d_, e_, s_, a_, p_, a_, r_, e_, c_, e_, r_, a_, m_, JumpLine, d_, o_, Space, l_, a_, d_, o_, Space, d_, e_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x1ED*/ const u8 rapidspinonstealthrock_text[] = {A_, s_, Space, p_, e_, d_, r_, a_, s_, Space, a_, f_, i_, a_, d_, a_, s_, Space, d_, e_, s_, a_, p_, a_, r_, e_, c_, e_, r_, a_, m_, JumpLine, d_, o_, Space, l_, a_, d_, o_, Space, d_, e_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x1EE*/ const u8 rapidspinonstickyweb_text[] = {A_, Space, t_, e_, i_, a_, Space, p_, e_, g_, a_, j_, o_, s_, a_, Space, d_, e_, s_, a_, p_, a_, r_, e_, c_, e_, u_, JumpLine, d_, o_, Space, l_, a_, d_, o_, Space, d_, e_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x1EF*/ const u8 powertrick_text[] = {BuffCharac, 15, Space, i_, n_, v_, e_, r_, t_, e_, u_, Space, A_, t_, k_, Space, e_, Space, D_, e_, f_, Exclam, 0xFF};
/*0x1F0*/ const u8 soak_text[] = {BuffCharac, 16, Space, f_, o_, i_, Space, t_, r_, a_, n_, s_, f_, o_, r_, m_, a_, d_, o_, JumpLine, n_, o_, Space, t_, i_, p_, o_, Space, BuffCharac, Exclam, 0xFF};
/*0x1F1*/ const u8 defogspikes_text[] = {O_, s_, Space, e_, s_, p_, i_, n_, h_, o_, s_, Space, d_, e_, s_, a_, p_, a_, r_, e_, c_, e_, r_, a_, m_, JumpLine, d_, o_, Space, l_, a_, d_, o_, Space, d_, e_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x1F2*/ const u8 power_text[] = {p_, o_, d_, e_, r_, 0xFF};
/*0x1F3*/ const u8 guard_text[] = {g_, u_, a_, r_, d_, a_, 0xFF};
/*0x1F4*/ const u8 psychosplit_text[] = {BuffCharac, 15, Space, r_, e_, p_, a_, r_, t_, i_, u_, Space, s_, e_, u_, s_, JumpLine, BuffCharac, Space, c_, o_, m_, Space, o_, Space, a_, l_, v_, o_, Exclam, 0xFF};
/*0x1F5*/ const u8 stockpileend_text[] = {O_, Space, e_, f_, e_, i_, t_, o_, Space, S_, t_, o_, c_, k_, p_, i_, l_, e_, Space, d_, e_, Space, BuffCharac, 15, JumpLine, a_, c_, a_, b_, o_, u_, Exclam, 0xFF};
/*0x1F6*/ const u8 geomancy_text[] = {BuffCharac, 15, Space, a_, b_, s_, o_, r_, v_, e_, Space, a_, Space, e_, n_, e_, r_, g_, i_, a_, Exclam, 0xFF};
/*0x1F7*/ const u8 powerherb_text[] = {BuffCharac, 15, Space, b_, e_, c_, a_, m_, e_, Space, f_, u_, l_, l_, y_, Space, c_, h_, a_, r_, g_, e_, d_, JumpLine, d_, u_, e_, Space, t_, o_, Space, i_, t_, s_, Space, BuffCharac, 22, Exclam, 0xFF};
/*0x1F8*/ const u8 iceburn_text[] = {BuffCharac, 15, Space, b_, e_, c_, a_, m_, e_, Space, c_, l_, o_, a_, k_, e_, d_, JumpLine, i_, n_, Space, f_, r_, e_, e_, z_, i_, n_, g_, Space, a_, i_, r_, Exclam, 0xFF};
/*0x1F9*/ const u8 freezeshock_text[] = {BuffCharac, 15, Space, b_, e_, c_, a_, m_, e_, Space, c_, l_, o_, a_, k_, e_, d_, JumpLine, i_, n_, Space, f_, r_, e_, e_, z_, i_, n_, g_, Space, l_, i_, g_, h_, t_, Exclam, 0xFF};\
/*0x1FA*/ const u8 shadowforce_text[] = {BuffCharac, 15, Space, v_, a_, n_, i_, s_, h_, e_, d_, Space, i_, n_, s_, t_, a_, n_, t_, l_, y_, Exclam, 0xFF};
/*0x1FB*/ const u8 mistyterrain_text[] = {M_, i_, s_, t_, Space, s_, w_, i_, r_, l_, e_, d_, Space, a_, b_, o_, u_, t_, Space, t_, h_, e_, Space, b_, a_, t_, t_, l_, e_, f_, i_, e_, l_, d_, Exclam, 0xFF};
/*0x1FC*/ const u8 grassyterrain_text[] = {G_, r_, a_, s_, s_, Space, g_, r_, e_, w_, Space, t_, o_, Space, c_, o_, v_, e_, r_, Space, t_, h_, e_, Space, b_, a_, t_, t_, l_, e_, f_, i_, e_, l_, d_, Exclam, 0xFF};
/*0x1FD*/ const u8 electricterrain_text[] = {A_, n_, Space, e_, l_, e_, c_, t_, r_, i_, c_, Space, c_, u_, r_, r_, e_, n_, t_, JumpLine, r_, u_, n_, s_, Space, a_, c_, r_, o_, s_, s_, Space, t_, h_, e_, Space, b_, a_, t_, t_, l_, e_, f_, i_, e_, l_, d_, Exclam, 0xFF};
/*0x1FE*/ const u8 aquaring_text[] = {BuffCharac, 15, Space, s_, u_, r_, r_, o_, u_, n_, d_, e_, d_, Space, i_, t_, s_, e_, l_, f_, JumpLine, w_, i_, t_, h_, Space, a_, Space, v_, e_, i_, l_, Space, o_, f_, Space, w_, a_, t_, e_, r_,Exclam, 0xFF};
/*0x1FF*/ const u8 aquaringheal_text[] = {A_, q_, u_, a_, Space, R_, i_, n_,g_, Space, r_, e_, s_, t_, o_, r_, e_, d_, JumpLine, BuffCharac, 15, Apos, s_, Space, H_, P_, Exclam, 0xFF};
/*0x200*/ const u8 assaultvest_text[] = {T_, h_, e_, Space, e_, f_, f_, e_, c_, t_, s_, Space, o_, f_, Space, BuffCharac, 22, JumpLine, p_, r_, e_, v_, e_, n_, t_, Space, u_, s_, i_, n_, g_, Space, s_, t_, a_, t_, u_, s_, Space, m_, o_, v_, e_, s_, Exclam, 0xFB, 0xFF};
/*0x201*/ const u8 gravityprevents2_text[] = {BuffCharac, 18, Space, c_, a_, n_, Apos, t_, Space, u_, s_, e_, JumpLine, BuffCharac, 20, Space, b_, e_, c_, a_, u_, s_, e_, Space, o_, f_, Space, g_, r_, a_, v_, i_, t_, y_, Exclam, 0xFB, 0xFF};
/*0x202*/ const u8 healblockprevents2_text[] = {BuffCharac, 18, Space, c_, a_, n_, Apos, t_, Space, u_, s_, e_, JumpLine, BuffCharac, 20, Space, b_, e_, c_, a_, u_, s_, e_, Space, o_, f_, Space, H_, e_, a_, l_, Space, B_, l_, o_, c_, k_, Exclam, 0xFB, 0xFF};
/*0x203*/ const u8 let_it_move_first_text[] = {BuffCharac, 15, Apos, s_, Space, BuffCharac, 22, Space, l_, e_, t_, JumpLine, i_, t_, Space, m_, o_, v_, e_, Space, f_, i_, r_, s_, t_, Exclam, Termin};
/*0x204*/ const u8 mega_evolved_text[] = {BuffCharac, 15, Space, h_, a_, s_, Space, M_, e_, g_, a_, Space, E_, v_, o_, l_, v_, e_, d_, JumpLine, i_, n_, t_, o_, Space, M_, e_, g_, a_, Space, BuffCharac, Space, Exclam, 0xFB, 0xFF};
/*0x205*/ const u8 mega_trigger_text[] = {BuffCharac, 15, Apos, s_, Space, BuffCharac, 22, Space, i_, s_, Space, r_, e_, a_, c_, t_, i_, n_, g_, JumpLine, t_, o_, Space, BuffCharac, 52, Apos, s_, Space, BuffCharac, 1, Exclam, 0xFB, 0xFF};
/*0x206*/ const u8 fervent_trigger_text[] = {BuffCharac, 52, Apos, s_, Space, f_, e_, r_, v_, e_, n_, t_, Space, w_, i_, s_, h_, JumpLine, r_, e_, a_, c_, h_, e_, d_, Space, BuffCharac, 0xF, Exclam, Termin};
/*0x207*/ const u8 quash_text[] = {BuffCharac, 16, Apos, s_, Space, m_, o_, v_, e_, JumpLine, w_, a_, s_, Space, p_, o_, s_, t_, p_, o_, n_, e_, d_, Exclam, 0xFF};
/*0x208*/ const u8 allyswitch_text[] = {BuffCharac, 19, Space, a_, n_, d_, Space, BuffCharac, 15, JumpLine, s_, w_, i_, t_, c_, h_, e_, d_, Space, p_, l_, a_, c_, e_, s_, Exclam, 0xFF};
/*0x209*/ const u8 topsyturvy_text[] = {BuffCharac, 16, Apos, s_, Space, s_, t_, a_, t_, Space, c_, h_, a_, n_, g_, e_, s_, JumpLine, w_, e_, r_, e_, Space, a_, l_, l_, Space, r_, e_, v_, e_, r_, s_, e_, d_, Exclam, 0xFF};
/*0x20A*/ const u8 bestow_text[] = {BuffCharac, 16, Space, r_, e_, c_, e_, v_, i_, e_, d_, Space, o_, n_, e_, JumpLine, BuffCharac, 22, Space, f_, r_, o_, m_, Space, BuffCharac, 15, Exclam, 0xFF};
/*0x20B*/ const u8 statushealpoison_text[] = {BuffCharac, Space, w_, a_, s_, Space, c_, u_, r_, e_, d_, Space, o_, f_, JumpLine, i_, t_, s_, Space, p_, o_, i_, s_, o_, n_, i_, n_, g_, Exclam, 0xFF};
/*0x20C*/ const u8 statushealburn_text[] = {BuffCharac, Space, h_, e_, a_, l_, e_, d_, JumpLine, i_, t_, s_, Space, b_, u_,r_, n_, Exclam, 0xFF};
/*0x20D*/ const u8 statushealpar_text[] = {BuffCharac, Space, w_, a_, s_, Space, c_, u_, r_, e_, d_, Space, o_, f_, JumpLine, p_, a_, r_, a_, l_, y_, s_, i_, s_, Exclam, 0xFF};
/*0x20E*/ const u8 statushealslp_text[] = {BuffCharac, Space, w_, o_, k_, e_, Space, u_, p_, Exclam, 0xFF};
/*0x20F*/ const u8 statushealfrz_text[] = {BuffCharac, Space, t_, h_, a_, w_, e_, d_, Space, o_, u_, t_, Exclam, 0xFF};
/*0x210*/ const u8 primal_reversion_text[] = {BuffCharac, 15, Apos, s_, Space, P_, r_, i_, m_, a_, l_, Space, R_, e_, v_, e_, r_, s_, i_, o_, n_, Exclam, JumpLine, I_, t_, Space, r_, e_, v_, e_, r_, t_, e_, d_, Space, t_, o_, Space, i_, t_, s_, Space, p_, r_, i_, m_, a_, l_, Space, f_, o_, r_, m_, Exclam, Termin};
/*0x211*/ const u8 congrats_player_text[] = {C_, o_, n_, g_, r_, a_, t_, u_, l_, a_, t_, i_, o_, n_, s_, Space, BuffCharac, 35, Exclam, 0xFF};
/*0x212*/ const u8 happyhour_text[] = {E_, v_, e_, r_, y_, o_, n_, e_, Space, i_, s_, Space, c_, a_, u_, g_, h_, t_, Space, u_, p_, JumpLine, i_, n_, Space, t_, h_, e_, Space, h_, a_, p_, p_, y_, Space, a_, t_, m_, o_, s_, p_, h_, e_, r_, e_, Exclam, 0xFF};
/*0x213*/ const u8 skydrop1_text[] = {BuffCharac, 15, Space, t_, o_, o_,k_, Space, BuffCharac, 16, JumpLine, i_, n_, t_, o_, Space, t_, h_, e_, Space, s_, k_, y_, Exclam, 0xFF};
/*0x214*/ const u8 skydrop2_text[] = {BuffCharac, 16, Space, w_, a_, s_, Space, f_, r_, e_, e_, d_, JumpLine, f_,r_, o_,m_, Space, t_, h_, e_, Space, s_, k_, y_, Space, d_, r_, o_, p_, Exclam, 0xFF};
/*0x215*/ const u8 skydroptooheavy_text[] = {BuffCharac, 16, Space, i_, s_, Space, t_, o_, o_, Space, h_, e_, a_, v_, y_, JumpLine, t_, o_, Space, b_, e_, Space, l_, i_, f_, t_, e_, d_, Exclam, 0xFF};
/*0x216*/ const u8 fairylock_text[] = {N_, o_, Space, o_, n_, e_, Space, w_,i_,l_,l_, Space, b_, e_, Space, a_, b_, l_, e_, Space, t_, o_, JumpLine, r_, u_, n_, Space, a_, w_, a_, y_, Space, d_, u_, r_, i_, n_, g_, Space, t_, h_, e_, Space, n_, e_, x_, t_, Space, t_, u_, r_, n_, Exclam, 0xFF};
/*0x217*/ const u8 illusion_off_text[] = {BuffCharac, 16, Apos, s_, Space, i_, l_, l_, u_, s_, i_, o_, n_, JumpLine, w_, o_, r_, e_, Space, o_, f_, f_, Exclam, 0xFF};
/*0x218*/ const u8 protean_text[] = {BuffCharac, 15, Space, t_, r_, a_, n_, s_, f_, o_, r_, m_, e_, d_, Space, i_, n_, t_, o_, JumpLine, t_, h_, e_, Space, BuffCharac, 0x0, Space, t_, y_, p_, e_, Exclam, 0xFF};
/*0x219*/ const u8 gem_text[] = {T_, h_, e_, Space, BuffCharac, 22, Space, s_, t_, r_, e_, n_, g_, t_, h_, e_, n_, e_, d_, JumpLine, BuffCharac, 0x0, Apos, s_, Space, p_, o_, w_, e_, r_, Exclam, 0xFF};
/*0x21A*/ const u8 telepathy_text[] = {BuffCharac, 16, Space, a_, v_, o_, i_, d_, s_, Space, a_, t_, t_, a_, c_, k_, s_, JumpLine, b_, y_, Space, i_, t_, s_, Space, a_, l_, l_, y_, Space, P_, o_, k_, Poke_e, m_, o_, n_, Exclam, Termin};
/*0x21B*/ const u8 flame_burst_text[] = {T_, h_, e_, Space, b_, u_, r_, s_, t_, i_, n_, g_, Space, f_, l_, a_, m_, e_, s_, JumpLine, h_, i_, t_, Space, BuffCharac, 17, Exclam, 0xFF};
/*0x21C*/ const u8 zen_mode_text[] = {Z_, e_, n_, Space, M_, o_, d_, e_, Space, t_, r_, i_, g_, g_, e_, r_, e_, d_, Exclam, 0xFF};
/*0x21D*/ const u8 zen_end_text[] = {Z_, e_, n_, Space, M_, o_, d_, e_, Space, e_, n_, d_, e_, d_, Exclam, 0xFF};
/*0x21E*/ const u8 form_change_text[] = {BuffCharac, 0xF, Space, t_, r_, a_, n_, s_, f_, o_, r_, m_, e_, d_, Exclam, 0xFF};
/*0x21F*/ const u8 partner_wait_text[] = {BuffCharac, 0xF, Space, i_, s_, Space, w_, a_, i_, t_, i_, n_, g_, JumpLine, f_, o_, r_, Space, BuffCharac, 0x13, Apos, s_, Space, m_, o_, v_, e_, Dot, Dot, Dot, Termin};
/*0x220*/ const u8 combined_move_text[] = {T_, h_, e_, Space, t_, w_, o_, Space, m_, o_, v_, e_, s_, Space, h_, a_, v_, e_, Space, b_ ,e_, c_, o_, m_, e_, Space, o_, n_, e_, Exclam, JumpLine, I_, t_, Apos, s_, Space, a_, Space, c_, o_, m_, b_, i_, n_, e_, d_, Space, m_, o_, v_, e_, Exclam, Termin};
/*0x221*/const u8 userteam_uc_text[] = {Y_, o_, u_, r_, Space, t_, e_, a_, m_, Termin};
/*0x222*/const u8 foeteam_uc_text[] = {T_, h_, e_, Space, f_, o_, e_, Apos, s_, Space, t_, e_, a_, m_, Termin};
/*0x223*/const u8 fire_sea_text[] = {A_, Space, s_, e_, a_, Space, o_, f_, Space, f_, i_, r_, e_, Space, e_, n_, v_, e_, l_, o_, p_, e_, d_, JumpLine, Space, BuffCharac, 0x0, Exclam, Termin};
/*0x224*/const u8 fire_sea_hurt_text[] = {BuffCharac, 0xF, Space, i_, s_, Space, h_, u_, r_, t_, JumpLine, b_, y_, Space, t_, h_, e_, Space, s_, e_, a_, Space, o_, f_, Space, f_, i_, r_, e_, Exclam, Termin};
/*0x225*/const u8 swamp_text[] = {A_, Space, s_, w_, a_, m_, p_, Space, e_, n_, v_, e_, l_, o_, p_, e_, d_, JumpLine, Space, BuffCharac, 0x0, Exclam, Termin};
/*0x226*/const u8 rainbow_text[] = {A_, Space, r_, a_, i_, n_, b_, o_, w_, Space, a_, p_, p_, e_, a_, r_, e_, d_, Space, i_, n_, Space, t_, h_, e_, Space, s_, k_, y_, JumpLine, o_, n_, Space, BuffCharac, 0x0, Apos, s_, Space, s_, i_, d_, e_, Exclam, Termin};
/*0x227*/const u8 swamp_end_text[] = {T_, h_, e_, Space, s_, w_, a_, m_, p_, Space, a_, r_, o_, u_, n_, d_, JumpLine, BuffCharac, 0x0, Space, d_, i_, s_,  a_, p_, p_, e_, a_, r_, e_, d_, Exclam, Termin};
/*0x228*/const u8 fire_sea_end_text[] = {T_, h_, e_, Space, s_, e_, a_, Space, o_, f_, Space, f_, i_, r_, e_, Space, a_, r_, o_, u_, n_, d_, JumpLine, BuffCharac, 0x0, Space, d_, i_, s_,  a_, p_, p_, e_, a_, r_, e_, d_, Exclam, Termin};
/*0x229*/const u8 rainbow_end_text[] = {T_, h_, e_, Space, r_, a_, i_, n_, b_, o_, w_, Space, o_, v_, e_, r_, JumpLine, BuffCharac, 0x0, Space, d_, i_, s_,  a_, p_, p_, e_, a_, r_, e_, d_, Exclam, Termin};
/*0x22A*/const u8 berry_redux_text[] = {BuffCharac, 0x10, Apos, s_, Space, BuffCharac, 0x16, JumpLine, r_, e_, d_, u_, c_, e_, d_, Space, BuffCharac, 0x14, Apos, s_, Space, p_, o_, w_, e_, r_, Exclam, Termin};
/*0x22B*/const u8 pokeballblock_text[] = {BuffCharac, 53, Space, b_, l_, o_, c_, k_, e_, d_, Space, t_, h_, e_, Space, B_, a_, l_, l_, Exclam, 0xFF};
/*0x22C*/const u8 player_wonlost_text[] = {BuffCharac, 35, Space, BuffCharac, 55, JumpLine, BuffCharac, 28, Space, BuffCharac, 29, Exclam, 0xFF};
/*0x22D*/const u8 trainerwon_text[] = {BuffCharac, 37, 0xFF};
/*0x22E*/const u8 skydrop_cantchooseaction_text[] = {S_, k_, y_, Space, D_, r_, o_, p_, Space, w_, o_, n_, Apos, t_, Space, l_, e_, t_, JumpLine, BuffCharac, 11, g_, o_, Exclam, 0xFF};
/*0x22F*/const u8 trainer_sliding_text[] = {BuffCharac, 56, 0xFF};
/*0x230*/const u8 sweetveilactivation_text[] = {BuffCharac, 16, Space, s_, u_, r_, r_, o_, u_, n_, d_, e_, d_, Space, i_, t_, s_, e_, l_, f_, JumpLine, w_, i_, t_, h_, Space, a_, Space, v_, e_, i_, l_, Space, o_, f_, Space, s_, w_, e_, e_, t_, n_, e_, s_, s_, Exclam, 0xFF};
/*0x231*/const u8 sportend_text[] = {T_, h_, e_, Space, e_, f_, f_, e_, c_, t_, s_, Space, o_, f_, Space, BuffCharac, JumpLine, h_, a_, v_, e_, Space, f_, a_, d_, e_, d_, Exclam, 0xFF};
/*0x232*/const u8 scr_active_ability_text[] = {BuffCharac, 19, 0xB4, 0xE7, Space, BuffCharac, 26, 0xAB, 0xFF};
/*0x233*/const u8 psychicterrain_text[] = {T_, h_, e_, Space, b_, a_, t_, t_, l_, e_, f_, i_, e_, l_, d_, Space, g_, o_, t_, Space, w_, e_, i_, r_, d_, Exclam, 0xFF};
/*0x234*/const u8 laserfocus_text[] = {BuffCharac, 15, Space, c_, o_, n_, c_, e_, n_, t_, r_, a_, t_, e_, d_, JumpLine, i_, n_, t_, e_, n_, s_, l_, y_, Exclam, 0xFF};
/*0x235*/const u8 auroraveil_text[] = {BuffCharac, 54, Space, m_, a_, d_, e_, Space, BuffCharac, 57, JumpLine, s_, t_, r_, o_, n_, g_, e_, r_, Space, a_, g_, a_, i_, s_, t_, Space, p_, h_, y_, s_, i_, c_, a_, l_, Space, a_, n_, d_, Space, s_, p_, e_, c_, i_, a_, l_, 0xFA, m_, o_, v_, e_, s_, Exclam, 0xFF};
/*0x236*/const u8 attacker_item_activates_text[] = {BuffCharac, 15, Apos, s_, Space, BuffCharac, 22, JumpLine, a_, c_, t_, i_, v_, a_, t_, e_, d_, Exclam, 0xFF};
/*0x237*/const u8 atk_ability_text[] = {BuffCharac, 15, Apos, s_, Space, BuffCharac, 24, Exclam, 0xFF};
/*0x238*/const u8 cantuse_text[] = {BuffCharac, 15, Space, c_, a_, n_, n_, o_, t_, JumpLine, u_, s_, e_, Space, BuffCharac, 54, Exclam, 0xFF};
/*0x239*/const u8 atkhpfull_text[] = {BuffCharac, 15, Apos, s_, JumpLine, H_, P_, Space, i_, s_, Space, f_, u_, l_, l_, Exclam, 0xFF};
/*0x23A*/const u8 statfail_text[] = {BuffCharac, 19, Apos, s_, Space, BuffCharac, Space, JumpLine, w_, o_, n_, Apos, t_, Space, g_, o_, Space, a_, n_, y_, Space, BuffCharac, 60, Exclam, 0xFF};
/*0x23B*/const u8 attackerhurt_text[] = {BuffCharac, 15, Space, w_, a_, s_, Space, h_, u_, r_, t_, Exclam, 0xFF};
/*0x23C*/const u8 attackerfellinlove_text[] = {BuffCharac, 15, Space, f_, e_, l_, l_, JumpLine, i_, n_, Space, l_, o_, v_, e_, Exclam, 0xFF};
/*0x23D*/const u8 itemstatraise_text[] = {T_, h_, e_, Space, BuffCharac, 22, Space, BuffCharac, 58, BuffCharac, 61, JumpLine, BuffCharac, 19, Apos, s_, Space, BuffCharac, Exclam, 0xFF};
/*0x23E*/const u8 targetnoconfusion_text[] = {BuffCharac, 16, Space, d_, o_, e_, s_, n_, Apos, t_, JumpLine, b_, e_, c_, o_, m_, e_, Space, c_, o_, n_, f_, u_, s_, e_, d_, Exclam, 0xFF};
/*0x23F*/const u8 burnuptext[] = {BuffCharac, 15, Space, b_, u_, r_, n_, e_, d_, JumpLine, i_, t_, s_, e_, l_, f_, Space, o_, u_, t_, Exclam, 0xFF};
/*0x240*/const u8 attackeracquired[] = {BuffCharac, 15, Space, a_, c_, q_, u_, i_, r_, e_, d_, Space, BuffCharac, 25, Exclam, 0xFF};
/*0x241*/const u8 scractiveHPrestored[] = {BuffCharac, 19, Apos, s_, Space, H_, P_, JumpLine, w_, a_, s_, Space, r_, e_, s_, t_, o_, r_, e_, d_, Exclam, 0xFF};
/*0x242*/const u8 shieldsdown_drop_text[] = {D_, r_, o_, p_, p_, e_, d_, Space, S_, h_, i_, e_, l_, d_, s_, Space, D_, o_, w_, n_, Exclam, Termin};
/*0x243*/const u8 shieldsdown_activate_text[] = {S_, h_, i_, e_, l_, d_, s_, Space, D_, o_, w_, n_, Space, a_, c_, t_, i_, v_, a_, t_, e_, d_, Exclam, Termin};
/*0x244*/const u8 schooling_text[] = {BuffCharac, 19, Space, f_, o_, r_, m_, e_, d_, Space, a_, Space, s_, c_, h_, o_, o_, l_, Exclam, Termin};
/*0x245*/const u8 schoolstop_text[] = {BuffCharac, 19, Space, Space, s_, t_, o_, p_, p_, e_, d_, Space, s_, c_, h_, o_, o_, l_, i_, n_, g_, Exclam, Termin};
/*0x246*/const u8 battlebond_text[] = {BuffCharac, 19, Space, h_, a_, s_, Space, b_, e_, c_, o_, m_, e_, Space, f_, u_, l_, l_, y_, Space, c_, h_, a_, r_, g_, e_, d_, JumpLine, d_, u_, e_, Space, t_, o_, Space, i_, t_, s_, Space, b_, o_, n_, d_, Space, w_, i_, t_, h_, Space, i_, t_, s_, Space, T_, r_, a_, i_, n_, e_, r_, Exclam, Termin};
/*0x247*/const u8 ashgrenja_text[] = {BuffCharac, 19, Space, b_, e_, c_, a_, m_, e_, Space, A_, s_, h_, Space, G_, r_, e_, n_, i_, n_, j_, a_, Exclam, Termin};
/*0x248*/const u8 zygarde_user_sense_text[] = {Y_, o_, u_, Space, s_, e_, n_, s_, e_, Space, t_, h_, e_, Space, p_, r_, e_, s_, e_, n_, c_, e_, Space, o_, f_, Space, m_, a_, n_, y_, Exclam, Termin};
/*0x249*/const u8 zygarde_ai_sense_text[] = {T_, h_, e_, Space, o_, p_, p_, o_, n_, e_, n_, t_, Space, s_, e_, n_, s_, e_, s_, Space, t_, h_, e_, Space, p_, r_, e_, s_, e_, n_, c_, e_, Space, o_, f_, Space, m_, a_, n_, y_, Exclam, Termin};
/*0x24A*/const u8 zygarde_transform_text[] = {BuffCharac, 19, Space, t_, r_, a_, n_, s_, f_, o_, r_, m_, e_, d_, Space, i_, n_, t_, o_, JumpLine, i_, t_, s_, Space, C_, o_, m_, p_, l_, e_, t_, e_, Space, F_, o_, r_, m_, Exclam, Termin};
/*0x24B*/const u8 mimikyu_busted_text[] = {BuffCharac, 0x13, Apos, s_, Space, d_, i_, s_, g_, u_, i_, s_, e_, Space, w_, a_, s_, Space, b_, u_, s_, t_, e_, d_, Exclam, Termin};
/*0x24C*/const u8 disguise_server_as_decoy_text[] = {I_, t_, s_, Space, d_, i_, s_, g_, u_, i_, s_, e_, Space, s_, e_, r_, v_, e_, d_, Space, i_, t_, Space, a_, s_, Space, a_, Space, d_, e_, c_, o_, y_, Exclam, Termin};
/*0x24D*/const u8 misty_terrain_status_prevent_text[] = {T_, h_, e_, Space, M_, i_, s_, t_, y_, Space, T_, e_, r_, r_, a_, i_, n_, Space, p_, r_, o_, t_, e_, c_, t_, e_, d_, JumpLine, BuffCharac, 16, Exclam, Termin};
/*0x24E*/const u8 electric_terrain_status_prevent_text[] = {O_, Space, C_, a_, m_, p_, o_, Space, E_, l_, 0x1B, t_, r_, i_, c_, o_, Space, p_, r_, o_, t_, e_, g_, e_, u_, JumpLine, BuffCharac, 16, Exclam, Termin};
/*0x24F*/const u8 psychic_terrain_priority_prevent_text[] = {O_, Space, C_, a_, m_, p_, o_, Space, P_, s_, 0x6F, q_, u_, i_, c_, o_, Space, p_, r_, o_, t_, e_, g_, e_, u_, JumpLine, BuffCharac, 16, Space, d_, e_, Space, BuffCharac, 54, Exclam, 0xFF};
/*0x250*/const u8 screencleaner_text[] = {0xBB, 0xE0, 0xDB, 0xE9, 0xE2, 0xE7, 0x00, 0xD9, 0xDA, 0xD9, 0xDD, 0xE8, 0xE3, 0xE7, 0x00, 0xD8, 0xD9, 0x00, 0xD6, 0xD5, 0xE6, 0xE6, 0xD9, 0xDD, 0xE6, 0xD5, 0xFE, 0xDA, 0xE3, 0xE6, 0xD5, 0xE1, 0x00, 0xD8, 0xD9, 0xE7, 0xD5, 0xE8, 0xDD, 0xEA, 0xD5, 0xD8, 0xE3, 0xE7, 0xAD, 0xFF};
/*0x251*/const u8 screencleaner_block_moves_text[] = {0xCD, 0xD7, 0xE6, 0xD9, 0xD9, 0xE2, 0x00, 0xBD, 0xE0, 0xD9, 0xD5, 0xE2, 0xD9, 0xE6, 0x00, 0xD6, 0xE0, 0xE3, 0xE5, 0xE9, 0xD9, 0xE3, 0xE9, 0x00, 0xFE, 0xE3, 0x00, 0xE9, 0xE7, 0xE3, 0x00, 0xD8, 0xD9, 0x00, BuffCharac, 0x14, 0xAB, 0xFB, 0xFF};
/*0x252*/const u8 wanderspirit_text[] = {0xCE, 0xDC, 0xD9, 0x00, 0xFC, 0x01, 0x02, 0xD1, 0xD5, 0xE2, 0xD8, 0xD9, 0xE6, 0xDD, 0xE2, 0xDB, 0x00, 0xCD, 0xE4, 0xDD, 0xE6, 0xDD, 0xE8, 0x00, 0xFC, 0x01, 0x01, 0xD7, 0xD5, 0xE9, 0xE7, 0xD9, 0xD8, 0x00, 0xD6, 0xE3, 0xE8, 0xDC, 0xFE, 0xE7, 0xDD, 0xD8, 0xD9, 0xE7, 0x00, 0xE8, 0xE3, 0x00, 0xE7, 0xEB, 0xD5, 0xE4, 0xE4, 0x00, 0xD5, 0xD6, 0xDD, 0xE0, 0xDD, 0xE8, 0xDD, 0xD9, 0xE7, 0xAB, 0xFF};	
/*0x253*/const u8 abilitychange_text2[] = {0xBB ,0xD6 ,0xDD ,0xE0 ,0xDD ,0xE8 ,0xED ,0x00 ,0xD8 ,0xD9 ,0x00 ,BuffCharac ,0x0F ,0xFE ,0xE8 ,0xE6 ,0xE3 ,0xD7 ,0xD5 ,0xD8 ,0xD5 ,0x00 ,0xE4 ,0xE3 ,0xE6 ,0x00 ,BuffCharac, 0x18, 0xAB, 0xFF};
/*0x254*/const u8 neutralizinggas_text[] = {0xC8, 0xD9, 0xE9, 0xE8, 0xE6, 0xD5, 0xE0, 0xDD, 0xEE, 0xDD, 0xE2, 0xDB, 0x00, 0xC1, 0xD5, 0xE7, 0x00, 0xDA, 0xDD, 0xE0, 0xE0, 0xD9, 0xD8, 0x00, 0xE8, 0xDC, 0xD9, 0x00, 0xD5, 0xE6, 0xD9, 0xD5, 0xAB, 0xFF};
/*0x255*/const u8 neutralizing_woreoff[] = {0xCE, 0xDC, 0xD9, 0x00, 0xD9, 0xDA, 0xDA, 0xD9, 0xD7, 0xE8, 0xE7, 0x00, 0xE3, 0xDA, 0x00, 0xC8, 0xD9, 0xE9, 0xE8, 0xE6, 0xD5, 0xE0, 0xDD, 0xEE, 0xDD, 0xE2, 0xDB, 0x00, 0xC1, 0xD5, 0xE7, 0x00, 0xEB, 0xE3, 0xE6, 0xD9, 0x00, 0xE3, 0xDA, 0xDA, 0xAB, 0xFF};
/*0x256*/const u8 gorillapower_block_moves_text[] = {0xC1, 0xE3, 0xE6, 0xDD, 0xE0, 0xE0, 0xD5, 0x00, 0xCE, 0xD5, 0xD7, 0xE8, 0xDD, 0xD7, 0xE7, 0x00, 0xE4, 0xD9, 0xE6, 0xE1, 0xDD, 0xE8, 0xD9, 0x00, 0xD5, 0xE4, 0xD9, 0xE2, 0xD5, 0xE7, 0x00, 0xFE, 0xE3, 0x00, 0xE9, 0xE7, 0xE3, 0x00, 0xD8, 0xD9, 0x00, BuffCharac, 0x14, 0xAB, 0xFB, 0xFF};
/*0x257*/const u8 abilitychange_text3[] = {0xCE, 0xDC, 0xD9, 0x00, 0xD5, 0xD6, 0xDD, 0xE0, 0xDD, 0xE8, 0xED, 0x00, 0xE3, 0xDA, 0x00, BuffCharac, 0x0F, 0xFE, 0xDC, 0xD5, 0xE7, 0x00, 0xD6, 0xD9, 0xD7, 0xE3, 0xE1, 0xD9, 0x00, BuffCharac, 0x18, 0xAB, 0xFF};
/*0x258*/const u8 pastelveil_text[] = {0xCE, 0xDC, 0xD9, 0x00, 0xCA, 0xD5, 0xE7, 0xE8, 0xD9, 0xE0, 0x00, 0xD0, 0xD9, 0xDD, 0xE0, 0x00, 0xE3, 0xE2, 0x00, 0xE8, 0xDC, 0xD9, 0x00, 0xDA, 0xDD, 0xD9, 0xE0, 0xD8, 0xFE, 0xDB, 0xE6, 0xD5, 0xE2, 0xE8, 0xE7, 0x00, 0xE4, 0xE6, 0xE3, 0xE8, 0xD9, 0xD7, 0xE8, 0xDD, 0xE3, 0xE2, 0xAD, 0xFF};	
/*0x259*/const u8 pastelveilheal_text[] = {0xCE, 0xDC, 0xD9, 0x00, 0xCA, 0xD5, 0xE7, 0xE8, 0xD9, 0xE0, 0x00, 0xD0, 0xD9, 0xDD, 0xE0, 0x00, 0xD7, 0xE9, 0xE6, 0xD9, 0xD8, 0x00, 0xE4, 0xE3, 0xDD, 0xE7, 0xE3, 0xE2, 0xAB, 0xFF};
/*0x25A*/const u8 levelcap_text[] = {0xFC, 0x01, 0x02, BuffCharac, 0x00, 0xFC, 0x01, 0x01, 0x00, 0xD5, 0xE0, 0xD7, 0xD5, 0xE2, 0x19, 0xE3, 0xE9, 0x00, 0xE3, 0x00, 0xC6, 0xD9, 0xEA, 0xD9, 0xE0, 0x00, 0xBD, 0xD5, 0xE4, 0xAB, 0xFB, 0xFF};
/*0x25B*/const u8 recoil_text[] = {BuffCharac, 0x0F, 0x00, 0xD5, 0xEA, 0xE3, 0xDD, 0xD8, 0xD9, 0xD8, 0x00, 0xE6, 0xD9, 0xD7, 0xE3, 0xDD, 0xE0, 0x00, 0xD8, 0xD5, 0xE1, 0xD5, 0xDB, 0xD9, 0xAB, 0xFF};
/*0x25C*/const u8 teatime_text[] = {BuffCharac, 0x10, 0x00, 0xD5, 0xE8, 0xD9, 0x00, 0xDD, 0xE8, 0xE7, 0x00, 0xE3, 0xEB, 0xE2, 0x00, BuffCharac, 0x16, 0xAB, 0xFF};
/*0x25D*/const u8 cant_pp_reduce[] = {BuffCharac, 0x10, 0xB4, 0xE7, 0x00, 0xCA, 0xCA, 0x00, 0xD7, 0xD5, 0xE2, 0xE2, 0xE3, 0xE8, 0x00, 0xD6, 0xD9, 0x00, 0xE6, 0xD9, 0xD8, 0xE9, 0xD7, 0xD9, 0xD8, 0xFE, 0xE3, 0xE6, 0x00, 0xDD, 0xE8, 0x00, 0xDC, 0xD5, 0xE7, 0x00, 0xE2, 0xE3, 0xE8, 0x00, 0xE1, 0xE3, 0xEA, 0xD9, 0xD8, 0x00, 0xED, 0xD9, 0xE8, 0xAD, 0xFB, 0xFF};
/*0x25E*/const u8 throatchopended_text[] = {BuffCharac, 0x12, 0x00, 0xD7, 0xD5, 0xE2, 0x00, 0xE7, 0xE4, 0xD9, 0xD5, 0xDF, 0x00, 0xD5, 0xDB, 0xD5, 0xDD, 0xE2, 0xAB, 0xFF};
/*0x25F*/const u8 let_it_move_first_text2[] = {0xFC, 0x01, 2, 0xCB, 0xE9, 0xDD, 0xD7, 0xDF, 0x00, 0xBE, 0xE6, 0xD5, 0xEB, 0xFC, 1, 1, Space, 0xD8, 0xE3, 0xFC, 0x01, 2, Space, BuffCharac, 15, Space, 0xFC, 1, 1, 0xE3, 0xFE, 0xE4, 0xD9, 0xE6, 0xE1, 0xDD, 0xE8, 0xD9, 0x00, 0xD5, 0xDB, 0xDD, 0xE6, 0x00, 0xE6, 0xD5, 0xE4, 0xDD, 0xD8, 0xD5, 0xE1, 0xD9, 0xE2, 0xE8, 0xD9, Exclam, Termin};
/*0x260*/const u8 snap_trap_text[] = {BuffCharac, 0x10, 0x00, 0xDD, 0xE7, 0x00, 0xE8, 0xE6, 0xD5, 0xE4, 0xE4, 0xD9, 0xD8, 0x00, 0xDD, 0xE2, 0xFE, BuffCharac, 0x0F, 0xB4, 0xE7, 0x00, 0xCD, 0xE2, 0xD5, 0xE4, 0x00, 0xCE, 0xE6, 0xD5, 0xE4, 0xAB, 0xFF};
/*0x261*/const u8 thundercage_text[] = {BuffCharac, 0x10, 0x00, 0xDD, 0xE7, 0x00, 0xE8, 0xE6, 0xD5, 0xE4, 0xE4, 0xD9, 0xD8, 0x00, 0xDD, 0xE2, 0x00, 0xD5, 0xE2, 0xFE, 0xD9, 0xE0, 0xD9, 0xD7, 0xE8, 0xE6, 0xDD, 0xD7, 0x00, 0xE4, 0xE6, 0xDD, 0xE7, 0xE3, 0xE2, 0xAB, 0xFF};
/*0x262*/const u8 bad_joke_text[] = {BuffCharac, 0x06, 0x00, 0xDD, 0xE7, 0x00, 0xE4, 0xE6, 0xD9, 0xE4, 0xD5, 0xE6, 0xDD, 0xE2, 0xDB, 0x00, 0xE8, 0xE3, 0x00, 0xE8, 0xD9, 0xE0, 0xE0, 0x00, 0xD5, 0xFE, 0xD7, 0xDC, 0xDD, 0xE0, 0xE0, 0xDD, 0xE2, 0xDB, 0xE0, 0xED, 0x00, 0xD6, 0xD5, 0xD8, 0x00, 0xDE, 0xE3, 0xDF, 0xD9, 0xAB, 0xFF};
/*0x263*/const u8 custap_text[]= {0xBE, 0xE9, 0xD9, 0x00, 0xE8, 0xE3, 0x00, BuffCharac, 0x16, 0xB4, 0xE7, 0x00, 0xD9, 0xDA, 0xDA, 0xD9, 0xD7, 0xE8, 0xB8, 0xFE, BuffCharac, 0x13, 0x00, 0xEB, 0xDD, 0xE0, 0xE0, 0x00, 0xE1, 0xE3, 0xEA, 0xD9, 0x00, 0xDA, 0xDD, 0xE6, 0xE7, 0xE8, 0x00, 0xE2, 0xD9, 0xEC, 0xE8, 0x00, 0xE8, 0xE9, 0xE6, 0xE2, 0xAB, 0xFF};
/*0x264*/const u8 throatchop_text[]= {BuffCharac, 0x10, 0x00, 0xDD, 0xE7, 0x00, 0xE9, 0xE2, 0xD5, 0xD6, 0xE0, 0xD9, 0x00, 0xE8, 0xE3, 0x00, 0xE1, 0xD5, 0xDF, 0xD9, 0x00, 0xD5, 0x00, 0xE7, 0xE3, 0xE9, 0xE2, 0xD8, 0xAB, 0xFF};
/*0x265*/const u8 throatchop_block_text[]= {0xCE, 0xDC, 0xE6, 0xE3, 0xD5, 0xE8, 0x00, 0xBD, 0xDC, 0xE3, 0xE4, 0x00, 0xD6, 0xE0, 0xE3, 0xE5, 0xE9, 0xD9, 0xE3, 0xE9, 0x00, 0xE3, 0xFE, 0xE9, 0xE7, 0xE3, 0x00, 0xD8, 0xD9, 0x00, BuffCharac, 0x14, 0xAB, 0xFB, 0xFF};
/*0x266*/const u8 adrenaline_orb_text[]= {0xFC, 0x01, 0x02, 0xBB, 0xD8, 0xE6, 0xD9, 0xE2, 0xD5, 0xE0, 0xDD, 0xE2, 0xD9, 0x00, 0xC9, 0xE6, 0xD6, 0xFC, 0x01, 0x01, 0x00, 0xD9, 0xE0, 0xD9, 0xEA, 0xD5, 0x00, 0xD5, 0xFE, 0xCD, 0xE4, 0xD9, 0xD9, 0xD8, 0x00, 0xD8, 0xE3, 0x5C, 0xD5, 0x5D, 0x00, 0xFC, 0x01, 0x02, BuffCharac, 0x02, 0xFC, 0x01, 0x01, 0xAB, 0xFF};
/*0x267*/const u8 eject_pack_text[]= {0xFC, 0x01, 0x01, BuffCharac, 0x10, 0x00, 0x1B, 0x00, 0xE6, 0xD9, 0xE8, 0xDD, 0xE6, 0xD5, 0xD8, 0xE3, 0x00, 0xD8, 0xD9, 0x00, 0xD7, 0xD5, 0xE1, 0xE4, 0xE3, 0xFE, 0xE4, 0xD9, 0xE0, 0xE3, 0x00, 0xFC, 0x01, 0x02, 0xBF, 0xDE, 0xD9, 0xD7, 0xE8, 0x00, 0xCA, 0xD5, 0xD7, 0xDF, 0xFC, 0x01, 0x01, 0xAB, 0xFF};
/*0x268*/const u8 honey_string_text[] = {0xFC, 0x01, 0x02, 0xC2, 0xE3, 0xE2, 0xD9, 0xED, 0xFC, 0x01, 0x01, 0x00, 0xD9, 0xE2, 0xD7, 0xE3, 0xE2, 0xE8, 0xE6, 0xD5, 0xD8, 0xE3, 0xAD, 0xFE, 0xBF, 0xE2, 0xEA, 0xDD, 0xD5, 0xD8, 0xE3, 0x00, 0xD8, 0xDD, 0xE6, 0xD9, 0xE8, 0xE3, 0x00, 0xE4, 0xD5, 0xE6, 0xD5, 0x00, 0xD5, 0x00, 0xD6, 0xE3, 0xE0, 0xE7, 0xD5, 0xAD, 0xFF};
/*0x269*/const u8 terraincleared_text[] = {0xCE, 0xDC, 0xD9, 0x00, 0xD5, 0xD7, 0xE8, 0xDD, 0xEA, 0xD9, 0x00, 0xCE, 0xD9, 0xE6, 0xE6, 0xD5, 0xDD, 0xE2, 0x00, 0xDC, 0xD5, 0xE7, 0x00, 0xD6, 0xD9, 0xD9, 0xE2, 0x00, 0xE6, 0xD9, 0xE1, 0xE3, 0xEA, 0xD9, 0xD8, 0xAB, 0xFF};
/*0x26a*/const u8 psychicterrainends_text[] = {0xCE, 0xDC, 0xD9, 0x00, 0xD6, 0xD5, 0xE8, 0xE8, 0xE0, 0xD9, 0xDA, 0xDD, 0xD9, 0xE0, 0xD8, 0x00, 0xDD, 0xE7, 0x00, 0xE2, 0xE3, 0x00, 0xE0, 0xE3, 0xE2, 0xDB, 0xD9, 0xE6, 0x00, 0xEB, 0xD9, 0xDD, 0xE6, 0xD8, 0xAB, 0xFF};
/*0x26b*/const u8 movefailed_text[] = {0xBC, 0xE9, 0xE8, 0x00, 0xDD, 0xE8, 0x00, 0xDA, 0xD5, 0xDD, 0xE0, 0xD9, 0xD8, 0xAB, 0xFF};
/*0x26c*/const u8 reflect_text[] = {0xC9, 0xE9, 0xE6, 0x00, 0xBE, 0xD9, 0xDA, 0xD9, 0xE2, 0xE7, 0xD9, 0x00, 0xDD, 0xE2, 0xD7, 0xE6, 0xD9, 0xD5, 0xE7, 0xD9, 0xD8, 0xFE, 0xD8, 0xE9, 0xD9, 0x00, 0xE8, 0xE3, 0x00, BuffCharac, 0x14, 0xAB, 0xFF};
/*0x26d*/const u8 reflectdouble_text[] = {0xC9, 0xE9, 0xE6, 0x00, 0xBE, 0xD9, 0xDA, 0xD9, 0xE2, 0xE7, 0xD9, 0x00, 0xDC, 0xD5, 0xE7, 0x00, 0xD6, 0xD9, 0xD9, 0xE2, 0x00, 0xE7, 0xE0, 0xDD, 0xDB, 0xDC, 0xE8, 0xE0, 0xED, 0xFE, 0xDD, 0xE1, 0xE4, 0xE6, 0xE3, 0xEA, 0xD9, 0xD8, 0x00, 0xD6, 0xED, 0x00, BuffCharac, 0x14, 0xAB, 0xFF};
/*0x26e*/const u8 lightscreen_text[] = {0xC9, 0xE9, 0xE6, 0x00, 0xCD, 0xE4, 0xD9, 0xD7, 0xDD, 0xD5, 0xE0, 0x00, 0xBE, 0xD9, 0xDA, 0xD9, 0xE2, 0xE7, 0xD9, 0x00, 0xDD, 0xE2, 0xD7, 0xE6, 0xD9, 0xD5, 0xE7, 0xD9, 0xD8, 0xFE, 0xD8, 0xE9, 0xD9, 0x00, 0xE8, 0xE3, 0x00, BuffCharac, 0x14, 0xAB, 0xFF};
/*0x26f*/const u8 lightscreendouble_text[] = {0xC9, 0xE9, 0xE6, 0x00, 0xCD, 0xE4, 0xD9, 0xD7, 0xDD, 0xD5, 0xE0, 0x00, 0xBE, 0xD9, 0xDA, 0xD9, 0xE2, 0xE7, 0xD9, 0x00, 0xDC, 0xD5, 0xE7, 0x00, 0xD6, 0xD9, 0xD9, 0xE2, 0xFE, 0xE7, 0xE0, 0xDD, 0xDB, 0xDC, 0xE8, 0xE0, 0xED, 0x00, 0xDD, 0xE1, 0xE4, 0xE6, 0xE3, 0xEA, 0xD9, 0xD8, 0x00, 0xD6, 0xED, 0x00, BuffCharac, 0x14, 0xAB, 0xFF};
/*0x270*/const u8 magearna_text[] = {0xCA, 0xE3, 0xE7, 0xE7, 0xE3, 0x00, 0xE4, 0xE6, 0xD9, 0xE7, 0xE7, 0xD9, 0xE2, 0xE8, 0xDD, 0xE6, 0x00, 0xE3, 0x00, 0xE4, 0xD9, 0xE6, 0xDD, 0xDB, 0xE3, 0x00, 0xD9, 0x00, 0xE3, 0x00, 0xD7, 0xD5, 0xE3, 0xE7, 0xAD, 0xFE, 0xBB, 0xE0, 0xE8, 0xD9, 0xE6, 0xD5, 0xE2, 0xD8, 0xE3, 0x00, 0xE4, 0xD5, 0xE6, 0xD5, 0x00, 0xE3, 0x00, 0xC7, 0xE3, 0xD8, 0xE3, 0x00, 0xD8, 0xD9, 0x00, 0xCD, 0xE3, 0xD6, 0xE6, 0xD9, 0xEA, 0xDD, 0xEA, 0x1C, 0xE2, 0xD7, 0xDD, 0xD5, 0xAD, 0xFF};
/*0x271*/const u8 micleacc_text[] = {BuffCharac, 0x13, 0x00, 0xEB, 0xDD, 0xE0, 0xE0, 0x00, 0xDC, 0xD5, 0xEA, 0xD9, 0x00, 0xDD, 0xE2, 0xD7, 0xE6, 0xD9, 0xD5, 0xE7, 0xD9, 0xD8, 0xFE, 0xD5, 0xD7, 0xD7, 0xE9, 0xE6, 0xD5, 0xD7, 0xED, 0x00, 0xE2, 0xD9, 0xEC, 0xE8, 0x00, 0xE8, 0xE9, 0xE6, 0xE2, 0xAB, 0xFF};
/*0x272*/const u8 started_snow_text[] = {0xC3, 0xE7, 0x00, 0xE7, 0xE8, 0xD5, 0xE6, 0xE8, 0xD9, 0xD8, 0x00, 0xE8, 0xE3, 0x00, 0xE7, 0xE2, 0xE3, 0xEB, 0xAB, 0xFF};
/*0x273*/const u8 ally_stat_reset[] = {0xCE, 0xDC, 0xD9, 0x00, 0xD5, 0xE0, 0xE0, 0xED, 0xB4, 0xE7, 0x00, 0xE7, 0xE8, 0xD5, 0xE8, 0xE7, 0x00, 0xEB, 0xD9, 0xE6, 0xD9, 0x00, 0xE6, 0xD9, 0xE7, 0xD9, 0xE8, 0xAB, 0xFF};

const u8* const new_strings_table[] = {firespintrap_text, magmastormtrap_text, extreme_sun_activation_text, heavyrain_activation_text, mysticalaircurrent_activation_text, forewarn_text, slowstart_text, anticipation_text,
infestationtrap_text, airlock_text, harvest_text, healer_text, empty_text5, moldbreaker_text, turboblaze_text, terravolt_text, empty_text9,
empty_text10, empty_text12, absorbabilityimmune_text, userteam_text, foeteam_text,
aftermath_text, pickpocket_text, mummy_text, target_ability, cursedbody_text, statchange_text, pressure_text, unnerve_text, aurabreak_text, fairyaura_text, darkaura_text, frisk_text, //0x19D
hurtbyitem_text, flameorb_text, toxicorb_text, airballoon_text, bad_dreams_text, stickybarb_text, rockyhelmet_text, popped_text, destinyknot_text, healblockend_text, redcart_text,
angerpoint_text, stealhrock_text, stickyweb_text, ejectbutton_text, absorbed_spikes_text, lost_some_hp_text, tauntended_text, tormentended_text,
healblockprevents_text, gravityprevents_text, embargoprevents_text, aromaveilprevents_text, empty_text7, symbiosispassing_text,
restored_hp_text, replacement_healed_text, telekinesis_end_text, embargoend_text, magnetriseend_text, empty_text11,
nofiremoves_text, nowatermoves_text, trickroom_ends, magicroom_ends, wonderoom_ends, gravity_ends_text, grassyterainends_text,
mistyterrainends_text, electrerrainends_text, grassyterrain_heal, fogcontinues_text, fogends_text, obtaineditem,
tailwind_begins_text, luckychant_begins_text, magnetrise_begins_text, magicroom_start_text, trickroom_start_text, wonderroom_start_text,
gravitystarts_text, telekinesis_start_text, abilitychange_text, statswap_text, heartswap_text, bugbite_text, incinerate_text,
gravitybringsdown_text, fellforfeint, protection_broken, teamprotection, becameatype, targetsabilitybecameattacker,
gastro_text, embargostart_text, afteryout_text, powder_text, powderdamage_text, statchangesremoved_text, electify_text,
stealthrock2_text, toxicspikes2_text, stickyweb2_text, nimble_text, iondelugeset_text, reflecttype_text, healblock_start_text, smackdown_text,
rapidspinontoxicspikes_text, rapidspinonstealthrock_text, rapidspinonstickyweb_text, powertrick_text, soak_text, defogspikes_text,
power_text, guard_text, psychosplit_text, stockpileend_text, geomancy_text, powerherb_text, iceburn_text, freezeshock_text,
shadowforce_text, mistyterrain_text, grassyterrain_text, electricterrain_text, aquaring_text, aquaringheal_text, assaultvest_text,
gravityprevents2_text, healblockprevents2_text , let_it_move_first_text, mega_evolved_text, mega_trigger_text, fervent_trigger_text,
quash_text, allyswitch_text, topsyturvy_text, bestow_text, statushealpoison_text, statushealburn_text, statushealpar_text,
statushealslp_text, statushealfrz_text, primal_reversion_text, congrats_player_text, happyhour_text, skydrop1_text, skydrop2_text,
skydroptooheavy_text, fairylock_text, illusion_off_text, protean_text, gem_text, telepathy_text, flame_burst_text, zen_mode_text,
zen_end_text, form_change_text, partner_wait_text, combined_move_text, userteam_uc_text, foeteam_uc_text, fire_sea_text, fire_sea_hurt_text,
swamp_text, rainbow_text, swamp_end_text, fire_sea_end_text, rainbow_end_text, berry_redux_text, pokeballblock_text, player_wonlost_text, trainerwon_text,
skydrop_cantchooseaction_text, trainer_sliding_text, sweetveilactivation_text, sportend_text, scr_active_ability_text, psychicterrain_text,
laserfocus_text, auroraveil_text, attacker_item_activates_text, atk_ability_text, cantuse_text, atkhpfull_text, statfail_text,
attackerhurt_text, attackerfellinlove_text, itemstatraise_text, targetnoconfusion_text, burnuptext, attackeracquired,
scractiveHPrestored, shieldsdown_drop_text, shieldsdown_activate_text, schooling_text, schoolstop_text, battlebond_text, ashgrenja_text,
zygarde_user_sense_text, zygarde_ai_sense_text, zygarde_transform_text, mimikyu_busted_text, disguise_server_as_decoy_text, misty_terrain_status_prevent_text,
electric_terrain_status_prevent_text, psychic_terrain_priority_prevent_text, screencleaner_text, screencleaner_block_moves_text, wanderspirit_text, abilitychange_text2,
neutralizinggas_text, neutralizing_woreoff, gorillapower_block_moves_text, abilitychange_text3, pastelveil_text, pastelveilheal_text, levelcap_text, recoil_text,
teatime_text, cant_pp_reduce, throatchopended_text, let_it_move_first_text2, snap_trap_text, thundercage_text, bad_joke_text, custap_text, throatchop_text,
throatchop_block_text, adrenaline_orb_text, eject_pack_text, honey_string_text, terraincleared_text, psychicterrainends_text,
movefailed_text, reflect_text, reflectdouble_text, lightscreen_text, lightscreendouble_text, magearna_text, micleacc_text, started_snow_text, ally_stat_reset};

u8* get_poke_nick2(struct pokemon* poke, u8 bank, u8* dst)
{
    struct pokemon* illusion_to_happen_later = get_poke_to_illusion_into(poke, bank);
    if (new_battlestruct->bank_affecting[bank].illusion_on)
        strcpy_xFF_terminated_0(dst, new_battlestruct->bank_affecting[bank].illusion_nick);
    else if (illusion_to_happen_later)
        get_attributes(illusion_to_happen_later, ATTR_NAME, dst);
    else
        get_attributes(poke, ATTR_NAME, dst);
    return shorten_str_to_10(dst);
}

u8* get_poke_nick(u8 bank, u8* dst)
{
    return get_poke_nick2(get_bank_poke_ptr(bank), bank, dst);
}

u8* get_chosen_poke_nick(u8 bank, u8 ID, u8* dst)
{
    return get_poke_nick2(&get_party_ptr(bank)[ID], bank, dst);
}

u8* get_poke_nick_link(u8 linkID, u8 to_xor, u8* dst)
{
    u8 bank = battle_link_pbs[linkID].bank_id ^ to_xor;
    struct pokemon* poke;
    if (to_xor & 1)
        poke = party_opponent;
    else
        poke = party_player;
    return get_poke_nick2(&poke[battle_team_id_by_side[bank]], bank, dst);
}

u8* get_poke_nick_prefix(u8 bank, u8* dst)
{
    u8 i = 0;
    if (get_bank_side(bank))
    {
        u8* prefix;
        if (battle_flags.trainer)
            prefix = (u8*) &text_Foe_;
        else
            prefix = (u8*) &text_Wild_;
        while (prefix[i] != 0xFF)
        {
            dst[i] = prefix[i];
            i++;
        }
    }
    return &dst[i];
}

u8* get_poke_nick_with_prefix(u8 bank, u8* dst)
{
    return get_poke_nick(bank, get_poke_nick_prefix(bank, dst));
}

u8* get_chosen_poke_nick_with_prefix(u8 bank, u8 ID, u8*dst)
{
    return get_chosen_poke_nick(bank, ID, get_poke_nick_prefix(bank, dst));
}

const u8* get_ability_name_ptr(u8 ability)
{
    return ability_names_table[ability];
}

const u8* get_trainerclass_ptr(u8 classID)
{
    return trainerclass_names[classID];
}

u8* get_link_trainername(u8 linkID, u8 to_xor)
{
    u8 bank = battle_link_pbs[linkID].bank_id ^ to_xor;
    return battle_link_pbs[get_linkpbs_id(bank)].trainer_name;
}

const u8* get_partner_name(void)
{
    const u8* string_ptr = NULL;
    if (battle_flags.player_ingame_partner)
    {
        if (partner_trainer & PARTNER_CUSTOM)
            string_ptr = (*trainer_table)[BIC(partner_trainer, PARTNER_ANIMATES | PARTNER_CUSTOM)].name;
        else
        {
            get_frontier_trainer_name(script_text_buffer1, partner_trainer);
            string_ptr = script_text_buffer1;
        }
    }
    else
    {
        u8 linkID = link_get_multiplayer_id();
        linkID = battle_link_pbs[linkID].bank_id;
        linkID = get_linkpbs_id(linkID ^ 2);
        string_ptr = battle_link_pbs[linkID].trainer_name;
    }
    return string_ptr;
}

const u8* get_battlestring(u16 strID)
{
    if (strID >= 0x17C)
        return new_strings_table[strID - 0x17C];
    return battle_strings_table[strID - 0xC];
}

static void b_fdecode_case(const u8* const src, u8* dst)
{
    *dst = 0xFF;
    u32 srcID = 1; //first char is always BuffCharac
	while (src[srcID] != Termin)
    {
        const u8* String = NULL;
        u8 curr_char = src[srcID];
        srcID++;
        switch (curr_char)
        {
        case 0: //get battlescript
            String = get_battlestring(read_hword(&src[srcID]));
            srcID += 2;
            break;
        case 1: //get a number
            {
                u32 number = 0;
                u8 bytes = src[srcID];
                srcID++;
                u8 digits = src[srcID];
                srcID++;
                switch (bytes)
                {
                case 1: //byte
					number = src[srcID];
                    break;
                case 2: //halfword
                    number = read_hword(&src[srcID]);
                    break;
                case 4: //word
                    number = read_word(&src[srcID]);
                    break;
                }
                srcID += bytes;
                dst = int_to_str(dst, number, 0, digits);
            }
            break;
        case 2: //move name
            String = move_names_table[read_hword(&src[srcID])];
            srcID += 2;
            break;
        case 3: //type name
            String = type_names[read_byte(&src[srcID])];
            srcID++;
            break;
        case 4: //poke nick with prefix
            dst = get_chosen_poke_nick_with_prefix(read_byte(&src[srcID]), read_byte(&src[srcID + 1]), dst);
            srcID += 2;
            break;
        case 5: //stat names
            String = stat_names_table[read_byte(&src[srcID])];
            srcID++;
            break;
        case 6: //poke species
            buffer_pokemon_species(dst, read_hword(&src[srcID]));
            srcID +=2;
            break;
        case 7: //poke nick with no prefix
            dst = get_chosen_poke_nick(read_byte(&src[srcID]), read_byte(&src[srcID + 1]), dst);
            srcID += 2;
            break;
        case 8: //todo
            String = negative_flavour_table[read_byte(&src[srcID])];
            srcID++;
            break;
        case 9: //ability name
            String = get_ability_name_ptr(read_byte(&src[srcID]));
            srcID++;
            break;
        case 10: //item name
            buffer_item(read_hword(&src[srcID]), dst);
            srcID +=2;
            break;
        default:
            return;
        }
        if (String != NULL)
            str_append(dst, String);
    }
}

u8 get_link_id()
{
	u8 link_id = link_get_multiplayer_id();
	if (battle_flags.flag_x2000000)
		link_id = battle_some_link_id;
	return link_id;
}

u8 get_trainer_opponent_A_class();

const u8* get_trainer_opponent_A_name(u8* text)
{
	const u8* string = NULL;
	if (battle_flags.secret_base)
		string = battle_resources->secretbase_opponent->trainer_name;
	else if (var_8015_trainer_opponent_A == 0xC00)
		string = battle_link_pbs[get_link_id() ^ 1].trainer_name;
	else if (BATTLE_FRONTIER_BATTLE)
	{
		get_frontier_trainer_name(text, var_8015_trainer_opponent_A);
		string = text;
	}
	else if (battle_flags.flag_x4000000)
	{
		get_x4000000_trainername(text, var_8015_trainer_opponent_A);
		string = text;
	}
	else if (battle_flags.flagx800)
	{
		get_x800_trainername(text);
		string = text;
	}
	else
		string = get_trainername_address(var_8015_trainer_opponent_A);
	return string;
}

u32 b_strcpy_decode(const u8* const src, u8* const dst)
{
	u8 link_id = get_link_id();
	u32 dst_id = 0;
	u32 src_id = 0;
	while (src[src_id] != 0xFF)
	{
		u8 curr_char = src[src_id];
		src_id++;
		if (curr_char == BuffCharac) //decode string
		{
			u8 text[20];
			const u8* string = NULL;
			curr_char = src[src_id];
			src_id++;
			switch (curr_char) //fd char decoding
			{
			case 0:
				if (battle_text_buff1[0] == BuffCharac)
				{
					b_fdecode_case(battle_text_buff1, text);
					string = text;
				}
				else
				{
					string = get_status_text(battle_text_buff1);
					if (!string)
						string = battle_text_buff1;
				}
				break;
			case 1:
				if (battle_text_buff2[0] == BuffCharac)
				{
					b_fdecode_case(battle_text_buff2, text);
					string = text;
				}
				else
					string = battle_text_buff2;
				break;
            case 52:
                if (battle_text_buff3[0] == BuffCharac)
                {
                    b_fdecode_case(battle_text_buff3, text);
                    string = text;
                }
                else
                    string = battle_text_buff3;
                break;
            case 2: //copy script text buffer1
                string = script_text_buffer1;
                break;
            case 3: //copy script text buffer2
                string = script_text_buffer2;
                break;
            case 4: //copy script text buffer3
                string = script_text_buffer3;
                break;
            case 5: //player first poke name
                get_poke_nick(get_bank_by_player_ai(0), text);
                string = text;
                break;
            case 6: //opponent first poke name
                get_poke_nick(get_bank_by_player_ai(1), text);
                string = text;
                break;
            case 7: //player second poke name
                get_poke_nick(get_bank_by_player_ai(2), text);
                string = text;
                break;
            case 8: //opponent second poke name
                get_poke_nick(get_bank_by_player_ai(3), text);
                string = text;
                break;
            case 9: //link first player pokemon
                get_poke_nick_link(link_id, 0, text);
                string = text;
                break;
            case 10: //link first opponent pokemon
                get_poke_nick_link(link_id, 1, text);
                string = text;
                break;
            case 11: //link second player pokemon
                get_poke_nick_link(link_id, 2, text);
                string = text;
                break;
            case 12: //link opponent player pokemon
                get_poke_nick_link(link_id, 3, text);
                string = text;
                break;
            case 13: //todo
                break;
            case 14: //attacker name
                get_poke_nick(bank_attacker, text);
                string = text;
                break;
            case 15: //attacker name with prefix
                get_poke_nick_with_prefix(bank_attacker, text);
                string = text;
                break;
            case 53: //target name
                get_poke_nick(bank_target, text);
                string = text;
                break;
            case 16: //target name with prefix
                get_poke_nick_with_prefix(bank_target, text);
                string = text;
                break;
            case 17: //target partner name with prefix
                get_poke_nick_with_prefix(bank_partner_def, text);
                string = text;
                break;
            case 18: //active name with prefix
                get_poke_nick_with_prefix(active_bank, text);
                string = text;
                break;
            case 19: //scripting active name with prefix
                get_poke_nick_with_prefix(battle_scripting.active_bank, text);
                string = text;
                break;
            case 62: //new battlestruct bank with prefix
                get_poke_nick_with_prefix(new_battlestruct->various.active_bank, text);
                string = text;
                break;
            case 20: //move1 in buffer pointer
                string = move_names_table[(*buffer_moves)[0]];
                break;
            case 21: //move2 in buffer pointer
                string = move_names_table[(*buffer_moves)[1]];
                break;
			case 22: //get last used item
				if ((battle_flags.link || battle_flags.flag_x2000000) && last_used_item == ITEM_ENIGMABERRY)
				{
					u8 field25 = battle_scripting.field25;
					u8 enigma = 1;
					if (battle_flags.player_partner)
					{
						if (battle_link_pbs[field25].bank_id == another_active_bank)
							enigma = 0;
					}
					else if (field25 == 0 && !(another_active_bank & 1))
						enigma = 0;
					if (enigma)
						string = text_ENIGMA_BERRY;
					else
					{
						strcpy_xFF_terminated_0(text, enigma_berry_battle[another_active_bank].berry_name);
						str_append(text, text__BERRY);
						string = text;
					}
				}
				else
				{
					buffer_item(last_used_item, text);
					string = text;
				}
				break;
            case 23: //last used ability
                string = get_ability_name_ptr(gLastUsedAbility);
                break;
            case 24: //attackers ability
                string = get_ability_name_ptr(abilities_by_banks[bank_attacker]);
                break;
            case 25: //targets ability
                string = get_ability_name_ptr(abilities_by_banks[bank_target]);
                break;
            case 26: //scripting actives ability
                string = get_ability_name_ptr(abilities_by_banks[battle_scripting.active_bank]);
                break;
            case 27: //def partners ability
                string = get_ability_name_ptr(abilities_by_banks[bank_partner_def]);
                break;
            case 28: //trainer A class
            {
				u8 classID;
				u16 trainerA = var_8015_trainer_opponent_A;
				if (battle_flags.secret_base)
					classID = get_secretbase_trainerclass();
				else if (trainerA == 0xC00)
					classID = get_trainerxC00_trainerclass();
				else if (BATTLE_FRONTIER_BATTLE)
					classID = get_frontier_opponent_class(trainerA);
				else if (battle_flags.flag_x4000000)
					classID = get_x4000000_trainerclass(trainerA);
				else if (battle_flags.flagx800)
					classID = get_x800_trainerclass();
				else
					classID = get_trainer_opponent_A_class();
				string = get_trainerclass_ptr(classID);
            }
                break;
            case 29: //trainer A name
				string = get_trainer_opponent_A_name(text);
				break;
            case 30: //link player 1 name
                string = get_link_trainername(link_id, 0);
                break;
            case 31: //link player 2 name
                string = get_link_trainername(link_id, 2);
                break;
            case 32: //link player 3 name
                string = get_link_trainername(link_id, 1);
                break;
            case 33: //link player 4 name
                string = get_link_trainername(link_id, 3);
                break;
            case 34: //scripting active link name
                string = battle_link_pbs[get_linkpbs_id(battle_scripting.active_bank)].trainer_name;
                break;
            case 35: //players name
                string = sav2->name;
                break;
            case 36: //trainer A lose text
                if (BATTLE_FRONTIER_BATTLE)
                    get_frontier_opponent_battleend_text(var_8015_trainer_opponent_A, 2);
                else if (battle_flags.flag_x4000000)
                    x4000000_get_battle_text(var_8015_trainer_opponent_A, 4);
                else
                    copy_opponent_a_lose_text();
                string = displayed_string_ov;
                break;
            case 37: //trainer A win text
                if (BATTLE_FRONTIER_BATTLE)
                {
                    get_frontier_opponent_battleend_text(var_8015_trainer_opponent_A, 1);
                    string = displayed_string_ov;
                }
                else if (battle_flags.flag_x4000000)
                {
                    x4000000_get_battle_text(var_8015_trainer_opponent_A, 3);
                    string = displayed_string_ov;
                }
                else if (GET_CUSTOMFLAG(ALLOW_LOSE_FLAG))
                {
                    string = opponentwon_text;
                }
                break;
            case 38: //todo
                break;
            case 39: //PC system creator's name
                string = text_someones;
                if (getflag(0x8AB))
                    string = text_LANETTES;
                break;
            case 40: //attacker foe/ally
                string = text_Ally;
                if (get_bank_side(bank_attacker))
                    string = text_Foe;
                break;
            case 41: //target foe/ally
                string = text_Ally;
                if (get_bank_side(bank_target))
                    string = text_Foe;
                break;
            case 42: //attacker foe_/ally_
            case 44:
                string = text_Ally_;
                if (get_bank_side(bank_attacker))
                    string = text_Foe_;
                break;
            case 43: //target foe_/ally_
            case 45:
                string = text_Ally_;
                if (get_bank_side(bank_target))
                    string = text_Foe_;
                break;
            case 46: //trainer B class
			{
				u8 class_id;
				if (BATTLE_FRONTIER_BATTLE)
					class_id = get_frontier_opponent_class(trainer_opponent_B);
				else if (battle_flags.flag_x4000000)
					class_id = get_x4000000_trainerclass(trainer_opponent_B);
				else
					class_id = (*trainer_table)[trainer_opponent_B].class;
				string = get_trainerclass_ptr(class_id);
			}
                break;
            case 47: //trainer B name
                if (BATTLE_FRONTIER_BATTLE)
                {
                    get_frontier_trainer_name(text, trainer_opponent_B);
                    string = text;
                }
                else if (battle_flags.flag_x4000000)
                {
                    get_x4000000_trainername(text, trainer_opponent_B);
                    string = text;
                }
                else
                    string = (*trainer_table)[trainer_opponent_B].name;
                break;
            case 48: //trainer B lose text
                if (BATTLE_FRONTIER_BATTLE)
                    get_frontier_opponent_battleend_text(trainer_opponent_B, 2);
                else if (battle_flags.flag_x4000000)
                    x4000000_get_battle_text(trainer_opponent_B, 4);
                else
                    copy_opponent_b_lose_text();
                string = displayed_string_ov;
                break;
            case 49: //trainer B win text
                if (BATTLE_FRONTIER_BATTLE)
                {
                    get_frontier_opponent_battleend_text(trainer_opponent_B, 1);
                    string = displayed_string_ov;
                }
                else if (battle_flags.flag_x4000000)
                {
                    x4000000_get_battle_text(trainer_opponent_B, 3);
                    string = displayed_string_ov;
                }
                break;
            case 50: //partner trainer class
                if (partner_trainer & PARTNER_CUSTOM)
                    string = get_trainerclass_ptr((*trainer_table)[BIC(partner_trainer, PARTNER_ANIMATES | PARTNER_CUSTOM)].class);
                else
                    string = get_trainerclass_ptr(get_frontier_opponent_class(partner_trainer));
                break;
            case 51: //partner trainer name
                string = get_partner_name();
                break;
            case 54: //current move
                string = move_names_table[current_move];
                break;
            case 55: //lost/drew/won
                if (battle_outcome == OUTCOME_LOSS)
                {
                    static const u8 lost[] = {p_, e_, r_, d_, e_, u_, Space, c_, o_, n_, t_, r_, a_, 0xFF};
                    strcpy_xFF_terminated_0(text, lost);
                }
                else if (battle_outcome == OUTCOME_WIN)
                {
                    static const u8 won[] = {v_, e_, n_, c_, e_, u_, Space, c_, o_, n_, t_, r_, a_, 0xFF};
                    strcpy_xFF_terminated_0(text, won);
                }
                else if (battle_outcome == OUTCOME_DRAW)
                {
                    static const u8 drew[] = {e_, m_, p_, a_, t_, o_, u_, Space, c_, o_, m_, 0xFF};
                    strcpy_xFF_terminated_0(text, drew);
                }
                string = text;
                break;
            case 56: //trainer sliding msg
                string = new_battlestruct->various.trainer_slide_msg;
                break;
            case 57: //bank attacker, your team or foe's team - lowercase first letter
                if (get_bank_side(bank_attacker))
                    string = foeteam_text;
                else
                    string = userteam_text;
                break;
            case 63: //bank target, your team or foe's team - lowercase first letter
                if (get_bank_side(bank_target))
                    string = foeteam_text;
                else
                    string = userteam_text;
                break;
            case 64: //bank target, your team or foe's team - uppercase first letter
                if (get_bank_side(bank_target))
                    string = foeteam_uc_text;
                else
                    string = userteam_uc_text;
                break;
            case 58: //sharply/harshly, drastically, severally
                {
                    u8 stat_val = battle_scripting.stat_changer & STAT_STAGES;
                    if (stat_val == 0x20)
                        string = text_sharply_;
                    else if (stat_val == 0xA0)
                        string = text_harshly_;
                    else if (stat_val >= 0xB0)
                    {
                        static const u8 text_severely_[] = {s_, e_, v_, e_, r_, a_, m_, e_, n_, t_, e_, Space, 0xFF};
                        string = text_severely_;
                    }
                    else if (stat_val >= 0x30 && stat_val < 0x70)
                    {
                        static const u8 text_drastically_[] = {d_, r_, a_, s_, t_, i_, c_, a_, m_, e_, n_, t_, e_, Space, 0xFF};
                        string = text_drastically_;
                    }
                }
                break;
            case 59: //rose/fell
                if (battle_scripting.stat_changer & STAT_NEGATIVE)
                    string = text_fell;
                else
                    string = text_rose;
                break;
            case 60: //lower/higher
                if (battle_scripting.stat_changer & STAT_NEGATIVE)
                    string = text_lower;
                else
                {
                    static const u8 text_higher[] = {m_, a_, i_, o_, r_, 0xFF};
                    string = text_higher;
                }
                break;
            case 61: //raised, lowered
                if (battle_scripting.stat_changer & STAT_NEGATIVE)
                {
                    static const u8 text_lowered[] = {c_, a_, i_, u_, 0xFF};
                    string = text_lowered;
                }
                else
                {
                    static const u8 text_raised[] = {s_, u_, b_, i_, u_, 0xFF};
                    string = text_raised;
                }
                break;
            }
            if (string) //copy decoded string
            {
                for (u32 i = 0; string[i] != 0xFF; i++)
                {
                    dst[dst_id] = string[i];
                    dst_id++;
                }
                if (curr_char == 36 || curr_char == 37 || curr_char == 48 || curr_char == 49) //slow win/lose text down
                {
                    dst[dst_id] = 0xFC;
                    dst[dst_id + 1] = 9;
                    dst_id += 2;
                }
            }
        }
        else //just copy character
        {
            dst[dst_id] = curr_char;
            dst_id++;
        }
    }
    dst[dst_id] = 0xFF;
    dst_id++;
    return dst_id;
}

struct string_inf
{
    u8 cmdID;
    u8 outcome;
    u16 stringID;
    u16 moves[2]; //curr move and last move
    u16 last_item;
    u8 last_ability;
    u8 scr_active;
    u8 b_stuff_52;
    u8 b_stuff_hpbadscale;
    u8 another_act;
    u8 move_type;
    u8 abilities[4];
    u8 buffs[3][0x10];
};

void b_buffer_string(u16 strID)
{
    u8 bank = active_bank;
    struct string_inf* Strings = (struct string_inf*) &battle_bufferA[bank];

    //fill various string information
    buffer_moves = &Strings->moves;
    last_used_item = Strings->last_item;
    gLastUsedAbility = Strings->last_ability;
    battle_scripting.active_bank = Strings->scr_active;
    battle_stuff_ptr->field_52 = Strings->b_stuff_52;
    u8* hp_scale = &battle_stuff_ptr->curr_hp_bad_scale;
    *hp_scale = Strings->b_stuff_hpbadscale;
    battle_stuff_ptr->str_movetype = Strings->move_type;
    another_active_bank = Strings->another_act;

    for (u8 i = 0; i < 4; i++)
    { abilities_by_banks[i] = Strings->abilities[i]; }

    for (u8 i = 0; i < 0x10; i++)
    {
        battle_text_buff1[i] = Strings->buffs[0][i];
        battle_text_buff2[i] = Strings->buffs[1][i];
        battle_text_buff3[i] = Strings->buffs[2][i];
    }

    const u8* StrPtr = text_empty_string_00;
    u8 side = get_bank_side(bank);

    switch(strID)
    {
    case 0: //first battle msg
        if (battle_flags.trainer)
        {
            if (!battle_flags.link && !battle_flags.flag_x2000000)
            {
                if (battle_flags.multibattle)
                    StrPtr = text_trainer_multi_b_start;
                else
                    StrPtr = text_trainer_b_start;
            }
        }
        else
        {
            if (battle_flags.wally)
                StrPtr = text_wally_b_start;
            else if (battle_flags.legendary)
                StrPtr = text_legendary_b_start;
            else if (battle_flags.double_battle)
                StrPtr = text_wild_double_b_start;
            else
            {
                if (new_battlestruct->various.fishing_battle)
                {
                    static const u8 text_wild_hooked_b_start[] = {O_, Space, f_, i_, s_, g_, a_, d_, o_, Space, BuffCharac, 6, Space, a_, t_, a_, c_, o_, u_, Exclam, 0xFB, Termin};
                    StrPtr = text_wild_hooked_b_start;
                }
                else
                    StrPtr = text_wild_b_start;
            }
        }
        break;
    case 1: //poke first send-out
        if (side) //opponent poke
        {
			if (!battle_flags.trainer)
			{
				break;
			}
            if (battle_flags.double_battle)
            {
                if (battle_flags.multibattle || battle_flags.flag_x800000)
                    StrPtr = text_opponent_sendout_multi;
                else if (battle_flags.player_partner)
                    StrPtr = text_opponent_sendout_playerpartner;
                else if (battle_flags.link || battle_flags.flag_x2000000)
                    StrPtr = text_opponent_sendout_link;
                else
                    StrPtr = text_opponent_sendouts_two;
            }
            else
            {
                if ((battle_flags.link || battle_flags.flag_x2000000) && var_8015_trainer_opponent_A != 0xC00)
                    StrPtr = text_opponent_single_sendout_link;
                else
                    StrPtr = text_opponent_sendout_single;
            }
        }
        else //player poke
        {
            if (battle_flags.double_battle)
            {
                if (battle_flags.player_ingame_partner)
                    StrPtr = text_player_sendout_ingame_partner;
                else if (battle_flags.player_partner)
                    StrPtr = text_player_sendout_partner;
                else
                    StrPtr = text_GO_xfd5_and_xfd7;
            }
            else
                StrPtr = text_GO_xfd5;
        }
        break;
    case 2: //sending poke to ball msg
        if (side) //opponent poke
        {
            if (var_8015_trainer_opponent_A == 0x800 || battle_flags.flag_x2000000)
            {
                if (battle_flags.player_partner)
                    StrPtr = text_fdx22_withdrew;
                else
                    StrPtr = text_fdx20_withdrew;
            }
            else
                StrPtr = text_trainerA_withdrew;
        }
        else //player poke
        {
            if (*hp_scale == 0)
                StrPtr = text_thatsenough_come_back;
            else if (*hp_scale == 1 || battle_flags.double_battle)
                StrPtr = text_xfd0_come_back;
            else if (*hp_scale == 2)
                StrPtr = text_ok_come_back;
            else
                StrPtr = text_good_come_back;
        }
        break;
    case 3: //switch-in msg
        if (side) //opponent poke
        {
            if ((battle_flags.link || battle_flags.flag_x2000000) && !battle_flags.flag_x800000)
            {
                if (battle_flags.player_partner)
                    StrPtr = text_fdx22_sent_out;
                else if (var_8015_trainer_opponent_A == 0xC00)
                    StrPtr = text_trainerA_sent_out;
                else
                    StrPtr = text_fdx20_sent_out;
            }
            else
            {
                if (battle_flags.multibattle && battle_scripting.active_bank != 1)
                    StrPtr = text_trainerB_sent_out;
                else
                    StrPtr = text_trainerA_sent_out;
            }
        }
        else //player poke
        {
            if (*hp_scale == 0 || battle_flags.double_battle)
                StrPtr = text_go_fdx0;
            else if (*hp_scale == 1)
                StrPtr = text_do_it_fdx0;
            else if (*hp_scale == 2)
                StrPtr = text_your_foe_is_weak_getem_fdx0;
            else
                StrPtr = text_go_for_it_fdx0;
        }
        break;
    case 4: //poke used a move msg
        {
            u8* str = strcpy_xFF_terminated_0(battle_text_buff2, move_names_table[(*buffer_moves)[0]]);
            str[0] = Exclam, str[1] = Termin;
            StrPtr = text_poke_used_move;
        }
        break;
    case 5: //battle end
	{
		u8* decider = &battle_text_buff1[0];
		if (*decider & 0x80) //apparently this is running away
		{
			*decider = BIC(*decider, 0x80);
			if (side && *decider != 3)
				*decider ^= 3;
			if (*decider == 3)
				StrPtr = text_fcx10_got_away_safely;
			else if (battle_flags.player_partner)
				StrPtr = text_fcx10_two_fled;
			else
				StrPtr = text_fcx10_one_fled;
		}
		else
		{
			if (side && *decider != 3)
				*decider ^= 3;
			if (battle_flags.multibattle)
			{
				if (*decider == 2)
					StrPtr = text_player_lost_to_fdx20_and_fdx21;
				else if (*decider == 1)
					StrPtr = text_player_beat_fdx20_and_fdx21;
				else if (*decider == 3)
					StrPtr = text_player_battled_to_draw_against_fdx20_and_fdx21;
			}
			else if (var_8015_trainer_opponent_A == 0xC00)
			{

			}
			else
			{
				if (*decider == 2)
					StrPtr = text_player_lost_to_fdx20;
				else if (*decider == 1)
					StrPtr = text_player_defeated_fdx20;
				else if (*decider == 3)
					StrPtr = text_player_battled_to_draw_against_fdx20;
			}
		}
	}
	break;
    default: //load from move table
        StrPtr = get_battlestring(strID);
        break;
    }

    b_strcpy_decode(StrPtr, displayed_string_in_battle);
}

void prep_string(u16 strID, u8 bank)
{
    active_bank = bank;
    bb10_printstring(0, strID), mark_buffer_bank_for_execution(bank);
}
