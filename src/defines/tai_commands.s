.text
.thumb

.macro jumpifrandLT jumpifrandLTnum jumpifrandLTaddress
.byte 0
.byte \jumpifrandLTnum
.word \jumpifrandLTaddress
.endm

.macro jumpifrandGE jumpifrandGTnum jumpifrandGTaddress
.byte 1
.byte \jumpifrandGTnum
.word \jumpifrandGTaddress
.endm

.macro jumpifrandNE jumpifrandNEnum jumpifrandNEaddress
.byte 2
.byte \jumpifrandNEnum
.word \jumpifrandNEaddress
.endm

.macro jumpifrandEQ jumpifrandEQnum jumpifrandEQaddress
.byte 3
.byte \jumpifrandEQnum
.word \jumpifrandEQaddress
.endm

.macro scoreupdate scoreupdatenum
.byte 4
.byte \scoreupdatenum
.endm

.macro jumpifhealthLT jumpifhealthLTbank jumpifhealthLTnum jumpifhealthLTaddress
.byte 5
.byte \jumpifhealthLTbank
.byte \jumpifhealthLTnum
.word \jumpifhealthLTaddress
.endm

.macro jumpifhealthGE jumpifhealthGEbank jumpifhealthGEnum jumpifhealthGEaddress
.byte 6
.byte \jumpifhealthGEbank
.byte \jumpifhealthGEnum
.word \jumpifhealthGEaddress
.endm

.macro jumpifhealthEQ jumpifhealthEQbank jumpifhealthEQnum jumpifhealthEQaddress
.byte 7
.byte \jumpifhealthEQbank
.byte \jumpifhealthEQnum
.word \jumpifhealthEQaddress
.endm

.macro jumpifhealthNE jumpifhealthNEbank jumpifhealthNEnum jumpifhealthNEaddress
.byte 8
.byte \jumpifhealthNEbank
.byte \jumpifhealthNEnum
.word \jumpifhealthNEaddress
.endm

.macro jumpifstatus jumpifstatusbank jumpifstatusstatus jumpifstatusaddress
.byte 9
.byte \jumpifstatusbank
.word \jumpifstatusstatus
.word \jumpifstatusaddress
.endm

.macro jumpifnostatus jumpifnostatusbank jumpifnostatusstatus jumpifnostatusaddress
.byte 0xA
.byte \jumpifnostatusbank
.word \jumpifnostatusstatus
.word \jumpifnostatusaddress
.endm

.macro jumpifstatus2 jumpifstatus2bank jumpifstatus2status jumpifstatus2address
.byte 0xB
.byte \jumpifstatus2bank
.word \jumpifstatus2status
.word \jumpifstatus2address
.endm

.macro jumpifnostatus2 jumpifnostatus2bank jumpifnostatus2status jumpifnostatus2address
.byte 0xC
.byte \jumpifnostatus2bank
.word \jumpifnostatus2status
.word \jumpifnostatus2address
.endm

.macro jumpifstatus3 jumpifstatus3bank jumpifstatus3status jumpifstatus3address
.byte 0xD
.byte \jumpifstatus3bank
.word \jumpifstatus3status
.word \jumpifstatus3address
.endm

.macro jumpifnostatus3 jumpifnostatus3bank jumpifnostatus3status jumpifnostatus3address
.byte 0xE
.byte \jumpifnostatus3bank
.word \jumpifnostatus3status
.word \jumpifnostatus3address
.endm

.macro jumpifsideaffecting jumpifsideaffectingbank jumpifsideaffectingstatus jumpifsideaffectingaddress
.byte 0xF
.byte \jumpifsideaffectingbank
.word \jumpifsideaffectingstatus
.word \jumpifsideaffectingaddress
.endm

.macro jumpifnosideaffecting jumpifnosideaffectingbank jumpifnosideaffectingstatus jumpifnosideaffectingaddress
.byte 0x10
.byte \jumpifnosideaffectingbank
.word \jumpifnosideaffectingstatus
.word \jumpifnosideaffectingaddress
.endm

.macro jumpifbytevarLT jumpifbytevarLTnum jumpifbytevarLTaddress
.byte 0x11
.byte \jumpifbytevarLTnum
.word \jumpifbytevarLTaddress
.endm

.macro jumpifbytevarGE jumpifbytevarGEnum jumpifbytevarGEaddress
.byte 0x12
.byte \jumpifbytevarGEnum
.word \jumpifbytevarGEaddress
.endm

