#INCLUDE <$VER$\tmp\Blizzard1.j>
    //-----------------------------------------------------------------------
    // Commander globals
    //-----------------------------------------------------------------------

    // default values
    string language = "Chinese"  // Possible values: "" (dialog), "English", "Deutsch", "Swedish", "French", "Spanish", "Romanian", "Russian", "Portuguese", "Norwegian", "Chinese"
    string game_mode = "" // Possible values: "" (dialog), "commander", "no_human", "ai_only", "shared"
    string backlanguage = "Chinese"

    integer array command_number
    integer array command_par1
    integer array command_par2
    integer array command_par3
    string array command_key1
    string array command_key2
    string array command_key3
    string array command_text1
    string array command_text2
    string array command_text3
    string array command_text4
    string array command_dlg1
    integer array command_hotkey1
    string array command_dlg2
    integer array command_hotkey2
    string array command_dlg3
    integer array command_hotkey3
    string array command_msg
    integer command_length = 0

    string array parsed_command
    string command_prefix = "-cmd"
    string array switch_state
    string switch_on = " |cff00ff00[on]|r"
    string switch_off = " |cffff0000[off]|r"
    #INCLUDETABLE <Commands.txt> #EFR #COND "%12" eq "arr_on" or "%12" eq "arr_off"
    string array current_%4_switch
    #ENDINCLUDE

    button array cdlg_button
    integer array cdlg_number
    dialog array cdlg_dialog
    integer cdlg_length = 0

    dialog number_dialog = null
    dialog last_number_dialog = null
    dialog player_dialog = null
    dialog last_player_dialog = null
    dialog start_dialog = null
    dialog root_dialog = null
    dialog clanguage_dialog = null
    dialog tribute_type_dlg = null

    integer array current_command
    integer array current_player_par
    integer array current_number_par
    player array commanded_player

#INCLUDETABLE <$VER$\Races.txt>
    string array %1_StrategyName
    integer %1_strategyNum = 0
#ENDINCLUDE
    button strategyBtn = null
    boolean strategyDialog = false

    string array tribute_type
    button tribute_g = null
    button tribute_l = null
    button tribute_give_g = null
    button tribute_give_l = null
    dialog tribute_dlg = null

    button array tribute_dlg_button
    integer tribute_dlg_length = 0

    button array sdbn_button
    integer array sdbn_number
    integer sdbn_length = 0
    integer sdbn_paged_length = 0

    button array pcbn_button
    integer array pcbn_number
    integer pcbn_length = 0
    integer pcbn_paged_length = 0

    button array ndbn_button
    button next_button = null
    button previous_button = null
    button all_button = null
    button clanguage_button = null
    integer ndbn_length = 0
    integer ndbn_paged_length = 0

    dialog array dlg_dialog
    string array dlg_string
    integer dlg_length = 0

    integer playermax = 12
    integer playerpassive = 15

    trigger ZoomSetx = null
    trigger AdjustZoomUp = null
    trigger AdjustZoomDown = null

    trigger W3CDeny = CreateTrigger()
    trigger W3CDenyControl = CreateTrigger()

    dialog game_start_dialog = null
    trigger game_start_trigger = null
    button commander_mode = null
    button no_human_mode = null
    button shared_mode = null
    button ai_only_mode = null

    dialog language_dialog = null
    trigger language_trigger = null
#INCLUDETABLE <Languages.txt> #EFR
    button %1_button = null
#ENDINCLUDE

    string chat_no_ally = ""
    string you_no_gold = ""
    string i_no_gold = ""
    string tribute_of_gold = ""
    string gold_received_thanks = ""
    string you_no_lumber = ""
    string i_no_lumber = ""
    string tribute_of_lumber = ""
    string lumber_received_thanks = ""
    string you_mistyped_tribute = ""
    string specified_player_not_valid = ""
    string command_not_valid = ""
    string all_not_allowed = ""
    string player_id_mistyped = ""
    string color_word_mistyped = ""
    string not_specified_computer = ""
    string dlgbutton_next_page = ""
    string dlgbutton_previous_page = ""
    string dlghdr_choose_ally = ""
    string dlghdr_choose_number = ""
    string dlghdr_choose_player = ""
    string dlghdr_game_type = ""
    string dlghdr_root = ""
    string dlghdr_tribute_type = ""
    string dlghdr_tribute_amount = ""
    string dlgbutton_cancel = ""
    string dlgbutton_all = ""
    string dlgbutton_gold = ""
    string dlgbutton_lumber = ""
    string dlgbutton_give_gold = "Give Gold"
    string dlgbutton_give_lumber = "Give Lumber"
    string dlgbutton_tribute = ""
    string dlgbutton_commander = ""
    string dlgbutton_commander_language = ""
    string dlgbutton_player_ally = ""
    string dlgbutton_no_human = ""
    string dlgbutton_shared = ""
    string dlgbutton_ai_only = ""
    boolean debugging = false
    string dglchoose_language = "Choose Language"

    leaderboard color_board = null
    playercolor        PLAYER_COLOR_MAROONX             = null
    playercolor        PLAYER_COLOR_NAVYX               = null
    playercolor        PLAYER_COLOR_TURQUOISEX          = null
    playercolor        PLAYER_COLOR_VIOLETX             = null
    playercolor        PLAYER_COLOR_WHEATX              = null
    playercolor        PLAYER_COLOR_PEACHX              = null
    playercolor        PLAYER_COLOR_MINTX               = null
    playercolor        PLAYER_COLOR_LAVENDERX           = null
    playercolor        PLAYER_COLOR_COALX               = null
    playercolor        PLAYER_COLOR_SNOWX               = null
    playercolor        PLAYER_COLOR_EMERALDX            = null
    playercolor        PLAYER_COLOR_PEANUTX             = null

    //gamecache translation = InitGameCache("Commander.w3v")
    hashtable translation = InitHashtable()

    timer last_timer = null
    trigger last_player_trigger = null
    triggeraction last_player_trigger_action = null
    trigger last_number_trigger = null
    triggeraction last_number_trigger_action = null
    trigger last_dialog_trigger = null
    triggeraction last_dialog_trigger_action = null
    trigger last_main_trigger = null
    trigger array dlg_trigger
    trigger array last_tribute_trigger

#INCLUDE <$VER$\tmp\Blizzard2.j>
#INCLUDE <$VER$\tmp\Blizzard3Gen.j>
#INCLUDE <$VER$\tmp\Blizzard4.j>

function DestroyLastTrigger takes trigger t, triggeraction ta returns nothing
  if (ta != null and t != null) then
    call TriggerRemoveAction(t, ta)
  endif
  if (t != null) then
    call TriggerClearActions(t)
    call DestroyTrigger(t)
  endif
endfunction

//***************************************************************************
//*
//*  Commander
//*
//***************************************************************************

//===========================================================================
// The Parser (Takes a String, Seperates words, puts in string array)
//===========================================================================
function Parser takes string ChatMsg returns nothing
  //Required Variables
  local integer Last = 0
  local integer A = 1
  local integer I = 0
  local integer Length = StringLength(ChatMsg)

  //Pulls Words and places them each in their own Variable
  loop
    if (SubStringBJ(ChatMsg,A,A) == " ") then
      set parsed_command[I] = StringCase(SubStringBJ(ChatMsg, (Last + 1), (A - 1)), true)
      set Last = A
      set I = I + 1
    elseif (SubStringBJ(ChatMsg,A,A) == ":") then
      if (SubStringBJ(ChatMsg,A+1,A+1) == " ") then
        set A = A + 1 // space after the : so include in separator
      endif
      set parsed_command[I] = StringCase(SubStringBJ(ChatMsg, (Last + 1), (A - 1)), true)
      set Last = A
      set I = I + 1
    elseif (A == Length) then
      set parsed_command[I] = StringCase(SubStringBJ(ChatMsg, (Last + 1), A), true)
      set I = I + 1
    endif
    set A = A + 1
    exitwhen(A>Length)
  endloop
  loop
    exitwhen I > 6
    set parsed_command[I] = ""
    set I = I + 1
  endloop
endfunction

//===========================================================================
// ColorPlayer (Converts from text version of a color to a playercolor)
//===========================================================================
function ColorPlayer takes string CompC returns playercolor

  //Finds player color of the text color
  if CompC == "Red" then
    return PLAYER_COLOR_RED
  elseif CompC == "Blue" then
    return PLAYER_COLOR_BLUE
  elseif CompC == "Cyan" then
    return PLAYER_COLOR_CYAN
  elseif CompC == "Purple" then
    return PLAYER_COLOR_PURPLE
  elseif CompC == "Yellow" then
    return PLAYER_COLOR_YELLOW
  elseif CompC == "Orange" then
    return PLAYER_COLOR_ORANGE
  elseif CompC == "Green" then
    return PLAYER_COLOR_GREEN
  elseif CompC == "Pink" then
    return PLAYER_COLOR_PINK
  elseif CompC == "Light Gray" then
    return PLAYER_COLOR_LIGHT_GRAY
  elseif CompC == "Light Blue" then
    return PLAYER_COLOR_LIGHT_BLUE
  elseif CompC == "Aqua" then
    return PLAYER_COLOR_AQUA
  elseif CompC == "Brown" then
    return PLAYER_COLOR_BROWN
  elseif CompC == "MAROON" then
    return PLAYER_COLOR_MAROONX
  elseif CompC == "Navy" then
    return PLAYER_COLOR_NAVYX
  elseif CompC == "Turquoise" then
    return PLAYER_COLOR_TURQUOISEX
  elseif CompC == "Violet" then
    return PLAYER_COLOR_VIOLETX
  elseif CompC == "Wheat" then
    return PLAYER_COLOR_WHEATX
  elseif CompC == "Peach" then
    return PLAYER_COLOR_PEACHX
  elseif CompC == "Mint" then
    return PLAYER_COLOR_MINTX
  elseif CompC == "Lavender" then
    return PLAYER_COLOR_LAVENDERX
  elseif CompC == "Coal" then
    return PLAYER_COLOR_COALX
  elseif CompC == "Snow" then
    return PLAYER_COLOR_SNOWX
  elseif CompC == "Emerald" then
    return PLAYER_COLOR_EMERALDX
  elseif CompC == "Peanut" then
    return PLAYER_COLOR_PEANUTX
  endif
  return null
