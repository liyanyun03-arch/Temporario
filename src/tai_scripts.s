.text
.thumb

.include "asm_defines.s"
.include "defines/tai_commands.s"

.equ POINTS_MINUS1, 0x082dc789
.equ POINTS_MINUS2, 0x082dc78c
.equ POINTS_MINUS3, 0x082dc78f
.equ POINTS_MINUS5, 0x082dc792
.equ POINTS_MINUS8, 0x082dc795
.equ POINTS_MINUS10, 0x082dc798
.equ POINTS_MINUS12, 0x082dc79b
.equ POINTS_MINUS30, 0x082dc79e
.equ POINTS_PLUS1, 0x082dc7a1
.equ POINTS_PLUS2, 0x082dc7a4
.equ POINTS_PLUS3, 0x082dc7a7
.equ POINTS_PLUS4, 0x082DD4D3 
.equ POINTS_PLUS5, 0x082dc7aa
.equ POINTS_PLUS10, 0x082dc7ad
.equ END_LOCATION, 0x082de34e

.equ SUPER_EFFECTIVE, 3
.equ NORMAL_EFFECTIVENESS, 2
.equ NOT_VERY_EFFECTIVE, 1
.equ NO_EFFECT, 0

.equ ITEM_NONE, 0
.equ STATUS_ANY, 0xFFFF

.equ bank_target, 0x0
.equ bank_ai, 0x1
.equ bank_targetpartner, 0x2
.equ bank_aipartner, 0x3

.equ min_stat_stage, 0
.equ default_stat_stage, 6
.equ max_stat_stage, 12

.equ AI_TYPE1_TARGET, 0x0
.equ AI_TYPE1_USER, 0x1
.equ AI_TYPE2_TARGET, 0x2
.equ AI_TYPE2_USER, 0x3
.equ AI_TYPE_MOVE, 0x4
.equ MOVE_POWER_OTHER, 0
.equ MOVE_NOT_MOST_POWERFUL, 1
.equ MOVE_MOST_POWERFUL, 2

.equ NO_INCREASE,      0
.equ WEAK_EFFECT,      1
.equ DECENT_EFFECT,    2
.equ GOOD_EFFECT,      3
.equ BEST_EFFECT,      4

.equ move_target_selected, 0
.equ move_target_depends, 1
.equ move_target_random, 4
.equ move_target_both, 8
.equ move_target_user, 0x10
.equ move_target_foes_and_ally, 0x20
.equ move_target_opponent_field, 0x40

.equ BANK_AFFECTING_HEALBLOCK, 0x0
.equ BANK_AFFECTING_EMBARGO, 0x1
.equ BANK_AFFECTING_GASTROACID, 0x2
.equ BANK_AFFECTING_MIRACLEEYE, 0x3
.equ BANK_AFFECTING_AQUARING, 0x4
.equ BANK_AFFECTING_MAGNETRISE, 0x5
.equ BANK_AFFECTING_TELEKINESIS, 0x6
.equ BANK_AFFECTING_LASERFOCUS, 0x7
.equ BANK_AFFECTING_POWERTRICK, 0x8
.equ BANK_AFFECTING_SMACKEDDOWN, 0x9
.equ BANK_AFFECTING_BANEFULBUNKER, 0xA
.equ BANK_AFFECTING_OBSTRUCT, 0xB

.equ SIDE_AFFECTING_TAILWIND, 0x0
.equ SIDE_AFFECTING_LUCKYCHANT, 0x1
.equ SIDE_AFFECTING_AURORAVEIL, 0x2
.equ SIDE_AFFECTING_GRASSPLEDGE, 0x3
.equ SIDE_AFFECTING_FIREPLEDGE, 0x4
.equ SIDE_AFFECTING_WATERPLEDGE, 0x5
.equ SIDE_AFFECTING_MATBLOCK, 0x6
.equ SIDE_AFFECTING_WIDEGUARD, 0x7
.equ SIDE_AFFECTING_QUICKGUARD, 0x8

.equ FIELD_AFFECTING_GRAVITY, 0x0
.equ FIELD_AFFECTING_TRICKROOM, 0x1
.equ FIELD_AFFECTING_WONDERROOM, 0x2
.equ FIELD_AFFECTING_MAGICROOM, 0x3
.equ FIELD_AFFECTING_TERRAINS, 0x4 @Read from Move ID
.equ FIELD_AFFECTING_MISTY_TERRAIN, 0x5
.equ FIELD_AFFECTING_GRASSY_TERRAIN, 0x6
.equ FIELD_AFFECTING_ELECTRIC_TERRAIN, 0x7
.equ FIELD_AFFECTING_PSYCHIC_TERRAIN, 0x8
.equ FIELD_AFFECTING_FAIRY_LOCK, 0x9
.equ FIELD_AFFECTING_ION_DELUGE, 0xA

TAI_SCRIPT_0: @don't act stupid; bitfield 0x1, AI_CheckBadMove
	jumpiftargetisally END_LOCATION
	getmovetarget
	jumpifbytevarEQ move_target_selected DISCOURAGE_NOTAFFECTED
	jumpifdoublebattle DISCOURAGE_MOVESBASEDONABILITIES
	getmovetarget
	jumpifbytevarEQ move_target_both DISCOURAGE_NOTAFFECTED
	jumpifbytevarNE move_target_foes_and_ally DISCOURAGE_MOVESBASEDONABILITIES
DISCOURAGE_NOTAFFECTED:
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10  @ 0x de dano
    @ Verifica efetividade reduzida (0.25x ou 0.125x)
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE DISCOURAGE_REDUCED_EFFECTIVENESS
DISCOURAGE_REDUCED_EFFECTIVENESS:
    getmoveid
    jumpifhwordvarinlist ignore_effectiveness_moves DISCOURAGE_MOVESBASEDONABILITIES
    goto_cmd NEGATIVE_RE

NEGATIVE_RE:
	scoreupdate -10
	return_cmd
DISCOURAGE_MOVESBASEDONABILITIES:
	discourage_moves_based_on_abilities
	isoftype bank_target TYPE_GRASS
	jumpifbytevarNE 1 DISCOURAGE_MOVES_ON_SUBSTITUTE
DISCOURAGE_POWDER_ON_GRASS:
	getmoveid
	jumpifhwordvarinlist powder_moves POINTS_MINUS10
DISCOURAGE_MOVES_ON_SUBSTITUTE:
	jumpifnostatus2 bank_target STATUS2_SUBSTITUTE DISCOURAGE_MOVES_ON_SEMIINVULNERABLE
	affected_by_substitute
	jumpifbytevarNE 1 DISCOURAGE_MOVES_ON_SEMIINVULNERABLE
	getmovepower
	jumpifbytevarEQ 0 POINTS_MINUS10
DISCOURAGE_MOVES_ON_SEMIINVULNERABLE:
	jumpiftargetisally POINTS_MINUS30
	isinsemiinvulnerablestate bank_target
	jumpifbytevarEQ 0 DISCOURAGE_STUPIDMOVEEFFECTS
	getmovetarget
	jumpifbytevarEQ move_target_user DISCOURAGE_STUPIDMOVEEFFECTS
	jumpifstrikessecond bank_ai bank_target DISCOURAGE_STUPIDMOVEEFFECTS @ai hits after poke is no longer in the semiinvlnerable state
	getmoveid
	movehitssemiinvulnerable bank_target 0xFFFF
	jumpifbytevarEQ 0x1 DISCOURAGE_STUPIDMOVEEFFECTS
	goto_cmd NEGATIVE_MS
	call_cmd DISCOURAGE_TWO_TURN

NEGATIVE_MS:
	scoreupdate -10
	return_cmd
DISCOURAGE_STUPIDMOVEEFFECTS:
	jumpifmovescriptEQ 0 DISCOURAGE_ZEROTH
	jumpifmovescriptEQ 1 DISCOURAGE_THAT_MAY_FAIL	@Endeavour
	jumpifmovescriptEQ 2 DISCOURAGE_ONESTATUSER
	jumpifmovescriptEQ 3 DISCOURAGE_ONESTATTARGET
	jumpifmovescriptEQ 4 DISCOURAGE_USERSTAT_CHANCE
	jumpifmovescriptEQ 5 DISCOURAGE_TARGETSTAT_CHANCE
	jumpifmovescriptEQ 6 DISCOURAGE_MULTIPLESTATSCHANGE
	jumpifmovescriptEQ 7 DISCOURAGE_MULTIPLESTATSCHANGE
	jumpifmovescriptEQ 8 DISCOURAGE_MULTIPLESTAT_CHANCE_USER
	jumpifmovescriptEQ 9 DISCOURAGE_CONFUSION
	jumpifmovescriptEQ 10 DISCOURAGE_ATTACK_CONFUSION
	jumpifmovescriptEQ 11 DISCOURAGE_FLINCH
	jumpifmovescriptEQ 12 DISCOURAGE_SLEEP
	jumpifmovescriptEQ 13 DISCOURAGE_POISON
	jumpifmovescriptEQ 14 DISCOURAGE_POISON
	jumpifmovescriptEQ 15 DISCOURAGE_PARALYSIS
	jumpifmovescriptEQ 16 DISCOURAGE_BURNING
	jumpifmovescriptEQ 18 DISCOURAGE_ATTACK_STATUS_CHANCE
	jumpifmovescriptEQ 19 DISCOURAGE_RECOIL
	jumpifmovescriptEQ 20 DISCOURAGE_KICK_FATAL
	jumpifmovescriptEQ 21 DISCOURAGE_SUICIDE
	jumpifmovescriptEQ 22 DISCOURAGE_SUICIDE
	jumpifmovescriptEQ 23 DISCOURAGE_EXPLOSION
	jumpifmovescriptEQ 24 DISCOURAGE_HEALBLOCK_AI @Draining Moves
	jumpifmovescriptEQ 25 DISCOURAGE_HPUSERHEAL
	jumpifmovescriptEQ 26 DISCOURAGE_HEAL_PULSE
	jumpifmovescriptEQ 27 DISCOURAGE_CHARGE
	jumpifmovescriptEQ 28 DISCOURAGE_PSYCHOSHIFT
	jumpifmovescriptEQ 29 DISCOURAGE_HPUSERHEAL @Roost
	jumpifmovescriptEQ 30 DISCOURAGE_GRAVITY
	jumpifmovescriptEQ 31 DISCOURAGE_IDENTYFING
	jumpifmovescriptEQ 32 DISCOURAGE_ATTACK_HEAL_TARGET_STATUS
	jumpifmovescriptEQ 33 DISCOURAGE_FEINT
	jumpifmovescriptEQ 34 DISCOURAGE_PROTECT
	jumpifmovescriptEQ 35 DISCOURAGE_SWITCH2
	jumpifmovescriptEQ 36 DISCOURAGE_SUCKER_PUNCH
	jumpifmovescriptEQ 37 DISCOURAGE_ATTRACT
	jumpifmovescriptEQ 38 DISCOURAGE_CAPTIVATE
	jumpifmovescriptEQ 39 DISCOURAGE_RECHARGE
	jumpifmovescriptEQ 40 DISCOURAGE_TRAP
	jumpifmovescriptEQ 41 DISCOURAGE_THIRDTYPEADD
	jumpifmovescriptEQ 42 DISCOURAGE_ABILITYCHANGE
	jumpifmovescriptEQ 43 DISCOURAGE_ROOMS
	jumpifmovescriptEQ 44 DISCOURAGE_COUNTER @Counter, Mirror Coat e Metal Burst
	jumpifmovescriptEQ 45 DISCOURAGE_GASTROACID
	jumpifmovescriptEQ 46 DISCOURAGE_EMBARGO
	jumpifmovescriptEQ 47 DISCOURAGE_NATURALGIFT
	jumpifmovescriptEQ 48 DISCOURAGE_AFTER_YOU @After You
	jumpifmovescriptEQ 49 DISCOURAGE_POWDER @ Powder
	jumpifmovescriptEQ 50 DISCOURAGE_AROMATIC_MIST @Aromatic Mist ;target is not bank at this point
	jumpifmovescriptEQ 51 DISCOURAGE_CLEARSMOG
	jumpifmovescriptEQ 52 DISCOURAGE_ELECTRIFY
	jumpifmovescriptEQ 53 DISCOURAGE_ENTRYHAZARDS
	jumpifmovescriptEQ 54 DISCOURAGE_IFNOALLY @Follow Me/Rage Powder
	jumpifmovescriptEQ 55 DISCOURAGE_SYNCHRONOISE
	jumpifmovescriptEQ 56 DISCOURAGE_ONESTATUSER @Autonomize
	jumpifmovescriptEQ 57 DISCOURAGE_IONDELUGE @ Ion Deluge
	jumpifmovescriptEQ 58 DISCOURAGE_CAMOUFLAGE@ Camouflage, necessita de completo
	jumpifmovescriptEQ 59 DISCOURAGE_REFLECT_TYPE @Necessita de completo
	jumpifmovescriptEQ 60 DISCOURAGE_FOCUSENERGY
	jumpifmovescriptEQ 61 DISCOURAGE_TAUNT
	jumpifmovescriptEQ 62 DISCOURAGE_TORMENT
	jumpifmovescriptEQ 63 DISCOURAGE_HEALBLOCK
	jumpifmovescriptEQ 64 DISCOURAGE_MEANLOOK
	jumpifmovescriptEQ 65 DISCOURAGE_PERISHSONG
	jumpifmovescriptEQ 66 DISCOURAGE_HITS_MULTIPLE_TIMES
	jumpifmovescriptEQ 67 DISCOURAGE_HITS2x
	jumpifmovescriptEQ 68 DISCOURAGE_BIDE
	jumpifmovescriptEQ 69 DISCOURAGE_PAYDAY
	jumpifmovescriptEQ 70 DISCOURAGE_ONEHITKO
	jumpifmovescriptEQ 71 DISCOURAGE_GEOMANCY
	jumpifmovescriptEQ 72 DISCOURAGE_ROAR
	jumpifmovescriptEQ 73 DISCOURAGE_IFNOALLY @Ally Switch
	jumpifmovescriptEQ 74 DISCOURAGE_CRAZY
	jumpifmovescriptEQ 75 DISCOURAGE_DISABLE
	jumpifmovescriptEQ 76 DISCOURAGE_ENCORE
	jumpifmovescriptEQ 77 DISCOURAGE_MIST
	jumpifmovescriptEQ 78 DISCOURAGE_LEECHSEED
	jumpifmovescriptEQ 79 DISCOURAGE_RAGE
	jumpifmovescriptEQ 80 DISCOURAGE_TELEPORT		@Teleport
	jumpifmovescriptEQ 81 DISCOURAGE_IFNOLASTMOVE @Mimic
	jumpifmovescriptEQ 82 DISCOURAGE_ONESTATUSER @Minimize
	jumpifmovescriptEQ 83 DISCOURAGE_ONESTATUSER @Defense Curl
	jumpifmovescriptEQ 84 DISCOURAGE_REFLECT
	jumpifmovescriptEQ 85 DISCOURAGE_LIGHTSCREEN
	jumpifmovescriptEQ 86 DISCOURAGE_HAZE
	jumpifmovescriptEQ 88 DISCOURAGE_COPYCAT @Mirror Move
	jumpifmovescriptEQ 89 DISCOURAGE_IFNOTASLEEP @Dream Eater
	jumpifmovescriptEQ 90 DISCOURAGE_NIGHTMARE
	jumpifmovescriptEQ 91 DISCOURAGE_TRANSFORM
	jumpifmovescriptEQ 92 POINTS_MINUS10 @Splash, Celebrate e Hold Hands
	jumpifmovescriptEQ 93 DISCOURAGE_HPUSERHEAL @ Rest
	jumpifmovescriptEQ 94 DISCOURAGE_CONVERSION @ Conversion e Conversion2
	jumpifmovescriptEQ 95 DISCOURAGE_TRIATTACK
	jumpifmovescriptEQ 96 DISCOURAGE_SUBSTITUTE
	jumpifmovescriptEQ 97 DISCOURAGE_SKETCH
	jumpifmovescriptEQ 98 DISCOURAGE_TRIPLEKICK
	jumpifmovescriptEQ 99 DISCOURAGE_THIEFCOVET
	jumpifmovescriptEQ 100 DISCOURAGE_LOCKON
	jumpifmovescriptEQ 101 DISCOURAGE_IFNOLASTMOVE @Spite
	jumpifmovescriptEQ 102 DISCOURAGE_BERRYDRUM
	jumpifmovescriptEQ 103 DISCOURAGE_DESTINYBOND
	jumpifmovescriptEQ 104 DISCOURAGE_CURSE
	jumpifmovescriptEQ 105 DISCOURAGE_ROICE
	jumpifmovescriptEQ 106 DISCOURAGE_FURYCUTTER
	jumpifmovescriptEQ 107 DISCOURAGE_IFNOSLEEPUSER @Sleep Talk
	jumpifmovescriptEQ 108 DISCOURAGE_HEALBELL
	jumpifmovescriptEQ 109 DISCOURAGE_PRESENT
	jumpifmovescriptEQ 110 DISCOURAGE_SAFEGUARD
	jumpifmovescriptEQ 111 DISCOURAGE_PAINSPLIT
	jumpifmovescriptEQ 112 DISCOURAGE_MAGICCOAT
	jumpifmovescriptEQ 113 DISCOURAGE_RAPIDSPIN
	jumpifmovescriptEQ 114 DISCOURAGE_PSYCHUP
	jumpifmovescriptEQ 115 DISCOURAGE_FUTURESIGHT
	jumpifmovescriptEQ 116 DISCOURAGE_BEATUP
	jumpifmovescriptEQ 117 DISCOURAGE_UPROAR
	jumpifmovescriptEQ 118 DISCOURAGE_STOCKPILESTUFF
	jumpifmovescriptEQ 119 DISCOURAGE_MAGNITUDE
	jumpifmovescriptEQ 120 DISCOURAGE_FOCUSPUNCH
	jumpifmovescriptEQ 121 DISCOURAGE_NATUREPOWER
	jumpifmovescriptEQ 122 DISCOURAGE_IFNOALLY @Helping Hand
	jumpifmovescriptEQ 123 DISCOURAGE_TRICK
	jumpifmovescriptEQ 124 DISCOURAGE_WISH
	jumpifmovescriptEQ 125 DISCOURAGE_ASSIST
	jumpifmovescriptEQ 126 DISCOURAGE_INGRAIN
	jumpifmovescriptEQ 127 DISCOURAGE_BATONPASS
	jumpifmovescriptEQ 128 DISCOURAGE_RECYCLE
	jumpifmovescriptEQ 129 DISCOURAGE_IFNOSLEEPUSER @Snore
	jumpifmovescriptEQ 130 DISCOURAGE_BRICKPSY
	jumpifmovescriptEQ 131 DISCOURAGE_YAWN
	jumpifmovescriptEQ 132 DISCOURAGE_KNOCK_OFF
	jumpifmovescriptEQ 133 DISCOURAGE_IMPRISION
	jumpifmovescriptEQ 134 DISCOURAGE_REFRESH
	jumpifmovescriptEQ 135 DISCOURAGE_GRUDGE
	jumpifmovescriptEQ 136 DISCOURAGE_SNATCH
	jumpifmovescriptEQ 137 DISCOURAGE_SECRETPOWER
	jumpifmovescriptEQ 138 DISCOURAGE_SPORTS
	jumpifmovescriptEQ 139 DISCOURAGE_PBI
	jumpifmovescriptEQ 140 DISCOURAGE_TAILWIND
	jumpifmovescriptEQ 141 DISCOURAGE_ACUPRESSURE
	jumpifmovescriptEQ 142 DISCOURAGE_FLING
	jumpifmovescriptEQ 143 DISCOURAGE_POWER_TRICK
	jumpifmovescriptEQ 144 DISCOURAGE_LUCKYCHANT
	jumpifmovescriptEQ 145 DISCOURAGE_POWER_GUARD_HEART_SWAP
	jumpifmovescriptEQ 146 DISCOURAGE_ME_FIRST
	jumpifmovescriptEQ 147 DISCOURAGE_COPYCAT
	jumpifmovescriptEQ 148 DISCOURAGE_AQUARING
	jumpifmovescriptEQ 149 DISCOURAGE_MAGNETRISE
	jumpifmovescriptEQ 150 DISCOURAGE_DEFOG
	jumpifmovescriptEQ 151 DISCOURAGE_TERRAINS
	jumpifmovescriptEQ 152 DISCOURAGE_POWERSPLIT
	jumpifmovescriptEQ 153 DISCOURAGE_TELEKINESIS
	jumpifmovescriptEQ 154 DISCOURAGE_SDTA
	jumpifmovescriptEQ 155 DISCOURAGE_SOAK
	jumpifmovescriptEQ 156 DISCOURAGE_SHELLSMASH
	jumpifmovescriptEQ 157 DISCOURAGE_SKYDROP
	jumpifmovescriptEQ 158 DISCOURAGE_SHIFTGEAR
	jumpifmovescriptEQ 159 DISCOURAGE_QUASH
	jumpifmovescriptEQ 160 DISCOURAGE_FAKEOUT
	jumpifmovescriptEQ 161 DISCOURAGE_SANDSTORM
	jumpifmovescriptEQ 162 DISCOURAGE_RAINDANCE
	jumpifmovescriptEQ 163 DISCOURAGE_SUNNYDAY
	jumpifmovescriptEQ 164 DISCOURAGE_HAIL
	jumpifmovescriptEQ 165 DISCOURAGE_THAT_MAY_FAIL @Magnetic Flux
	jumpifmovescriptEQ 166 DISCOURAGE_VENOMDRENCH
	jumpifmovescriptEQ 167 DISCOURAGE_ROTOTILLER
	jumpifmovescriptEQ 168 DISCOURAGE_THAT_MAY_FAIL @Last Resort
	jumpifmovescriptEQ 169 DISCOURAGE_TOPSY_TURVY @Topsy Turvy
	jumpifmovescriptEQ 170 DISCOURAGE_BESTOW @ Bestow
	jumpifmovescriptEQ 171 DISCOURAGE_PARTING_SHOT @Parting Shot
	jumpifmovescriptEQ 172 POINTS_MINUS10 @Happy Hour
	jumpifmovescriptEQ 173 DISCOURAGE_FAIRYLOCK
	jumpifmovescriptEQ 174 DISCOURAGE_THAT_MAY_FAIL @Belch
	jumpifmovescriptEQ 175 DISCOURAGE_FLAMEBURST
	jumpifmovescriptEQ 176 DISCOURAGE_DAMAGETRAP
	jumpifmovescriptEQ 177 DISCOURAGE_SWITCH @Dragon Tail e Circle Throw
	jumpifmovescriptEQ 178 DISCOURAGE_FINAL_GAMBIT @Final Gambit
	jumpifmovescriptEQ 179 DISCOURAGE_PLEDGE @ Pledge
	jumpifmovescriptEQ 180 DISCOURAGE_PURIFY @Purify
	jumpifmovescriptEQ 181 DISCOURAGE_TOXICTHREAD @Toxic Thread
	jumpifmovescriptEQ 182 DISCOURAGE_LASERFOCUS @Laser Focus
	jumpifmovescriptEQ 183 DISCOURAGE_AURORAVEIL @Aurora Veil
	jumpifmovescriptEQ 184 DISCOURAGE_STRENGTH_SAP @Strength Sap
	jumpifmovescriptEQ 185 DISCOURAGE_LOSETYPE
	jumpifmovescriptEQ 186 DISCOURAGE_CONFUSE_STATCHANGE @Confuse Moves
	jumpifmovescriptEQ 187 DISCOURAGE_INSTRUCT
	jumpifmovescriptEQ 188 DISCOURAGE_MINDBLOWN
	jumpifmovescriptEQ 189 DISCOURAGE_EERIE
	jumpifmovescriptEQ 190 DISCOURAGE_CHILLY_RECEPTION @Chilly Reception
	jumpifmovescriptEQ 191 DISCOURAGE_CHLOROBLAST
	jumpifmovescriptEQ 192 DISCOURAGE_CLANGOROUSSOUL
	jumpifmovescriptEQ 193 DISCOURAGE_PLASMAFISTS
	jumpifmovescriptEQ 194 DISCOURAGE_SPOTLIGHT @Lógica a ser adicionada
	jumpifmovescriptEQ 196 DISCOURAGE_HIT_ENEMY_HEAL_ALLY @ Pollen Puff
	jumpifmovescriptEQ 197 DISCOURAGE_SPEEDSWAP @ Speed Swap
	jumpifmovescriptEQ 199 DISCOURAGE_DIRECLAW
	goto_cmd END_LOCATION
################################################################################################
DISCOURAGE_ZEROTH:
	getmoveid
	jumpifmove MOVE_KARATE_CHOP CRITICAL_CHANCE @Encoraja um pouco se tiver itens que eleva chance crítica
	jumpifmove MOVE_MEGA_PUNCH CRITICAL_CHANCE 
	jumpifmove MOVE_VICE_GRIP CHECK_EFFECTIVENESS_GENERIC  @Verificação de efetividade
	jumpifmove MOVE_GUST GUST
	jumpifmove MOVE_VINE_WHIP CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_WATER_GUN CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_HYDRO_PUMP CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_SURF ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_PECK CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_DRILL_PECK CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_LOW_KICK LOW_KICK
	jumpifmove MOVE_RAZOR_LEAF CRITICAL_CHANCE 
	jumpifmove MOVE_ROCK_THROW CRITICAL_CHANCE 
	jumpifmove MOVE_EARTHQUAKE EARTHQUAKE
	jumpifmove MOVE_EGG_BOMB EGG_BOMB
	jumpifmove MOVE_QUICK_ATTACK NOT_PRIORITY @Desencoraja seu uso perante anulação de prioridade
	jumpifmove MOVE_CRABHAMMER CRITICAL_CHANCE 
	jumpifmove MOVE_SLASH CRITICAL_MORE_SHARPNESS
	jumpifmove MOVE_FLAIL HP_DAMAGE @Quanto menor o HP, maior será o dano causado
	jumpifmove MOVE_AEROBLAST CRITICAL_CHANCE 
	jumpifmove MOVE_REVERSAL HP_DAMAGE
	jumpifmove MOVE_MACH_PUNCH NOT_PRIORITY
	jumpifmove MOVE_FEINT_ATTACK CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_RETURN RETURN_DAMAGE
	jumpifmove MOVE_FRUSTRATION FRUSTRATION_DAMAGE
	jumpifmove MOVE_MEGAHORN CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_PURSUIT PURSUIT
	jumpifmove MOVE_VITAL_THROW VITAL_THROW
	jumpifmove MOVE_HIDDEN_POWER CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_CROSS_CHOP CRITICAL_CHANCE
	jumpifmove MOVE_EXTREME_SPEED NOT_PRIORITY
	jumpifmove MOVE_FACADE FACADE
	jumpifmove MOVE_REVENGE CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_ERUPTION HP_DAMAGE_HIGH @Quanto maior o HP atual, maior o dano causado
	jumpifmove MOVE_HYPER_VOICE BULLETPROOF_IMUNE
	jumpifmove MOVE_WEATHER_BALL CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_AIR_CUTTER CRITICAL_CHANCE
	jumpifmove MOVE_WATER_SPOUT HP_DAMAGE_HIGH
	jumpifmove MOVE_SHADOW_PUNCH ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_SKY_UPPERCUT SKY_UPPERCUT
	jumpifmove MOVE_AERIAL_ACE CRITICAL_MORE_SHARPNESS
	jumpifmove MOVE_DRAGON_CLAW CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_MAGICAL_LEAF ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_LEAF_BLADE CRITICAL_MORE_SHARPNESS
	jumpifmove MOVE_SHOCK_WAVE ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_GYRO_BALL ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_BRINE BRINE
	jumpifmove MOVE_PAYBACK PAYBACK
	jumpifmove MOVE_ASSURANCE CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_TRUMP_CARD ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_WRING_OUT HP_DAMAGE_HIGH
	jumpifmove MOVE_PUNISHMENT HP_DAMAGE_HIGH
	jumpifmove MOVE_AURA_SPHERE AURA_SPHERE
	jumpifmove MOVE_NIGHT_SLASH CRITICAL_MORE_SHARPNESS
	jumpifmove MOVE_AQUA_TAIL CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_SEED_BOMB BULLETPROOF_IMUNE
	jumpifmove MOVE_XSCISSOR SHARPNESS
	jumpifmove MOVE_DRAGON_PULSE DRAGON_PULSE
	jumpifmove MOVE_POWER_GEM CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_VACUUM_WAVE NOT_PRIORITY
	jumpifmove MOVE_BULLET_PUNCH NOT_PRIORITY
	jumpifmove MOVE_AVALANCHE AVALANCHE
	jumpifmove MOVE_ICE_SHARD NOT_PRIORITY
	jumpifmove MOVE_SHADOW_CLAW CRITICAL_CHANCE
	jumpifmove MOVE_SHADOW_SNEAK NOT_PRIORITY
	jumpifmove MOVE_PSYCHO_CUT CRITICAL_MORE_SHARPNESS
	jumpifmove MOVE_POWER_WHIP CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_MAGNET_BOMB BULLETPROOF_IMUNE_MORE_ALVO_SEMI_IVULNERAVEL
	jumpifmove MOVE_STONE_EDGE CRITICAL_CHANCE
	jumpifmove MOVE_GRASS_KNOT GRASS_KNOT
	jumpifmove MOVE_JUDGMENT JUDGMENT
	jumpifmove MOVE_AQUA_JET NOT_PRIORITY
	jumpifmove MOVE_ATTACK_ORDER CRITICAL_CHANCE
	jumpifmove MOVE_SPACIAL_REND CRITICAL_CHANCE
	jumpifmove MOVE_CRUSH_GRIP HP_DAMAGE_HIGH
	jumpifmove MOVE_PSYSHOCK PSYSHOCK
	jumpifmove MOVE_VENOSHOCK VENOSHOCK
	jumpifmove MOVE_STORM_THROW STORM_THROW
	jumpifmove MOVE_HEAVY_SLAM STORM_THROW
	jumpifmove MOVE_ELECTRO_BALL ELECTRO_BALL
	jumpifmove MOVE_FOUL_PLAY FOUL_PLAY
	jumpifmove MOVE_ROUND MOVE_ROUND
	jumpifmove MOVE_ECHOED_VOICE ECHOED_VOICE
	jumpifmove MOVE_CHIP_AWAY CHIP_AWAY
	jumpifmove MOVE_HEX HEX
	jumpifmove MOVE_ACROBATICS ACROBATICS
	jumpifmove MOVE_FROST_BREATH FROST_BREATH
	jumpifmove MOVE_DRILL_RUN CRITICAL_CHANCE
	jumpifmove MOVE_SACRED_SWORD CRITICAL_CHANCE
	jumpifmove MOVE_HEAT_CRASH HEAT_CRASH
	jumpifmove MOVE_PSYSTRIKE PSYSTRIKE
	jumpifmove MOVE_TECHNO_BLAST CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_SECRET_SWORD SECRET_SWORD
	jumpifmove MOVE_FLYING_PRESS FLYING_PRESS
	jumpifmove MOVE_FELL_STINGER FELL_STINGER
	jumpifmove MOVE_PETAL_BLIZZARD CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_FREEZEDRY FREEZE_DRY
	jumpifmove MOVE_DISARMING_VOICE DISARMING_VOICE
	jumpifmove MOVE_FAIRY_WIND CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_BOOMBURST CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_HYPERSPACE_HOLE CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_DAZZLING_GLEAM CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_HOLD_BACK CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_LANDS_WRATH CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_ORIGIN_PULSE DRAGON_PULSE
	jumpifmove MOVE_PRECIPICE_BLADES CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_DARKEST_LARIAT CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_HIGH_HORSEPOWER CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_LEAFAGE CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_POWER_TRIP PUNISHMENT
	jumpifmove MOVE_SMART_STRIKE SMART_STRIKE
	jumpifmove MOVE_REVELATION_DANCE MOVE_REVELATION_DANCE
	jumpifmove MOVE_CORE_ENFORCER CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_INSTRUCT CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_BEAK_BLAST BEAK_BLAST
	jumpifmove MOVE_DRAGON_HAMMER CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_BRUTAL_SWING CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_SHELL_TRAP SHELL_TRAP
	jumpifmove MOVE_STOMPING_TANTRUM CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_ACCELEROCK NOT_PRIORITY
	jumpifmove MOVE_SUNSTEEL_STRIKE IGNORE_ABILITY
	jumpifmove MOVE_MOONGEIST_BEAM IGNORE_ABILITY
	jumpifmove MOVE_MULTI_ATTACK MULTI_ATTACK
	jumpifmove MOVE_BODY_PRESS CHECK_EFFECTIVENESS_GENERIC
	jumpifmove MOVE_ZIPPY_ZAP NOT_PRIORITY
	jumpifmove MOVE_CEASELESS_EDGE SHARPNESS
	jumpifmove MOVE_EXPANDING_FORCE EXPANDING_FORCE
	jumpifmove MOVE_PHOTON_GEYSER PHOTON_GEYSER
	jumpifmove MOVE_DRAGON_ENERGY HP_DAMAGE_HIGH
	jumpifmove MOVE_MISTY_EXPLOSION HP_DAMAGE_HIGH
	return_cmd

MISTY_EXPLOSION:
	checkability bank_target ABILITY_DAMP
	jumpifbytevarEQ 1 POINTS_MINUS30
    jumpiffieldaffecting FIELD_AFFECTING_PSYCHIC_TERRAIN POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PHOTON_GEYSER:
    checkability bank_target ABILITY_BATTLE_ARMOR
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_BIG_PECKS   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_BULLETPROOF 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_CLEAR_BODY  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DAMP        
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DRIZZLE     
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DRY_SKIN    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FILTER      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FLASH_FIRE  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FLOWER_GIFT 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FRIEND_GUARD
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HEATPROOF   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HEAVY_METAL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HYPER_CUTTER
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_IMMUNITY    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_INNER_FOCUS 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_INSOMNIA    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LEAF_GUARD  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LEVITATE    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LIGHT_METAL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LIMBER      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGIC_BOUNCE
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGMA_ARMOR 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGNET_PULL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MARVEL_SCALE
    jumpifbytevarEQ 1 POINTS_PLUS5             
    checkability bank_target ABILITY_MOTOR_DRIVE 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MULTISCALE  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_OBLIVIOUS   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_OWN_TEMPO   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_PASTEL_VEIL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_RAIN_DISH   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SAP_SIPPER  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHADOW_SHIELD
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHIELD_DUST 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SIMPLE      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHELL_ARMOR 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHIELD_DUST 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SOUNDPROOF  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STICKY_HOLD 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STORM_DRAIN 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STURDY      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SUCTION_CUPS
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_TANGLED_FEET
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_TELEPATHY   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_THICK_FAT   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_UNAWARE     
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_VITAL_SPIRIT
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_VOLT_ABSORB 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_ABSORB
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_BUBBLE
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_VEIL  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WHITE_SMOKE 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WONDER_GUARD
    jumpifbytevarEQ 1 POINTS_PLUS5
    jumpifstatbuffLT bank_ai STAT_ATK default_stat_stage-1 PG_LOW_ATTACK
    jumpifstatbuffLT bank_ai STAT_SP_ATK default_stat_stage-1 PG_LOW_SPATK
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PG_LOW_ATTACK:
    jumpifstatbuffLT bank_ai STAT_SP_ATK default_stat_stage-1 POINTS_MINUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PG_LOW_SPATK:
    jumpifstatbuffLT bank_ai STAT_ATK default_stat_stage-1 POINTS_MINUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

IGNORE_ABILITY:
    checkability bank_target ABILITY_BATTLE_ARMOR
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_BIG_PECKS   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_BULLETPROOF 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_CLEAR_BODY  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DAMP        
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DRIZZLE     
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_DRY_SKIN    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FILTER      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FLASH_FIRE  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FLOWER_GIFT 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_FRIEND_GUARD
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HEATPROOF   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HEAVY_METAL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_HYPER_CUTTER
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_IMMUNITY    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_INNER_FOCUS 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_INSOMNIA    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LEAF_GUARD  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LEVITATE    
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LIGHT_METAL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_LIMBER      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGIC_BOUNCE
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGMA_ARMOR 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MAGNET_PULL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MARVEL_SCALE
    jumpifbytevarEQ 1 POINTS_PLUS5             
    checkability bank_target ABILITY_MOTOR_DRIVE 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_MULTISCALE  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_OBLIVIOUS   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_OWN_TEMPO   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_PASTEL_VEIL 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_RAIN_DISH   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SAP_SIPPER  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHADOW_SHIELD
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHIELD_DUST 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SIMPLE      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHELL_ARMOR 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SHIELD_DUST 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SOUNDPROOF  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STICKY_HOLD 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STORM_DRAIN 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_STURDY      
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_SUCTION_CUPS
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_TANGLED_FEET
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_TELEPATHY   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_THICK_FAT   
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_UNAWARE     
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_VITAL_SPIRIT
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_VOLT_ABSORB 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_ABSORB
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_BUBBLE
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WATER_VEIL  
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WHITE_SMOKE 
    jumpifbytevarEQ 1 POINTS_PLUS5               
    checkability bank_target ABILITY_WONDER_GUARD
    jumpifbytevarEQ 1 POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

EXPANDING_FORCE:
    jumpiffieldaffecting FIELD_AFFECTING_PSYCHIC_TERRAIN POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BODY_PRESS:
    jumpifstatbuffLT bank_ai STAT_DEF default_stat_stage-1, POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+1, POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

MULTI_ATTACK:
    jumpiffieldaffecting FIELD_AFFECTING_ION_DELUGE POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MAGICROOM POINTS_MINUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SHELL_TRAP:
    hasanymovewithsplit bank_target SPLIT_PHYSICAL
    jumpifbytevarEQ 0x1 POINTS_MINUS3
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BRUTAL_SWING:
	isdoublebattle
    jumpifbytevarEQ 1 CHECK_ALLY_BS
	return_cmd
CHECK_ALLY_BS:
    jumpifhealthLT bank_aipartner 40 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BEAK_BLAST:
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

REVELATION_DANCE:
    jumpiffieldaffecting FIELD_AFFECTING_ION_DELUGE POINTS_MINUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SMART_STRIKE:
	jumpifstatus bank_target STATUS2_SUBSTITUTE POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HYPERSPACE_HOLE:
    getprotectuses bank_target
    jumpifbytevarGE 1 POINTS_PLUS2
	jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_PLUS2
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BOOMBURST:
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
	jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

DISARMING_VOICE:
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
    jumpifstatbuffGE bank_target STAT_EVASION default_stat_stage, POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FREEZE_DRY:
	isoftype bank_target TYPE_WATER
    jumpifbytevarNE 1 POINTS_PLUS3
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FELL_STINGER:
    jumpifwillfaint bank_ai bank_target POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FLYING_PRESS:
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS5
	jumpiffieldaffecting FIELD_AFFECTING_GRAVITY POINTS_MINUS30
	jumpifstatus3 bank_target STATUS3_MINIMIZED POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SECRET_SWORD:
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage-1, POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1, POINTS_PLUS3
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage+2, POINTS_MINUS3
	checkability bank_ai ABILITY_SHARPNESS
	jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PSYSTRIKE:
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage-1, POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1, POINTS_PLUS3
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage+2, POINTS_MINUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HEAT_CRASH:
    heavyslamweighttier bank_ai bank_target
    jumpifbytevarEQ 4 POINTS_PLUS10   @ Peso do usuário >=5x o do alvo (poder 120)
    jumpifbytevarEQ 3 POINTS_PLUS5    @ Peso do usuário 4x o do alvo (poder 100)
    jumpifbytevarEQ 2 POINTS_PLUS3    @ Peso do usuário 3x o do alvo (poder 80)
    jumpifbytevarEQ 1 POINTS_PLUS1    @ Peso do usuário 2x o do alvo (poder 60)
    jumpifbytevarEQ 0 POINTS_MINUS3   @ Peso do usuário <2x o do alvo (poder 40)
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
	jumpifstatus3 bank_target STATUS3_MINIMIZED POINTS_PLUS3
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SACRED_SWORD:
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage, POINTS_PLUS2
    jumpifstatbuffGE bank_target STAT_EVASION default_stat_stage, POINTS_PLUS2
	checkability bank_ai ABILITY_SHARPNESS
	jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FROST_BREATH:
	checkability bank_target ABILITY_BATTLE_ARMOR
	jumpifbytevarEQ 1 POINTS_MINUS30
	checkability bank_target ABILITY_SHELL_ARMOR
	jumpifbytevarEQ 1 POINTS_MINUS30
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW POINTS_PLUS2
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

ACROBATICS:
	jumpifitem bank_ai 0x0 POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HEX:
	jumpifstatus bank_target 0xFFFF POINTS_PLUS4
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

CHIP_AWAY:
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage, POINTS_PLUS2
    jumpifstatbuffGE bank_target STAT_EVASION default_stat_stage, POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
	
ECHOED_VOICE:
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_PLUS3
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
	getlastusedmove bank_target
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
	getlastusedmove bank_targetpartner
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
	getlastusedmove bank_aipartner
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_METRONOME POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

MOVE_ROUND:
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_PLUS3
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
	getlastusedmove bank_target
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
	getlastusedmove bank_targetpartner
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
	getlastusedmove bank_aipartner
    jumpifwordvarEQ MOVE_ROUND POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FOUL_PLAY:
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+1 POINTS_PLUS2
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+2 POINTS_PLUS4
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+3 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+4 POINTS_PLUS10
    jumpifstatbuffLT bank_target STAT_ATK default_stat_stage POINTS_MINUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

ELECTRO_BALL:
    electroballpowerlevel bank_ai bank_target
    jumpifbytevarEQ 4 POINTS_PLUS10   @ Muito forte (poder 150)
    jumpifbytevarEQ 3 POINTS_PLUS5    @ Forte (poder 120)
    jumpifbytevarEQ 2 POINTS_PLUS3    @ Ok (poder 80)
    jumpifbytevarEQ 1 POINTS_PLUS1    @ Fraco (poder 60)
    jumpifbytevarEQ 0 POINTS_MINUS5   @ Muito fraco (poder 40)
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HEAVY_SLAM:
    heavyslamweighttier bank_ai bank_target
    jumpifbytevarEQ 4 POINTS_PLUS10   @ Peso do usuário >=5x o do alvo (poder 120)
    jumpifbytevarEQ 3 POINTS_PLUS5    @ Peso do usuário 4x o do alvo (poder 100)
    jumpifbytevarEQ 2 POINTS_PLUS3    @ Peso do usuário 3x o do alvo (poder 80)
    jumpifbytevarEQ 1 POINTS_PLUS1    @ Peso do usuário 2x o do alvo (poder 60)
    jumpifbytevarEQ 0 POINTS_MINUS3   @ Peso do usuário <2x o do alvo (poder 40)
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

STORM_THROW:
	checkability bank_target ABILITY_BATTLE_ARMOR
	jumpifbytevarEQ 1 POINTS_MINUS30
	checkability bank_target ABILITY_SHELL_ARMOR
	jumpifbytevarEQ 1 POINTS_MINUS30
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW POINTS_PLUS2
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
VENOSHOCK:
	jumpifstatus bank_target STATUS_POISON | STATUS_BAD_POISON POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PSYSHOCK:
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1 POINTS_PLUS2
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage-1 POINTS_MINUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

JUDGMENT:
    jumpiffieldaffecting FIELD_AFFECTING_ION_DELUGE POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MAGICROOM POINTS_MINUS10
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_PLATES POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
GRASS_KNOT:
	grassknotweighttier bank_target
    jumpifbytevarEQ 5 POINTS_PLUS10   @ Peso altíssimo (poder 120)
    jumpifbytevarEQ 4 POINTS_PLUS5    @ Peso alto (poder 100)
    jumpifbytevarEQ 3 POINTS_PLUS3    @ Peso médio-alto (poder 80)
    jumpifbytevarEQ 2 POINTS_PLUS1    @ Peso médio (poder 60)
    jumpifbytevarEQ 1 POINTS_MINUS2   @ Peso baixo (poder 40)
    jumpifbytevarEQ 0 POINTS_MINUS10   @ Peso muito baixo (poder 20)
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BULLETPROOF_IMUNE_MORE_ALVO_SEMI_IVULNERAVEL:
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

AVALANCHE:
    jumpifstrikesfirst bank_target bank_ai POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

DRAGON_PULSE:
	checkability bank_ai ABILITY_MEGA_LAUNCHER
	jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SHARPNESS:
	checkability bank_ai ABILITY_SHARPNESS
	jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

AURA_SPHERE:
	checkability bank_ai ABILITY_MEGA_LAUNCHER
	jumpifbytevarEQ 1 POINTS_PLUS10
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PUNISHMENT:
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_target STAT_SP_ATK default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_target STAT_SPD default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_ai STAT_ACC default_stat_stage+1 PUNISHMENT_BOOST
    jumpifstatbuffGE bank_ai STAT_EVASION default_stat_stage+1 PUNISHMENT_BOOST
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PUNISHMENT_BOOST:
	scoreupdate +10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PAYBACK:
	getusedhelditem bank_target
	jumpifbytevarEQ 1 POINTS_PLUS10
    jumpifstrikesfirst bank_target bank_ai POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BRINE:
    jumpifhealthLT bank_target 50 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

GYRO_BALL:
    gyroballpowerlevel bank_ai bank_target
	jumpifbytevarEQ 3 POINTS_PLUS10    @ Gyro Ball muito forte!
    jumpifbytevarEQ 2 POINTS_PLUS5    @ Forte
    jumpifbytevarEQ 1 POINTS_PLUS3    @ Médio
    jumpifbytevarEQ 0 POINTS_MINUS5   @ Fraco
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

SKY_UPPERCUT:
	jumpifstatus3 bank_target STATUS3_ONAIR POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

BULLETPROOF_IMUNE:
	checkability bank_target ABILITY_SOUNDPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HP_DAMAGE_HIGH:
    jumpifhealthGE bank_ai 80 POINTS_PLUS5
    jumpifhealthGE bank_ai 50 POINTS_PLUS3
    jumpifhealthGE bank_ai 25 POINTS_MINUS2
    jumpifhealthLT bank_ai 25 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FACADE:
	jumpifstatus bank_target STATUS_POISON | STATUS_BAD_POISON | STATUS_PARALYSIS | STATUS_BURN POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

VITAL_THROW:
	jumpifhealthLT bank_ai 25 POINTS_MINUS8
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

PURSUIT:
    getlastusedmove bank_target
    jumpifwordvarEQ MOVE_BATON_PASS POINTS_PLUS5
    jumpifwordvarEQ MOVE_UTURN POINTS_PLUS5
    jumpifwordvarEQ MOVE_VOLT_SWITCH POINTS_PLUS5
    jumpifwordvarEQ MOVE_TELEPORT POINTS_PLUS5
    jumpifwordvarEQ MOVE_PARTING_SHOT POINTS_PLUS5
    jumpifwordvarEQ MOVE_CHILLY_RECEPTION POINTS_PLUS5
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

FRUSTRATION_DAMAGE:
    gethappiness bank_ai
    jumpifbytevarEQ 4 POINTS_MINUS8
    jumpifbytevarEQ 3 POINTS_MINUS3
    jumpifbytevarEQ 2 POINTS_PLUS3
    jumpifbytevarEQ 1 POINTS_PLUS5
    jumpifbytevarEQ 0 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

RETURN_DAMAGE:
    gethappiness bank_ai
    jumpifbytevarEQ 4 POINTS_PLUS10
    jumpifbytevarEQ 3 POINTS_PLUS5
    jumpifbytevarEQ 2 POINTS_PLUS3
    jumpifbytevarEQ 1 POINTS_MINUS3
    jumpifbytevarEQ 0 POINTS_MINUS8
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

HP_DAMAGE:
    jumpifhealthLT bank_ai 5 POINTS_PLUS10      @ HP <= 4%
    jumpifhealthLT bank_ai 11 POINTS_PLUS5     @ HP 5–10%
    jumpifhealthLT bank_ai 22 POINTS_PLUS3      @ HP 11–20%
    jumpifhealthLT bank_ai 44 POINTS_PLUS2      @ HP 21–40%
    jumpifhealthGE bank_ai 50 POINTS_MINUS8     @ HP >= 50%
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
CRITICAL_MORE_SHARPNESS:
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW POINTS_PLUS2
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS POINTS_PLUS2
	checkability bank_ai ABILITY_SHARPNESS
	jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
NOT_PRIORITY:
	checkability bank_target ABILITY_QUEENLY_MAJESTY
	jumpifbytevarEQ 1 POINTS_MINUS30
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
EGG_BOMB:
	checkability bank_target ABILITY_BULLETPROOF
	jumpifbytevarEQ 1 POINTS_MINUS30
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
EARTHQUAKE:
	isdoublebattle
    jumpifbytevarEQ 1 POINTS_MINUS5
    jumpiffieldaffecting FIELD_AFFECTING_GRASSY_TERRAIN POINTS_MINUS8
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
	jumpifstatus3 bank_target STATUS3_UNDERGROUND POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
ROCK_THROW:
	getitemeffect bank_ai 1
	jumpifbytevarEQ ITEM_EFFECT_WIDELENS POINTS_PLUS3
	jumpifbytevarEQ ITEM_EFFECT_ZOOMLENS POINTS_PLUS1
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
LOW_KICK:
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
CRITICAL_CHANCE:
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW POINTS_PLUS2
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS POINTS_PLUS2
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
GUST:
	getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC
ALVO_SEMI_IVULNERAVEL:
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_PLUS10
    goto_cmd CHECK_EFFECTIVENESS_GENERIC

CHECK_EFFECTIVENESS_GENERIC:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS3
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS8
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS30
    return_cmd
################################################################################################
DISCOURAGE_CONFUSE_STATCHANGE:
	getmoveid
    @ Verifica se o alvo já está confuso
    jumpifstatus2 bank_target STATUS2_CONFUSION POINTS_MINUS10
    @ Verifica Own Tempo
    checkability bank_target ABILITY_OWN_TEMPO
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Verifica Safeguard
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    @ Verifica se é Swagger (aumenta ATK do alvo)
    jumpifmove MOVE_SWAGGER CHECK_SWAGGER_CONDITIONS
    @ Verifica se é Flatter (aumenta SP_ATK do alvo)
    jumpifmove MOVE_FLATTER CHECK_FLATTER_CONDITIONS
    @ Caso padrão para outros movimentos de confusão
    return_cmd
CHECK_SWAGGER_CONDITIONS:
    @ Verifica se o ataque do alvo já está no máximo
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_ATK CHECK_MAX_ATK
    return_cmd
CHECK_MAX_ATK:
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_FLATTER_CONDITIONS:
    @ Verifica se o SP_ATK do alvo já está no máximo
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_SP_ATK CHECK_MAX_SPATK
    return_cmd
CHECK_MAX_SPATK:
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_LOSETYPE:
    jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    isoftype bank_ai TYPE_FIRE
    jumpifbytevarNE 1 POINTS_MINUS30
	gettypeinfo AI_TYPE1_TARGET @ 2. Penalizar se o Pokémon é Fire puro
	jumpifbytevarEQ TYPE_FIRE POINTS_MINUS10
	gettypeinfo AI_TYPE2_TARGET
	jumpifbytevarEQ TYPE_FIRE POINTS_MINUS10
    checkability bank_ai ABILITY_PROTEAN
    jumpifbytevarEQ 1 POINTS_PLUS10  @ Incentiva se o Pokémon tem Protean para recuperar o tipo
    jumpifmove bank_ai MOVE_REFLECT_TYPE
    jumpifbytevarEQ 1 POINTS_PLUS5   @ Incentiva se o Pokémon tem Reflect Type para recuperar o tipo
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se o tipo Fire é necessário para resistências
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10   @ Incentiva se o STAB Fire é essencial contra o adversário
    return_cmd  @ Finaliza a lógica
################################################################################################
DISCOURAGE_TWO_TURN:
    getmoveid  @ Obtém o ID do movimento
    jumpifhwordvarinlist istwoturnnotsemiinvulnerablemove CHECK_CAN_FAINT  @ Verifica se é um movimento de dois turnos não semi-invulnerável
    return_cmd  @ Se não for, retorna (não penaliza)

CHECK_CAN_FAINT:
    cantargetfaintuser 1  @ Verifica se o alvo pode nocautear o usuário (bank_ai)
    jumpifbytevarEQ 0x0 POINTS_MINUS10  @ Se puder, penaliza
    return_cmd  @ Se não puder, retorna chilly_reception_hail
################################################################################################
DISCOURAGE_AURORAVEIL:
    @ Verifica se Aurora Veil já está ativa
    jumpifnewsideaffecting bank_ai SIDE_AFFECTING_AURORAVEIL POINTS_MINUS10
    @ Verifica se o parceiro já escolheu Aurora Veil
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_AURORA_VEIL POINTS_MINUS10
    @ Verifica clima de hail/snow
    jumpifweather weather_hail | weather_permament_hail | chilly_reception_hail CHECK_END_AV
    goto_cmd NEGATIVE_AV

CHECK_END_AV:
    return_cmd

NEGATIVE_AV:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_STRENGTH_SAP:
    checkability bank_target ABILITY_CONTRARY
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Não pode baixar Atk por ability ou stat já minado
    checkability bank_target ABILITY_CLEAR_BODY
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FLOWER_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_GRASS
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_HYPER_CUTTER
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10
    jumpifsideaffecting bank_target SIDE_MIST POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_ATK 0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_LASERFOCUS:
    jumpifbankaffecting bank_ai BANK_AFFECTING_LASERFOCUS POINTS_MINUS10
    checkability bank_target ABILITY_SHELL_ARMOR
    jumpifbytevarEQ 1 POINTS_MINUS8
    checkability bank_target ABILITY_BATTLE_ARMOR
    jumpifbytevarEQ 1 POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_SKYDROP:
	gettypeinfo AI_TYPE1_TARGET
	jumpifbytevarEQ TYPE_FLYING POINTS_MINUS10 @ 1) Não usar em Pokémon de tipo puro Voador
	gettypeinfo AI_TYPE2_TARGET
	jumpifbytevarEQ TYPE_FLYING POINTS_MINUS10
    check_weather_faint @ 2) Não usar se o usuário vai desmaiar por clima no próximo turno
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_ai ABILITY_INFILTRATOR 1 @ 3) Não usar se o Substituto bloquear (a menos que tenha Infiltrator)
    jumpifbytevarEQ 1 SKIP_SUBSTITUTE_CHECK
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10
SKIP_SUBSTITUTE_CHECK:
    @ 4) Se o peso do alvo é >= 2000 (200.0 kg)
    checkpokeweight bank_target
    jumpifbytevarGE 1 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_SHIFTGEAR:
    @ Primeira condição: Ataque no máximo OU sem movimentos físicos
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_ATK CHECK_ATK_CONDITION
    return_cmd
CHECK_ATK_CONDITION:
    jumpifbytevarEQ max_stat_stage PHYSICAL_MOVE_CHECK  @ Ataque já no máximo
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 PHYSICAL_MOVE_CHECK_FAILED
    goto_cmd CHECK_SPEED_CONDITION
PHYSICAL_MOVE_CHECK_FAILED:
PHYSICAL_MOVE_CHECK:
    goto_cmd NEGATIVE_SG
CHECK_SPEED_CONDITION:
    @ Verifica condição da velocidade
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_SPD CHECK_SPD_MAX
    return_cmd
CHECK_SPD_MAX:
    jumpifbytevarEQ max_stat_stage POINTS_MINUS8
    return_cmd

NEGATIVE_SG:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_SHELLSMASH:
    if_ability bank_ai ABILITY_CONTRARY DISCOURAGE_SHELLSMASH_CONTRARY
    @ Caso normal (não Contrary)
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_ATK_MOVES
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage CHECK_SPATK_MOVES
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS5
    return_cmd

CHECK_ATK_MOVES:
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_SPATK_MOVES:
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS8
    return_cmd

DISCOURAGE_SHELLSMASH_CONTRARY:
    @ Caso Contrary
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_TARGETSTAT_CHANCE:
    getmoveid                                             		    @ Obtém o movimento atual
    jumpifwordvarEQ MOVE_ACID            CHANCE_10_SP_DEF 		    @ Acid: 10%
    jumpifwordvarEQ MOVE_PSYCHIC         CHANCE_10_SP_DEF 		    @ Psychic: 10%
    jumpifwordvarEQ MOVE_SHADOW_BALL     CHANCE_20_SP_DEF		    @ Shadow Ball: 20%
    jumpifwordvarEQ MOVE_LUSTER_PURGE    CHANCE_50_SP_DEF		    @ Luster Purge: 50%
    jumpifwordvarEQ MOVE_BUG_BUZZ        CHANCE_10_SP_DEF 		    @ Bug Buzz: 10%
    jumpifwordvarEQ MOVE_FOCUS_BLAST     CHANCE_10_SP_DEF           @ Focus Blast: 10%
    jumpifwordvarEQ MOVE_ENERGY_BALL     CHANCE_10_SP_DEF 		    @ Energy Ball: 10%
    jumpifwordvarEQ MOVE_EARTH_POWER     CHANCE_10_SP_DEF  			@ Earth Power: 10%
    jumpifwordvarEQ MOVE_FLASH_CANNON    CHANCE_10_SP_DEF			@ Flash Cannon: 10%
    jumpifwordvarEQ MOVE_SEED_FLARE      CHANCE_40_SP_DEF           @ Seed Flare: 40%
    jumpifwordvarEQ MOVE_ACID_SPRAY      REDUZ_SPECIAL_DEFENSE	    @ Acid Spray: 100%
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    jumpifwordvarEQ MOVE_BUBBLE          CHANCE_10_SPEED            @ Bubble: 10%
    jumpifwordvarEQ MOVE_BUBBLE_BEAM     CHANCE_10_SPEED            @ Bubble Beam: 10%
    jumpifwordvarEQ MOVE_ICY_WIND        REDUZ_SPEED	            @ Icy Wind: 100%
    jumpifwordvarEQ MOVE_LOW_SWEEP       REDUZ_SPEED    	        @ Low Sweep: 100%
    jumpifwordvarEQ MOVE_BULLDOZE        REDUZ_SPEED        	    @ Bulldoze: 100%
    jumpifwordvarEQ MOVE_ELECTROWEB      REDUZ_SPEED	            @ Electro Web: 100%
    jumpifwordvarEQ MOVE_GLACIATE        REDUZ_SPEED	            @ Glaciate: 100%
    jumpifwordvarEQ MOVE_CONSTRICT       CHANCE_10_SPEED	        @ Constrict: 10%
    jumpifwordvarEQ MOVE_ROCK_TOMB       REDUZ_SPEED	            @ Rock Tomb: 100%
    jumpifwordvarEQ MOVE_MUD_SHOT        REDUZ_SPEED	            @ Mud-Shot: 100%
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    jumpifwordvarEQ MOVE_AURORA_BEAM     CHANCE_10_ATTACK           @ Aurora Beam: 10%
    jumpifwordvarEQ MOVE_TROP_KICK       REDUZ_ATTACK 	            @ Trop Kick: 100%
    jumpifwordvarEQ MOVE_LUNGE           REDUZ_ATTACK 	            @ Lunge: 100%
    jumpifwordvarEQ MOVE_PLAY_ROUGH      CHANCE_10_ATTACK           @ Play Rough: 10%
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    jumpifwordvarEQ MOVE_MUDSLAP         REDUZ_ACCURACY             @ Mud-Slap: 100%
    jumpifwordvarEQ MOVE_MUD_BOMB        CHANCE_30_ACCURACY         @ Mud Bomb: 30%
    jumpifwordvarEQ MOVE_OCTAZOOKA       CHANCE_50_ACCURACY         @ Octazooka: 50%
    jumpifwordvarEQ MOVE_MUDDY_WATER     CHANCE_30_ACCURACY         @ Muddy Water: 30%
    jumpifwordvarEQ MOVE_MIRROR_SHOT     CHANCE_30_ACCURACY         @ Mirror Shot: 30%
    jumpifwordvarEQ MOVE_LEAF_TORNADO    CHANCE_30_ACCURACY         @ Leaf Tornado: 30%
    jumpifwordvarEQ MOVE_NIGHT_DAZE      CHANCE_40_ACCURACY         @ Night Daze: 40%
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    jumpifwordvarEQ MOVE_IRON_TAIL       CHANCE_30_DEFENSE          @ Iron Tail: 30%
    jumpifwordvarEQ MOVE_SHADOW_BONE     CHANCE_20_DEFENSE          @ Shadow Bone: 20%
    jumpifwordvarEQ MOVE_LIQUIDATION     CHANCE_20_DEFENSE          @ Liquidation: 20%
    jumpifwordvarEQ MOVE_THUNDEROUS_KICK REDUZ_DEFENSE          	@ Thunderous Kick: 100%
    jumpifwordvarEQ MOVE_CRUNCH          CHANCE_20_DEFENSE          @ Crunch: 20%
    jumpifwordvarEQ MOVE_ROCK_SMASH      CHANCE_50_DEFENSE          @ Rock Smash: 50%
    jumpifwordvarEQ MOVE_CRUSH_CLAW      CHANCE_50_DEFENSE          @ Crush Claw: 50%
    jumpifwordvarEQ MOVE_FIRE_LASH       REDUZ_DEFENSE          	@ Fire Lash: 100%
    jumpifwordvarEQ MOVE_RAZOR_SHELL     CHANCE_50_DEFENSE          @ Razor Shell: 50%
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    jumpifwordvarEQ MOVE_MIST_BALL       CHANCE_50_SPECIAL_ATTACK   @ Mist Ball: 50%
    jumpifwordvarEQ MOVE_STRUGGLE_BUG    REDUZ_SPECIAL_ATTACK   	@ Struggle Bug: 100%
    jumpifwordvarEQ MOVE_MOONBLAST       CHANCE_30_SPECIAL_ATTACK   @ Moonblast: 30%
    jumpifwordvarEQ MOVE_MYSTICAL_FIRE   REDUZ_SPECIAL_ATTACK   	@ Mystical Fire: 100%
    jumpifwordvarEQ MOVE_SNARL           REDUZ_SPECIAL_ATTACK   	@ Snarl: 100%
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_10_SP_DEF:
    jumpifrandLT 10 REDUZ_SPECIAL_DEFENSE
    return_cmd
CHANCE_20_SP_DEF:
    jumpifrandLT 20 REDUZ_SPECIAL_DEFENSE
    return_cmd
CHANCE_40_SP_DEF:
    jumpifrandLT 40 REDUZ_SPECIAL_DEFENSE
    return_cmd
CHANCE_50_SP_DEF:
    jumpifrandLT 50 REDUZ_SPECIAL_DEFENSE
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_10_SPEED:
    jumpifrandLT 10 REDUZ_SPEED
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_10_ATTACK:
    jumpifrandLT 10 REDUZ_ATTACK
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_30_ACCURACY:
    jumpifrandLT 30 REDUZ_ACCURACY
    return_cmd
CHANCE_40_ACCURACY:
    jumpifrandLT 40 REDUZ_ACCURACY
    return_cmd
CHANCE_50_ACCURACY:
    jumpifrandLT 50 REDUZ_ACCURACY
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_20_DEFENSE:
    jumpifrandLT 20 REDUZ_DEFENSE
    return_cmd
CHANCE_30_DEFENSE:
    jumpifrandLT 30 REDUZ_DEFENSE
    return_cmd
CHANCE_50_DEFENSE:
    jumpifrandLT 50 REDUZ_DEFENSE
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CHANCE_30_SPECIAL_ATTACK:
    jumpifrandLT 30 REDUZ_SPECIAL_ATTACK
    return_cmd
CHANCE_50_SPECIAL_ATTACK:
    jumpifrandLT 50 REDUZ_SPECIAL_ATTACK
    return_cmd
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
REDUZ_ATTACK:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_ATK 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_ATK 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 REDUZ_ATTACK_CONTRARY
    return_cmd

REDUZ_ATTACK_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_ATK 8  POINTS_MINUS3
    return_cmd

REDUZ_DEFENSE:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_DEF 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_DEF 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 REDUZ_DEFENSE_CONTRARY
    return_cmd

REDUZ_DEFENSE_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_DEF 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_DEF 8  POINTS_MINUS3
    return_cmd

REDUZ_SPECIAL_DEFENSE:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_SP_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_DEF 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_SP_DEF 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 SPECIAL_DEFENSE_CONTRARY
    return_cmd

SPECIAL_DEFENSE_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_SP_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_SP_DEF 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_SP_DEF 8  POINTS_MINUS3
    return_cmd

REDUZ_SPEED:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_SPD min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SPD 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_SPD 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 REDUZ_SPEED_CONTRARY
    return_cmd

REDUZ_SPEED_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_SPD max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_SPD 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_SPD 8  POINTS_MINUS3
    return_cmd

REDUZ_SPECIAL_ATTACK:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_ATK 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_SP_ATK 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 REDUZ_SPECIAL_ATTACK_CONTRARY
    return_cmd

REDUZ_SPECIAL_ATTACK_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_SP_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_SP_ATK 8  POINTS_MINUS3
    return_cmd

REDUZ_ACCURACY:
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_target STAT_ACC min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_ACC 2 POINTS_MINUS5
    jumpifstatbuffLT bank_target STAT_ACC 4 POINTS_MINUS3
    affected_by_substitute
    jumpifbytevarEQ 1 RETURN_CMD_TARGETSTAT_CHANCE
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 REDUZ_ACCURACY_CONTRARY
    return_cmd

REDUZ_ACCURACY_CONTRARY:
    jumpifstatbuffEQ bank_target STAT_ACC max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_target STAT_ACC 10 POINTS_MINUS5
    jumpifstatbuffGE bank_target STAT_ACC 8 POINTS_MINUS3
    return_cmd

RETURN_CMD_TARGETSTAT_CHANCE:
    return_cmd
################################################################################################
DISCOURAGE_MULTIPLESTATSCHANGE:
    canmultiplestatwork
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    @ Verifica primeiro se é movescript 6 (usuário) ou 7 (alvo)
    getmovescript
    jumpifbytevarEQ 6 CHECK_USER_MULTISTAT
    jumpifbytevarEQ 7 CHECK_TARGET_MULTISTAT
    return_cmd
CHECK_USER_MULTISTAT:
    @ Verifica movimentos específicos do usuário
    getmoveid
    jumpifwordvarEQ MOVE_GROWTH CHECK_GROWTH
    jumpifwordvarEQ MOVE_COSMIC_POWER CHECK_COSMIC_POWER
    jumpifwordvarEQ MOVE_BULK_UP CHECK_BULK_UP
    jumpifwordvarEQ MOVE_CALM_MIND CHECK_CALM_MIND
    jumpifwordvarEQ MOVE_DRAGON_DANCE CHECK_DRAGON_DANCE
    jumpifwordvarEQ MOVE_DEFEND_ORDER CHECK_DEFEND_ORDER
    jumpifwordvarEQ MOVE_HONE_CLAWS CHECK_HONE_CLAWS
    jumpifwordvarEQ MOVE_QUIVER_DANCE CHECK_QUIVER_DANCE
    jumpifwordvarEQ MOVE_COIL CHECK_COIL
    jumpifwordvarEQ MOVE_WORK_UP CHECK_WORK_UP
	jumpifwordvarEQ MOVE_VICTORY_DANCE CHECK_VICTORY_DANCE
    return_cmd
CHECK_TARGET_MULTISTAT:
    @ Verifica movimentos específicos no alvo
    getmoveid
    jumpifwordvarEQ MOVE_TICKLE CHECK_TICKLE
    jumpifwordvarEQ MOVE_NOBLE_ROAR CHECK_NOBLE_ROAR
    jumpifwordvarEQ MOVE_TEARFUL_LOOK CHECK_TEARFUL_LOOK
    return_cmd
@ Implementações específicas para cada movimento
CHECK_GROWTH:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_GROWTH_SPATK
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage CHECK_GROWTH_DAMAGE
    return_cmd
CHECK_GROWTH_SPATK:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_GROWTH_DAMAGE:
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 1 CHECK_GROWTH_SPECIAL
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_GROWTH_SPECIAL:
    return_cmd
CHECK_COSMIC_POWER:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS8
    return_cmd
CHECK_BULK_UP:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_BULK_UP_DEF
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_BULK_UP_DEF:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_TICKLE:
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage CHECK_TICKLE_DEF
    jumpifstatbuffEQ bank_target STAT_DEF min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_TICKLE_DEF:
    jumpifstatbuffEQ bank_target STAT_DEF min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_NOBLE_ROAR:
    jumpifstatbuffEQ bank_target STAT_SP_ATK min_stat_stage CHECK_NOBLE_ROAR_ATK
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_NOBLE_ROAR_ATK:
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_TEARFUL_LOOK:
    @ Verifica se o ataque já está no mínimo
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage CHECK_TEARFUL_LOOK_SPATK
    jumpifstatbuffEQ bank_target STAT_SP_ATK min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_TEARFUL_LOOK_SPATK:
    jumpifstatbuffEQ bank_target STAT_SP_ATK min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_CALM_MIND:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage CHECK_CALM_MIND_SPDEF
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS8
    return_cmd
CHECK_CALM_MIND_SPDEF:
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_DRAGON_DANCE:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_DRAGON_DANCE_SPD
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_DRAGON_DANCE_SPD:
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_DEFEND_ORDER:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage CHECK_DEFEND_ORDER_SPDEF
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS8
    return_cmd
CHECK_DEFEND_ORDER_SPDEF:
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_HONE_CLAWS:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_ATK max_stat_stage CHECK_HONE_CLAWS_ACC
    jumpifstatbuffEQ bank_ai STAT_ACC max_stat_stage POINTS_MINUS10
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_HONE_CLAWS_ACC:
    jumpifstatbuffEQ bank_ai STAT_ACC max_stat_stage POINTS_MINUS8
    return_cmd
CHECK_QUIVER_DANCE:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage CHECK_QUIVER_DANCE_SPD
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_QUIVER_DANCE_SPD:
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage CHECK_QUIVER_DANCE_SPDEF
    return_cmd
CHECK_QUIVER_DANCE_SPDEF:
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_COIL:
    jumpifstatbuffEQ bank_ai STAT_ACC max_stat_stage CHECK_COIL_ATK
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_COIL_DEF
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS8
    return_cmd
CHECK_COIL_ATK:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_COIL_DEF
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_COIL_DEF:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_WORK_UP:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_WORK_UP_SPATK
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage CHECK_WORK_UP_DAMAGE
    return_cmd
CHECK_WORK_UP_SPATK:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    return_cmd
CHECK_WORK_UP_DAMAGE:
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL | SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
CHECK_VICTORY_DANCE:
    @ 1ª condição: ATK no máximo OU sem movimentos físicos
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_VICTORY_SPEED
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
CHECK_VICTORY_SPEED:
    @ 2ª condição: Velocidade não pode aumentar
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage CHECK_VICTORY_DEF
    return_cmd
CHECK_VICTORY_DEF:
    @ 3ª condição: DEF não pode aumentar
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_FLAMEBURST:
    jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    isdoublebattle
	jumpifbytevarGE 1 POINTS_PLUS5  @ Incentiva se há múltiplos alvos (batalhas duplas/triplas)
    checkability bank_target ABILITY_FLASH_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS12  @ Penaliza se o alvo tem Flash Fire
    checkability bank_target ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 POINTS_MINUS12  @ Penaliza se o alvo tem Flash Fire
    checkability bank_targetpartner ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 POINTS_MINUS12  @ Penaliza se o alvo tem Flash Fire
    @ 3. Verificar o HP dos Pokémon no campo
    jumpifhealthLT bank_target 25 POINTS_PLUS5  @ Incentiva se o HP dos Pokémon adjacentes é baixo (<25%)
    jumpifhealthLT bank_targetpartner 25 POINTS_PLUS5  @ Incentiva se o HP dos Pokémon adjacentes é baixo (<25%)
    @ 4. Considerar habilidades/status do alvo principal
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10  @ Penaliza se o alvo usa Substitute
    return_cmd  @ Finaliza a lógica
################################################################################################
DISCOURAGE_DAMAGETRAP:
    jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    @ 1. Verificar habilidades ou status que anulam o efeito de "trapping"
    checkability bank_target ABILITY_RUN_AWAY
    jumpifbytevarEQ 1 POINTS_MINUS10  @ Penaliza se o alvo tem Run Away
	getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_SHEDSHELL POINTS_MINUS10
    checkability bank_target ABILITY_SHADOW_TAG
    jumpifbytevarEQ 1 POINTS_MINUS5   @ Penaliza se o alvo tem Shadow Tag
    jumpifstatus2 bank_target STATUS2_WRAPPED POINTS_MINUS5  @ Penaliza se o alvo já está preso (ex.: Wrap)
    @ 2. Penalizar se o alvo é imune ou resistente ao golpe
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penaliza fortemente se o alvo é imune
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se o golpe é pouco eficaz
    @ 4. Evitabilidade do alvo
    jumpifstatus2 bank_target STATUS2_TRAPPED | STATUS2_WRAPPED POINTS_MINUS10  @ Penaliza se o alvo já está preso por outro efeito
    return_cmd  @ Finaliza a lógica
################################################################################################
DISCOURAGE_SWITCH: 
	checkability bank_target ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_CIRCLE_THROW POINTS_MINUS10
    jumpifwordvarEQ MOVE_DRAGON_TAIL POINTS_MINUS10
    @ 2. O alvo está com menos de 10% de HP e vai morrer por dano residual?
    jumpifhealthLT bank_target 10 CHECK_SECONDARY_DAMAGE
    goto_cmd CHECK_PERISH_SONG

CHECK_SECONDARY_DAMAGE:
	jumpifstatus2 bank_target STATUS2_CURSED POINTS_MINUS10
	jumpifstatus2 bank_target STATUS2_NIGHTMARE POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_TRAPPED | STATUS2_WRAPPED POINTS_MINUS10
	jumpifstatus3 bank_target STATUS3_ROOTED POINTS_MINUS10
	jumpifstatus bank_target STATUS_BAD_POISON | STATUS_POISON POINTS_MINUS10
    jumpifweather weather_permament_sandstorm | weather_sandstorm CHECK_SANDSTORM_IMMUNITY
    jumpifweather weather_permament_hail | weather_hail CHECK_HAIL_IMMUNITY
    goto_cmd CHECK_PERISH_SONG
CHECK_SANDSTORM_IMMUNITY:
    isoftype bank_target TYPE_ROCK | TYPE_STEEL | TYPE_GROUND 
    jumpifbytevarEQ 1 CONTINUE_HAIL_CHECK
    checkability bank_target ABILITY_OVERCOAT
    jumpifbytevarEQ 1 CONTINUE_HAIL_CHECK
    checkability bank_target ABILITY_SAND_VEIL
    jumpifbytevarEQ 1 CONTINUE_HAIL_CHECK
	getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_SAFETYGOOGLES CHECK_PERISH_SONG
    jumpifbytevarEQ 1 CONTINUE_HAIL_CHECK
	jumpifstatus3 bank_target STATUS3_UNDERGROUND | STATUS3_UNDERWATER CONTINUE_HAIL_CHECK
    @ Se chegou aqui, o alvo toma dano de sandstorm
    goto_cmd NEGATIVE_SW
CONTINUE_HAIL_CHECK:
    jumpifweather weather_permament_hail | weather_hail CHECK_HAIL_IMMUNITY
    goto_cmd CHECK_PERISH_SONG
CHECK_HAIL_IMMUNITY:
    isoftype bank_target TYPE_ICE 
    jumpifbytevarEQ 1 CHECK_PERISH_SONG
    checkability bank_target ABILITY_OVERCOAT
    jumpifbytevarEQ 1 CHECK_PERISH_SONG
    checkability bank_target ABILITY_ICE_BODY
    jumpifbytevarEQ 1 CHECK_PERISH_SONG
	getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_SAFETYGOOGLES CHECK_PERISH_SONG
	jumpifstatus3 bank_target STATUS3_UNDERGROUND | STATUS3_UNDERWATER CHECK_PERISH_SONG
    @ Se chegou aqui, o alvo toma dano de hail
    goto_cmd NEGATIVE_SW
CHECK_PERISH_SONG:
    jumpifstatus3 bank_target STATUS3_PERISHSONG POINTS_MINUS10
    return_cmd
NEGATIVE_SW:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_FINAL_GAMBIT:
    countalivepokes bank_ai            @ Verifica se a IA tem Pokémon utilizáveis
    jumpifbytevarEQ 0x0 POINTS_MINUS10 @ Se não houver, penaliza -10
    getpartnerchosenmove               @ Obtém o movimento escolhido pelo parceiro
    jumpifwordvarEQ MOVE_FINAL_GAMBIT POINTS_MINUS10 @ Se for Final Gambit, penaliza -10
    return_cmd
################################################################################################
DISCOURAGE_PLEDGE:
	getmoveid
    jumpifnotdoublebattle END_PLEDGE @ 1. Verifica se é batalha dupla
    isbankpresent bank_aipartner @ 2. Verifica se o parceiro está vivo
    jumpifbytevarEQ 0 END_PLEDGE
    getpartnerchosenmove @ 3. Obtém movimento do parceiro e verifica se é Pledge
    jumpifwordvarEQ 0 END_PLEDGE @ Se nenhum movimento, sai
    jumpifmove MOVE_WATER_PLEDGE CHECK_DIFF
    jumpifmove MOVE_FIRE_PLEDGE CHECK_DIFF
    jumpifmove MOVE_GRASS_PLEDGE CHECK_DIFF
    goto_cmd END_PLEDGE
CHECK_DIFF: @ 4. Compara movimento atual com o do parceiro
    getmoveid                     @ Move atual → var1
    vartovar2                     @ Salva var1 em var2
    getpartnerchosenmove          @ Move do parceiro → var1
    jumpifvarsEQ END_PLEDGE       @ Se iguais, não penaliza
	@ 5. Verifica status do parceiro (sono, congelamento ou paralizia)
    jumpifstatus bank_aipartner STATUS_SLEEP | STATUS_FREEZE | STATUS_PARALYSIS APPLY_PENALTY_PLEDGE
    goto_cmd END_PLEDGE
APPLY_PENALTY_PLEDGE:
    scoreupdate -10               @ Penaliza -10 pontos
END_PLEDGE:
    return_cmd
################################################################################################
DISCOURAGE_THAT_MAY_FAIL:
    jumpifcantusemove POINTS_MINUS10
    getmovescript
    jumpifbytevarEQ 165 DISCOURAGE_MAGNETIC_FLUX  @ Magnetic Flux/Gear Up
    return_cmd
DISCOURAGE_MAGNETIC_FLUX:
    getmoveid
    jumpifwordvarEQ MOVE_GEAR_UP DISCOURAGE_GEAR_UP
    @ Magnetic Flux specific checks
    if_ability bank_ai ABILITY_PLUS CHECK_MAGNETIC_FLUX_STATS
    if_ability bank_ai ABILITY_MINUS CHECK_MAGNETIC_FLUX_STATS
    jumpifnotdoublebattle POINTS_MINUS10
    if_ability bank_aipartner ABILITY_PLUS CHECK_PARTNER_MAGNETIC_FLUX
    if_ability bank_aipartner ABILITY_MINUS CHECK_PARTNER_MAGNETIC_FLUX
    goto_cmd NEGATIVE_TMF
CHECK_MAGNETIC_FLUX_STATS:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_DEF CHECK_MAGNETIC_FLUX_SPDEF
    goto_cmd NEGATIVE_TMF
CHECK_MAGNETIC_FLUX_SPDEF:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_SP_DEF POINTS_MINUS8
    goto_cmd NEGATIVE_TMF
CHECK_PARTNER_MAGNETIC_FLUX:
    getstatvaluemovechanges bank_aipartner
    jumpifbytevarEQ STAT_DEF CHECK_PARTNER_MAGNETIC_FLUX_SPDEF
    goto_cmd NEGATIVE_TMF
CHECK_PARTNER_MAGNETIC_FLUX_SPDEF:
    getstatvaluemovechanges bank_aipartner
    jumpifbytevarEQ STAT_SP_DEF POINTS_MINUS8
    goto_cmd NEGATIVE_TMF
DISCOURAGE_GEAR_UP:
    @ Similar structure to Magnetic Flux but for ATK/SPATK
    if_ability bank_ai ABILITY_PLUS CHECK_GEAR_UP_STATS
    if_ability bank_ai ABILITY_MINUS CHECK_GEAR_UP_STATS
    jumpifnotdoublebattle POINTS_MINUS10
    if_ability bank_aipartner ABILITY_PLUS CHECK_PARTNER_GEAR_UP
    if_ability bank_aipartner ABILITY_MINUS CHECK_PARTNER_GEAR_UP
    goto_cmd NEGATIVE_TMF
CHECK_GEAR_UP_STATS:
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS8
    return_cmd
CHECK_PARTNER_GEAR_UP:
    hasanymovewithsplit bank_aipartner SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    hasanymovewithsplit bank_aipartner SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS8
    return_cmd
NEGATIVE_TMF:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_TOPSY_TURVY:
    jumpiftargetisally END_LOCATION
    @ 1) Se não há NENHUM estágio positivo (> default_stat_stage), penaliza -10
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_SPD default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_SP_ATK default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_ACC default_stat_stage+1 SKIP_NO_NEG_CHECK
    jumpifstatbuffGE bank_target STAT_EVASION default_stat_stage+1 SKIP_NO_NEG_CHECK
    scoreupdate -10
    return_cmd
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_TOPSYTURVY POINTS_MINUS10
SKIP_NO_NEG_CHECK:
    @ 2) Agora, se NÃO há NENHUM estágio negativo (< default_stat_stage), 
    @    significa que negativeCount==0 < positiveCount>=1 → penaliza -5
    jumpifstatbuffLT bank_target STAT_ATK default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_SPD default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_SP_ATK default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_SP_DEF default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_ACC default_stat_stage END_LOCATION
    jumpifstatbuffLT bank_target STAT_EVASION default_stat_stage END_LOCATION
    scoreupdate -5
    return_cmd
################################################################################################
DISCOURAGE_HITS_MULTIPLE_TIMES:
    getmoveid                          @ Obtém o ID do movimento atual
    jumpifmove MOVE_DOUBLE_SLAP CHECK_DOUBLE_SLAP  @ Verifica se é Double Slap Obs: Quebra Substitute e só hita 1 vez após isso.
    jumpifmove MOVE_BONE_RUSH CHECK_BONE_RUSH      @ Verifica se é Bone Rush
    jumpifmove MOVE_COMET_PUNCH CHECK_DOUBLE_SLAP  @ Verifica se é Comet Punch Obs: Quebra Substitute e só hita 1 vez após isso.
    jumpifmove MOVE_BARRAGE CHECK_BARRAGE		   @ Verifica se é Barrage Obs: Não tem efeito em alvos com Bulletproof, e o mesmo caso com Substitute
    jumpifmove MOVE_FURY_SWIPES CHECK_DOUBLE_SLAP  @ Verifica se é Fury Swipes Obs: Quebra Substitute e só hita 1 vez após isso.
    jumpifmove MOVE_ARM_THRUST CHECK_BONE_RUSH	   @ Verifica se é Arm Thrust
    jumpifmove MOVE_BULLET_SEED CHECK_BULLET_SEED  @ Verifica se é Bullet Seed Obs: Não tem efeito em alvos com Bulletproof
    jumpifmove MOVE_ROCK_BLAST CHECK_ROCK_BLAST	   @ Verifica se é Rock Blast
    jumpifmove MOVE_TAIL_SLAP CHECK_BONE_RUSH	   @ Verifica se é Tail Slap
    jumpifmove MOVE_WATER_SHURIKEN CHECK_WS		   @ Verifica se é Rock Blast  Obs: Não tem efeito em alvos com Bulletproof
    return_cmd									   @ Retorna se não for um golpe multi-hit registrado

CHECK_DOUBLE_SLAP:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS5
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS8 @ 4. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd

CHECK_BONE_RUSH:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS5
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd

CHECK_BARRAGE:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS5
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_BULLETPROOF 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS30
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS8 @ 4. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd

CHECK_BULLET_SEED:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_BULLETPROOF 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS30
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS8 @ 4. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd

CHECK_ROCK_BLAST:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_BULLETPROOF 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS30
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS8 @ 4. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd

CHECK_WS:
    isoftype bank_target TYPE_GHOST   @ 1. Verificar se o alvo é do tipo Ghost (imune a golpes de contato)
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30 @ Se Ghost, penaliza
    getmoveaccuracy @ 2. Penalizar se precisão do movimento for baixa (Double Slap tem 85% de precisão)
    jumpifbytevarLT 85 POINTS_MINUS5  @ Se precisão < 85%, penaliza
	checkability bank_ai ABILITY_SKILL_LINK 0 @ 3. Se tiver Skill Link, encoraja o uso do golpe
    jumpifbytevarEQ 1 POINTS_PLUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    checkability bank_target ABILITY_MULTISCALE 0 @ desencorajar por motivos obvios
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WATER_COMPACTION 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS12
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS8 @ 4. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS5  @ Penalidade leve para eficácia abaixo do normal
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30   @ Penalidade severa para imunidade
    getbestdamagelefthp bank_ai bank_target @ 6. Verificar se o alvo está com HP baixo (menos de 30%)
    jumpifbytevarLT 30 POINTS_MINUS12
    return_cmd
################################################################################################
DISCOURAGE_PERISHSONG:
    jumpifstatus3 bank_target STATUS3_PERISHSONG POINTS_MINUS10 @ Penaliza se o alvo já está sob Perish Song
    getability bank_target @ Penaliza se o alvo tem Soundproof (golpe será inútil)
    jumpifbytevarEQ ABILITY_SOUNDPROOF POINTS_MINUS10
    getpartnerchosenmove @ Penaliza se o parceiro tem o mesmo movimento
    vartovar2
    getmoveid
    jumpifvarsEQ POINTS_MINUS10
    isbankpresent bank_aipartner @ Verificações extras em batalhas em dupla
    jumpifbytevarEQ 0 CHECK_SOLO_PERISH_LOGIC
    @ Se o usuário não tem Pokémon restantes e não tem Soundproof em si nem no parceiro e o inimigo ainda tem Pokémon
    countalivepokes bank_ai
    jumpifbytevarEQ 0 PERISH_NO_POKES_LEFT
CHECK_ENEMY_PERISH:
    jumpifstatus3 bank_target STATUS3_PERISHSONG ENEMY_1_DONE
    getability bank_target
    jumpifbytevarEQ ABILITY_SOUNDPROOF ENEMY_1_DONE
ENEMY_1_DONE:
    isbankpresent bank_targetpartner
    jumpifbytevarEQ 0 return_label
    jumpifstatus3 bank_targetpartner STATUS3_PERISHSONG ENEMY_2_DONE
    getability bank_targetpartner
    jumpifbytevarEQ ABILITY_SOUNDPROOF ENEMY_2_DONE
    goto_cmd return_label
ENEMY_2_DONE:
    goto_cmd NEGATIVE_PS @ Ambos inimigos já estão afetados ou imunes — golpe será redundante
PERISH_NO_POKES_LEFT:
    getability bank_ai
    jumpifbytevarEQ ABILITY_SOUNDPROOF CHECK_PARTNER_SOUNDPROOF
    goto_cmd return_label
CHECK_PARTNER_SOUNDPROOF:
    getability bank_aipartner
    jumpifbytevarNE ABILITY_SOUNDPROOF POINTS_MINUS10
CHECK_SOLO_PERISH_LOGIC:
    @ Em batalhas solo: se o usuário não tem pokémon restantes e não tem Soundproof, e o inimigo ainda tem, penaliza
    countalivepokes bank_ai
    jumpifbytevarNE 0 return_label
    getability bank_ai
    jumpifbytevarEQ ABILITY_SOUNDPROOF return_label
    countalivepokes bank_target
    jumpifbytevarEQ 0 return_label
    goto_cmd NEGATIVE_PS
return_label:
    return_cmd
NEGATIVE_PS:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_SANDSTORM:
    jumpifweather weather_permament_sandstorm | weather_sandstorm | weather_harsh_sun | weather_heavy_rain | weather_air_current POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_SANDSTORM POINTS_MINUS10
    return_cmd
DISCOURAGE_SUNNYDAY:
    jumpifweather weather_permament_sun | weather_sun | weather_harsh_sun | weather_heavy_rain | weather_air_current POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_SUNNY_DAY POINTS_MINUS10
    return_cmd
DISCOURAGE_RAINDANCE:
    jumpifweather weather_permament_rain | weather_rain | weather_downpour | weather_harsh_sun | weather_heavy_rain | weather_air_current POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_RAIN_DANCE POINTS_MINUS10
    return_cmd
DISCOURAGE_HAIL:
    jumpifweather weather_permament_hail | weather_hail | weather_harsh_sun | weather_heavy_rain | weather_air_current POINTS_MINUS10
    jumpifweather chilly_reception_hail POINTS_MINUS8  @ Penalidade menor para evitar alternância entre hail e snow
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_HAIL POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_BESTOW:
	getmoveid
    @ Verifica se o item da IA não tem efeito (HOLD_EFFECT_NONE)
    getitemeffect bank_ai 0                  @ Obtém o efeito do item (ignorando Embargo/Magic Room)
    jumpifbytevarEQ 0 POINTS_MINUS10         @ Se não tem efeito, penaliza -10
    @ Verifica se a IA tem Sticky Hold (impede perda de item)
    checkability bank_ai ABILITY_STICKY_HOLD 1
    jumpifbytevarEQ 1 POINTS_MINUS10         @ Penaliza se Sticky Hold impede a troca
    @ Verifica se o Pokémon está sob o efeito de Embargo
    jumpifmove MOVE_EMBARGO POINTS_MINUS10   @ Penaliza se Embargo impede o uso de itens
    @ Verifica se o Pokémon usou Trick, Switcheroo ou Thief
    jumpifmove MOVE_TRICK POINTS_MINUS10 @ Penaliza se Trick está em efeito
    jumpifmove MOVE_SWITCHEROO POINTS_MINUS10 @ Penaliza se Switcheroo está em efeito
    jumpifmove MOVE_THIEF CONTINUE_CMD @ Se Thief está em efeito, ignora penalização
    @ Verifica se o Pokémon tem Magician ou Pickup
    checkability bank_ai ABILITY_MAGICIAN 1
    jumpifbytevarEQ 1 CONTINUE_CMD @ Se Magician está ativo, ignora penalização
    checkability bank_ai ABILITY_PICKUP 1
    jumpifbytevarEQ 1 CONTINUE_CMD @ Se Pickup está ativo, ignora penalização
    return_cmd
CONTINUE_CMD:
	return_cmd
################################################################################################
DISCOURAGE_PARTING_SHOT:
    countalivepokes bank_ai
    jumpifbytevarEQ 0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_FAIRYLOCK:
	jumpifnotdoublebattle DISCOURAGE_MEANLOOK
	return_cmd
################################################################################################
DISCOURAGE_VENOMDRENCH:
    @ Verifica se o alvo está envenenado
    jumpifnostatus bank_target STATUS_BAD_POISON | STATUS_POISON POINTS_MINUS10
    @ Inicia verificação das estatísticas
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_ATK CHECK_ATK_LOWER
    jumpifbytevarEQ STAT_SP_ATK CHECK_SPATK_LOWER
    jumpifbytevarEQ STAT_SPD CHECK_SPEED_LOWER
    return_cmd
CHECK_ATK_LOWER:
    @ Verifica Hyper Cutter
    checkability bank_target ABILITY_HYPER_CUTTER
    jumpifbytevarEQ 1 POINTS_MINUS5
    goto_cmd CHECK_STAT_BOOSTS
CHECK_SPATK_LOWER:
    @ Não há habilidades que bloqueiem redução de Sp.Atk especificamente
    goto_cmd CHECK_STAT_BOOSTS
CHECK_SPEED_LOWER:
    @ Verifica se a IA é mais rápida e sem Pokémon reservas
    jumpifstrikesfirst bank_ai bank_target CHECK_AI_FASTER
    goto_cmd CHECK_STAT_BOOSTS
CHECK_AI_FASTER:
    countalivepokes bank_ai
    jumpifbytevarEQ 0 CHECK_ELECTRO_BALL
    goto_cmd CHECK_STAT_BOOSTS
CHECK_ELECTRO_BALL:
    jumpifhasmove bank_ai MOVE_ELECTRO_BALL CHECK_STAT_BOOSTS
    goto_cmd NEGATIVE_VD10 @ Penalidade máxima para Speed se IA for mais rápida sem reservas
CHECK_STAT_BOOSTS:
    @ Verifica estágios de estatística e habilidades genéricas
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10 @ Já está no mínimo
    @ Verifica Clear Body/White Smoke/Full Metal Body
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Aplica penalidades específicas por estatística
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_ATK CHECK_ATK_PENALTY
    jumpifbytevarEQ STAT_SP_ATK CHECK_SPATK_PENALTY
    jumpifbytevarEQ STAT_SPD CHECK_SPEED_PENALTY
    return_cmd
CHECK_ATK_PENALTY:
    goto_cmd NEGATIVE_VD5 @ -6 para ATK
CHECK_SPATK_PENALTY:
    goto_cmd NEGATIVE_VD8 @ -8 para SP_ATK
CHECK_SPEED_PENALTY:
    goto_cmd NEGATIVE_VD10 @ -10 para SPEED
NEGATIVE_VD5:
	scoreupdate -5
	return_cmd
NEGATIVE_VD8:
	scoreupdate -8
	return_cmd
NEGATIVE_VD10:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_ROTOTILLER:
	getmoveid
    jumpifmove MOVE_FLOWER_SHIELD LABEL_FLOWER_SHIELD
    jumpifmove MOVE_ROTOTILLER LABEL_ROTOTILLER
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID @ Default: não penaliza se for outro move (defensivo)

LABEL_FLOWER_SHIELD:
    jumpifnotdoublebattle FLOWER_SHIELD_SINGLE
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 1 FLOWER_SHIELD_ROTOTILLER_VALID
    isoftype bank_aipartner TYPE_GRASS
    jumpifbytevarEQ 1 FLOWER_SHIELD_ROTOTILLER_VALID
    goto_cmd NEGATIVE_RTT
FLOWER_SHIELD_SINGLE:
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 1 FLOWER_SHIELD_ROTOTILLER_VALID
    goto_cmd NEGATIVE_RTT

LABEL_ROTOTILLER:
    @ Aqui entra toda sua lógica robusta para Rototiller
    jumpifnotdoublebattle ROTOTILLER_SINGLE
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 0 ROTOTILLER_PARTNER
    call_cmd CHECK_GROUNDED
    jumpifbytevarEQ 0 ROTOTILLER_PARTNER
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage ROTOTILLER_SPATK_USER
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
ROTOTILLER_SPATK_USER:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage ROTOTILLER_PARTNER
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
ROTOTILLER_PARTNER:
    isoftype bank_aipartner TYPE_GRASS
    jumpifbytevarEQ 0 POINTS_MINUS10
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0 POINTS_MINUS10
    checkability bank_aipartner ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstatbuffEQ bank_aipartner STAT_ATK max_stat_stage ROTOTILLER_SPATK_PARTNER
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
ROTOTILLER_SPATK_PARTNER:
    jumpifstatbuffEQ bank_aipartner STAT_SP_ATK max_stat_stage POINTS_MINUS10
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
ROTOTILLER_SINGLE:
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 0 POINTS_MINUS10
    call_cmd CHECK_GROUNDED
    jumpifbytevarEQ 0 POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage ROTOTILLER_SPATK_SINGLE
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
ROTOTILLER_SPATK_SINGLE:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    goto_cmd FLOWER_SHIELD_ROTOTILLER_VALID
CHECK_GROUNDED:
    checkability bank_ai ABILITY_LEVITATE 1
    jumpifbytevarEQ 1 RETURN_0
    jumpifbankaffecting bank_ai BANK_AFFECTING_TELEKINESIS RETURN_0
    jumpifbankaffecting bank_ai BANK_AFFECTING_MAGNETRISE RETURN_0
    goto_cmd RETURN_1
RETURN_0:
    setbytevar 0
    return_cmd
RETURN_1:
    setbytevar 1
    return_cmd
FLOWER_SHIELD_ROTOTILLER_VALID:
    return_cmd
NEGATIVE_RTT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_FAKEOUT:
	jumpifnofirstturnfor bank_ai POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_QUASH:
    jumpifnotdoublebattle POINTS_MINUS10
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS10 @ Se o usuário já é mais rápido, usar Quash é desperdício
    getpartnerchosenmove @ Verifica se o parceiro já escolheu Quash
    jumpifwordvarEQ MOVE_QUASH POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_SDTA:
    jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    isoftype bank_target TYPE_FLYING @ 1. Verificar condições do alvo
    jumpifbytevarEQ 1 INCENTIVAR  @ Incentiva se o alvo é Flying-type
    checkability bank_target ABILITY_LEVITATE
    jumpifbytevarEQ 1 INCENTIVAR  @ Incentiva se o alvo tem Levitate
    jumpifbankaffecting bank_target BANK_AFFECTING_MAGNETRISE INCENTIVAR  @ Incentiva se o alvo está sob Magnet Rise
    jumpifbankaffecting bank_target BANK_AFFECTING_TELEKINESIS INCENTIVAR  @ Incentiva se o alvo está sob Magnet Rise
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penaliza fortemente se o alvo é imune 
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se o golpe é pouco eficaz
    @ 4. Verificar status específicos do alvo
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10  @ Penaliza se o alvo usa Substitute
    jumpiffieldaffecting FIELD_AFFECTING_GRAVITY POINTS_MINUS5
    jumpifitem bank_target 547 POINTS_MINUS5  @ Penaliza se o alvo tem Iron Ball
    @ 5. Incentivar interações específicas 
    jumpifstatus3 bank_target STATUS3_ONAIR INCENTIVAR  @ Incentiva se o alvo está usando Fly
    return_cmd  @ Finaliza a lógica

INCENTIVAR:
    scoreupdate +10  @ Incentiva o uso em condições favoráveis
    return_cmd
################################################################################################
DISCOURAGE_SOAK:
    getpartnerchosenmove @ 1. Se o parceiro também escolheu Soak, penaliza
    jumpifwordvarEQ MOVE_SOAK POINTS_MINUS10
    isoftype bank_target TYPE_WATER @ 2. Se o alvo já for puro Water, penaliza
    jumpifbytevarEQ 0x1 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_TELEKINESIS:
    @ 1) Se já está sob Telekinesis, Rooted ou Smacked Down
    jumpifstatus3 bank_target STATUS3_ROOTED POINTS_MINUS10
    @ 2) Se o campo está sob Gravity
    jumpiffieldaffecting FIELD_AFFECTING_GRAVITY POINTS_MINUS10
	jumpifbankaffecting bank_ai BANK_AFFECTING_SMACKEDDOWN POINTS_MINUS10
	jumpifbankaffecting bank_ai BANK_AFFECTING_TELEKINESIS POINTS_MINUS10
    @ 3) Se o defensor está segurando Iron Ball
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_IRONBALL POINTS_MINUS10
    @ 4) Se a espécie do alvo está na lista de banidos
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_DIGLETT POINTS_MINUS10
    jumpifwordvarEQ POKE_DUGTRIO POINTS_MINUS10
    jumpifwordvarEQ POKE_DIGLETT_ALOLA POINTS_MINUS10
    jumpifwordvarEQ POKE_DUGTRIO_ALOLA POINTS_MINUS10
    jumpifwordvarEQ POKE_SANDYGAST POINTS_MINUS10
    jumpifwordvarEQ POKE_PALOSSAND POINTS_MINUS10
    @ 5) Se o parceiro também vai usar Telekinesis
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_TELEKINESIS POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_DEFOG:
    @ Verifica efeitos de campo do oponente e hazards próprios
    jumpifsideaffecting bank_target SIDE_REFLECT | SIDE_LIGHTSCREEN | SIDE_SAFEGUARD | SIDE_MIST CHECK_PARTNER_MOVE_DEFOG
    jumpifsideaffecting bank_target SIDE_AFFECTING_AURORAVEIL POINTS_MINUS10
	jumpifauroraveiltimer bank_target END_LOCATION @ Salta se o Aurora Veil estiver ativo para o lado do oponente
	scoreupdate -10                            @ Penaliza se Aurora Veil estiver ativo
	return_cmd
    arehazardson bank_ai
    jumpifbytevarEQ 1 CHECK_PARTNER_MOVE_DEFOG
    @ Verifica se parceiro já usou Defog
CHECK_PARTNER_MOVE_DEFOG:
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_DEFOG POINTS_MINUS10
    @ Verifica hazards do oponente
    arehazardson bank_target
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Verificação em batalha dupla
    jumpifnotdoublebattle CHECK_EVASION
    ishazardmove bank_aipartner
    jumpifbytevarEQ 0 CHECK_EVASION
    jumpifstrikesfirst bank_aipartner bank_ai POINTS_MINUS10
    
    @ Verificação de evasão/Contrary
CHECK_EVASION:
    jumpifstatbuffEQ bank_target STAT_EVASION min_stat_stage POINTS_MINUS10
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_CONTRARY_LOGIC
    return_cmd

CHECK_CONTRARY_LOGIC:
    jumpiftargetisally END_LOCATION @ Só aplica se não for aliado
    scoreupdate -10
    return_cmd
################################################################################################
DISCOURAGE_TERRAINS:
    @ Verifica se o campo já está sob efeito de um terreno
    jumpiffieldaffecting FIELD_AFFECTING_TERRAINS POINTS_MINUS10
    @ Obtém o golpe escolhido pelo parceiro
    getpartnerchosenmove
    jumpifmovescriptEQ 151 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_MAGNETRISE:
    jumpiffieldaffecting FIELD_AFFECTING_GRAVITY POINTS_MINUS10
    jumpifbankaffecting bank_ai BANK_AFFECTING_MAGNETRISE POINTS_MINUS10
    jumpifbankaffecting bank_ai BANK_AFFECTING_TELEKINESIS POINTS_MINUS10
    if_ability bank_ai ABILITY_LEVITATE POINTS_MINUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_IRONBALL POINTS_MINUS10
	jumpifbankaffecting bank_ai BANK_AFFECTING_SMACKEDDOWN POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_POWERSPLIT:
    jumpiftargetisally POINTS_MINUS10         @ Penaliza se o alvo for aliado
    getmoveid
    jumpifwordvarEQ MOVE_POWER_SPLIT HANDLE_POWER_SPLIT
    jumpifwordvarEQ MOVE_GUARD_SPLIT HANDLE_GUARD_SPLIT
    return_cmd
HANDLE_POWER_SPLIT:
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+1 POWER_AI_ATK_HIGH
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage+1 POWER_AI_SPATK_HIGH
    return_cmd                                @ Nenhum dos stats ofensivos altos → não penaliza
POWER_AI_ATK_HIGH:
    jumpifstatbuffLT bank_target STAT_ATK default_stat_stage POWER_ATK_ONLY
    return_cmd                                @ Ambos têm ATK alto → não penaliza
POWER_AI_SPATK_HIGH:
    jumpifstatbuffLT bank_target STAT_SP_ATK default_stat_stage POWER_SPATK_ONLY
    return_cmd                                @ Ambos têm SP_ATK alto → não penaliza
POWER_ATK_ONLY:
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage+1 POWER_FULL_CHECK
    scoreupdate -5
    return_cmd
POWER_SPATK_ONLY:
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+1 POWER_FULL_CHECK
    scoreupdate -5
    return_cmd
POWER_FULL_CHECK:
    jumpifstatbuffGE bank_target STAT_ATK default_stat_stage+1 RETURN_CMD_POWERSPLIT
    jumpifstatbuffGE bank_target STAT_SP_ATK default_stat_stage+1 RETURN_CMD_POWERSPLIT
    scoreupdate -10
    return_cmd
HANDLE_GUARD_SPLIT:
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+1 GUARD_AI_DEF_HIGH
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage+1 GUARD_AI_SPDEF_HIGH
    return_cmd                                @ Nenhum dos stats defensivos altos → não penaliza
GUARD_AI_DEF_HIGH:
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage GUARD_DEF_ONLY
    return_cmd
GUARD_AI_SPDEF_HIGH:
    jumpifstatbuffLT bank_target STAT_SP_DEF default_stat_stage GUARD_SPDEF_ONLY
    return_cmd
GUARD_DEF_ONLY:
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage+1 GUARD_FULL_CHECK
    scoreupdate -5
    return_cmd
GUARD_SPDEF_ONLY:
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+1 GUARD_FULL_CHECK
    scoreupdate -5
    return_cmd
GUARD_FULL_CHECK:
    jumpifstatbuffGE bank_target STAT_DEF default_stat_stage+1 RETURN_CMD_POWERSPLIT
    jumpifstatbuffGE bank_target STAT_SP_DEF default_stat_stage+1 RETURN_CMD_POWERSPLIT
    scoreupdate -10
    return_cmd
RETURN_CMD_POWERSPLIT:
    return_cmd
################################################################################################
DISCOURAGE_POWER_GUARD_HEART_SWAP:
    jumpiftargetisally POINTS_MINUS10 @ Se o alvo for aliado, penaliza
    getmoveid
    jumpifwordvarEQ MOVE_POWER_SPLIT POWER_SPLIT
    jumpifwordvarEQ MOVE_GUARD_SWAP GUARD_SWAP
    jumpifwordvarEQ MOVE_HEART_SWAP HEART_SWAP
    return_cmd
POWER_SPLIT:
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage POINTS_MINUS10
    return_cmd
GUARD_SWAP:
    jumpifstatbuffGE bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd
HEART_SWAP:
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+1 SKIP_HEART_NEG_CHECK
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+1 SKIP_HEART_NEG_CHECK
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage+1 SKIP_HEART_NEG_CHECK
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage+1 SKIP_HEART_NEG_CHECK
    jumpifstatbuffGE bank_ai STAT_ACC default_stat_stage+1 SKIP_HEART_NEG_CHECK
    jumpifstatbuffGE bank_ai STAT_EVASION default_stat_stage+1 SKIP_HEART_NEG_CHECK
    scoreupdate -10
    return_cmd
SKIP_HEART_NEG_CHECK:
    jumpifstatbuffLT bank_ai STAT_ATK default_stat_stage END_HEART
    jumpifstatbuffLT bank_ai STAT_DEF default_stat_stage END_HEART
    jumpifstatbuffLT bank_ai STAT_SP_ATK default_stat_stage END_HEART
    jumpifstatbuffLT bank_ai STAT_SP_DEF default_stat_stage END_HEART
    jumpifstatbuffLT bank_ai STAT_ACC default_stat_stage END_HEART
    jumpifstatbuffLT bank_ai STAT_EVASION default_stat_stage END_HEART
    scoreupdate -10
END_HEART:
    return_cmd
################################################################################################
DISCOURAGE_ME_FIRST:
    getpredictedmove bank_target            @ Obtém o movimento previsto do alvo
    jumpifbytevarEQ 0x0 POINTS_MINUS10      @ Penaliza se nenhum movimento foi previsto (alvo provavelmente vai trocar)
    jumpifstrikesfirst bank_target bank_ai POINTS_MINUS10 @ Penaliza se o alvo ataca primeiro (Me First falhará)
	call_cmd TAI_SCRIPT_0
    return_cmd
################################################################################################
DISCOURAGE_COPYCAT:
    call_cmd TAI_SCRIPT_0
    return_cmd
################################################################################################
DISCOURAGE_AQUARING:
	jumpifbankaffecting bank_ai BANK_AFFECTING_AQUARING POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_LUCKYCHANT:
    jumpifnewsideaffecting bank_ai SIDE_AFFECTING_LUCKYCHANT POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_LUCKY_CHANT POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_FLING:
	jumpifitem bank_ai 0x0 POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_PBI:
    jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    @ 1. Verificar se o alvo está segurando uma Berry
    getitemeffect bank_target 1
    jumpifbytevarEQ 0 NO_BERRY_FOUND  @ Se o alvo não estiver segurando uma Berry, penaliza
    goto_cmd CHECK_BERRY_EFFECT

NO_BERRY_FOUND:
    scoreupdate -15  @ Penaliza se o alvo não tem Berry
    goto_cmd CHECK_TYPE_MATCHUP

CHECK_BERRY_EFFECT:
    @ Encoraja se o alvo possui uma Berry útil (ex.: Sitrus, Lum)
    @ 1. Cura de HP - Incentivo Alto
    jumpifbytevarEQ ITEM_EFFECT_SITRUSBERRY POINTS_PLUS10  @ Cura 25% HP
    jumpifbytevarEQ ITEM_EFFECT_ORANBERRY POINTS_PLUS5    @ Cura 10 HP
    jumpifbytevarEQ ITEM_EFFECT_FIGYBERRY POINTS_PLUS10   @ Cura se HP < 50%
    jumpifbytevarEQ ITEM_EFFECT_WIKIBERRY POINTS_PLUS10   @ Cura se HP < 50%
    jumpifbytevarEQ ITEM_EFFECT_MAGOBERRY POINTS_PLUS10   @ Cura se HP < 50%
    jumpifbytevarEQ ITEM_EFFECT_AGUAVBERRY POINTS_PLUS10  @ Cura se HP < 50%
    jumpifbytevarEQ ITEM_EFFECT_IAPAPABERRY POINTS_PLUS10 @ Cura se HP < 50%
    @ 2. Remoção de Status - Incentivo Moderado
    jumpifbytevarEQ ITEM_EFFECT_CHERIBERRY POINTS_PLUS5   @ Cura paralisia
    jumpifbytevarEQ ITEM_EFFECT_CHESTOBERRY POINTS_PLUS5  @ Cura sono
    jumpifbytevarEQ ITEM_EFFECT_PECHABERRY POINTS_PLUS5   @ Cura envenenamento
    jumpifbytevarEQ ITEM_EFFECT_RAWSTBERRY POINTS_PLUS5   @ Cura queimadura
    jumpifbytevarEQ ITEM_EFFECT_ASPEARBERRY POINTS_PLUS5  @ Cura congelamento
    jumpifbytevarEQ ITEM_EFFECT_PERSIMBERRY POINTS_PLUS5  @ Cura confusão
    jumpifbytevarEQ ITEM_EFFECT_LUMBERRY POINTS_PLUS10    @ Cura qualquer status
    @ 3. Buffs de Estatísticas - Incentivo Alto
    jumpifbytevarEQ ITEM_EFFECT_LIECHIBERRY POINTS_PLUS10  @ +1 Attack
    jumpifbytevarEQ ITEM_EFFECT_GANLONBERRY POINTS_PLUS10  @ +1 Defense
    jumpifbytevarEQ ITEM_EFFECT_SALACBERRY POINTS_PLUS10   @ +1 Speed
    jumpifbytevarEQ ITEM_EFFECT_PETAYABERRY POINTS_PLUS10  @ +1 Special Attack
    jumpifbytevarEQ ITEM_EFFECT_APICOTBERRY POINTS_PLUS10  @ +1 Special Defense
    @ 4. Berries Especiais - Incentivo Situacional
    jumpifbytevarEQ ITEM_EFFECT_LANSATBERRY POINTS_PLUS5   @ +1 Critical Hit Rate
    jumpifbytevarEQ ITEM_EFFECT_STARFBERRY POINTS_PLUS5    @ +2 em stat aleatório
    jumpifbytevarEQ ITEM_EFFECT_CUSTAPBERRY POINTS_PLUS10  @ Prioridade no próximo movimento
    jumpifbytevarEQ ITEM_EFFECT_KEEBERRY POINTS_PLUS5      @ -1 Attack do atacante
    jumpifbytevarEQ ITEM_EFFECT_MARANGABERRY POINTS_PLUS5  @ -1 Special Attack do atacante
    jumpifbytevarEQ ITEM_EFFECT_MICLEBERRY POINTS_PLUS5    @ Aumenta precisão
    jumpifbytevarEQ ITEM_EFFECT_JABOCABERRY POINTS_PLUS5   @ Dano ao contato físico
    jumpifbytevarEQ ITEM_EFFECT_ROWAPBERRY POINTS_PLUS5    @ Dano ao contato especial
    @ Penaliza se a Berry não é relevante
    jumpifbytevarNE 0 POINTS_MINUS5

CHECK_ABILITY:
    @ 2. Verificar habilidades que impedem o uso efetivo
    checkability bank_target ABILITY_STICKY_HOLD
    jumpifbytevarEQ 1 POINTS_MINUS10  @ Penaliza se o alvo tem Sticky Hold
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10  @ Penaliza se o alvo usa Substitute

CHECK_TYPE_MATCHUP:
    @ 3. Verificar imunidades e resistências
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penaliza fortemente se o alvo é imune
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se o golpe é pouco eficaz

CHECK_SPECIFIC_MOVE:
    @ 4. Lógica específica para cada golpe
	getmoveid
    jumpifmove MOVE_PLUCK HANDLE_PLUCK
    jumpifmove MOVE_BUG_BITE HANDLE_BUG_BITE
    jumpifmove MOVE_INCINERATE HANDLE_INCINERATE
    goto_cmd END_PBI_LOGIC

HANDLE_PLUCK:
    @ Incentivo adicional para Pluck se o alvo for fraco ao tipo Flying
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10
    goto_cmd END_PBI_LOGIC

HANDLE_BUG_BITE:
    @ Incentivo adicional para Bug Bite se o alvo for fraco ao tipo Bug
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10
    goto_cmd END_PBI_LOGIC

HANDLE_INCINERATE:
    @ Para Incinerate, verifica múltiplos alvos em batalha dupla/tripla
    isdoublebattle 
    jumpifbytevarGE 1 POINTS_PLUS5  @ Encoraja se há múltiplos alvos
    goto_cmd END_PBI_LOGIC

END_PBI_LOGIC:
    return_cmd
################################################################################################
DISCOURAGE_TAILWIND:
    jumpifnewsideaffecting bank_ai SIDE_AFFECTING_TAILWIND POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_TAILWIND POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM CHECK_TRICK_ROOM_TURNS
    return_cmd

CHECK_TRICK_ROOM_TURNS:
    checkiftrickroomisending
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_POWER_TRICK:
    @ 1. Verifica se o alvo é o parceiro
    jumpiftargetisally POINTS_MINUS10
    @ 2. Compara DEF e ATK
    comparestats bank_ai STAT_DEF STAT_ATK   @ Compara DEF e ATK
    jumpifbytevarEQ 0 POINTS_MINUS10        @ Penaliza se DEF >= ATK
    @ 3. Verifica se não há movimentos físicos
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10      @ Penaliza se não há movimentos físicos
    return_cmd
################################################################################################
DISCOURAGE_ACUPRESSURE:
    @ Verifica Substitute no alvo (etapa 1)
    jumpifnostatus2 bank_target STATUS2_SUBSTITUTE CHECK_MAXED_STATS
    @ Verifica movimentos que ignoram Substitute (etapa 2)
    getmoveid
    jumpifhwordvarinlist ignore_substitute CHECK_MAXED_STATS
    @ Verifica habilidade Infiltrator (etapa 3)
    checkability bank_ai ABILITY_INFILTRATOR
    jumpifbytevarEQ 1 CHECK_MAXED_STATS
    @ Penalidade se bloqueado por Substitute
    goto_cmd NEGATIVE_ACU

CHECK_MAXED_STATS:
    @ Sistema de verificação em cascata otimizado
    jumpifstatbuffNE bank_target STAT_ATK max_stat_stage RETURN_CMD
    jumpifstatbuffNE bank_target STAT_DEF max_stat_stage RETURN_CMD
    jumpifstatbuffNE bank_target STAT_SP_ATK max_stat_stage RETURN_CMD
    jumpifstatbuffNE bank_target STAT_SP_DEF max_stat_stage RETURN_CMD
    jumpifstatbuffNE bank_target STAT_SPD max_stat_stage RETURN_CMD
    jumpifstatbuffNE bank_target STAT_ACC max_stat_stage RETURN_CMD
    jumpifstatbuffEQ bank_target STAT_EVASION max_stat_stage STATS_MAXED
    
RETURN_CMD:
    return_cmd
STATS_MAXED:
    goto_cmd NEGATIVE_ACU
NEGATIVE_ACU:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_SECRETPOWER:
    jumpifhealthLT bank_ai 30 POINTS_MINUS12  @ Penaliza se o HP do usuário está baixo (<30%)
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN HANDLE_ELECTRIC_TERRAIN @ 1. Verificar os efeitos de campo (Terrenos Ativos)
    jumpiffieldaffecting FIELD_AFFECTING_GRASSY_TERRAIN HANDLE_GRASSY_TERRAIN
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN HANDLE_MISTY_TERRAIN
    jumpiffieldaffecting FIELD_AFFECTING_PSYCHIC_TERRAIN HANDLE_PSYCHIC_TERRAIN
    goto_cmd HANDLE_DEFAULT_CONDITION  @ Se nenhum terreno está ativo, aplica lógica padrão

HANDLE_ELECTRIC_TERRAIN:  @ Efeito: 30% de chance de paralisar
    isoftype bank_target TYPE_ELECTRIC  @ Tipos Elétricos são imunes a paralisia
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_LIMBER  @ Habilidade que previne paralisia
    jumpifbytevarEQ 1 POINTS_MINUS10
    goto_cmd HANDLE_STATUS_CHECK

HANDLE_GRASSY_TERRAIN:  @ Efeito: 30% de chance de causar sono
    isoftype bank_target TYPE_GRASS  @ Tipos Planta são imunes a Spore/Sleep Powder
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_INSOMNIA | ABILITY_VITAL_SPIRIT  @ Imunidade a Sono
    jumpifbytevarEQ 1 POINTS_MINUS10
    goto_cmd HANDLE_STATUS_CHECK

HANDLE_MISTY_TERRAIN:  @ Efeito: 30% de chance de reduzir Sp. Atk
    jumpifstatbuffGE bank_target STAT_SP_ATK 0 HANDLE_STATUS_CHECK  @ Penaliza se Sp. Atk já está baixo
    scoreupdate -10
    goto_cmd HANDLE_STATUS_CHECK

HANDLE_PSYCHIC_TERRAIN:  @ Efeito: 30% de chance de reduzir Velocidade
    jumpifstatbuffGE bank_target STAT_SPD 0 HANDLE_STATUS_CHECK  @ Penaliza se Speed já está baixo
    scoreupdate -10
    goto_cmd HANDLE_STATUS_CHECK

HANDLE_DEFAULT_CONDITION:  @ Efeito padrão (ex.: 30% de chance de paralisar em cavernas)
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS8  @ Penaliza se o alvo já está paralisado
    checkability bank_target ABILITY_LIMBER
    jumpifbytevarEQ 1 POINTS_MINUS8
    goto_cmd HANDLE_TYPE_MATCHUP

HANDLE_STATUS_CHECK:  @ Verifica se o alvo já está com algum status
    jumpifstatus bank_target 0xFFFF POINTS_MINUS8  @ Penaliza se o alvo já tem algum status
    goto_cmd HANDLE_TYPE_MATCHUP

HANDLE_TYPE_MATCHUP:  @ Verifica imunidades e resistências
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penaliza fortemente se o alvo é imune (ex.: Ghost)
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se resistência (ex.: Rock/Steel)
    checkability bank_ai ABILITY_SERENE_GRACE @ Encorajamento se o usuário tem Serene Grace (dobra chance de efeitos secundários)
    jumpifbytevarEQ 1 POINTS_PLUS10
    return_cmd
################################################################################################
DISCOURAGE_SPORTS:
    jumpifstatus3 bank_target STATUS3_MUDSPORT ALREADY_ACTIVE @ Penaliza se o alvo já está sob Mud Sport
    jumpifstatus3 bank_target STATUS3_WATERSPORT ALREADY_ACTIVE @ Penaliza se o alvo já está sob Water Sport
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_MUD_SPORT ALREADY_ACTIVE
    jumpifwordvarEQ MOVE_WATER_SPORT ALREADY_ACTIVE
    return_cmd
ALREADY_ACTIVE: @ Se nada disso, não penaliza
    goto_cmd NEGATIVE_SPT
NEGATIVE_SPT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_GRUDGE:
	countalivepokes bank_ai
	jumpifbytevarEQ 0x0 POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_SNATCH:
    jumpifmoveflag 3 NO_SNATCH_EFFECT_LABEL       @ Verifica se o movimento pode ser afetado por Snatch
    call_cmd CHECK_PARTNER_MOVE_SNATCH           @ Verifica se o parceiro tem o mesmo efeito de movimento
    return_cmd

NO_SNATCH_EFFECT_LABEL:
    return_cmd                                   @ Nenhuma penalização adicional necessária

CHECK_PARTNER_MOVE_SNATCH:
    getpartnerchosenmove                         @ Obtém o movimento escolhido do parceiro
    jumpifwordvarEQ MOVE_SNATCH POINTS_MINUS10   @ Penaliza se o movimento do parceiro também tem efeito Snatch
    return_cmd
################################################################################################
DISCOURAGE_REFRESH:
	jumpifnostatus bank_ai STATUS_BURN | STATUS_PARALYSIS | STATUS_BAD_POISON | STATUS_POISON POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_IMPRISION:
	jumpifstatus3 bank_target STATUS3_IMPRISONED POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_KNOCK_OFF:
    checkability bank_target ABILITY_STICKY_HOLD 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getitemeffect bank_target 0x0
    jumpifbytevarNE 0x0 END_LOCATION
    jumpifitem bank_ai 0x0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_BRICKPSY:
    getmoveid                          @ Obtém o ID do movimento atual
    jumpifmove MOVE_BRICK_BREAK CHECK_BRICK_BREAK
    jumpifmove MOVE_PSYCHIC_FANGS CHECK_PSYCHIC_FANGS
    return_cmd                         @ Retorna se não for Brick Break/Psychic Fangs

CHECK_BRICK_BREAK:
    @ 1. Verificar se o usuário tem Scrappy (ignora Ghost)
    checkability bank_ai ABILITY_SCRAPPY 0
    jumpifbytevarEQ 1 SKIP_GHOST_CHECK
    isoftype bank_target TYPE_GHOST    @ Verificar imunidade Ghost
    jumpifbytevarEQ 1 POINTS_MINUS30
SKIP_GHOST_CHECK:
    @ 2. Verificar Substitute
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12
    @ 3. Verificar barreiras (Reflect/Light Screen)
    jumpifsideaffecting bank_target SIDE_REFLECT | SIDE_LIGHTSCREEN | SIDE_AFFECTING_AURORAVEIL SKIP_BARRIER_PENALTY_BRICK
    scoreupdate -15                    @ Penalidade se não houver barreiras
SKIP_BARRIER_PENALTY_BRICK:
    goto_cmd CHECK_EFFECTIVENESS
CHECK_PSYCHIC_FANGS:
    @ 1. Verificar se o usuário tem Mold Breaker (ignora Dark)
    checkability bank_ai ABILITY_MOLD_BREAKER 0
    jumpifbytevarEQ 1 SKIP_DARK_CHECK
    isoftype bank_target TYPE_DARK     @ Verificar imunidade Dark
    jumpifbytevarEQ 1 POINTS_MINUS30
SKIP_DARK_CHECK:
    @ 2. Verificar Substitute
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12
    @ 3. Verificar barreiras (Reflect/Light Screen/Aurora Veil)
    jumpifsideaffecting bank_target SIDE_REFLECT | SIDE_LIGHTSCREEN | SIDE_AFFECTING_AURORAVEIL SKIP_BARRIER_PENALTY_BRICK
    scoreupdate -15                    @ Penalidade se não houver barreiras
SKIP_BARRIER_PENALTY_PSYCHIC:
    goto_cmd CHECK_EFFECTIVENESS
CHECK_EFFECTIVENESS:
    @ 4. Verificar eficácia do movimento
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30    @ Imunidade total
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS12 @ Resistência
    @ 5. Habilidades defensivas (Filter/Solid Rock)
    checkability bank_target ABILITY_FILTER 0
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_SOLID_ROCK 0
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 6. Verificar status do usuário (Burn/Paralysis)
    jumpifstatus bank_ai STATUS_BURN POINTS_MINUS10
    jumpifstatus bank_ai STATUS_PARALYSIS POINTS_MINUS5
    @ 7. Verificar Life Orb do usuário (aumenta dano)
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_LIFEORB POINTS_PLUS5
    return_cmd
################################################################################################
DISCOURAGE_YAWN:
    jumpifstatus2 bank_target STATUS3_YAWN POINTS_MINUS10  @ Se já está sob Yawn, penaliza -10
    call_cmd CHECK_SLEEP_CONDITIONS                        @ Chama verificações de sono
    return_cmd
CHECK_SLEEP_CONDITIONS:
    @ 1. Verifica se o alvo pode ser adormecido (CanBeSlept)
    if_ability bank_target ABILITY_INSOMNIA POINTS_MINUS10
    if_ability bank_target ABILITY_VITAL_SPIRIT POINTS_MINUS10
    jumpifstatus bank_target STATUS_SLEEP POINTS_MINUS10
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    @ 2. Verifica Substitute (DoesSubstituteBlockMove)
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE CHECK_SUBSTITUTE_BYPASS
    goto_cmd CHECK_PARTNER_MOVE_YAWN

CHECK_SUBSTITUTE_BYPASS:
    checkability bank_ai ABILITY_INFILTRATOR 1              @ Infiltrator ignora Substitute
    jumpifbytevarEQ 1 CHECK_PARTNER_MOVE_YAWN
    getmoveid                                              @ Verifica se o movimento ignora Substitute
    jumpifhwordvarinlist ignore_substitute  CHECK_PARTNER_MOVE_YAWN
    goto_cmd NEGATIVE_YAWN                                @ Substitute bloqueia

CHECK_PARTNER_MOVE_YAWN:
    @ 3. Verifica se o parceiro já escolheu movimento de sono
    getpartnerchosenmove
    jumpifhwordvarinlist sleep_moves POINTS_MINUS10         @ Lista de movimentos que induzem sono
    return_cmd
NEGATIVE_YAWN:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_RECYCLE:
	getusedhelditem bank_ai
	jumpifbytevarEQ 0x0 POINTS_MINUS10
	jumpifitem bank_ai 0x0 END_LOCATION
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_BATONPASS:
    @ Se não há pokémons usáveis, penaliza forte
    countalivepokes bank_ai
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    @ Se tem Substitute, Rooted, Aqua Ring, Magnet Rise ou Power Trick, não penaliza
    jumpifstatus2 bank_ai STATUS2_SUBSTITUTE END_LOCATION
    jumpifstatus3 bank_ai STATUS3_ROOTED END_LOCATION
    jumpifbankaffecting bank_ai BANK_AFFECTING_AQUARING END_LOCATION
    jumpifbankaffecting bank_ai BANK_AFFECTING_MAGNETRISE END_LOCATION
    jumpifbankaffecting bank_ai BANK_AFFECTING_POWERTRICK END_LOCATION
    @ Se qualquer stat está aumentado, não penaliza
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_SPD default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_ACC default_stat_stage END_LOCATION
    jumpifstatbuffGE bank_ai STAT_EVASION default_stat_stage END_LOCATION
    @ Caso contrário, penaliza levemente
    scoreupdate -6
    return_cmd
################################################################################################
DISCOURAGE_INGRAIN:
	jumpifstatus3 bank_ai STATUS3_ROOTED POINTS_MINUS10
	goto_cmd DISCOURAGE_HEALBLOCK_AI
################################################################################################
DISCOURAGE_WISH:
    @ Obtém a duração do Wish para o banco da IA
    get_wish_duration bank_ai          @ Carrega a duração do Wish para o banco da IA
    jumpifbytevarNE 0 POINTS_MINUS10   @ Penaliza se a duração não for zero
    return_cmd                        @ Finaliza o comando
################################################################################################
DISCOURAGE_ASSIST:
    @ Verifica se o alvo tem Pokémon utilizáveis na party
    countalivepokes bank_target
    jumpifbytevarEQ 0x0 POINTS_MINUS10
################################################################################################
DISCOURAGE_TRICK:
    checkability bank_target ABILITY_STICKY_HOLD 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getitemeffect bank_target 0x0
    jumpifbytevarNE 0x0 END_LOCATION
    jumpifitem bank_ai 0x0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_BEATUP:
    jumpifhealthLT bank_ai 30 POINTS_MINUS8
    isoftype bank_target TYPE_DARK
    jumpifbytevarEQ TYPE_DARK POINTS_MINUS10
    isoftype bank_target TYPE_FAIRY
    jumpifbytevarEQ TYPE_FAIRY POINTS_MINUS10
    isoftype bank_target TYPE_FIGHTING
    jumpifbytevarEQ TYPE_FIGHTING POINTS_MINUS10
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30
    countalivepokes bank_ai
    jumpifbytevarLT 1 POINTS_MINUS10
    arehazardson bank_ai
    jumpifbytevarNE 0 POINTS_MINUS5
    checkability bank_target ABILITY_ROUGH_SKIN
    jumpifbytevarEQ 1 BB_CHECK_IRON_BARBS
    checkability bank_target ABILITY_JUSTIFIED 0
    jumpifbytevarEQ 1 POINTS_MINUS12
    return_cmd

BB_CHECK_IRON_BARBS: @ 5. Alvo com item que pune contato
    checkability bank_target ABILITY_IRON_BARBS
    jumpifbytevarEQ 1 BB_CHECK_ROCKY_HELMET
    return_cmd

BB_CHECK_ROCKY_HELMET:
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS5
    return_cmd
    getstatvaluemovechanges bank_target
    jumpifbytevarGE STAT_EVASION BB_POINTS_EVA
    getprotectuses bank_target
    jumpifbytevarGE 1 POINTS_MINUS12
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS5
    return_cmd

BB_POINTS_EVA:
    jumpifbytevarGE default_stat_stage+2 POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_UPROAR:
    @ 1. Verificar imunidade do alvo (Ghost-type ou Soundproof)
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ TYPE_GHOST POINTS_MINUS30
    checkability bank_target ABILITY_SOUNDPROOF 0
    jumpifbytevarEQ ABILITY_SOUNDPROOF POINTS_MINUS30
    @ 2. Verificar Substitute do alvo
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12
    @ 3. Verificar se o usuário está dormindo (Uproar falha se estiver dormindo)
    jumpifstatus bank_ai STATUS_SLEEP POINTS_MINUS30
    @ 4. Verificar Protect/Detect do alvo
    getprotectuses bank_target
    jumpifbytevarGE 1 POINTS_MINUS8
    @ 5. Verificar evasão do alvo (>= +3)
    getstatvaluemovechanges bank_target
    jumpifbytevarGE STAT_EVASION BB_POINTS_EVA2
    @ 6. Verificar HP baixo do usuário (<30%)
    jumpifhealthLT bank_ai 30 POINTS_MINUS10
    @ 7. Verificar se o oponente tem Pokémon imunes em seu time
	jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS12
    goto_cmd CHECK_UPROAR_ACTIVE

CHECK_UPROAR_ACTIVE:
    @ 8. Verificar se Uproar já está ativo (evitar sobreposição)
    jumpifstatus2 bank_ai STATUS2_UPROAR POINTS_MINUS12
    return_cmd
BB_POINTS_EVA2:
    jumpifbytevarGE default_stat_stage+2 POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_STOCKPILESTUFF:
	getmoveid
    jumpifmove MOVE_STOCKPILE DISCOURAGE_STOCKPILE
    jumpifmove MOVE_SWALLOW DISCOURAGE_SWALLOW
    jumpifmove MOVE_SPIT_UP DISCOURAGE_IFUSERNOSTOCKPILE
    return_cmd

DISCOURAGE_STOCKPILE:
    getstockpileuses bank_ai
    jumpifbytevarGE 3 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_MAGNITUDE:
    @ Verifica condições no alvo principal
    checkability bank_target ABILITY_LEVITATE 1
    jumpifbytevarEQ 1 APPLY_PENALTY
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_AIRBALLOON APPLY_PENALTY
    jumpifbankaffecting bank_target BANK_AFFECTING_MAGNETRISE APPLY_PENALTY
    jumpifbankaffecting bank_target BANK_AFFECTING_TELEKINESIS APPLY_PENALTY
    
    @ Verifica parceiro em batalhas duplas
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0 END_LOCATION
    checkability bank_aipartner ABILITY_LEVITATE 1
    jumpifbytevarEQ 1 APPLY_PENALTY
    getitemeffect bank_aipartner 1
    jumpifbytevarEQ ITEM_EFFECT_AIRBALLOON APPLY_PENALTY
    jumpifbankaffecting bank_aipartner BANK_AFFECTING_MAGNETRISE APPLY_PENALTY
    jumpifbankaffecting bank_aipartner BANK_AFFECTING_TELEKINESIS APPLY_PENALTY
    isoftype bank_aipartner TYPE_FLYING
    jumpifbytevarEQ 1 APPLY_PENALTY
    jumpifhealthLT bank_aipartner 30 APPLY_PENALTY
    return_cmd

APPLY_PENALTY:
    @ Verifica exceções (Mold Breaker, Inverse Battle etc)
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_MOLD_BREAKER END_LOCATION
    jumpifbytevarEQ ABILITY_TERAVOLT END_LOCATION
    jumpifbytevarEQ ABILITY_TURBOBLAZE END_LOCATION
    goto_cmd NEGATIVE_MAG
NEGATIVE_MAG:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_SWALLOW:
    getstockpileuses bank_ai
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    jumpifhealthGE bank_ai 100 POINTS_MINUS10
    jumpifhealthGE bank_ai 80 POINTS_MINUS5
    return_cmd

DISCOURAGE_IFUSERNOSTOCKPILE:
    getstockpileuses bank_ai
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_FUTURESIGHT: @ Cobre Future Sight e Doom Desire
    jumpifsideaffecting bank_target SIDE_FUTUREATTACK FUTURE_SIGHT_PENALTY @ Verifica se o alvo já tem um ataque futuro pendente
    jumpifsideaffecting bank_ai SIDE_FUTUREATTACK FUTURE_SIGHT_PENALTY @ Verifica se o usuário já tem um ataque futuro pendente
    goto_cmd NEGATIVE_FUS @ Equivalente a GOOD_EFFECT @ Se não há ataques futuros pendentes, aplica bônus
    return_cmd

FUTURE_SIGHT_PENALTY:
    goto_cmd NEGATIVE_FUS2 @ Penalização maior como no código original (-12 vs -10)
    return_cmd
NEGATIVE_FUS:
	scoreupdate +3
	return_cmd
NEGATIVE_FUS2:
	scoreupdate -12
	return_cmd
################################################################################################
DISCOURAGE_MAGICCOAT:
    jumpifmoveflag 2 NO_MAGIC_COAT_EFFECT_LABEL    @ Verifica se o movimento pode ser afetado pelo Magic Coat
    goto_cmd NEGATIVE_MAGICCOAT                       @ Penaliza se o movimento não pode ser afetado pelo Magic Coat
    return_cmd

NO_MAGIC_COAT_EFFECT_LABEL:
    return_cmd                                    @ Nenhuma penalização adicional necessária
NEGATIVE_MAGICCOAT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_RAPIDSPIN:
    jumpifhealthLT bank_ai 30 POINTS_MINUS8 @ Baixo HP do usuário reduz eficácia de Rapid Spin
	arehazardson bank_ai
    jumpifbytevarEQ 0 POINTS_MINUS10
    isoftype bank_target TYPE_GHOST @ Verificar se o alvo é Ghost-type (imune a Rapid Spin)
    jumpifbytevarEQ 1 POINTS_MINUS30   @ Imunidade = penalidade total
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12 @ Verificar se o alvo tem Substitute ativo
    jumpifstatus2 bank_ai STATUS2_WRAPPED POINTS_PLUS10
    checkability bank_target ABILITY_ROUGH_SKIN @ 3. Alvo com habilidade que pune contato
    jumpifbytevarEQ 1 RS_CHECK_IRON_BARBS

CHECK_HP_AND_UTILITY:
    jumpifhealthLT bank_ai 25 POINTS_MINUS10 @ 7. Verificar se o usuário tem HP baixo (<25%)
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_HEAVYDUTYBOOTS POINTS_MINUS30
    isoftype bank_ai TYPE_ROCK
    jumpifbytevarEQ 1 POINTS_PLUS10
    isoftype bank_ai TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_PLUS10
    getbestdamagelefthp bank_ai bank_target
    jumpifbytevarLT 20 POINTS_MINUS12  @ Dano <20% do HP máximo do alvo
    return_cmd

RS_CHECK_IRON_BARBS: @ 4. Alvo com item que pune contato
    checkability bank_target ABILITY_IRON_BARBS
    jumpifbytevarEQ 1 RS_CHECK_ROCKY_HELMET
    return_cmd
RS_CHECK_ROCKY_HELMET:
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS5
    return_cmd
    getstatvaluemovechanges bank_target @ 5. Alvo com buff de evasão alto (menos impacto de Spin)
    jumpifbytevarEQ STAT_EVASION RS_CHECK_EVA
    getprotectuses bank_target @ 6. Alvo usando Protect/Detect
    jumpifbytevarGE 1 POINTS_MINUS10
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS5 @ 7. Oponente mais rápido (pode interromper Spin)
    return_cmd
RS_CHECK_EVA:
    jumpifbytevarGE default_stat_stage+3 POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_PSYCHUP:
    @ --- Verifica se vai resetar stats positivas aliadas ---
    jumpifsamestatboosts bank_ai bank_target POINTS_MINUS10
    @ Verifica parceiro (se existir)
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0 CHECK_ENEMY_STATS
    jumpifsamestatboosts bank_aipartner bank_target POINTS_MINUS10
CHECK_ENEMY_STATS:
    @ --- Verifica se vai copiar stats reduzidas do inimigo ---
    @ Stats do alvo principal
    jumpifstatbuffLT bank_target STAT_ATK 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_DEF 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_SPD 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_SP_ATK 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_SP_DEF 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_ACC 6 CHECK_TARGET_PARTNER
    jumpifstatbuffLT bank_target STAT_EVASION 6 CHECK_TARGET_PARTNER
CHECK_TARGET_PARTNER:
    @ Verifica parceiro do alvo (se existir)
    isbankpresent bank_targetpartner
    jumpifbytevarEQ 0 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_ATK 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_DEF 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_SPD 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_SP_ATK 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_SP_DEF 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_ACC 6 CHECK_ALLY_STATS_PSYCHUP
    jumpifstatbuffLT bank_targetpartner STAT_EVASION 6 CHECK_ALLY_STATS_PSYCHUP
CHECK_ALLY_STATS_PSYCHUP:
    @ --- Verifica stats positivas do usuário ---
    jumpifstatbuffGE bank_ai STAT_ATK 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_DEF 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_SPD 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_SP_ATK 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_SP_DEF 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_ACC 6 CHECK_ALLY_PARTNER
    jumpifstatbuffGE bank_ai STAT_EVASION 6 CHECK_ALLY_PARTNER
CHECK_ALLY_PARTNER:
    @ Verifica parceiro do usuário (se existir)
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0 APPLY_PENALTY_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_ATK 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_DEF 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_SPD 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_SP_ATK 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_SP_DEF 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_ACC 6 RETURN_CMD_PSYCHUP
    jumpifstatbuffGE bank_aipartner STAT_EVASION 6 RETURN_CMD_PSYCHUP
APPLY_PENALTY_PSYCHUP:
    scoreupdate -10
RETURN_CMD_PSYCHUP:
    return_cmd
################################################################################################
DISCOURAGE_PAINSPLIT:
	jumpifhealthGE bank_ai 86 POINTS_MINUS10
	jumpifhealthLT bank_target 16 POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_SAFEGUARD:
    jumpifsideaffecting bank_ai SIDE_SAFEGUARD POINTS_MINUS10 @ Verifica se já há Safeguard ativo
    getpartnerchosenmove @ Verifica se o parceiro já usou Safeguard neste turno
    jumpifwordvarEQ MOVE_SAFEGUARD POINTS_MINUS10 @ Se parceiro escolheu o mesmo movimento
    return_cmd
################################################################################################
DISCOURAGE_HEALBELL:
    @ Verifica se há algum Pokémon com status no time (considerando Soundproof)
    jumpifanypartymemberhasstatus bank_ai 0xFFFF CHECK_PARTNER_MOVE_HEALBELL
    @ Verificação adicional para Soundproof em batalhas duplas
    jumpifnotdoublebattle APPLY_PENALTY_HEALBELL
    checkability bank_aipartner ABILITY_SOUNDPROOF
    jumpifbytevarEQ 1 CHECK_MAIN_BATTLER
CHECK_PARTNER_MOVE_HEALBELL:
    @ Verifica se o parceiro já escolheu o mesmo movimento
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_HEAL_BELL APPLY_PENALTY_HEALBELL
    @ Verifica status no Pokémon principal
    jumpifstatus bank_ai STATUS_SLEEP | STATUS_POISON | STATUS_BURN | STATUS_PARALYSIS | STATUS_FREEZE CHECK_MAIN_BATTLER
    return_cmd
CHECK_MAIN_BATTLER:
    @ Verifica Soundproof no próprio Pokémon
    checkability bank_ai ABILITY_SOUNDPROOF
    jumpifbytevarEQ 1 RETURN_CMD_HEALBELL
APPLY_PENALTY_HEALBELL:
    scoreupdate -10
RETURN_CMD_HEALBELL:
    return_cmd
################################################################################################
CHECK_WONDER_GUARD_EFFECTIVENESS:
    @ Verifica Wonder Guard + efetividade < 2x
    checkability bank_target ABILITY_WONDER_GUARD 1
    jumpifbytevarNE 1 CHECK_END
    @ Verifica efetividade
    jumpifeffectiveness_EQ SUPER_EFFECTIVE CHECK_END
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS CHECK_END
    @ Aplica penalidade se passar nas verificações
    goto_cmd NEGATIVE_GUARD

CHECK_END:
    return_cmd
DISCOURAGE_PRESENT:
    call_cmd CHECK_WONDER_GUARD_EFFECTIVENESS
    return_cmd
DISCOURAGE_FOCUSPUNCH:
    call_cmd CHECK_WONDER_GUARD_EFFECTIVENESS
    return_cmd
NEGATIVE_GUARD:
	scoreupdate +10
	return_cmd
################################################################################################
DISCOURAGE_FURYCUTTER:
    isoftype bank_target TYPE_FLYING @ 1. Verificar imunidade do alvo a Bug (ex: Flying, Ghost, Steel)
    jumpifbytevarEQ 1 POINTS_MINUS30
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ 1 POINTS_MINUS30
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS30
    isoftype bank_target TYPE_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS30
    @ Penalidades para habilidades defensivas do alvo
	checkability bank_ai ABILITY_SHARPNESS
	jumpifbytevarEQ 1 POINTS_PLUS10
    checkability bank_target ABILITY_ROUGH_SKIN 0
    jumpifbytevarEQ 1 POINTS_MINUS8
    checkability bank_target ABILITY_IRON_BARBS 0
    jumpifbytevarEQ 1 POINTS_MINUS8
    checkability bank_target ABILITY_MAGIC_GUARD 0
    jumpifbytevarEQ 1 POINTS_MINUS10  @ Penaliza se Magic Guard está ativo
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS30 @ 2. Verificar se o alvo tem Substitute ativo
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE CHECK_TINTED_LENS @ 3. Verificar resistência ao tipo Bug (ex: Fire, Fighting)
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_METRONOME POINTS_PLUS10
	jumpifbytevarEQ ITEM_EFFECT_WIDELENS POINTS_PLUS5  @ Encoraja se o usuário possui Wide Lens
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS POINTS_PLUS5  @ Encoraja se o usuário possui Scope Lens
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS5
	getmoveaccuracy  @ Verifica a precisão do golpe
    jumpifbytevarLT 95 POINTS_MINUS5  @ Penaliza levemente devido à chance de erro
    getstatvaluemovechanges bank_target @ 4. Alvo com buff de evasão alto
    jumpifbytevarEQ STAT_EVASION FC_CHECK_EVA
    getprotectuses bank_target @ 5. Alvo usando Protect/Detect
    jumpifbytevarGE 1 POINTS_MINUS10
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS5 @ 6. Oponente mais rápido
    goto_cmd APPLY_RESIST_PENALTY

CHECK_TINTED_LENS:
    checkability bank_ai ABILITY_TINTED_LENS 0
    jumpifbytevarEQ 1 POINTS_PLUS5

APPLY_RESIST_PENALTY:
    scoreupdate -15  @ Penalidade por resistência ao tipo Bug
    goto_cmd CHECK_CONSECUTIVE_HITS

FC_CHECK_EVA:
    jumpifbytevarGE default_stat_stage+2 POINTS_MINUS5
    return_cmd

CHECK_CONSECUTIVE_HITS:
    @ 6. Verificar número de usos consecutivos de Fury Cutter (0 a 4)
    get_consecutive_move_count bank_ai MOVE_FURY_CUTTER
    jumpifbytevarEQ 0 POINTS_MINUS12  @ Primeiro uso: poder base baixo (40)
    jumpifbytevarEQ 1 POINTS_MINUS10  @ Segundo uso: poder 80
    jumpifbytevarEQ 2 POINTS_PLUS5    @ Terceiro uso: poder 160 (encorajar)
    jumpifbytevarGE 3 POINTS_PLUS10   @ Quarto/quinto uso: poder 320+ (forte)
    @ 7. Verificar se o alvo está com HP baixo (<25%)
    getbestdamagelefthp bank_ai bank_target
    jumpifbytevarLT 25 POINTS_PLUS10  @ Priorizar finalização
    @ 8. Verificar buffs de ataque do usuário ou debuffs de defesa do alvo
    jumpifstatbuffGE bank_ai STAT_ATK 2 POINTS_PLUS10  @ +2 ou mais de Attack
    jumpifstatbuffLT bank_target STAT_DEF 2 POINTS_PLUS5   @ -2 ou menos de Defense
    return_cmd
################################################################################################
DISCOURAGE_IFNOSLEEPUSER:
    @ Verifica status de sono normal primeiro
    jumpifnostatus bank_ai STATUS_SLEEP CHECK_COMATOSE
    return_cmd

CHECK_COMATOSE:
    @ Verifica se tem a habilidade Comatose (que conta como estado de sono)
    checkability bank_ai ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 RETURN_CMD_IFNOSLEEPUSER
    goto_cmd NEGATIVE_INSU

RETURN_CMD_IFNOSLEEPUSER:
    return_cmd

NEGATIVE_INSU:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_ROICE:
    isoftype bank_target TYPE_STEEL    @ Steel resiste a Ice Ball (Ice)
    jumpifbytevarEQ 1 POINTS_MINUS12
    isoftype bank_target TYPE_FLYING    @ Super aconselhável
    jumpifbytevarEQ 1 POINTS_PLUS10
    getstatvaluemovechanges bank_ai
    jumpifbytevarLT STAT_DEF CHECK_DEF_ROICE
    jumpifhealthLT bank_ai 30 POINTS_MINUS8 @ 1. Baixo HP do usuário reduz eficácia de Rollout/Ice Ball
	jumpifstatus bank_ai STATUS_BURN | STATUS_POISON POINTS_MINUS5
    checkability bank_target ABILITY_ROUGH_SKIN @ 2. Alvo com habilidade que pune contato
    jumpifbytevarEQ 1 CHECK_IRON_BARBS
    checkability bank_target ABILITY_DISGUISE
    jumpifbytevarNE 1 POINTS_MINUS30

CHECK_IRON_BARBS: @ 3. Alvo com item que pune contato
    checkability bank_target ABILITY_IRON_BARBS
    jumpifbytevarEQ 1 CHECK_ROCKY_HELMET
    return_cmd

CHECK_ROCKY_HELMET:
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS5
    getstatvaluemovechanges bank_target @ 4. Alvo com alta evasão
    jumpifbytevarEQ STAT_EVASION CHECK_EVA
    getprotectuses bank_target @ 5. Alvo usando Protect/Detect
    jumpifbytevarGE 1 POINTS_MINUS10
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS5 @ 6. Oponente mais rápido
    return_cmd

CHECK_EVA:
    jumpifbytevarGE default_stat_stage+3 POINTS_MINUS5
    return_cmd
CHECK_DEF_ROICE:
    jumpifbytevarGE default_stat_stage-1 POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_CURSE:
    isoftype bank_ai TYPE_GHOST
    jumpifbytevarEQ 0x1 GHOST_CURSE_LOGIC
    goto_cmd REGULAR_CURSE_LOGIC
GHOST_CURSE_LOGIC:
    @ Verifica se alvo já está amaldiçoado
    jumpifstatus2 bank_target STATUS2_CURSED POINTS_MINUS10
    @ Verifica se parceiro tem mesmo efeito (não tem comando equivalente direto, aproximação)
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_CURSE POINTS_MINUS10
    @ Verifica HP do usuário
    jumpifhealthLT bank_ai 50 POINTS_MINUS5
    return_cmd

REGULAR_CURSE_LOGIC:
    if_ability bank_ai ABILITY_CONTRARY CONTRARY_CURSE
    @ Verifica Ataque e movimentos físicos
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage CHECK_PHYSICAL_MOVES2
    goto_cmd CHECK_DEFENSE
CHECK_PHYSICAL_MOVES2:
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
CHECK_DEFENSE:
    @ Verifica Defesa
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS8
    return_cmd
CONTRARY_CURSE:
    @ Lógica para Contrary
    jumpifstatbuffEQ bank_ai STAT_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_BERRYDRUM:
    checkability bank_ai ABILITY_CONTRARY
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifhealthLT bank_ai 60 POINTS_MINUS10
    jumpifstatbuffEQ bank_ai 0x1 0xC POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_DESTINYBOND:
    jumpifstatus2 bank_target STATUS2_DESTINNY_BOND POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_THIEFCOVET:
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS30 @ 1. Verificar se o alvo tem Substitute ativo (não pode roubar item)
    checkability bank_target ABILITY_STICKY_HOLD 0 @ 2. Verificar habilidades que bloqueiam roubo (Sticky Hold)
    jumpifbytevarEQ 1 POINTS_MINUS30   @ Sticky Hold bloqueia roubo
    getitemeffect bank_target 1 @ 3. Verificar se o alvo tem itens não-roubáveis (Mega Stone, Plates, etc.)
    jumpifbytevarEQ ITEM_EFFECT_MEGASTONE POINTS_MINUS30
    jumpifbytevarEQ ITEM_EFFECT_PRIMALORB POINTS_MINUS30
    jumpifbytevarEQ ITEM_EFFECT_PLATES POINTS_MINUS30
    jumpifbytevarEQ ITEM_EFFECT_FAIRYPLATE POINTS_MINUS30
    jumpifbytevarEQ ITEM_EFFECT_DRIVES POINTS_MINUS30
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10 @ Rocky Helmet pode ser roubado, mas penaliza o usuário
    getbankspecies bank_target @ 4. Verificar espécie do alvo (Giratina e Griseous Orb)
    jumpifwordvarEQ POKE_GIRATINA CHECK_GRISEOUS_ORB
    goto_cmd ALLOW

CHECK_GRISEOUS_ORB:
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_GRISEOUSORB POINTS_MINUS30 @ Griseous Orb não pode ser roubado de Giratina
    goto_cmd ALLOW

ALLOW:
    @ 5. Verificar se o usuário já tem um item (Thief só funciona se o usuário não tiver item)
    getitemeffect bank_ai 0
    jumpifbytevarNE 0 POINTS_MINUS12
    return_cmd
################################################################################################
DISCOURAGE_LOCKON:
    islockon_on bank_ai bank_target
    jumpifbytevarEQ 0x1 POINTS_MINUS10                 @ Verifica se já está sob Lock-On
    if_ability bank_ai ABILITY_NO_GUARD POINTS_MINUS10 @ Verifica No Guard no usuário
    if_ability bank_target ABILITY_NO_GUARD POINTS_MINUS10 @ Verifica No Guard no alvo
    getpartnerchosenmove                                @ Obtém movimento do parceiro
    jumpifwordvarEQ MOVE_LOCKON POINTS_MINUS10         @ Verifica se parceiro já escolheu Lock-On
    jumpifwordvarEQ MOVE_MIND_READER POINTS_MINUS10         @ Verifica se parceiro já escolheu Mind Reader
    return_cmd
################################################################################################
DISCOURAGE_TRIATTACK:
    isoftype bank_target TYPE_GHOST @ 1. Verificar se o alvo é do tipo Ghost (imune a Normal)
    jumpifbytevarEQ 1 POINTS_MINUS30   @ Penalidade máxima por imunidade
	jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza levemente se resistência
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penaliza severamente se imunidade
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12 @ 2. Verificar se o alvo tem Substitute ativo
	checkability bank_target ABILITY_GUTS 0  @ Verificar habilidade Guts
    jumpifbytevarEQ 1 POINTS_MINUS5  @ Penaliza se o alvo tem Guts (benefício ao status)
	checkability bank_target ABILITY_MAGIC_GUARD 0  @ Verificar habilidade Magic Guard
    jumpifbytevarEQ 1 POINTS_MINUS5  @ Penaliza se Magic Guard está ativo
    checkability bank_target ABILITY_SHIELD_DUST 0   @ Bloqueia efeitos secundários
    jumpifbytevarEQ 1 POINTS_MINUS5
    checkability bank_target ABILITY_IMMUNITY 0      @ Imune a envenenamento
    jumpifbytevarEQ 1 POINTS_MINUS2
    checkability bank_target ABILITY_WATER_VEIL 0    @ Imune a queimadura
    jumpifbytevarEQ 1 POINTS_MINUS2
    checkability bank_target ABILITY_LIMBER 0        @ Imune a paralisia
    jumpifbytevarEQ 1 POINTS_MINUS2
    checkability bank_target ABILITY_COMATOSE 0        @ Imune a paralisia
    jumpifbytevarEQ 1 POINTS_MINUS2
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10 @ 4. Verificar se o alvo já está com algum status
	getitemeffect bank_ai 0  @ Verificar item do atacante
    jumpifbytevarEQ ITEM_EFFECT_LIFEORB POINTS_PLUS5  @ Encoraja se o atacante possui Life Orb
    jumpifbytevarEQ ITEM_EFFECT_CHOICESPECS POINTS_PLUS5  @ Encoraja se o atacante possui Choice Specs
    checkability bank_ai ABILITY_SERENE_GRACE 0 @ 6. Reduzir penalidade se o usuário tem Serene Grace (dobra chance de status)
    jumpifbytevarEQ 1 POINTS_PLUS10
    return_cmd
################################################################################################
DISCOURAGE_SUBSTITUTE:
    jumpifstatus2 bank_ai STATUS2_SUBSTITUTE SUBSTITUTE_PENALTY @ 1. Verifica se já tem Substitute ativo
    jumpifhealthLT bank_ai 26 HP_PENALTY @ 2. Verifica HP <= 25%
    if_ability bank_target ABILITY_INFILTRATOR INFILTRATOR_PENALTY @ 3. Verifica Infiltrator no alvo
    affected_by_substitute @ Verifica no bank_target @ 4. Verifica se o alvo já tem Substitute (HasSubstituteIgnoringMove)
    jumpifbytevarEQ 1 SUBSTITUTE_PENALTY
    return_cmd

SUBSTITUTE_PENALTY:
    scoreupdate -10 @ Penalidade original para self-substitute
    return_cmd
HP_PENALTY:
    scoreupdate -10 @ Mesma penalidade para HP baixo
    return_cmd
INFILTRATOR_PENALTY:
    scoreupdate -8 @ Penalidade reduzida para Infiltrator
    return_cmd
################################################################################################
DISCOURAGE_SKETCH:
    getlastusedmove bank_target          @ Obtém último movimento usado pelo alvo
    jumpifwordvarEQ 0x0 POINTS_MINUS10  @ Verifica MOVE_NONE (0x0000)
    return_cmd
################################################################################################
DISCOURAGE_TRIPLEKICK:
    jumpifhealthLT bank_ai 30 POINTS_MINUS8  @ 1. Penaliza se o HP do usuário está baixo (<30%)
    getmoveaccuracy  @ Verifica a precisão do golpe
    jumpifbytevarLT 90 POINTS_MINUS5  @ Penaliza levemente devido à chance de erro
    getitemeffect bank_ai 0  @ Verifica o item do atacante
    jumpifbytevarEQ ITEM_EFFECT_WIDELENS POINTS_PLUS5  @ Encoraja se o atacante possui Wide Lens
    checkability bank_target ABILITY_ROUGH_SKIN  @ 2. Verifica se o alvo tem habilidades que punem contato (Rough Skin/Iron Barbs)
    jumpifbytevarEQ 1 APPLY_ROUGH_SKIN_PENALTY
    checkability bank_target ABILITY_IRON_BARBS
    jumpifbytevarEQ 1 APPLY_IRON_BARBS_PENALTY
    getitemeffect bank_target 1  @ Verifica se o alvo possui Rocky Helmet
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET APPLY_ROCKY_HELMET_PENALTY
    jumpifhealthLT bank_target 20 POINTS_MINUS12  @ Penaliza se o HP do alvo é muito baixo (<20%)
    getstatvaluemovechanges bank_target  @ 3. Verifica se o alvo tem evasão alta (>= +3)
    jumpifbytevarGE STAT_EVASION POINTS_MINUS5
    getprotectuses bank_target  @ 4. Verifica se o alvo usa Protect/Detect com frequência
    jumpifbytevarGE 1 POINTS_MINUS10
    jumpifstrikesfirst bank_target bank_ai POINTS_MINUS5  @ 5. Penaliza se o alvo é mais rápido (prioridade)
    return_cmd  @ Fim da lógica

APPLY_ROUGH_SKIN_PENALTY:
    scoreupdate -8  @ Penalidade por Rough Skin
    goto_cmd END_PENALTY
APPLY_IRON_BARBS_PENALTY:
    scoreupdate -8  @ Penalidade por Iron Barbs
    goto_cmd END_PENALTY
APPLY_ROCKY_HELMET_PENALTY:
    scoreupdate -5  @ Penalidade por Rocky Helmet
    goto_cmd END_PENALTY
END_PENALTY:
    return_cmd
################################################################################################
DISCOURAGE_CONVERSION:
    getmoveidbyindex bank_ai 0     @ Pega o ID do primeiro movimento do usuário (slot 0)
    getmovetype                    @ Carrega o tipo desse movimento em uma variável (tipicamente var1)
    isoftype bank_ai -1            @ Compara o tipo do usuário com o tipo em var1 (-1 = usar tipo em var1)
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_TRANSFORM:
	jumpifstatus bank_ai STATUS2_TRANSFORMED POINTS_MINUS10
	jumpifstatus bank_target STATUS2_TRANSFORMED | STATUS2_SUBSTITUTE POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_NIGHTMARE:
    jumpifstatus2 bank_target STATUS2_NIGHTMARE POINTS_MINUS10 @ 1. Verifica se já está sob Nightmare
    jumpifstatus bank_target STATUS_SLEEP CHECK_PARTNER_MOVE @ 2. Verifica se o alvo está dormindo ou com Comatose
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 0x1 CHECK_PARTNER_MOVE
    goto_cmd NEGATIVE_NIG
    
CHECK_PARTNER_MOVE:
    getpartnerchosenmove @ 3. Verifica se o parceiro tem o mesmo movimento
    jumpifwordvarEQ MOVE_NIGHTMARE POINTS_MINUS10
    return_cmd
NEGATIVE_NIG:
	scoreupdate -8
	return_cmd
################################################################################################
DISCOURAGE_IFNOTASLEEP:
	jumpifnostatus bank_target STATUS_SLEEP POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_HAZE:
    getpartnerchosenmove @ Verifica se o parceiro já está usando Haze
    jumpifwordvarEQ MOVE_HAZE POINTS_MINUS10
    @ Verifica stats reduzidas do alvo (não queremos resetar)
    jumpifstatbuffLT bank_target STAT_ATK default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_DEF default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_ATK default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_DEF default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SPD default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_ACC default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_EVASION default_stat_stage POINTS_MINUS10
    isbankpresent bank_targetpartner @ Verifica parceiro do alvo (se existir)
    jumpifbytevarEQ 0 CHECK_ALLY_STATS
    jumpifstatbuffLT bank_targetpartner STAT_ATK default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_DEF default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_SP_ATK default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_SP_DEF default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_SPD default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_ACC default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_targetpartner STAT_EVASION default_stat_stage POINTS_MINUS10
CHECK_ALLY_STATS: @ Verifica stats aumentadas do aliado (não queremos perder)
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SPD default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_ACC default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_EVASION default_stat_stage+2 POINTS_MINUS10
    isbankpresent bank_aipartner @ Verifica parceiro do aliado (se existir)
    jumpifbytevarEQ 0 END_HAZE_CHECK
    jumpifstatbuffGE bank_aipartner STAT_ATK default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_DEF default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_SP_ATK default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_SP_DEF default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_SPD default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_ACC default_stat_stage+2 POINTS_MINUS10
    jumpifstatbuffGE bank_aipartner STAT_EVASION default_stat_stage+2 POINTS_MINUS10
END_HAZE_CHECK:
    return_cmd
################################################################################################
DISCOURAGE_LIGHTSCREEN:
    jumpifsideaffecting bank_ai SIDE_LIGHTSCREEN POINTS_MINUS10 @ Verifica se Light Screen já está ativo no próprio lado
    getpartnerchosenmove @ Verifica se o parceiro já usou Light Screen neste turno
    jumpifwordvarEQ MOVE_LIGHT_SCREEN POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_REFLECT:
    jumpifsideaffecting bank_ai SIDE_REFLECT POINTS_MINUS10 @ Verifica se Reflect já está ativo no próprio lado
    getpartnerchosenmove @ Verifica se o parceiro já usou Reflect neste turno
    jumpifwordvarEQ MOVE_REFLECT POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_LEECHSEED:
    jumpifstatus3 bank_target STATUS3_SEEDED POINTS_MINUS10 @ Verifica se alvo já está seedado
    isoftype bank_target TYPE_GRASS @ Verifica tipo Grass
    jumpifbytevarEQ 0x1 POINTS_MINUS10
    getpartnerchosenmove @ Verifica se parceiro já usou Leech Seed (nova condição)
    jumpifwordvarEQ MOVE_LEECH_SEED POINTS_MINUS10
    checkability bank_target ABILITY_LIQUID_OOZE 1 @ Verifica Liquid Ooze com penalidade específica
    jumpifbytevarEQ 0x1 POINTS_MINUS3  @ Alterado de -10 para -3
    return_cmd
################################################################################################
DISCOURAGE_RAGE:
    isoftype bank_target TYPE_GHOST		@ 1. Verificar se o alvo é do tipo Ghost (imune a Normal, a menos que o usuário tenha Scrappy)
    jumpifbytevarEQ 1 CHECK_SCRAPPY		@ Se Ghost, verifica Scrappy
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS12 @ 2. Verificar se o alvo tem Substitute (Rage não ativa o aumento de Attack)
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+2 POINTS_MINUS10 @ 2. Verificar estágio de Attack do usuário (se já está alto, Rage é menos útil)
    jumpifhealthEQ bank_ai
    jumpifbytevarLT 50 POINTS_NEGATIVE20
    jumpifsideaffecting bank_ai SIDE_SAFEGUARD APPLY_DEFAULT_PENALTY_RAGE
    jumpifstatus bank_ai STATUS_CONFUSION POINTS_MINUS10
    jumpifstatus bank_ai STATUS_PARALYSIS POINTS_MINUS10
APPLY_DEFAULT_PENALTY_RAGE:
    scoreupdate -25  @ Penalidade padrão pelo risco de ficar travado
    goto_cmd RAGE_RETURN
CHECK_SCRAPPY:
    @ Se o usuário tem Scrappy, ignora imunidade Ghost
    checkability bank_ai ABILITY_SCRAPPY 0
    jumpifbytevarEQ 1 RAGE_RETURN  @ Scrappy ativo: ignora penalidade
    goto_cmd POINTS_NEGATIVE30 @ Caso contrário, penaliza
POINTS_NEGATIVE30:
    scoreupdate -30  @ Alvo é Ghost e usuário não tem Scrappy
    goto_cmd RAGE_RETURN
POINTS_NEGATIVE20:
    scoreupdate -20  @ HP do usuário <50%
    goto_cmd RAGE_RETURN
RAGE_RETURN:
    return_cmd
################################################################################################
DISCOURAGE_MIST:
    @ Verifica se Mist já está ativo no próprio lado
    jumpifsideaffecting bank_ai SIDE_MIST POINTS_MINUS10
    @ Verifica se o parceiro já usou Mist (mesmo efeito)
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_MIST PARTNER_USED_MIST
    return_cmd
PARTNER_USED_MIST:
    @ Verifica se o parceiro está presente
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0x0 RETURN_CMD_MIST
    goto_cmd NEGATIVE_MIST
RETURN_CMD_MIST:
    return_cmd
NEGATIVE_MIST:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_ENCORE:
    @ Se o alvo já está sob Encore ou qualquer movimento está desabilitado
    jumpifanymovedisabled_or_encored bank_target 0x1 POINTS_MINUS10
    @ Se o alvo estiver segurando Mental Herb, anula o Encore
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_MENTALHERB POINTS_MINUS10
    @ Verifica se o parceiro do atacante tem efeito de mesmo movimento (impede farm de Encore)
    getpartnerchosenmove       @ carrega o ID do movimento que o parceiro escolheu
    vartovar2                  @ salva esse ID em var2
    getmoveid                  @ carrega o ID do movimento atual em var1
    jumpifvarsEQ POINTS_MINUS10 @ se var1 == var2 (mesmo efeito), penaliza
    @ Se o atacante for mais rápido que o alvo, verifica o último movimento usado
    jumpifstrikesfirst bank_ai bank_target ENCORE_CHECK_LAST_MOVE
    @ Caso contrário (acaba último), aplica penalidade se não houver movimento previsto
    setbytevar 0            @ padrão: nenhum movimento previsto
    jumpifbytevarEQ 0 POINTS_MINUS10
    return_cmd

ENCORE_CHECK_LAST_MOVE:
    @ Obtém o último movimento usado pelo alvo
    getlastusedmove bank_target
    @ Se não há movimento anterior (0 ou 0xFFFF), penaliza
    jumpifwordvarEQ 0 POINTS_MINUS10
    jumpifwordvarEQ 0xFFFF POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_CRAZY:
    getmoveid  @ Obtém o ID do movimento atual
    jumpifmove MOVE_THRASH CHECK_CRAZY_MOVE
    jumpifmove MOVE_PETAL_DANCE CHECK_CRAZY_MOVE
    jumpifmove MOVE_OUTRAGE CHECK_CRAZY_MOVE
    jumpifmove MOVE_RAGING_FURY CHECK_CRAZY_MOVE
    return_cmd  @ Retorna se não for um golpe "crazy"

CHECK_CRAZY_MOVE:
    checkability bank_ai ABILITY_OWN_TEMPO 0  @ 1. Verificar OWN_TEMPO (imune à confusão)
    jumpifbytevarEQ 1 CRAZY_NO_PENALTY
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10  @ 2. Penalizar se o alvo tem Substitute
    jumpifeffectiveness_NE NO_EFFECT POINTS_MINUS30  @ Penalidade severa para imunidade
    jumpifeffectiveness_NE NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penalidade leve para resistência
    getbestdamagelefthp bank_ai bank_target  @ 3. Verificar HP do alvo
    jumpifbytevarLT 30 POINTS_MINUS12  @ Penalizar para evitar overkill
    jumpifstatus2 bank_ai STATUS2_CONFUSION CRAZY_NO_PENALTY  @ 4. Sem penalidade se já confuso
    jumpifsideaffecting bank_ai SIDE_SAFEGUARD CRAZY_NO_PENALTY  @ 5. Sem penalidade se sob efeito de Safeguard
    jumpifweather weather_sun CHECK_PETAL_DANCE_SUN		@ 6. Verificar clima (Petal Dance e Outrage têm interações específicas)
    jumpifweather weather_rain CHECK_OUTRAGE_RAIN
    goto_cmd APPLY_DEFAULT_PENALTY  @ Penalidade padrão

CHECK_PETAL_DANCE_SUN:
    jumpifmove MOVE_PETAL_DANCE CRAZY_NO_PENALTY  @ Sol beneficia Petal Dance (sem penalidade)
    goto_cmd APPLY_DEFAULT_PENALTY
CHECK_OUTRAGE_RAIN:
    jumpifmove MOVE_OUTRAGE CRAZY_NO_PENALTY  @ Chuva não afeta Outrage (sem penalidade)
    goto_cmd APPLY_DEFAULT_PENALTY
APPLY_DEFAULT_PENALTY:
    scoreupdate -25  @ Penalidade padrão por risco de confusão e perda de controle
    goto_cmd CRAZY_RETURN
CRAZY_NO_PENALTY:
    scoreupdate 0  @ Sem penalidade (Own Tempo, já confuso ou Safeguard ativo)
    goto_cmd CRAZY_RETURN
CRAZY_RETURN:
    return_cmd
################################################################################################
DISCOURAGE_DISABLE:
    jumpifanymovedisabled_or_encored bank_target 0x0 POINTS_MINUS10
    getitemeffect bank_target 0x0
    jumpifbytevarEQ ITEM_EFFECT_MENTALHERB POINTS_MINUS10
    @ Verificação de movimento do parceiro
    getpartnerchosenmove
    vartovar2
    getmoveid
    jumpifvarsEQ POINTS_MINUS10
    jumpifstrikesfirst bank_ai bank_target CHECK_LAST_MOVE
    @ Verificação de movimento previsto (simplificada)
    setbytevar 0 @ Valor padrão para nenhum movimento
    jumpifbytevarEQ 0 POINTS_MINUS10
    return_cmd
    
CHECK_LAST_MOVE:
    getlastusedmove bank_target
    jumpifwordvarEQ 0 POINTS_MINUS10
    jumpifwordvarEQ 0xFFFF POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_TELEPORT:
    @ Penalização base para Teleport (equivalente ao ADJUST_SCORE(-10))
    goto_cmd NEGATIVE_TELEPORT
    @ Se precisar de verificações adicionais no futuro, pode-se adicionar aqui
    if_ability bank_ai ABILITY_RUN_AWAY POINTS_PLUS5
    return_cmd
NEGATIVE_TELEPORT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_IFNOLASTMOVE:
    jumpifstrikesfirst bank_ai bank_target CHECK_LAST_MOVE2 @ Verifica se o atacante é mais rápido que o alvo
    setbytevar 0     @ Simula predictedMove == MOVE_NONE
    jumpifbytevarEQ 0 POINTS_MINUS10 @ Penaliza se não há movimento previsto
    return_cmd

CHECK_LAST_MOVE2:
    call_cmd DISCOURAGE_IFNOLASTMOVE @ Reutiliza a lógica existente para verificar o último movimento
    return_cmd
################################################################################################
DISCOURAGE_NATUREPOWER:
    call_cmd TAI_SCRIPT_0   @ Chama AI_CheckBadMove(bank_ai, bank_target, curr_move, score)
    return_cmd
################################################################################################
DISCOURAGE_IFNOALLY:
    jumpifnotdoublebattle POINTS_MINUS10 @ 1. Penaliza se não for Double Battle
    isbankpresent bank_aipartner @ 2. Penaliza se parceiro não está presente/vivo
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    @ 3. Penaliza se parceiro vai usar um movimento de troca/pivot neste turno
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_UTURN POINTS_MINUS10
    jumpifwordvarEQ MOVE_VOLT_SWITCH POINTS_MINUS10
    jumpifwordvarEQ MOVE_PARTING_SHOT POINTS_MINUS10
    jumpifwordvarEQ MOVE_CHILLY_RECEPTION POINTS_MINUS10
    jumpifwordvarEQ MOVE_BATON_PASS POINTS_MINUS10
    jumpifwordvarEQ MOVE_TELEPORT POINTS_MINUS10
    @ 4. Penaliza abilities que forçam troca automática
    checkability bank_aipartner ABILITY_WIMP_OUT
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_aipartner ABILITY_EMERGENCY_EXIT
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 5. Penaliza se o parceiro tem item que pode causar troca (Eject/Red Card)
    getitemeffect bank_aipartner 0
    jumpifbytevarEQ ITEM_EFFECT_EJECTBUTTON POINTS_MINUS10
    jumpifbytevarEQ ITEM_EFFECT_EJECTPACK POINTS_MINUS10
    jumpifbytevarEQ ITEM_EFFECT_REDCARD POINTS_MINUS10
    @ 6. Penaliza se parceiro vai usar o mesmo move
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_FOLLOW_ME POINTS_MINUS10
    jumpifwordvarEQ MOVE_HELPING_HAND POINTS_MINUS10
    jumpifwordvarEQ MOVE_RAGE_POWDER POINTS_MINUS10
    jumpifwordvarEQ MOVE_ALLY_SWITCH POINTS_MINUS10
    @ 7. Penaliza se o move do parceiro for status após getpartnerchosenmove
    getmovesplit
    jumpifbytevarEQ SPLIT_STATUS POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_ROAR:
    @ Verifica se o alvo tem Pokémon utilizáveis na party
    countalivepokes bank_target
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    @ Verifica Suction Cups (incluindo Mold Breaker)
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_MOLD_BREAKER RETURN_CMD_ROAR
    jumpifbytevarEQ ABILITY_TERAVOLT RETURN_CMD_ROAR
    jumpifbytevarEQ ABILITY_TURBOBLAZE RETURN_CMD_ROAR
    checkability bank_target ABILITY_SUCTION_CUPS 1
    jumpifbytevarEQ 0x1 POINTS_MINUS10
RETURN_CMD_ROAR:
    return_cmd
################################################################################################
DISCOURAGE_HITS2x:
    getmoveid
    jumpifmove MOVE_DOUBLE_KICK CHECK_DB 	 	 @ Continua a atacar mesmo após quebrar Substitute
    jumpifmove MOVE_TWINEEDLE CHECK_TWINEEDLE	 @ Continua a atacar mesmo após quebrar Substitute
    jumpifmove MOVE_BONEMERANG CHECK_BONEMERANG  @ Continua a atacar mesmo após quebrar Substitute
    jumpifmove MOVE_DOUBLE_HIT CHECK_DB			 @ Continua a atacar mesmo após quebrar Substitute
    jumpifmove MOVE_DUAL_CHOP CHECK_DB			 @ Continua a atacar mesmo após quebrar Substitute
    jumpifmove MOVE_GEAR_GRIND CHECK_DB			 @ Continua a atacar mesmo após quebrar Substitute
	return_cmd

CHECK_BONEMERANG:
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    return_cmd

CHECK_DB:
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET POINTS_MINUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    return_cmd

CHECK_TWINEEDLE:
    getbankspecies bank_target @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_SHEDINJA POINTS_MINUS30
    checkability bank_target ABILITY_STAMINA 0 @ não compensa muito encorajar isso
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_WEAK_ARMOR 0 @ mesmo caso do de cima, mas é menos pior '-'
    jumpifbytevarEQ 1 POINTS_MINUS10
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK POINTS_PLUS2
    return_cmd
################################################################################################
DISCOURAGE_BIDE:
    @ 1. Se o oponente não tem moves ofensivos
    jumpifattackerhasdamagingmove bank_target
    jumpifbytevarEQ 0 POINTS_MINUS10
    @ 2. Se o HP do usuário está abaixo de 30%
    jumpifhealthLT bank_ai 30 POINTS_MINUS10
    @ 3. Se o oponente está dormindo ou congelado
    jumpifstatus bank_target STATUS_SLEEP POINTS_MINUS10
    jumpifstatus bank_target STATUS_FREEZE POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_PAYDAY:
    call_cmd CHECK_BEST_DMG  @ verifica se tem algum golpe melhor, irrelevante farmar money pra IA '-'
    jumpifbytevarEQ 1 PAY_DAY_PENALTY
    return_cmd
CHECK_BEST_DMG:
    setbytevar 0             @ 0 significa que não tem nada melhor pra usar
    ismostpowerful    @ vai caçar se tem algo de melhor e reporta o valor pra var setada acima
    return_cmd
PAY_DAY_PENALTY:
    scoreupdate -5           @ penaliza se não tiver algo melhor pra usar
    return_cmd
################################################################################################
DISCOURAGE_ONEHITKO:
	getmoveid
    @ 1. Verificação específica para Sheer Cold vs Ice (Gen7+)
    jumpifmove MOVE_SHEER_COLD CHECK_ICE_IMMUNITY
    goto_cmd CHECK_FOCUS_ITEMS
CHECK_ICE_IMMUNITY:
    isoftype bank_target TYPE_ICE
    jumpifbytevarEQ 0x1 POINTS_MINUS30
CHECK_FOCUS_ITEMS:
    @ 2. Verificação precisa de itens (Focus Band/Sash)
    getitemeffect bank_target 1 @ 1 = Ignora efeitos negados (Magic Room, Embargo, etc)
    jumpifbytevarEQ ITEM_EFFECT_FOCUSBAND  CHECK_FOCUS_BAND
    jumpifbytevarEQ ITEM_EFFECT_FOCUSSASH CHECK_FOCUS_SASH
    goto_cmd CHECK_ABILITIES
CHECK_FOCUS_BAND:
    @ 3. Focus Band (10% de chance de ativar)
    jumpifrandLT 10 POINTS_MINUS10 @ 10% chance
    goto_cmd CHECK_ABILITIES
CHECK_FOCUS_SASH:
    @ 4. Focus Sash (verifica HP cheio)
    comparehp bank_target bank_target
    jumpifbytevarEQ 0x0 POINTS_MINUS10 @ Se HP = HP máximo
    goto_cmd CHECK_ABILITIES
CHECK_ABILITIES:
    @ 5. Verifica Sturdy (exceto Mold Breaker)
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_MOLD_BREAKER CHECK_NO_GUARD
    jumpifbytevarEQ ABILITY_TERAVOLT CHECK_NO_GUARD
    jumpifbytevarEQ ABILITY_TURBOBLAZE CHECK_NO_GUARD
    checkability bank_target ABILITY_STURDY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
CHECK_NO_GUARD:
    @ 6. Verifica condições de acerto garantido
    islockon_on bank_ai bank_target
    jumpifbytevarEQ 1 CHECK_LEVEL
    checkability bank_ai ABILITY_NO_GUARD
    jumpifbytevarEQ 1 CHECK_LEVEL
    checkability bank_target ABILITY_NO_GUARD
    jumpifbytevarEQ 1 CHECK_LEVEL
    @ 7. Verificação final de nível
    jumpifleveldifference lvai_lower POINTS_MINUS10
    return_cmd
CHECK_LEVEL:
    jumpifleveldifference lvai_lower POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_GEOMANCY:
    @ 1ª condição: SP_ATK no máximo OU sem movimentos especiais
    getstatvaluemovechanges bank_ai
    jumpifbytevarNE STAT_SP_ATK CHECK_SPEED  @ Só verifica se for aumentar SP_ATK
    @ Verifica SP_ATK no máximo
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    @ Verifica movimentos especiais
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    
CHECK_SPEED:
    @ 2ª condição: Velocidade não pode aumentar
    getstatvaluemovechanges bank_ai
    jumpifbytevarNE STAT_SPD CHECK_SPDEF_GEOMANCY  @ Só verifica se for aumentar SPD
    jumpifbytevarEQ max_stat_stage POINTS_MINUS8
    
CHECK_SPDEF_GEOMANCY:
    @ 3ª condição: SP_DEF não pode aumentar
    getstatvaluemovechanges bank_ai
    jumpifbytevarNE STAT_SP_DEF GEOMANCY_END  @ Só verifica se for aumentar SP_DEF
    jumpifbytevarEQ max_stat_stage POINTS_MINUS5

GEOMANCY_END:
    return_cmd
################################################################################################
DISCOURAGE_MEANLOOK:
    getmovescript
    jumpifbytevarEQ 173 CHECK_FAIRYLOCK_CONDITIONS  @ Fairy Lock tem tratamento especial
    call_cmd CHECK_BATTLER_TRAPPED @ Lógica para Mean Look/Block/Spider Web
    jumpifbytevarEQ 1 POINTS_MINUS10
    getpartnerchosenmove @ Verifica se parceiro já usou movimento similar
    jumpifwordvarEQ MOVE_MEAN_LOOK POINTS_MINUS10
    jumpifwordvarEQ MOVE_BLOCK POINTS_MINUS10
    jumpifwordvarEQ MOVE_SPIDER_WEB POINTS_MINUS10
    if_ability bank_target ABILITY_RUN_AWAY SKIP_TRAP_CHECK @ Verifica condições de escape
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_SHEDSHELL POINTS_MINUS10
SKIP_TRAP_CHECK:
    jumpifnostatus bank_ai STATUS_SLEEP POINTS_MINUS10
    return_cmd
CHECK_FAIRYLOCK_CONDITIONS:
    if_ability bank_target ABILITY_RUN_AWAY SKIP_FAIRYLOCK_CHECK
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_SHEDSHELL POINTS_MINUS10
SKIP_FAIRYLOCK_CHECK:
    jumpifstatus2 bank_target STATUS2_TRAPPED POINTS_MINUS10
    jumpifstatus3 bank_target STATUS3_ROOTED | STATUS3_ONAIR POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_FAIRY_LOCK POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_FAIRY_LOCK POINTS_MINUS10 @ novo
    return_cmd
CHECK_BATTLER_TRAPPED:
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ 1 RETURN_FALSE
    jumpifstatus2 bank_target STATUS2_TRAPPED | STATUS2_WRAPPED RETURN_TRUE
    jumpifstatus3 bank_target STATUS3_ROOTED | STATUS3_ONAIR RETURN_TRUE
    abilitypreventsescape bank_ai bank_target
    jumpifbytevarEQ 1 RETURN_TRUE
    setbytevar 0
    return_cmd
RETURN_TRUE:
    setbytevar 1
    return_cmd
RETURN_FALSE:
    setbytevar 0
    return_cmd
################################################################################################
DISCOURAGE_HEALBLOCK:
	jumpifbankaffecting bank_target BANK_AFFECTING_HEALBLOCK POINTS_MINUS10
	getpartnerchosenmove
	jumpifwordvarEQ MOVE_HEAL_BLOCK POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_TORMENT:
    @ Verifica se o alvo já está sob Torment
    jumpifstatus2 bank_target STATUS2_TORMENTED POINTS_MINUS10
    @ Verifica se o parceiro já usou Torment no mesmo alvo
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0x0 CHECK_MENTAL_HERB @ Se não tem parceiro, pula
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_TORMENT POINTS_MINUS10

CHECK_MENTAL_HERB:
    @ Verifica Mental Herb
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_MENTALHERB POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_TAUNT:
    jumpiftargettaunted POINTS_MINUS10 @ Verifica se o alvo está sob efeito de Taunt e penaliza
    getpartnerchosenmove               @ Obtém o movimento escolhido pelo parceiro
    jumpifwordvarEQ MOVE_TAUNT POINTS_MINUS10 @ Se for Taunt, penaliza -10
    return_cmd
################################################################################################
DISCOURAGE_REFLECT_TYPE:
    @ Verifica se o AI e o alvo já compartilham tipos
    sharetype bank_ai bank_target
    jumpifbytevarEQ 1 END_DISCOURAGE  @ Se tipos iguais, desencorajar
    @ Verifica se o alvo tem um ou dois tipos
    gettypeinfo AI_TYPE1_TARGET
    jumpifbytevarEQ TYPE_EGG SINGLE_TYPE  @ Se AI_TYPE1_TARGET é inválido, trata como tipo único
    @ Analisa o primeiro tipo do alvo
    gettypeinfo AI_TYPE1_TARGET
    getability bank_ai 0  @ Obtém habilidade do AI (sem Gastro Acid)
    if_ability bank_ai ABILITY_ADAPTABILITY ADAPT_PENALTY  @ Exemplo: penaliza se tiver Adaptability
    @ Analisa o segundo tipo do alvo (se existir)
    gettypeinfo AI_TYPE2_TARGET
    jumpifbytevarEQ TYPE_EGG CHECK_WEATHER  @ Pula se não houver segundo tipo
    call_cmd DUAL_TYPE  @ NOVO: Chama a lógica de tipos duplos

DUAL_TYPE:
    @ Lógica para dois tipos (ex: verificar fraquezas combinadas)
    scoreupdate -10  @ Penalidade alta para tipos duplos perigosos
    call_cmd CHECK_WEATHER  @ Continua para verificar clima
SINGLE_TYPE:
    @ Lógica para tipo único
    scoreupdate -5  @ Penalidade moderada
    call_cmd CHECK_WEATHER
ADAPT_PENALTY:
    @ Penalidade adicional para habilidades que aumentam risco
    scoreupdate -3
    call_cmd CHECK_WEATHER
CHECK_WEATHER:
    jumpifweather weather_rain RAIN_PENALTY
    jumpifweather weather_sun SUN_PENALTY
    jumpifweather weather_sandstorm SANDSTORM_PENALTY
    jumpifweather weather_hail HAIL_PENALTY
    call_cmd HAZARDS_CHECK  @ Se nenhum clima, verifica hazards
RAIN_PENALTY:
    @ Desencoraja tipos fracos contra Água (ex: Fogo, Pedra)
    scoreupdate -5
    call_cmd HAZARDS_CHECK
SUN_PENALTY:
    @ Desencoraja tipos fracos contra Fogo (ex: Planta, Gelo)
    scoreupdate -5
    call_cmd HAZARDS_CHECK
SANDSTORM_PENALTY:
    @ Desencoraja tipos não imunes a areia (ex: não Pedra/Terra/Aço)
    scoreupdate -5
    call_cmd HAZARDS_CHECK
HAIL_PENALTY:
    @ Desencoraja tipos não imunes a granizo (ex: não Gelo)
    scoreupdate -5
    call_cmd HAZARDS_CHECK
HAZARDS_CHECK:
    arehazardson bank_ai
    jumpifvarsNE POINTS_MINUS8
    call_cmd END_DISCOURAGE
END_DISCOURAGE:
    return_cmd
################################################################################################
DISCOURAGE_FOCUSENERGY:
    @ Verifica STATUS2_PUMPEDUP (equivalente a STATUS2_FOCUS_ENERGY_ANY)
    jumpifstatus2 bank_ai STATUS2_PUMPEDUP POINTS_MINUS10
    @ Verificação adicional para habilidades que afetam criticos
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_SUPER_LUCK CHECK_CRIT_RATE
    jumpifbytevarEQ ABILITY_SNIPER CHECK_CRIT_RATE
    return_cmd
CHECK_CRIT_RATE:
    @ Se tem habilidade que beneficia de críticos, reduz penalidade
    hashighcriticalratio
    jumpifbytevarEQ 0x0 POINTS_MINUS5  @ Penalidade menor se não tiver movimentos com alta taxa de crítico
    return_cmd
################################################################################################
DISCOURAGE_SYNCHRONOISE:
    getitemeffect bank_target 1
    jumpifbytevarEQ ITEM_EFFECT_RINGTARGET RETURN_CMD_SYNCHRO
    sharetype bank_ai bank_target
    jumpifbytevarEQ 0x0 POINTS_MINUS10

RETURN_CMD_SYNCHRO:
    return_cmd
################################################################################################
DISCOURAGE_IFNOTDOUBLE:
	jumpifnotdoublebattle POINTS_MINUS8
	return_cmd
################################################################################################
DISCOURAGE_AFTER_YOU:
    jumpifnotdoublebattle POINTS_MINUS10
    jumpiftargetisally CONTINUE_CHECK
CONTINUE_CHECK:
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_AFTER_YOU POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_POWDER:
    jumpifhasattackingmovewithtype bank_target TYPE_FIRE CHECK_POWDER_PARTNER @ 1) Se o defensor NÃO tiver nenhum movimento de tipo Fogo, penaliza
    goto_cmd NEGATIVE_POWDER

CHECK_POWDER_PARTNER:
    getpartnerchosenmove @ 2) Se o parceiro também escolheu Powder, penaliza
    jumpifwordvarEQ MOVE_POWDER POINTS_MINUS10
    return_cmd @ caso contrário, nada a penalizar
NEGATIVE_POWDER:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_AROMATIC_MIST:
    jumpifnotdoublebattle POINTS_MINUS10           @ Penaliza se não é double
    isbankpresent bank_aipartner
    jumpifbytevarEQ 0 POINTS_MINUS10               @ Penaliza se parceiro está morto/ausente
    checkability bank_aipartner ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_CONTRARY               @ Se parceiro tem Contrary, vai para checagem especial
    jumpifstatbuffEQ bank_aipartner STAT_SP_DEF max_stat_stage+6 POINTS_MINUS10 @ Se já está no máximo, penaliza
    goto_cmd AROMATIC_MIST_VALID
CHECK_CONTRARY:
    jumpifstatbuffEQ bank_aipartner STAT_SP_DEF min_stat_stage POINTS_MINUS10 @ Se Contrary e já está no mínimo, penaliza
AROMATIC_MIST_VALID:
    return_cmd
################################################################################################
DISCOURAGE_CLEARSMOG:
    goto_cmd CHECK_IMMUNITIES_CS                  @ Verifica imunidades ao tipo Poison
    goto_cmd CHECK_SUBSTITUTE_CS                  @ Verifica se o alvo está protegido por Substitute
    goto_cmd CHECK_PROTECTION_STATUS           @ Verifica se o alvo está usando movimentos de proteção
    goto_cmd CHECK_STAT_BOOSTS_CS                 @ Verifica se o alvo tem boosts de status
    goto_cmd CHECK_SEMI_INVULNERABILITY        @ Verifica se o alvo está em semi-invulnerabilidade
    checkability bank_target ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_CONTRARY_CS
    return_cmd

CHECK_IMMUNITIES_CS:
    @ Verifica imunidades ao tipo Poison
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS10          @ Penaliza se o alvo for do tipo Steel
    checkability bank_target ABILITY_MAGIC_GUARD 1
    jumpifbytevarEQ 1 POINTS_MINUS10          @ Penaliza se o alvo tiver Magic Guard
    checkability bank_target ABILITY_LEVITATE 1
    jumpifbytevarEQ 1 POINTS_MINUS5           @ Penaliza se Levitate tornar o alvo imune
    return_cmd

CHECK_SUBSTITUTE_CS:
    @ Penaliza se o alvo estiver protegido por Substitute
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10          @ Penaliza se o Substitute bloquear Clear Smog
    return_cmd

CHECK_PROTECTION_STATUS_CS:
    @ Penaliza se o alvo estiver protegido por Protect ou similar
    getprotectuses bank_target
    jumpifbytevarGE 1 POINTS_MINUS8           @ Penaliza se o alvo estiver protegido
    return_cmd

CHECK_STAT_BOOSTS_CS:
    @ penaliza se o adversário tiver debuff (ou seja, Clear Smog vai ajudaria o adversário se usasse)
    jumpifstatbuffLT bank_target STAT_ATK 	  default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_DEF     default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SPD 	  default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_ATK  default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_SP_DEF  default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_ACC 	  default_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_EVASION default_stat_stage POINTS_MINUS10
    @ encoraja se algum stat ofensivo/defensivo estiver +2 ou mais
    jumpifstatbuffGE bank_target STAT_ATK  default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffGE bank_target STAT_DEF  default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffGE bank_target STAT_SPD  default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffGE bank_target STAT_SP_ATK  default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffGE bank_target STAT_SP_DEF  default_stat_stage+2 POINTS_PLUS10
    @ bônus menor se for apenas +1 nesses stats porque são os mais importantes
    jumpifstatbuffEQ bank_target STAT_ATK  default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffEQ bank_target STAT_DEF  default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffEQ bank_target STAT_SPD  default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffEQ bank_target STAT_SP_ATK  default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffEQ bank_target STAT_SP_DEF  default_stat_stage+1 POINTS_PLUS5
    @ só encoraja se a evasão e/ou precisão do adversário for MUITO alta (+3 ou mais)
    jumpifstatbuffGE bank_target STAT_ACC     default_stat_stage+3 POINTS_PLUS3
    jumpifstatbuffGE bank_target STAT_EVASION default_stat_stage+3 POINTS_PLUS3
    return_cmd

CHECK_CONTRARY_CS:
    @ Penaliza fortemente se houver debuff (pois Contrary vai inverter)
    jumpifstatbuffLT bank_target STAT_ATK		  	 default_stat_stage-1 POINTS_MINUS12
    jumpifstatbuffLT bank_target STAT_DEF		 	 default_stat_stage-1 POINTS_MINUS12
    jumpifstatbuffLT bank_target STAT_SPD			 default_stat_stage-1 POINTS_MINUS12
    jumpifstatbuffLT bank_target STAT_SP_ATK		 default_stat_stage-1 POINTS_MINUS12
    jumpifstatbuffLT bank_target STAT_SP_DEF		 default_stat_stage-1 POINTS_MINUS12
    jumpifstatbuffLT bank_target STAT_ACC			 default_stat_stage-2 POINTS_MINUS10
    jumpifstatbuffLT bank_target STAT_EVASION		 default_stat_stage-2 POINTS_MINUS10
    @ se o target com Contrary tiver qualquer buff, encoraja o uso de Clear Smog pois transformará o buff em debuff
    jumpifstatbuffEQ bank_target STAT_ATK  			 default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_ATK  	 		 default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffEQ bank_target STAT_DEF  	 		 default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_DEF  	 		 default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffGE bank_target STAT_SP_DEF 		 default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffEQ bank_target STAT_SP_DEF 		 default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_SP_ATK 		 default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffEQ bank_target STAT_SP_ATK 		 default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_SPD  	 		 default_stat_stage+2 POINTS_PLUS10
    jumpifstatbuffEQ bank_target STAT_SPD  	 		 default_stat_stage+1 POINTS_PLUS5
    jumpifstatbuffGE bank_target STAT_ACC    		 default_stat_stage+3 POINTS_PLUS3
    jumpifstatbuffGE bank_target STAT_EVASION		 default_stat_stage+3 POINTS_PLUS3
    return_cmd

CHECK_SEMI_INVULNERABILITY:
    @ Penaliza se o alvo estiver em semi-invulnerabilidade (Fly, Dig, etc.)
    isinsemiinvulnerablestate bank_target
    jumpifbytevarEQ 1 POINTS_MINUS10          @ Penaliza se o alvo estiver semi-invulnerável
    return_cmd
################################################################################################
DISCOURAGE_ELECTRIFY:
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_ELECTRIFY POINTS_MINUS10 
    jumpifstatus bank_target STATUS_SLEEP POINTS_MINUS5 @ Sugestão 1: Se o alvo estiver impedido de atacar, o golpe se torna menos útil
    jumpifstatus bank_target STATUS_FREEZE POINTS_MINUS5
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS5
    jumpifstatus2 bank_target STATUS2_FLINCHED POINTS_MINUS5
    getability bank_target 1 @ Sugestão 2: Habilidade do alvo pode anular ou ignorar efeitos indiretos
    jumpifbytevarEQ ABILITY_MOLD_BREAKER POINTS_MINUS5
    jumpifbytevarEQ ABILITY_TERAVOLT POINTS_MINUS5
    jumpifbytevarEQ ABILITY_TURBOBLAZE POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_ENTRYHAZARDS: @movescript 53 utilizado pelos mesmos golpes listados acima
    countalivepokes bank_target
    jumpifbytevarEQ 0 POINTS_MINUS10 @ Não há sentido colocar hazard se não há inimigos vivos
    if_ability bank_target ABILITY_MAGIC_BOUNCE POINTS_MINUS12 @ Verificação adicional
    getpartnerchosenmove            @ Pega o move do parceiro
    vartovar2                       @ Salva em var2
    discouragehazards              @ Aplica penalização contextual conforme acima
    return_cmd
################################################################################################
DISCOURAGE_NATURALGIFT:
    getability bank_ai @ Verifica se a habilidade do atacante é Klutz
    jumpifbytevarEQ ABILITY_KLUTZ POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MAGICROOM POINTS_MINUS10 @ Verifica se o campo está sob efeito de Magic Room
    getitempocket bank_ai @ Verifica se o item do atacante está no pocket de berries
    jumpifbytevarNE 4 POINTS_MINUS10
    jumpifbankaffecting bank_ai BANK_AFFECTING_EMBARGO POINTS_MINUS8 @ Verifica se o atacante está sob efeito de Embargo
    return_cmd
################################################################################################
DISCOURAGE_EMBARGO:
    jumpifbankaffecting bank_target BANK_AFFECTING_EMBARGO POINTS_MINUS10 @ 1) Se o alvo já está sob Embargo (embargoTimer != 0)
    getpartnerchosenmove @ 2) Se o parceiro também escolheu EMBARGO neste turno
    jumpifwordvarEQ MOVE_EMBARGO POINTS_MINUS10 @3) Se Magic Room está ativo no campo
    jumpiffieldaffecting FIELD_AFFECTING_MAGICROOM POINTS_MINUS10
    getability bank_target 1 @ 4) Se o alvo tem Klutz
    jumpifbytevarEQ ABILITY_KLUTZ POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_GASTROACID:
	jumpifbankaffecting bank_target BANK_AFFECTING_GASTROACID POINTS_MINUS10
	getability bank_target 0
	jumpifbytevarEQ ABILITY_STANCE_CHANGE POINTS_MINUS8
	jumpifbytevarEQ ABILITY_MULTITYPE POINTS_MINUS8
	jumpifbytevarEQ ABILITY_ZEN_MODE POINTS_MINUS8
	jumpifbytevarEQ ABILITY_SHIELDS_DOWN POINTS_MINUS8
	jumpifbytevarEQ ABILITY_SCHOOLING POINTS_MINUS8
	jumpifbytevarEQ ABILITY_DISGUISE POINTS_MINUS8
	jumpifbytevarEQ ABILITY_BATTLE_BOND POINTS_MINUS8
	jumpifbytevarEQ ABILITY_POWER_CONSTRUCT POINTS_MINUS8
	jumpifbytevarEQ ABILITY_COMATOSE POINTS_MINUS8
	jumpifbytevarEQ ABILITY_RKS_SYSTEM POINTS_MINUS8
	return_cmd
################################################################################################
DISCOURAGE_ROOMS:
	getmoveid
    jumpifmove MOVE_TRICK_ROOM DISCOURAGE_TRICKROOM
    jumpifmove MOVE_WONDER_ROOM DISCOURAGE_WONDERROOM
    jumpifmove MOVE_MAGIC_ROOM DISCOURAGE_MAGICROOM
    return_cmd

DISCOURAGE_TRICKROOM:
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_TRICK_ROOM POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM CHECK_TRICKROOM_LOGIC
    @ Trick Room não está ativo: penaliza se o lado da IA é mais rápido
    jumpifstrikesfirst bank_ai bank_target POINTS_MINUS10
    return_cmd

CHECK_TRICKROOM_LOGIC:
    @ Se Trick Room está ativo: penaliza se o lado da IA é mais lento (equivalente a GetBattlerSideSpeedAverage)
    jumpifstrikesfirst bank_target bank_ai POINTS_MINUS10
    return_cmd

DISCOURAGE_WONDERROOM:
    @ Verifica se parceiro já escolheu Wonder Room
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_WONDER_ROOM POINTS_MINUS10
    @ Verifica se Wonder Room já está ativo
    jumpiffieldaffecting FIELD_AFFECTING_WONDERROOM POINTS_MINUS10
    return_cmd

DISCOURAGE_MAGICROOM:
    @ Verifica se parceiro já escolheu Magic Room
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_MAGIC_ROOM POINTS_MINUS10
    @ Verifica se Magic Room já está ativo
    jumpiffieldaffecting FIELD_AFFECTING_MAGICROOM POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_COUNTER: @ Para movescript 44 (Counter/Mirror Coat/Metal Burst)
	jumpifstrikesfirst bank_ai bank_target POINTS_MINUS12
    @ Verifica se o alvo está incapacitado ou com status problemático
    jumpifstatus2 bank_target STATUS2_CONFUSION | STATUS2_INLOVE LIGHT_PENALTY
    jumpifstatus bank_target STATUS_SLEEP | STATUS_FREEZE | STATUS_PARALYSIS LIGHT_PENALTY
    @ Verifica situação de movimento previsto
    getpartnerchosenmove
    jumpifwordvarEQ 0 HEAVY_PENALTY
    @ Verifica se é movimento de status
    getmoveid
    jumpifwordvarEQ 0 HEAVY_PENALTY @ Fallback caso não tenha movimento
    getmovesplit
    jumpifbytevarEQ SPLIT_STATUS HEAVY_PENALTY
    jumpifbytevarEQ SPLIT_SPECIAL HEAVY_PENALTY
    @ Verifica bloqueio por Substitute
    affected_by_substitute
    jumpifbytevarEQ 1 HEAVY_PENALTY
    goto_cmd END_COUNTER_CHECKS
    
LIGHT_PENALTY:
    scoreupdate -3
    goto_cmd END_COUNTER_CHECKS
HEAVY_PENALTY:
    scoreupdate -10
    goto_cmd END_COUNTER_CHECKS
CHECK_NO_PREDICTED_MOVE:
    @ Verificação mais robusta para quando não há movimento previsto
    if_ability bank_ai ABILITY_PRANKSTER END_COUNTER_CHECKS
    if_ability bank_ai ABILITY_ADAPTABILITY END_COUNTER_CHECKS
    goto_cmd HEAVY_PENALTY
END_COUNTER_CHECKS:
    return_cmd
################################################################################################
DISCOURAGE_ABILITYCHANGE:
    @ 1. Verifica se as habilidades são iguais
    checkability bank_ai 0             @ Obtém habilidade do usuário
    vartovar2                         @ Salva em var2
    checkability bank_target 0        @ Obtém habilidade do alvo
    jumpifvarsEQ POINTS_MINUS10       @ Se iguais, penaliza -10
	canchangeability bank_ai bank_target
	jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_ONESTATUSER:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_ATK CHECK_PHYSICAL_MOVES
    jumpifbytevarEQ STAT_DEF CHECK_DEFENSE_OR_CURL
    jumpifbytevarEQ STAT_SP_ATK CHECK_SPECIAL_MOVES
    jumpifbytevarEQ STAT_SP_DEF CHECK_SPDEF
    jumpifbytevarEQ STAT_ACC CHECK_ACCURACY
    jumpifbytevarEQ STAT_EVASION CHECK_EVASION_OR_MINIMIZE
    jumpifbytevarEQ STAT_SPD CHECK_SPEED_OR_AUTONOMIZE
    return_cmd

CHECK_PHYSICAL_MOVES:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    hasanymovewithsplit bank_ai SPLIT_PHYSICAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd

CHECK_SPECIAL_MOVES:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x0 POINTS_MINUS10
    return_cmd

CHECK_DEFENSE_OR_CURL:
    getmovescript
    jumpifbytevarEQ 83 CHECK_DEFENSE_CURL
    @ Caso normal para outros movimentos de defesa
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_DEFENSE_CURL:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    jumpifstatus2 bank_ai STATUS2_CURLED POINTS_MINUS10
    return_cmd

CHECK_SPDEF:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_ACCURACY:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_EVASION_OR_MINIMIZE:
    getmovescript
    jumpifbytevarEQ 82 CHECK_MINIMIZE
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_MINIMIZE:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    jumpifstatus3 bank_ai STATUS3_MINIMIZED POINTS_MINUS10
    return_cmd

CHECK_SPEED_OR_AUTONOMIZE:
    getmovescript
    jumpifbytevarEQ 56 CHECK_AUTONOMIZE
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_AUTONOMIZE:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ max_stat_stage POINTS_MINUS10
    if_ability bank_ai ABILITY_SPEED_BOOST POINTS_MINUS5 @ Penaliza menos se já tem Speed Boost
    return_cmd
################################################################################################
DISCOURAGE_IONDELUGE:
    @ Penalize if Ion Deluge is active on field
    jumpiffieldaffecting FIELD_AFFECTING_ION_DELUGE POINTS_MINUS10
    @ Penalize if partner already chose Ion Deluge
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_ION_DELUGE POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_CAMOUFLAGE:
    @ Penaliza em batalhas duplas
    jumpifdoublebattle POINTS_MINUS10
    @ Verifica o terreno ativo
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN CHECK_ELECTRIC_PRE
    jumpiffieldaffecting FIELD_AFFECTING_GRASSY_TERRAIN CHECK_GRASS_PRE
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN CHECK_FAIRY_PRE
    jumpiffieldaffecting FIELD_AFFECTING_PSYCHIC_TERRAIN CHECK_PSYCHIC_PRE
    return_cmd  @ Sem terreno ativo: não penaliza

CHECK_ELECTRIC_PRE:
    @ Verifica se o tipo Elétrico é vantajoso OFENSIVAMENTE (contra Water/Flying)
    isoftype bank_target TYPE_WATER | TYPE_FLYING
    jumpifbytevarEQ 1 CHECK_ELECTRIC_TYPE
    @ Verifica se o tipo Elétrico é vantajoso DEFENSIVAMENTE (imune a Ground)
    getmovetype
	isoftype bank_target TYPE_GROUND
    jumpifbytevarEQ 1 CHECK_ELECTRIC_TYPE 
    goto_cmd PENALTY  @ Não é útil: penaliza

CHECK_GRASS_PRE:
    @ Verifica vantagem ofensiva (contra Ground/Rock/Water)
    isoftype bank_target TYPE_GROUND | TYPE_ROCK | TYPE_WATER
    jumpifbytevarEQ 1 CHECK_GRASS_TYPE
    @ Verifica vantagem defensiva (resistência a Ground/Water)
    getmovetype
	isoftype bank_target TYPE_GROUND | TYPE_WATER | TYPE_ROCK | TYPE_ELECTRIC
    jumpifbytevarEQ 1 CHECK_GRASS_TYPE
    goto_cmd PENALTY

CHECK_FAIRY_PRE:
    @ Verifica vantagem ofensiva (contra Dragon/Dark/Fighting)
    isoftype bank_target TYPE_DRAGON | TYPE_DARK | TYPE_FIGHTING
    jumpifbytevarEQ 1 CHECK_FAIRY_TYPE
    @ Verifica vantagem defensiva (imunidade a Dragon, resistência a Dark/Fighting)
    getmovetype
	isoftype bank_target TYPE_DRAGON | TYPE_DARK | TYPE_FIGHTING
    jumpifbytevarEQ 1 CHECK_FAIRY_TYPE
    goto_cmd PENALTY

CHECK_PSYCHIC_PRE:
    @ Verifica vantagem ofensiva (contra Poison/Fighting)
    isoftype bank_target TYPE_POISON | TYPE_FIGHTING
    jumpifbytevarEQ 1 CHECK_PSYCHIC_TYPE
    @ Verifica vantagem defensiva (resistência a Fighting/Poison)
    getmovetype
	isoftype bank_target TYPE_FIGHTING | TYPE_POISON
    jumpifbytevarEQ 1 CHECK_PSYCHIC_TYPE
    goto_cmd PENALTY

CHECK_ELECTRIC_TYPE:
    isoftype bank_ai TYPE_ELECTRIC
    jumpifbytevarEQ 1 POINTS_MINUS10  @ Redundante: penaliza
    return_cmd

CHECK_GRASS_TYPE:
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd

CHECK_FAIRY_TYPE:
    isoftype bank_ai TYPE_FAIRY
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd

CHECK_PSYCHIC_TYPE:
    isoftype bank_ai TYPE_PSYCHIC
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd

PENALTY:
    scoreupdate -10
    return_cmd
################################################################################################
DISCOURAGE_USERSTAT_CHANCE:
    getmoveid
    jumpifwordvarEQ MOVE_STEEL_WING   CHECK_STEEL_WING
    jumpifwordvarEQ MOVE_METEOR_MASH  CHECK_METEOR_MASH
    jumpifwordvarEQ MOVE_METAL_CLAW   CHECK_METAL_CLAW
    jumpifwordvarEQ MOVE_OVERHEAT     CHECK_OVERHEAT
    jumpifwordvarEQ MOVE_PSYCHO_BOOST CHECK_PSYCHO_BOOST
    jumpifwordvarEQ MOVE_DRACO_METEOR CHECK_DRACO_METEOR
    jumpifwordvarEQ MOVE_LEAF_STORM   CHECK_LEAF_STORM
    jumpifwordvarEQ MOVE_ICE_HAMMER   CHECK_ICE_HAMMER
    jumpifwordvarEQ MOVE_FLEUR_CANNON CHECK_FLEUR_CANNON
    jumpifwordvarEQ MOVE_HAMMER_ARM   CHECK_HAMMER_ARM
    jumpifwordvarEQ MOVE_CHARGE_BEAM  CHECK_CHARGE_BEAM
    jumpifwordvarEQ MOVE_FLAME_CHARGE CHECK_FLAME_CHARGE
    jumpifwordvarEQ MOVE_FIERY_DANCE  CHECK_FIERY_DANCE
    jumpifwordvarEQ MOVE_DIAMOND_STORM CHECK_DIAMOND_STORM
    jumpifwordvarEQ MOVE_POWERUP_PUNCH CHECK_POWER_UP_PUNCH
    jumpifwordvarEQ MOVE_HYPERSPACE_FURY CHECK_HYPERSPACE_FURY
    goto_cmd GENERIC_STATCHANGE_CHECK

@ --- Steel Wing (+10% DEF) ---
CHECK_STEEL_WING:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_STEEL_WING_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_DEF 10 POINTS_MINUS3  @ +4 ou +5
    jumpifstatbuffGE bank_ai STAT_DEF 8 POINTS_MINUS1   @ +2 ou +3
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_STEEL_WING_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_DEF 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_DEF 8 RETURN_CMD_MAIN
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Meteor Mash (+10% ATK) ---
CHECK_METEOR_MASH:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_METEOR_MASH_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_ATK 8 POINTS_MINUS1
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_METEOR_MASH_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 8 RETURN_CMD_MAIN
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Metal Claw (+10% ATK) ---
CHECK_METAL_CLAW:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_METAL_CLAW_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_ATK 8 POINTS_MINUS1
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_METAL_CLAW_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 8 RETURN_CMD_MAIN
    jumpifrandLT 20 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Overheat (−2 SP.ATK) ---
CHECK_OVERHEAT:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_OVERHEAT_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_OVERHEAT_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS5     @ -4 ou -5
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS3     @ -2 ou -3
    return_cmd
CHECK_OVERHEAT_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS5
    return_cmd
CHECK_OVERHEAT_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS3
    return_cmd

@ --- Psycho Boost (−2 SP.ATK) ---
CHECK_PSYCHO_BOOST:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_PSYCHO_BOOST_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_PSYCHO_BOOST_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS3
    return_cmd
CHECK_PSYCHO_BOOST_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS5
    return_cmd
CHECK_PSYCHO_BOOST_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS3
    return_cmd

@ --- Draco Meteor / Leaf Storm (−2 SP.ATK) ---
CHECK_DRACO_METEOR:
CHECK_LEAF_STORM:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_DRACO_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_DRACO_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS3
    return_cmd
CHECK_DRACO_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS5
    return_cmd
CHECK_DRACO_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS3
    return_cmd

@ --- Ice Hammer (−1 SPD) ---
CHECK_ICE_HAMMER:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_ICE_HAMMER_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_ICE_HAMMER_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_SPD 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SPD 4 POINTS_MINUS3
    return_cmd
CHECK_ICE_HAMMER_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS12
    jumpifstatbuffLT bank_ai STAT_SPD 2 POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_SPD 4 POINTS_MINUS5
    return_cmd
CHECK_ICE_HAMMER_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_SPD 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SPD 8 POINTS_MINUS3
    return_cmd

@ --- Fleur Cannon (−2 SP.ATK) ---
CHECK_FLEUR_CANNON:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_FLEUR_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_FLEUR_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS3
    return_cmd
CHECK_FLEUR_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS10
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS5
    return_cmd
CHECK_FLEUR_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS3
    return_cmd

@ --- Hammer Arm (-1 SPD) ---
CHECK_HAMMER_ARM:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_HAMMER_ARM_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_HAMMER_ARM_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_SPD 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SPD 4 POINTS_MINUS3
    return_cmd
CHECK_HAMMER_ARM_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS12
    jumpifstatbuffLT bank_ai STAT_SPD 2 POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_SPD 4 POINTS_MINUS5
    return_cmd
CHECK_HAMMER_ARM_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_SPD 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SPD 8 POINTS_MINUS3
    return_cmd

@ --- Charge Beam (+70% SP.ATK) ---
CHECK_CHARGE_BEAM:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_CHARGE_BEAM_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS1
    jumpifrandLT 70 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_CHARGE_BEAM_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 RETURN_CMD_MAIN
    jumpifrandLT 70 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Flame Charge (+1 SPD) ---
CHECK_FLAME_CHARGE:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_FLAME_CHARGE_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_FLAME_CHARGE_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SPD 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_SPD 8 POINTS_MINUS1
    return_cmd
CHECK_FLAME_CHARGE_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SPD 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SPD 8 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1
CHECK_FLAME_CHARGE_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SPD 2 POINTS_MINUS3
    jumpifstatbuffLT bank_ai STAT_SPD 4 POINTS_MINUS1
    return_cmd

@ --- Fiery Dance (+50% SP.ATK) ---
CHECK_FIERY_DANCE:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_FIERY_DANCE_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS1
    jumpifrandLT 50 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_FIERY_DANCE_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 RETURN_CMD_MAIN
    jumpifrandLT 50 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Diamond Storm (+50% DEF) ---
CHECK_DIAMOND_STORM:
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_DIAMOND_STORM_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_DEF 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_DEF 8 POINTS_MINUS1
    jumpifrandLT 50 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC
CHECK_DIAMOND_STORM_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_DEF 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_DEF 8 RETURN_CMD_MAIN
    jumpifrandLT 50 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1

@ --- Power-Up Punch (+1 ATK) ---
CHECK_POWER_UP_PUNCH:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_POWER_UP_PUNCH_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_POWER_UP_PUNCH_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_ATK 8 POINTS_MINUS1
    return_cmd
CHECK_POWER_UP_PUNCH_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 8 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1
CHECK_POWER_UP_PUNCH_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_ATK min_stat_stage POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_ATK 2 POINTS_MINUS3
    jumpifstatbuffLT bank_ai STAT_ATK 4 POINTS_MINUS1
    return_cmd

@ --- Hyperspace Fury (-1 DEF) ---
CHECK_HYPERSPACE_FURY:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_HYPERSPACE_FURY_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_HYPERSPACE_FURY_SIMPLE
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_DEF 2 POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_DEF 4 POINTS_MINUS3
    return_cmd
CHECK_HYPERSPACE_FURY_SIMPLE:
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_WHITEHERB RETURN_CMD_MAIN
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS12
    jumpifstatbuffLT bank_ai STAT_DEF 2 POINTS_MINUS8
    jumpifstatbuffLT bank_ai STAT_DEF 4 POINTS_MINUS5
    return_cmd
CHECK_HYPERSPACE_FURY_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_DEF 10 POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_DEF 8 POINTS_MINUS3
    return_cmd

@ --- Genérico para stat-changes ---
GENERIC_STATCHANGE_CHECK:
    getstatvaluemovechanges bank_ai
    jumpifbytevarEQ STAT_ATK   CHECK_ATK_STAT
    jumpifbytevarEQ STAT_SP_ATK CHECK_SPATK_STAT
    return_cmd

CHECK_ATK_STAT:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_ATK_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_ATK_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_ATK 8 POINTS_MINUS1
    return_cmd
CHECK_ATK_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_ATK 8 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1
CHECK_ATK_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_ATK min_stat_stage POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_ATK 2 POINTS_MINUS3
    jumpifstatbuffLT bank_ai STAT_ATK 4 POINTS_MINUS1
    return_cmd

CHECK_SPATK_STAT:
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_SPATK_CONTRARY
    checkability bank_ai ABILITY_SIMPLE 1
    jumpifbytevarEQ 1 CHECK_SPATK_SIMPLE
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS5
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 POINTS_MINUS3
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 POINTS_MINUS1
    return_cmd
CHECK_SPATK_SIMPLE:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 10 RETURN_CMD_MAIN
    jumpifstatbuffGE bank_ai STAT_SP_ATK 8 RETURN_CMD_MAIN
    goto_cmd NEGATIVE_USC1
CHECK_SPATK_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS5
    jumpifstatbuffLT bank_ai STAT_SP_ATK 2 POINTS_MINUS3
    jumpifstatbuffLT bank_ai STAT_SP_ATK 4 POINTS_MINUS1
    return_cmd
RETURN_CMD_MAIN:
    return_cmd
NEGATIVE_USC:
	scoreupdate -3
	return_cmd
NEGATIVE_USC1:
	scoreupdate -1
	return_cmd
################################################################################################
DISCOURAGE_ONESTATTARGET:
    @ Verifica se a mudança é positiva (para Contrary)
    isstatchangepositive
    jumpifbytevarEQ 0x1 POINTS_MINUS10 @ Penaliza se Contrary inverter para positivo
    @ Verifica estatística específica sendo alterada
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_ATK CHECK_ATTACK_DOWN
    jumpifbytevarEQ STAT_DEF CHECK_DEFENSE_DOWN
    jumpifbytevarEQ STAT_SP_ATK CHECK_SPATK_DOWN
    jumpifbytevarEQ STAT_SP_DEF CHECK_SPDEF_DOWN
    jumpifbytevarEQ STAT_ACC CHECK_ACCURACY_DOWN
    jumpifbytevarEQ STAT_EVASION CHECK_EVASION_DOWN
    jumpifbytevarEQ STAT_SPD CHECK_SPEED_DOWN
    return_cmd
CHECK_ATTACK_DOWN:
    @ Verifica Hyper Cutter primeiro
    checkability bank_target ABILITY_HYPER_CUTTER 1
    jumpifbytevarEQ 1 HYPER_CUTTER_CHECK
	checkability bank_target ABILITY_DEFIANT 1
	jumpifbytevarEQ 1 POINTS_MINUS5 @ Penaliza menos pois pode ser arriscado
    @ Verifica se a estatística já está no mínimo
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    @ Verifica exceções específicas para redução de ataque
    getmoveid
    jumpifwordvarEQ MOVE_PLAY_NICE HYPER_CUTTER_CHECK @ Ignora Hyper Cutter
    jumpifwordvarEQ MOVE_NOBLE_ROAR HYPER_CUTTER_CHECK @ Ignora Hyper Cutter
    jumpifwordvarEQ MOVE_TEARFUL_LOOK HYPER_CUTTER_CHECK @ Ignora Hyper Cutter
    jumpifwordvarEQ MOVE_VENOM_DRENCH HYPER_CUTTER_CHECK @ Ignora Hyper Cutter
    return_cmd

HYPER_CUTTER_CHECK:
    @ Aplica penalidade extra se tiver Hyper Cutter (exceto para movimentos especiais)
    checkability bank_target ABILITY_HYPER_CUTTER 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd
CHECK_DEFENSE_DOWN:
    @ Verifica Clear Body, White Smoke e Full Metal Body
	checkability bank_target ABILITY_BIG_PECKS 1
	jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Verifica se a defesa já está no mínimo
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_SPATK_DOWN:
    @ Verifica Clear Body, White Smoke e Full Metal Body
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
	checkability bank_target ABILITY_COMPETITIVE 1
	jumpifbytevarEQ 1 POINTS_MINUS8
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_SPDEF_DOWN:
    @ Verifica Clear Body, White Smoke e Full Metal Body
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_ACCURACY_DOWN:
    @ Verifica Keen Eye
    checkability bank_target ABILITY_KEEN_EYE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_EVASION_DOWN:
    @ Verifica Clear Body, White Smoke e Full Metal Body
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_SPEED_DOWN:
    @ Verifica Clear Body, White Smoke e Full Metal Body
    checkability bank_target ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_MULTIPLESTAT_CHANCE_USER:
    getmoveid
    jumpifwordvarEQ MOVE_ANCIENT_POWER   CHECK_ANCIENT_POWER       @ Ancient Power: +1 em todas as stats (10%)
    jumpifwordvarEQ MOVE_OMINOUS_WIND    CHECK_ANCIENT_POWER       @ Ominous Wind: +1 em todas as stats (10%)
    jumpifwordvarEQ MOVE_SUPERPOWER      CHECK_SUPERPOWER          @ Superpower: -1 ATK/DEF
    jumpifwordvarEQ MOVE_CLOSE_COMBAT    CHECK_CLOSE_COMBAT        @ Close Combat: -1 DEF/SP.DEF
    jumpifwordvarEQ MOVE_VCREATE        CHECK_V_CREATE            @ V-Create: -1 DEF/SP.DEF/SPD
    jumpifwordvarEQ MOVE_DRAGON_ASCENT   CHECK_DRAGON_ASCENT       @ Dragon Ascent: -1 DEF/SP.DEF
    return_cmd

CHECK_ANCIENT_POWER:
    goto_cmd CHECK_STATUS_BLOCKS         @ Verifica status antes do movimento
    goto_cmd CHECK_SHEER_FORCE           @ Verifica Sheer Force
    @ Verifica se todas as stats já estão no máximo
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS10
    @ Verifica Contrary (Ancient Power/Ominous Wind aumentariam stats → Contrary as diminuiria)
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_ANCIENT_CONTRARY
    @ Verifica chance de 10% (90% de falha)
    jumpifrandLT 10 RETURN_CMD_MCU
    goto_cmd NEGATIVE_MCU
    return_cmd

CHECK_ANCIENT_CONTRARY:
    @ Se Contrary: Ancient Power/Ominous Wind **reduziriam** todas as stats. Penaliza se alguma já está no mínimo.
    jumpifstatbuffEQ bank_ai STAT_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS10
    return_cmd

CHECK_SUPERPOWER:
    goto_cmd CHECK_STATUS_BLOCKS         @ Verifica status antes do movimento
    goto_cmd CHECK_CLEAR_BODY            @ Verifica Clear Body/White Smoke
    goto_cmd CHECK_SUBSTITUTE_MCU		 @ Verifica Substitute
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_SUPERPOWER_CONTRARY
    @ Verifica se ATK/DEF já estão no mínimo
    jumpifstatbuffEQ bank_ai STAT_ATK min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS10
    return_cmd

CHECK_SUPERPOWER_CONTRARY:
    jumpifstatbuffEQ bank_ai STAT_ATK max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_CLOSE_COMBAT:
    goto_cmd CHECK_STATUS_BLOCKS @ Verifica status antes do movimento
	goto_cmd CHECK_CLEAR_BODY
    goto_cmd CHECK_SUBSTITUTE_MCU		 @ Verifica Substitute
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_CLOSE_COMBAT_CONTRARY
    @ Verifica se DEF/SP.DEF já estão no mínimo
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF min_stat_stage POINTS_MINUS10
    return_cmd

CHECK_CLOSE_COMBAT_CONTRARY:
    @ Se Contrary: Close Combat **aumenta** DEF/SP.DEF. Penaliza se já estão no máximo.
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_V_CREATE:
    goto_cmd CHECK_STATUS_BLOCKS
    goto_cmd CHECK_CLEAR_BODY
    goto_cmd CHECK_SUBSTITUTE_MCU		 @ Verifica Substitute
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_V_CREATE_CONTRARY
    @ Verifica se DEF/SP.DEF/SPD estão no mínimo
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SPD min_stat_stage POINTS_MINUS10
    return_cmd

CHECK_V_CREATE_CONTRARY:
    @ Se Contrary: V-Create **aumenta** DEF/SP.DEF/SPD. Penaliza se já estão no máximo.
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SPD max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_DRAGON_ASCENT:
    goto_cmd CHECK_STATUS_BLOCKS
    goto_cmd CHECK_CLEAR_BODY
    goto_cmd CHECK_SUBSTITUTE_MCU		 @ Verifica Substitute
    checkability bank_ai ABILITY_CONTRARY 1
    jumpifbytevarEQ 1 CHECK_DRAGON_ASCENT_CONTRARY
    @ Verifica se DEF/SP.DEF estão no mínimo
    jumpifstatbuffEQ bank_ai STAT_DEF min_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF min_stat_stage POINTS_MINUS10
    return_cmd

CHECK_DRAGON_ASCENT_CONTRARY:
    @ Se Contrary: Dragon Ascent **aumenta** DEF/SP.DEF. Penaliza se já estão no máximo.
    jumpifstatbuffEQ bank_ai STAT_DEF max_stat_stage POINTS_MINUS10
    jumpifstatbuffEQ bank_ai STAT_SP_DEF max_stat_stage POINTS_MINUS10
    return_cmd

CHECK_STATUS_BLOCKS:
    jumpifstatus bank_ai STATUS_PARALYSIS CHECK_PARALYSIS_RAND
    jumpifstatus bank_ai STATUS_FREEZE CHECK_PARALYSIS_RAND
    jumpifstatus bank_ai STATUS_SLEEP POINTS_MINUS10
    jumpifstatus bank_ai STATUS_CONFUSION CHECK_CONFUSION_RAND
	return_cmd

CHECK_CLEAR_BODY:
    checkability bank_ai ABILITY_CLEAR_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_ai ABILITY_WHITE_SMOKE 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_ai ABILITY_FULL_METAL_BODY 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifsideaffecting bank_ai SIDE_MIST POINTS_MINUS10
    return_cmd

CHECK_SUBSTITUTE_MCU:
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd

CHECK_SHEER_FORCE:
    checkability bank_ai ABILITY_SHEER_FORCE 1
    jumpifbytevarEQ 1 POINTS_MINUS5  @ Penaliza levemente, já que o buff não será aplicado
    return_cmd

CHECK_PARALYSIS_RAND:
    jumpifrandLT 25 POINTS_MINUS10 @ 25% de chance de falhar devido à paralisia
	return_cmd
CHECK_CONFUSION_RAND:
    jumpifrandLT 50 POINTS_MINUS10 @ 50% de chance de falhar devido à confusão
	return_cmd
RETURN_CMD_MCU:
	return_cmd
NEGATIVE_MCU:
	scoreupdate -5
	return_cmd
################################################################################################
DISCOURAGE_CONFUSION:
	jumpifstatus2 bank_target STATUS2_CONFUSION POINTS_MINUS10
	getability bank_target 1
	jumpifbytevarEQ ABILITY_OWN_TEMPO POINTS_MINUS10
	return_cmd
################################################################################################
DISCOURAGE_ATTACK_CONFUSION:
    getmoveid
    jumpifwordvarEQ MOVE_PSYBEAM          CHANCE_10   			   @ Psybeam: Chance de confundir 10%
    jumpifwordvarEQ MOVE_CONFUSION        CHANCE_10   			   @ Confusion: Chance de confundir 10%
    jumpifwordvarEQ MOVE_DIZZY_PUNCH      CHANCE_20   			   @ Dizzy Punch: Chance de confundir 20%
    jumpifwordvarEQ MOVE_DYNAMIC_PUNCH    CHECK_CONFUSION_CHANCE   @ DynamicPunch: Chance de confundir 100%
    jumpifwordvarEQ MOVE_SIGNAL_BEAM      CHANCE_10   			   @ Signal Beam: Chance de confundir 10%
    jumpifwordvarEQ MOVE_WATER_PULSE      CHANCE_20   			   @ Water Pulse: Chance de confundir 20%
    jumpifwordvarEQ MOVE_ROCK_CLIMB       CHANCE_20   			   @ Rock Climb: Chance de confundir 20%
    jumpifwordvarEQ MOVE_CHATTER          CHECK_CONFUSION_CHANCE   @ Chatter: Chance de confundir 100%
    jumpifwordvarEQ MOVE_HURRICANE        CHANCE_30   			   @ Hurricane: Chance de confundir 30%
    jumpifwordvarEQ MOVE_STRANGE_STEAM    CHANCE_20   			   @ Strange Steam: Chance de confundir 20%
    return_cmd                            @ Se não for nenhum dos golpes, retorna

CHANCE_10:
    jumpifrandLT 10 CHECK_CONFUSION_CHANCE
    return_cmd
CHANCE_20:
    jumpifrandLT 20 CHECK_CONFUSION_CHANCE
    return_cmd
CHANCE_30:
    jumpifrandLT 30 CHECK_CONFUSION_CHANCE
    return_cmd

CHECK_CONFUSION_CHANCE:
    goto_cmd CHECK_SUBSTITUTE_ATTACK_CONFUSION             @ Verifica Substitute no alvo
    goto_cmd CHECK_OWN_TEMPO              @ Verifica Own Tempo no alvo
    goto_cmd CHECK_CONFUSION_STATUS       @ Verifica se o alvo já está confuso
    @ Verifica chance de confundir (exemplo: 10%, 30%)
    goto_cmd NEGATIVE_AC               @ Penaliza levemente se confusão não se aplicar
    return_cmd
CHECK_SUBSTITUTE_ATTACK_CONFUSION:
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS30      @ Penaliza fortemente se o Substitute bloquear o efeito
    return_cmd
CHECK_OWN_TEMPO:
    checkability bank_target ABILITY_OWN_TEMPO 1
    jumpifbytevarEQ 1 POINTS_MINUS12      @ Penaliza se o alvo tiver Own Tempo
    return_cmd
CHECK_CONFUSION_STATUS:
    jumpifstatus bank_target STATUS_CONFUSION
    jumpifbytevarEQ 1 POINTS_MINUS12      @ Penaliza se o alvo já estiver confuso
    return_cmd
NEGATIVE_AC:
	scoreupdate -5
	return_cmd
################################################################################################
DISCOURAGE_FLINCH:
    getmoveid
    jumpifwordvarEQ MOVE_BONE_CLUB        CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_HYPER_FANG       CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_EXTRASENSORY     CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_THUNDER_FANG     CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_ICE_FANG         CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_FIRE_FANG        CHANCE_10_FLINCH
    jumpifwordvarEQ MOVE_STOMP            CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_ROLLING_KICK     CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_HEADBUTT         CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_BITE             CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_WATERFALL        CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_ROCK_SLIDE       CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_TWISTER          CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_NEEDLE_ARM       CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_ASTONISH         CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_DARK_PULSE       CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_AIR_SLASH        CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_DRAGON_RUSH      CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_ZEN_HEADBUTT     CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_IRON_HEAD        CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_HEART_STAMP      CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_STEAMROLLER      CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_ICICLE_CRASH     CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_ZING_ZAP         CHANCE_30_FLINCH
    jumpifwordvarEQ MOVE_FIERY_WRATH      CHANCE_20_FLINCH
    jumpifwordvarEQ MOVE_DOUBLE_IRON_BASH CHANCE_30_FLINCH
    return_cmd

CHANCE_10_FLINCH:
    jumpifrandLT 10 FLINCH_CHECK
    return_cmd
CHANCE_20_FLINCH:
    jumpifrandLT 20 FLINCH_CHECK
    return_cmd
CHANCE_30_FLINCH:
    goto_cmd CALCULATE_FLINCH_CHANCE       @ Verifica modificadores de chance
    jumpifrandLT 30 FLINCH_CHECK           @ Default: 30%
    return_cmd

CALCULATE_FLINCH_CHANCE:
    @ Se atacante tem Stench, aumenta chance em 10
    checkability bank_ai ABILITY_STENCH 1
    jumpifbytevarEQ 1 FLINCH_CHANCE_PLUS_10
    @ Se atacante está segurando King's Rock ou Razor Fang, aumenta chance em 10
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_KINGSROCK FLINCH_CHANCE_PLUS_10
    @ Se atacante tem Serene Grace, dobra a chance
    checkability bank_ai ABILITY_SERENE_GRACE 1
    jumpifbytevarEQ 1 FLINCH_CHANCE_DOUBLE
    @ Verifica se o lado do campo tem efeito de arco-íris (Rainbow Effect de Water Pledge)
    jumpifsideaffecting bank_ai SIDE_AFFECTING_WATERPLEDGE FLINCH_CHANCE_DOUBLE
    @ Default: 30% de chance de flinch
    jumpifrandLT 30 FLINCH_CHECK
    return_cmd

FLINCH_CHANCE_PLUS_10:
    jumpifrandLT 40 FLINCH_CHECK
    return_cmd
FLINCH_CHANCE_DOUBLE:
    jumpifrandLT 60 FLINCH_CHECK           @ Dobra a chance (30% vira 60%)
    return_cmd
FLINCH_CHECK:
    goto_cmd FLINCH_CONDITIONS
    return_cmd
FLINCH_CONDITIONS:
    goto_cmd CHECK_SUBSTITUTE_FLINCH
    goto_cmd CHECK_SHIELD_DUST
    goto_cmd CHECK_FLINCH_STATUS
    return_cmd
CHECK_SUBSTITUTE_FLINCH:
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10       @ Penaliza se o Substitute bloquear o efeito
    return_cmd
CHECK_SHIELD_DUST:
    checkability bank_target ABILITY_SHIELD_DUST 1
    jumpifbytevarEQ 1 POINTS_MINUS10       @ Penaliza se o alvo tiver Shield Dust
    return_cmd
CHECK_FLINCH_STATUS:
    @ Verifica Inner Focus (imunidade a flinch)
    checkability bank_target ABILITY_INNER_FOCUS 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Verifica Steadfast (alvo ganha Speed ao ser flinchado)
    checkability bank_target ABILITY_STEADFAST 1
    jumpifbytevarEQ 1 POINTS_MINUS10       @ Penaliza porque beneficia o adversário
    return_cmd
################################################################################################
DISCOURAGE_SLEEP:
    getability bank_target 1
    jumpifbytevarEQ ABILITY_INSOMNIA POINTS_MINUS10
    jumpifbytevarEQ ABILITY_VITAL_SPIRIT POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_UPROAR POINTS_MINUS10
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_POISON:
    getability bank_target 1
    jumpifbytevarEQ ABILITY_IMMUNITY POINTS_MINUS10
    jumpifbytevarEQ ABILITY_PASTEL_VEIL POINTS_MINUS10
    @ Verificação de tipos (Steel/Poison)
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 CHECK_CORROSION
    isoftype bank_target TYPE_POISON
    jumpifbytevarEQ 1 CHECK_CORROSION
    getmovescript
    jumpifbytevarEQ 14 CHECK_TOXIC_SPECIFIC
    goto_cmd DISCOURAGE_IF_CANTBESTATUSED
CHECK_TOXIC_SPECIFIC:
    jumpifstatus bank_target STATUS_BAD_POISON POINTS_MINUS10
    jumpifstatus bank_target STATUS_POISON POINTS_MINUS5
    goto_cmd DISCOURAGE_IF_CANTBESTATUSED
CHECK_CORROSION:
    checkability bank_ai ABILITY_CORROSION
    jumpifbytevarNE 1 POINTS_MINUS10
    getmovescript
    jumpifbytevarEQ 14 CHECK_TOXIC_SPECIFIC
    goto_cmd DISCOURAGE_IF_CANTBESTATUSED
################################################################################################
DISCOURAGE_PURIFY:
    @ 1. Se o alvo estiver sob Heal Block, penaliza fortemente (não pode curar)
    jumpifbankaffecting bank_target BANK_AFFECTING_HEALBLOCK POINTS_MINUS10
    @ 2. Se não houver nenhum status para curar, não faz sentido usar Purify
    jumpifstatus bank_target STATUS_SLEEP | STATUS_POISON | STATUS_BURN | STATUS_PARALYSIS | STATUS_FREEZE PURIFY_HAS_STATUS
    @ —> nenhum status presente: penaliza
    goto_cmd NEGATIVE_PURIFY

PURIFY_HAS_STATUS:
    @ 3. Se o alvo for aliado (incluindo self), sempre permita sem penalizar
    jumpiftargetisally END_LOCATION
    @ 4. Se o HP do alvo já estiver no máximo (100%), penaliza fortemente
    jumpifhealthGE bank_target 100 POINTS_MINUS10
    @ 5. Se o HP do alvo estiver ≥ 90%, penaliza levemente
    jumpifhealthGE bank_target  90 POINTS_MINUS8
    @ 6. Caso contrário, nada a penalizar
    return_cmd
NEGATIVE_PURIFY:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_TOXICTHREAD:
    call_cmd DISCOURAGE_POISON
    getstatvaluemovechanges bank_target
    jumpifbytevarNE STAT_SPD END_TOXICTHREAD
    @ Verificação de tipos para Toxic Thread
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_POISON
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Restante da lógica original
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ min_stat_stage END_TOXICTHREAD
    checkability bank_target ABILITY_CONTRARY
    jumpifbytevarEQ 1 END_TOXICTHREAD
    checkability bank_target ABILITY_CLEAR_BODY
    jumpifbytevarEQ 1 POINTS_MINUS1
    checkability bank_target ABILITY_WHITE_SMOKE
    jumpifbytevarEQ 1 POINTS_MINUS1
    checkability bank_target ABILITY_FULL_METAL_BODY
    jumpifbytevarEQ 1 POINTS_MINUS1
    jumpifstrikesfirst bank_ai bank_target CHECK_ELECTROBALL
    goto_cmd END_TOXICTHREAD
CHECK_ELECTROBALL:
    countalivepokes bank_ai
    jumpifbytevarNE 0 END_TOXICTHREAD
    jumpifhasmove bank_ai MOVE_ELECTRO_BALL END_TOXICTHREAD
    goto_cmd NEGATIVE_TT
END_TOXICTHREAD:
    return_cmd
NEGATIVE_TT:
	scoreupdate -1
	return_cmd
################################################################################################
DISCOURAGE_INSTRUCT:
	jumpifhealthLT bank_ai 30 POINTS_MINUS10  @ Penaliza se o HP do usuário está baixo (<30%)
    @ Verifica se o Pokémon é do tipo Fire
    isoftype bank_ai TYPE_FIRE
    jumpifbytevarNE 1 POINTS_MINUS30  @ Penaliza fortemente se o usuário não for do tipo Fire
    @ Verifica habilidade Protean
    checkability bank_ai ABILITY_PROTEAN
    jumpifbytevarEQ 1 POINTS_MINUS12  @ Penaliza adicionalmente se o Pokémon tem Protean mas não é Fire
    @ Penalizar Pokémon Fire puro
    gettypeinfo AI_TYPE1_TARGET
    jumpifbytevarEQ TYPE_FIRE POINTS_MINUS10  @ Penaliza se o Pokémon é Fire puro
    gettypeinfo AI_TYPE2_TARGET
    jumpifbytevarEQ TYPE_EGG POINTS_MINUS10  @ Penaliza se o Pokémon não tem tipo secundário
	getlastusedmove bank_target
    jumpifwordvarEQ 0x0 POINTS_MINUS10
    jumpifwordvarEQ MOVE_HYPER_BEAM POINTS_MINUS12  @ Penaliza se o alvo está em recarga (ex.: Hyper Beam)
	jumpifwordvarEQ MOVE_BLAST_BURN       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_HYDRO_CANNON       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_FRENZY_PLANT       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_GIGA_IMPACT       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_ROCK_WRECKER       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_ROAR_OF_TIME       	  POINTS_MINUS12
    jumpifwordvarEQ MOVE_PRISMATIC_LASER		  POINTS_MINUS12
    @ 2. Incentivar movimentos estratégicos
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10  @ Incentiva se o último movimento foi super eficaz
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS5  @ Incentiva se o último movimento tem STAB (Same-Type Attack Bonus)
    @ 3. Verificar status do alvo
    jumpifstatus bank_target STATUS_CONFUSION POINTS_MINUS10  @ Penaliza se o alvo está confuso
    jumpifstatus bank_target STATUS_SLEEP POINTS_MINUS10  @ Penaliza se o alvo está dormindo
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS10  @ Penaliza se o alvo está paralisado
    @ 4. Compatibilidade com movimentos de suporte
    jumpifhasmove bank_target MOVE_HEAL_PULSE POINTS_PLUS10  @ Incentiva se o último movimento é Heal Pulse
    jumpifhasmove bank_target MOVE_TAILWIND POINTS_PLUS10  @ Incentiva se o último movimento é Tailwind
    return_cmd  @ Finaliza a lógica
################################################################################################
DISCOURAGE_MINDBLOWN:
	checkability bank_target ABILITY_DAMP
    jumpifbytevarEQ 1 POINTS_MINUS30
	checkability bank_target ABILITY_FLASH_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS30
	jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS30
   @ 1. Penalizar com base no HP do usuário
    jumpifhealthLT bank_ai 25 POINTS_MINUS10  @ Penaliza fortemente se o HP está abaixo de 25%
    jumpifhealthLT bank_ai 60 POINTS_MINUS5  @ Penaliza levemente se o HP está abaixo de 50%
    @ 2. Incentivar se o golpe for super eficaz
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10  @ Incentiva se o golpe for super eficaz
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS10  @ Penaliza se o golpe for pouco eficaz
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS12  @ Penaliza fortemente se o alvo for imune
    @ 4. Situações de desespero
    jumpifhealthLT bank_ai 15 POINTS_PLUS10 @ Incentiva se for um último recurso (HP crítico)
    @ 5. Situações de batalha
    jumpifhealthLT bank_ai 50
    jumpifhealthLT bank_target 50 POINTS_PLUS10  @ Incentiva se o alvo também está com HP baixo
    jumpifhealthLT bank_ai 50
    jumpifhealthLT bank_target 15 POINTS_PLUS10  @ Incentiva fortemente se pode derrotar o alvo com HP crítico
    return_cmd  @ Finaliza a lógica
################################################################################################
DISCOURAGE_CHLOROBLAST:
    @ 1. Penaliza se a efetividade for ruim
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS12
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS8
    @ 2. Penaliza se HP do usuário for baixo (metade do HP será perdido)
    jumpifhealthLT bank_ai 25 POINTS_MINUS12     @ Menos de 25% do HP
    jumpifhealthLT bank_ai 50 POINTS_MINUS5      @ Menos de 50% do HP
    @ 3. Incentiva se o golpe for causar nocaute
    jumpifwillfaint bank_target bank_ai POINTS_PLUS10
    @ 4. Penaliza se o alvo tem pouquíssimo HP (overkill)
    jumpifhealthLT bank_target 10 POINTS_MINUS5
    @ 5. Incentiva se for super efetivo
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS5
    @ 6. Penaliza se for o último Pokémon do usuário (risco de perder)
    countalivepokes bank_ai
    jumpifbytevarEQ 1 POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_CLANGOROUSSOUL:
    @ 1. Penaliza se HP está baixo (não pode usar, ou arriscado)
    jumpifhealthLT bank_ai 34 POINTS_MINUS12   @ Não pode usar o golpe (falha)
    jumpifhealthLT bank_ai 50 POINTS_MINUS10   @ Muito arriscado
    @ 2. Penaliza se oponente pode nocautear
    jumpifwillfaint bank_target bank_ai POINTS_MINUS10
    jumpifstatbuffGE bank_ai STAT_ATK default_stat_stage+3 POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_DEF default_stat_stage+3 POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_SPD default_stat_stage+3 POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_SP_ATK default_stat_stage+3 POINTS_MINUS8
    jumpifstatbuffGE bank_ai STAT_SP_DEF default_stat_stage+3 POINTS_MINUS8
    @ 5. Penaliza se é o último Pokémon do usuário
    countalivepokes bank_ai
    jumpifbytevarEQ 1 POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_PLASMAFISTS:
    @ 1. Penaliza se o alvo é imune a golpes Elétricos (Ground puro ou com Lightning Rod/Motor Drive/Volt Absorb)
	isoftype bank_target TYPE_GROUND
    jumpifbytevarEQ 1 POINTS_MINUS12
    checkability bank_target ABILITY_VOLT_ABSORB
	jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_MOTOR_DRIVE
	jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_LIGHTNING_ROD
	jumpifbytevarEQ 1 POINTS_MINUS10
	jumpifsideaffecting bank_target SIDE_REFLECT | SIDE_LIGHTSCREEN POINTS_MINUS5
    @ 2. Penaliza se o golpe não vai causar muito dano (resistência dupla ou mais, ou alvo com HP alto)
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS8
    @ 3. Penaliza se o AI está com HP baixo e pode ser nocauteado
    jumpifhealthLT bank_ai 36 POINTS_MINUS8
    jumpifwillfaint bank_target bank_ai POINTS_MINUS10
    @ 4. Penaliza se está queimado (burn), reduzindo o dano físico
    jumpifstatus bank_ai STATUS_BURN, POINTS_MINUS5
    @ 5. Penaliza se o oponente usou Protect/Detect
    getprotectuses bank_target
	jumpifbytevarGE 1 POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_SPOTLIGHT:
################################################################################################
DISCOURAGE_EERIE:
    @ 1. Verifica imunidade Psíquica
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS12
    @ 2. Obtém último movimento do alvo
    getlastusedmove bank_target
    jumpifwordvarEQ 0 POINTS_MINUS10      @ Sem movimento anterior
    jumpifwordvarEQ 0xFFFF POINTS_MINUS10 @ Movimento inválido
    @ 3. Penaliza golpes irrelevantes (sem dano/impacto direto)
    jumpifwordvarEQ MOVE_SPLASH POINTS_MINUS10
    jumpifwordvarEQ MOVE_GROWL POINTS_MINUS10
    jumpifwordvarEQ MOVE_LEER POINTS_MINUS10
    jumpifwordvarEQ MOVE_TAIL_WHIP POINTS_MINUS10
    jumpifwordvarEQ MOVE_CHARM POINTS_MINUS10
    jumpifwordvarEQ MOVE_SAND_ATTACK POINTS_MINUS10
    jumpifwordvarEQ MOVE_DOUBLE_TEAM POINTS_MINUS10
    jumpifwordvarEQ MOVE_CONFIDE POINTS_MINUS10
    jumpifwordvarEQ MOVE_STRING_SHOT POINTS_MINUS10
    jumpifwordvarEQ MOVE_DEFENSE_CURL POINTS_MINUS10
    @ 4. Incentiva golpes de recuperação/setup
    jumpifwordvarEQ MOVE_RECOVER POINTS_PLUS10
    jumpifwordvarEQ MOVE_SOFTBOILED POINTS_PLUS10
    jumpifwordvarEQ MOVE_ROOST POINTS_PLUS10
    jumpifwordvarEQ MOVE_DRAGON_DANCE POINTS_PLUS10
    jumpifwordvarEQ MOVE_SWORDS_DANCE POINTS_PLUS10
    jumpifwordvarEQ MOVE_NASTY_PLOT POINTS_PLUS10
    jumpifwordvarEQ MOVE_CALM_MIND POINTS_PLUS10
    jumpifwordvarEQ MOVE_QUIVER_DANCE POINTS_PLUS10
    jumpifwordvarEQ MOVE_SHELL_SMASH POINTS_PLUS10
    @ 5. Eficácia do tipo
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_CHILLY_RECEPTION:
    @ Primeira condição: verifica Pokémon utilizáveis
    countalivepokes bank_ai
    jumpifbytevarEQ 0 POINTS_MINUS10
    @ Segunda condição: verifica clima de Snow ou partner move de clima
    jumpifweather chilly_reception_hail CHECK_PARTNER_MOVE_WEATHER
    @ Terceira condição: verifica clima de Hail
    jumpifweather weather_hail | weather_permament_hail APPLY_HAIL_PENALTY
    return_cmd
CHECK_PARTNER_MOVE_WEATHER:
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_SUNNY_DAY APPLY_WEATHER_PENALTY
    jumpifwordvarEQ MOVE_RAIN_DANCE APPLY_WEATHER_PENALTY
    jumpifwordvarEQ MOVE_SANDSTORM APPLY_WEATHER_PENALTY
    jumpifwordvarEQ MOVE_HAIL APPLY_WEATHER_PENALTY
    jumpifwordvarEQ MOVE_CHILLY_RECEPTION APPLY_WEATHER_PENALTY
    return_cmd

APPLY_WEATHER_PENALTY:
    goto_cmd NEGATIVE_CR
    return_cmd
APPLY_HAIL_PENALTY:
    goto_cmd NEGATIVE_CR2
    return_cmd
NEGATIVE_CR:
	scoreupdate -8
	return_cmd
NEGATIVE_CR2:
	scoreupdate -8
	return_cmd
################################################################################################
DISCOURAGE_SPEEDSWAP:
    jumpiftargetisally END_LOCATION          @ Se o alvo é aliado, penaliza -10
    scoreupdate -10
    return_cmd

TRICKROOM_LOGIC:
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM CHECK_SPEED_UNDER_TRICKROOM
    goto_cmd CHECK_SPEED_NORMAL

CHECK_SPEED_UNDER_TRICKROOM:
    comparestatsboth bank_ai bank_target STAT_SPD  @ Compara Speed do usuário e alvo
    jumpifbytevarLT 0x1 POINTS_MINUS10        @ Se Speed do usuário <= alvo (em Trick Room), penaliza -10
    return_cmd

CHECK_SPEED_NORMAL:
    comparestatsboth bank_ai bank_target STAT_SPD  @ Compara Speed do usuário e alvo
    jumpifbytevarGE 0x1 POINTS_MINUS10        @ Se Speed do usuário >= alvo (fora de Trick Room), penaliza -10
    return_cmd
################################################################################################
DISCOURAGE_DIRECLAW:
    @ 1. Verificar a eficácia do golpe
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS30        @ Penaliza fortemente se o alvo for imune (ex.: Steel)
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS8  @ Penaliza se for pouco eficaz
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS10 @ Incentiva se for super eficaz
    @ 2. Imunidade a status
    checkability bank_target ABILITY_IMMUNITY
    jumpifbytevarEQ 1 POINTS_MINUS8                     @ Penaliza se não pode envenenar
    checkability bank_target ABILITY_LIMBER
    jumpifbytevarEQ 1 POINTS_MINUS8                     @ Penaliza se não pode paralisar
    checkability bank_target ABILITY_INSOMNIA
    jumpifbytevarEQ 1 POINTS_MINUS8                     @ Penaliza se não pode dormir
    checkability bank_target ABILITY_VITAL_SPIRIT
    jumpifbytevarEQ 1 POINTS_MINUS8                     @ Penaliza se não pode dormir
    @ 3. Alvo já sob status
    jumpifstatus bank_target STATUS_ANY POINTS_MINUS5    @ Penaliza se o alvo já está com status
    @ 4. HP do alvo
    jumpifhealthLT bank_target 25 POINTS_PLUS10           @ Incentiva se pode finalizar o alvo
    @ 5. HP do usuário
    jumpifhealthLT bank_ai 20 POINTS_MINUS5              @ Penaliza se o usuário está muito vulnerável
    return_cmd
################################################################################################
DISCOURAGE_IF_CANTBESTATUSED:
    @ Verifica se já tem algum status
    jumpifstatus bank_target STATUS_SLEEP | STATUS_POISON | STATUS_BAD_POISON | STATUS_BURN | STATUS_PARALYSIS | STATUS_FREEZE POINTS_MINUS10
    @ Verifica proteções contra status
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN POINTS_MINUS10
    return_cmd
DISCOURAGE_PARALYSIS:
    @ Verificações específicas para paralisia
    isoftype bank_target TYPE_ELECTRIC
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Verifica habilidades que previnem paralisia
    getability bank_target 1
    jumpifbytevarEQ ABILITY_LIMBER POINTS_MINUS10
    @ Verifica se já está paralisado
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS10
    goto_cmd DISCOURAGE_IF_CANTBESTATUSED
################################################################################################
DISCOURAGE_BURNING:
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10  @ Checa se é imune
    isoftype bank_target TYPE_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS10 @ 1. Não tente queimar tipos Fire
    @ 2. Habilidades que previnem burn 
    getability bank_target 1
    jumpifbytevarEQ ABILITY_WATER_VEIL POINTS_MINUS10
    jumpifbytevarEQ ABILITY_WATER_BUBBLE POINTS_MINUS10
    jumpifbytevarEQ ABILITY_COMATOSE POINTS_MINUS10
    jumpifbytevarEQ ABILITY_LEAF_GUARD POINTS_MINUS10
    jumpifbytevarEQ ABILITY_FLOWER_VEIL POINTS_MINUS10 @ só para Grass, mas é seguro penalizar sempre
    @ 3. Status já presente
    jumpifstatus bank_target STATUS_BURN POINTS_MINUS10
    @ 4. Checa Leaf Guard + clima de sol
    if_ability bank_target ABILITY_LEAF_GUARD CHECK_SUN
    goto_cmd CHECK_SUBSTITUTE
CHECK_SUN:
    jumpifweather weather_sun | weather_harsh_sun POINTS_MINUS10
    goto_cmd CHECK_SUBSTITUTE
CHECK_SUBSTITUTE:
    @ 5. Checa Substitute bloqueando (precisa macro/func específica no seu script)
    @ Exemplo hipotético:
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE CHECK_IGNORE_SUBSTITUTE
    goto_cmd CHECK_PARTNER
CHECK_IGNORE_SUBSTITUTE:
    @ Will-O-Wisp ignora Substitute? (em geral, não)
    @ Se seu sistema permite, checar se o move ignora Substitute, ou se o usuário tem Infiltrator
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_INFILTRATOR CHECK_PARTNER
    @ Se não ignora, penaliza
    scoreupdate -10
    return_cmd
CHECK_PARTNER:
    @ 6. O parceiro vai tentar infligir status igual no mesmo alvo?
    @ Precisa macro/rotina para isso, ex:
	getpartnerchosenmove
	jumpifwordvarEQ MOVE_WILLOWISP POINTS_MINUS10
	jumpifwordvarEQ MOVE_THUNDER_WAVE POINTS_MINUS10
	jumpifwordvarEQ MOVE_NUZZLE POINTS_MINUS10
	jumpifwordvarEQ MOVE_STUN_SPORE POINTS_MINUS10
	jumpifwordvarEQ MOVE_GLARE POINTS_MINUS10
	jumpifwordvarEQ MOVE_SPORE POINTS_MINUS10
	jumpifwordvarEQ MOVE_SLEEP_POWDER POINTS_MINUS10
	jumpifwordvarEQ MOVE_HYPNOSIS POINTS_MINUS10
	jumpifwordvarEQ MOVE_LOVELY_KISS POINTS_MINUS10
	jumpifwordvarEQ MOVE_DARK_VOID POINTS_MINUS10
	jumpifwordvarEQ MOVE_GRASS_WHISTLE POINTS_MINUS10
	jumpifwordvarEQ MOVE_SING POINTS_MINUS10
	jumpifwordvarEQ MOVE_YAWN POINTS_MINUS10
	jumpifwordvarEQ MOVE_POISON_POWDER POINTS_MINUS10
	jumpifwordvarEQ MOVE_TOXIC POINTS_MINUS10
	jumpifwordvarEQ MOVE_CONFUSE_RAY POINTS_MINUS10
	jumpifwordvarEQ MOVE_SWEET_KISS POINTS_MINUS10
	jumpifwordvarEQ MOVE_TEETER_DANCE POINTS_MINUS10
	jumpifwordvarEQ MOVE_ATTRACT POINTS_MINUS10
	jumpifwordvarEQ MOVE_SWAGGER POINTS_MINUS10
	jumpifwordvarEQ MOVE_FLATTER POINTS_MINUS10
    @ 7. Checa outros status: se já tem outro status, não faz sentido tentar queimar
    @ E outras proteções de status
    call_cmd DISCOURAGE_IF_CANTBESTATUSED2
    return_cmd
DISCOURAGE_IF_CANTBESTATUSED2:
    @ Verifica se já tem algum status
    jumpifstatus bank_target STATUS_SLEEP | STATUS_POISON | STATUS_BAD_POISON | STATUS_BURN | STATUS_PARALYSIS | STATUS_FREEZE POINTS_MINUS10
    @ Verifica proteções contra status
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_ATTACK_STATUS_CHANCE:
    getmoveid
    @ --- Queimadura (Burn) ---
    jumpifwordvarEQ MOVE_FIRE_PUNCH       CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_EMBER            CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_FLAMETHROWER     CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_FIRE_BLAST       CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_FLAME_WHEEL      CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_SACRED_FIRE      CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_BLAZE_KICK       CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_HEAT_WAVE        CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_LAVA_PLUME       CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_INFERNO          CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_STEAM_ERUPTION   CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_BLUE_FLARE       CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_SCALD            CHECK_BURN_ASC
    jumpifwordvarEQ MOVE_INFERNAL_PARADE  CHECK_BURN_ASC
    @ --- Congelamento (Freeze) ---
    jumpifwordvarEQ MOVE_ICE_PUNCH        CHECK_FREEZE_ASC
    jumpifwordvarEQ MOVE_ICE_BEAM         CHECK_FREEZE_ASC
    jumpifwordvarEQ MOVE_BLIZZARD         CHECK_FREEZE_ASC
    jumpifwordvarEQ MOVE_POWDER_SNOW      CHECK_FREEZE_ASC
    jumpifwordvarEQ MOVE_FREEZING_GLARE   CHECK_FREEZE_ASC
    @ --- Paralisia (Paralysis) ---
    jumpifwordvarEQ MOVE_THUNDER_PUNCH    CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_THUNDER_SHOCK    CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_THUNDERBOLT      CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_THUNDER          CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_LICK             CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_SPARK            CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_DISCHARGE        CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_ZAP_CANNON       CHECK_PARALYSIS_100
    jumpifwordvarEQ MOVE_BOLT_STRIKE      CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_NUZZLE           CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_BODY_SLAM        CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_FORCE_PALM       CHECK_PARALYSIS_ASC
    jumpifwordvarEQ MOVE_DRAGON_BREATH    CHECK_PARALYSIS_ASC
    @ --- Envenenamento (Poison) ---
    jumpifwordvarEQ MOVE_POISON_STING     CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_SMOG             CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_SLUDGE           CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_SLUDGE_BOMB      CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_SLUDGE_WAVE      CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_POISON_FANG      CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_POISON_TAIL      CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_POISON_JAB       CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_CROSS_POISON     CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_GUNK_SHOT        CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_SHELL_SIDE_ARM   CHECK_POISON_ASC
    jumpifwordvarEQ MOVE_BARB_BARRAGE	  CHECK_POISON_ASC
    @ --- Sono (Sleep) ---
    jumpifwordvarEQ MOVE_RELIC_SONG       CHECK_SLEEP_ASC
    return_cmd

@ ---------------------------
@ --- Queimadura (Burn) ---
@ ---------------------------
CHECK_BURN_ASC:
    call_cmd COMMON_STATUS_CHECKS
    checkability bank_target ABILITY_WATER_VEIL 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Water Veil bloqueia/imuniza contra Burn
    checkability bank_target ABILITY_WATER_BUBBLE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Water Bubble bloqueia Burn
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Comatose imuniza contra status
    checkability bank_target ABILITY_FLASH_FIRE 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Flash Fire imuniza contra Fire e eleva o dano de golpes Fire em 50%
    isoftype bank_target TYPE_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Fire é imune a Burn
    jumpifstatus bank_target STATUS_BURN POINTS_MINUS10 @ Já queimado
    getmoveeffectchance
    jumpifbytevarLT 30 POINTS_MINUS5   @ Penalizar se chance < 30%
    return_cmd

@ ---------------------------
@ --- Congelamento (Freeze) ---
@ ---------------------------
CHECK_FREEZE_ASC:
    call_cmd COMMON_STATUS_CHECKS
    jumpifweather weather_harsh_sun POINTS_MINUS10
    checkability bank_target ABILITY_MAGMA_ARMOR 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Magma Armor blocks Freeze
    checkability bank_target ABILITY_SHIELD_DUST 1
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_ICE
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Ice é imune a Freeze
    jumpifstatus bank_target STATUS_FREEZE POINTS_MINUS10 @ Já congelado
    getmoveeffectchance
    jumpifbytevarLT 20 POINTS_MINUS5   @ Penalizar se chance < 20%
    return_cmd

@ ---------------------------
@ --- Paralisia (Paralysis) ---
@ ---------------------------
CHECK_PARALYSIS_ASC:
    call_cmd COMMON_STATUS_CHECKS
    checkability bank_target ABILITY_LIMBER 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Limber blocks Paralysis
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Comatose imuniza de status
    checkability bank_target ABILITY_MOTOR_DRIVE 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Motor Drive Imuniza a Paralysis e eleva a Speed do portador em 1 estágio
    checkability bank_target ABILITY_VOLT_ABSORB 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Volt Absorb torna o pokémon imune a paralisia e recupera HP quando atingido por um move elétrico
    checkability bank_target ABILITY_LIGHTNING_ROD 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Lightning Rod torna o Pokémon imune a paralisia e redireciona moves elétricos para si, ganhando +1 Sp.Atk
    isoftype bank_target TYPE_ELECTRIC
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Electric é imune a Paralysis
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS10 @ Já paralisado
    getmoveeffectchance
    jumpifbytevarLT 25 POINTS_MINUS5   @ Penalizar se chance < 25%
    return_cmd

CHECK_PARALYSIS_100:
    call_cmd COMMON_STATUS_CHECKS
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_GRAVITY POINTS_MINUS10
    checkability bank_target ABILITY_LIMBER 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Limber blocks Paralysis
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Comatose imuniza de status
    checkability bank_target ABILITY_MOTOR_DRIVE 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Motor Drive Imuniza a Paralysis e eleva a Speed do portador em 1 estágio
    checkability bank_target ABILITY_VOLT_ABSORB 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Volt Absorb torna o pokémon imune a paralisia e recupera HP quando atingido por um move elétrico
    checkability bank_target ABILITY_LIGHTNING_ROD 1
    jumpifbytevarEQ 1 POINTS_MINUS12    @ Lightning Rod torna o Pokémon imune a paralisia e redireciona moves elétricos para si, ganhando +1 Sp.Atk
    isoftype bank_target TYPE_ELECTRIC
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Electric é imune a Paralysis
    jumpifstatus bank_target STATUS_PARALYSIS POINTS_MINUS10 @ Já paralisado
    return_cmd

@ ---------------------------
@ --- Envenenamento (Poison) ---
@ ---------------------------
CHECK_POISON_ASC:
    call_cmd COMMON_STATUS_CHECKS
    checkability bank_target ABILITY_IMMUNITY 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Immunity bloqueia o Poison
    checkability bank_target ABILITY_PASTEL_VEIL 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Pastel Veil bloqueia o Poison
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Comatose imuniza de status
    isoftype bank_target TYPE_POISON
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Poison é imune
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Tipo Steel é imune
    jumpifstatus bank_target STATUS_POISON POINTS_MINUS10 @ Já envenenado
	getform bank_target @Minior Core do Adversário
    jumpifbytevarLT 1 POINTS_MINUS10
	getform bank_targetpartner @Minior Core do Parceiro do Adversário
    jumpifbytevarLT 1 POINTS_MINUS10
    getmoveeffectchance
    jumpifbytevarLT 30 POINTS_MINUS5   @ Penalizar se chance < 30%
    return_cmd

@ ---------------------------
@ --- Sono (Sleep) ---
@ ---------------------------
CHECK_SLEEP_ASC:
    call_cmd COMMON_STATUS_CHECKS
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN POINTS_MINUS10
    checkability bank_target ABILITY_VITAL_SPIRIT 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Vital Spirit blocks Sleep
    checkability bank_target ABILITY_INSOMNIA 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Insomnia blocks Sleep
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Comatose imuniza de status
    checkability bank_target ABILITY_SWEET_VEIL 1
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Sweet Veil imuniza o portador e aliados de Sleep
    checkability bank_target ABILITY_EARLY_BIRD 1
    jumpifbytevarEQ 1 POINTS_MINUS10	@ Early Bird fará com que o pokémon dorma 1/2 da quantidade normal de turnos, possivelmente fazendo com que eles acordem imediatamente.
    jumpifstatus bank_target STATUS_SLEEP POINTS_MINUS10 @ Já dormindo
    getmoveeffectchance
    jumpifbytevarLT 20 POINTS_MINUS5   @ Penalizar se chance < 20%
    return_cmd

@ ---------------------------
@ --- Verificações Comuns ---
@ ---------------------------
COMMON_STATUS_CHECKS:
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10    @ Substitute bloqueia status
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN POINTS_MINUS10
    jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10 @ Efeitos de campo
    return_cmd
################################################################################################
DISCOURAGE_EXPLOSION:
    @ Verifica se a IA não quer se sacrificar (flag WILL_SUICIDE)
    @ Como não temos acesso direto às flags, usamos uma abordagem alternativa
    countalivepokes bank_ai
    jumpifbytevarEQ 0 END_LOCATION @ Se não há outros Pokémon, pode usar
    @ Verifica efetividade 0x
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10
    @ Verifica habilidade Damp no campo
    checkability bank_target ABILITY_DAMP
    jumpifbytevarEQ 1 DAMP_ACTIVE
    checkability bank_targetpartner ABILITY_DAMP
    jumpifbytevarNE 1 CHECK_PARTY_COUNT

DAMP_ACTIVE:
    @ Verifica se o atacante ignora habilidades (Mold Breaker etc)
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_MOLD_BREAKER CHECK_PARTY_COUNT
    jumpifbytevarEQ ABILITY_TERAVOLT CHECK_PARTY_COUNT
    jumpifbytevarEQ ABILITY_TURBOBLAZE CHECK_PARTY_COUNT
    goto_cmd NEGATIVE_EXPLOSION

CHECK_PARTY_COUNT:
    @ Verifica contagem de Pokémon utilizáveis
    countalivepokes bank_ai
    jumpifbytevarEQ 0 AI_NO_USABLE_MONS
    return_cmd

AI_NO_USABLE_MONS:
    countalivepokes bank_target
    jumpifbytevarEQ 0 POINTS_MINUS1 @ Ambos sem Pokémon - pequena penalização
    goto_cmd NEGATIVE_EXPLOSION @ Apenas a IA sem Pokémon - grande penalização
NEGATIVE_EXPLOSION:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_RECOIL:
    getmoveid
    @ --- Golpes que Causam Recoil ---
    jumpifwordvarEQ MOVE_TAKE_DOWN         CHECK_RECOIL
    jumpifwordvarEQ MOVE_DOUBLEEDGE       CHECK_RECOIL
    jumpifwordvarEQ MOVE_SUBMISSION        CHECK_RECOIL
    jumpifwordvarEQ MOVE_STRUGGLE          CHECK_RECOIL
    jumpifwordvarEQ MOVE_VOLT_TACKLE       CHECK_RECOIL
    jumpifwordvarEQ MOVE_FLARE_BLITZ       CHECK_RECOIL
    jumpifwordvarEQ MOVE_BRAVE_BIRD        CHECK_RECOIL
    jumpifwordvarEQ MOVE_WOOD_HAMMER       CHECK_RECOIL
    jumpifwordvarEQ MOVE_HEAD_SMASH        CHECK_RECOIL
    jumpifwordvarEQ MOVE_WILD_CHARGE       CHECK_RECOIL
    jumpifwordvarEQ MOVE_HEAD_CHARGE       CHECK_RECOIL
    jumpifwordvarEQ MOVE_LIGHT_OF_RUIN     CHECK_RECOIL
    return_cmd

@ ---------------------------
@ --- Verificação de Recoil ---
@ ---------------------------
CHECK_RECOIL:
    @ --- Verificar Habilidades ---
    checkability bank_ai ABILITY_ROCK_HEAD 1
    jumpifbytevarEQ 1 NO_RECOIL_PENALTY     @ Rock Head impede recoil
    checkability bank_ai ABILITY_MAGIC_GUARD 1
    jumpifbytevarEQ 1 NO_RECOIL_PENALTY     @ Magic Guard impede dano indireto
    checkability bank_ai ABILITY_RECKLESS 1
    jumpifbytevarEQ 1 POINTS_PLUS5        @ Reckless aumenta poder e recoil
    @ --- Penalizar se HP do Atacante Estiver Baixo ---
    jumpifhealthLT bank_ai 10 POINTS_MINUS30              @ Penalizar severamente se HP < 20%
    jumpifhealthLT bank_ai 20 POINTS_MINUS12              @ Penalizar severamente se HP < 20%
    jumpifhealthLT bank_ai 50 POINTS_MINUS8               @ Penalizar moderadamente se HP < 50%
	getitemeffect bank_ai
	jumpifbytevarEQ ITEM_EFFECT_LIFEORB POINTS_MINUS2  @ não é recoil, mas não deixa de ser um dano extra
	jumpifbytevarEQ ITEM_EFFECT_STICKYBARB POINTS_MINUS2  @ não é recoil, mas não deixa de ser um dano extra
    return_cmd

@ --- Sem Penalidade para Recoil ---
NO_RECOIL_PENALTY:
    return_cmd                              @ Sem penalidade para Rock Head ou Magic Guard
################################################################################################
DISCOURAGE_KICK_FATAL:
    @ 1. Se o usuário tiver Ability Magic Guard, ignora penalização
    checkability bank_ai ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 APPLY_RECOIL_PENALTY
    @ 2. Verifica precisão do movimento (<75%): se sim, penaliza -6
    getmoveaccuracy
    jumpifbytevarLT 75 APPLY_RECOIL_PENALTY
    @ 3. Caso contrário, não há penalização
    return_cmd
APPLY_RECOIL_PENALTY:
    scoreupdate -6
    return_cmd
################################################################################################
DISCOURAGE_SUICIDE:
    getmoveid
    jumpifwordvarEQ MOVE_MEMENTO HANDLE_MEMENTO
    jumpifwordvarEQ MOVE_HEALING_WISH HANDLE_HEALING_WISH
    jumpifwordvarEQ MOVE_LUNAR_DANCE HANDLE_HEALING_WISH
    return_cmd
HANDLE_HEALING_WISH:
    countalivepokes bank_ai
    jumpifbytevarEQ 0 POINTS_MINUS10   @ Se todos os aliados mortos, penaliza
	check_party_fully_healed @ Se todos os vivos estiverem com HP cheio, penaliza
	jumpifbytevarEQ 0x1 POINTS_MINUS10
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_HEALING_WISH POINTS_MINUS10
    jumpifwordvarEQ MOVE_LUNAR_DANCE POINTS_MINUS10
    return_cmd
HANDLE_MEMENTO:
    countalivepokes bank_ai
    jumpifbytevarEQ 0 POINTS_MINUS10   @ Todos aliados mortos → penaliza
    jumpifstatbuffEQ bank_target STAT_ATK min_stat_stage CHECK_SPATK
    return_cmd
CHECK_SPATK:
    jumpifstatbuffEQ bank_target STAT_SP_ATK min_stat_stage POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_HEALBLOCK_AI:
    @ Penaliza se usuário está sob Heal Block
    jumpifbankaffecting bank_ai BANK_AFFECTING_HEALBLOCK POINTS_MINUS10
    @ Penaliza se alvo tem Liquid Ooze
    checkability bank_target ABILITY_LIQUID_OOZE
    jumpifbytevarEQ 1 POINTS_MINUS8
    return_cmd
################################################################################################
DISCOURAGE_HPUSERHEAL:
    getmovescript
    jumpifbytevarEQ 93 CHECK_REST_CONDITIONS
    jumpifbytevarEQ 25 CHECK_WEATHER_PENALTY
    jumpifhealthGE bank_ai 100 POINTS_MINUS10         @ Penaliza fortemente se HP máximo (100%)
    jumpifhealthGE bank_ai 90 POINTS_MINUS8           @ Penaliza levemente se HP >= 90%
    goto_cmd DISCOURAGE_HEALBLOCK_AI
CHECK_REST_CONDITIONS:
    getability bank_ai 1
    jumpifbytevarEQ ABILITY_INSOMNIA POINTS_MINUS10
    jumpifbytevarEQ ABILITY_VITAL_SPIRIT POINTS_MINUS10
    jumpifbytevarEQ ABILITY_COMATOSE POINTS_MINUS10
    checkability bank_ai ABILITY_SWEET_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_aipartner ABILITY_SWEET_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_ai TYPE_GRASS
    jumpifbytevarEQ 1 CHECK_FLOWER_VEIL
    if_ability bank_ai ABILITY_SHIELDS_DOWN CHECK_SHIELDS_DOWN
    jumpifstatus2 bank_ai STATUS2_UPROAR POINTS_MINUS10
    jumpifsideaffecting bank_ai SIDE_SAFEGUARD POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN POINTS_MINUS10
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN POINTS_MINUS10
    if_ability bank_ai ABILITY_LEAF_GUARD CHECK_LEAF_GUARD_SUN_REST
    jumpifstatus bank_ai STATUS_SLEEP | STATUS_POISON | STATUS_BURN | STATUS_PARALYSIS | STATUS_FREEZE POINTS_MINUS10
    return_cmd
CHECK_WEATHER_PENALTY:
    jumpifweather weather_rain | weather_sandstorm | weather_hail | chilly_reception_hail | weather_fog POINTS_MINUS3
    jumpifhealthGE bank_ai 100 POINTS_MINUS10
    jumpifhealthGE bank_ai 90 POINTS_MINUS8
    goto_cmd DISCOURAGE_HEALBLOCK_AI
CHECK_FLOWER_VEIL:
    checkability bank_ai ABILITY_FLOWER_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    return_cmd
CHECK_SHIELDS_DOWN:
    getform bank_ai
    jumpifbytevarLT 1 POINTS_MINUS10
    return_cmd
CHECK_LEAF_GUARD_SUN_REST:
    jumpifweather weather_sun | weather_harsh_sun POINTS_MINUS10
    return_cmd
################################################################################################
DISCOURAGE_HEAL_PULSE:               @ equivalent to EFFECT_HEAL_PULSE
    jumpiftargetisally CHECK_HEAL_ALLY   @ se for aliado, vai para lógica de cura
    goto_cmd NEGATIVE_HP              @ se não for aliado, penaliza -10
                                         @ (break no C) 
CHECK_HEAL_ALLY:                     @ fallthrough from HEAL_PULSE → HIT_ENEMY_HEAL_ALLY
    jumpifbankaffecting bank_target BANK_AFFECTING_HEALBLOCK POINTS_MINUS10 @ 1) impede se Heal Block ativo
    jumpifhealthGE bank_target 100 POINTS_MINUS10 @ 2) penaliza se HP já estiver cheio
    jumpifhealthGE bank_target 50 POINTS_MINUS5 @ 3) penaliza levemente se HP > 50%
    return_cmd
NEGATIVE_HP:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_HIT_ENEMY_HEAL_ALLY:      @ também cobre Pollen Puff (EFFECT_HIT_ENEMY_HEAL_ALLY)
    getpartnerchosenmove @ se o parceiro também for usar a mesma cura, evita redundância
    jumpifwordvarEQ MOVE_HEAL_PULSE POINTS_MINUS10
    jumpifwordvarEQ MOVE_POLLEN_PUFF POINTS_MINUS10 @ depois a mesma lógica de cura de aliado
    goto_cmd CHECK_HEAL_ALLY

################################################################################################
DISCOURAGE_CHARGE:
    @ Verifica se já está carregado
    jumpifstatus3 bank_ai STATUS3_CHARGED POINTS_MINUS30
    @ Verifica se tem movimentos do tipo Elétrico
    jumpifhasattackingmovewithtype bank_ai TYPE_ELECTRIC CHECK_SPDEF_CHARGE
    goto_cmd NEGATIVE_CHARGE
    
CHECK_SPDEF_CHARGE:
    @ Verifica se a Defesa Especial pode aumentar
    getstatvaluemovechanges bank_ai
    jumpifbytevarNE STAT_SP_DEF CHECK_SPDEF_END  @ Só aplica se estiver aumentando SP_DEF
    jumpifbytevarEQ max_stat_stage POINTS_MINUS5
    
CHECK_SPDEF_END:
    return_cmd
NEGATIVE_CHARGE:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_PSYCHOSHIFT:
    @ Poison
    jumpifstatus bank_ai STATUS_POISON | STATUS_BAD_POISON CHECK_POISON
    @ Burn
    jumpifstatus bank_ai STATUS_BURN CHECK_BURN
    @ Paralysis
    jumpifstatus bank_ai STATUS_PARALYSIS CHECK_PARALYSIS
    @ Sleep
    jumpifstatus bank_ai STATUS_SLEEP CHECK_SLEEP
    @ Nenhum status transmissível
    goto_cmd NEGATIVE_PSH

@ --- Poison
CHECK_POISON:
    getpartnerchosenmove
    jumpifhwordvarinlist status_effect_scripts POINTS_MINUS10
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10  @ 0x de dano
    checkability bank_target ABILITY_CORROSION
    jumpifbytevarEQ 1 SKIP_TYPE_CHECKS_POISON
	checkability bank_target ABILITY_IMMUNITY
	jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_POISON
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS10
SKIP_TYPE_CHECKS_POISON:
    isdoublebattle
    jumpifbytevarEQ 0 END_LOCATION
    checkability bank_targetpartner ABILITY_PASTEL_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    goto_cmd END_LOCATION

@ --- Burn
CHECK_BURN:
    getpartnerchosenmove
    jumpifhwordvarinlist status_effect_scripts POINTS_MINUS10
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10
	jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10  @ 0x de dano
    checkability bank_target ABILITY_WATER_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    checkability bank_target ABILITY_WATER_BUBBLE
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_FIRE
    jumpifbytevarEQ 1 POINTS_MINUS10
    isdoublebattle
    jumpifbytevarEQ 0 END_LOCATION
    checkability bank_targetpartner ABILITY_PASTEL_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    goto_cmd END_LOCATION

@ --- Paralysis
CHECK_PARALYSIS:
    getpartnerchosenmove
    jumpifhwordvarinlist status_effect_scripts POINTS_MINUS10
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10
	jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10  @ 0x de dano
    checkability bank_target ABILITY_LIMBER
    jumpifbytevarEQ 1 POINTS_MINUS10
    isoftype bank_target TYPE_ELECTRIC
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ Checagem de Safeguard (side status)
	jumpifsideaffecting bank_target SIDE_SAFEGUARD POINTS_MINUS10
    isdoublebattle
    jumpifbytevarEQ 0 END_LOCATION
    checkability bank_targetpartner ABILITY_PASTEL_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    goto_cmd END_LOCATION

@ --- Sleep
CHECK_SLEEP:
    getpartnerchosenmove
    jumpifhwordvarinlist status_effect_scripts POINTS_MINUS10
    jumpifstatus bank_target 0xFFFF POINTS_MINUS10
    jumpifstatus2 bank_target STATUS2_SUBSTITUTE POINTS_MINUS10
	checkability bank_target ABILITY_INSOMNIA
	jumpifbytevarEQ 1 POINTS_MINUS10
	checkability bank_target ABILITY_VITAL_SPIRIT
	jumpifbytevarEQ 1 POINTS_MINUS10
	checkability bank_target ABILITY_SWEET_VEIL
	jumpifbytevarEQ 1 POINTS_MINUS10
	jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN POINTS_MINUS10
	isdoublebattle
	jumpifbytevarEQ 0 END_LOCATION
	checkability bank_targetpartner ABILITY_PASTEL_VEIL
	jumpifbytevarEQ 1 POINTS_MINUS10
	goto_cmd END_LOCATION

NEGATIVE_PSH:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_GRAVITY:
    @ Verifica se Gravity já está ativo
    jumpiffieldaffecting FIELD_AFFECTING_GRAVITY CHECK_GRAVITY_LOGIC
    return_cmd

CHECK_GRAVITY_LOGIC:
    @ Verifica se parceiro já escolheu Gravity
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_GRAVITY POINTS_MINUS10
    @ Verifica se o banco AI não é do tipo Flying
    isoftype bank_ai TYPE_FLYING
    jumpifbytevarEQ 1 RETURN_NO_PENALTY
    @ Verifica se o banco AI não está segurando Air Balloon
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_AIRBALLOON RETURN_NO_PENALTY
    @ Penaliza se todas as condições acima forem verdadeiras
    goto_cmd NEGATIVE_GRAVITY

RETURN_NO_PENALTY:
    return_cmd
NEGATIVE_GRAVITY:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_IDENTYFING: @ movescript 31 (Foresight/Odor Sleuth/Miracle Eye)
	getmoveid
    jumpifmove MOVE_MIRACLE_EYE CHECK_MIRACLE_EYE_CONDITIONS
    @ --- Verificações Gerais ---
    jumpifstatus2 bank_target STATUS2_IDENTIFIED APPLY_PENALTY_IDENTIFIED @ Foresight/Odor Sleuth
    jumpifbankaffecting bank_target BANK_AFFECTING_MIRACLEEYE APPLY_PENALTY_IDENTIFIED @ Miracle Eye
    @ --- Verificações Específicas por Movimento ---
    @ --- Lógica para Foresight/Odor Sleuth ---
    jumpifstatbuffGE bank_target STAT_EVASION 5 CHECK_GHOST_TYPE_FORESIGHT
    scoreupdate -8
    return_cmd
    
CHECK_GHOST_TYPE_FORESIGHT:
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ 0x0 APPLY_PENALTY_FORESIGHT
    goto_cmd CHECK_PARTNER_MOVES
    
APPLY_PENALTY_FORESIGHT:
    scoreupdate -8
    return_cmd
    
CHECK_MIRACLE_EYE_CONDITIONS:
    @ --- Lógica Exclusiva Miracle Eye ---
    getstatvaluemovechanges bank_target
    jumpifbytevarLT STAT_EVASION CHECK_DARK_TYPE
    isoftype bank_target TYPE_DARK
    jumpifbytevarEQ 1 CHECK_PARTNER_MOVES
    scoreupdate -9
    return_cmd
    
CHECK_DARK_TYPE:
    scoreupdate -9
    return_cmd
CHECK_PARTNER_MOVES: @ Verificação comum a todos
    getpartnerchosenmove
    jumpifwordvarEQ MOVE_FORESIGHT APPLY_PARTNER_PENALTY
    jumpifwordvarEQ MOVE_ODOR_SLEUTH APPLY_PARTNER_PENALTY
    jumpifwordvarEQ MOVE_MIRACLE_EYE APPLY_PARTNER_PENALTY
    return_cmd
    
APPLY_PARTNER_PENALTY:
    scoreupdate -8 @ Penalidade unificada
    return_cmd
APPLY_PENALTY_IDENTIFIED:
    scoreupdate -10
    return_cmd
################################################################################################
DISCOURAGE_ATTACK_HEAL_TARGET_STATUS:
    getmoveid
    jumpifwordvarEQ MOVE_SMELLING_SALTS     CHECK_SMELLINGSALT_STATUS   @ SmellingSalt: Remove paralisia
    jumpifwordvarEQ MOVE_WAKEUP_SLAP     CHECK_WAKE_UP_SLAP_STATUS   @ Wake-Up Slap: Remove sono
    jumpifwordvarEQ MOVE_SPARKLING_ARIA   CHECK_SPARKLING_ARIA_STATUS @ Sparkling Aria: Remove queimadura
    return_cmd

CHECK_SMELLINGSALT_STATUS:
    @ Verifica se o alvo tem Substitute
    affected_by_substitute
    jumpifbytevarEQ 1 SMELLINGSALT_NO_EFFECT
    @ Verifica se o alvo está paralisado
    jumpifstatus bank_target STATUS_PARALYSIS FLIP_SMELLINGSALT_POINTS
    @ Se não está paralisado, penaliza fortemente o movimento
    jumpifrandLT 70 POINTS_MINUS10
    return_cmd
SMELLINGSALT_NO_EFFECT:
    @ Penaliza fortemente se o Substitute bloquear o efeito
    jumpifrandLT 70 POINTS_MINUS10
    return_cmd
FLIP_SMELLINGSALT_POINTS:
    @ Penaliza levemente se o alvo está paralisado (movimento cura o status)
    jumpifrandLT 60 POINTS_MINUS5
    return_cmd
CHECK_WAKE_UP_SLAP_STATUS:
    @ Verifica se o alvo tem Substitute
    affected_by_substitute
    jumpifbytevarEQ 1 WAKE_UP_SLAP_NO_EFFECT
    @ Verifica se o alvo está dormindo
    jumpifstatus bank_target STATUS_SLEEP FLIP_WAKE_UP_POINTS
    @ Verifica se o alvo tem Comatose (conta como dormindo)
    checkability bank_target ABILITY_COMATOSE 1
    jumpifbytevarEQ 1 WAKE_UP_SLAP_NO_EFFECT
    @ Se não está dormindo, penaliza fortemente o movimento
    jumpifrandLT 80 POINTS_MINUS10
    return_cmd
WAKE_UP_SLAP_NO_EFFECT:
    @ Penaliza fortemente se o Substitute bloquear o efeito
    jumpifrandLT 50 POINTS_MINUS10
    return_cmd
FLIP_WAKE_UP_POINTS:
    @ Penaliza levemente se o alvo está dormindo ou com Comatose
    jumpifrandLT 50 POINTS_MINUS5
    return_cmd
CHECK_SPARKLING_ARIA_STATUS:
    @ Verifica se o alvo tem Shield Dust
    checkability bank_target ABILITY_SHIELD_DUST 1
    jumpifbytevarEQ 1 SPARKLING_ARIA_NO_EFFECT
    @ Verifica se o alvo tem queimadura
    jumpifstatus bank_target STATUS_BURN FLIP_ARIA_POINTS
    @ Se não está queimado, penaliza fortemente o movimento
    jumpifrandLT 70 POINTS_MINUS10
    return_cmd
SPARKLING_ARIA_NO_EFFECT:
    @ Penaliza fortemente se Shield Dust bloquear a cura de queimadura
    jumpifrandLT 50 POINTS_MINUS10
    return_cmd
FLIP_ARIA_POINTS:
    @ Penaliza levemente se o alvo está queimado (movimento cura o status)
    jumpifrandLT 50 POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_SWITCH2:
    getmoveid
    jumpifwordvarEQ MOVE_UTURN       SWITCH_CHECK
    jumpifwordvarEQ MOVE_VOLT_SWITCH  SWITCH_CHECK
    return_cmd

@ — Se só resta um pokémon ativo, não adianta trocar —
SWITCH_CHECK:
    countalivepokes bank_ai
    jumpifbytevarLT 1 POINTS_MINUS10         @ só 1 ou 0 pokés vivos → penaliza pesado    
    getitemeffect bank_target @ — Se o alvo vai usar Eject Button, Fecharia a troca —
    jumpifbytevarEQ ITEM_EFFECT_EJECTBUTTON POINTS_MINUS10
    getitemeffect bank_ai @ — Se o usuário está segurando Red Card, não vai trocar —
    jumpifbytevarEQ ITEM_EFFECT_REDCARD    POINTS_MINUS10
    getpartnerchosenmove @ — Se o parceiro já vai usar o mesmo move de troca, é redundante —
    jumpifwordvarEQ MOVE_UTURN       POINTS_MINUS5
    jumpifwordvarEQ MOVE_VOLT_SWITCH  POINTS_MINUS5
    return_cmd
################################################################################################
DISCOURAGE_SUCKER_PUNCH:
    getpredictedmove bank_target
    jumpifwordvarEQ 0 RETURN_CMD_SUCKERPUNCH
    hasanymovewithsplit bank_target SPLIT_STATUS
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifstrikesfirst bank_target bank_ai POINTS_MINUS10

RETURN_CMD_SUCKERPUNCH:
    return_cmd
################################################################################################
DISCOURAGE_FEINT:
    getmoveid
    jumpifwordvarNE MOVE_FEINT END_DISCOURAGE_FEINT    @ Verifica se o movimento é Feint; caso contrário, retorna
    goto_cmd CHECK_PROTECTION_STATUS        @ Verifica se o alvo está usando um movimento de proteção
    goto_cmd CHECK_GUARD_EFFECTS            @ Verifica Wide Guard e Quick Guard
    goto_cmd CHECK_GHOST_IMMUNITY           @ Verifica imunidade do tipo Ghost
    goto_cmd CHECK_SUBSTITUTE_FEINT         @ Verifica se o alvo está protegido por Substitute
    goto_cmd CHECK_PRIORITY_BLOCKERS        @ Verifica habilidades como Dazzling/Queenly Majesty
    return_cmd
CHECK_PROTECTION_STATUS:
    @ Verifica se o alvo está protegido por Protect, Detect, King's Shield, Spiky Shield, etc.
    getprotectuses bank_target
    jumpifbytevarGE 2 POINTS_PLUS10
    getprotectuses bank_targetpartner
    jumpifbytevarGE 2 POINTS_PLUS10
    @ Verifica Mat Block, Baneful Bunker e Obstruct
    jumpifsideaffecting bank_target SIDE_AFFECTING_MATBLOCK POINTS_PLUS10
    jumpifsideaffecting bank_targetpartner SIDE_AFFECTING_MATBLOCK POINTS_PLUS10
    jumpifbankaffecting bank_target BANK_AFFECTING_BANEFULBUNKER POINTS_PLUS10
    jumpifbankaffecting bank_target BANK_AFFECTING_OBSTRUCT POINTS_PLUS10
    goto_cmd NEGATIVE_FEINT                 @ Penaliza se o alvo não estiver protegido
    return_cmd
CHECK_GUARD_EFFECTS:
    @ Verifica Wide Guard e Quick Guard
    jumpifsideaffecting bank_target SIDE_AFFECTING_WIDEGUARD POINTS_PLUS10          @ Encoraja se Wide Guard estiver ativo
    jumpifsideaffecting bank_target SIDE_AFFECTING_QUICKGUARD POINTS_PLUS10          @ Encoraja se Quick Guard estiver ativo
    return_cmd
CHECK_GHOST_IMMUNITY:
    @ Verifica se o alvo é imune a movimentos do tipo Normal
    isoftype bank_target TYPE_GHOST
    jumpifbytevarEQ 1 POINTS_MINUS10         @ Penaliza se o alvo for do tipo Ghost
    return_cmd
CHECK_SUBSTITUTE_FEINT:
    @ Se o alvo estiver protegido por Substitute, Feint não será útil
    affected_by_substitute
    jumpifbytevarEQ 1 POINTS_MINUS10         @ Penaliza se o Substitute bloquear o efeito
    return_cmd
CHECK_PRIORITY_BLOCKERS:
    @ Verifica habilidades que bloqueiam golpes de prioridade como Feint
    checkability bank_target ABILITY_DAZZLING 1
    jumpifbytevarEQ 1 POINTS_MINUS10         @ Penaliza se Dazzling bloquear Feint
    checkability bank_target ABILITY_QUEENLY_MAJESTY 1
    jumpifbytevarEQ 1 POINTS_MINUS10         @ Penaliza se Queenly Majesty bloquear Feint
    return_cmd
END_DISCOURAGE_FEINT:
    return_cmd
NEGATIVE_FEINT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_PROTECT:
    @ 1. Penaliza se HP = 1
    jumpifhealthEQ bank_ai 1 POINTS_MINUS10
    @ 2. Penaliza uso repetido de Protect
    getprotectuses bank_ai
    jumpifbytevarGE 2 POINTS_MINUS10
    jumpifbytevarEQ 1 CHECK_DOUBLE_PROTECT_PENALTY
    @ 3. Penaliza se o oponente tem Moxie ou Beast Boost
    checkability bank_target ABILITY_MOXIE | ABILITY_BEAST_BOOST
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 4. Verifica Magic Guard (imune a dano secundário)
    checkability bank_ai ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    @ --- Verificação de danos secundários ---
	jumpifstatus bank_target STATUS_SLEEP | STATUS_PARALYSIS | STATUS_FREEZE POINTS_MINUS10
    @ 1. Dano de Curse
    jumpifstatus2 bank_ai STATUS2_CURSED POINTS_MINUS10
    @ 2. Dano de Nightmare
    jumpifstatus2 bank_ai STATUS2_NIGHTMARE POINTS_MINUS10
    @ 3. Dano de Leech Seed
    jumpifstatus3 bank_ai STATUS3_SEEDED POINTS_MINUS10
    @ 4. Dano de armadilhas (Wrap/Bind/etc)
    jumpifstatus2 bank_ai STATUS2_WRAPPED POINTS_MINUS10
    @ 5. Dano de veneno (status + Toxic Spikes via arehazardson)
    jumpifstatus bank_ai STATUS_POISON | STATUS_BAD_POISON CHECK_POISON_DAMAGE
    arehazardson2 bank_ai
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 6. Dano climático (sandstorm/hail)
    call_cmd CHECK_WEATHER_DAMAGE
    @ --- Movimentos específicos ---
    getmovescript
    jumpifbytevarEQ 34 CHECK_PROTECT_TYPE @ Movescript para Protect e similares
    return_cmd
CHECK_PROTECT_TYPE:
	getmoveid
    @ Movimentos específicos com penalidades adicionais
    jumpifmove MOVE_QUICK_GUARD | MOVE_WIDE_GUARD | MOVE_CRAFTY_SHIELD CHECK_DOUBLE_BATTLE_ONLY
    jumpifmove MOVE_MAT_BLOCK CHECK_FIRST_TURN_ONLY
    @ --- Novos movimentos adicionados ---
    jumpifmove MOVE_KINGS_SHIELD CHECK_KINGS_SHIELD
    jumpifmove MOVE_SPIKY_SHIELD CHECK_SPIKY_SHIELD
    jumpifmove MOVE_BANEFUL_BUNKER CHECK_BANEFUL_BUNKER
    return_cmd
CHECK_KINGS_SHIELD:
    @ 1. Verifica se o alvo tem Clear Body/White Smoke
    checkability bank_target ABILITY_CLEAR_BODY | ABILITY_WHITE_SMOKE
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 2. Verifica se o ataque do alvo já está no mínimo
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ STAT_ATK CHECK_MIN_ATK
    return_cmd
CHECK_MIN_ATK:
    jumpifbytevarEQ min_stat_stage POINTS_MINUS10
    return_cmd
CHECK_SPIKY_SHIELD:
    @ 1. Verifica se o oponente tem Magic Guard
    checkability bank_target ABILITY_MAGIC_GUARD
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 2. Verifica se o oponente tem movimentos de contato
    hascontactmove bank_target
    jumpifbytevarEQ 0 POINTS_MINUS10
    return_cmd
CHECK_BANEFUL_BUNKER:
    @ 1. Verifica imunidade a veneno
    checkability bank_target ABILITY_IMMUNITY | ABILITY_PASTEL_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 2. Verifica tipos Poison/Steel
    isoftype bank_target TYPE_POISON | TYPE_STEEL
    jumpifbytevarEQ 1 POINTS_MINUS10
    @ 3. Verifica se já está envenenado
    jumpifstatus bank_target STATUS_POISON | STATUS_BAD_POISON POINTS_MINUS10
    return_cmd
CHECK_DOUBLE_BATTLE_ONLY:
    jumpifdoublebattle RETURN_CMD_PROTECT
    goto_cmd NEGATIVE_PROTECT
CHECK_FIRST_TURN_ONLY:
    jumpifstrikesfirst bank_ai bank_target RETURN_CMD_PROTECT
    goto_cmd NEGATIVE_PROTECT
CHECK_DOUBLE_PROTECT_PENALTY:
    @ Penaliza se a IA tentar usar Protect duas vezes seguidas
    jumpifdoublebattle DOUBLE_PROTECT_DOUBLES_PENALTY
    jumpifrandLT 50 POINTS_MINUS5 @ Probabilidade de 50% para penalizar no single
    return_cmd
DOUBLE_PROTECT_DOUBLES_PENALTY:
    jumpifrandLT 100 POINTS_MINUS10 @ Penaliza mais severamente em batalhas duplas
    return_cmd
CHECK_POISON_DAMAGE:
    @ Ignora se for tipo Poison/Steel
    isoftype bank_ai TYPE_POISON | TYPE_STEEL
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    goto_cmd NEGATIVE_PROTECT
CHECK_WEATHER_DAMAGE:
    @ Sandstorm
    jumpifweather weather_sandstorm CHECK_SANDSTORM_IMMUNE
    @ Hail
    jumpifweather weather_hail CHECK_HAIL_IMMUNE
    return_cmd
CHECK_SANDSTORM_IMMUNE:
    isoftype bank_ai TYPE_ROCK | TYPE_STEEL | TYPE_GROUND
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    checkability bank_ai ABILITY_OVERCOAT | ABILITY_SAND_VEIL
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    goto_cmd NEGATIVE_PROTECT
CHECK_HAIL_IMMUNE:
    isoftype bank_ai TYPE_ICE
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    checkability bank_ai ABILITY_OVERCOAT | ABILITY_ICE_BODY
    jumpifbytevarEQ 1 RETURN_CMD_PROTECT
    goto_cmd NEGATIVE_PROTECT
RETURN_CMD_PROTECT:
    return_cmd
NEGATIVE_PROTECT:
	scoreupdate -10
	return_cmd
################################################################################################
DISCOURAGE_ATTRACT:
    isbankinlovewith bank_target bank_ai @ 1. Verifica se já está apaixonado
    jumpifbytevarEQ 1 POINTS_MINUS10
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS10 @ 2. Verifica efetividade 0x
    checkability bank_target ABILITY_OBLIVIOUS @ 3. Verifica habilidade Oblivious
    jumpifbytevarEQ 1 POINTS_MINUS10
    getgender bank_ai @ 4. Verifica gêneros opostos
    jumpifbytevarEQ 0xFF POINTS_MINUS10  @ Sem gênero
    vartovar2
    getgender bank_target
    jumpifbytevarEQ 0xFF POINTS_MINUS10  @ Sem gênero
    jumpifvarsEQ POINTS_MINUS10  @ Mesmo gênero
    checkability bank_target ABILITY_AROMA_VEIL @ 5. Verifica Aroma Veil (no alvo ou parceiro)
    jumpifbytevarEQ 1 POINTS_MINUS10
    isbankpresent bank_targetpartner
    jumpifbytevarEQ 0 CHECK_END_ATTRACT
    checkability bank_targetpartner ABILITY_AROMA_VEIL
    jumpifbytevarEQ 1 POINTS_MINUS10

CHECK_END_ATTRACT:
    return_cmd
################################################################################################
DISCOURAGE_UNLESS_OPPOSITEGENDERS:
	getgender bank_ai
	jumpifbytevarEQ 0xFF POINTS_MINUS10
	vartovar2
	getgender bank_target
	jumpifbytevarEQ 0xFF POINTS_MINUS10
	jumpifvarsEQ POINTS_MINUS10
	return_cmd
DISCOURAGE_CAPTIVATE:
    @ Primeiro verifica os gêneros (chama DISCOURAGE_UNLESS_OPPOSITEGENDERS)
    getgender bank_ai
    jumpifbytevarEQ 0xFF POINTS_MINUS10  @ Gênero desconhecido (genderless)
    vartovar2
    getgender bank_target
    jumpifbytevarEQ 0xFF POINTS_MINUS10  @ Gênero desconhecido (genderless)
    jumpifvarsEQ POINTS_MINUS10          @ Mesmo gênero

    @ Depois verifica a condição de stat target (chama DISCOURAGE_ONESTATTARGET)
    isstatchangepositive
    jumpifbytevarEQ 0x1 POINTS_MINUS10   @ Se for positivo para o usuário
    getstatvaluemovechanges bank_target
    jumpifbytevarEQ 0x0 POINTS_MINUS10   @ Se não puder reduzir a stat
    return_cmd
################################################################################################
DISCOURAGE_RECHARGE:
    getmoveid
    jumpifwordvarEQ MOVE_BLAST_BURN       CHECK_RECHARGE
    jumpifwordvarEQ MOVE_HYDRO_CANNON     CHECK_RECHARGE
    jumpifwordvarEQ MOVE_FRENZY_PLANT     CHECK_RECHARGE
    jumpifwordvarEQ MOVE_GIGA_IMPACT      CHECK_RECHARGE
    jumpifwordvarEQ MOVE_ROCK_WRECKER     CHECK_RECHARGE
    jumpifwordvarEQ MOVE_ROAR_OF_TIME     CHECK_RECHARGE
    jumpifwordvarEQ MOVE_PRISMATIC_LASER  CHECK_RECHARGE
    return_cmd

CHECK_RECHARGE:
    isoftype bank_target TYPE_GHOST @ 1) Verifica imunidade do tipo Ghost para Rock Wrecker
    jumpifbytevarEQ 1 POINTS_MINUS10       @ Penaliza se o alvo for Ghost
    getmoveid
    jumpifwordvarEQ MOVE_ROCK_WRECKER SKIP_BULLETPROOF_CHECK
    goto_cmd CHECK_BULLETPROOF
SKIP_BULLETPROOF_CHECK:
    getprotectuses bank_target @ 2) Verifica se o alvo está usando movimentos de proteção
    jumpifbytevarGE 1 POINTS_MINUS8        @ Penaliza se o alvo estiver protegido
    jumpifhealthLT bank_ai 20 POINTS_MINUS12   @ <20% HP → muito ruim
    jumpifhealthLT bank_ai 50 POINTS_MINUS8    @ <50% HP → arriscado
    goto_cmd CHECK_PARTNER_PROTECTION @ 4) Adiciona camada para golpes de proteção do parceiro
    return_cmd
CHECK_BULLETPROOF:
    checkability bank_target ABILITY_BULLETPROOF 1 @ 5) Verifica se o alvo tem a habilidade Bulletproof
    jumpifbytevarEQ 1 POINTS_MINUS10        @ Penaliza se o alvo tiver Bulletproof
    return_cmd
CHECK_PARTNER_PROTECTION:
	getpartnerchosenmove @ Verifica se o parceiro tem golpes de proteção relevantes
    jumpifwordvarEQ MOVE_PROTECT POINTS_PLUS10
    jumpifwordvarEQ MOVE_WIDE_GUARD POINTS_PLUS10
    jumpifwordvarEQ MOVE_QUICK_GUARD POINTS_PLUS10
    jumpifwordvarEQ MOVE_FOLLOW_ME POINTS_PLUS10
    jumpifwordvarEQ MOVE_RAGE_POWDER POINTS_PLUS10
    return_cmd @ Sai se não houver proteção do parceiro
################################################################################################
DISCOURAGE_TRAP:
    getmoveid
    jumpifwordvarNE MOVE_BIND CHECK_CONDITIONS
    jumpifwordvarNE MOVE_WRAP CHECK_CONDITIONS
    jumpifwordvarNE MOVE_FIRE_SPIN CHECK_CONDITIONS
    jumpifwordvarNE MOVE_CLAMP CHECK_CONDITIONS
    jumpifwordvarNE MOVE_WHIRLPOOL CHECK_CONDITIONS
    jumpifwordvarNE MOVE_SAND_TOMB CHECK_CONDITIONS
    jumpifwordvarNE MOVE_MAGMA_STORM CHECK_CONDITIONS
    jumpifwordvarNE MOVE_INFESTATION CHECK_CONDITIONS
    jumpifwordvarNE MOVE_SNAP_TRAP CHECK_CONDITIONS
    return_cmd
CHECK_CONDITIONS:
    isoftype bank_target TYPE_GHOST @ 1) Verificar imunidade do tipo Ghost
    jumpifbytevarEQ 1 POINTS_MINUS10        @ Penaliza se o alvo for Ghost
    checkability bank_target ABILITY_RUN_AWAY 1 @ 2) Verificar habilidades que anulam aprisionamento
    jumpifbytevarEQ 1 POINTS_MINUS10        @ Penaliza se o alvo tiver Run Away
    checkability bank_target ABILITY_SHADOW_TAG 1
    jumpifbytevarEQ 1 POINTS_MINUS10        @ Penaliza se o alvo tiver Shadow Tag
    checkability bank_target ABILITY_MAGIC_GUARD 1
    jumpifbytevarEQ 1 POINTS_MINUS10        @ Penaliza se o alvo tiver Magic Guard
    getitemeffect bank_target @ 3) Verificar Shed Shell no alvo
    jumpifbytevarEQ ITEM_EFFECT_SHEDSHELL POINTS_MINUS8 @ Penaliza se o alvo estiver segurando Shed Shell
    jumpifstatus2 bank_target STATUS2_WRAPPED POINTS_MINUS8 @ 4) Penalizar se o alvo já estiver preso
    jumpifhealthLT bank_ai 20 POINTS_MINUS12   @ Penaliza se o HP do usuário for <20% (muito arriscado)
    jumpifhealthLT bank_ai 50 POINTS_MINUS8    @ Penaliza se o HP do usuário for <50% (arriscado)
    jumpifhealthLT bank_target 50 POINTS_PLUS10 @ Encoraja se o HP do alvo for <50%
    jumpifhealthLT bank_target 20 POINTS_MINUS5 @ Penaliza se o HP do alvo for muito baixo (<20%)
    countalivepokes bank_target @ 6) Verifica se o adversário tem Pokémon utilizáveis
    jumpifbytevarEQ 1 POINTS_PLUS5            @ Encoraja se o adversário ainda tiver Pokémon utilizáveis
    jumpifleveldifference lvai_higher POINTS_PLUS10 @ Encoraja se o alvo for uma ameaça alta
    call_cmd CHECK_PARTNER_SUPPORT @ 8) Verifica suporte em batalhas de dupla
    return_cmd
CHECK_PARTNER_SUPPORT:
	getpartnerchosenmove @ Verificar se o parceiro pode proteger ou auxiliar
	jumpifwordvarEQ MOVE_PROTECT POINTS_PLUS10
	jumpifwordvarEQ MOVE_WIDE_GUARD POINTS_PLUS10
	jumpifwordvarEQ MOVE_QUICK_GUARD POINTS_PLUS10  @ Um pouco menos relevante que Protect
	jumpifwordvarEQ MOVE_FOLLOW_ME POINTS_PLUS10
	checkability bank_aipartner ABILITY_FRIEND_GUARD 1 @ Verifica habilidades que podem ajudar
	jumpifbytevarEQ 1 POINTS_PLUS10
    return_cmd @ Sai se o parceiro não puder ajudar
################################################################################################
DISCOURAGE_THIRDTYPEADD:
	getmoveid
	jumpifwordvarEQ MOVE_TRICKORTREAT TRICK_OR_TREAT_LOGIC
	jumpifwordvarEQ MOVE_FORESTS_CURSE FORESTS_CURSE_LOGIC
	return_cmd

TRICK_OR_TREAT_LOGIC:
	@ Verifica se o tipo Ghost já está em algum slot
	gettypeinfo AI_TYPE1_TARGET
	jumpifbytevarEQ TYPE_GHOST POINTS_MINUS10
	gettypeinfo AI_TYPE2_TARGET
	jumpifbytevarEQ TYPE_GHOST POINTS_MINUS10
	@ Verifica se o parceiro também está usando Trick or Treat
	getpartnerchosenmove
	jumpifwordvarEQ MOVE_TRICKORTREAT POINTS_MINUS10
	return_cmd

FORESTS_CURSE_LOGIC:
	@ Verifica se o tipo Grass já está em algum slot
	gettypeinfo AI_TYPE1_TARGET
	jumpifbytevarEQ TYPE_GRASS POINTS_MINUS10
	gettypeinfo AI_TYPE2_TARGET
	jumpifbytevarEQ TYPE_GRASS POINTS_MINUS10
	@ Verifica se o parceiro também está usando Forest's Curse
	getpartnerchosenmove
	jumpifwordvarEQ MOVE_FORESTS_CURSE POINTS_MINUS10
	return_cmd

################################################################################################
TAI_SCRIPT_2: @ENCOURAGE a fatal move; bitfield 0x4, AI_TryToFaint
	jumpiftargetisally END_LOCATION
	jumpifattackerhasnodamagingmoves END_LOCATION
	jumpiffatal ENCOURAGE_FATAL
	call_cmd SUICIDAL_MOVES
	jumpifmostpowerful MOST_POWERFUL_MOVE
	jumpifeffectiveness_EQ SUPER_EFFECTIVE AI_TryToFaint_DoubleSuperEffective
	return_cmd

AI_TryToFaint_DoubleSuperEffective:
	jumpifrandLT 90, AI_TryToFaint_End @ Aumenta a chance de usar golpes super efetivos
	scoreupdate +5
	return_cmd
ENCOURAGE_FATAL:
	jumpifmovescriptEQ 23 END_LOCATION @ Ignora se for Explosão, já que será usada de forma natural abaixo
	jumpifstrikesfirst bank_ai bank_target POINTS_PLUS5 @ Prioriza se o movimento for mais rápido
	scoreupdate +5
	return_cmd
MOST_POWERFUL_MOVE:
	jumpifhasnostatusmoves bank_ai POINTS_PLUS4 @ Ignora movimentos de status
	jumpifstatusmovesnotworthusing bank_ai POINTS_PLUS4 @ Ignora movimentos de status que não valem a pena
	getbestdamagelefthp bank_ai bank_target
	jumpifbytevarLT 11 POINTS_PLUS3 @ Maior dano potencial ao HP restante do alvo
	jumpifbytevarLT 31 POINTS_PLUS2
	jumpifbytevarGE 61 END_LOCATION
	jumpifrandGE 0x30 POINTS_PLUS2 @ Pequeno fator aleatório para priorizar dano
	return_cmd
SUICIDAL_MOVES:
	@ Movimentos como Explosão ou Final Gambit para garantir o nocaute
	jumpifmove MOVE_MISTY_EXPLOSION SUICIDE_EXECUTE
	jumpifmove MOVE_MIND_BLOWN SUICIDE_EXECUTE
	jumpifmove MOVE_CHLOROBLAST SUICIDE_EXECUTE
	jumpifmovescriptEQ 21 SUICIDE_EXECUTE @ Explosion & SELFDESTRUCT
	jumpifmovescriptEQ 22 SUICIDE_EXECUTE @ Memento
	jumpifmovescriptEQ 23 SUICIDE_EXECUTE @ Lunal Dance & Healing Wish
	jumpifmovescriptEQ 178 SUICIDE_EXECUTE @ Final Gambit
	return_cmd
SUICIDE_EXECUTE:
	scoreupdate +10 @ Prioriza ao máximo movimentos suicidas
	return_cmd
IS_TARGET_UNABLETOESCAPE:
	getitemeffect bank_target 1
	jumpifbytevarEQ 1 AI_VAR_RETURN_0
	jumpifstatus2 bank_target STATUS2_WRAPPED | STATUS2_TRAPPED AI_VAR_RETURN_1
	abilitypreventsescape bank_ai bank_target
	return_cmd
IS_AI_UNABLETOESCAPE:	
	jumpifstatus2 bank_ai STATUS2_WRAPPED | STATUS2_TRAPPED AI_VAR_RETURN_1
	abilitypreventsescape bank_target bank_ai
	return_cmd
AI_VAR_RETURN_0:
	setbytevar 0x0
	return_cmd
AI_VAR_RETURN_1:
	setbytevar 0x1
	return_cmd
AI_TryToFaint_End:
	return_cmd
################################################################################################
TAI_SCRIPT_1: @encourage moves that make most sense; bitfield 0x2 AI_TryToKO
    jumpiftargetisally END_LOCATION
    call_cmd LOGIC_BASED_ON_HELDITEM
    call_cmd LOGIC_BASED_ON_ABILITIES
    call_cmd LOGIC_BASED_ON_MOVEEFFECTS
    call_cmd LOGIC_BASED_ON_TYPE_EFFECTIVENESS  @ Adiciona a verificação de efetividade aqui
    return_cmd

LOGIC_BASED_ON_TYPE_EFFECTIVENESS:
    getmovetarget
    jumpifbytevarEQ move_target_user END_LOCATION  @ Não considera a efetividade em si mesmo
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3  @ Muito eficaz
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS1   @ Eficaz normalmente
    jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POINTS_MINUS1    @ Pouco eficaz
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS5             @ Sem efeito
    return_cmd
LOGIC_BASED_ON_MOVEEFFECTS:
	jumpifmovescriptEQ 2 LOGIC_ONESTATUSER
	jumpifmovescriptEQ 3 LOGIC_ONESTATTARGET
	jumpifmovescriptEQ 9 LOGIC_ONESTATTARGET
	jumpifmovescriptEQ 12 LOGIC_PUTTOSLEEP
	jumpifmovescriptEQ 13 LOGIC_APPLYSTATCONDITION
	jumpifmovescriptEQ 14 LOGIC_APPLYSTATCONDITION
	jumpifmovescriptEQ 15 LOGIC_APPLYPARALYSIS
	jumpifmovescriptEQ 16 LOGIC_APPLYSTATCONDITION
	jumpifmovescriptEQ 19 LOGIC_RECOIL
	jumpifmovescriptEQ 25 LOGIC_HPHEAL
	jumpifmovescriptEQ 27 LOGIC_CHARGE
	jumpifmovescriptEQ 29 LOGIC_HPHEAL	@Roost
	jumpifmovescriptEQ 31 LOGIC_IDENTYFING
	jumpifmovescriptEQ 34 LOGIC_PROTECT
	jumpifmovescriptEQ 40 LOGIC_WRAP
	jumpifmovescriptEQ 64 LOGIC_MEANLOOK
	jumpifmovescriptEQ 65 LOGIC_PERISHSONG
	jumpifmovescriptEQ 70 LOGIC_ONEHITKO
	jumpifmovescriptEQ 72 LOGIC_ROAR
	jumpifmovescriptEQ 83 LOGIC_DEFENSECURL
	jumpifmovescriptEQ 93 LOGIC_REST
	jumpifmovescriptEQ 100 LOGIC_LOCKON
	jumpifmovescriptEQ 102 LOGIC_BELLYDRUM
	jumpifmovescriptEQ 104 LOGIC_CURSE
	jumpifmovescriptEQ 113 LOGIC_RAPIDSPIN
	jumpifmovescriptEQ 120 LOGIC_FOCUSPUNCH
	jumpifmovescriptEQ 130 LOGIC_BRICKBREAK
	jumpifmovescriptEQ 163 LOGIC_SUNNYDAY
	return_cmd
LOGIC_IDENTYFING:
	call_cmd CAN_TARGET_FAINT_USER
	jumpifbytevarEQ 0x1 POINTS_MINUS2
	jumpifstatbuffGE bank_target STAT_EVASION 7 POINTS_PLUS2
	return_cmd
LOGIC_CHARGE:
	call_cmd LOGIC_ONESTATUSER
	jumpifstatus3 bank_ai STATUS3_CHARGED END_LOCATION
	jumpifhasattackingmovewithtype bank_ai TYPE_ELECTRIC POINTS_PLUS1
	return_cmd
LOGIC_DEFENSECURL:
	call_cmd LOGIC_ONESTATUSER
	jumpifstatus2 bank_ai STATUS2_CURLED END_LOCATION
	jumpifhasmove bank_ai MOVE_ROLLOUT POINTS_PLUS1
	jumpifhasmove bank_ai MOVE_ICE_BALL POINTS_PLUS1
	return_cmd
LOGIC_BRICKBREAK:
	jumpifsideaffecting bank_target SIDE_REFLECT | SIDE_LIGHTSCREEN POINTS_PLUS1
	return_cmd
LOGIC_ONEHITKO:
	islockon_on bank_ai bank_target
	jumpifbytevarEQ 0x1 POINTS_PLUS4
	return_cmd
LOGIC_LOCKON:
	if_ability bank_ai ABILITY_NO_GUARD POINTS_MINUS5
	if_ability bank_target ABILITY_NO_GUARD POINTS_MINUS5
	hasmovewithaccuracylower bank_ai 100
	jumpifbytevarEQ 0x0 POINTS_MINUS1
	hasmovewithaccuracylower bank_ai 40
	jumpifbytevarEQ 0x1 POINTS_PLUS2
	hasmovewithaccuracylower bank_ai 86
	jumpifbytevarEQ 0x1 POINTS_PLUS1
	return_cmd
ENCOURAGE_IF_DREAMEATERNIGHTMARE:
	jumpifhasmove bank_ai MOVE_DREAM_EATER POINTS_PLUS1
	jumpifhasmove bank_ai MOVE_NIGHTMARE POINTS_PLUS1
	return_cmd
LOGIC_PUTTOSLEEP:
	call_cmd ENCOURAGE_IF_DREAMEATERNIGHTMARE
LOGIC_APPLYSTATCONDITION:
	call_cmd CAN_TARGET_FAINT_USER
	jumpifbytevarEQ 1 POINTS_MINUS3
	return_cmd
LOGIC_APPLYPARALYSIS:
	call_cmd LOGIC_APPLYSTATCONDITION
	jumpifstrikesfirst bank_target bank_ai POINTS_PLUS4
	scoreupdate 3
	return_cmd
LOGIC_SUNNYDAY:
	cantargetfaintuser 1
	jumpifbytevarEQ 0x1 POINTS_MINUS1
	if_ability bank_ai ABILITY_CHLOROPHYLL POINTS_PLUS2
	jumpifhasmove bank_ai MOVE_SOLAR_BEAM POINTS_PLUS2
	jumpifhasmove bank_ai MOVE_GROWTH POINTS_PLUS2
	jumpifhasmove bank_ai MOVE_SYNTHESIS POINTS_PLUS2
	isoftype bank_ai TYPE_FIRE
	jumpifbytevarEQ 0x1 POINTS_PLUS2
	return_cmd
LOGIC_CURSE:
	isoftype bank_ai TYPE_GHOST
	jumpifbytevarEQ 0x0 END_LOCATION
	cantargetfaintuser 1
	jumpifbytevarEQ 0x1 POINTS_MINUS1
	call_cmd IS_TARGET_UNABLETOESCAPE
	call_cmd PLUS1_IF_VAR_NE_0
	call_cmd PLUS1_IF_VAR_NE_0
	return_cmd
LOGIC_RECOIL: @Don't risk using recoil move, if it won't make difference
	getability bank_ai 1
	jumpifbytevarEQ ABILITY_ROCK_HEAD END_LOCATION
	isrecoilmovenecessary
	jumpifbytevarEQ 0x0 POINTS_MINUS3
	return_cmd
LOGIC_HPHEAL:
	jumpifhealthLT bank_ai 26 POINTS_PLUS4
	jumpifhealthGE bank_ai 67 END_LOCATION
	getlastusedmove bank_ai
	vartovar2
	getmoveid
	jumpifvarsEQ END_LOCATION
	jumpifhealthLT bank_ai 56 POINTS_PLUS2
	return_cmd
LOGIC_ROAR_ON_EVASION_BOOST:
	if_ability bank_ai ABILITY_NO_GUARD END_LOCATION
	if_ability bank_target ABILITY_NO_GUARD END_LOCATION
	jumpifstatus2 bank_target STATUS2_IDENTIFIED END_LOCATION
	jumpifbankaffecting bank_target BANK_AFFECTING_MIRACLEEYE END_LOCATION
	jumpifstatbuffGE bank_ai STAT_EVASION 7 POINTS_PLUS2
	return_cmd
LOGIC_ROAR_ON_SUBSTITUTE:
	jumpifnostatus2 bank_target STATUS2_SUBSTITUTE END_LOCATION
	getbestdamagelefthp bank_ai bank_target
	jumpifbytevarGE 25 END_LOCATION
	if_ability bank_ai ABILITY_INFILTRATOR END_LOCATION
	scoreupdate 3
	return_cmd
LOGIC_ROAR:
	scoreupdate -1 @to not use it when it's not necessary
	cantargetfaintuser 1
	jumpifbytevarEQ 1 POINTS_MINUS5
	call_cmd LOGIC_ROAR_ON_EVASION_BOOST
	call_cmd LOGIC_ROAR_ON_SUBSTITUTE
	jumpifstatbuffGE bank_target STAT_ATK 7 POINTS_PLUS3
	jumpifstatbuffGE bank_target STAT_SP_ATK 7 POINTS_PLUS3
	return_cmd
LOGIC_REST:
	cantargetfaintuser 1
	call_cmd PLUS1_IF_VAR_NE_0
	return_cmd
HAS_ATTACKER_PRIORITY_MOVE:
	hasprioritymove bank_ai
	return_cmd
PLUS1_IF_VAR_NE_0:
	jumpifbytevarNE 0x0 POINTS_PLUS1
	return_cmd
LOGIC_BELLYDRUM:
	hasanymovewithsplit bank_ai SPLIT_PHYSICAL
	jumpifbytevarEQ 0x0 POINTS_MINUS3
	gettypeofattacker bank_ai
	jumpifbytevarEQ SPLIT_SPECIAL POINTS_MINUS1
	cantargetfaintuser 1
	jumpifbytevarEQ 1 POINTS_MINUS1
	call_cmd HAS_ATTACKER_PRIORITY_MOVE
	call_cmd PLUS1_IF_VAR_NE_0
	return_cmd
LOGIC_FOCUSPUNCH:
	jumpifstatus2 bank_ai STATUS2_SUBSTITUTE POINTS_PLUS2
	return_cmd
LOGIC_PROTECT:
	getmoveid
	getprotectuses bank_ai
	jumpifbytevarNE 0 END_LOCATION
	jumpifmove MOVE_ENDURE LOGIC_ENDURE
	isinsemiinvulnerablestate bank_target
	jumpifbytevarEQ 1 POINTS_PLUS5
	isintruantturn bank_target
	jumpifbytevarEQ 1 POINTS_PLUS5
	jumpifstatus3 bank_target STATUS3_PERISHSONG POINTS_PLUS2
	return_cmd
LOGIC_ENDURE:
	jumpifhealthLT bank_ai 25 POINTS_MINUS2
	cantargetfaintuser 1
	jumpifbytevarEQ 0x0 POINTS_MINUS1
	jumpifhasmove bank_ai MOVE_FLAIL POINTS_PLUS1
	jumpifhasmove bank_ai MOVE_REVERSAL POINTS_PLUS1
	return_cmd
LOGIC_TRAPPING:
	jumpifhasmove bank_ai MOVE_PERISH_SONG POINTS_PLUS2
	jumpifstatus2 bank_target STATUS2_CURSED POINTS_PLUS2
	jumpifhasmove bank_ai MOVE_CURSE POINTS_PLUS1
	return_cmd
LOGIC_MEANLOOK:
	call_cmd IS_TARGET_UNABLETOESCAPE
	jumpifbytevarEQ 0x1 END_LOCATION
	call_cmd LOGIC_TRAPPING
	return_cmd
LOGIC_WRAP:
	jumpifstatus2 bank_target STATUS2_WRAPPED END_LOCATION
	call_cmd LOGIC_TRAPPING
	return_cmd
LOGIC_RAPIDSPIN:
	arehazardson bank_ai
	jumpifbytevarEQ 1 POINTS_PLUS2
	return_cmd
LOGIC_PERISHSONG:
	jumpifstatus3 bank_ai STATUS3_PERISHSONG END_LOCATION
	call_cmd IS_TARGET_UNABLETOESCAPE
	jumpifbytevarEQ 0x0 END_LOCATION
	jumpifhealthLT bank_ai 31 END_LOCATION
	call_cmd POINTS_PLUS3
	jumpifhasmovewithscript bank_ai 34 POINTS_PLUS1
	return_cmd
CAN_TARGET_FAINT_USER:
	cantargetfaintuser 1
	jumpifbytevarEQ 0x1 END_LOCATION
	jumpifstrikesfirst bank_ai bank_target END_LOCATION
	cantargetfaintuser 2
	return_cmd
LOGIC_ONESTATUSER:
	call_cmd CAN_TARGET_FAINT_USER
	jumpifbytevarEQ 0x1 POINTS_MINUS2
	logiconestatuser
	return_cmd
LOGIC_ONESTATTARGET:
	call_cmd CAN_TARGET_FAINT_USER
	jumpifbytevarEQ 0x1 POINTS_MINUS3
	logiconestattarget
	return_cmd
LOGIC_BASED_ON_ABILITIES: @To do Contrary
	getability bank_ai 1
	jumpifbytevarEQ ABILITY_SPEED_BOOST ABILITY_USER_SPEEDBOOST
	jumpifbytevarEQ ABILITY_SERENE_GRACE ABILITY_USER_SERENEGRACE
	jumpifbytevarEQ ABILITY_TRUANT ABILITY_USER_TRUANT
	return_cmd
ABILITY_USER_SERENEGRACE:
	if_ability bank_target ABILITY_SHIELD_DUST END_LOCATION
	getmoveeffectchance
	jumpifbytevarEQ 0x0 END_LOCATION
	call_cmd POINTS_PLUS1
	jumpifstatus bank_target STATUS_PARALYSIS SERENEGRACE_FLINCHPARHAX
	return_cmd
SERENEGRACE_FLINCHPARHAX:
	if_ability bank_target ABILITY_INNER_FOCUS END_LOCATION
	jumpifstrikessecond bank_ai bank_target END_LOCATION
	jumpifmovescriptEQ 11 POINTS_PLUS1
	return_cmd
IFBATONPASS_PLUS1:
	getmoveid
	jumpifmove MOVE_BATON_PASS POINTS_PLUS1
	return_cmd
ABILITY_USER_TRUANT:
	jumpifmovescriptEQ 39 POINTS_PLUS1 @recharge needed
	return_cmd
ABILITY_USER_SPEEDBOOST:
	getmoveid
	call_cmd IFBATONPASS_PLUS1
	jumpifstrikesfirst bank_ai bank_target END_LOCATION
	getprotectuses bank_ai
	jumpifbytevarNE 0x0 END_LOCATION
	jumpifmove MOVE_ENDURE END_LOCATION
	jumpifmovescriptNE 34 END_LOCATION
	goto_cmd NEGATIVE_SPEEDBOOT
NEGATIVE_SPEEDBOOT:
	scoreupdate +1
	return_cmd
LOGIC_BASED_ON_HELDITEM:
	getitemeffect bank_ai 1
	jumpifbytevarEQ ITEM_EFFECT_ORANBERRY HELDITEM_USER_ORAN
	jumpifbytevarEQ ITEM_EFFECT_CHERIBERRY HELDITEM_USER_CHERI
	jumpifbytevarEQ ITEM_EFFECT_CHESTOBERRY HELDITEM_USER_CHESTO
	jumpifbytevarEQ ITEM_EFFECT_PECHABERRY HELDITEM_USER_PECHA
	jumpifbytevarEQ ITEM_EFFECT_RAWSTBERRY HELDITEM_USER_RAWST
	jumpifbytevarEQ ITEM_EFFECT_ASPEARBERRY HELDITEM_USER_ASPEAR
	jumpifbytevarEQ ITEM_EFFECT_LEPPABERRY HELDITEM_USER_LEPPA
	jumpifbytevarEQ ITEM_EFFECT_PERSIMBERRY HELDITEM_USER_PERSIM
	jumpifbytevarEQ ITEM_EFFECT_LUMBERRY HELDITEM_USER_LUM
	jumpifbytevarEQ ITEM_EFFECT_FIGYBERRY HELDITEM_USER_FIGY
	jumpifbytevarEQ ITEM_EFFECT_WIKIBERRY HELDITEM_USER_FIGY
	jumpifbytevarEQ ITEM_EFFECT_MAGOBERRY HELDITEM_USER_FIGY
	jumpifbytevarEQ ITEM_EFFECT_AGUAVBERRY HELDITEM_USER_FIGY
	jumpifbytevarEQ ITEM_EFFECT_IAPAPABERRY HELDITEM_USER_FIGY
	jumpifbytevarEQ ITEM_EFFECT_SITRUSBERRY HELDITEM_USER_SITRUS
	jumpifbytevarEQ ITEM_EFFECT_LIECHIBERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_GANLONBERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_SALACBERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_PETAYABERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_APICOTBERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_STARFBERRY HELDITEM_USER_BERRYSTATRAISE
	jumpifbytevarEQ ITEM_EFFECT_LANSATBERRY HELDITEM_USER_BERRYFOCUSENERGY
	jumpifbytevarEQ ITEM_EFFECT_WHITEHERB HELDITEM_USER_WHITEHERB
	jumpifbytevarEQ ITEM_EFFECT_MACHOBRACE HELDITEM_USER_MACHOBRACE
	jumpifbytevarEQ ITEM_EFFECT_MENTALHERB HELDITEM_USER_MENTALHERB
	jumpifbytevarEQ ITEM_EFFECT_CHOICEBAND HELDITEM_USER_CHOICEBAND
	jumpifbytevarEQ ITEM_EFFECT_CHOICESPECS HELDITEM_USER_CHOICESPECS
	jumpifbytevarEQ ITEM_EFFECT_CHOICESCARF HELDITEM_USER_CHOICESCARF
	jumpifbytevarEQ ITEM_EFFECT_SILVERPOWDER HELDITEM_USER_SILVER
	jumpifbytevarEQ ITEM_EFFECT_CHARCOAL HELDITEM_USER_CHARCOAL
	jumpifbytevarEQ ITEM_EFFECT_MYSTICWATER HELDITEM_USER_MW
	jumpifbytevarEQ ITEM_EFFECT_BLACKGLASSES HELDITEM_USER_BG
	jumpifbytevarEQ ITEM_EFFECT_MAGNET HELDITEM_USER_MAGNET
	jumpifbytevarEQ ITEM_EFFECT_MIRACLESEED HELDITEM_USER_MS
	jumpifbytevarEQ ITEM_EFFECT_SOFTSAND HELDITEM_USER_SS
	jumpifbytevarEQ ITEM_EFFECT_SHARPBEAK HELDITEM_USER_SB
	jumpifbytevarEQ ITEM_EFFECT_TWISTEDSPOON HELDITEM_USER_TTS
	jumpifbytevarEQ ITEM_EFFECT_HARDSTONE HELDITEM_USER_HS
	jumpifbytevarEQ ITEM_EFFECT_METALCOAT HELDITEM_USER_MC
	jumpifbytevarEQ ITEM_EFFECT_POISONBARB HELDITEM_USER_PB
	jumpifbytevarEQ ITEM_EFFECT_FAIRYPLATE HELDITEM_USER_FAIRYPLATE
	jumpifbytevarEQ ITEM_EFFECT_SILKSCARF HELDITEM_USER_SILKSCARF
	jumpifbytevarEQ ITEM_EFFECT_ADAMANTORB HELDITEM_USER_ADAMANTORB
	jumpifbytevarEQ ITEM_EFFECT_GRISEOUSORB HELDITEM_USER_GRISEOUSORB
	jumpifbytevarEQ ITEM_EFFECT_LUSTROUSORB HELDITEM_USER_LUSTROUSORB
	jumpifbytevarEQ ITEM_EFFECT_EVIOLITE HELDITEM_USER_EVIOLITE
	jumpifbytevarEQ ITEM_EFFECT_ASSAULTVEST HELDITEM_USER_ASSAULTVEST
	jumpifbytevarEQ ITEM_EFFECT_MUSCLEBAND HELDITEM_USER_MUSCLEBAND
	jumpifbytevarEQ ITEM_EFFECT_WISEGLASSES HELDITEM_USER_WISEGLASSES
	jumpifbytevarEQ ITEM_EFFECT_BURNDRIVE HELDITEM_USER_DRIVE
	jumpifbytevarEQ ITEM_EFFECT_CHILLDRIVE HELDITEM_USER_DRIVE
	jumpifbytevarEQ ITEM_EFFECT_DOUSEDRIVE HELDITEM_USER_DRIVE
	jumpifbytevarEQ ITEM_EFFECT_SHOCKDRIVE HELDITEM_USER_DRIVE
	jumpifbytevarEQ ITEM_EFFECT_EXPERTBELT HELDITEM_USER_EXPERTBELT
	jumpifbytevarEQ ITEM_EFFECT_LAGGINGTAIL HELDITEM_USER_LAGGINGTAIL
	jumpifbytevarEQ ITEM_EFFECT_FLOATSTONE HELDITEM_USER_FLOATSTONE
	jumpifbytevarEQ ITEM_EFFECT_METRONOME HELDITEM_USER_METRONOME
	jumpifbytevarEQ ITEM_EFFECT_SAFETYGOOGLES HELDITEM_USER_SAFETYGOOGLES
	jumpifbytevarEQ ITEM_EFFECT_LIFEORB HELDITEM_USER_LIFEORB
	jumpifbytevarEQ ITEM_EFFECT_SHELLBELL HELDITEM_USER_SHELLBELL
	jumpifbytevarEQ ITEM_EFFECT_THICKCLUB HELDITEM_USER_THICKCLUB
	jumpifbytevarEQ ITEM_EFFECT_DRAGONFANG HELDITEM_USER_DF
	jumpifbytevarEQ ITEM_EFFECT_DRAGONSCALE HELDITEM_USER_DF
	jumpifbytevarEQ ITEM_EFFECT_SPELLTAG HELDITEM_USER_ST
	jumpifbytevarEQ ITEM_EFFECT_BLACKBELT HELDITEM_USER_BLACKBELT
	jumpifbytevarEQ ITEM_EFFECT_NEVERMELTICE HELDITEM_USER_NMI
	jumpifbytevarEQ ITEM_EFFECT_SOULDEW HELDITEM_USER_SOULDEW
	jumpifbytevarEQ ITEM_EFFECT_DEEPSEATOOTH HELDITEM_USER_DEEPSEATOOTH
	jumpifbytevarEQ ITEM_EFFECT_DEEPSEASCALE HELDITEM_USER_DEEPSEASCALE
	jumpifbytevarEQ ITEM_EFFECT_FOCUSBAND HELDITEM_USER_FOCUSBAND
	jumpifbytevarEQ ITEM_EFFECT_LIGHTBALL HELDITEM_USER_LIGHTBALL
	jumpifbytevarEQ ITEM_EFFECT_SCOPELENS HELDITEM_USER_ENCOURAGECRITS
	jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW HELDITEM_USER_ENCOURAGECRITS
	jumpifbytevarEQ ITEM_EFFECT_LUCKYPUNCH HELDITEM_USER_ENCOURAGECRITS
	jumpifbytevarEQ ITEM_EFFECT_STICK HELDITEM_USER_ENCOURAGECRITS
	jumpifbytevarEQ ITEM_EFFECT_LEFTOVERS HELDITEM_USER_LEFTOVERS
	jumpifbytevarEQ ITEM_EFFECT_WIDELENS HELDITEM_USER_WIDELENS
	jumpifbytevarEQ ITEM_EFFECT_ZOOMLENS HELDITEM_USER_ZOOMLENS
	jumpifbytevarEQ ITEM_EFFECT_HEATROCK HELDITEM_USER_HEATROCK
	jumpifbytevarEQ ITEM_EFFECT_ICYROCK HELDITEM_USER_ICYROCK
	jumpifbytevarEQ ITEM_EFFECT_SMOOTHROCK HELDITEM_USER_SMOOTHROCK
	jumpifbytevarEQ ITEM_EFFECT_DAMPROCK HELDITEM_USER_DAMPROCK
	jumpifbytevarEQ ITEM_EFFECT_LIGHTCLAY HELDITEM_USER_LIGHTCLAY
	jumpifbytevarEQ ITEM_EFFECT_BINDINGBAND HELDITEM_USER_ENCOURAGEWRAP
	jumpifbytevarEQ ITEM_EFFECT_GRIPCLAW HELDITEM_USER_ENCOURAGEWRAP
	jumpifbytevarEQ ITEM_EFFECT_BLACKSLUDGE HELDITEM_USER_BLACKSLUDGE
	jumpifbytevarEQ ITEM_EFFECT_STICKYBARB HELDITEM_USER_STICKYBARB
	jumpifbytevarEQ ITEM_EFFECT_FLAMEORB HELDITEM_USER_FLAMEORB
	jumpifbytevarEQ ITEM_EFFECT_TOXICORB HELDITEM_USER_TOXICORB
	jumpifbytevarEQ ITEM_EFFECT_WEAKNESSPOLICY HELDITEM_USER_WEAKNESSPOLICY
	jumpifbytevarEQ ITEM_EFFECT_EJECTBUTTON HELDITEM_USER_EJECTBUTTON
	jumpifbytevarEQ ITEM_EFFECT_REDCARD HELDITEM_USER_REDCARD
	jumpifbytevarEQ ITEM_EFFECT_ROCKYHELMET HELDITEM_USER_ROCKYHELMET
	jumpifbytevarEQ ITEM_EFFECT_DESTINYKNOT HELDITEM_USER_DESTINYKNOT
	jumpifbytevarEQ ITEM_EFFECT_LUMINOUSMOSS HELDITEM_USER_LUMINOUSMOSS
	jumpifbytevarEQ ITEM_EFFECT_CELLBATTERY HELDITEM_USER_CELLBATTERY
	jumpifbytevarEQ ITEM_EFFECT_SNOWBALL HELDITEM_USER_SNOWBALL
	jumpifbytevarEQ ITEM_EFFECT_ABSORBBULB HELDITEM_USER_ABSORBBULB
	jumpifbytevarEQ ITEM_EFFECT_QUICKPOWDER HELDITEM_USER_QUICKPOWDER
	jumpifbytevarEQ ITEM_EFFECT_BIGROOT HELDITEM_USER_BIGROOT
	jumpifbytevarEQ ITEM_EFFECT_CUSTAPBERRY HELDITEM_USER_CUSTAPBERRY
	jumpifbytevarEQ ITEM_EFFECT_POWERHERB HELDITEM_USER_POWERHERB
	jumpifbytevarEQ ITEM_EFFECT_SHEDSHELL HELDITEM_USER_SHEDSHELL
	jumpifbytevarEQ ITEM_EFFECT_GEM HELDITEM_USER_GEM
	jumpifbytevarEQ ITEM_EFFECT_KEEBERRY HELDITEM_USER_KEEBERRY
	jumpifbytevarEQ ITEM_EFFECT_MARANGABERRY HELDITEM_USER_MARANGABERRY
	jumpifbytevarEQ ITEM_EFFECT_MICLEBERRY HELDITEM_USER_MICLEBERRY
	jumpifbytevarEQ ITEM_EFFECT_JABOCABERRY HELDITEM_USER_JABOCABERRY
	jumpifbytevarEQ ITEM_EFFECT_ROWAPBERRY HELDITEM_USER_ROWAPBERRY
	jumpifbytevarEQ ITEM_EFFECT_THROATSPRAY HELDITEM_USER_THROATSPRAY
	jumpifbytevarEQ ITEM_EFFECT_BLUNDERPOLICY HELDITEM_USER_BLUNDERPOLICY
	jumpifbytevarEQ ITEM_EFFECT_EJECTPACK HELDITEM_USER_EJECTPACK
	jumpifbytevarEQ ITEM_EFFECT_ODD_INCENSE HELDITEM_USER_ODD_INCENSE
	jumpifbytevarEQ ITEM_EFFECT_ROCK_INCENSE HELDITEM_USER_ROCK_INCENSE
	jumpifbytevarEQ ITEM_EFFECT_ROSE_INCENSE HELDITEM_USER_ROSE_INCENSE
	jumpifbytevarEQ ITEM_EFFECT_WAVE_INCENSE HELDITEM_USER_WAVE_INCENSE
	jumpifbytevarEQ ITEM_EFFECT_SEAINCENSE HELDITEM_USER_WAVE_INCENSE
	jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW HELDITEM_USER_RAZOR_CLAW
	jumpifbytevarEQ ITEM_EFFECT_ROOMSERVICE HELDITEM_USER_ROOMSERVICE
	jumpifbytevarEQ ITEM_EFFECT_HEAVYDUTYBOOTS HELDITEM_USER_HEAVYDUTYBOOTS
	jumpifbytevarEQ ITEM_EFFECT_UTILITYUMBRELLA HELDITEM_USER_UTILITYUMBRELLA
	return_cmd
.align 1
MOVES_LOWERING_USERS_STAT:
.hword MOVE_CURSE, MOVE_OVERHEAT, MOVE_DRACO_METEOR, MOVE_LEAF_STORM, MOVE_SHELL_SMASH, 0xFFFF
################################################################################################
HELDITEM_USER_UTILITYUMBRELLA:
    jumpifweather weather_rain | weather_heavy_rain | weather_sun | weather_harsh_sun POINTS_PLUS3
    get_curr_move_type
	jumpifbytevarEQ TYPE_WATER | TYPE_FIRE POINTS_PLUS3  @ Verifica se o movimento é afetado pelo clima
    checkability bank_ai ABILITY_CHLOROPHYLL
    jumpifbytevarEQ 1 POINTS_PLUS1
    checkability bank_ai ABILITY_SWIFT_SWIM
    jumpifbytevarEQ 1 POINTS_PLUS1
    goto_cmd UTILITYUMBRELLA_PENALIZE                                @ Penaliza se o item não for relevante

UTILITYUMBRELLA_PENALIZE:
    scoreupdate -3
################################################################################################
HELDITEM_USER_HEAVYDUTYBOOTS:
    arehazardson bank_ai
    jumpifbytevarEQ 1 HAZARDS_HEAVYDUTYBOOTS                        @ Verifica se há hazards no campo
    jumpifhealthLT bank_ai 50 POINTS_PLUS1
    jumpifstrikesfirst bank_ai bank_target POINTS_PLUS1		@ Verifica a Speed atual do Pokémon
    goto_cmd HEAVYDUTYBOOTS_PENALIZE                                 @ Penaliza se o item não for relevante

HAZARDS_HEAVYDUTYBOOTS:
    scoreupdate +3                                                   @ Grande bônus se houver hazards no campo
    goto_cmd HEAVYDUTYBOOTS_END

HEAVYDUTYBOOTS_PENALIZE:
    scoreupdate -3                                                   @ Penaliza severamente se o item não for estratégico

HEAVYDUTYBOOTS_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_ROOMSERVICE:
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM ROOMSERVICE_BONUS_FIELD	@ Verifica se Trick Room está ativo no campo
    jumpifstrikesfirst bank_ai bank_target POINTS_PLUS2		@ Verifica a Speed atual do Pokémon
    jumpifstrikessecond bank_target bank_ai POINTS_PLUS1				@ Verifica a Speed do adversário
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    goto_cmd ROOMSERVICE_PENALIZE                                   @ Penaliza se o item não for relevante

ROOMSERVICE_BONUS_FIELD:
    scoreupdate +3                                                  @ Grande bônus se Trick Room estiver ativo
    goto_cmd ROOMSERVICE_END

ROOMSERVICE_PENALIZE:
    scoreupdate -3                                                  @ Penaliza severamente se o item não for estratégico

ROOMSERVICE_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_RAZOR_CLAW:
	hashighcriticalratio
	jumpifbytevarEQ 0x1 RAZOR_CLAW_CRIT_BONUS_CHECK              @ Verifica se o item aumenta a taxa de crítico
    jumpifhealthLT bank_ai 50 POINTS_PLUS1
    jumpifhealthLT bank_target 50 POINTS_PLUS1
    goto_cmd RAZOR_CLAW_PENALIZE                                    @ Penaliza se o item não for relevante

RAZOR_CLAW_CRIT_BONUS_CHECK:
    scoreupdate +2
    goto_cmd RAZOR_CLAW_END

RAZOR_CLAW_PENALIZE:
    scoreupdate -3

RAZOR_CLAW_END:
    return_cmd
################################################################################################
HELDITEM_USER_WAVE_INCENSE:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS3
	get_curr_move_type
    jumpifbytevarEQ TYPE_WATER POINTS_PLUS2
	jumpifhealthLT bank_target 50 POINTS_PLUS1
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    goto_cmd ODD_INCENSE_PENALIZE                                    @ Penaliza se o item não for relevante

WAVE_INCENSE_PENALIZE:
    scoreupdate -3
################################################################################################
HELDITEM_USER_ROSE_INCENSE:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS3
	get_curr_move_type
    jumpifbytevarEQ TYPE_GRASS POINTS_PLUS2
	jumpifhealthLT bank_target 50 POINTS_PLUS1
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    goto_cmd ODD_INCENSE_PENALIZE                                    @ Penaliza se o item não for relevante

ROSE_INCENSE_PENALIZE:
    scoreupdate -3
################################################################################################
HELDITEM_USER_ROCK_INCENSE:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS3
	get_curr_move_type
    jumpifbytevarEQ TYPE_ROCK POINTS_PLUS2            
	jumpifhealthLT bank_target 50 POINTS_PLUS1
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    goto_cmd ODD_INCENSE_PENALIZE                                    @ Penaliza se o item não for relevante

ROCK_INCENSE_PENALIZE:
    scoreupdate -3
################################################################################################
HELDITEM_USER_ODD_INCENSE:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS3
	get_curr_move_type
    jumpifbytevarEQ TYPE_PSYCHIC POINTS_PLUS2
	jumpifhealthLT bank_target 50 POINTS_PLUS1
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    goto_cmd ODD_INCENSE_PENALIZE                                    @ Penaliza se o item não for relevante

ODD_INCENSE_PENALIZE:
    scoreupdate -3
################################################################################################
HELDITEM_USER_EJECTPACK:
    jumpifstatbuffLT bank_ai STAT_ATK default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_DEF default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_SP_ATK default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_SP_DEF default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_SPD default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_ACC default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_EVASION default_stat_stage POINTS_PLUS3
    jumpifmovescriptEQ 4 POINTS_PLUS3
    jumpifmovescriptEQ 8 POINTS_PLUS3
    jumpifhealthLT bank_ai 50 POINTS_PLUS1
    goto_cmd EJECTPACK_PENALIZE                                     @ Penaliza se o item não for relevante

EJECTPACK_PENALIZE:
    scoreupdate -3                                                  @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_BLUNDERPOLICY:
    getmoveaccuracy
	jumpifbytevarLT 80 POINTS_PLUS3
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    jumpifhealthLT bank_target 50 POINTS_PLUS1
    goto_cmd BLUNDERPOLICY_PENALIZE                                 @ Penaliza se o item não for relevante

BLUNDERPOLICY_PENALIZE:
    scoreupdate -3                                                  @ Penaliza severamente se o item não for estratégico

BLUNDERPOLICY_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_THROATSPRAY:
	getmoveid
	jumpifhwordvarinlist sound_moves POINTS_PLUS3
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    jumpifhealthLT bank_target 50 POINTS_PLUS1
	goto_cmd THROATSPRAY_PENALIZE

THROATSPRAY_PENALIZE:
    scoreupdate -3
	return_cmd
################################################################################################
HELDITEM_USER_ROWAPBERRY:
    hasanymovewithsplit bank_target SPLIT_SPECIAL
    jumpifbytevarEQ 0x1 ROWAP_BONUS_SPECIAL @ Verifica se o adversário usa um ataque especial
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    jumpifhealthLT bank_target 50 POINTS_PLUS1                    @ Verifica o HP do adversário
    checkability bank_ai ABILITY_STURDY
    jumpifbytevarEQ 0x1 ROWAP_BONUS_STURDY             @ Verifica sinergia com Sturdy
    goto_cmd ROWAP_PENALIZE                                           @ Penaliza se o item não for relevante

ROWAP_BONUS_SPECIAL:
    scoreupdate +3                                                    @ Grande bônus contra ataques especiais
    goto_cmd ROWAP_END

ROWAP_BONUS_STURDY:
    scoreupdate +2                                                    @ Bônus médio para sinergia com Sturdy
    goto_cmd ROWAP_END

ROWAP_PENALIZE:
    scoreupdate -3                                                    @ Penaliza severamente se o item não for estratégico

ROWAP_END:
    return_cmd                                                        @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_JABOCABERRY:
    hasanymovewithsplit bank_target SPLIT_SPECIAL
    jumpifbytevarEQ 0x1 JABOCA_BONUS_PHYSICAL @ Verifica se o adversário usa um ataque físico
    jumpifhealthLT bank_ai 30 POINTS_PLUS1
    jumpifhealthLT bank_target 50 POINTS_PLUS1                    @ Verifica o HP do adversário
    checkability bank_ai ABILITY_STURDY
    jumpifbytevarEQ 0x1 JABOCA_BONUS_STURDY             @ Verifica sinergia com Sturdy
    goto_cmd JABOCA_PENALIZE                                           @ Penaliza se o item não for relevante

JABOCA_BONUS_PHYSICAL:
    scoreupdate +3                                                    @ Grande bônus contra ataques físicos
    goto_cmd JABOCA_END

JABOCA_BONUS_STURDY:
    scoreupdate +2                                                    @ Bônus médio para sinergia com Sturdy
    goto_cmd JABOCA_END

JABOCA_PENALIZE:
    scoreupdate -3                                                    @ Penaliza severamente se o item não for estratégico

JABOCA_END:
    return_cmd                                                        @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_MICLEBERRY:
    jumpifhealthLT bank_ai 25 POINTS_PLUS3                  @ Verifica se o HP é ≤ 25%
    getmoveaccuracy
    jumpifbytevarLT 80 POINTS_PLUS3             @ Obtém a precisão do movimento atual
    getmovepower
    jumpifwordvarEQ 80 POINTS_PLUS2                   @ Obtém o poder do movimento atual
    goto_cmd MICLEBERRY_PENALIZE                                   @ Penaliza se o item não for relevante

MICLEBERRY_PENALIZE:
    scoreupdate -3                                                 @ Penaliza severamente se o item não for estratégico

MICLEBERRY_END:
    return_cmd                                                     @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_MARANGABERRY:
    hasanymovewithsplit bank_target SPLIT_SPECIAL
    jumpifbytevarEQ 0x1 MARANGA_BONUS_SPECIAL @ Verifica se o adversário usa um ataque especial
    jumpifhealthLT bank_ai 30 POINTS_PLUS1                      @ Verifica o HP do Pokémon
    checkability bank_ai ABILITY_MULTISCALE
    jumpifbytevarEQ 1 MARANGA_BONUS_MULTISCALE @ Verifica sinergia com Multiscale
    goto_cmd MARANGA_PENALIZE                                       @ Penaliza se o item não for relevante

MARANGA_BONUS_SPECIAL:
    scoreupdate +3                                                  @ Grande bônus para ataques especiais
    goto_cmd MARANGA_END

MARANGA_BONUS_MULTISCALE:
    scoreupdate +2                                                  @ Bônus médio para sinergia com Multiscale
    goto_cmd MARANGA_END

MARANGA_PENALIZE:
    scoreupdate -3                                                  @ Penaliza severamente se o item não for estratégico

MARANGA_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_KEEBERRY:
    hasanymovewithsplit bank_target SPLIT_PHYSICAL
    jumpifbytevarEQ 0x1 KEEBERRY_BONUS_PHYSICAL @ Verifica se o adversário usa um ataque físico
    jumpifhealthLT bank_ai 30 POINTS_MINUS2                      @ Verifica o HP do Pokémon
    checkability bank_ai ABILITY_STURDY
    jumpifbytevarEQ 1 KEEBERRY_BONUS_STURDY         @ Verifica sinergia com Sturdy
    checkability bank_ai ABILITY_MULTISCALE
    jumpifbytevarEQ 1 KEEBERRY_BONUS_STURDY @ Verifica sinergia com Multiscale
    goto_cmd KEEBERRY_PENALIZE                                       @ Penaliza se o item não for relevante

KEEBERRY_BONUS_PHYSICAL:
    scoreupdate +3                                                  @ Grande bônus para ataques físicos
    goto_cmd KEEBERRY_END

KEEBERRY_BONUS_STURDY:
    scoreupdate +2                                                  @ Bônus médio para sinergia com Sturdy
    goto_cmd KEEBERRY_END

KEEBERRY_PENALIZE:
    scoreupdate -3                                                  @ Penaliza severamente se o item não for estratégico

KEEBERRY_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_GEM:
    checkstab bank_ai
    jumpifbytevarEQ 1 GEM_BONUS_STAB                    @ Verifica se o movimento é STAB
    jumpifeffectiveness_EQ SUPER_EFFECTIVE GEM_BONUS_SUPER_EFFECTIVE      @ Verifica se o movimento é super efetivo
    jumpifeffectiveness_EQ NO_EFFECT GEM_PENALIZE_IMMUNE           @ Penaliza se o adversário for imune ao movimento
    jumpifhealthLT bank_target 40 GEM_TARGET_HP_CHECK              @ Obtém o HP atual do alvo
    jumpifmostpowerful GEM_BONUS_SUPER_EFFECTIVE                   @ Verifica o golpe mais poderoso disponível
    goto_cmd GEM_END                                                @ Finaliza

GEM_BONUS_STAB:
    scoreupdate +2                                                 @ Bônus médio para movimentos STAB
    goto_cmd GEM_END

GEM_BONUS_SUPER_EFFECTIVE:
    scoreupdate +3                                                 @ Grande bônus para movimentos super efetivos
    goto_cmd GEM_END

GEM_PENALIZE_IMMUNE:
    scoreupdate -3                                                 @ Penaliza severamente movimentos imunes
    goto_cmd GEM_END

GEM_TARGET_HP_CHECK:
    scoreupdate +1                                                 @ Pequeno bônus se o HP do alvo for ≥ 50%
    goto_cmd GEM_END

GEM_END:
    return_cmd                                                     @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SHEDSHELL:
    jumpifstatus2 bank_ai STATUS2_WRAPPED SHEDSHELL_BONUS_TRAPPED       @ Verifica se o Pokémon está preso
    checkability bank_target ABILITY_ARENA_TRAP
	jumpifbytevarEQ 1 SHEDSHELL_BONUS_ARENATRAP @ Verifica se o adversário tem Arena Trap
    checkability bank_target ABILITY_SHADOW_TAG
	jumpifbytevarEQ 1 SHEDSHELL_BONUS_ARENATRAP @ Verifica se o adversário tem Shadow Tag
    jumpifmove MOVE_UTURN SHEDSHELL_BONUS_PIVOT             @ Verifica sinergia com U-turn
    jumpifmove MOVE_VOLT_SWITCH SHEDSHELL_BONUS_PIVOT        @ Verifica sinergia com Volt Switch
    goto_cmd SHEDSHELL_PENALIZE                                      @ Penaliza se o item não for relevante

SHEDSHELL_BONUS_TRAPPED:
    scoreupdate +3                                                  @ Grande bônus se o Pokémon estiver preso
    goto_cmd SHEDSHELL_END

SHEDSHELL_BONUS_ARENATRAP:
    scoreupdate +2                                                  @ Bônus médio para Arena Trap
    goto_cmd SHEDSHELL_END

SHEDSHELL_BONUS_PIVOT:
    scoreupdate +1                                                  @ Pequeno bônus para sinergia com U-turn/Volt Switch
    goto_cmd SHEDSHELL_END

SHEDSHELL_PENALIZE:
    scoreupdate -3                                                  @ Penaliza se o item não for estratégico

SHEDSHELL_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_POWERHERB:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE CHECKMOVE
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS CHECKMOVE
	jumpifeffectiveness_EQ NOT_VERY_EFFECTIVE POWERHERB_PENALIZE
	jumpifeffectiveness_EQ NO_EFFECT POWERHERB_PENALIZE
	goto_cmd POWERHERB_END

CHECKMOVE:
    getmoveid
	jumpifmovescriptEQ 71 POWERHERB_BONUS
    goto_cmd POWERHERB_PENALIZE                                @ Penaliza se o item não for relevante

POWERHERB_BONUS:
    scoreupdate +3                                             @ Grande bônus para Solar Beam
    goto_cmd POWERHERB_END

POWERHERB_PENALIZE:
    scoreupdate -3                                             @ Penaliza severamente se o item não for relevante

POWERHERB_END:
    return_cmd                                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_CUSTAPBERRY:
    jumpifhealthLT bank_ai 26 POINTS_PLUS2                  @ Verifica se o HP está abaixo de 25%
	hasprioritymove bank_ai
	jumpifbytevarEQ 1 CUSTAPBERRY_BONUS_PRIORITY
    goto_cmd CUSTAPBERRY_PENALIZE                                    @ Penaliza se o item não for relevante

CUSTAPBERRY_BONUS_PRIORITY:
    scoreupdate +3                                                   @ Grande bônus para movimentos prioritários
    goto_cmd CUSTAPBERRY_END

CUSTAPBERRY_PENALIZE:
    scoreupdate -2                                                   @ Penaliza se nenhuma condição for atendida

CUSTAPBERRY_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_ENCOURAGEWRAP:
    jumpifnostatus2 bank_target STATUS2_WRAPPED BINDINGBAND_BONUS_WRAPPED  @ Verifica se o alvo está preso por movimentos de aprisionamento
	jumpifmovescriptEQ 40 POINTS_PLUS2
	jumpifmove MOVE_ANCHOR_SHOT POINTS_PLUS2
	jumpifmove MOVE_BLOCK POINTS_PLUS2
	jumpifmove MOVE_FAIRY_LOCK POINTS_PLUS2
	jumpifmove MOVE_INGRAIN POINTS_PLUS2
	jumpifmove MOVE_MEAN_LOOK POINTS_PLUS2
	jumpifmove MOVE_SPIDER_WEB POINTS_PLUS2
	jumpifmove MOVE_SPIRIT_SHACKLE POINTS_PLUS2
	jumpifmove MOVE_THOUSAND_WAVES POINTS_PLUS2
    goto_cmd HELDITEM_PENALIZE_NO_WRAP                                      @ Penaliza se nenhum movimento de aprisionamento for usado

BINDINGBAND_BONUS_WRAPPED:
    scoreupdate +3                                                         @ Grande bônus para movimentos de aprisionamento ativos
    goto_cmd HELDITEM_END

HELDITEM_USER_GRIPCLAW:
    jumpifnostatus2 bank_target STATUS2_WRAPPED BINDINGBAND_BONUS_WRAPPED     @ Verifica se o alvo está preso por movimentos de aprisionamento
    goto_cmd HELDITEM_PENALIZE_NO_WRAP                                      @ Penaliza se nenhum movimento de aprisionamento for usado

HELDITEM_PENALIZE_NO_WRAP:
    scoreupdate -2                                                         @ Penaliza se nenhum movimento de aprisionamento for usado
    goto_cmd HELDITEM_END

HELDITEM_END:
    return_cmd                                                             @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_BIGROOT:
    getmoveid
    jumpifmove MOVE_ABSORB BIGROOT_BONUS_INGRAIN         @ Prioriza Giga Drain
    jumpifmove MOVE_GIGA_DRAIN BIGROOT_BONUS_LEECHSEED				@ Prioriza Giga Drain
    jumpifmove MOVE_MEGA_DRAIN BIGROOT_BONUS_LEECHSEED				@ Prioriza Giga Drain
    jumpifmove MOVE_OBLIVION_WING BIGROOT_BONUS_LEECHSEED			@ Prioriza Giga Drain
    jumpifmove MOVE_DREAM_EATER BIGROOT_BONUS_DRAINPUNCH			@ Prioriza Drain Punch
    jumpifmove MOVE_DRAIN_PUNCH BIGROOT_BONUS_DRAINPUNCH			@ Prioriza Drain Punch
    jumpifmove MOVE_HORN_LEECH BIGROOT_BONUS_DRAINPUNCH				@ Prioriza Drain Punch
    jumpifmove MOVE_LEECH_LIFE BIGROOT_BONUS_DRAINPUNCH				@ Prioriza Leech Life
    jumpifmove MOVE_PARABOLIC_CHARGE BIGROOT_BONUS_DRAINPUNCH		@ Prioriza Parabolic Charge
    jumpifmove MOVE_LEECH_SEED BIGROOT_BONUS_LEECHSEED				@ Prioriza Leech Seed
    jumpifstatus3 bank_target STATUS3_ROOTED BIGROOT_BONUS_INGRAIN	@ Verifica sinergia com Ingrain
    jumpifhealthGE bank_ai 80 POINTS_MINUS3							@ Penaliza se o HP for muito baixo
    scoreupdate -2													@ Penaliza se nenhuma condição for atendida
    goto_cmd BIGROOT_END

BIGROOT_BONUS_DRAINPUNCH:
    scoreupdate +2                                           @ Bônus médio para Drain Punch
    goto_cmd BIGROOT_END

BIGROOT_BONUS_LEECHSEED:
    scoreupdate +3                                           @ Grande bônus para Leech Seed
    goto_cmd BIGROOT_END

BIGROOT_BONUS_INGRAIN:
    scoreupdate +1                                           @ Pequeno bônus para Ingrain
    goto_cmd BIGROOT_END

BIGROOT_END:
    return_cmd                                               @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_QUICKPOWDER:
    getbankspecies bank_ai
    jumpifwordvarEQ POKE_DITTO QUICKPOWDER_BONUS_DITTO  @ Verifica se o Pokémon é Ditto
    jumpifstatus2 bank_ai POKE_DITTO QUICKPOWDER_PENALIZE_TRANSFORMED @ Penaliza se Ditto já estiver transformado
    goto_cmd QUICKPOWDER_PENALIZE                               @ Penaliza se o item não for relevante

QUICKPOWDER_BONUS_DITTO:
    scoreupdate +3                                              @ Grande bônus para Ditto não transformado
    goto_cmd QUICKPOWDER_END

QUICKPOWDER_PENALIZE_TRANSFORMED:
    scoreupdate -3                                              @ Penaliza severamente se Ditto já estiver transformado
    goto_cmd QUICKPOWDER_END

QUICKPOWDER_PENALIZE:
    scoreupdate -5                                              @ Penaliza severamente se não for Ditto

QUICKPOWDER_END:
    return_cmd                                                  @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_ABSORBBULB:
    getmovetype bank_target
	jumpifbytevarEQ TYPE_WATER ABSORBBULB_BONUS_WATER      @ Verifica se o adversário tem movimentos do tipo Water
    checkability bank_ai ABILITY_STORM_DRAIN
    jumpifbytevarEQ 1 ABSORBBULB_BONUS_STORMDRAIN @ Verifica sinergia com Storm Drain
    checkability bank_ai ABILITY_WATER_ABSORB
    jumpifbytevarEQ 1 ABSORBBULB_BONUS_STORMDRAIN @ Verifica sinergia com Water Absorb
    jumpifhealthLT bank_ai 25 POINTS_MINUS3             @ Penaliza se o HP for muito baixo
    scoreupdate -2                                                    @ Penaliza se nenhuma condição for atendida
    goto_cmd ABSORBBULB_END

ABSORBBULB_BONUS_WATER:
    scoreupdate +3                                                   @ Grande bônus para adversários com movimentos do tipo Water
    goto_cmd ABSORBBULB_END

ABSORBBULB_BONUS_STORMDRAIN:
    scoreupdate +2                                                   @ Bônus médio para Storm Drain
    goto_cmd ABSORBBULB_END

ABSORBBULB_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SNOWBALL:
    getmovetype bank_target
	jumpifbytevarEQ TYPE_ICE SNOWBALL_BONUS_ICE           @ Verifica se o adversário tem movimentos do tipo Ice
	checkstab bank_ai
    jumpifbytevarEQ 1 SNOWBALL_BONUS_WEAKNESS    @ Verifica se o Pokémon é fraco a movimentos do tipo Ice
    jumpifhealthLT bank_ai 25 POINTS_MINUS3             @ Penaliza se o HP for muito baixo
    scoreupdate -2                                                    @ Penaliza se nenhuma condição for atendida
    goto_cmd SNOWBALL_END

SNOWBALL_BONUS_ICE:
    scoreupdate +3                                                   @ Grande bônus para adversários com movimentos do tipo Ice
    goto_cmd SNOWBALL_END

SNOWBALL_BONUS_WEAKNESS:
    scoreupdate +2                                                   @ Bônus médio se o Pokémon for fraco a movimentos do tipo Ice
    goto_cmd SNOWBALL_END

SNOWBALL_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_CELLBATTERY:
    getmovetype bank_target
	jumpifbytevarEQ TYPE_ELECTRIC CELLBATTERY_BONUS_ELECTRIC @ Verifica se o adversário tem movimentos do tipo Electric
    checkability bank_ai ABILITY_LIGHTNING_ROD
	jumpifbytevarEQ 1 CELLBATTERY_BONUS_LIGHTNINGROD @ Verifica sinergia com Lightning Rod
    checkability bank_ai ABILITY_VOLT_ABSORB
	jumpifbytevarEQ 1 CELLBATTERY_BONUS_LIGHTNINGROD @ Verifica sinergia com Volt Absorb
    jumpifhealthLT bank_ai 25 POINTS_MINUS3             @ Penaliza se o HP for muito baixo
    scoreupdate -2                                                      @ Penaliza se nenhuma condição for atendida
    goto_cmd CELLBATTERY_END

CELLBATTERY_BONUS_ELECTRIC:
    scoreupdate +3                                                     @ Grande bônus para adversários com movimentos do tipo Electric
    goto_cmd CELLBATTERY_END

CELLBATTERY_BONUS_LIGHTNINGROD:
    scoreupdate +2                                                     @ Bônus médio para Lightning Rod
    goto_cmd CELLBATTERY_END

CELLBATTERY_END:
    return_cmd                                                         @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_LUMINOUSMOSS: 
    getmovetype bank_target
	jumpifbytevarEQ TYPE_WATER LUMINOUSMOSS_BONUS_WATER    @ Verifica se o adversário tem movimentos do tipo Water
    checkability bank_ai ABILITY_STORM_DRAIN
	jumpifbytevarEQ 1 LUMINOUSMOSS_BONUS_STORMDRAIN @ Verifica sinergia com Storm Drain
    checkability bank_ai ABILITY_WATER_ABSORB
	jumpifbytevarEQ 1 LUMINOUSMOSS_BONUS_STORMDRAIN @ Verifica sinergia com Water Absorb
    jumpifhealthLT bank_ai 25 POINTS_MINUS3             @ Penaliza se o HP for muito baixo
    scoreupdate -2                                                    @ Penaliza se nenhuma condição for atendida
    goto_cmd LUMINOUSMOSS_END

LUMINOUSMOSS_BONUS_WATER:
    scoreupdate +3                                                   @ Grande bônus para adversários com movimentos do tipo Water
    goto_cmd LUMINOUSMOSS_END

LUMINOUSMOSS_BONUS_STORMDRAIN:
    scoreupdate +2                                                   @ Bônus médio para Storm Drain
    goto_cmd LUMINOUSMOSS_END

LUMINOUSMOSS_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_DESTINYKNOT:
    getmoveid
    jumpifmove MOVE_ATTRACT DESTINYKNOT_BONUS_ATTRACT       @ Prioriza Attract
    checkability bank_ai ABILITY_CUTE_CHARM
	jumpifbytevarEQ 1 DESTINYKNOT_BONUS_CUTECHARM @ Verifica sinergia com Cute Charm
    goto_cmd DESTINYKNOT_PENALIZE                          @ Penaliza se nenhuma condição for atendida

DESTINYKNOT_BONUS_ATTRACT:
    scoreupdate +3                                         @ Grande bônus para Attract
    goto_cmd DESTINYKNOT_END

DESTINYKNOT_BONUS_CUTECHARM:
    scoreupdate +2                                         @ Bônus médio para Cute Charm
    goto_cmd DESTINYKNOT_END

DESTINYKNOT_PENALIZE:
    scoreupdate -3                                         @ Penaliza se o item não for relevante

DESTINYKNOT_END:
    return_cmd                                             @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_ROCKYHELMET:
    checkability bank_ai ABILITY_IRON_BARBS
	jumpifbytevarEQ 1 ROCKYHELMET_BONUS_IRONBARBS @ Verifica sinergia com Iron Barbs
    checkability bank_ai ABILITY_ROUGH_SKIN
	jumpifbytevarEQ 1 ROCKYHELMET_BONUS_ROUGH_SKIN @ Verifica sinergia com Rough Skin
    hascontactmove bank_target
	jumpifbytevarEQ 1 ROCKYHELMET_BONUS_CONTACT            @ Verifica se o adversário tem movimentos de contato
    jumpifhealthLT bank_ai 25 POINTS_MINUS3               @ Penaliza se o HP for muito baixo
    hasanymovewithsplit bank_ai SPLIT_STATUS
	jumpifbytevarEQ 1 ROCKYHELMET_BONUS_SUPPORT                @ Verifica movimentos de suporte
    scoreupdate -2                                                     @ Penaliza se nenhuma condição for atendida
    goto_cmd ROCKYHELMET_END

ROCKYHELMET_BONUS_IRONBARBS:
    scoreupdate +3                                                     @ Grande bônus para Iron Barbs
    goto_cmd ROCKYHELMET_END

ROCKYHELMET_BONUS_ROUGH_SKIN:
    scoreupdate +3                                                     @ Grande bônus para Rough Skin
    goto_cmd ROCKYHELMET_END

ROCKYHELMET_BONUS_CONTACT:
    scoreupdate +2                                                     @ Bônus médio se o adversário usar movimentos de contato
    goto_cmd ROCKYHELMET_END

ROCKYHELMET_BONUS_SUPPORT:
    scoreupdate +1                                                     @ Pequeno bônus para movimentos de suporte (Toxic, Spikes, etc.)
    goto_cmd ROCKYHELMET_END

ROCKYHELMET_END:
    return_cmd                                                         @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_REDCARD:
    checkability bank_ai ABILITY_STURDY
	jumpifbytevarEQ 1 REDCARD_BONUS_STURDY           @ Verifica sinergia com Sturdy
    checkability bank_ai ABILITY_MULTISCALE
	jumpifbytevarEQ 1 REDCARD_BONUS_MULTISCALE   @ Verifica sinergia com Multiscale
    hasanymovewithsplit bank_ai SPLIT_STATUS
	jumpifbytevarEQ 1 REDCARD_BONUS_MULTISCALE                   @ Verifica movimentos de suporte
    jumpifhealthLT bank_ai 25 POINTS_MINUS3                  @ Penaliza se o HP for muito baixo
    checkability bank_target ABILITY_MAGIC_GUARD
	jumpifbytevarEQ 1 REDCARD_PENALIZE_MAGICGUARD @ Penaliza se o adversário tiver Magic Guard
    checkability bank_target ABILITY_SHEER_FORCE
	jumpifbytevarEQ 1 REDCARD_PENALIZE_MAGICGUARD @ Penaliza para Sheer Force
    scoreupdate -2                                                    @ Penaliza se nenhuma condição for atendida
    goto_cmd REDCARD_END

REDCARD_BONUS_STURDY:
    scoreupdate +3                                                    @ Grande bônus para Sturdy
    goto_cmd REDCARD_END

REDCARD_BONUS_MULTISCALE:
    scoreupdate +2                                                    @ Bônus médio para Multiscale
    goto_cmd REDCARD_END

REDCARD_PENALIZE_MAGICGUARD:
    scoreupdate -3                                                    @ Penaliza severamente para Magic Guard/Sheer Force
    goto_cmd REDCARD_END

REDCARD_END:
    return_cmd                                                        @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_EJECTBUTTON:
    checkability bank_ai ABILITY_REGENERATOR
	jumpifbytevarEQ 1 EJECTBUTTON_BONUS_REGENERATOR   @ Verifica sinergia com Regenerator
    checkability bank_ai ABILITY_STURDY
	jumpifbytevarEQ 1 EJECTBUTTON_BONUS_STURDY           @ Verifica sinergia com Sturdy
    jumpifmove MOVE_UTURN EJECTBUTTON_BONUS_UTURN                         @ Prioriza U-turn
    jumpifmove MOVE_VOLT_SWITCH EJECTBUTTON_BONUS_VOLTSWITCH               @ Prioriza Volt Switch
    jumpifhealthLT bank_target 25 POINTS_MINUS3                  @ Penaliza se o HP for muito baixo
    scoreupdate -2                                                        @ Penaliza se nenhuma condição for atendida
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_BONUS_REGENERATOR:
    scoreupdate +3                                                        @ Grande bônus para Regenerator
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_BONUS_STURDY:
    scoreupdate +2                                                        @ Bônus médio para Sturdy
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_BONUS_UTURN:
    scoreupdate +2                                                        @ Bônus médio para U-turn
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_BONUS_VOLTSWITCH:
    scoreupdate +2                                                        @ Bônus médio para Volt Switch
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_BONUS_SUPPORT:
    scoreupdate +1                                                        @ Pequeno bônus para movimentos de suporte
    goto_cmd EJECTBUTTON_END

EJECTBUTTON_END:
    return_cmd                                                            @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_WEAKNESSPOLICY:
    checkability bank_ai ABILITY_STURDY
	jumpifbytevarEQ 1 WEAKNESSPOLICY_BONUS_STURDY    @ Verifica sinergia com Sturdy
    checkability bank_ai ABILITY_MULTISCALE
	jumpifbytevarEQ 1 WEAKNESSPOLICY_BONUS_MULTISCALE @ Verifica sinergia com Multiscale
	checkstab bank_target
    jumpifbytevarEQ 1 WEAKNESSPOLICY_BONUS_STURDY
    jumpifmove MOVE_ENDURE WEAKNESSPOLICY_BONUS_ENDURE                @ Prioriza Endure para garantir ativação
    scoreupdate -2                                                   @ Penaliza se nenhuma condição for atendida
    goto_cmd WEAKNESSPOLICY_END

WEAKNESSPOLICY_BONUS_STURDY:
    scoreupdate +3                                                   @ Grande bônus para Sturdy
    goto_cmd WEAKNESSPOLICY_END

WEAKNESSPOLICY_BONUS_MULTISCALE:
    scoreupdate +2                                                   @ Bônus médio para Multiscale
    goto_cmd WEAKNESSPOLICY_END

WEAKNESSPOLICY_BONUS_ENDURE:
    scoreupdate +1                                                   @ Pequeno bônus para Endure
    goto_cmd WEAKNESSPOLICY_END

WEAKNESSPOLICY_PENALIZE_USED:
    scoreupdate -3                                                   @ Penaliza se o item já foi consumido
    goto_cmd WEAKNESSPOLICY_END

WEAKNESSPOLICY_END:
    return_cmd                                                       @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_FLAMEORB:
    checkability bank_ai ABILITY_GUTS
	jumpifbytevarEQ 1 FLAMEORB_BONUS_GUTS             @ Verifica sinergia com Guts
    checkability bank_ai ABILITY_MAGIC_GUARD
	jumpifbytevarEQ 1 FLAMEORB_BONUS_MAGICGUARD @ Verifica sinergia com Magic Guard
    checkability bank_ai ABILITY_QUICK_FEET
	jumpifbytevarEQ 1 FLAMEORB_BONUS_QUICKFEET  @ Verifica sinergia com Quick Feet
    jumpifmove MOVE_FACADE FLAMEORB_BONUS_FACADE                     @ Prioriza movimentos como Facade
    jumpifmove MOVE_PSYCHO_SHIFT FLAMEORB_BONUS_PSYCHOSHIFT          @ Prioriza Psycho Shift para transferir Burn
    jumpifstatus bank_ai STATUS_ANY FLAMEORB_PENALIZE_ALREADY_STATUS  @ Penaliza se já houver outro status
    scoreupdate -2                                                  @ Penaliza se nenhuma condição for atendida
    goto_cmd FLAMEORB_END

FLAMEORB_BONUS_GUTS:
    scoreupdate +3                                                  @ Grande bônus para Guts
    goto_cmd FLAMEORB_END

FLAMEORB_BONUS_MAGICGUARD:
    scoreupdate +3                                                  @ Grande bônus para Magic Guard
    goto_cmd FLAMEORB_END

FLAMEORB_BONUS_QUICKFEET:
    scoreupdate +2                                                  @ Bônus médio para Quick Feet
    goto_cmd FLAMEORB_END

FLAMEORB_BONUS_FACADE:
    scoreupdate +1                                                  @ Pequeno bônus para Facade
    goto_cmd FLAMEORB_END

FLAMEORB_BONUS_PSYCHOSHIFT:
    scoreupdate +2                                                  @ Bônus médio para Psycho Shift
    goto_cmd FLAMEORB_END

FLAMEORB_PENALIZE_ALREADY_STATUS:
    scoreupdate -3                                                  @ Penaliza se já estiver com outro status
    goto_cmd FLAMEORB_END

FLAMEORB_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_TOXICORB:
    checkability bank_ai ABILITY_POISON_HEAL
	jumpifbytevarEQ 1 TOXICORB_BONUS_POISONHEAL							@ Verifica sinergia com Poison Heal
    checkability bank_ai ABILITY_GUTS
	jumpifbytevarEQ 1 TOXICORB_BONUS_GUTS								@ Verifica sinergia com Guts
    checkability bank_ai ABILITY_QUICK_FEET
	jumpifbytevarEQ 1 TOXICORB_BONUS_QUICKFEET							@ Verifica sinergia com Quick Feet
    jumpifmove MOVE_FACADE TOXICORB_BONUS_FACADE						@ Prioriza movimentos como Facade
    jumpifstatus bank_ai STATUS_ANY TOXICORB_PENALIZE_ALREADY_STATUS	@ Penaliza se já houver outro status
    scoreupdate -2														@ Penaliza se nenhuma condição for atendida
    goto_cmd TOXICORB_END

TOXICORB_BONUS_POISONHEAL:
    scoreupdate +3                                                  @ Grande bônus para Poison Heal
    goto_cmd TOXICORB_END

TOXICORB_BONUS_GUTS:
    scoreupdate +2                                                  @ Bônus médio para Guts
    goto_cmd TOXICORB_END

TOXICORB_BONUS_QUICKFEET:
    scoreupdate +2                                                  @ Bônus médio para Quick Feet
    goto_cmd TOXICORB_END

TOXICORB_BONUS_FACADE:
    scoreupdate +1                                                  @ Pequeno bônus para Facade
    goto_cmd TOXICORB_END

TOXICORB_PENALIZE_ALREADY_STATUS:
    scoreupdate -3                                                  @ Penaliza se já estiver com outro status
    goto_cmd TOXICORB_END

TOXICORB_END:
    return_cmd                                                      @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_STICKYBARB:
	hascontactmove bank_ai
    jumpifbytevarEQ 1 STICKYBARB_BONUS_CONTACT @ Verifica se o Pokémon tem movimento de contato
    jumpifmove MOVE_TRICK STICKYBARB_BONUS_TRICK        @ Prioriza Trick para transferir o item
    jumpifmove MOVE_SWITCHEROO STICKYBARB_BONUS_TRICK   @ Prioriza Switcheroo para transferir o item
	jumpifitem bank_target ITEM_NONE STICKYBARB_BONUS_TRANSFER @ Verifica se o adversário não tem item
    scoreupdate -2                                      @ Penaliza se nenhuma condição for atendida
    goto_cmd STICKYBARB_END

STICKYBARB_BONUS_CONTACT:
    scoreupdate +3                                      @ Grande bônus para movimentos de contato
    goto_cmd STICKYBARB_END

STICKYBARB_BONUS_TRICK:
    scoreupdate +3                                      @ Grande bônus para Trick e Switcheroo
    goto_cmd STICKYBARB_END

STICKYBARB_BONUS_TRANSFER:
    scoreupdate +2                                      @ Bônus médio se o adversário não tiver item
    goto_cmd STICKYBARB_END

STICKYBARB_END:
    return_cmd                                          @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_BLACKSLUDGE:
    isoftype bank_ai TYPE_POISON
	jumpifbytevarEQ 1 BLACKSLUDGE_BONUS_POISON @ Verifica se o Pokémon é do tipo Poison
    checkability bank_ai ABILITY_POISON_HEAL
	jumpifbytevarEQ 1 BLACKSLUDGE_BONUS_HEAL @ Verifica se o Pokémon tem Poison Heal
    jumpifmove MOVE_TRICK BLACKSLUDGE_BONUS_TRICK         @ Prioriza Trick para estratégias ofensivas
    jumpifmove MOVE_SWITCHEROO BLACKSLUDGE_BONUS_TRICK    @ Prioriza Switcheroo para estratégias ofensivas
    jumpifmove MOVE_FLING BLACKSLUDGE_BONUS_FLING         @ Prioriza Fling para estratégias ofensivas
    scoreupdate -2                                        @ Penaliza se o Pokémon não for Poison e não tiver sinergia
    goto_cmd BLACKSLUDGE_END

BLACKSLUDGE_BONUS_POISON:
    scoreupdate +3                                        @ Grande bônus para Pokémon do tipo Poison
    goto_cmd BLACKSLUDGE_END

BLACKSLUDGE_BONUS_HEAL:
    scoreupdate +3                                        @ Grande bônus para Poison Heal
    goto_cmd BLACKSLUDGE_END

BLACKSLUDGE_BONUS_TRICK:
    scoreupdate +2                                        @ Bônus médio para movimentos como Trick ou Switcheroo
    goto_cmd BLACKSLUDGE_END

BLACKSLUDGE_BONUS_FLING:
    scoreupdate +1                                        @ Pequeno bônus para Fling (uso situacional)
    goto_cmd BLACKSLUDGE_END

BLACKSLUDGE_END:
    return_cmd                                            @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_CHESTO:
	jumpifhealthGE bank_ai 50 END_LOCATION
    jumpifstatus bank_ai STATUS_SLEEP CHESTO_AI_SLEEPING
    goto_cmd CHESTO_AI_NOT_SLEEPING

CHESTO_AI_SLEEPING:
    scoreupdate +3  @ Prioritize impactful moves after sleep removal
    return_cmd
CHESTO_AI_NOT_SLEEPING:
    return_cmd  @ Neutral logic if not sleeping
################################################################################################
HELDITEM_USER_PECHA:
    jumpifstatus bank_ai STATUS_POISON PECHA_AI_POISONED
    goto_cmd PECHA_AI_NOT_POISONED

PECHA_AI_POISONED:
    scoreupdate +3  @ Prioritize impactful moves as poisoning will be removed
    return_cmd
PECHA_AI_NOT_POISONED:
    return_cmd  @ Neutral logic if not poisoned
################################################################################################
HELDITEM_USER_RAWST:
    jumpifstatus bank_ai STATUS_BURN RAWST_AI_BURNED
    goto_cmd RAWST_AI_NOT_BURNED

RAWST_AI_BURNED:
    scoreupdate +3  @ Prioritize impactful moves as the burn will be removed
    return_cmd
RAWST_AI_NOT_BURNED:
    return_cmd  @ Neutral logic if not burned
################################################################################################
HELDITEM_USER_ASPEAR:
    jumpifstatus bank_ai STATUS_FREEZE ASPEAR_AI_FROZEN
    goto_cmd ASPEAR_AI_NOT_FROZEN

ASPEAR_AI_FROZEN:
    scoreupdate +3  @ Prioritize impactful moves as the freeze will be removed
    return_cmd
ASPEAR_AI_NOT_FROZEN:
    return_cmd  @ Neutral logic if not frozen
################################################################################################
HELDITEM_USER_LEPPA:
    checklowpp bank_ai            @ Verifica se algum golpe do atacante tem 5 PP ou menos
    jumpifbytevarEQ 1 POINTS_PLUS2 @ Se encontrou PP baixo, salta para POINTS_PLUS2
    return_cmd                    @ Caso contrário, segue o fluxo normal

POINTS_PLUS2:
    scoreupdate +2                @ Aumenta a pontuação para priorizar o uso do item
    return_cmd                    @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_PERSIM:
    jumpifstatus bank_ai STATUS_CONFUSION PERSIM_AI_CONFUSED
    goto_cmd PERSIM_AI_NOT_CONFUSED

PERSIM_AI_CONFUSED:
    scoreupdate +3
    return_cmd
PERSIM_AI_NOT_CONFUSED:
    return_cmd
################################################################################################
HELDITEM_USER_LUM:
    call_cmd CHECK_AI_STATUS
    return_cmd

CHECK_AI_STATUS:
    jumpifstatus bank_ai STATUS_ANY LUM_AI_STATUS_ACTIVE
    return_cmd
LUM_AI_STATUS_ACTIVE:
    scoreupdate +3
    return_cmd
################################################################################################
HELDITEM_USER_FIGY:
    jumpifhealthGE bank_ai 40 FIGY_AI_HIGH_HP  @ If HP >= 50%, neutral logic
    call_cmd CHECK_FIGY_CONFUSION_AI
    scoreupdate +3
    return_cmd

FIGY_AI_HIGH_HP:
    return_cmd
CHECK_FIGY_CONFUSION_AI:
	jumpifrandLT 30 
    scoreupdate -2
    return_cmd
################################################################################################
HELDITEM_USER_LIGHTCLAY:
    getmoveid
    jumpifmove MOVE_REFLECT LIGHTCLAY_BONUS_REFLECT			@ Prioriza Reflect
    jumpifmove MOVE_LIGHT_SCREEN LIGHTCLAY_BONUS_REFLECT	@ Prioriza Light Screen
    jumpifmove MOVE_AURORA_VEIL LIGHTCLAY_BONUS_AURORA		@ Prioriza Aurora Veil
    goto_cmd LIGHTCLAY_PENALIZE								@ Penaliza se nenhum movimento relevante estiver presente

LIGHTCLAY_BONUS_REFLECT:
    scoreupdate +2                                      @ Bônus médio para Reflect
    goto_cmd LIGHTCLAY_END

LIGHTCLAY_BONUS_AURORA:
    jumpifweather weather_hail | chilly_reception_hail LIGHTCLAY_BONUS_REFLECT   @ Verifica se Hail/Snow está ativo
    scoreupdate -2                                      @ Penaliza se Aurora Veil não puder ser usado
    goto_cmd LIGHTCLAY_END

LIGHTCLAY_PENALIZE:
    scoreupdate -3                                      @ Penaliza severamente se o item não for relevante

LIGHTCLAY_END:
    return_cmd                                          @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_DAMPROCK:
	getmoveid
	jumpifmove MOVE_RAIN_DANCE POINTS_PLUS1
	return_cmd
HELDITEM_USER_SMOOTHROCK:
	getmoveid
	jumpifmove MOVE_SANDSTORM POINTS_PLUS1
	return_cmd
HELDITEM_USER_ICYROCK:
	getmoveid
	jumpifmove MOVE_HAIL POINTS_PLUS1
	return_cmd
HELDITEM_USER_HEATROCK:
	getmoveid
	jumpifmove MOVE_SUNNY_DAY POINTS_PLUS1
	return_cmd
################################################################################################
HELDITEM_USER_ZOOMLENS:
    jumpifstrikesfirst bank_ai bank_target END_LOCATION @ Ignora a lógica se o Pokémon atacar primeiro
    getmoveaccuracy										@ Obtém a precisão do movimento atual
    jumpifbytevarEQ 100 POINTS_MINUS1					@ Penaliza movimentos com 100% de precisão
    jumpifbytevarLT 79 POINTS_PLUS3						@ Grande bônus para precisão menor que 79%
    jumpifbytevarLT 91 POINTS_PLUS2						@ Bônus médio para precisão entre 79% e 90%
    jumpifbytevarLT 100 POINTS_PLUS1					@ Pequeno bônus para precisão entre 91% e 99%
    goto_cmd END_LOCATION_ZOOMLENS						@ Finaliza a lógica

END_LOCATION_ZOOMLENS:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_WIDELENS:
    islockon_on bank_ai bank_target            @ Verifica se Lock-On ou Mind Reader está ativo
    jumpifbytevarEQ 0x1 END_LOCATION          @ Ignora a lógica se precisão já for garantida
    if_ability bank_ai ABILITY_NO_GUARD END_LOCATION @ Ignora lógica se o usuário tiver No Guard
    if_ability bank_target ABILITY_NO_GUARD END_LOCATION @ Ignora lógica se o alvo tiver No Guard
    getmoveaccuracy                            @ Obtém a precisão do movimento atual
    jumpifbytevarEQ 100 POINTS_MINUS1          @ Penaliza movimentos com 100% de precisão
    jumpifbytevarLT 79 POINTS_PLUS2            @ Grande bônus para precisão menor que 79%
    jumpifbytevarLT 91 POINTS_PLUS1            @ Bônus médio para precisão entre 79% e 90%
    jumpifbytevarLT 100 POINTS_PLUS1           @ Pequeno bônus para precisão entre 91% e 99%
    return_cmd                                 @ Finaliza a lógica

END_LOCATION:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_LEFTOVERS:
	getmoveid                                   @ Obtém o ID do movimento atual
	jumpifmove MOVE_ENDURE END_LOCATION         @ Ignora se o movimento for Endure
	jumpifmove MOVE_EXPLOSION NEGATIVE_LEFTOVERS @ Penaliza movimentos de sacrifício
	jumpifmove MOVE_SELFDESTRUCT NEGATIVE_LEFTOVERS @ Penaliza movimentos de sacrifício
	jumpifhealthGE bank_ai 89 END_LOCATION      @ Ignora se o HP for maior ou igual a 89%
	getprotectuses bank_ai                      @ Verifica o número de usos de movimentos de proteção
	jumpifbytevarNE 0x0 END_LOCATION            @ Ignora se já houveram usos de proteção neste turno
	jumpifmovescriptNE 34 END_LOCATION          @ Ignora se o movimento atual não for de proteção
	jumpifhealthLT bank_ai 40 POINTS_PLUS2      @ Prioriza mais se o HP for menor que 40%
	jumpifhealthLT bank_ai 25 POINTS_PLUS4      @ Prioriza mais se o HP for menor que 25%
	goto_cmd NEGATIVE_LEFTOVERS                 @ Caso contrário, aplica um pequeno bônus

NEGATIVE_LEFTOVERS: 
	scoreupdate +1                              @ Pequeno bônus para movimentos normais
################################################################################################
HELDITEM_USER_ENCOURAGECRITS:
	hashighcriticalratio
	jumpifbytevarEQ 0x1 POINTS_PLUS1
	return_cmd
################################################################################################
HELDITEM_USER_CHOICEITEM_ENCOURAGE_VOLTSWITCH:
	countalivepokes bank_ai
	jumpifbytevarEQ 0x0 END_LOCATION
	jumpifmovescriptEQ 35 POINTS_PLUS2
	return_cmd
HELDITEM_USER_CHOICESPECS:
    getmovesplit
    jumpifbytevarNE SPLIT_SPECIAL POINTS_MINUS12  @ Penalizar movimentos não especiais
    call_cmd HELDITEM_USER_CHOICEITEM_ENCOURAGE_VOLTSWITCH
    jumpifmostpowerful POINTS_PLUS2
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS30
    getmoveaccuracy
    jumpifbytevarGE 84 POINTS_MINUS5
    return_cmd
################################################################################################
HELDITEM_USER_CHOICEBAND:
    getmovesplit
    jumpifbytevarNE SPLIT_PHYSICAL POINTS_MINUS12  @ Penalidade se não for físico
    call_cmd HELDITEM_USER_CHOICEITEM_ENCOURAGE_VOLTSWITCH
    jumpifmostpowerful POINTS_PLUS2
    getmoveaccuracy
    jumpifbytevarGE 84 POINTS_MINUS5
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS30
    return_cmd
################################################################################################
HELDITEM_USER_CHOICESCARF:
    getmovesplit
    jumpifbytevarEQ SPLIT_STATUS POINTS_MINUS12  @ Penalizar movimentos de status
    call_cmd HELDITEM_USER_CHOICEITEM_ENCOURAGE_VOLTSWITCH
    jumpifmostpowerful POINTS_PLUS2
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3
    jumpifeffectiveness_EQ NO_EFFECT POINTS_MINUS30
	jumpifhealthLT bank_target 30 POINTS_PLUS3
    getmoveaccuracy
    jumpifbytevarGE 84 POINTS_MINUS5
    return_cmd
################################################################################################
HELDITEM_USER_SILVER:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_BUG TYPEBOOSTER_END	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END						@ Finaliza a lógica

TYPEBOOSTER_END:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_CHARCOAL:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END2			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_FIRE TYPEBOOSTER_END2	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END2						@ Finaliza a lógica

TYPEBOOSTER_END2:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_MW:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END3			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_WATER TYPEBOOSTER_END3	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END3						@ Finaliza a lógica

TYPEBOOSTER_END3:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_BG:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END4			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_DARK TYPEBOOSTER_END4	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END4						@ Finaliza a lógica

TYPEBOOSTER_END4:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_MAGNET:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END5			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_ELECTRIC TYPEBOOSTER_END5	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END5						@ Finaliza a lógica

TYPEBOOSTER_END5:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################

HELDITEM_USER_MS:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END6			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_GRASS TYPEBOOSTER_END6	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END6						@ Finaliza a lógica

TYPEBOOSTER_END6:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SS:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END7			@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_GROUND TYPEBOOSTER_END7	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END7						@ Finaliza a lógica

TYPEBOOSTER_END7:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SB:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END8		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_FLYING TYPEBOOSTER_END8	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END8						@ Finaliza a lógica

TYPEBOOSTER_END8:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_TTS:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END59		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_PSYCHIC TYPEBOOSTER_END59	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END59						@ Finaliza a lógica

TYPEBOOSTER_END59:
    return_cmd
################################################################################################    
HELDITEM_USER_HS:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END10		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_ROCK TYPEBOOSTER_END10	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END10						@ Finaliza a lógica

TYPEBOOSTER_END10:
    return_cmd
################################################################################################    
HELDITEM_USER_MC:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END11		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_STEEL TYPEBOOSTER_END11	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END11						@ Finaliza a lógica

TYPEBOOSTER_END11:
    return_cmD
################################################################################################    
HELDITEM_USER_PB:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END12		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_POISON TYPEBOOSTER_END12	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END12						@ Finaliza a lógica

TYPEBOOSTER_END12:
    return_cmd
################################################################################################
################################################################################################    
HELDITEM_USER_FAIRYPLATE:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END18		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_FAIRY TYPEBOOSTER_END18	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END18						@ Finaliza a lógica

TYPEBOOSTER_END18:
    return_cmd
################################################################################################
HELDITEM_USER_DF:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END13		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_POISON TYPEBOOSTER_END13	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END13						@ Finaliza a lógica

TYPEBOOSTER_END13:
    return_cmd
################################################################################################  
HELDITEM_USER_ADAMANTORB:
	get_curr_move_type
	jumpifbytevarEQ TYPE_STEEL POINTS_PLUS3 @ Verifica se o movimento é do tipo Aço
	jumpifbytevarEQ TYPE_DRAGON POINTS_PLUS3 @ Verifica se o movimento é do tipo Dragão
    goto_cmd ADAMANT_END                       @ Se não for nenhum dos tipos, ignora a lógica

ADAMANT_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_GRISEOUSORB:
	get_curr_move_type
	jumpifbytevarEQ TYPE_GHOST POINTS_PLUS3 @ Verifica se o movimento é do tipo Fantasma
	jumpifbytevarEQ TYPE_DRAGON POINTS_PLUS3 @ Verifica se o movimento é do tipo Dragão
    goto_cmd GRISEOUS_END                      @ Se não for nenhum dos tipos, ignora a lógica

GRISEOUS_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_LUSTROUSORB:
	get_curr_move_type
	jumpifbytevarEQ TYPE_WATER POINTS_PLUS3 @ Verifica se o movimento é do tipo Fantasma
	jumpifbytevarEQ TYPE_DRAGON POINTS_PLUS3 @ Verifica se o movimento é do tipo Dragão
    goto_cmd LUSTROUS_END                      @ Se não for nenhum dos tipos, ignora a lógica

LUSTROUS_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_EVIOLITE:
    jumpifhealthLT bank_ai 30 EVIOLITE_LOW_HP	@ Se o HP for menor que 30%, prioriza movimentos defensivos
    getmovesplit								@ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS EVIOLITE_DEF	@ Prioriza movimentos de status/defensivos
    scoreupdate -1								@ Penaliza movimentos ofensivos
    goto_cmd EVIOLITE_END						@ Finaliza a lógica

EVIOLITE_LOW_HP:
    getmoveid									@ Obtém o ID do movimento atual
    jumpifmovescriptEQ 35 EVIOLITE_DEF			@ Se for Protect, prioriza
    jumpifmovescriptEQ 96 EVIOLITE_DEF		@ Se for Substitute, prioriza
    scoreupdate +2								@ Bônus para qualquer movimento defensivo
    goto_cmd EVIOLITE_END						@ Finaliza a lógica

EVIOLITE_DEF:
    scoreupdate +4                             @ Grande bônus para movimentos defensivos
    goto_cmd EVIOLITE_END
EVIOLITE_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_ASSAULTVEST:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS POINTS_MINUS3 @ Penaliza movimentos de status
    scoreupdate +3                             @ Aumenta a pontuação para movimentos ofensivos
    goto_cmd ASSAULTVEST_END                   @ Finaliza a lógica

ASSAULTVEST_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_MUSCLEBAND:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_PHYSICAL POINTS_PLUS3 @ Prioriza movimentos físicos
    scoreupdate -2                             @ Penaliza movimentos especiais ou de status
    goto_cmd MUSCLEBAND_END                    @ Finaliza a lógica

MUSCLEBAND_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_WISEGLASSES:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_SPECIAL POINTS_PLUS3 @ Prioriza movimentos especiais
    scoreupdate -2                             @ Penaliza movimentos físicos ou de status
    goto_cmd WISEGLASSES_END                   @ Finaliza a lógica

WISEGLASSES_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_DRIVE:
    getmoveid                                  @ Obtém o ID do movimento atual
    jumpifmove MOVE_TECHNO_BLAST DRIVE_CHECK    @ Verifica se o movimento é Techno Blast
    goto_cmd DRIVE_END                         @ Se não for Techno Blast, ignora a lógica

DRIVE_CHECK:
    getitemeffect bank_ai 1                      @ Obtém o efeito do item segurado
    jumpifbytevarEQ ITEM_EFFECT_BURNDRIVE  DRIVE_FIRE		@ Verifica se é Burn Drive
    jumpifbytevarEQ ITEM_EFFECT_CHILLDRIVE DRIVE_ICE		@ Verifica se é Chill Drive
    jumpifbytevarEQ ITEM_EFFECT_DOUSEDRIVE DRIVE_WATER		@ Verifica se é Douse Drive
    jumpifbytevarEQ ITEM_EFFECT_SHOCKDRIVE DRIVE_ELECTRIC	@ Verifica se é Shock Drive
    goto_cmd DRIVE_END                         @ Ignora se não for nenhum dos Drives

DRIVE_FIRE:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS4	@ Se for super efetivo, adiciona bônus
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS2
    scoreupdate -1										@ Bônus menor se não for super efetivo
    goto_cmd DRIVE_END

DRIVE_ICE:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS4	@ Se for super efetivo, adiciona bônus
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS2
    scoreupdate -1                             @ Bônus menor se não for super efetivo
    goto_cmd DRIVE_END

DRIVE_WATER:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS4	@ Se for super efetivo, adiciona bônus
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS2
    scoreupdate -1                             @ Bônus menor se não for super efetivo
    goto_cmd DRIVE_END

DRIVE_ELECTRIC:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS4	@ Se for super efetivo, adiciona bônus
    jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS2
    scoreupdate -1                             @ Bônus menor se não for super efetivo
    goto_cmd DRIVE_END

DRIVE_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_EXPERTBELT:
    jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS3 @ Verifica se o movimento é super efetivo
    goto_cmd EXPERTBELT_END                    @ Se não for super efetivo, finaliza a lógica

EXPERTBELT_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SAFETYGOOGLES:
    jumpifweather weather_permament_sandstorm | weather_sandstorm POINTS_PLUS2	@ Verifica se há tempestade de areia
    jumpifweather weather_permament_hail | weather_hail POINTS_PLUS2			@ Verifica se há granizo
    goto_cmd CHECK_POWDER                         @ Continua para verificar movimentos de pó

CHECK_POWDER:
    jumpifhasmove bank_target MOVE_SPORE POINTS_PLUS3			@ Prioriza se o movimento for Spore
    jumpifhasmove bank_target MOVE_SLEEP_POWDER POINTS_PLUS3	@ Prioriza se o movimento for Sleep Powder
    jumpifhasmove bank_target MOVE_RAGE_POWDER POINTS_PLUS3		@ Prioriza se o movimento for Rage Powder
    goto_cmd SAFETYGOOGLES_END									@ Finaliza a lógica se nada relevante for encontrado

SAFETYGOOGLES_END:
    return_cmd                                    @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_LAGGINGTAIL:
    getmoveid                                  @ Obtém o ID do movimento atual
    jumpifmove MOVE_COUNTER LAGGINGTAIL_BONUS  @ Prioriza movimentos como Counter
    jumpifmove MOVE_MIRROR_COAT LAGGINGTAIL_BONUS @ Prioriza movimentos como Mirror Coat
    jumpifmove MOVE_PAYBACK LAGGINGTAIL_BONUS  @ Prioriza movimentos como Payback
    jumpifmove MOVE_REVENGE LAGGINGTAIL_BONUS  @ Prioriza movimentos como Revenge

    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM LAGGINGTAIL_IGNORE @ Se Trick Room estiver ativo, ignora
    scoreupdate -2                             @ Penaliza o item se não for útil
    goto_cmd LAGGINGTAIL_END

LAGGINGTAIL_BONUS:
    scoreupdate +3                             @ Grande bônus para movimentos que se beneficiam
    goto_cmd LAGGINGTAIL_END

LAGGINGTAIL_IGNORE:
    scoreupdate +1                             @ Pequeno bônus se Trick Room estiver ativo
LAGGINGTAIL_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_FLOATSTONE:
    jumpifhasmove bank_target MOVE_GRASS_KNOT FLOATSTONE_BONUS @ Prioriza se o movimento for Grass Knot
    jumpifhasmove bank_target MOVE_LOW_KICK FLOATSTONE_BONUS   @ Prioriza se o movimento for Low Kick
    jumpifhasmove bank_target MOVE_HEAVY_SLAM FLOATSTONE_BONUS @ Prioriza se o movimento for Heavy Slam
    jumpifhasmove bank_target MOVE_HEAT_CRASH FLOATSTONE_BONUS @ Prioriza se o movimento for Heat Crash
    goto_cmd FLOATSTONE_END                    @ Ignora se nenhum movimento relevante for encontrado

FLOATSTONE_BONUS:
    scoreupdate +3                             @ Grande bônus se o Float Stone for útil
    goto_cmd FLOATSTONE_END

FLOATSTONE_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_METRONOME:
	jumpifeffectiveness_EQ SUPER_EFFECTIVE POINTS_PLUS2
	jumpifeffectiveness_EQ NORMAL_EFFECTIVENESS POINTS_PLUS1
	jumpifmove MOVE_ICE_BALL POINTS_PLUS2
	jumpifmove MOVE_OUTRAGE POINTS_PLUS2
	jumpifmove MOVE_PETAL_DANCE POINTS_PLUS2
	jumpifmove MOVE_RAGING_FURY POINTS_PLUS2
	jumpifmove MOVE_ROLLOUT POINTS_PLUS2
	jumpifmove MOVE_THRASH POINTS_PLUS2
	jumpifmove MOVE_UPROAR POINTS_PLUS2
	getlastusedmove bank_ai                       @ Obtém o último movimento usado pelo Pokémon
	jumpifwordvarEQ MOVE_ICE_BALL POINTS_PLUS2    @ Verifica se é Ice Ball
	jumpifwordvarEQ MOVE_OUTRAGE POINTS_PLUS2     @ Verifica se é Outrage
	jumpifwordvarEQ MOVE_PETAL_DANCE POINTS_PLUS2 @ Verifica se é Petal Dance
	jumpifwordvarEQ MOVE_RAGING_FURY POINTS_PLUS2 @ Verifica se é Raging Fury
	jumpifwordvarEQ MOVE_ROLLOUT POINTS_PLUS2     @ Verifica se é Rollout
	jumpifwordvarEQ MOVE_THRASH POINTS_PLUS2      @ Verifica se é Thrash
	jumpifwordvarEQ MOVE_UPROAR POINTS_PLUS2      @ Verifica se é Uproar
	return_cmd                                    @ Finaliza a lógica
################################################################################################
HELDITEM_USER_LIFEORB:
    jumpifhealthLT bank_ai 20 LIFEORB_LOW_HP          @ Se o HP for menor que 20%, desincentiva movimentos ofensivos
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS POINTS_MINUS2 @ Penaliza movimentos de status (não ofensivos)
    getmovepower                               @ Obtém o poder do movimento atual
    jumpifwordvarLE 50 LIFEORB_LOW_DAMAGE      @ Se o poder for menor ou igual a 50, prioriza menos
    scoreupdate +4                             @ Aumenta a pontuação para movimentos de alto dano
    goto_cmd LIFEORB_END                       @ Finaliza a lógica

LIFEORB_LOW_DAMAGE:
    scoreupdate +2                             @ Pequeno bônus para movimentos de baixo dano
    goto_cmd LIFEORB_END
LIFEORB_LOW_HP:
    scoreupdate -3                             @ Penaliza movimentos ofensivos com HP baixo
    goto_cmd LIFEORB_END
LIFEORB_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_SILKSCARF:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END17		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_NORMAL TYPEBOOSTER_END17	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END17						@ Finaliza a lógica

TYPEBOOSTER_END17:
    return_cmd
################################################################################################ 
HELDITEM_USER_SHELLBELL:
    jumpifhealthGE bank_ai 90 SHELLBELL_END			@ Se o HP estiver cheio (100%), ignora a lógica
    getmovesplit									@ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS POINTS_MINUS2	@ Penaliza movimentos de status (não ofensivos)
    getmovepower									@ Obtém o poder do movimento atual
    jumpifwordvarLE 50 SHELLBELL_LOW_DAMAGE			@ Se o poder for menor ou igual a 50, prioriza menos
    scoreupdate +3									@ Aumenta a pontuação para movimentos de alto dano
    goto_cmd SHELLBELL_END							@ Finaliza a lógica

SHELLBELL_LOW_DAMAGE:
    scoreupdate +1                             @ Pequeno bônus para movimentos de baixo dano
    goto_cmd SHELLBELL_END
SHELLBELL_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_THICKCLUB:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_PHYSICAL THICKCLUB_PHYSICAL @ Prioriza movimentos físicos
    scoreupdate -2                             @ Penaliza movimentos não físicos
    goto_cmd THICKCLUB_END                     @ Finaliza a lógica

THICKCLUB_PHYSICAL:
    scoreupdate +4                             @ Aumenta a pontuação para movimentos físicos
    goto_cmd THICKCLUB_END                     @ Finaliza a lógica
THICKCLUB_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################ 
HELDITEM_USER_ST:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END14		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_GHOST TYPEBOOSTER_END14	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END14						@ Finaliza a lógica

TYPEBOOSTER_END14:
    return_cmd
################################################################################################
################################################################################################      
HELDITEM_USER_BLACKBELT:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END16		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_FIGHTING TYPEBOOSTER_END16	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END16						@ Finaliza a lógica

TYPEBOOSTER_END16:
    return_cmd
################################################################################################
HELDITEM_USER_NMI:
    checkstab bank_ai							@ Verifica STAB e efetividade do movimento
    jumpifbytevarEQ 0 TYPEBOOSTER_END15		@ Se não for STAB ou não for efetivo, ignora a lógica
    get_curr_move_type							@ Obtém o tipo do movimento atual e armazena em AI_STATE->var
    jumpifbytevarNE TYPE_ICE TYPEBOOSTER_END15	@ Se o tipo do movimento não for Bug, ignora a lógica
    scoreupdate +2								@ Aumenta a pontuação para movimentos do tipo correspondente
    goto_cmd TYPEBOOSTER_END15						@ Finaliza a lógica

TYPEBOOSTER_END15:
    return_cmd
################################################################################################
HELDITEM_USER_SOULDEW:
    getbankspecies bank_ai @ Obtém a espécie do bank_target
    jumpifwordvarEQ POKE_LATIOS SOULDEW_CHECK_SPECIAL
    jumpifwordvarEQ POKE_LATIAS SOULDEW_CHECK_SPECIAL
    goto_cmd SOULDEW_END							@ Se não for Latios ou Latias, ignora a lógica

SOULDEW_CHECK_SPECIAL:
    getmovesplit
    jumpifbytevarNE SPLIT_SPECIAL POINTS_MINUS3 @ Verifica se o movimento é especial
    scoreupdate +2								@ Aumenta a pontuação para movimentos especiais

SOULDEW_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_DEEPSEATOOTH:
    getbankspecies bank_ai						@ Obtém a espécie do Pokémon no banco ai
    jumpifwordvarNE POKE_CLAMPERL TOOTH_END		@ Se não for Huntail, ignora a lógica
    getmovesplit								@ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarNE SPLIT_SPECIAL TOOTH_END		@ Se o movimento não for especial, ignora a lógica
    scoreupdate +4								@ Aumenta a pontuação para movimentos especiais
TOOTH_END:
    return_cmd									@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_DEEPSEASCALE:
    getbankspecies bank_ai                     @ Obtém a espécie do Pokémon no banco ai
    jumpifwordvarNE POKE_CLAMPERL SCALE_END    @ Se não for Clamperl, ignora a lógica
    scoreupdate +3                             @ Aumenta a pontuação para situações defensivas
SCALE_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_FOCUSBAND:
    jumpifhealthLT bank_ai 10 FOCUSBAND_LOW_HP        @ Verifica se o HP é 10% ou menos
    goto_cmd FOCUSBAND_END                     @ Se o HP for maior que 10%, ignora a lógica

FOCUSBAND_LOW_HP:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS FOCUSBAND_PRIORITY @ Prioriza movimentos de status
    scoreupdate +2                             @ Aumenta a pontuação para movimentos normais
    goto_cmd FOCUSBAND_END                     @ Finaliza a lógica
FOCUSBAND_PRIORITY:
    scoreupdate +4                             @ Aumenta a pontuação para movimentos de status
    return_cmd                                 @ Retorna ao fluxo normal
FOCUSBAND_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_LIGHTBALL:
    getmovesplit                               @ Obtém o tipo do movimento (físico/especial/status)
    jumpifbytevarEQ SPLIT_STATUS LIGHTBALL_MINUS @ Penaliza movimentos de status (não ofensivos)
    scoreupdate +4                             @ Aumenta a pontuação para movimentos ofensivos
    goto_cmd LIGHTBALL_END                     @ Finaliza a lógica

LIGHTBALL_MINUS:
    scoreupdate -2                             @ Penaliza movimentos de status
LIGHTBALL_END:
    return_cmd                                 @ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_WHITEHERB:
    getmoveid
    jumpifhwordvarinlist MOVES_LOWERING_USERS_STAT POINTS_PLUS1
    jumpifstatbuffLT bank_ai STAT_ATK default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_DEF default_stat_stage POINTS_PLUS2
    jumpifstatbuffLT bank_ai STAT_SPD default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_SP_ATK default_stat_stage POINTS_PLUS3
    jumpifstatbuffLT bank_ai STAT_SP_DEF default_stat_stage POINTS_PLUS2
    jumpifstatbuffLT bank_ai STAT_ACC default_stat_stage POINTS_PLUS1
    jumpifstatbuffLT bank_ai STAT_EVASION default_stat_stage POINTS_PLUS1
    return_cmd
################################################################################################
HELDITEM_USER_MACHOBRACE:
    getmoveid
    jumpifwordvarEQ MOVE_PAYBACK PAYBACK_LOGIC
    jumpifwordvarEQ MOVE_REVENGE PAYBACK_LOGIC
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM TRICK_ROOM_LOGIC
    return_cmd

PAYBACK_LOGIC:
    scoreupdate +3  @ Priorizar Payback, já que Macho Brace reduz a Velocidade
    return_cmd
TRICK_ROOM_LOGIC:
    scoreupdate +2  @ A redução de Velocidade é vantajosa no Trick Room
    return_cmd
################################################################################################
HELDITEM_USER_MENTALHERB:

################################################################################################
HELDITEM_USER_SITRUS:
	getmoveid
	jumpifmove MOVE_BELLY_DRUM POINTS_PLUS1
	jumpifmove MOVE_CLANGOROUS_SOUL POINTS_PLUS1
    jumpifmove MOVE_SUBSTITUTE POINTS_PLUS1					@ Prioriza Substitute (sinergia moderada)
	jumpifmovescriptEQ 34 POINTS_PLUS1
    jumpifhealthLT bank_ai 50 SITRUS_BONUS_HP				@ Bônus se o HP estiver em 50% ou menos
    jumpifhealthLT bank_ai 75 SITRUS_BONUS_GLUTTONY			@ Bônus menor se o HP estiver em 75% (Gluttony)
    scoreupdate -1											@ Penaliza se nenhuma condição for atendida
    goto_cmd SITRUS_END

SITRUS_BONUS_HP:
    scoreupdate +3											@ Grande bônus se o HP estiver em 50% ou menos
    goto_cmd SITRUS_END

SITRUS_BONUS_GLUTTONY:
    checkability bank_ai ABILITY_GLUTTONY					@ Verifica se o Pokémon tem a habilidade Gluttony
    jumpifbytevarEQ 1 POINTS_PLUS1							@ Pequeno bônus adicional para Gluttony
    goto_cmd SITRUS_END

SITRUS_END:
    return_cmd												@ Retorna ao fluxo normal
################################################################################################
HELDITEM_USER_CHERI:
    jumpifstatus bank_ai STATUS_PARALYSIS CHERI_AI_PARALYZED
    goto_cmd CHERI_AI_NOT_PARALYZED

CHERI_AI_PARALYZED:
    scoreupdate +3  @ Prioritize impactful moves as the status will be removed
    return_cmd
CHERI_AI_NOT_PARALYZED:
    return_cmd  @ Neutral logic if not paralyzed
################################################################################################
HELDITEM_USER_ORAN:
    jumpifhealthGE bank_ai 50 ORAN_AI_HIGH_HP  @ If HP >= 50%, encourage prolonging the battle
    jumpifhealthLT bank_ai 50 ORAN_AI_LOW_HP   @ If HP < 50%, prioritize defensive moves
	return_cmd
ORAN_AI_HIGH_HP:
    scoreupdate +2  @ Encourage moves that prolong the battle
    return_cmd
ORAN_AI_LOW_HP:
    scoreupdate +3  @ Prioritize defensive or healing moves
    return_cmd
################################################################################################
HELDITEM_USER_BERRYFOCUSENERGY:
	jumpifstatus2 bank_ai STATUS2_PUMPEDUP END_LOCATION
################################################################################################
HELDITEM_USER_BERRYSTATRAISE:
    getmoveid
    cantargetfaintuser 1
    jumpifbytevarEQ 0x0 END_LOCATION
    getitemeffect bank_ai 1
    jumpifbytevarEQ ITEM_EFFECT_LIECHIBERRY LIECHI_LOGIC
    jumpifbytevarEQ ITEM_EFFECT_GANLONBERRY GANLON_LOGIC
    jumpifbytevarEQ ITEM_EFFECT_SALACBERRY SALAC_LOGIC
    jumpifbytevarEQ ITEM_EFFECT_PETAYABERRY PETAYA_LOGIC
    jumpifbytevarEQ ITEM_EFFECT_APICOTBERRY APICOT_LOGIC
    jumpifbytevarEQ ITEM_EFFECT_STARFBERRY STARF_LOGIC
    goto_cmd END_LOCATION2

LIECHI_LOGIC:
    scoreupdate +4  @ Prioritize physical moves due to Attack boost
    return_cmd
GANLON_LOGIC:
    scoreupdate +3  @ Prioritize defensive strategies
    return_cmd
SALAC_LOGIC:
    scoreupdate +4  @ Prioritize high-priority moves due to Speed boost
    return_cmd
PETAYA_LOGIC:
    scoreupdate +4  @ Prioritize special moves due to Special Attack boost
    return_cmd
APICOT_LOGIC:
    scoreupdate +3  @ Prioritize defensive strategies against special moves
    return_cmd
STARF_LOGIC:
    scoreupdate +2  @ Adjust based on random stat boost (neutral logic)
    return_cmd
END_LOCATION2:
    return_cmd
################################################################################################
TAI_SCRIPT_3: @ENCOURAGE status moves if it's a first turn; bitfield 0x8, AI_SetupFirstTurn
    jumpiftargetisally END_LOCATION       @ Verifica se o alvo é aliado
    getbattleturncounter
    jumpifbytevarNE 0x00 END_LOCATION     @ Sai se não for o primeiro turno
	hasprioritymove bank_ai
	jumpifbytevarEQ 0x0 END_LOCATION
    getmovesplit
    jumpifbytevarNE SPLIT_STATUS END_LOCATION @ Sai se o movimento não for de status
    jumpifmovescriptEQ 2 POINTS_PLUS2         @ Movimentos que alteram um único status do usuário
    jumpifmovescriptEQ 3 POINTS_PLUS1         @ Movimentos que alteram um único status do alvo
    jumpifmovescriptEQ 4 POINTS_PLUS3         @ Alteração de status do usuário com chance
    jumpifmovescriptEQ 5 POINTS_PLUS2         @ Alteração de status do alvo com chance
    jumpifmovescriptEQ 6 POINTS_PLUS4         @ Alteração de múltiplos status
    jumpifmovescriptEQ 7 POINTS_PLUS4         @ Alteração de múltiplos status
    jumpifmovescriptEQ 8 POINTS_PLUS3         @ Alteração de múltiplos status do usuário com chance
    jumpifmovescriptEQ 9 POINTS_PLUS1         @ Confusão
    jumpifmovescriptEQ 13 POINTS_PLUS1        @ Envenenamento
    jumpifmovescriptEQ 14 POINTS_PLUS1        @ Envenenamento (outra variante)
    jumpifmovescriptEQ 15 POINTS_PLUS2        @ Paralisia
    jumpifmovescriptEQ 16 POINTS_PLUS2        @ Queimadura
    jumpifmovescriptEQ 43 POINTS_PLUS3        @ Rooms (Trick Room, Magic Room, etc.)
    jumpifmovescriptEQ 53 POINTS_PLUS2        @ Hazards de entrada (Stealth Rock, Spikes, etc.)
    jumpifmovescriptEQ 58 POINTS_PLUS1        @ Camouflage (situação específica)
    jumpifmovescriptEQ 60 POINTS_PLUS2        @ Focus Energy
    jumpifmovescriptEQ 62 POINTS_PLUS1        @ Torment
    jumpifmovescriptEQ 71 POINTS_PLUS3        @ Geomancy (movimento poderoso de preparação)
    jumpifmovescriptEQ 78 POINTS_PLUS2        @ Leech Seed
    jumpifmovescriptEQ 84 POINTS_PLUS3        @ Reflect (barreira defensiva)
    jumpifmovescriptEQ 85 POINTS_PLUS3        @ Light Screen (barreira especial)
    jumpifmovescriptEQ 94 POINTS_PLUS2        @ Conversion e Conversion2
    jumpifmovescriptEQ 96 POINTS_PLUS3        @ Substitute (substituto)
    jumpifmovescriptEQ 104 POINTS_PLUS2       @ Curse
    jumpifmovescriptEQ 126 POINTS_PLUS2       @ Ingrain (curar HP e evitar troca)
    jumpifmovescriptEQ 131 POINTS_PLUS2       @ Yawn (preparação para sono)
    jumpifmovescriptEQ 133 POINTS_PLUS3       @ Imprison (bloquear movimentos do alvo)
    jumpifmovescriptEQ 140 POINTS_PLUS3       @ Tailwind (aumenta velocidade em 4 turnos)
    jumpifmovescriptEQ 141 POINTS_PLUS2       @ Acupressure
    jumpifmovescriptEQ 151 POINTS_PLUS3       @ Terrains (Psychic Terrain, Grassy Terrain, etc.)
    jumpifmovescriptEQ 156 POINTS_PLUS4       @ Shell Smash (aumenta atributos drasticamente)
    jumpifmovescriptEQ 158 POINTS_PLUS3       @ Shift Gear (aumenta velocidade e ataque)
    jumpifmovescriptEQ 161 POINTS_PLUS2       @ Sandstorm (invoca tempestade de areia)
    jumpifmovescriptEQ 162 POINTS_PLUS2       @ Rain Dance (invoca chuva)
    jumpifmovescriptEQ 163 POINTS_PLUS2       @ Sunny Day (invoca sol forte)
    jumpifmovescriptEQ 164 POINTS_PLUS2       @ Hail (invoca granizo)
    jumpifmovescriptEQ 186 POINTS_PLUS2       @ Confusão com alteração de status
    jumpifmovescriptEQ 190 POINTS_PLUS1       @ Chilly Reception (retirada estratégica)
	return_cmd
################################################################################################
TAI_SCRIPT_7: @Act Smart During Double Battles; bitfield 16 AI_DoubleBattle
    jumpiftargetisally AI_TryOnAlly
    call_cmd AI_CheckTerrains  @ Avalia como o terreno afeta as decisões
    call_cmd AI_CheckWeather  @ Avalia como o clima afeta as decisões
    call_cmd AI_PrioritizeSpeed  @ Avalia a prioridade de velocidade no turno
	discourage_moves_double
    jumpifhasmove bank_aipartner MOVE_HELPING_HAND AI_DoubleBattlePartnerHasHelpingHand
    jumpifmove MOVE_SKILL_SWAP AI_DoubleBattleSkillSwap
    jumpifmove MOVE_EARTHQUAKE | MOVE_MAGNITUDE AI_DoubleBattleAllHittingGroundMove
    jumpifmove MOVE_DISCHARGE AI_DoubleBattleElectricMove
    jumpifmove MOVE_SURF AI_CheckSurfPartner
    jumpifmove MOVE_MUDDY_WATER AI_CheckMuddyWaterPartner
    jumpifmove MOVE_HEAT_WAVE AI_DoubleBattleHeatWavePartner
    jumpifmove MOVE_ERUPTION AI_DoubleBattleEruptionPartner
    jumpifmove MOVE_HYPER_VOICE AI_CheckHyperVoicePartner
    jumpifmove MOVE_BOOMBURST AI_CheckBoomBurstPartner
    jumpifmove MOVE_ECHOED_VOICE AI_CheckEchoedVoicePartner
    jumpifmove MOVE_DAZZLING_GLEAM AI_CheckDazzlingGleamPartner
    jumpifmove MOVE_FAIRY_WIND AI_CheckFairyWindPartner
    jumpifmove MOVE_MOONBLAST AI_CheckMoonblastTarget
    jumpifmove MOVE_ROCK_SLIDE AI_CheckRockSlidePartner
    jumpifmove MOVE_ANCIENT_POWER AI_CheckAncientPowerUser
    jumpifmove MOVE_STONE_EDGE AI_CheckStoneEdgeTarget
    jumpifmove MOVE_EXPLOSION AI_CheckExplosionPartner  @ Verifica lógica específica para Explosion
    jumpifmove MOVE_SELFDESTRUCT AI_CheckSelfDestructPartner  @ Verifica lógica específica para Self-Destruct
    get_curr_move_type
    jumpifbytevarEQ TYPE_ELECTRIC AI_DoubleBattleElectricMove
    jumpifbytevarEQ TYPE_FIRE AI_DoubleBattleFireMove
    getability bank_ai
    jumpifbytevarNE ABILITY_GUTS AI_DoubleBattleCheckUserStatus
    call_cmd AI_CheckPartnerMoveEffect
    goto_cmd AI_DoubleBattleCheckUserStatus
	return_cmd

AI_CheckPartnerMoveEffect:
    getpartnerchosenmove  @ Obtém o movimento do parceiro
    jumpifwordvarEQ MOVE_HELPING_HAND AI_PartnerEffect_HelpingHand
    jumpifwordvarEQ MOVE_PERISH_SONG AI_PartnerEffect_PerishSong
    jumpifwordvarEQ MOVE_SUNNY_DAY AI_PartnerEffect_WeatherMove
    jumpifwordvarEQ MOVE_HAIL AI_PartnerEffect_WeatherMove
    jumpifwordvarEQ MOVE_RAIN_DANCE AI_PartnerEffect_WeatherMove
    jumpifwordvarEQ MOVE_SANDSTORM AI_PartnerEffect_WeatherMove
    jumpifwordvarEQ MOVE_CHILLY_RECEPTION AI_PartnerEffect_WeatherMove
    call_cmd AI_CheckPartnerAbility
    call_cmd AI_ConsiderMoveEffectPartnerState
    return_cmd

AI_CheckPartnerAbility:
    getability bank_aipartner  @ Obtém a habilidade do parceiro
    jumpifbytevarEQ ABILITY_ANGER_POINT AI_PartnerAbility_AngerPoint
    jumpifbytevarEQ ABILITY_VOLT_ABSORB AI_PartnerAbility_VoltAbsorb
    jumpifbytevarEQ ABILITY_MOTOR_DRIVE AI_PartnerAbility_MotorDrive
    jumpifbytevarEQ ABILITY_LIGHTNING_ROD AI_PartnerAbility_LightningRod
    jumpifbytevarEQ ABILITY_WATER_ABSORB AI_PartnerAbility_WaterAbsorb
    jumpifbytevarEQ ABILITY_DRY_SKIN AI_PartnerAbility_DrySkin
    jumpifbytevarEQ ABILITY_STORM_DRAIN AI_PartnerAbility_StormDrain
    jumpifbytevarEQ ABILITY_WATER_COMPACTION AI_PartnerAbility_WaterCompaction
    jumpifbytevarEQ ABILITY_FLASH_FIRE AI_PartnerAbility_FlashFire
    jumpifbytevarEQ ABILITY_SAP_SIPPER AI_PartnerAbility_SapSipper
    jumpifbytevarEQ ABILITY_JUSTIFIED AI_PartnerAbility_Justified
    jumpifbytevarEQ ABILITY_RATTLED AI_PartnerAbility_Rattled
    jumpifbytevarEQ ABILITY_CONTRARY AI_PartnerAbility_Contrary
    return_cmd

AI_PartnerAbility_AngerPoint:
    jumpifmovealwayscrits bank_ai AI_AngerPoint_CheckStat  @ Verifica se o movimento sempre causa crítico
    return_cmd

AI_AngerPoint_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_ATK max_stat_stage AI_AngerPoint_Encourage  @ Verifica se o STAT_ATK do parceiro pode aumentar
    return_cmd

AI_AngerPoint_Encourage:
    scoreupdate +3  @ Incrementa o score se Anger Point for ativo e útil
    return_cmd

AI_PartnerAbility_VoltAbsorb:
    jumpifhasattackingmovewithtype bank_ai TYPE_ELECTRIC Score_Minus10  @ Penaliza movimentos elétricos contra parceiros com Volt Absorb
    return_cmd

AI_PartnerAbility_MotorDrive:
    jumpifhasattackingmovewithtype bank_ai TYPE_ELECTRIC AI_MotorDrive_CheckStat  @ Verifica movimentos elétricos
    return_cmd

AI_MotorDrive_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_SPD max_stat_stage Score_Plus2  @ Incrementa se Motor Drive pode aumentar Speed
    return_cmd

AI_PartnerAbility_LightningRod:
    jumpifhasattackingmovewithtype bank_ai TYPE_ELECTRIC AI_LightningRod_Check  @ Verifica movimentos elétricos
    return_cmd

AI_LightningRod_Check:
    jumpifstatbuffLT bank_aipartner STAT_SP_ATK max_stat_stage Score_Plus2  @ Incrementa se Lightning Rod pode aumentar Sp. Atk
    return_cmd

AI_PartnerAbility_WaterAbsorb:
    jumpifhasattackingmovewithtype bank_ai TYPE_WATER Score_Minus10  @ Penaliza movimentos de água contra parceiros com Water Absorb
    return_cmd

AI_PartnerAbility_DrySkin:
    jumpifhasattackingmovewithtype bank_ai TYPE_WATER Score_Minus10  @ Penaliza movimentos de água contra Dry Skin
    return_cmd

AI_PartnerAbility_StormDrain:
    jumpifhasattackingmovewithtype bank_ai TYPE_WATER AI_StormDrain_CheckStat  @ Verifica movimentos de água
    return_cmd

AI_StormDrain_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_SP_ATK max_stat_stage Score_Plus2  @ Incrementa se Storm Drain pode aumentar Sp. Atk
    return_cmd

AI_PartnerAbility_WaterCompaction:
    jumpifhasattackingmovewithtype bank_ai TYPE_WATER AI_WaterCompaction_CheckHP  @ Verifica movimentos de água
    return_cmd

AI_WaterCompaction_CheckHP:
    jumpifhealthLT bank_aipartner 50 Score_Minus5  @ Penaliza se o HP do parceiro está abaixo de 50%
    scoreupdate +2  @ Incrementa se Water Compaction pode ser útil
    return_cmd

AI_PartnerAbility_FlashFire:
    jumpifhasattackingmovewithtype bank_ai TYPE_FIRE AI_FlashFire_CheckBoost  @ Verifica movimentos de fogo
    return_cmd

AI_FlashFire_CheckBoost:
    jumpifflashfired bank_aipartner  @ Função em TrainerAI.c verifica se Flash Fire está ativo
    return_cmd

AI_PartnerAbility_SapSipper:
    jumpifhasattackingmovewithtype bank_ai TYPE_GRASS AI_SapSipper_CheckStat  @ Verifica movimentos de grama
    return_cmd

AI_SapSipper_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_ATK max_stat_stage Score_Plus2  @ Incrementa se Sap Sipper pode aumentar Attack
    return_cmd

AI_PartnerAbility_Justified:
    jumpifhasattackingmovewithtype bank_ai TYPE_DARK AI_Justified_CheckStat  @ Verifica movimentos do tipo DARK
    return_cmd

AI_Justified_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_ATK max_stat_stage Score_Plus2  @ Incrementa se Justified pode aumentar Attack
    return_cmd

AI_PartnerAbility_Rattled:
    jumpifhasattackingmovewithtype bank_ai TYPE_DARK | TYPE_GHOST | TYPE_BUG AI_Rattled_CheckStat  @ Verifica movimentos desses tipos
    return_cmd

AI_Rattled_CheckStat:
    jumpifstatbuffLT bank_aipartner STAT_SPD max_stat_stage Score_Plus2  @ Incrementa se Rattled pode aumentar Speed
    return_cmd

AI_PartnerAbility_Contrary:
    jumpifmovescriptEQ 3 Score_Plus3  @ Incrementa se Contrary inverte redução de stats
    return_cmd

AI_ConsiderMoveEffectPartnerState:
    getmovescript
    jumpifbytevarEQ 149 AI_Effect_HelpingHand
	jumpifbytevarEQ 122 AI_Effect_PerishSong
	jumpifbytevarEQ 65 AI_Effect_MagnetRise
    return_cmd

AI_Effect_HelpingHand:
    jumpifnostatus bank_aipartner STATUS_ANY AI_HelpingHand_Penalize  @ Penaliza se o parceiro não estiver vivo
    jumpifhasmove bank_aipartner MOVE_POWER_OTHER AI_HelpingHand_Penalize  @ Penaliza se o parceiro não tiver movimentos ofensivos
    return_cmd

AI_HelpingHand_Penalize:
    scoreupdate -5  @ Penaliza o uso de Helping Hand
    return_cmd

AI_Effect_PerishSong:
    jumpifhasmove bank_aipartner MOVE_WRAP | MOVE_BIND | MOVE_INFESTATION AI_PerishSong_WeakEffect
    return_cmd

AI_PerishSong_WeakEffect:
    scoreupdate -3  @ Penaliza se o parceiro já tiver movimentos de aprisionamento
    return_cmd

AI_Effect_MagnetRise:
    jumpifbankaffecting bank_ai BANK_AFFECTING_MAGNETRISE AI_MagnetRise_NoEffect  @ Ignora se já está sob efeito de Magnet Rise
    return_cmd

AI_MagnetRise_CheckPartner:
    jumpifhasmove bank_aipartner MOVE_EARTHQUAKE | MOVE_MAGNITUDE AI_MagnetRise_PartnerGroundMove
    return_cmd

AI_MagnetRise_PartnerGroundMove:
    get_user_type1             @ Obtém o primeiro tipo do Pokémon
    jumpifbytevarEQ TYPE_GROUND AI_MagnetRise_NoEffect   @ Se o Pokémon for do tipo Ground ignora
    get_user_type2             @ Obtém o segundo tipo do Pokémon
    jumpifbytevarEQ TYPE_GROUND AI_MagnetRise_NoEffect   @ Se o Pokémon for do tipo Ground ignora
    getability bank_ai            @ Verifica a habilidade do Pokémon
    jumpifbytevarEQ ABILITY_LEVITATE AI_MagnetRise_NoEffect  @ Ignora se o Pokémon tem Levitate
    jumpifmove2 bank_ai MOVE_EARTHQUAKE AI_MagnetRise_PartnerGroundMoveEffective  @ Verifica se o movimento é Earthquake
    jumpifmove2 bank_ai MOVE_MAGNITUDE AI_MagnetRise_PartnerGroundMoveEffective  @ Verifica se o movimento é Magnitude
    return_cmd 

AI_MagnetRise_PartnerGroundMoveEffective:
    scoreupdate +3  @ Incentiva o uso de Magnet Rise se o movimento Ground for eficaz
    return_cmd

AI_MagnetRise_NoEffect:
    return_cmd

AI_CheckTerrains:
    jumpiffieldaffecting FIELD_AFFECTING_ELECTRIC_TERRAIN AI_ElectricTerrain
    jumpiffieldaffecting FIELD_AFFECTING_GRASSY_TERRAIN AI_GrassyTerrain
    jumpiffieldaffecting FIELD_AFFECTING_PSYCHIC_TERRAIN AI_PsychicTerrain
    jumpiffieldaffecting FIELD_AFFECTING_MISTY_TERRAIN AI_MistyTerrain
    return_cmd

AI_CheckWeather:
    jumpifweather weather_rain | weather_heavy_rain AI_RainDance
    jumpifweather weather_sun | weather_permament_sun AI_SunnyDay
    jumpifweather weather_hail | weather_permament_hail AI_Hail
    jumpifweather weather_sandstorm | weather_permament_sandstorm AI_Sandstorm
    jumpifmove MOVE_TAILWIND | MOVE_TRICK_ROOM Score_Plus5  @ Incentiva movimentos de suporte baseados no clima
    return_cmd

AI_PrioritizeSpeed:
    jumpiffieldaffecting FIELD_AFFECTING_TRICKROOM AI_TrickRoomSpeedCheck
    comparestatsboth bank_aipartner bank_ai STAT_SPD
    jumpifbytevarGE 0x1 AI_PartnerFaster  @ Se o parceiro for mais rápido
    comparestatsboth bank_ai bank_target STAT_SPD
    jumpifbytevarGE 0x1 AI_UserFasterThanTarget  @ Se o usuário for mais rápido que o alvo
    comparestatsboth bank_target bank_aipartner STAT_SPD
    jumpifbytevarGE 0x1 AI_TargetFaster  @ Se o alvo for mais rápido que o parceiro
    goto_cmd AI_SpeedNeutral  @ Caso nenhuma condição específica se aplique

AI_TrickRoomSpeedCheck:
    comparestatsboth bank_ai bank_target STAT_SPD
    jumpifbytevarLT 0x1 AI_UserFasterThanTarget  @ Inverte lógica de velocidade no Trick Room
    comparestatsboth bank_target bank_aipartner STAT_SPD
    jumpifbytevarLT 0x1 AI_TargetFaster
    goto_cmd AI_SpeedNeutral

AI_PartnerFaster: 
    jumpifhasprioritymove bank_aipartner AI_EncouragePartnerPriority  @ Verifica se o parceiro tem movimentos de prioridade
    scoreupdate +2  @ Incentiva sinergia com parceiros rápidos
    return_cmd

AI_UserFasterThanTarget:
    jumpifhasprioritymove bank_ai AI_EncourageDefensivePlay  @ Incentiva movimentos prioritários mesmo sendo mais rápido
    scoreupdate +3  @ Incentiva eliminar alvos mais lentos
    return_cmd

AI_TargetFaster:
    jumpifhasprioritymove bank_target AI_EncourageDefensivePlay  @ Se o alvo for mais rápido e tiver prioridade
    scoreupdate -3  @ Penaliza movimentos de setup contra alvos mais rápidos
    return_cmd

AI_SpeedNeutral:
    return_cmd

AI_EncouragePartnerPriority:
    scoreupdate +3  @ Movimentos de prioridade do parceiro são incentivados
    return_cmd

AI_EncourageDefensivePlay:
    scoreupdate +2  @ Movimentos de prioridade do usuário são incentivados
    return_cmd


AI_PartnerEffect_HelpingHand:
    getmovepower
    jumpifbytevarEQ MOVE_POWER_OTHER Score_Minus7
    return_cmd

AI_PartnerEffect_PerishSong:
    jumpifnostatus2 bank_target STATUS2_WRAPPED AI_PartnerEffect_PerishSong_Continue
    return_cmd

AI_PartnerEffect_PerishSong_Continue:
    getpartnerchosenmove  @ Obtém o movimento do parceiro
    jumpifwordvarEQ MOVE_INGRAIN Score_Minus3
    return_cmd

AI_PartnerEffect_WeatherMove:
	get_curr_move_type
    jumpifbytevarEQ TYPE_FIRE Score_Minus10
    jumpifbytevarEQ TYPE_ICE Score_Minus10
    jumpifbytevarEQ TYPE_WATER Score_Minus10
    jumpifbytevarEQ TYPE_ROCK Score_Minus10
    return_cmd

AI_CheckAlwaysCrits:
    getability bank_ai
    jumpifbytevarNE ABILITY_ANGER_POINT AI_CheckAlwaysCrits_End
    jumpifstrikesfirst bank_ai bank_aipartner AI_CheckAlwaysCrits_Encourage
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_SCOPELENS Score_Plus5
    jumpifbytevarEQ ITEM_EFFECT_RAZOR_CLAW Score_Plus3
    getmoveid
	jumpifmove MOVE_AEROBLAST Score_Plus5        @ Alta chance de crítico e poder base elevado
	jumpifmove MOVE_AIR_CUTTER Score_Plus3       @ Chance de crítico moderada poder base baixo
	jumpifmove MOVE_ATTACK_ORDER Score_Plus4     @ Alta chance de crítico e boa precisão
	jumpifmove MOVE_BLAZE_KICK Score_Plus4       @ Chance de crítico efeito secundário (queimadura)
	jumpifmove MOVE_CRABHAMMER Score_Plus5       @ Alta chance de crítico e poder base elevado
	jumpifmove MOVE_CROSS_CHOP Score_Plus5       @ Alta chance de crítico poder base elevado
	jumpifmove MOVE_CROSS_POISON Score_Plus4     @ Chance de crítico efeito secundário (envenenamento)
	jumpifmove MOVE_DIRE_CLAW Score_Plus5        @ Alta chance de crítico múltiplos efeitos secundários
	jumpifmove MOVE_DRILL_RUN Score_Plus4        @ Chance de crítico boa cobertura de tipos
	jumpifmove MOVE_ESPER_WING Score_Plus3       @ Chance de crítico moderada potencial estratégico
	jumpifmove MOVE_KARATE_CHOP Score_Plus3      @ Chance de crítico moderada poder base baixo
	jumpifmove MOVE_LEAF_BLADE Score_Plus5       @ Alta chance de crítico boa cobertura
	jumpifmove MOVE_NIGHT_SLASH Score_Plus5      @ Alta chance de crítico e boa cobertura
	jumpifmove MOVE_POISON_TAIL Score_Plus3      @ Chance de crítico moderada efeito secundário (envenenamento)
	jumpifmove MOVE_PSYCHO_CUT Score_Plus4       @ Chance de crítico boa cobertura
	jumpifmove MOVE_RAZOR_LEAF Score_Plus3       @ Chance de crítico moderada golpe multi-alvo
	jumpifmove MOVE_RAZOR_WIND Score_Plus2       @ Alta chance de crítico mas baixa precisão e atraso
	jumpifmove MOVE_SHADOW_CLAW Score_Plus5      @ Alta chance de crítico boa cobertura
	jumpifmove MOVE_SKY_ATTACK Score_Plus5       @ Alta chance de crítico poder base muito elevado
	jumpifmove MOVE_SLASH Score_Plus4            @ Alta chance de crítico poder base mediano
	jumpifmove MOVE_SPACIAL_REND Score_Plus5     @ Alta chance de crítico poder base elevado
	jumpifmove MOVE_STONE_EDGE Score_Plus5       @ Alta chance de crítico boa cobertura
	jumpifmove MOVE_TRIPLE_ARROW Score_Plus5     @ Alta chance de crítico múltiplos efeitos adicionais
    getmovepower
    jumpifbytevarEQ MOVE_POWER_OTHER Score_Minus5
    getability bank_ai
    jumpifbytevarEQ ABILITY_SUPER_LUCK Score_Plus3
    jumpifbytevarEQ ABILITY_SNIPER Score_Plus5
    jumpifmove MOVE_FOCUS_ENERGY Score_Minus3
    jumpifmove MOVE_SWORDS_DANCE Score_Minus2
    getmovetarget
    jumpifbytevarEQ move_target_both | move_target_foes_and_ally Score_Plus2
    jumpifstatus bank_target STATUS_POISON | STATUS_BURN Score_Plus3
    jumpifstrikesfirst bank_ai bank_target Score_Plus2
    jumpifstrikesfirst bank_target bank_ai Score_Minus3
AI_CheckAlwaysCrits_End:
    return_cmd

AI_CheckAlwaysCrits_Encourage:
    getmovetarget
    jumpifbytevarNE move_target_both | move_target_foes_and_ally Score_Plus2
    goto_cmd AI_CheckAlwaysCrits_End

AI_ElectricTerrain:
	get_curr_move_type
    jumpifbytevarEQ TYPE_ELECTRIC Score_Plus5 @ Incentiva golpes elétricos
    getability bank_ai
    jumpifbytevarEQ ABILITY_SURGE_SURFER Score_Plus3
    return_cmd

AI_GrassyTerrain:
	get_curr_move_type
    jumpifbytevarEQ TYPE_GRASS Score_Plus5    @ Incentiva golpes de grama
    jumpifmove MOVE_EARTHQUAKE Score_Minus5    @ Penaliza terremotos
    return_cmd

AI_PsychicTerrain:
	get_curr_move_type
    jumpifbytevarEQ TYPE_PSYCHIC Score_Plus5  @ Incentiva golpes psíquicos
    hasprioritymove bank_ai    @ Penaliza movimentos de prioridade
	scoreupdate -5 
    return_cmd

AI_MistyTerrain:
	get_curr_move_type
    jumpifbytevarEQ TYPE_DRAGON Score_Minus5  @ Penaliza golpes de dragão
	getmovesplit 
    jumpifbytevarEQ SPLIT_STATUS  Score_Minus3      @ Penaliza movimentos de status
    return_cmd

AI_RainDance:
    get_curr_move_type
    jumpifbytevarEQ TYPE_WATER Score_Plus5    @ Incentiva golpes de água
    jumpifbytevarEQ TYPE_FIRE Score_Minus5    @ Penaliza golpes de fogo
    getability bank_ai
    jumpifbytevarEQ ABILITY_SWIFT_SWIM Score_Plus3  @ Usuário (bank_ai) tem Swift Swim
    jumpifbytevarEQ ABILITY_HYDRATION Score_Plus2  @ Usuário (bank_ai) tem Hydration
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_DAMPROCK Score_Plus1  @ Parceiro tem Damp Rock
    getability bank_aipartner
    jumpifbytevarEQ ABILITY_SWIFT_SWIM Score_Plus3  @ Parceiro tem Swift Swim
    jumpifbytevarEQ ABILITY_HYDRATION Score_Plus2  @ Parceiro tem Hydration
    jumpifbytevarEQ ABILITY_RAIN_DISH Score_Plus2  @ Parceiro tem Rain Dish
    getitemeffect bank_aipartner
    jumpifbytevarEQ ITEM_EFFECT_DAMPROCK Score_Plus1  @ Parceiro tem Damp Rock
    return_cmd

AI_SunnyDay:
	get_curr_move_type
    jumpifbytevarEQ TYPE_FIRE Score_Plus5     @ Incentiva golpes de fogo
    jumpifbytevarEQ TYPE_WATER Score_Minus5   @ Penaliza golpes de água
    getability bank_ai
    jumpifbytevarEQ ABILITY_CHLOROPHYLL Score_Plus3
	jumpifbytevarEQ ABILITY_SOLAR_POWER Score_Plus2
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_HEATROCK Score_Plus1  @ Parceiro tem Heat Rock
    getability bank_aipartner
    jumpifbytevarEQ ABILITY_CHLOROPHYLL Score_Plus3  @ Parceiro tem Chlorophyll
    jumpifbytevarEQ ABILITY_SOLAR_POWER Score_Plus2  @ Parceiro tem Solar Power
    jumpifbytevarEQ ABILITY_FLOWER_GIFT Score_Plus2  @ Parceiro tem Flower Gift
    getitemeffect bank_aipartner
    jumpifbytevarEQ ITEM_EFFECT_HEATROCK Score_Plus1  @ Parceiro tem Heat Rock
    return_cmd

AI_Hail:
	get_curr_move_type
    jumpifbytevarEQ TYPE_ICE Score_Plus5      @ Incentiva golpes de gelo
    getability bank_ai
    jumpifbytevarEQ ABILITY_ICE_BODY Score_Plus3
    jumpifbytevarEQ ABILITY_SLUSH_RUSH Score_Plus3
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_ICYROCK Score_Plus1  @ Parceiro tem Icy Rock
    getability bank_aipartner
    jumpifbytevarEQ ABILITY_ICE_BODY Score_Plus3  @ Parceiro tem Ice Body
    jumpifbytevarEQ ABILITY_SLUSH_RUSH Score_Plus3  @ Parceiro tem Slush Rush
    jumpifbytevarEQ ABILITY_SNOW_CLOAK Score_Plus2  @ Parceiro tem Snow Cloak
    getitemeffect bank_aipartner
    jumpifbytevarEQ ITEM_EFFECT_ICYROCK Score_Plus1  @ Parceiro tem Icy Rock
    return_cmd

AI_Sandstorm:
	get_curr_move_type
    jumpifbytevarEQ TYPE_ROCK | TYPE_GROUND | TYPE_STEEL Score_Plus3   @ Incentiva Pokémon do tipo rocha
    getability bank_ai
    jumpifbytevarEQ ABILITY_SAND_RUSH Score_Plus3
    jumpifbytevarEQ ABILITY_SAND_FORCE Score_Plus2
    getitemeffect bank_ai
    jumpifbytevarEQ ITEM_EFFECT_SMOOTHROCK Score_Plus1  @ Parceiro tem Smooth Rock
    getability bank_aipartner
    jumpifbytevarEQ ABILITY_SAND_RUSH Score_Plus3  @ Parceiro tem Sand Rush
    jumpifbytevarEQ ABILITY_SAND_FORCE Score_Plus2  @ Parceiro tem Sand Force
    jumpifbytevarEQ ABILITY_SAND_VEIL Score_Plus2  @ Parceiro tem Sand Veil
    getitemeffect bank_aipartner
    jumpifbytevarEQ ITEM_EFFECT_SMOOTHROCK Score_Plus1  @ Parceiro tem Smooth Rock
    return_cmd

AI_DoubleBattlePenalizeBadPartner:
    scoreupdate -5
    return_cmd

AI_DoubleBattlePartnerHasHelpingHand:
    getmovepower
    jumpifbytevarNE MOVE_POWER_OTHER Score_Plus1
    return_cmd

AI_DoubleBattleCheckUserStatus:
    jumpifstatus bank_ai STATUS_ANY AI_DoubleBattleCheckUserStatus2
    call_cmd AI_CheckTargetStatus  @ Verifica o status do alvo
    return_cmd

AI_DoubleBattleCheckUserStatus2:
    getmovepower
    jumpifbytevarEQ MOVE_POWER_OTHER Score_Minus5
    scoreupdate +1
    jumpifbytevarEQ MOVE_MOST_POWERFUL Score_Plus2
    call_cmd AI_CheckTargetStatus  @ Verifica o status do alvo
    return_cmd

AI_CheckTargetStatus:
    jumpifstatus bank_target STATUS_BURN AI_TargetBurned
    jumpifstatus bank_target STATUS_POISON | STATUS_BAD_POISON AI_TargetPoisoned
    jumpifstatus bank_target STATUS_PARALYSIS AI_TargetParalyzed
    jumpifstatus bank_target STATUS_FREEZE AI_TargetFrozen
    jumpifstatus bank_target STATUS_SLEEP AI_TargetAsleep
    jumpifmove MOVE_HEX | MOVE_VENOSHOCK Score_Plus5  @ Incentiva movimentos sinérgicos com status
    return_cmd

AI_TargetBurned:
    hasanymovewithsplit bank_ai SPLIT_SPECIAL
    jumpifbytevarEQ 0x1 Score_Plus3  @ Incentiva ataques especiais contra alvos queimados
    getability bank_target
	jumpifbytevarEQ ABILITY_GUTS Score_Minus2 @ Penaliza ataques físicos contra alvos com GUTS
    return_cmd

AI_TargetPoisoned:
    scoreupdate +3  @ Incentiva ataques críticos contra alvos envenenados
    return_cmd

AI_TargetParalyzed:
    jumpifstrikesfirst bank_ai bank_target Score_Plus3 @ Incentiva ataques críticos se o atacante agir primeiro
    return_cmd

AI_TargetFrozen:
    scoreupdate +5  @ Incentiva fortemente ataques críticos contra alvos congelados
    return_cmd

AI_TargetAsleep:
    scoreupdate +5  @ Incentiva fortemente ataques críticos contra alvos adormecidos
    return_cmd

AI_DoubleBattleAllHittingGroundMove:
    if_ability bank_aipartner ABILITY_LEVITATE Score_Plus2
    if_type bank_aipartner TYPE_FLYING Score_Plus2
    if_type bank_aipartner TYPE_FIRE Score_Minus10
    if_type bank_aipartner TYPE_ELECTRIC Score_Minus10
    if_type bank_aipartner TYPE_POISON Score_Minus10
    if_type bank_aipartner TYPE_ROCK Score_Minus10
    return_cmd

AI_DoubleBattleSkillSwap:
    getability bank_ai
    jumpifbytevarEQ ABILITY_TRUANT Score_Plus5  @ Incentiva transferir Truant para o alvo
    getability bank_ai
    jumpifhwordvarinlist BadAbilities AI_SkillSwap_StealGoodAbility  @ Incentiva trocar uma habilidade ruim
    getability bank_target
    jumpifbytevarEQ ABILITY_SHADOW_TAG Score_Plus2  @ Incentiva roubar Shadow Tag
    jumpifbytevarEQ ABILITY_PURE_POWER Score_Plus2  @ Incentiva roubar Pure Power
    getability bank_target
    jumpifhwordvarinlist GoodAbilities AI_SkillSwap_StealGoodAbility  @ Incentiva roubar uma habilidade excelente
    return_cmd

AI_SkillSwap_StealGoodAbility:
    scoreupdate +5  @ Incrementa score ao roubar ou trocar habilidades vantajosas
    return_cmd

AI_DoubleBattleElectricMove:
    if_no_ability bank_targetpartner ABILITY_LIGHTNING_ROD AI_DoubleBattleElectricMoveEnd
    scoreupdate -2
    if_no_type bank_targetpartner TYPE_GROUND AI_DoubleBattleElectricMoveEnd
    scoreupdate -8
AI_DoubleBattleElectricMoveEnd:
    return_cmd

AI_CheckDischargePartner:
    @ Verifica se o parceiro tem Lightning Rod Motor Drive ou é imune ao tipo Elétrico
    if_ability bank_aipartner ABILITY_LIGHTNING_ROD Score_Plus5
    if_ability bank_aipartner ABILITY_MOTOR_DRIVE Score_Plus5
    if_type bank_aipartner TYPE_GROUND Score_Plus5  @ Imunidade ao golpe elétrico devido ao tipo Ground
    if_type bank_aipartner TYPE_ELECTRIC Score_Plus3  @ Parceiro resiste ao tipo Elétrico
    goto_cmd AI_DischargePenalizePartner

AI_DischargePenalizePartner:
    @Penaliza se o parceiro não tem imunidade/resistência
    if_no_type bank_aipartner TYPE_GROUND Score_Minus5
    if_no_type bank_aipartner TYPE_ELECTRIC Score_Minus3
    return_cmd

AI_CheckSurfPartner:
    @ Verifica se o parceiro tem imunidade ou resistência ao tipo Water
    if_ability bank_aipartner ABILITY_WATER_ABSORB Score_Plus5  @ Parceiro é curado por Surf
    if_ability bank_aipartner ABILITY_STORM_DRAIN Score_Plus5  @ Parceiro aumenta Sp. Atk com Surf
    if_type bank_aipartner TYPE_WATER | TYPE_GRASS Score_Plus3  @ Parceiro resiste ao golpe
    goto_cmd AI_SurfPenalizePartner

AI_SurfPenalizePartner:
    @ Penaliza se o parceiro não tem imunidade ou resistência
    if_no_type bank_aipartner TYPE_WATER Score_Minus5
    if_no_ability bank_aipartner ABILITY_WATER_ABSORB Score_Minus5
    if_no_ability bank_aipartner ABILITY_STORM_DRAIN Score_Minus5
    return_cmd

AI_CheckMuddyWaterPartner:
    @ Movimentos como Muddy Water só afetam os oponentes então são seguros
    scoreupdate +5  @ Incentiva o movimento pois não prejudica o parceiro
    return_cmd

AI_DoubleBattleFireMove:
    @ Avalia se o usuário (bank_ai) ativou Flash Fire
    jumpifflashfired bank_ai AI_DoubleBattleFireMoveFlashFire
    @ Verifica o impacto nos parceiros
    if_ability bank_aipartner ABILITY_FLASH_FIRE AI_DoubleBattleFireMovePartnerFlashFire
    if_type bank_aipartner TYPE_FIRE Score_Plus3  @ Parceiro resiste ao tipo Fire
    if_type bank_aipartner TYPE_WATER Score_Minus5  @ Parceiro é fraco ao tipo Fire
    goto_cmd AI_DoubleBattleFireMoveEnd

AI_DoubleBattleFireMoveFlashFire:
    scoreupdate +3  @ Incentiva movimentos de fogo se Flash Fire foi ativado
    return_cmd

AI_DoubleBattleFireMovePartnerFlashFire:
    jumpifflashfired bank_aipartner AI_DoubleBattleFireMoveEnd  @ Ignora se o parceiro já ativou Flash Fire
    scoreupdate +5  @ Incentiva movimentos de fogo que ativam Flash Fire no parceiro
    return_cmd

AI_DoubleBattleHeatWavePartner:
    @ Heat Wave afeta ambos os oponentes avalia sinergia com parceiros
    if_ability bank_aipartner ABILITY_FLASH_FIRE Score_Plus5  @ Incentiva se o parceiro se beneficia
    if_type bank_aipartner TYPE_FIRE Score_Plus2  @ Parceiro resiste ao golpe
    if_type bank_aipartner TYPE_WATER Score_Minus5  @ Penaliza se o parceiro é fraco
    return_cmd

AI_DoubleBattleEruptionPartner:
    @ Eruption é mais eficaz com HP alto penaliza se o HP do usuário está baixo
    jumpifhealthLT bank_ai 50 Score_Minus5  @ Penaliza se o HP está abaixo de 50%
    scoreupdate +3  @ Incentiva se o HP está alto
    return_cmd

AI_DoubleBattleFireMoveEnd:
    return_cmd

AI_CheckHyperVoicePartner:
    @ Hyper Voice afeta ambos os oponentes avalia sinergia com parceiros
    if_ability bank_aipartner ABILITY_SOUNDPROOF Score_Plus5  @ Parceiro é imune a Hyper Voice
    if_type bank_aipartner TYPE_GHOST Score_Plus5  @ Parceiro é imune ao tipo Normal
    goto_cmd AI_HyperVoicePenalizePartner

AI_HyperVoicePenalizePartner:
    @ Penaliza se o parceiro não tem imunidade ou resistência
    if_no_ability bank_aipartner ABILITY_SOUNDPROOF Score_Minus5
    if_no_type bank_aipartner TYPE_GHOST Score_Minus3
    return_cmd

AI_CheckBoomBurstPartner:
    @ BoomBurst afeta todos no campo incluindo o parceiro
    if_ability bank_aipartner ABILITY_SOUNDPROOF Score_Plus5  @ Parceiro é imune a BoomBurst
    if_type bank_aipartner TYPE_GHOST Score_Plus5  @ Parceiro é imune ao tipo Normal
    goto_cmd AI_BoomBurstPenalizePartner

AI_BoomBurstPenalizePartner:
    @ Penaliza se o parceiro não tem imunidade ou resistência
    if_no_ability bank_aipartner ABILITY_SOUNDPROOF Score_Minus7
    if_no_type bank_aipartner TYPE_GHOST Score_Minus5
    return_cmd

AI_CheckEchoedVoicePartner:
    @ Echoed Voice depende de uso consecutivo penaliza se não foi usado antes
    getlastusedmove bank_ai
    jumpifwordvarEQ MOVE_ECHOED_VOICE Score_Plus3  @ Incentiva se foi usado no turno anterior
    scoreupdate -3  @ Penaliza se não há sinergia de uso consecutivo
    return_cmd

AI_CheckDazzlingGleamPartner:
    scoreupdate +5  @ Incentiva o uso de Dazzling Gleam
    return_cmd

AI_CheckFairyWindPartner:
    @ Fairy Wind é um movimento fraco mas pode ser útil em certos casos
    if_ability bank_aipartner ABILITY_PIXILATE Score_Plus2  @ Parceiro beneficia Pixilate
    scoreupdate -2  @ Penaliza levemente devido ao baixo impacto
    return_cmd

AI_CheckMoonblastTarget:
    @ Moonblast é um movimento individual com alta potência
    if_type bank_target TYPE_DARK Score_Plus5  @ Muito eficaz contra Dark
    if_type bank_target TYPE_DRAGON Score_Plus5  @ Muito eficaz contra Dragon
    if_type bank_target TYPE_FIGHTING Score_Plus3  @ Eficaz contra Fighting
    if_type bank_target TYPE_FIRE Score_Minus3  @ Resiste ao tipo Fairy
    return_cmd

AI_CheckRockSlidePartner:
    @ Rock Slide afeta ambos os oponentes é seguro para o parceiro
    jumpifweather weather_permament_sandstorm | weather_sandstorm Score_Plus3  @ Incentiva em tempestades de areia
    if_type bank_target TYPE_FLYING Score_Plus5  @ Muito eficaz contra Flying
    if_type bank_target TYPE_FIRE Score_Plus5  @ Muito eficaz contra Fire
    if_type bank_target TYPE_ICE Score_Plus5  @ Muito eficaz contra Ice
    if_type bank_target TYPE_BUG Score_Plus3  @ Eficaz contra Bug
    return_cmd

AI_CheckAncientPowerUser:
    @ Ancient Power tem chance de aumentar os stats do usuário
    jumpifweather weather_permament_sandstorm | weather_sandstorm Score_Plus3  @ Leve incentivo em tempestades de areia
    scoreupdate +3  @ Incentiva pelo efeito secundário de aumentar stats
    return_cmd

AI_CheckStoneEdgeTarget:
    @ Stone Edge é um movimento individual com alta taxa de crítico
    if_type bank_target TYPE_FLYING Score_Plus5  @ Muito eficaz contra Flying
    if_type bank_target TYPE_FIRE Score_Plus5  @ Muito eficaz contra Fire
    if_type bank_target TYPE_ICE Score_Plus5  @ Muito eficaz contra Ice
    if_type bank_target TYPE_BUG Score_Plus3  @ Eficaz contra Bug
    return_cmd

AI_CheckExplosionPartner:
    @ Verifica se o parceiro é imune ou resistente a Explosion
    if_type bank_aipartner TYPE_GHOST Score_Plus5  @ Parceiro é imune ao tipo Normal
    if_ability bank_aipartner ABILITY_DAMP Score_Minus10  @ Parceiro impede o uso de Explosion
    goto_cmd AI_PenalizeExplosionPartner

AI_PenalizeExplosionPartner:
    @ Penaliza se o parceiro não tem imunidade ou resistência
    if_no_type bank_aipartner TYPE_GHOST Score_Minus5
    return_cmd

AI_CheckSelfDestructPartner:
    @ Verifica se o parceiro é imune ou resistente a Self-Destruct
    if_type bank_aipartner TYPE_GHOST Score_Plus5  @ Parceiro é imune ao tipo Normal
    if_ability bank_aipartner ABILITY_DAMP Score_Minus10  @ Parceiro impede o uso de Self-Destruct
    goto_cmd AI_PenalizeSelfDestructPartner

AI_PenalizeSelfDestructPartner:
    @ Penaliza se o parceiro não tem imunidade ou resistência
    if_no_type bank_aipartner TYPE_GHOST Score_Minus5
    return_cmd

AI_TryOnAlly:
    getmovepower
    jumpifbytevarEQ MOVE_POWER_OTHER AI_TryStatusMoveOnAlly
    jumpifmovescriptEQ 180 AI_Effect_Purify
    jumpifmovescriptEQ 186 AI_Effect_Confusion
    jumpifmovescriptEQ 116 AI_Effect_BeatUpOnAlly
    jumpifmovescriptEQ 42 AI_Effect_SkillSwapOnAlly
    jumpifmovescriptEQ 42 AI_Effect_RolePlayOnAlly
    jumpifmovescriptEQ 42 AI_Effect_AbilityChangeOnAlly
    jumpifmovescriptEQ 45 AI_Effect_AbilityChangeOnAlly
    jumpifmovescriptEQ 42 AI_Effect_AbilityChangeOnAlly
    jumpifmovescriptEQ 42 AI_Effect_EntrainmentOnAlly
    jumpifmovescriptEQ 155 AI_Effect_SoakOnAlly
    jumpifmovescriptEQ 48 AI_Effect_AfterYouOnAlly
    jumpifmovescriptEQ 26 AI_Effect_HealPulseOnAlly
    return_cmd

AI_Effect_Purify:
    jumpifnostatus bank_aipartner STATUS_ANY Score_Minus30
    scoreupdate +3
    return_cmd

AI_Effect_Confusion:
    jumpifstatbuffGE bank_aipartner STAT_ATK max_stat_stage Score_Minus30
    hasanymovewithsplit bank_aipartner SPLIT_PHYSICAL
    jumpifbytevarEQ 0x1 AI_CheckPartnerConfusion
    return_cmd

AI_CheckPartnerConfusion:
    checkability bank_aipartner ABILITY_OWN_TEMPO
	jumpifbytevarEQ 1 Score_Minus30  @ Parceiro é imune à confusão
    jumpifstatus2 bank_aipartner STATUS2_CONFUSION Score_Minus30  @ Parceiro já está confuso
	getitemeffect bank_aipartner 1
    jumpifbytevarEQ ITEM_EFFECT_MIRACLESEED Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_LUMBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_RAWSTBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_ASPEARBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_CHERIBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_PECHABERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_PERSIMBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_MENTALHERB Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_CHESTOBERRY Score_Plus3
    jumpifbytevarEQ ITEM_EFFECT_LUMBERRY Score_Plus3
    scoreupdate +3
    return_cmd

AI_Effect_BeatUpOnAlly:
    checkability bank_aipartner ABILITY_JUSTIFIED
	jumpifbytevarEQ 1 AI_CheckBeatUpPartner
    return_cmd

AI_CheckBeatUpPartner:
    isoftype bank_ai TYPE_DARK
	jumpifbytevarEQ 1 AI_CheckBeatUpPartner_AtkStat
    return_cmd

AI_CheckBeatUpPartner_AtkStat:
    jumpifstatbuffGE bank_aipartner STAT_ATK max_stat_stage Score_Minus30
    getmoveidbyindex 0  @ Obtém o ID do movimento pelo índice
    jumpifwillfaint bank_ai bank_aipartner Score_Minus30  @ Verifica se o movimento atual derrota o parceiro
    scoreupdate +3
    return_cmd

AI_Effect_SkillSwapOnAlly:
    getability bank_ai
    jumpifbytevarEQ ABILITY_TRUANT Score_Plus10
    jumpifbytevarEQ ABILITY_INTIMIDATE Score_Plus5
    jumpifbytevarEQ ABILITY_COMPOUND_EYES AI_CheckSkillSwapAccuracy
    jumpifbytevarEQ ABILITY_CONTRARY AI_CheckSkillSwapContrary
    getability bank_aipartner
    jumpifbytevarEQ ABILITY_TRUANT Score_Plus10
    jumpifbytevarEQ ABILITY_INTIMIDATE Score_Plus5
    jumpifbytevarEQ ABILITY_COMPOUND_EYES AI_CheckSkillSwapAccuracy
    jumpifbytevarEQ ABILITY_CONTRARY AI_CheckSkillSwapContrary
    return_cmd

AI_CheckSkillSwapAccuracy:
    jumpifhasmove bank_aipartner MOVE_THUNDER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_FIRE_BLAST Score_Plus5
    jumpifhasmove bank_aipartner MOVE_HYDRO_PUMP Score_Plus5
    jumpifhasmove bank_aipartner MOVE_BLIZZARD Score_Plus5
    jumpifhasmove bank_aipartner MOVE_FOCUS_BLAST Score_Plus5
    jumpifhasmove bank_aipartner MOVE_STONE_EDGE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_HURRICANE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_DYNAMIC_PUNCH Score_Plus5
    jumpifhasmove bank_aipartner MOVE_ZAP_CANNON Score_Plus5
    jumpifhasmove bank_aipartner MOVE_SING Score_Plus5
    jumpifhasmove bank_aipartner MOVE_HYPNOSIS Score_Plus5
    jumpifhasmove bank_aipartner MOVE_WILLOWISP Score_Plus5
    jumpifhasmove bank_aipartner MOVE_TOXIC Score_Plus5
    jumpifhasmove bank_aipartner MOVE_LOVELY_KISS Score_Plus5
    jumpifhasmove bank_aipartner MOVE_GRASS_WHISTLE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_SLEEP_POWDER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_STUN_SPORE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_POISON_POWDER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_CROSS_CHOP Score_Plus5
    jumpifhasmove bank_aipartner MOVE_MEGA_KICK Score_Plus5
    jumpifhasmove bank_aipartner MOVE_IRON_TAIL Score_Plus5
    jumpifhasmove bank_aipartner MOVE_METEOR_MASH Score_Plus5
    jumpifhasmove bank_aipartner MOVE_PLAY_ROUGH Score_Plus5
    jumpifhasmove bank_aipartner MOVE_ROCK_BLAST Score_Plus5
    jumpifhasmove bank_aipartner MOVE_PIN_MISSILE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_ICICLE_SPEAR Score_Plus5
    return_cmd

AI_CheckSkillSwapContrary:
    jumpifhasmove bank_aipartner MOVE_SUPERPOWER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_CLOSE_COMBAT Score_Plus5
    jumpifhasmove bank_aipartner MOVE_LEAF_STORM Score_Plus5
    jumpifhasmove bank_aipartner MOVE_OVERHEAT Score_Plus5
    jumpifhasmove bank_aipartner MOVE_DRACO_METEOR Score_Plus5
    jumpifhasmove bank_aipartner MOVE_FLEUR_CANNON Score_Plus5
    jumpifhasmove bank_aipartner MOVE_PSYCHO_BOOST Score_Plus5
    jumpifhasmove bank_aipartner MOVE_HAMMER_ARM Score_Plus5
    jumpifhasmove bank_aipartner MOVE_VCREATE Score_Plus5
    jumpifhasmove bank_aipartner MOVE_SHELL_SMASH Score_Plus5
    jumpifhasmove bank_aipartner MOVE_ICE_HAMMER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_ROCK_WRECKER Score_Plus5
    jumpifhasmove bank_aipartner MOVE_SHADOW_BONE Score_Plus5
    return_cmd

AI_Effect_RolePlayOnAlly:
    getability bank_ai
    jumpifhwordvarinlist BadAbilities AI_CheckRolePlayPartnerAbility
    return_cmd

AI_CheckRolePlayPartnerAbility:
AI_Effect_AbilityChangeOnAlly:
    getability bank_aipartner
    jumpifhwordvarinlist BadAbilities Score_Plus3
    return_cmd

AI_Effect_EntrainmentOnAlly:
    getability bank_aipartner
    jumpifhwordvarinlist BadAbilities AI_CheckEntrainmentPartnerAbility
    return_cmd

AI_CheckEntrainmentPartnerAbility:
    getability bank_ai
    jumpifhwordvarinlist BadAbilities Score_Plus3
    return_cmd

AI_Effect_SoakOnAlly:
    checkability bank_aipartner ABILITY_WONDER_GUARD
	jumpifbytevarEQ 1 AI_CheckSoakPartnerType
    return_cmd

AI_CheckSoakPartnerType:
    isoftype bank_aipartner TYPE_WATER
	jumpifbytevarEQ 1 Score_Minus30
    scoreupdate +3
    return_cmd

AI_Effect_AfterYouOnAlly:
    jumpifstrikesfirst bank_aipartner bank_targetpartner Score_Plus3
    return_cmd

AI_Effect_HealPulseOnAlly:
    jumpifhealthGE bank_aipartner 50 Score_Minus30
    scoreupdate +3
    return_cmd

AI_DiscourageOnAlly:
	goto_cmd Score_Minus30

AI_TryFireMoveOnAlly:
	if_ability bank_aipartner ABILITY_FLASH_FIRE AI_TryFireMoveOnAlly_FlashFire
	goto_cmd AI_DiscourageOnAlly

AI_TryFireMoveOnAlly_FlashFire:
	jumpifflashfired bank_aipartner AI_DiscourageOnAlly
	goto_cmd Score_Plus3

AI_TryStatusMoveOnAlly:
	get_curr_move_type
	jumpifmove MOVE_SKILL_SWAP AI_TrySkillSwapOnAlly
	jumpifmove MOVE_WILLOWISP AI_TryStatusOnAlly
	jumpifmove MOVE_TOXIC AI_TryStatusOnAlly
	jumpifmove MOVE_HELPING_HAND AI_TryHelpingHandOnAlly
	jumpifmove MOVE_SWAGGER AI_TrySwaggerOnAlly
	goto_cmd Score_Minus30

AI_TrySkillSwapOnAlly:
	getability bank_target
	jumpifbytevarEQ ABILITY_TRUANT Score_Plus10
	getability bank_ai
	jumpifbytevarNE ABILITY_LEVITATE AI_TrySkillSwapOnAlly2
	getability bank_target
	jumpifbytevarEQ ABILITY_LEVITATE Score_Minus30
	get_target_type1
	jumpifbytevarNE TYPE_ELECTRIC AI_TrySkillSwapOnAlly2
	scoreupdate +1
	get_target_type2
	jumpifbytevarNE TYPE_ELECTRIC AI_TrySkillSwapOnAlly2
	scoreupdate +1
	return_cmd

AI_TrySkillSwapOnAlly2:
	jumpifbytevarNE ABILITY_COMPOUND_EYES Score_Minus30
	jumpifhasmove bank_aipartner MOVE_FIRE_BLAST AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_THUNDER AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_CROSS_CHOP AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_HYDRO_PUMP AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_DYNAMIC_PUNCH AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_BLIZZARD AI_TrySkillSwapOnAllyPlus3
	jumpifhasmove bank_aipartner MOVE_MEGAHORN AI_TrySkillSwapOnAllyPlus3
	goto_cmd Score_Minus30

AI_TrySkillSwapOnAllyPlus3:
	goto_cmd Score_Plus3

AI_TryStatusOnAlly:
	getability bank_target
	jumpifbytevarNE ABILITY_GUTS Score_Minus30
	jumpifstatus bank_target STATUS_ANY Score_Minus30
	jumpifhealthLT bank_ai 91 Score_Minus30
	goto_cmd Score_Plus5

AI_TryHelpingHandOnAlly:
	jumpifrandLT 64 Score_Minus1
	goto_cmd Score_Plus2

AI_TrySwaggerOnAlly:
	jumpifitem bank_target ITEM_PERSIMBERRY AI_TrySwaggerOnAlly2
	goto_cmd Score_Minus30

AI_TrySwaggerOnAlly2:
	jumpifstatbuffGE bank_target STAT_ATK 7 AI_TrySwaggerOnAlly_End
	scoreupdate +3
AI_TrySwaggerOnAlly_End:
	return_cmd

Score_Minus1:
	scoreupdate -1
	return_cmd

Score_Minus2:
	scoreupdate -2
	return_cmd

Score_Minus3:
	scoreupdate -3
	return_cmd

Score_Minus5:
	scoreupdate -5
	return_cmd

Score_Minus7:
	scoreupdate -7
	return_cmd

Score_Minus8:
	scoreupdate -8
	return_cmd

Score_Minus10:
	scoreupdate -10
	return_cmd

Score_Minus12:
	scoreupdate -12
	return_cmd

Score_Minus30:
	scoreupdate -30
	return_cmd

Score_Plus1:
	scoreupdate +1
	return_cmd

Score_Plus2:
	scoreupdate +2
	return_cmd

Score_Plus3:
	scoreupdate +3
	return_cmd

Score_Plus4:
	scoreupdate +4
	return_cmd

Score_Plus5:
	scoreupdate +5
	return_cmd

Score_Plus10:
	scoreupdate +10
	return_cmd
################################################################################################
TAI_SCRIPT_1D: @roaming
	call_cmd IS_AI_UNABLETOESCAPE
	jumpifbytevarEQ 0x1 END_LOCATION
	flee

.align 4
tai_command_table:
.byte 0x79, 0x11, 0x13, 0x08	@0x0
.byte 0xB9, 0x11, 0x13, 0x08	@0x1
.byte 0xF9, 0x11, 0x13, 0x08	@0x2
.byte 0x39, 0x12, 0x13, 0x08	@0x3
.byte 0x79, 0x12, 0x13, 0x08	@0x4
.byte 0xBD, 0x12, 0x13, 0x08	@0x5
.byte 0x25, 0x13, 0x13, 0x08	@0x6
.byte 0x8D, 0x13, 0x13, 0x08	@0x7
.byte 0xF5, 0x13, 0x13, 0x08	@0x8
.byte 0x5D, 0x14, 0x13, 0x08	@0x9
.byte 0xD1, 0x14, 0x13, 0x08	@0xA
.byte 0x45, 0x15, 0x13, 0x08	@0xB
.byte 0xB9, 0x15, 0x13, 0x08	@0xC
.byte 0x2D, 0x16, 0x13, 0x08	@0xD
.byte 0x9D, 0x16, 0x13, 0x08	@0xE
.byte 0x0D, 0x17, 0x13, 0x08	@0xF
.byte 0x89, 0x17, 0x13, 0x08	@0x10
.byte 0x05, 0x18, 0x13, 0x08	@0x11
.byte 0x41, 0x18, 0x13, 0x08	@0x12
.byte 0x7D, 0x18, 0x13, 0x08	@0x13
.byte 0xB9, 0x18, 0x13, 0x08	@0x14
.byte 0xF5, 0x18, 0x13, 0x08	@0x15
.byte 0x49, 0x19, 0x13, 0x08	@0x16
.byte 0x9D, 0x19, 0x13, 0x08	@0x17
.byte 0xF1, 0x19, 0x13, 0x08	@0x18
.byte 0x45, 0x1A, 0x13, 0x08	@0x19
.byte 0x89, 0x1A, 0x13, 0x08	@0x1A
.byte 0xCD, 0x1A, 0x13, 0x08	@0x1B
.byte 0x35, 0x1B, 0x13, 0x08	@0x1C
.byte 0xA1, 0x1B, 0x13, 0x08	@0x1D
.byte 0x0D, 0x1C, 0x13, 0x08	@0x1E
.byte 0x7D, 0x1C, 0x13, 0x08	@0x1F
.byte 0xED, 0x1C, 0x13, 0x08	@0x20
.byte 0x5D, 0x1D, 0x13, 0x08	@0x21
.byte 0x81, 0x1D, 0x13, 0x08	@0x22
.byte 0x1D, 0x1F, 0x13, 0x08	@0x23
.word tai24_ismostpowerful + 1	@0x24
.byte 0x4D, 0x21, 0x13, 0x08	@0x25
.byte 0xA5, 0x21, 0x13, 0x08	@0x26
.byte 0xE1, 0x21, 0x13, 0x08	@0x27
.word tai28_jumpifstrikesfirst + 1	@0x28
.word tai29_jumpifstrikessecond + 1	@0x29
.word tai2A_discourage_moves_based_on_abilities + 1	@0x2A
.word tai2B_affected_by_substitute + 1	@0x2B
.byte 0xBD, 0x22, 0x13, 0x08	@0x2C
.byte 0xB9, 0x23, 0x13, 0x08	@0x2D
.byte 0xD5, 0x23, 0x13, 0x08	@0x2E
.word tai2F_getability + 1		@0x2F
.byte 0x15, 0x26, 0x13, 0x08	@0x30
.word tai31_jumpifeffectiveness_EQ + 1	@0x31
.word tai32_jumpifeffectiveness_NE + 1	@0x32
.word tai33_is_in_semiinvulnerable_state + 1	@0x33
.byte 0xD9, 0x27, 0x13, 0x08	@0x34
.byte 0xB9, 0x28, 0x13, 0x08	@0x35
.word tai36_jumpifweather + 1	@0x36
.byte 0x01, 0x2A, 0x13, 0x08	@0x37
.byte 0x4D, 0x2A, 0x13, 0x08	@0x38
.byte 0x99, 0x2A, 0x13, 0x08	@0x39
.byte 0x01, 0x2B, 0x13, 0x08	@0x3A
.byte 0x69, 0x2B, 0x13, 0x08	@0x3B
.byte 0xD1, 0x2B, 0x13, 0x08	@0x3C
.word tai3D_jumpiffatal + 1		@0x3D
.word tai3E_jumpifnotfatal + 1	@0x3E
.word tai3F_jumpifhasmove + 1				@0x3F
.byte 0x49, 0x2F, 0x13, 0x08	@0x40
.byte 0x21, 0x30, 0x13, 0x08	@0x41
.byte 0x19, 0x31, 0x13, 0x08	@0x42
.byte 0xFD, 0x31, 0x13, 0x08	@0x43
.byte 0x85, 0x32, 0x13, 0x08	@0x44
.byte 0x15, 0x33, 0x13, 0x08	@0x45
.byte 0x29, 0x33, 0x13, 0x08	@0x46
.byte 0x89, 0x33, 0x13, 0x08	@0x47
.word tai48_getitemeffect + 1	@0x48
.byte 0x95, 0x34, 0x13, 0x08	@0x49
.byte 0xED, 0x34, 0x13, 0x08	@0x4A
.byte 0x39, 0x35, 0x13, 0x08	@0x4B
.byte 0x85, 0x35, 0x13, 0x08	@0x4C
.byte 0xAD, 0x35, 0x13, 0x08	@0x4D
.byte 0xF9, 0x35, 0x13, 0x08	@0x4E
.byte 0x25, 0x36, 0x13, 0x08	@0x4F
.byte 0x51, 0x36, 0x13, 0x08	@0x50
.word tai51_getprotectuses + 1				@0x51
.word tai52_movehitssemiinvulnerable + 1	@0x52
.word tai53_getmovetarget + 1				@0x53
.word tai54_getvarmovetarget + 1			@0x54
.word tai55_isstatchangepositive + 1		@0x55
.word tai56_getstatvaluemovechanges + 1		@0x56
.word tai57_jumpifbankaffecting + 1			@0x57
.byte 0xE1, 0x36, 0x13, 0x08	@0x58
.byte 0x11, 0x37, 0x13, 0x08	@0x59
.byte 0x31, 0x37, 0x13, 0x08	@0x5A
.byte 0x55, 0x37, 0x13, 0x08	@0x5B
.byte 0x2D, 0x38, 0x13, 0x08	@0x5C
.byte 0x7D, 0x38, 0x13, 0x08	@0x5D
.byte 0xCD, 0x38, 0x13, 0x08	@0x5E
.word tai5F_is_of_type + 1		@0x5F
.word tai60_checkability + 1	@0x60
.byte 0x1D, 0x39, 0x13, 0x08	@0x61
.byte 0x15, 0x34, 0x13, 0x08	@0x62
.word tai63_jumpiffieldaffecting + 1	@0x63
.word tai64_isbankinlovewith + 1		@0x64
.word tai65_vartovar2 + 1			@0x65
.word tai66_jumpifvarsEQ + 1		@0x66
.word tai67_jumpifcantaddthirdtype + 1 	@0x67
.word tai68_canchangeability + 1 		@0x68
.word tai69_getitempocket + 1 			@0x69
.word tai6A_discouragehazards + 1 		@0x6A
.word tai6B_sharetype + 1 				@0x6B
.word tai6C_isbankpresent + 1			@0x6C 
.word tai6D_jumpifwordvarEQ + 1  		@0x6D
.word tai6E_islockon_on + 1 			@0x6E
.word tai6F_discouragesports + 1 		@0x6F
.word tai70_jumpifnewsideaffecting + 1 	@0x70
.word tai71_getmovesplit + 1    		@0x71
.word tai72_cantargetfaintuser + 1 		@0x72
.word tai73_hashighcriticalratio + 1 	@0x73
.word tai74_getmoveaccuracy + 1 		@0x74
.word tai75_logiconestatuser + 1 		@0x75
.word tai76_logiconestattarget + 1 		@0x76
.word tai77_abilitypreventsescape + 1 	@0x77
.word tai78_setbytevar + 1 				@0x78
.word tai79_arehazardson + 1 			@0x79
.word tai7A_gettypeofattacker + 1 		@0x7A
.word tai7B_hasanymovewithsplit + 1 	@0x7B
.word tai7C_hasprioritymove + 1 		@0x7C
.word tai7D_getbestdamage_lefthp + 1 	@0x7D
.word tai7E_isrecoilmove_necessary + 1  @0x7E
.word tai7F_isintruantturn + 1 			@0x7F
.word tai80_getmoveeffectchance + 1 	@0x80
.word tai81_hasmovewithaccuracylower + 1 	@0x81
.word tai82_getpartnerchosenmove + 1 		@0x82
.word tai83_hasanydamagingmoves + 1 	@0x83
.word tai84_jumpifcantusemove + 1		@0x84
.word tai85_canmultiplestatwork + 1 	@0x85
.word tai86_jumpifhasattackingmovewithtype + 1 		@0x86
.word tai87_jumpifhasnostatusmoves + 1		@0x87
.word tai88_jumpifstatusmovesnotworthusing + 1 		@0x88
.word tai89_jumpifsamestatboosts + 1							@0x89
.word tai8A_can_use_multitarget_move + 1					@0x8A
.word tai8B_getmovetype +1							@8B
.word tai8C_comparehp + 1 							@8C
.word tai8D_getmoveidbyindex + 1 							@8D
.word tai8E_getform + 1 							@8E
.word tai8F_jumpifally + 1 							@8F
.word tai90_arehazardson2 + 1 							@90
.word tai91_hascontactmove + 1 	@0x91
.word tai92_ishazardmove + 1 	@0x92
.word tai93_jumpifauroraveiltimer + 1 	@0x93
.word tai94_check_weather_faint + 1 	@0x94
.word tai95_get_wish_duration + 1 	@0x95
.word tai96_jumpifmoveflag + 1 	@0x96
.word tai97_comparestats + 1 	@0x97
.word tai98_comparestatsboth + 1 	@0x98
.word tai99_getpredictedmove + 1 	@0x99
.word tai9A_getbankspecies + 1 	@0x9A
.word tai9B_check_party_fully_healed + 1 	@0x9B
.word tai9C_checkiftrickroomisending + 1 	@0x9C
.word tai9D_checkpokeweight + 1 	@0x9D
.word tai9E_jumpifwordvarNE + 1 	@0x9E
.word tai9F_jumpifwordvarLE + 1 	@0x9F
.word taiA0_jumpifvarsNE + 1 	@0xA0
.word taiA1_jumpifvarsLT + 1 	@0xA1
.word taiA2_get_consecutive_move_count + 1 	@0xA2
.word taiA3_jumpifwillfaint + 1 	@0xA3
.word taiA4_gethappiness + 1 	@0xA4
.word taiA5_gyroballpowerlevel + 1 	@0xA5
.word taiA6_grassknotweighttier + 1 	@0xA6
.word taiA7_heavyslamweighttier + 1 	@0xA7
.word taiA8_electroballpowerlevel + 1 	@0xA8
.word taiA9_jumpifattackboostmove + 1 	@0xA9
.word taiAA_jumpifmovealwayscrits + 1 	@0xAA
.word taiAB_jumpifmovestatusmove + 1 	@0xAB
.word taiAC_isbattlergrounded + 1 	@0xAC
.word taiAD_jumpifhasprioritymove + 1 	@0xAD
.word taiAE_jumpifmove2 + 1 	@0xAE
.word taiAF_discourage_moves_double + 1 	@0xAF
.word taiB0_checklowpp + 1 	@0xB0
.word taiB1_checkstab + 1 	@0xB1

.align 2
correct_0x2ddf6A:
.hword 0xB6,0xC5,0xFFFF