.macro jumpifbytevarEQ jumpifbytevarEQnum jumpifbytevarEQaddress
.byte 0x13
.byte \jumpifbytevarEQnum
.word \jumpifbytevarEQaddress
.endm

.macro jumpifbytevarNE jumpifbytevarNEnum jumpifbytevarNEaddress
.byte 0x14
.byte \jumpifbytevarNEnum
.word \jumpifbytevarNEaddress
.endm

.macro jumpifbytevarfromptrLT jumpifbytevarfromptrLTnum jumpifbytevarfromptrLTaddress
.byte 0x15
.word \jumpifbytevarfromptrLTnum
.word \jumpifbytevarfromptrLTaddress
.endm

.macro jumpifbytevarfromptrGE jumpifbytevarfromptrGEnum jumpifbytevarfromptrGEaddress
.byte 0x16
.word \jumpifbytevarfromptrGEnum
.word \jumpifbytevarfromptrGEaddress
.endm

.macro jumpifbytevarfromptrEQ jumpifbytevarfromptrEQnum jumpifbytevarfromptrEQaddress
.byte 0x17
.word \jumpifbytevarfromptrEQnum
.word \jumpifbytevarfromptrEQaddress
.endm

.macro jumpifbytevarfromptrNE jumpifbytevarfromptrNEnum jumpifbytevarfromptrNEaddress
.byte 0x18
.word \jumpifbytevarfromptrNEnum
.word \jumpifbytevarfromptrNEaddress
.endm

.macro jumpifmove jumpifmovemove jumpifmoveaddress
.byte 0x19
.hword \jumpifmovemove
.word \jumpifmoveaddress
.endm

.macro jumpifnotmove jumpifnotmovemove jumpifnotmoveaddress
.byte 0x1A
.hword \jumpifnotmovemove
.word \jumpifnotmoveaddress
.endm

.macro jumpifbytevarinlist jumpifbytevarinlistnum jumpifbytevarinlistaddress
.byte 0x1B
.word \jumpifbytevarinlistnum
.word \jumpifbytevarinlistaddress
.endm

.macro jumpifbytevarnotinlist jumpifbytevarnotinlistnum jumpifbytevarnotinlistaddress
.byte 0x1C
.word \jumpifbytevarnotinlistnum
.word \jumpifbytevarnotinlistaddress
.endm

.macro jumpifhwordvarinlist jumpifhwordvarinlistnum jumpifhwordvarinlistaddress
.byte 0x1D
.word \jumpifhwordvarinlistnum
.word \jumpifhwordvarinlistaddress
.endm

.macro jumpifhwordvarnotinlist jumpifhwordvarnotinlistnum jumpifhwordvarnotinlistaddress
.byte 0x1E
.word \jumpifhwordvarnotinlistnum
.word \jumpifhwordvarnotinlistaddress
.endm

.macro jumpifattackerhasdamagingmove jumpifattackerhasdamagingmoveaddress
.byte 0x1F
.word \jumpifattackerhasdamagingmoveaddress
.endm

.macro jumpifattackerhasnodamagingmoves jumpifattackerhasnodamagingmovesaddress
.byte 0x20
.word \jumpifattackerhasnodamagingmovesaddress
.endm

.macro getbattleturncounter
.byte 0x21
.endm

########################################
.macro gettypeinfo gettypeinfonum
.byte 0x22
.byte \gettypeinfonum
.endm

.macro get_curr_move_type
gettypeinfo AI_TYPE_MOVE
.endm

.macro get_user_type1
gettypeinfo AI_TYPE1_USER
.endm

.macro get_user_type2
gettypeinfo AI_TYPE2_USER
.endm

.macro get_target_type1
gettypeinfo AI_TYPE1_TARGET
.endm

.macro get_target_type2
gettypeinfo AI_TYPE2_TARGET
.endm
########################################
.macro getmovepower
.byte 0x23
.endm

.macro ismostpowerful @rewritten
.byte 0x24
.endm

.macro jumpifmostpowerful jumpifmostpowerfuladdress
ismostpowerful
jumpifbytevarEQ 1 \jumpifmostpowerfuladdress
.endm

.macro jumpifnotmostpowerful jumpifnotmostpowerfuladdress
ismostpowerful
jumpifbytevarEQ 0 \jumpifnotmostpowerfuladdress
.endm