endfunction

//===========================================================================
// ColorText (Converts the player color to a text version)
//===========================================================================
function ColorText takes player CPlayer returns string
  //Required Variables
  local playercolor PColor = GetPlayerColor(CPlayer)  //Gets the Player's color

  //Finds the Nicer Text Version of the Player's Color
  if PColor == PLAYER_COLOR_RED then
    set PColor = null
    return "Red"
  elseif PColor == PLAYER_COLOR_BLUE then
    set PColor = null
    return "Blue"
  elseif PColor == PLAYER_COLOR_CYAN then
    set PColor = null
    return "Cyan"
  elseif PColor == PLAYER_COLOR_PURPLE then
    set PColor = null
    return "Purple"
  elseif PColor == PLAYER_COLOR_YELLOW then
    set PColor = null
    return "Yellow"
  elseif PColor == PLAYER_COLOR_ORANGE then
    set PColor = null
    return "Orange"
  elseif PColor == PLAYER_COLOR_GREEN then
    set PColor = null
    return "Green"
  elseif PColor == PLAYER_COLOR_PINK then
    set PColor = null
    return "Pink"
  elseif PColor == PLAYER_COLOR_LIGHT_GRAY then
    set PColor = null
    return "Light Gray"
  elseif PColor == PLAYER_COLOR_LIGHT_BLUE then
    set PColor = null
    return "Light Blue"
  elseif PColor == PLAYER_COLOR_AQUA then
    set PColor = null
    return "Aqua"
  elseif PColor == PLAYER_COLOR_BROWN then
    set PColor = null
    return "Brown"
  elseif PColor == PLAYER_COLOR_MAROONX then
    set PColor = null
    return "Maroon"
  elseif PColor == PLAYER_COLOR_NAVYX then
    set PColor = null
    return "Navy"
  elseif PColor == PLAYER_COLOR_TURQUOISEX then
    set PColor = null
    return "Turquoise"
  elseif PColor == PLAYER_COLOR_VIOLETX then
    set PColor = null
    return "Violet"
  elseif PColor == PLAYER_COLOR_WHEATX then
    set PColor = null
    return "Wheat"
  elseif PColor == PLAYER_COLOR_PEACHX then
    set PColor = null
    return "Peach"
  elseif PColor == PLAYER_COLOR_MINTX then
    set PColor = null
    return "Mint"
  elseif PColor == PLAYER_COLOR_LAVENDERX then
    set PColor = null
    return "Lavender"
  elseif PColor == PLAYER_COLOR_COALX then
    set PColor = null
    return "Coal"
  elseif PColor == PLAYER_COLOR_SNOWX then
    set PColor = null
    return "Snow"
  elseif PColor == PLAYER_COLOR_EMERALDX then
    set PColor = null
    return "Emerald"
  elseif PColor == PLAYER_COLOR_PEANUTX then
    set PColor = null
    return "Peanut"
  endif
  //Returns text version
  set PColor = null
  return ""
endfunction

function cs2s takes string s, playercolor c returns string
  if c == PLAYER_COLOR_RED then
    return "|CffFF0000"+s+"|r"
  elseif c == PLAYER_COLOR_BLUE then
    return "|Cff0064FF"+s+"|r"
  elseif c == PLAYER_COLOR_CYAN then
    return "|Cff1BE7BA"+s+"|r"
  elseif c == PLAYER_COLOR_PURPLE then
    return "|Cff550081"+s+"|r"
  elseif c == PLAYER_COLOR_YELLOW then
    return "|CffFFFC00"+s+"|r"
  elseif c == PLAYER_COLOR_ORANGE then
    return "|CffFF8A0D"+s+"|r"
  elseif c == PLAYER_COLOR_GREEN then
    return "|Cff21BF00"+s+"|r"
  elseif c == PLAYER_COLOR_PINK then
    return "|CffE45CAF"+s+"|r"
  elseif c == PLAYER_COLOR_LIGHT_GRAY then
    return "|Cff949696"+s+"|r"
  elseif c == PLAYER_COLOR_LIGHT_BLUE then
    return "|Cff7EBFF1"+s+"|r"
  elseif c == PLAYER_COLOR_AQUA then
    return "|Cff106247"+s+"|r"
  elseif c == PLAYER_COLOR_MAROONX then
    return "|Cff9C0000"+s+"|r"
  elseif c == PLAYER_COLOR_NAVYX then
    return "|Cff0000C3"+s+"|r"
  elseif c == PLAYER_COLOR_TURQUOISEX then
    return "|Cff00EBFF"+s+"|r"
  elseif c == PLAYER_COLOR_VIOLETX then
    return "|CffBD00FF"+s+"|r"
  elseif c == PLAYER_COLOR_WHEATX then
    return "|CffECCD87"+s+"|r"
  elseif c == PLAYER_COLOR_PEACHX then
    return "|CffF7A58B"+s+"|r"
  elseif c == PLAYER_COLOR_MINTX then
    return "|CffBFFF81"+s+"|r"
  elseif c == PLAYER_COLOR_LAVENDERX then
    return "|CffDBB9EB"+s+"|r"
  elseif c == PLAYER_COLOR_COALX then
    return "|Cff4F5055"+s+"|r"
  elseif c == PLAYER_COLOR_SNOWX then
    return "|CffECF0FF"+s+"|r"
  elseif c == PLAYER_COLOR_EMERALDX then
    return "|Cff00781E"+s+"|r"
  elseif c == PLAYER_COLOR_PEANUTX then
    return "|CffA57033"+s+"|r"
  endif
  return "|Cff4F2B05"+s+"|r"  //Brown
endfunction

function c2s takes player p returns string
  return cs2s(GetPlayerName(p), GetPlayerColor(p)) + ": "
endfunction

function DisplayToTP takes string msg returns nothing
  call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 5, msg )
endfunction

function TraceToTP takes string msg returns nothing
  if debugging then
    call DisplayToTP(msg)
  endif
endfunction

function DisplayToPlayer takes player p, string msg returns nothing
  call DisplayTimedTextToPlayer(p, 0, 0, 5, msg )
endfunction

function DisplayToAll takes string msg returns nothing
  call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 7, msg )
endfunction

function TraceToAll takes string msg returns nothing
  if debugging then
    call DisplayToAll(msg)
  endif
endfunction

function DisplayFromPlayer takes player p, string msg returns nothing
  call DisplayToTP(c2s(p) + msg)
endfunction

function DisplayFromToPlayer takes player sp, player rp, string msg returns nothing
  call DisplayToPlayer(rp, c2s(sp) + msg)
endfunction

function DisplayFromDlg takes string msg returns nothing
  if msg == "" or commanded_player[GetPlayerId(GetTriggerPlayer())] == Player(playermax) then
    return
  endif
  if GetTriggerPlayer() != null then
    if commanded_player[GetPlayerId(GetTriggerPlayer())] != null then
      call DisplayFromToPlayer(commanded_player[GetPlayerId(GetTriggerPlayer())], GetTriggerPlayer(), msg)
    else
      call DisplayToPlayer(commanded_player[GetPlayerId(GetTriggerPlayer())], msg)
    endif
  else
    call DisplayToAll(msg)
  endif
endfunction

//===========================================================================
// Sync integer
//===========================================================================
function SyncInteger takes player sync_p, integer unsynced returns integer
  local integer array source_int // the bits of the unsynced integer are stored in there
  local integer array target_int // the bits of the synced integer are stored in there
  local unit array sel_unit // the units used for the selection
  local integer i = 1
  local integer j = 0
  local integer sum = unsynced
  local group old_selection = null
  local unit u = null
  local integer bits_per_selection = 8 // that many bits are sent per selection
  local integer selection_num = 2 // that many times a selection is done
  local integer bits_number = selection_num * bits_per_selection // number of bits of integer used
  local timer t = null
  local location l = null

//  call DisplayToPlayer(sync_p, I2S(sum))

  if bj_isSinglePlayer then
    return unsynced
  endif
  set old_selection = CreateGroup()
  set t = CreateTimer()
  // separate integer in bits
  if sum < 0 then
    set source_int[0] = 1
    set sum = -sum
  else
    set source_int[0] = 0
  endif
  loop
    exitwhen i >= bits_number
    set source_int[i] = ModuloInteger(sum, 2)
    set sum = sum / 2
    set i = i + 1
  endloop

  // create units to select
  set i = 0
  set l = GetPlayerStartLocationLoc(sync_p)
  loop
    exitwhen i >= bits_per_selection
    set sel_unit[i] = CreateUnitAtLoc( sync_p, 'nshf', l, bj_UNIT_FACING )
    set i = i + 1
  endloop
  call RemoveLocation(l)
  set l = null
  // save old selection
  call SyncSelections()
  call GroupEnumUnitsSelected(old_selection, sync_p, null)

  // send the bits by selection
  set i = 0
  loop
    exitwhen i >= selection_num

    // write information
    if GetLocalPlayer() == sync_p then
      set j = 0
      call ClearSelection()
      loop
        exitwhen j >= bits_per_selection
        if source_int[i*bits_per_selection + j] == 0 then
          call SelectUnit(sel_unit[j], false)
        else
          call SelectUnit(sel_unit[j], true)
        endif
        set j = j + 1
      endloop
    endif

    // read information
    call TimerStart(t, 1, false, null)  // prevent wait bug
    loop
      exitwhen TimerGetRemaining(t) <= 0
      call TriggerSleepAction(0.5)
    endloop
    call DestroyTimer(t)
    set t = null
    call SyncSelections()
    set j = 0
    loop
      exitwhen j >= bits_per_selection
      if IsUnitSelected(sel_unit[j], sync_p) then
        set target_int[i*bits_per_selection + j] = 1
      else
        set target_int[i*bits_per_selection + j] = 0
      endif
      set j = j + 1
    endloop

    set i = i + 1
  endloop

  // restore selection
  if GetLocalPlayer() == sync_p then
    call ClearSelection()
    loop
      set u = FirstOfGroup(old_selection)
      exitwhen u == null
      call SelectUnit(u, true)
      call GroupRemoveUnit(old_selection, u)
    endloop
  endif
  call SyncSelections()

  // remove units to select
  set i = 0
  loop
    exitwhen i >= bits_per_selection
    call RemoveUnit(sel_unit[i])
    set sel_unit[i] = null
    set i = i + 1
  endloop

  // rebuild integer
  set i = bits_number - 1
  set sum = 0
  loop
    exitwhen i < 1
    set sum = 2 * sum + target_int[i]
    set i = i - 1
  endloop
  if target_int[0] != 0 then
    set sum = -sum
  endif

  call DestroyGroup(old_selection)
  set old_selection = null
  set u = null

//  call DisplayToPlayer(sync_p, I2S(sum))

  return sum

endfunction

//===========================================================================
// Convert2Player (Converts either text color or id to player)
//===========================================================================
function Convert2Player takes string Comp, boolean all_allowed returns player
  //Required Variables
  local integer j = 0
  local playercolor CColor = ColorPlayer(Comp)  //Gets the player color
  local player theplayer = null

  if Comp == "All" then
    if all_allowed then
      set theplayer = Player(playermax)
    else
      call DisplayToTP(all_not_allowed)
    endif

  elseif (CColor == null) then
   //Makes Sure color was typed Correctly
    //Makes sure number is 0 or bigger and (11 or 23) or smaller
    if (S2I(Comp) >= 0) and (S2I(Comp) < playermax) then
      set theplayer = Player(S2I(Comp))
    else
      call DisplayToTP(player_id_mistyped)
    endif
  else
  //Compares the color until we get a match then stores that player
    loop
      exitwhen((CColor == GetPlayerColor(Player(j))) or (j > playermax))
      set j = j + 1
      if (j > playermax) then
        call DisplayToTP(color_word_mistyped)
      endif
    endloop
    if j <= playermax then
      set theplayer = Player(j)
    endif
  endif

  set CColor = null

  //Returns player
  return theplayer

endfunction

//===========================================================================
// Colorboard Function (Displays all the Colors on screen)
//===========================================================================
//Required by GetPlayersMatching to select a players playing
function GetPlayersMatchingCode takes nothing returns boolean
    return ( GetPlayerSlotState(GetFilterPlayer()) == PLAYER_SLOT_STATE_PLAYING )
endfunction

//Required by ForForce to add a player name for each player
function ForForceCode takes nothing returns nothing
    call LeaderboardAddItemBJ(GetEnumPlayer(), color_board, GetPlayerName(GetEnumPlayer()), 0 )
    call LeaderboardSetPlayerItemLabelBJ(GetEnumPlayer(), color_board, ColorText(GetEnumPlayer()))
    call LeaderboardSetPlayerItemValueBJ(GetEnumPlayer(), color_board, GetPlayerId(GetEnumPlayer()))
endfunction

//The Main function for Showing the Colorboard
function CreateBoard takes nothing returns nothing
  //Required Variables
  local integer j = 0

  //Creates Colorboard
  set color_board =CreateLeaderboardBJ( GetPlayersAll(), "Colorboard" ) //Creates board
  //Adds all player to Colorboard
  call ForForce( GetPlayersMatching(Condition(function GetPlayersMatchingCode)), function ForForceCode )
  
  //Displays the Colorboard
  call LeaderboardDisplay(color_board, false)

endfunction

function ShowBoard takes nothing returns nothing
  call LeaderboardDisplay(color_board, not IsLeaderboardDisplayed(color_board))
endfunction

//===========================================================================
// W3C UNIT DENY TIP
//===========================================================================
function W3CDenyTip takes nothing returns nothing
  local unit u1 = GetDyingUnit()
  local unit u2 = GetKillingUnit()
  local player p0 = GetLocalPlayer()
  local player p1 = GetOwningPlayer(u1)
  local player p2 = GetOwningPlayer(u2)
  local real x = GetUnitX(u1)
  local real y = GetUnitY(u1)
  local texttag t = null
  local string s = cs2s("!",GetPlayerColor(p2))
  if (not (IsUnitType(u1,UNIT_TYPE_STRUCTURE) and GetUnitTypeId(u2) == 'uaco')) and GetUnitTypeId(u2) != 'otot' and GetUnitTypeId(u2) != 'usap' and not IsUnitHidden(u1) then
    if (IsPlayerAlly(p1,p2) or p1 == Player(playermax) or p2 == Player(playermax)) and p1 != Player(playerpassive) then
      if p2 == Player(playermax) then
        set s = "|cff323232"+"!"+"|r"
      endif
      set t = CreateTextTagUnitBJ(s, u1, -80, 13, 100, 100, 100, 0)
      call SetTextTagVisibility(t, (IsVisibleToPlayer(x,y,p0) and not IsFoggedToPlayer(x,y,p0) and not IsMaskedToPlayer(x,y,p0)) or IsPlayerObserver(p0))
      call SetTextTagPermanentBJ(t, false)
      call SetTextTagVelocityBJ(t, 20, 90)
      call SetTextTagLifespanBJ(t, 2)
      call SetTextTagFadepointBJ(t, 1.5)
      set t = null
    endif
  endif
  set s = null
  set u1 = null
  set u2 = null
  set p0 = null
  set p1 = null
  set p2 = null
endfunction

function SetW3CDenyTip takes nothing returns nothing
  local string t = "DenyTip |cfffd0000[off]|r"
  if GetTriggerPlayer() != null then
    if not IsTriggerEnabled(W3CDeny) then
      call EnableTrigger(W3CDeny)
      set t = "DenyTip |cff00ff00[on]|r"
    else
      call DisableTrigger(W3CDeny)
    endif
    call DisplayTimedTextToForce( GetPlayersAll(), 7.00, t)
  endif
  set t = null
endfunction

function W3CDenyTipControl takes nothing returns nothing
  local integer i = 0
  loop
    exitwhen i >= playermax
    if (GetPlayerController(Player(i)) != MAP_CONTROL_COMPUTER) then
      call TriggerRegisterPlayerChatEvent(W3CDenyControl, Player(i), "-deny", false)
    endif
    set i = i + 1
  endloop
  call TriggerAddAction( W3CDenyControl, function SetW3CDenyTip )
  call TriggerRegisterAnyUnitEventBJ( W3CDeny, EVENT_PLAYER_UNIT_DEATH )
  call TriggerAddAction( W3CDeny, function W3CDenyTip )
endfunction

//===========================================================================
// Zoom
//===========================================================================
function ZoomSet takes nothing returns nothing
  local real Zoom = 0
  if SubStringBJ(GetEventPlayerChatString(), 6, 6) != " " then
    set Zoom = S2R(SubStringBJ(GetEventPlayerChatString(), 6, 10))
  else
    set Zoom = S2R(SubStringBJ(GetEventPlayerChatString(), 7, 11))
  endif
  if Zoom < 1650 then
    call SetCameraFieldForPlayer( GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 1650, 0 )
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 7, "zoom min: |cff00ff001650|r" )
  elseif Zoom > 3000 then
    call SetCameraFieldForPlayer( GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 3000, 0 )
    call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 7, "zoom max: |cff00ff003000|r" )
  else
    call SetCameraFieldForPlayer( GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, Zoom, 0 )
  endif
endfunction

function ZoomDown takes nothing returns nothing
  local real Zoom = CameraSetupGetFieldSwap(CAMERA_FIELD_TARGET_DISTANCE, GetCurrentCameraSetup())
  if Zoom > 1650 and GetTriggerPlayer() == GetLocalPlayer() then
    call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, Zoom - 50, 0 )
  endif
endfunction

function ZoomUp takes nothing returns nothing
  local real Zoom = CameraSetupGetFieldSwap(CAMERA_FIELD_TARGET_DISTANCE, GetCurrentCameraSetup())
  if Zoom < 3000 and GetTriggerPlayer() == GetLocalPlayer() then
    call SetCameraFieldForPlayer(GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, Zoom + 50, 0 )
  endif
endfunction

function InitZoom takes nothing returns nothing
  local integer i = 0
  set ZoomSetx = CreateTrigger()
  set AdjustZoomUp = CreateTrigger()
  set AdjustZoomDown = CreateTrigger()
  call TriggerAddAction(ZoomSetx, function ZoomSet)
  call TriggerAddAction(AdjustZoomUp , function ZoomUp)
  call TriggerAddAction(AdjustZoomDown , function ZoomDown)
  loop
    exitwhen i >= playermax
    if (GetPlayerController(Player(i)) != MAP_CONTROL_COMPUTER) then
      call DisplayTimedTextToPlayer(Player(i),0,0,7,"Set Zoom type: |c00d5f038-zoom1850|r")
      call TriggerRegisterPlayerChatEvent( ZoomSetx, Player(i), "-zoom", false )
      call TriggerRegisterPlayerKeyEventBJ( AdjustZoomUp, Player(i), bj_KEYEVENTTYPE_DEPRESS, bj_KEYEVENTKEY_UP )
      call TriggerRegisterPlayerKeyEventBJ( AdjustZoomDown, Player(i), bj_KEYEVENTTYPE_DEPRESS, bj_KEYEVENTKEY_DOWN )
      if IsPlayerObserver(Player(i)) then
        call SetCameraFieldForPlayer(Player(i), CAMERA_FIELD_TARGET_DISTANCE, 1950, 0)
      endif
    endif
    set i = i + 1
  endloop
endfunction

//===========================================================================
// Help Function (Displays help on screen)
//===========================================================================
function DisplayHelpToPlayer takes player p, string msg returns nothing
  if msg == "PAUSE" then
    call TriggerSleepAction( 15.00 )
  else
    call DisplayTimedTextToPlayer(p, 0, 0, 15, msg)
  endif
endfunction

function Helpin takes nothing returns nothing
  local player p = GetTriggerPlayer()
#INCLUDETABLE <Languages\CommanderHelp.txt>
  call DisplayHelpToPlayer(p, "%1")
#ENDINCLUDE
  set p = null
endfunction

//===========================================================================
// Map Initialization (Runs all stuff needed to be run after map is loaded)
//===========================================================================
function MapInit takes nothing returns nothing

  call DestroyTimer(last_timer)

  //Displays the Leaderboard
  call CreateBoard()

  //Display Commander Message
  if false then
#INCLUDETABLE <Languages.txt> #EFR
  elseif language == "%1" then