.macro getlastusedmove getlastusedmovebank
.byte 0x25
.byte \getlastusedmovebank
.endm
##################################################################################################################
.macro jumpifstrikesfirst jumpifstrikesfirstbank1 jumpifstrikesfirstbank2 jumpifstrikesfirstptr @rewritten
.byte 0x28
.byte \jumpifstrikesfirstbank1
.byte \jumpifstrikesfirstbank2
.word \jumpifstrikesfirstptr
.endm

.macro if_target_faster ptr
jumpifstrikesfirst 1, \ptr
.endm

.macro if_user_faster ptr
jumpifstrikesfirst 0, \ptr
.endm
##################################################################################################################
.macro jumpifstrikessecond jumpifstrikessecondbank1 jumpifstrikessecondbank2 jumpifstrikessecondptr @rewritten
.byte 0x29
.byte \jumpifstrikessecondbank1
.byte \jumpifstrikessecondbank2
.word \jumpifstrikessecondptr
.endm

##################################################################################################################
.macro discourage_moves_based_on_abilities @new command, old slot
.byte 0x2A
.endm
##################################################################################################################
.macro affected_by_substitute
.byte 0x2B
.endm

.macro countalivepokes countalivepokesbank
.byte 0x2C
.byte \countalivepokesbank
.endm

.macro getmoveid
.byte 0x2D
.endm

.macro getmovescript
.byte 0x2E
.endm

.macro getability getabilitybank getabilityGastro @rewritten
.byte 0x2F
.byte \getabilitybank
.byte \getabilityGastro
.endm

.macro jumpifeffectiveness_EQ jumpifeffectiveness_EQeffectiveness jumpifeffectiveness_EQaddress @rewritten
.byte 0x31
.byte \jumpifeffectiveness_EQeffectiveness
.word \jumpifeffectiveness_EQaddress
.endm

.macro jumpifeffectiveness_NE jumpifeffectiveness_NEeffectiveness jumpifeffectiveness_NEaddress @rewritten
.byte 0x32
.byte \jumpifeffectiveness_NEeffectiveness
.word \jumpifeffectiveness_NEaddress
.endm

.macro isinsemiinvulnerablestate isinsemiinvulnerablestatebank @new command
.byte 0x33
.byte \isinsemiinvulnerablestatebank
.endm

.macro jumpifanypartymemberhasstatus jumpifanypartymemberhasstatusbank jumpifanypartymemberhasstatusstatus jumpifanypartymemberhasstatusaddress
.byte 0x34
.byte \jumpifanypartymemberhasstatusbank
.word \jumpifanypartymemberhasstatusstatus
.word \jumpifanypartymemberhasstatusaddress
.endm

.macro jumpifnopartymemberhasstatus jumpifnopartymemberhasstatusbank jumpifnopartymemberhasstatusstatus jumpifnopartymemberhasstatusaddress @buggy
.byte 0x35
.byte \jumpifnopartymemberhasstatusbank
.word \jumpifnopartymemberhasstatusstatus
.word \jumpifnopartymemberhasstatusaddress
.endm

.macro jumpifweather jumpifweatherflags jumpifweatherptr @rewritten
.byte 0x36
.word \jumpifweatherflags
.word \jumpifweatherptr
.endm

.macro jumpifmovescriptEQ jumpifmovescriptEQnum jumpifmovescriptEQaddress
.byte 0x37
.byte \jumpifmovescriptEQnum
.word \jumpifmovescriptEQaddress
.endm

.macro jumpifmovescriptNE jumpifmovescriptNEnum jumpifmovescriptNEaddress
.byte 0x38
.byte \jumpifmovescriptNEnum
.word \jumpifmovescriptNEaddress
.endm

.macro jumpifstatbuffLT jumpifstatbuffLTbank jumpifstatbuffLTstat jumpifstatbuffLTnum jumpifstatbuffLTaddress
.byte 0x39
.byte \jumpifstatbuffLTbank
.byte \jumpifstatbuffLTstat
.byte \jumpifstatbuffLTnum
.word \jumpifstatbuffLTaddress
.endm

.macro jumpifstatbuffGE jumpifstatbuffGEbank jumpifstatbuffGEstat jumpifstatbuffGEnum jumpifstatbuffGEaddress
.byte 0x3A
.byte \jumpifstatbuffGEbank
.byte \jumpifstatbuffGEstat
.byte \jumpifstatbuffGEnum
.word \jumpifstatbuffGEaddress
.endm