#INCLUDETABLE <Languages\%1\CommanderStart.txt> #ENC:%4
    call DisplayToAll("|c0000ffff%1|r")
#ENDINCLUDE
#ENDINCLUDE
  endif

endfunction

//===========================================================================
// Tribute Function (Allows computer allies to give you resources)
//===========================================================================
function TributeGold takes player Commander, player Comp, integer res_amount returns nothing
  if res_amount < 0 then
    set res_amount = -res_amount
    if GetPlayerState(Commander, PLAYER_STATE_RESOURCE_GOLD) >= res_amount then
      call SetPlayerState(Comp, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Comp, PLAYER_STATE_RESOURCE_GOLD) + res_amount)
      call SetPlayerState(Commander, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Commander, PLAYER_STATE_RESOURCE_GOLD) - res_amount)
      call DisplayFromToPlayer(Comp, Commander, I2S(res_amount) + gold_received_thanks)
    //You don't have enough Gold to share
    else
      call DisplayFromToPlayer(Comp, Commander, you_no_gold)
    endif
  elseif GetPlayerState(Comp, PLAYER_STATE_RESOURCE_GOLD) >= res_amount then
    call SetPlayerState(Comp, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Comp, PLAYER_STATE_RESOURCE_GOLD) - res_amount)
    call SetPlayerState(Commander, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Commander, PLAYER_STATE_RESOURCE_GOLD) + res_amount)
    call DisplayFromToPlayer(Comp, Commander, I2S(res_amount) + tribute_of_gold)
  //I don't have enough Gold to share
  else
    call DisplayFromToPlayer(Comp, Commander, i_no_gold)
  endif
endfunction

function TributeWood takes player Commander, player Comp, integer res_amount returns nothing
  if res_amount < 0 then
    set res_amount = -res_amount
    if GetPlayerState(Commander, PLAYER_STATE_RESOURCE_LUMBER) >= res_amount then
      call SetPlayerState(Comp, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(Comp, PLAYER_STATE_RESOURCE_LUMBER) + res_amount)
      call SetPlayerState(Commander, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(Commander, PLAYER_STATE_RESOURCE_LUMBER) - res_amount)
      call DisplayFromToPlayer(Comp, Commander, I2S(res_amount) + lumber_received_thanks)
      //You don't have enough Lumber to share
    else
      call DisplayFromToPlayer(Comp, Commander, you_no_lumber)
    endif
  elseif GetPlayerState(Comp, PLAYER_STATE_RESOURCE_LUMBER) >= res_amount then
    call SetPlayerState(Comp, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(Comp, PLAYER_STATE_RESOURCE_LUMBER) - res_amount)
    call SetPlayerState(Commander, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(Commander, PLAYER_STATE_RESOURCE_LUMBER) + res_amount)
    call DisplayFromToPlayer(Comp, Commander, I2S(res_amount) + tribute_of_lumber)
    //I don't have enough Lumber to share
  else
    call DisplayFromToPlayer(Comp, Commander, i_no_lumber)
  endif

endfunction

function TributeGoldFromAll takes player Commander, integer res_amount returns nothing
  local integer i = 0
  loop
    exitwhen i >= playermax
    if IsPlayerAlly(Commander, Player(i)) and GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER then
      call TributeGold(Commander, Player(i),res_amount)
    endif
    set i = i + 1
  endloop
endfunction

function TributeWoodFromAll takes player Commander, integer res_amount returns nothing
  local integer i = 0
  loop
    exitwhen i >= playermax
    if IsPlayerAlly(Commander,Player(i)) and GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER then
      call TributeWood(Commander, Player(i),res_amount)
    endif
    set i = i + 1
  endloop
endfunction

function Tribute takes player Commander, player Comp, string LorG, string ResAmount returns nothing
  //Player wants Gold
  if (LorG == "G") or (LorG == "GiveG") or (LorG == "Gold") then
    if LorG == "GiveG" then
      set ResAmount = "-" + ResAmount
    endif
    if Comp == Player(playermax) then
      call TributeGoldFromAll(Commander, S2I(ResAmount))
    else
      call TributeGold(Commander, Comp, S2I(ResAmount))
    endif
  //Player wants Lumber
  elseif (LorG == "L") or (LorG == "GiveL") or (LorG == "Lumber") then
    if LorG == "GiveL" then
      set ResAmount = "-" + ResAmount
    endif
    if Comp == Player(playermax) then
      call TributeWoodFromAll(Commander, S2I(ResAmount))
    else
      call TributeWood(Commander, Comp, S2I(ResAmount))
    endif
  //Didn't type L or G
  else
    call DisplayToPlayer(Commander, you_mistyped_tribute)
  endif
endfunction

//===========================================================================
// Execute Command
//===========================================================================
function SetMainSwitch takes integer num returns nothing
  if switch_state[num] == switch_off then
    set switch_state[num] = switch_on
  elseif switch_state[num] == switch_on then
    set switch_state[num] = switch_off
  endif
endfunction

function SetPlayerSwitch takes integer num, integer playernum returns string
  if false then
  #INCLUDETABLE <Commands.txt> #EFR #COND "%12" eq "arr_on" or "%12" eq "arr_off"
  elseif num == %4 then
    if current_%4_switch[playernum] == switch_on then
      set current_%4_switch[playernum] = switch_off
      return switch_off
    elseif current_%4_switch[playernum] == switch_off then
      set current_%4_switch[playernum] = switch_on
      return switch_on
    endif
  #ENDINCLUDE
  endif
  return switch_state[num]
endfunction

function GetParValue takes integer par returns integer
  local player p = null
  local integer pid = -1
  if par == -1 then
    return 0
  elseif par == -30 then
    return SyncInteger(GetTriggerPlayer(), R2I(GetCameraTargetPositionX()))
  elseif par == -31 then
    return SyncInteger(GetTriggerPlayer(), R2I(GetCameraTargetPositionY()))
  elseif par == -40 then
    return GetPlayerId(GetTriggerPlayer())
  elseif par < -100 then
    set p = Convert2Player(parsed_command[-(par + 100)], false)
    if p == null then
      return -1000000
    else
      set pid = GetPlayerId(p)
      set p = null
      return pid
    endif
  elseif par < 0 then
    return S2I(parsed_command[-par])
  else
    return par
  endif
endfunction

function ExecuteCommand takes player Comp, integer number returns nothing
  local integer cn = GetParValue(command_number[number])
  local integer par1 = GetParValue(command_par1[number])
  local integer par2 = GetParValue(command_par2[number])
  local integer par3 = GetParValue(command_par3[number])
  local string s = command_msg[number] + SetPlayerSwitch(number,GetPlayerId(Comp))
  if cn == -1000000 or par1 == -1000000 or par2 == -1000000 or par3 == -1000000 then
    set s = null
    return
  endif

  if command_par2[number] != -1 then
    call CommandAI(Comp, par2, par3)
  endif
  if command_number[number] != -1 then
    call CommandAI(Comp, cn, par1)
  endif
  call DisplayFromPlayer(Comp, s)
  set s = null
endfunction

function ExecuteCommandForAll takes integer number returns nothing
  local integer i = 0
  loop
    exitwhen i >= playermax
    if (command_text1[number] == "AI Setting" or IsPlayerAlly(GetTriggerPlayer(),Player(i))) and GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER then
      call ExecuteCommand(Player(i), number)
    endif
    set i = i + 1
  endloop
endfunction

function GetDlgParValue takes integer par returns integer
  if par == -1 then
    return 0
  elseif par == -30 then
    return SyncInteger(GetTriggerPlayer(), R2I(GetCameraTargetPositionX()))
  elseif par == -31 then
    return SyncInteger(GetTriggerPlayer(), R2I(GetCameraTargetPositionY()))
  elseif par == -40 then
    return GetPlayerId(GetTriggerPlayer())
  elseif par < -100 then
    return current_player_par[GetPlayerId(GetTriggerPlayer())]
  elseif par < 0 then
    return current_number_par[GetPlayerId(GetTriggerPlayer())]
  else
    return par
  endif
endfunction

function ExecuteDlgCommand takes player Comp, integer number returns nothing
  local integer cn = GetDlgParValue(command_number[number])
  local integer par1 = GetDlgParValue(command_par1[number])
  local integer par2 = GetDlgParValue(command_par2[number])
  local integer par3 = GetDlgParValue(command_par3[number])
  local string s = command_msg[number] + SetPlayerSwitch(number,GetPlayerId(Comp))
  if command_par2[number] != -1 then
    call CommandAI(Comp, par2, par3)
  endif
  if command_number[number] != -1 then
    call CommandAI(Comp, cn, par1)
  endif
  call DisplayFromDlg(s)
  set s = null
endfunction

function ExecuteDlgCommandForAll takes integer number returns nothing
  local integer i = 0
  loop
    exitwhen i >= playermax
    if (command_text1[number] == "AI Setting" or IsPlayerAlly(GetTriggerPlayer(),Player(i))) and GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER then
      set commanded_player[GetPlayerId(GetTriggerPlayer())] = Player(i)
      call ExecuteDlgCommand(Player(i), number)
    endif
    set i = i + 1
  endloop
endfunction

function ExecuteDialogCommand takes player Comp, integer number returns nothing
  if commanded_player[GetPlayerId(GetTriggerPlayer())] == Player(playermax) then
    call SetMainSwitch(number)
    call ExecuteDlgCommandForAll(number)
  else
    call ExecuteDlgCommand(Comp, number)
  endif
endfunction

//===========================================================================
// Find Command
//===========================================================================
function FindCommand takes nothing returns integer
  local integer i = 0
  loop
    exitwhen i >= command_length
    if command_key1[i] == "" or command_key1[i] == parsed_command[2] then
      if command_key2[i] == "" or command_key2[i] == parsed_command[3] then
        exitwhen command_key3[i] == "" or command_key3[i] == parsed_command[4]
      endif
    endif
    set i = i + 1
  endloop

  if i >= command_length then
    return -1
  else
    return i
  endif

endfunction

#INCLUDETABLE <Languages.txt> #EFR
function initLanguage%1 takes nothing returns nothing
#INCLUDETABLE <Languages\%1\Commander.txt> #ENC:%4 #EFR
  set %1 = "%2"
#ENDINCLUDE
// English backup if translation missing
#INCLUDETABLE <Languages\English\Commander.txt> #ENC:%4 #EFR
  if %1 == null or %1 == "" then
    set %1 = "%2"
  endif
#ENDINCLUDE
#INCLUDETABLE <Languages\%1\CommandsTrans.txt> #ENC:%4 #EFR
  call SaveStr(translation, StringHash(language), StringHash("%1"), "%2")
#ENDINCLUDE
#INCLUDETABLE <Languages\%1\Strategy.txt> #ENC:%4 #EFR
  call SaveStr(translation, StringHash(language), StringHash("%1"), "%2")
#ENDINCLUDE
endfunction
#ENDINCLUDE

//===========================================================================
// The Commander
//===========================================================================
function AddCancelButton takes dialog d returns nothing
  call DialogAddButton(d, dlgbutton_cancel, 8) // backspace
endfunction

function AddNextButton takes dialog d returns nothing
  set next_button = DialogAddButton(d, dlgbutton_next_page, 78) // n
endfunction

function AddPreviousButton takes dialog d returns nothing
  set previous_button = DialogAddButton(d, dlgbutton_previous_page, 80) // p
endfunction

function AddCDCancelButtons takes nothing returns nothing
  local integer i = 0
  loop
    exitwhen i >= dlg_length
    call AddCancelButton(dlg_dialog[i])
    set i = i + 1
  endloop
endfunction

function RegisterCDialogButton takes button b, integer cn, dialog d returns nothing
  set cdlg_button[cdlg_length] = b
  set cdlg_number[cdlg_length] = cn
  set cdlg_dialog[cdlg_length] = d
  set cdlg_length = cdlg_length + 1
  //call DisplayToAll("RegsiterButton:" + I2S(cn) + " length:" + I2S(cdlg_length))
endfunction

function FindDialog takes string s returns dialog
  local integer i = 0
  loop
    exitwhen i >= dlg_length
    if dlg_string[i] == s then
      return dlg_dialog[i]
    endif
    set i = i + 1
  endloop
  return null
endfunction

function TributeDialogResponse takes nothing returns nothing
  local button b = GetClickedButton()
  local integer pid = GetPlayerId(GetTriggerPlayer())
  if b == tribute_g then
    set tribute_type[pid] = "G"
  elseif b == tribute_l then
    set tribute_type[pid] = "L"
  elseif b == tribute_give_g then
    set tribute_type[pid] = "GiveG"
  elseif b == tribute_give_l then
    set tribute_type[pid] = "GiveL"
  else
    set b = null
    return
  endif
  call DialogSetMessage(tribute_dlg, dlghdr_tribute_amount)
  call DialogDisplay(GetTriggerPlayer(), tribute_dlg, true)
  set b = null
endfunction

function TributeAmountDialogResponse takes nothing returns nothing
  local integer i = 0
  local button b = GetClickedButton()
  local string tribute_amount = null
  local integer pid = GetPlayerId(GetTriggerPlayer())
  loop
    if i >= tribute_dlg_length then
      set b = null
      return
    endif
    exitwhen tribute_dlg_button[i] == b
    set i = i + 1
  endloop
  set tribute_amount = I2S((i+1) * 100)
  set b = null
  call Tribute(GetTriggerPlayer(), commanded_player[pid], tribute_type[pid], tribute_amount)
endfunction

function BuildTributeDialogs takes nothing returns nothing
  local trigger t = CreateTrigger()
  local integer i = 0

  call DestroyLastTrigger(last_tribute_trigger[0], null)
  call DestroyLastTrigger(last_tribute_trigger[1], null)
  call DialogDestroy(tribute_type_dlg)
  set tribute_type_dlg = DialogCreate()
  call DialogSetMessage(tribute_type_dlg, dlghdr_tribute_type)
  set tribute_g = DialogAddButton(tribute_type_dlg, dlgbutton_gold, 71)
  set tribute_l = DialogAddButton(tribute_type_dlg, dlgbutton_lumber, 76)
  set tribute_give_g = DialogAddButton(tribute_type_dlg, dlgbutton_give_gold, 79)
  set tribute_give_l = DialogAddButton(tribute_type_dlg, dlgbutton_give_lumber, 85)
  call AddCancelButton(tribute_type_dlg)
  call TriggerRegisterDialogEvent(t, tribute_type_dlg)
  set last_tribute_trigger[0] = t
  call TriggerAddAction(t, function TributeDialogResponse)
  //call DisplayToAll("RegsiterButton:" + dlgbutton_tribute)
  call RegisterCDialogButton(DialogAddButton(root_dialog, dlgbutton_tribute, 84), 0, tribute_type_dlg)

  set tribute_dlg = DialogCreate()
  call DialogSetMessage(tribute_dlg, dlghdr_tribute_amount)
  loop
    exitwhen i >= 10
    set tribute_dlg_button[i] = DialogAddButton(tribute_dlg, I2S(100 * (i+1)), IMinBJ(48 + i, 57))
    set i = i + 1
  endloop
  call AddCancelButton(tribute_dlg)
  set tribute_dlg_length = i
  set t = CreateTrigger()
  call TriggerRegisterDialogEvent(t, tribute_dlg)
  set last_tribute_trigger[1] = t
  call TriggerAddAction(t, function TributeAmountDialogResponse)
  set t = null
endfunction

function Translation takes string s returns string
  local string translate = null
  if HaveSavedString(translation, StringHash(language), StringHash(s)) then
    //call DisplayToAll("Translated " + s + " to " + language)
    set translate = LoadStr(translation, StringHash(language), StringHash(s))
  endif
  if (translate == null or translate == "") and HaveSavedString(translation, StringHash(backlanguage), StringHash(s)) then
    //call DisplayToAll("Translated " + s + " to english FAILSAFE")
    set translate = LoadStr(translation, StringHash(backlanguage), StringHash(s))
  endif
  if (translate == null or translate == "") then
    call TraceToAll("Cannot translate:" + s + " to " + language)
    set translate = null
    return s
  else
    return translate
  endif
endfunction

function reTranslateCommands takes nothing returns nothing
  local integer i = 0
  loop
    exitwhen i >= command_length
    set command_dlg1[i] = Translation(command_text1[i])
    set command_dlg2[i] = Translation(command_text2[i])
    set command_dlg3[i] = Translation(command_text3[i])
    set command_msg[i] = Translation(command_text4[i])
    set i = i + 1
  endloop
endfunction

function CommanderLanguageResponse takes nothing returns nothing
  local button b = GetClickedButton()
  if language != backlanguage and language != "" and b != null then
    set language = backlanguage
    call initLanguageEnglish()  // After more than one language change the english backup would not be applied for any missing entries in the new language as they may be set to the old language.
  endif
  if false then
#INCLUDETABLE <Languages.txt> #EFR
  elseif b == %1_button then
    set language = "%1"
    call initLanguage%1()
#ENDINCLUDE
  endif
  call reTranslateCommands()
  set b = null
endfunction

function BuildCommanderLanguage takes nothing returns dialog
  local dialog d = DialogCreate()
  call DialogDestroy(clanguage_dialog)
  call DialogSetMessage(d, dglchoose_language)
#INCLUDETABLE <Languages.txt> #EFR
  set %1_button = DialogAddButton(d, "%1", %3)
#ENDINCLUDE
  return d
endfunction

function BuildStartDialog takes player current_player, integer startnum returns dialog
  local integer i = 0
  local integer totalplayers = 0
  local dialog d = DialogCreate()
  call DialogDestroy(start_dialog)
  call DialogSetMessage(d, dlghdr_choose_ally)
  loop
    exitwhen i >= playermax
    if GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and IsPlayerAlly(current_player, Player(i)) then
      set totalplayers = totalplayers + 1
    endif
    set i = i + 1
  endloop
  call TraceToTP("Max: " + I2S(totalplayers) + " for player: " + I2S(GetPlayerId(current_player)) + " starting page at:" + I2S(startnum))
  set sdbn_length = startnum
  if startnum <= 0 then
    set i = 0
  else
    set i = sdbn_number[sdbn_length - 1] + 1
  endif
  set all_button = DialogAddButton(d, dlgbutton_all, 65)
  set sdbn_paged_length = 0
  loop
    exitwhen sdbn_paged_length >= 7 or sdbn_length >= totalplayers
    if GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and IsPlayerAlly(current_player, Player(i)) then
      call TraceToTP("Create Button: " + I2S(sdbn_length) + " Player:" + I2S(i))
      set sdbn_button[sdbn_length] = DialogAddButton(d, cs2s(GetPlayerName(Player(i)), GetPlayerColor(Player(i))), IMinBJ(48 + i, 57))
      set sdbn_number[sdbn_length] = i
      set sdbn_length = sdbn_length + 1
      set sdbn_paged_length = sdbn_paged_length + 1
    endif
    set i = i + 1
  endloop
  call TraceToTP("sdbn length: " + I2S(sdbn_length))
  if (sdbn_length < totalplayers) then
    call AddNextButton(d)
  endif
  if (sdbn_length > 7) then
    call AddPreviousButton(d)
  endif
  set clanguage_button = DialogAddButton(d, dlgbutton_commander_language,67) // c
  call AddCancelButton(d)
  return d
endfunction