.macro jumpifstatbuffEQ jumpifstatbuffEQbank jumpifstatbuffEQstat jumpifstatbuffEQnum jumpifstatbuffEQaddress
.byte 0x3B
.byte \jumpifstatbuffEQbank
.byte \jumpifstatbuffEQstat
.byte \jumpifstatbuffEQnum
.word \jumpifstatbuffEQaddress
.endm

.macro jumpifstatbuffNE jumpifstatbuffNEbank jumpifstatbuffNEstat jumpifstatbuffNEnum jumpifstatbuffNEaddress
.byte 0x3C
.byte \jumpifstatbuffNEbank
.byte \jumpifstatbuffNEstat
.byte \jumpifstatbuffNEnum
.word \jumpifstatbuffNEaddress
.endm

.macro jumpiffatal jumpiffataladdress @rewritten
.byte 0x3D
.word \jumpiffataladdress
.endm

.macro jumpifnotfatal jumpifnotfataladdress @rewritten
.byte 0x3E
.word \jumpifnotfataladdress
.endm

.macro jumpifhasmove jumpifhasmovebank jumpifhasmovemove jumpifhasmoveaddress
.byte 0x3F
.byte \jumpifhasmovebank
.hword \jumpifhasmovemove
.word \jumpifhasmoveaddress
.endm

.macro jumpifhasnomove jumpifhasnomovebank jumpifhasnomovemove jumpifhasnomoveaddress
.byte 0x40
.byte \jumpifhasnomovebank
.hword \jumpifhasnomovemove
.word \jumpifhasnomoveaddress
.endm

.macro jumpifhasmovewithscript jumpifhasmovewithscriptbank jumpifhasmovewithscriptmovewithscript jumpifhasmovewithscriptaddress
.byte 0x41
.byte \jumpifhasmovewithscriptbank
.byte \jumpifhasmovewithscriptmovewithscript
.word \jumpifhasmovewithscriptaddress
.endm

.macro jumpifhasnomovewithscript jumpifhasnomovewithscriptbank jumpifhasnomovewithscriptmovewithscript jumpifhasnomovewithscriptaddress
.byte 0x42
.byte \jumpifhasnomovewithscriptbank
.byte \jumpifhasnomovewithscriptmovewithscript
.word \jumpifhasnomovewithscriptaddress
.endm
##################################################################################################################################################################
.macro jumpifanymovedisabled_or_encored jumpifanymovedisabled_or_encoredbank jumpifanymovedisabled_or_encoredkind jumpifanymovedisabled_or_encoredaddress
.byte 0x43
.byte \jumpifanymovedisabled_or_encoredbank
.byte \jumpifanymovedisabled_or_encoredkind
.word \jumpifanymovedisabled_or_encoredaddress
.endm

.macro if_any_move_disabled battler, ptr
jumpifanymovedisabled_or_encored \battler, 0, \ptr
.endm

.macro if_any_move_encored battler, ptr
jumpifanymovedisabled_or_encored \battler, 1, \ptr
.endm
##################################################################################################################################################################
.macro jumpifcurrmovedisabled_or_encored jumpifcurrmovedisabled_or_encoredbank jumpifcurrmovedisabled_or_encoredkind jumpifcurrmovedisabled_or_encoredaddress
.byte 0x44
.byte \jumpifcurrmovedisabled_or_encoredbank
.byte \jumpifcurrmovedisabled_or_encoredkind
.word \jumpifcurrmovedisabled_or_encoredaddress
.endm

.macro flee
.byte 0x45
.endm

.macro safarirandomjump safarirandomjumpaddress
.byte 0x46
.word \safarirandomjumpaddress
.endm

.macro pokeiswatchingcarefully
.byte 0x47
.endm

.macro getitemeffect getitemeffectbank getitemeffectNegatingEffect @rewritten
.byte 0x48
.byte \getitemeffectbank
.byte \getitemeffectNegatingEffect
.endm

.macro getgender getgenderbank
.byte 0x49
.byte \getgenderbank
.endm
###########################################################################################
.macro isfirstturnfor isfirstturnforbank
.byte 0x4A
.byte \isfirstturnforbank
.endm

.macro jumpiffirstturnfor jumpiffirstturnforbank jumpiffirstturnforaddress
isfirstturnfor \jumpiffirstturnforbank
jumpifbytevarEQ 1 \jumpiffirstturnforaddress
.endm