function StartDialogResponse takes nothing returns nothing
  local integer i = 0
  local button b = GetClickedButton()
  local trigger t = CreateTrigger()
  call DestroyLastTrigger(last_dialog_trigger, last_dialog_trigger_action)
  set last_dialog_trigger = null
  set last_dialog_trigger_action = null
  loop
    exitwhen sdbn_button[i] == b or i >= sdbn_length
    set i = i + 1
  endloop
  if (b == next_button) then // next page
    set start_dialog = BuildStartDialog(GetTriggerPlayer(), i)
    call TriggerRegisterDialogEvent(t, start_dialog )
    set last_dialog_trigger_action = TriggerAddAction(t, function StartDialogResponse)
    set last_dialog_trigger = t
    call DialogDisplay(GetTriggerPlayer(), start_dialog, true)
  endif
  if (b == previous_button) then // previous page
    set start_dialog = BuildStartDialog(GetTriggerPlayer(), i - sdbn_paged_length - 7)
    call TriggerRegisterDialogEvent(t, start_dialog )
    set last_dialog_trigger_action = TriggerAddAction(t, function StartDialogResponse)
    set last_dialog_trigger = t
    call DialogDisplay(GetTriggerPlayer(), start_dialog, true)
  endif
  if (b == clanguage_button) then
    set clanguage_dialog = BuildCommanderLanguage()
    set language_trigger = CreateTrigger()
    call TriggerRegisterDialogEvent(language_trigger, clanguage_dialog)
    call TriggerAddAction(language_trigger, function CommanderLanguageResponse)
    call DialogDisplay(GetTriggerPlayer(), clanguage_dialog, true)
  endif
  if (b == all_button or sdbn_button[i] == b) then
    if (sdbn_button[i] == b) then
      set commanded_player[GetPlayerId(GetTriggerPlayer())] = Player(sdbn_number[i])
    elseif (b == all_button) then
      set commanded_player[GetPlayerId(GetTriggerPlayer())] = Player(playermax)
    endif
    if commanded_player[GetPlayerId(GetTriggerPlayer())] != Player(playermax) and (not IsPlayerAlly(GetTriggerPlayer(), commanded_player[GetPlayerId(GetTriggerPlayer())])) then
      call DisplayFromDlg(chat_no_ally)
      set b = null
      set t = null
      return
    endif
    call DialogSetMessage(root_dialog, dlghdr_root)
    call DialogDisplay(GetTriggerPlayer(), root_dialog, true)
  endif
  set b = null
  set t = null
endfunction

// Builds a pageable number dialog
function BuildNumberDialog takes player p, integer startnum returns dialog
  local integer maxCount = 25  // Configure this to increase total number options to display
  local integer i = startnum
  local dialog new_dialog = DialogCreate()
  local string RaceStrategy = null
  //call DisplayToAll("STRAT Max: " + I2S(maxCount) + " for player: " + I2S(GetPlayerId(p)) + " starting page at:" + I2S(i))
  call DestroyLastTrigger(last_number_trigger, last_number_trigger_action)
  set last_number_trigger = null
  set last_number_trigger_action = null
  call DialogDestroy(last_number_dialog)
  set last_number_dialog = new_dialog
  call DialogSetMessage(new_dialog, dlghdr_choose_number)
  set ndbn_length = startnum
  set ndbn_paged_length = 0

  loop
    exitwhen i >= 9 + startnum or i >= maxCount
    if (strategyDialog) then
      if GetPlayerRace(p) == RACE_HUMAN then
        set RaceStrategy = Translation(HUMAN_StrategyName[i])
      elseif GetPlayerRace(p) == RACE_ORC then
        set RaceStrategy = Translation(ORC_StrategyName[i])
      elseif GetPlayerRace(p) == RACE_UNDEAD then
        set RaceStrategy = Translation(UNDEAD_StrategyName[i])
      elseif GetPlayerRace(p) == RACE_NIGHTELF then
        set RaceStrategy = Translation(ELF_StrategyName[i])
      endif
      if RaceStrategy != null then
        set ndbn_button[ndbn_length] = DialogAddButton(new_dialog, RaceStrategy, IMinBJ(48 + i, 57))
      else
        set ndbn_button[ndbn_length] = DialogAddButton(new_dialog, I2S(i), IMinBJ(48 + i, 57))
      endif
    else
      set ndbn_button[ndbn_length] = DialogAddButton(new_dialog, I2S(i), IMinBJ(48 + i, 57))
    endif
    set ndbn_length = ndbn_length + 1
    set ndbn_paged_length = ndbn_paged_length + 1
    set i = i + 1
  endloop
  if (i < maxCount) then
    call AddNextButton(new_dialog)
  endif
  if (i > 9) then
    call AddPreviousButton(new_dialog)
  endif
  call AddCancelButton(new_dialog)
  return new_dialog
endfunction

function BuildPlayerDialog takes player currentplayer, integer startnum returns dialog
  local integer i = 0
  local dialog new_dialog = DialogCreate()
  local integer totalplayers = 0
  local string ally = ""
  call DestroyLastTrigger(last_player_trigger, last_player_trigger_action)
  set last_player_trigger = null
  set last_player_trigger_action = null
  call DialogDestroy(last_player_dialog)
  set last_player_dialog = new_dialog
  call DialogSetMessage(new_dialog, dlghdr_choose_player)
  set pcbn_length = startnum
  set pcbn_paged_length = 0
  loop
    exitwhen i >= playermax
    if not IsPlayerObserver(Player(i)) and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
      set totalplayers = totalplayers + 1
    endif
    set i = i + 1
  endloop
  call TraceToTP("Max: " + I2S(totalplayers) + " starting page at:" + I2S(startnum))
  if startnum <= 0 then
    set i = 0
  else
    set i = pcbn_number[pcbn_length - 1] + 1 // player id we got up to
  endif
  loop
    exitwhen pcbn_paged_length >= 9 or pcbn_length >= totalplayers
    if not IsPlayerObserver(Player(i)) and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
      if (IsPlayerAlly(currentplayer, Player(i))) then
        set ally = " (" + dlgbutton_player_ally + ")"
      else
        set ally = ""
      endif
      set pcbn_button[pcbn_length] = DialogAddButton(new_dialog, cs2s(GetPlayerName(Player(i)), GetPlayerColor(Player(i))) + ally, IMinBJ(48 + i, 57))
      set pcbn_number[pcbn_length] = i
      set pcbn_length = pcbn_length + 1
      set pcbn_paged_length = pcbn_paged_length + 1
    endif
    set i = i + 1
  endloop
  call TraceToTP("pcbn length: " + I2S(sdbn_length))
  if (pcbn_length < totalplayers) then
    call AddNextButton(new_dialog)
  endif
  if (pcbn_length > 9) then
    call AddPreviousButton(new_dialog)
  endif
  call AddCancelButton(new_dialog)
  return new_dialog
endfunction

function PlayerDialogResponse takes nothing returns nothing
  local integer i = 0
  local button b = GetClickedButton()
  local trigger t = CreateTrigger()
  local dialog d

  call DestroyLastTrigger(last_player_trigger, last_player_trigger_action)
  set last_player_trigger = null
  set last_player_trigger_action = null

  loop
    exitwhen pcbn_button[i] == b or i >= pcbn_length
    set i = i + 1
  endloop
  if (b == next_button) then // next page
    set d = BuildPlayerDialog(GetTriggerPlayer(), i)
    call TriggerRegisterDialogEvent(t, d)
    set last_player_trigger_action = TriggerAddAction(t, function PlayerDialogResponse)
    set last_player_trigger = t
    call DialogDisplay(GetTriggerPlayer(), d, true)
  endif
  if (b == previous_button) then // previous page
    set d = BuildPlayerDialog(GetTriggerPlayer(), i - pcbn_paged_length - 9)
    call TriggerRegisterDialogEvent(t, d )
    set last_player_trigger_action = TriggerAddAction(t, function PlayerDialogResponse)
    set last_player_trigger = t
    call DialogDisplay(GetTriggerPlayer(), d, true)
  endif
  if (pcbn_button[i] == b) then
    set current_player_par[GetPlayerId(GetTriggerPlayer())] = pcbn_number[i]
    call ExecuteDialogCommand(commanded_player[GetPlayerId(GetTriggerPlayer())], current_command[GetPlayerId(GetTriggerPlayer())])
  endif
  set b = null
  set t = null
  set d = null
endfunction

function NumberDialogResponse takes nothing returns nothing
  local integer i = 0
  local button b = GetClickedButton()
  local trigger t = CreateTrigger()
  local dialog d
  call DestroyLastTrigger(last_number_trigger, last_number_trigger_action)
  set last_number_trigger = null
  set last_number_trigger_action = null
  loop
    exitwhen ndbn_button[i] == b or i >= ndbn_length
    set i = i + 1
  endloop
  if (b == next_button) then // next page
    set d = BuildNumberDialog(commanded_player[GetPlayerId(GetTriggerPlayer())], i)
    call TriggerRegisterDialogEvent(t, d )
    set last_number_trigger_action = TriggerAddAction(t, function NumberDialogResponse)
    set last_number_trigger = t
    call DialogDisplay(GetTriggerPlayer(), d, true)
  endif
  if (b == previous_button) then // previous page
    set d = BuildNumberDialog(commanded_player[GetPlayerId(GetTriggerPlayer())], i - ndbn_paged_length - 9)
    call TriggerRegisterDialogEvent(t, d )
    set last_number_trigger_action = TriggerAddAction(t, function NumberDialogResponse)
    set last_number_trigger = t
    call DialogDisplay(GetTriggerPlayer(), d, true)
  endif
  if (ndbn_button[i] == b) then
    call TraceToTP("Number picked: " + I2S(i))
    set current_number_par[GetPlayerId(GetTriggerPlayer())] = i
    call ExecuteDialogCommand(commanded_player[GetPlayerId(GetTriggerPlayer())], current_command[GetPlayerId(GetTriggerPlayer())])
  endif
  set b = null
  set t = null
  set d = null
endfunction

function DialogResponse takes nothing returns nothing
  local button b = GetClickedButton()
  local integer i = 0
  local dialog d = null
  local integer cn = 0
  local trigger t
  local string message = null

  call DestroyLastTrigger(last_main_trigger, null)

  loop
    if i >= cdlg_length then
      set b = null
      return
    endif
    exitwhen b == cdlg_button[i]
    set i = i + 1
  endloop

  set d = cdlg_dialog[i]
  set cn = cdlg_number[i]

  set strategyDialog = false
  if d != null then
    set current_command[GetPlayerId(GetTriggerPlayer())] = cn
    if (d == number_dialog) then
      set t = CreateTrigger()
      if (b == strategyBtn) then 
        set strategyDialog = true
      endif
      set d = BuildNumberDialog(commanded_player[GetPlayerId(GetTriggerPlayer())], 0)
      call TriggerRegisterDialogEvent(t, d )
      set last_number_trigger_action = TriggerAddAction(t, function NumberDialogResponse)
      set last_number_trigger = t
      call DialogDisplay(GetTriggerPlayer(), d, true)
    elseif (d == player_dialog) then
      set t = CreateTrigger()
      set d = BuildPlayerDialog(GetTriggerPlayer(), 0)
      call TriggerRegisterDialogEvent(t, d )
      set last_player_trigger_action = TriggerAddAction(t, function PlayerDialogResponse)
      set last_player_trigger = t
      call DialogDisplay(GetTriggerPlayer(), d, true)
    else
      if d == tribute_type_dlg then
        //call BuildTributeDialogs()
        call DialogDisplay(GetTriggerPlayer(), tribute_type_dlg, true)
      elseif message != "" then
          set i = 0
          loop
            if d == dlg_dialog[i] then
              if dlg_string[i] != null then
                set message = dlg_string[i]
              endif
            endif
            set i = i + 1
            call DestroyLastTrigger(dlg_trigger[dlg_length], null) //  clean up previous triggers
            exitwhen i >= dlg_length
          endloop
          call DialogSetMessage(d, message)
      endif
      call DialogDisplay(GetTriggerPlayer(), d, true)
    endif 
    set b = null
    set t = null
    set d = null
    return
  endif

  call ExecuteDialogCommand(commanded_player[GetPlayerId(GetTriggerPlayer())], cn)
endfunction

function RegisterDialog takes string s returns dialog
  local dialog d = DialogCreate()
  local trigger t = CreateTrigger()

  if s == "" then
    //call DisplayToAll("RegsiterDialog:" + dlghdr_root)
    call DialogSetMessage(d, dlghdr_root)
  else
    //call DisplayToAll("RegsiterDialog:" + s)
    call DialogSetMessage(d, s)
  endif
  set dlg_dialog[dlg_length] = d
  set dlg_string[dlg_length] = s
  set dlg_trigger[dlg_length] = t
  set dlg_length = dlg_length + 1
  call TriggerRegisterDialogEvent(t, d)
  call TriggerAddAction(t, function DialogResponse)
  set t = null
  return d
endfunction

function AddCommandDialog takes integer i returns nothing
  local dialog current_dialog = null
  local dialog next_dialog = null
  local boolean next_dialog_strat = false
  local string current_name = ""
  local string switch = null

  if command_dlg3[i] != "" then
    if command_dlg3[i] == "#" then
      set next_dialog = number_dialog
    elseif command_dlg2[i] == "s" then
      set next_dialog = number_dialog
      set next_dialog_strat = true
    elseif command_dlg3[i] == "e" then
      set next_dialog = player_dialog
    elseif command_dlg3[i] == "on" or command_dlg3[i] == "off" then
      set switch = switch_state[i]
    elseif command_dlg3[i] == "arr_on" or command_dlg3[i] == "arr_off" then
      // AI player person switch status , no dialog , show this will be confused with the main switch , just display the report
    else
      set current_name = command_dlg1[i]+" "+command_dlg2[i]
      set current_dialog = FindDialog(current_name)
      if current_dialog != null then
        call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg3[i], command_hotkey3[i]), i, next_dialog)
        set current_dialog = null
        set next_dialog = null
        set current_name = null
        return
      endif
      set current_dialog = RegisterDialog(current_name)
      call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg3[i], command_hotkey3[i]), i, next_dialog)
      set next_dialog = current_dialog
    endif
  endif

  if command_dlg2[i] != "" then
    if command_dlg2[i] == "#" then
      set next_dialog = number_dialog
    elseif command_dlg2[i] == "s" then
      set next_dialog = number_dialog
      set next_dialog_strat = true
    elseif command_dlg2[i] == "e" then
      set next_dialog = player_dialog
    else
      set current_name = command_dlg1[i]
      set current_dialog = FindDialog(current_name)
      if current_dialog != null then
        call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg2[i] + switch, command_hotkey2[i]), i, next_dialog)
        set current_dialog = null
        set next_dialog = null
        set current_name = null
        set switch = null
        return
      endif
      set current_dialog = RegisterDialog(current_name)
      call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg2[i], command_hotkey2[i]), i, next_dialog)
      set next_dialog = current_dialog
    endif
  endif

  if command_dlg1[i] != "" then
    set current_name = ""
    set current_dialog = FindDialog(current_name)
    if current_dialog != null then
      if next_dialog_strat then
        set strategyBtn = DialogAddButton(current_dialog, command_dlg1[i], command_hotkey1[i])
        call RegisterCDialogButton(strategyBtn, i, next_dialog)
      else
        call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg1[i], command_hotkey1[i]), i, next_dialog)
      endif
      set current_dialog = null
      set next_dialog = null
      set current_name = null
      set switch = null
      return
    endif
    set current_dialog = RegisterDialog(current_name)
    call RegisterCDialogButton(DialogAddButton(current_dialog, command_dlg1[i], command_hotkey1[i]), i, next_dialog)
  endif
  set current_dialog = null
  set next_dialog = null
  set current_name = null
  set switch = null
endfunction

function BuildCommandDialogs takes nothing returns nothing
  local integer i = 0
  loop
    exitwhen i >= command_length
    call AddCommandDialog(i)
    set i = i + 1
  endloop
  set root_dialog = FindDialog("")
endfunction

function DialogCommander takes nothing returns nothing
  local trigger t = CreateTrigger()
  set commanded_player[GetPlayerId(GetTriggerPlayer())] = null
  set start_dialog = BuildStartDialog(GetTriggerPlayer(), 0)
  call TriggerRegisterDialogEvent(t, start_dialog )
  set last_dialog_trigger_action = TriggerAddAction(t, function StartDialogResponse)
  set last_dialog_trigger = t
  call DialogDisplay(GetTriggerPlayer(), start_dialog, true)
  if (root_dialog != null) then
      //set root_dialog = RegisterDialog("")
      set cdlg_length = 0
      set dlg_length = 0
      call DialogDestroy(root_dialog)
  endif
  call BuildCommandDialogs()
  call BuildTributeDialogs()
  call AddCDCancelButtons()
  set t = null
endfunction

function SendToAllAIs takes integer cmd, integer data returns nothing
  local integer i = 0
  call SetMainSwitch(cmd)
  loop
    exitwhen i >= playermax
    if GetPlayerController(Player(i)) == MAP_CONTROL_COMPUTER then
      call CommandAI(Player(i), cmd, data)
    endif
    set i = i + 1
  endloop
endfunction

function Commander takes nothing returns nothing
  local player Comp = null
  local string ChatMsg = GetEventPlayerChatString()
  local integer cn = 0

  call Parser(ChatMsg)
  set ChatMsg = null
  call DisplayToTP("Command:" + parsed_command[1] + ":" + parsed_command[2]+ ":" + parsed_command[3] + ":" + parsed_command[4])

  if parsed_command[1] == "" then
    call DialogCommander()
    set Comp = null
    return
  endif

  if parsed_command[1] == "HELP" then
    call Helpin()
    set Comp = null
    return
  endif

  if parsed_command[1] == "BOARD" then
    call ShowBoard()
    set Comp = null
    return
  endif

  if parsed_command[1] == "DEBUG" then
    set debugging = not debugging
    call SendToAllAIs(51, 0)
    set Comp = null
    return
  endif

  set Comp = Convert2Player(parsed_command[1], true)
  if Comp == null then
    call DisplayToTP(specified_player_not_valid)
    set Comp = null
    return
  elseif Comp != Player(playermax) then
    if GetPlayerController(Comp) != MAP_CONTROL_COMPUTER then
       call DisplayToTP(not_specified_computer)
       set Comp = null
      return
    elseif not IsPlayerAlly(GetTriggerPlayer(), Comp) then
      call DisplayFromPlayer(Comp, chat_no_ally)
      set Comp = null
      return
    endif
  endif

  if parsed_command[2] == "TRIBUTE" or parsed_command[2] == "TRIB" then
    call Tribute(GetTriggerPlayer(), Comp, parsed_command[4], parsed_command[3])
    set Comp = null
    return
  endif

  set cn = FindCommand()

  if cn < 0 then
    call DisplayFromPlayer(Comp, command_not_valid)
    set Comp = null
    return
  endif

  if Comp == Player(playermax) then
    call SetMainSwitch(cn)
    call ExecuteCommandForAll(cn)
  else
    call ExecuteCommand(Comp, cn)
  endif

  set Comp = null
endfunction

function RegisterCommand takes string c_key1, string c_key2, string c_key3, integer c_number, integer c_par1, integer c_par2, integer c_par3, string c_dlg1, integer c_hk1, string c_dlg2, integer c_hk2, string c_dlg3, integer c_hk3, string c_msg returns nothing
  local integer i = 0
  set command_key1[command_length] = StringCase(c_key1, true)
  set command_key2[command_length] = StringCase(c_key2, true)
  set command_key3[command_length] = StringCase(c_key3, true)
  set command_number[command_length] = c_number
  set command_par1[command_length] = c_par1
  set command_par2[command_length] = c_par2
  set command_par3[command_length] = c_par3
  set command_text1[command_length] = c_dlg1
  set command_text2[command_length] = c_dlg2
  set command_text3[command_length] = c_dlg3
  set command_text4[command_length] = c_msg
  set command_dlg1[command_length] = Translation(c_dlg1)
  set command_hotkey1[command_length] = c_hk1
  set command_dlg2[command_length] = Translation(c_dlg2)
  set command_hotkey2[command_length] = c_hk2
  set command_dlg3[command_length] = Translation(c_dlg3)
  if c_dlg3 == "on" then
    set switch_state[command_length] = switch_on
  elseif c_dlg3 == "off" then
    set switch_state[command_length] = switch_off
  elseif c_dlg3 == "arr_on" then
    set switch_state[command_length] = switch_on
    loop
      exitwhen i >= playermax
      #INCLUDETABLE <Commands.txt> #EFR #COND "%12" eq "arr_on"
      set current_%4_switch[i] = switch_on
      #ENDINCLUDE
      set i = i + 1
    endloop
  elseif c_dlg3 == "arr_off" then
    set switch_state[command_length] = switch_off
    loop
      exitwhen i >= playermax
      #INCLUDETABLE <Commands.txt> #EFR #COND "%12" eq "arr_off"
      set current_%4_switch[i] = switch_off
      #ENDINCLUDE
      set i = i + 1
    endloop
  endif
  set command_hotkey3[command_length] = c_hk3
  set command_msg[command_length] = Translation(c_msg)
  set command_length = command_length + 1