.macro jumpifnofirstturnfor jumpifnofirstturnforbank jumpifnofirstturnforaddress
.byte 0x4A
.byte \jumpifnofirstturnforbank
jumpifbytevarEQ 0 \jumpifnofirstturnforaddress
.endm
###########################################################################################
.macro getstockpileuses getstockpileusesbank
.byte 0x4B
.byte \getstockpileusesbank
.endm
#################################################################
.macro isdoublebattle
.byte 0x4C
.endm

.macro jumpifdoublebattle jumpifdoublebattleaddress
isdoublebattle
jumpifbytevarEQ 1 \jumpifdoublebattleaddress
.endm

.macro jumpifnotdoublebattle jumpifnotdoublebattleaddress
isdoublebattle
jumpifbytevarEQ 0 \jumpifnotdoublebattleaddress
.endm
#################################################################
.macro getusedhelditem getusedhelditembank
.byte 0x4D
.byte \getusedhelditembank
.endm

.macro getvarmovetype
.byte 0x4E
.endm

.macro getvarmovepower
.byte 0x4F
.endm

.macro getvarmovescript
.byte 0x50
.endm

.macro getprotectuses getprotectusesbank @rewritten
.byte 0x51
.byte \getprotectusesbank
.endm

.macro movehitssemiinvulnerable movehitssemiinvulnerablebank movehitssemiinvulnerablemove @new command, old slot
.byte 0x52
.byte \movehitssemiinvulnerablebank
.hword \movehitssemiinvulnerablemove
.endm

.macro getmovetarget @new command, old slot
.byte 0x53
.endm

.macro getvarmovetarget @new command, old slot
.byte 0x54
.endm

.macro isstatchangepositive @new command, old slot
.byte 0x55
.endm

.macro getstatvaluemovechanges getstatvaluemovechangesbank
.byte 0x56
.byte \getstatvaluemovechangesbank
.endm

.macro jumpifbankaffecting jumpifbankaffectingbank jumpifbankaffectingcase jumpifbankaffectingptr
.byte 0x57
.byte \jumpifbankaffectingbank
.byte \jumpifbankaffectingcase
.word \jumpifbankaffectingptr
.endm

.macro call_cmd calladdress
.byte 0x58
.word \calladdress
.endm

.macro goto_cmd goto_cmdaddress
.byte 0x59
.word \goto_cmdaddress
.endm

.macro return_cmd
.byte 0x5A
.endm

.macro end_cmd
.byte 0x5A
.endm

.macro jumpifleveldifference jumpifleveldifferencediff jumpifleveldifferenceaddress
.byte 0x5B
.byte \jumpifleveldifferencediff
.word \jumpifleveldifferenceaddress
.endm

.equ lvai_higher, 0x0
.equ lvai_lower, 0x1
.equ lvai_equal, 0x2

.macro jumpiftargettaunted jumpiftargettauntedaddress
.byte 0x5C
.word \jumpiftargettauntedaddress
.endm

.macro jumpiftargetnottaunted jumpiftargetnottauntedaddress
.byte 0x5D
.word \jumpiftargetnottauntedaddress
.endm

.macro jumpiftargetisally jumpiftargetisallyaddress
.byte 0x5E
.word \jumpiftargetisallyaddress
.endm
############################################################
.macro isoftype isoftypebank isoftyptype @rewritten
.byte 0x5F
.byte \isoftypebank
.byte \isoftyptype
.endm

.macro if_type battler, type, ptr
isoftype \battler, \type
jumpifbytevarEQ 1, \ptr
.endm

.macro if_no_type battler, type, ptr
isoftype \battler, \type
jumpifbytevarEQ 0, \ptr
.endm
###################################################################################
.macro checkability checkabilitybank checkabilityID checkabilityGastro @rewritten
.byte 0x60
.byte \checkabilitybank
.byte \checkabilityID
.byte \checkabilityGastro
.endm

.macro if_ability battler, ability, ptr
checkability \battler, \ability
jumpifbytevarEQ 1, \ptr
.endm

.macro if_no_ability battler, ability, ptr
checkability \battler, \ability
jumpifbytevarEQ 0, \ptr
.endm
###################################################################################
.macro jumpifflashfired jumpifflashfiredbank jumpifflashfiredptr
.byte 0x61
.byte \jumpifflashfiredbank
.word \jumpifflashfiredptr
.endm