endfunction

function RegisterCommands takes nothing returns nothing
#INCLUDETABLE <Commands.txt> #EFR
  call RegisterCommand("%1", "%2", "%3", %4, %5, %6, %7, "%8", %9, "%10", %11, "%12", %13, "%14")
#ENDINCLUDE
#INCLUDETABLE <Languages.txt> #EFR
  call RegisterCommand("LANGUAGE", "%1", "", 71, #EVAL{%row-1}, -1, -1, "AI Setting", 0, "Language", 76, "%1", %3, "%2")
#ENDINCLUDE
endfunction

function BuildDialogs takes nothing returns nothing
  set number_dialog = DialogCreate()
  set player_dialog = DialogCreate()
  set tribute_type_dlg = DialogCreate()
  call BuildCommandDialogs()
  call BuildTributeDialogs()
  call AddCDCancelButtons()
endfunction

function InitCommanderPart takes nothing returns nothing
  local integer i = 0
  local trigger commander_trigger = CreateTrigger()
  local trigger cdlg_trigger = CreateTrigger()

  loop
    exitwhen i >= playermax
    call TriggerRegisterPlayerChatEvent( commander_trigger, Player(i), command_prefix, false )
    call TriggerRegisterPlayerEvent( cdlg_trigger, Player(i), EVENT_PLAYER_END_CINEMATIC )
    set i = i + 1
  endloop
  call TriggerAddAction( commander_trigger, function Commander )
  call TriggerAddAction( cdlg_trigger, function DialogCommander )

  call RegisterCommands()
  call BuildDialogs()

  set commander_trigger = null
  set cdlg_trigger = null
endfunction

function GetNextPlayableHuman takes integer last returns integer
  local integer i = last + 1
  loop
    exitwhen i >= playermax
    if GetPlayerController(Player(i)) == MAP_CONTROL_USER and not IsPlayerObserver(Player(i)) and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
      return i
    endif
    set i = i + 1
  endloop
  return -1
endfunction

function GetFirstPlayableHuman takes nothing returns integer
  return GetNextPlayableHuman(-1)
endfunction

function GetFirstHuman takes nothing returns integer
  local integer i = 0
  loop
    exitwhen i >= playermax
    if GetPlayerController(Player(i)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
      return i
    endif
    set i = i + 1
  endloop
  set i = 0
  loop
    exitwhen i >= playermax
    if IsPlayerObserver(Player(i)) then
      return i
    endif
    set i = i + 1
  endloop
  return -1
endfunction

function CheckAllyToControl takes player p returns boolean
  local integer q = 0
  loop
    exitwhen q >= playermax
    if IsPlayerAlly(Player(q), p) and GetPlayerController(Player(q)) == MAP_CONTROL_COMPUTER then
      return true
    endif
    set q = q + 1
  endloop
  return false
endfunction

function EnumKillUnit takes nothing returns nothing
  call KillUnit(GetEnumUnit())
endfunction

function RemoveHumanUnitsAndRes takes nothing returns nothing
  local player p = GetEnumPlayer()
  local group g = null
  if GetPlayerController(p) != MAP_CONTROL_USER then
    return
  endif
  set g = CreateGroup()
  call GroupEnumUnitsOfPlayer(g, p, null)
  call ForGroup(g, function EnumKillUnit)
  call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, 0)
  call SetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER, 0)
  call DestroyGroup(g)
  set g = null
  set p = null
endfunction

//--------------------------------------------------------------------------------
function ShareWithHumans takes nothing returns nothing
  local player p = GetEnumPlayer()
  local integer i = 0
  if GetPlayerController(p) != MAP_CONTROL_USER then
    return
  endif
  loop
    exitwhen i >= playermax
    if p != Player(i) and IsPlayerAlly(Player(i), p) and GetPlayerController(Player(i)) != MAP_CONTROL_USER and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
      call SetPlayerAllianceStateBJ( Player(i), p, bj_ALLIANCE_ALLIED_ADVUNITS )
    endif
    set i = i + 1
  endloop
  set p = null
endfunction

function MapInitTimer takes nothing returns nothing
  local timer t = CreateTimer()
  set last_timer = t
  call TimerStart(t,3.0, false, function MapInit)
  set t = null
endfunction

function GameStartDefault takes nothing returns nothing
  if game_mode != "ai_only" then
    call InitCommanderPart()
    if game_mode == "no_human" or game_mode == "shared" then
      call ForForce(GetPlayersAll(), function RemoveHumanUnitsAndRes)
      if (game_mode == "shared") then
        call ForForce(GetPlayersAll(), function ShareWithHumans)
      endif
      call SendToAllAIs(53,0)
      call SendToAllAIs(54,0)
    endif
  endif
  call MapInitTimer()
endfunction

function GameStartDlgResponse takes nothing returns nothing
  local button cb = GetClickedButton()
  if cb == commander_mode then
    set game_mode = "commander"
  elseif cb == no_human_mode then
    set game_mode = "no_human"
  elseif cb == ai_only_mode then
    set game_mode = "ai_only"
  elseif cb == shared_mode then
    set game_mode = "shared"
  endif
  call GameStartDefault()
  call DialogDestroy(game_start_dialog)
  call DestroyTrigger(game_start_trigger)
  set cb = null
endfunction

//-------------------------------------------------------------------------
function GameStartDlg takes nothing returns nothing
  local integer host = GetFirstPlayableHuman()
  local integer p = host
  loop
    if p == -1 or IsPlayerObserver(Player(p)) then
      call MapInitTimer()
      return
    endif
    exitwhen CheckAllyToControl(Player(p))
    set p = GetNextPlayableHuman(p)
  endloop
  if game_mode != "" then
    call GameStartDefault()
    return
  endif
  set game_start_dialog = DialogCreate()
  call DialogSetMessage(game_start_dialog, dlghdr_game_type)
  set commander_mode = DialogAddButton(game_start_dialog, dlgbutton_commander, 67)
  set no_human_mode = DialogAddButton(game_start_dialog, dlgbutton_no_human, 79)
  set ai_only_mode = DialogAddButton(game_start_dialog, dlgbutton_ai_only, 78)
  set shared_mode = DialogAddButton(game_start_dialog, dlgbutton_shared, 80)

  set game_start_trigger = CreateTrigger()
  call TriggerRegisterDialogEvent(game_start_trigger, game_start_dialog)
  call TriggerAddAction(game_start_trigger, function GameStartDlgResponse)

  call DialogDisplay(Player(host), game_start_dialog, true)
endfunction

function SyncBackLanguage takes nothing returns nothing
  if backlanguage == null or backlanguage == "" then
#INCLUDETABLE <Languages.txt> #EFR
  elseif backlanguage == "%1" then
    call SendToAllAIs(72,#EVAL{%row-1})
#ENDINCLUDE
  endif
endfunction

function LanguageDlgResponse takes nothing returns nothing
  local button b = GetClickedButton()
  if language != "" and b != null and language != backlanguage then
    set language = backlanguage
    call SyncBackLanguage()  // After more than one language change the back language would not be applied for any missing entries in the new language as they may be set to the old language.
  endif
  if false then
#INCLUDETABLE <Languages.txt> #EFR
  elseif b == %1_button then
    set language = "%1"
    call SendToAllAIs(71,#EVAL{%row-1})
    call initLanguage%1()
#ENDINCLUDE
  endif
  call PauseAllUnitsBJ(false)
  call GameStartDlg()
  set b = null
endfunction

function LanguageDefault takes nothing returns nothing
  if false then
#INCLUDETABLE <Languages.txt> #EFR
  elseif language == "%1" then
    call SendToAllAIs(71,#EVAL{%row-1})
    call initLanguage%1()
#ENDINCLUDE
  endif
  call PauseAllUnitsBJ(false)
  call GameStartDlg()
endfunction

function SetupStrategies takes nothing returns nothing
  // Has to match same order that races.eai makes
  #SEARCHTREE Strats <$VER$\ELF\Strategy.txt> %1 %13 build_sequence_%1() #EFR
  #SEARCHLIST Strats
    set ELF_StrategyName[%row] = "%1"
  #ENDSEARCHLIST
  #SEARCHTREE Strats2 <$VER$\HUMAN\Strategy.txt> %1 %13 build_sequence_%1() #EFR
  #SEARCHLIST Strats2
    set HUMAN_StrategyName[%row] = "%1"
  #ENDSEARCHLIST
  #SEARCHTREE Strats3 <$VER$\ORC\Strategy.txt> %1 %13 build_sequence_%1() #EFR
  #SEARCHLIST Strats3
    set ORC_StrategyName[%row] = "%1"
  #ENDSEARCHLIST
  #SEARCHTREE Strats4 <$VER$\UNDEAD\Strategy.txt> %1 %13 build_sequence_%1() #EFR
  #SEARCHLIST Strats4
    set UNDEAD_StrategyName[%row] = "%1"
  #ENDSEARCHLIST
endfunction

function LanguageDlg takes nothing returns nothing
  local integer host = GetFirstHuman()
  call DestroyTimer(last_timer)
  // Need to pause computer ai and players
  call PauseAllUnitsBJ(true)
  call SetupStrategies()
  call SyncBackLanguage()
  if language != "" or host == -1 then
    call LanguageDefault()
    return
  endif
  set language_dialog = DialogCreate()
  call DialogSetMessage(language_dialog, dglchoose_language)
#INCLUDETABLE <Languages.txt> #EFR
  set %1_button = DialogAddButton(language_dialog, "%1", %3)
#ENDINCLUDE
  set language_trigger = CreateTrigger()
  call TriggerRegisterDialogEvent(language_trigger, language_dialog)
  call TriggerAddAction(language_trigger, function LanguageDlgResponse)
  call DialogDisplay(Player(host), language_dialog, true)
endfunction

function InitCommander takes nothing returns nothing
  local timer t = CreateTimer()
  set last_timer = t
  call TimerStart(t,1.0, false, function LanguageDlg)
  set t = null
endfunction

#INCLUDE <$VER$\tmp\Blizzard5.j>
    call InitCommander()
    call InitZoom()
    call W3CDenyTipControl()
#INCLUDE <$VER$\tmp\Blizzard6.j>