.macro jumpifitem jumpifitembank jumpifitemitem jumpifitemptr
.byte 0x62
.byte \jumpifitembank
.hword \jumpifitemitem
.word \jumpifitemptr
.endm

.macro jumpiffieldaffecting jumpiffieldaffectingcase jumpiffieldaffectingptr
.byte 0x63
.byte \jumpiffieldaffectingcase
.word \jumpiffieldaffectingptr
.endm

.macro isbankinlovewith isbankinlovewithbank1 isbankinlovewithbank2
.byte 0x64
.byte \isbankinlovewithbank1
.byte \isbankinlovewithbank2
.endm

.macro vartovar2
.byte 0x65
.endm

.macro jumpifvarsEQ jumpifvarsEQptr
.byte 0x66
.word \jumpifvarsEQptr
.endm

.macro jumpifcantaddthirdtype jumpifcantaddthirdtypebank jumpifcantaddthirdtypeptr
.byte 0x67
.byte \jumpifcantaddthirdtypebank
.word \jumpifcantaddthirdtypeptr
.endm

.macro canchangeability canchangeabilitybank1 canchangeabilitybank2
.byte 0x68
.byte \canchangeabilitybank1
.byte \canchangeabilitybank2
.endm

.macro getitempocket getitempocketbank
.byte 0x69
.byte \getitempocketbank
.endm

.macro discouragehazards
.byte 0x6A
.endm

.macro sharetype sharetypebank1 sharetypebank2
.byte 0x6B
.byte \sharetypebank1
.byte \sharetypebank2
.endm

.macro isbankpresent isbankpresentbank
.byte 0x6C
.byte \isbankpresentbank
.endm

.macro jumpifwordvarEQ jumpifwordvarEQword jumpifwordvarEQptr
.byte 0x6D
.word \jumpifwordvarEQword
.word \jumpifwordvarEQptr
.endm

.macro islockon_on islockon_onbank1 islockon_onbank2
.byte 0x6E
.byte \islockon_onbank1
.byte \islockon_onbank2
.endm

.macro discouragesports
.byte 0x6F
.endm

.macro jumpifnewsideaffecting jumpifnewsideaffectingside jumpifnewsideaffectingcase jumpifnewsideaffectingptr
.byte 0x70
.byte \jumpifnewsideaffectingside
.byte \jumpifnewsideaffectingcase
.word \jumpifnewsideaffectingptr
.endm

.macro getmovesplit
.byte 0x71
.endm

.macro cantargetfaintuser cantargetfaintuserHitsNo
.byte 0x72
.byte \cantargetfaintuserHitsNo
.endm

.macro hashighcriticalratio
.byte 0x73
.endm

.macro getmoveaccuracy
.byte 0x74
.endm

.macro logiconestatuser
.byte 0x75
.endm

.macro logiconestattarget
.byte 0x76
.endm

.macro abilitypreventsescape abilitypreventsescapebank1 abilitypreventsescapebank2
.byte 0x77
.byte \abilitypreventsescapebank1
.byte \abilitypreventsescapebank2
.endm

.macro setbytevar setbytevarvalue
.byte 0x78
.byte \setbytevarvalue
.endm

.macro arehazardson arehazardsonbank
.byte 0x79
.byte \arehazardsonbank
.endm

.macro gettypeofattacker gettypeofattackerbank
.byte 0x7A
.byte \gettypeofattackerbank
.endm

.macro hasanymovewithsplit hasanymovewithsplitbank hasanymovewithsplitsplit
.byte 0x7B
.byte \hasanymovewithsplitbank
.byte \hasanymovewithsplitsplit
.endm

.macro hasprioritymove hasprioritymovebank
.byte 0x7C
.byte \hasprioritymovebank
.endm

.macro getbestdamagelefthp getbestdamagelefthpattacker getbestdamagelefthptarget
.byte 0x7D
.byte \getbestdamagelefthpattacker
.byte \getbestdamagelefthptarget
.endm

.macro isrecoilmovenecessary
.byte 0x7E
.endm

.macro isintruantturn isintruantturnbank
.byte 0x7F
.byte \isintruantturnbank
.endm

.macro getmoveeffectchance
.byte 0x80
.endm

.macro hasmovewithaccuracylower hasmovewithaccuracylowerbank hasmovewithaccuracyloweracc
.byte 0x81
.byte \hasmovewithaccuracylowerbank
.byte \hasmovewithaccuracyloweracc
.endm

.macro getpartnerchosenmove
.byte 0x82
.endm

.macro hasanydamagingmoves hasanydamagingmovesbank
.byte 0x83
.byte \hasanydamagingmovesbank
.endm

.macro jumpifcantusemove jumpifcantusemoveptr
.byte 0x84
.word \jumpifcantusemoveptr
.endm

.macro canmultiplestatwork
.byte 0x85
.endm

.macro jumpifhasattackingmovewithtype jumpifhasattackingmovewithtypebank jumpifhasattackingmovewithtypetype jumpifhasattackingmovewithtypeptr
.byte 0x86
.byte \jumpifhasattackingmovewithtypebank
.byte \jumpifhasattackingmovewithtypetype
.word \jumpifhasattackingmovewithtypeptr
.endm

.macro jumpifhasnostatusmoves jumpifhasnostatusmovesbank jumpifhasnostatusmovesptr
.byte 0x87
.byte \jumpifhasnostatusmovesbank
.word \jumpifhasnostatusmovesptr
.endm

.macro jumpifstatusmovesnotworthusing jumpifstatusmovesnotworthusingbank jumpifstatusmovesnotworthusingptr
.byte 0x88
.byte \jumpifstatusmovesnotworthusingbank
.word \jumpifstatusmovesnotworthusingptr
.endm

.macro jumpifsamestatboosts jumpifsamestatboostsbank1 jumpifsamestatboostsbank2 jumpifsamestatboostsptr
.byte 0x89
.byte \jumpifsamestatboostsbank1
.byte \jumpifsamestatboostsbank2
.word \jumpifsamestatboostsptr
.endm

.macro canusemultitargetmove
.byte 0x8A
.endm

.macro getmovetype getmovetypebank
.byte 0x8B @ Usando o próximo índice disponível (0x8B é o último na sua lista)
.byte \getmovetypebank
.endm

.macro ai_check_inverse_battle
.byte 0x8C @ ID do comando
.endm

.macro GetPerishCount Target
.byte 0x8D       @ ID do novo comando (ex: 0x8D)
.byte \Target    @ Banco do alvo (0x0 a 0x3)
.endm

.macro GetSpikesLayer Target
    .byte 0x8E       @ ID do comando GetSpikesLayer
    .byte \Target    @ Banco do alvo (ex: bank_target, bank_ai)
.endm

.macro comparehp comparehp_bank1 comparehp_bank2
.byte 0x8C
.byte \comparehp_bank1
.byte \comparehp_bank2
.endm

.macro getmoveidbyindex getmoveidbyindexbank getmoveidbyindexslot
.byte 0x8D
.byte \getmoveidbyindexbank
.byte \getmoveidbyindexslot
.endm

.macro getform getformbank
.byte 0x8E
.byte \getformbank
.endm

.macro jumpifally bank1, bank2, label
    .byte 0x8F @ substitua XX pelo opcode do comando jumpifally
    .byte \bank1
    .byte \bank2
    .hword \label
.endm

.macro arehazardson2 arehazardson2bank
.byte 0x90
.byte \arehazardson2bank
.endm

.macro hascontactmove hascontactmovebank
.byte 0x91
.byte \hascontactmovebank
.endm

.macro ishazardmove ishazardmovebank
.byte 0x92
.byte \ishazardmovebank
.endm

.macro jumpifauroraveiltimer jumpifauroraveiltimerbank jumpifauroraveiltimerptr
.byte 0x93
.byte \jumpifauroraveiltimerbank
.word \jumpifauroraveiltimerptr
.endm

.macro check_weather_faint battler
.byte 0x94 // Opcode definido na função `tai92_check_weather_faint`
.byte \battler
.endm

.macro get_wish_duration bank
.byte 0x95                    @ Identificador único para a instrução
.byte \bank                   @ Banco de onde obter a duração do Wish
.endm

.macro jumpifmoveflag moveflag address
.byte 0x96                 @ Código único para a macro
.byte \moveflag              @ Índice do bit que será verificado
.word \address           @ Endereço para pular se o bit estiver ativo
.endm

.macro comparestats bank stat1 stat2
.byte 0x97          @ Opcode da função
.byte \bank         @ Banco (bank_ai ou bank_target)
.byte \stat1        @ 1ª estatística (STAT_ATK, STAT_DEF, etc.)
.byte \stat2        @ 2ª estatística (STAT_ATK, STAT_DEF, etc.)
.endm

.macro comparestatsboth bank1 bank2 stat
.byte 0x98          @ Opcode da função
.byte \bank1        @ Primeiro banco (bank_ai ou bank_target)
.byte \bank2        @ Segundo banco (bank_ai ou bank_target)
.byte \stat         @ Estatística a ser comparada (STAT_ATK, STAT_DEF, etc.)
.endm

.macro getpredictedmove bank
.byte 0x99          @ Opcode para obter o movimento previsto
.byte \bank         @ Banco (bank_ai ou bank_target)
.endm

.macro getbankspecies bank
.byte 0x9A              @ Opcode exclusivo para o comando getbankspecies
.byte \bank              @ Banco do qual a espécie será recuperada (bank_target, bank_ai, etc.)
.endm

.macro check_party_fully_healed
.byte 0x9B
.endm

.macro checkiftrickroomisending
.byte 0x9C
.endm

.macro checkpokeweight bank
.byte 0x9D
.byte \bank
.endm

.macro jumpifwordvarNE jumpifwordvarNEword jumpifwordvarNEptr
.byte 0x9E
.word \jumpifwordvarNEword
.word \jumpifwordvarNEptr
.endm

.macro jumpifwordvarLE jumpifwordvarLEword jumpifwordvarLEptr
.byte 0x9F
.word \jumpifwordvarLEword
.word \jumpifwordvarLEptr
.endm

.macro jumpifvarsNE jumpifvarsNEptr
.byte 0xA0
.word \jumpifvarsNEptr
.endm

.macro jumpifvarsLT jumpifvarsLTptr
.byte 0xA1
.word \jumpifvarsLTptr
.endm

.macro get_consecutive_move_count bank move_id
.byte 0xA2   @ Escolhe um opcode não utilizado (e.g., 0xA2)
.byte \bank  @ Especifica o banco (e.g., bank_ai ou bank_target)
.byte \move_id  @ Especifica o ID do movimento (e.g., MOVE_FURY_CUTTER ou MOVE_ICE_BALL)
.endm

.macro jumpifwillfaint bank1, bank2, ptr
.byte 0xA3
.byte \bank1
.byte \bank2
.word \ptr
.endm

.macro gethappiness bank
.byte 0xA4
.byte \bank
.endm

.macro gyroballpowerlevel bank1 bank2
.byte 0xA5
.byte \bank1
.byte \bank2
.endm

.macro grassknotweighttier bank
.byte 0xA6
.byte \bank
.endm

.macro heavyslamweighttier bank1 bank2
.byte 0xA7 @ Substitua XX pelo opcode correspondente à função
.byte \bank1
.byte \bank2
.endm

.macro electroballpowerlevel bank1 bank2
.byte 0xA8
.byte \bank1
.byte \bank2
.endm

.macro jumpifattackboostmove bank jumpifattackboostmovePtr
.byte 0xA9
.byte \bank
.word \jumpifattackboostmovePtr
.endm

.macro jumpifmovealwayscrits jumpifmovealwayscritsBank jumpifmovealwayscritsPtr
.byte 0xAA              			@ opcode livre escolhido
.byte \jumpifmovealwayscritsBank	@ parâmetro (aqui você usará “0”)
.word \jumpifmovealwayscritsPtr		@ label para onde pular
.endm

.macro jumpifmovestatusmove bank, ptr
.byte 0xAB                   @ Opcode livre escolhido para este comando
.byte \bank                  @ Banco cujo movimento será testado
.word \ptr                   @ Para onde pular se for movimento de status
.endm

.macro isbattlergrounded bank label
.byte 0xAC
.byte \bank                  @ Banco do batalhador a ser verificado
.word \label                 @ Endereço do rótulo para salto condicional
.endm

.macro jumpifhasprioritymove jumpifhasprioritymovebank label2
.byte 0xAD
.byte \jumpifhasprioritymovebank
.word \label2 
.endm

.macro jumpifmove2 bank, move, label
.byte 0xAE
.byte \bank                     @ Carrega o banco (ex: bank_ai, bank_target)
.byte \move                     @ Carrega o ID do movimento (ex: MOVE_MAGNITUDE)
.word \label                    @ Carrega o rótulo para o salto
.endm

.macro discourage_moves_double
.byte 0x2A
.endm

.macro checklowpp bank
.byte 0xB0
.byte \bank
.endm

.macro checkstab checkstabbank
.byte 0xB1
.byte \checkstabbank
.endm
