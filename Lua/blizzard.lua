bj_PI = 3.14159
bj_E = 2.71828
bj_CELLWIDTH = 128.0
bj_CLIFFHEIGHT = 128.0
bj_UNIT_FACING = 270.0
bj_RADTODEG = 180.0 / bj_PI
bj_DEGTORAD = bj_PI / 180.0
bj_TEXT_DELAY_ = 20.00
bj_TEXT_DELAY_QUESTUPDATE = 20.00
bj_TEXT_DELAY_QUESTDONE = 20.00
bj_TEXT_DELAY_QUESTFAILED = 20.00
bj_TEXT_DELAY_QUESTREQUIREMENT = 20.00
bj_TEXT_DELAY_MISSIONFAILED = 20.00
bj_TEXT_DELAY_ALWAYSHINT = 12.00
bj_TEXT_DELAY_HINT = 12.00
bj_TEXT_DELAY_SECRET = 10.00
bj_TEXT_DELAY_UNITACQUIRED = 15.00
bj_TEXT_DELAY_UNITAVAILABLE = 10.00
bj_TEXT_DELAY_ITEMACQUIRED = 10.00
bj_TEXT_DELAY_WARNING = 12.00
bj_QUEUE_DELAY_QUEST = 5.00
bj_QUEUE_DELAY_HINT = 5.00
bj_QUEUE_DELAY_SECRET = 3.00
bj_HANDICAP_EASY = 60.00
bj_HANDICAP_NORMAL = 90.00
bj_HANDICAPDAMAGE_EASY = 50.00
bj_HANDICAPDAMAGE_NORMAL = 90.00
bj_HANDICAPREVIVE_NOTHARD = 50.00
bj_GAME_STARTED_THRESHOLD = 0.01
bj_WAIT_FOR_COND_MIN_INTERVAL = 0.10
bj_POLLED_WAIT_INTERVAL = 0.10
bj_POLLED_WAIT_SKIP_THRESHOLD = 2.00

-- Game constants
bj_MAX_INVENTORY = 6
bj_MAX_PLAYERS = GetBJMaxPlayers()
bj_PLAYER_NEUTRAL_VICTIM = GetBJPlayerNeutralVictim()
bj_PLAYER_NEUTRAL_EXTRA = GetBJPlayerNeutralExtra()
bj_MAX_PLAYER_SLOTS = GetBJMaxPlayerSlots()
bj_MAX_SKELETONS = 25
bj_MAX_STOCK_ITEM_SLOTS = 11
bj_MAX_STOCK_UNIT_SLOTS = 11
bj_MAX_ITEM_LEVEL = 10

-- Auto Save constants
bj_MAX_CHECKPOINTS = 5

-- Ideally these would be looked up from Units/MiscData.txt,
-- but there is currently no script functionality exposed to do that
bj_TOD_DAWN = 6.00
bj_TOD_DUSK = 18.00

-- Melee game settings:
--   - Starting Time of Day (TOD)
--   - Starting Gold
--   - Starting Lumber
--   - Starting Hero Tokens (free heroes)
--   - Max heroes allowed per player
--   - Max heroes allowed per hero type
--   - Distance from start loc to search for nearby mines
--
bj_MELEE_STARTING_TOD = 8.00
bj_MELEE_STARTING_GOLD_V0 = 750
bj_MELEE_STARTING_GOLD_V1 = 500
bj_MELEE_STARTING_LUMBER_V0 = 200
bj_MELEE_STARTING_LUMBER_V1 = 150
bj_MELEE_STARTING_HERO_TOKENS = 1
bj_MELEE_HERO_LIMIT = 3
bj_MELEE_HERO_TYPE_LIMIT = 1
bj_MELEE_MINE_SEARCH_RADIUS = 2000
bj_MELEE_CLEAR_UNITS_RADIUS = 1500
bj_MELEE_CRIPPLE_TIMEOUT = 120.00
bj_MELEE_CRIPPLE_MSG_DURATION = 20.00
bj_MELEE_MAX_TWINKED_HEROES_V0 = 3
bj_MELEE_MAX_TWINKED_HEROES_V1 = 1

-- Delay between a creep's death and the time it may drop an item.
bj_CREEP_ITEM_DELAY = 0.50

-- Timing settings for Marketplace inventories.
bj_STOCK_RESTOCK_INITIAL_DELAY = 120
bj_STOCK_RESTOCK_INTERVAL = 30
bj_STOCK_MAX_ITERATIONS = 20

-- Max events registered by a single "dest dies in region" event.
bj_MAX_DEST_IN_REGION_EVENTS = 64

-- Camera settings
bj_CAMERA_MIN_FARZ = 100
bj_CAMERA_DEFAULT_DISTANCE = 1650
bj_CAMERA_DEFAULT_FARZ = 5000
bj_CAMERA_DEFAULT_AOA = 304
bj_CAMERA_DEFAULT_FOV = 70
bj_CAMERA_DEFAULT_ROLL = 0
bj_CAMERA_DEFAULT_ROTATION = 90

-- Rescue
bj_RESCUE_PING_TIME = 2.00

-- Transmission behavior settings
bj__SOUND_DURATION = 5.00
bj_TRANSMISSION_PING_TIME = 1.00
bj_TRANSMISSION_IND_RED = 255
bj_TRANSMISSION_IND_BLUE = 255
bj_TRANSMISSION_IND_GREEN = 255
bj_TRANSMISSION_IND_ALPHA = 255
bj_TRANSMISSION_PORT_HANGTIME = 1.50

-- Cinematic mode settings
bj_CINEMODE_INTERFACEFADE = 0.50
bj_CINEMODE_ = MAP_SPEED_NORMAL

-- Cinematic mode volume levels
bj_CINEMODE_VOLUME_UNITMOVEMENT = 0.40
bj_CINEMODE_VOLUME_UNITSOUNDS = 0.00
bj_CINEMODE_VOLUME_COMBAT = 0.40
bj_CINEMODE_VOLUME_SPELLS = 0.40
bj_CINEMODE_VOLUME_UI = 0.00
bj_CINEMODE_VOLUME_MUSIC = 0.55
bj_CINEMODE_VOLUME_AMBIENTSOUNDS = 1.00
bj_CINEMODE_VOLUME_FIRE = 0.60

-- Speech mode volume levels
bj_SPEECH_VOLUME_UNITMOVEMENT = 0.25
bj_SPEECH_VOLUME_UNITSOUNDS = 0.00
bj_SPEECH_VOLUME_COMBAT = 0.25
bj_SPEECH_VOLUME_SPELLS = 0.25
bj_SPEECH_VOLUME_UI = 0.00
bj_SPEECH_VOLUME_MUSIC = 0.55
bj_SPEECH_VOLUME_AMBIENTSOUNDS = 1.00
bj_SPEECH_VOLUME_FIRE = 0.60

-- Smart pan settings
bj_SMARTPAN_TRESHOLD_PAN = 500
bj_SMARTPAN_TRESHOLD_SNAP = 3500

-- QueuedTriggerExecute settings
bj_MAX_QUEUED_TRIGGERS = 100
bj_QUEUED_TRIGGER_TIMEOUT = 180.00

-- Campaign indexing constants
bj_CAMPAIGN_INDEX_T = 0
bj_CAMPAIGN_INDEX_H = 1
bj_CAMPAIGN_INDEX_U = 2
bj_CAMPAIGN_INDEX_O = 3
bj_CAMPAIGN_INDEX_N = 4
bj_CAMPAIGN_INDEX_XN = 5
bj_CAMPAIGN_INDEX_XH = 6
bj_CAMPAIGN_INDEX_XU = 7
bj_CAMPAIGN_INDEX_XO = 8

-- Campaign offconstants (for mission indexing)
bj_CAMPAIGN_OFFSET_T = 0
bj_CAMPAIGN_OFFSET_H = 1
bj_CAMPAIGN_OFFSET_U = 2
bj_CAMPAIGN_OFFSET_O = 3
bj_CAMPAIGN_OFFSET_N = 4
bj_CAMPAIGN_OFFSET_XN = 5
bj_CAMPAIGN_OFFSET_XH = 6
bj_CAMPAIGN_OFFSET_XU = 7
bj_CAMPAIGN_OFFSET_XO = 8

-- Mission indexing constants
-- Tutorial
bj_MISSION_INDEX_T00 = bj_CAMPAIGN_OFFSET_T * 1000 + 0
bj_MISSION_INDEX_T01 = bj_CAMPAIGN_OFFSET_T * 1000 + 1
bj_MISSION_INDEX_T02 = bj_CAMPAIGN_OFFSET_T * 1000 + 2
bj_MISSION_INDEX_T03 = bj_CAMPAIGN_OFFSET_T * 1000 + 3
bj_MISSION_INDEX_T04 = bj_CAMPAIGN_OFFSET_T * 1000 + 4
-- Human
bj_MISSION_INDEX_H00 = bj_CAMPAIGN_OFFSET_H * 1000 + 0
bj_MISSION_INDEX_H01 = bj_CAMPAIGN_OFFSET_H * 1000 + 1
bj_MISSION_INDEX_H02 = bj_CAMPAIGN_OFFSET_H * 1000 + 2
bj_MISSION_INDEX_H03 = bj_CAMPAIGN_OFFSET_H * 1000 + 3
bj_MISSION_INDEX_H04 = bj_CAMPAIGN_OFFSET_H * 1000 + 4
bj_MISSION_INDEX_H05 = bj_CAMPAIGN_OFFSET_H * 1000 + 5
bj_MISSION_INDEX_H06 = bj_CAMPAIGN_OFFSET_H * 1000 + 6
bj_MISSION_INDEX_H07 = bj_CAMPAIGN_OFFSET_H * 1000 + 7
bj_MISSION_INDEX_H08 = bj_CAMPAIGN_OFFSET_H * 1000 + 8
bj_MISSION_INDEX_H09 = bj_CAMPAIGN_OFFSET_H * 1000 + 9
bj_MISSION_INDEX_H10 = bj_CAMPAIGN_OFFSET_H * 1000 + 10
bj_MISSION_INDEX_H11 = bj_CAMPAIGN_OFFSET_H * 1000 + 11
-- Undead
bj_MISSION_INDEX_U00 = bj_CAMPAIGN_OFFSET_U * 1000 + 0
bj_MISSION_INDEX_U01 = bj_CAMPAIGN_OFFSET_U * 1000 + 1
bj_MISSION_INDEX_U02 = bj_CAMPAIGN_OFFSET_U * 1000 + 2
bj_MISSION_INDEX_U03 = bj_CAMPAIGN_OFFSET_U * 1000 + 3
bj_MISSION_INDEX_U05 = bj_CAMPAIGN_OFFSET_U * 1000 + 4
bj_MISSION_INDEX_U07 = bj_CAMPAIGN_OFFSET_U * 1000 + 5
bj_MISSION_INDEX_U08 = bj_CAMPAIGN_OFFSET_U * 1000 + 6
bj_MISSION_INDEX_U09 = bj_CAMPAIGN_OFFSET_U * 1000 + 7
bj_MISSION_INDEX_U10 = bj_CAMPAIGN_OFFSET_U * 1000 + 8
bj_MISSION_INDEX_U11 = bj_CAMPAIGN_OFFSET_U * 1000 + 9
-- Orc
bj_MISSION_INDEX_O00 = bj_CAMPAIGN_OFFSET_O * 1000 + 0
bj_MISSION_INDEX_O01 = bj_CAMPAIGN_OFFSET_O * 1000 + 1
bj_MISSION_INDEX_O02 = bj_CAMPAIGN_OFFSET_O * 1000 + 2
bj_MISSION_INDEX_O03 = bj_CAMPAIGN_OFFSET_O * 1000 + 3
bj_MISSION_INDEX_O04 = bj_CAMPAIGN_OFFSET_O * 1000 + 4
bj_MISSION_INDEX_O05 = bj_CAMPAIGN_OFFSET_O * 1000 + 5
bj_MISSION_INDEX_O06 = bj_CAMPAIGN_OFFSET_O * 1000 + 6
bj_MISSION_INDEX_O07 = bj_CAMPAIGN_OFFSET_O * 1000 + 7
bj_MISSION_INDEX_O08 = bj_CAMPAIGN_OFFSET_O * 1000 + 8
bj_MISSION_INDEX_O09 = bj_CAMPAIGN_OFFSET_O * 1000 + 9
bj_MISSION_INDEX_O10 = bj_CAMPAIGN_OFFSET_O * 1000 + 10
-- Night Elf
bj_MISSION_INDEX_N00 = bj_CAMPAIGN_OFFSET_N * 1000 + 0
bj_MISSION_INDEX_N01 = bj_CAMPAIGN_OFFSET_N * 1000 + 1
bj_MISSION_INDEX_N02 = bj_CAMPAIGN_OFFSET_N * 1000 + 2
bj_MISSION_INDEX_N03 = bj_CAMPAIGN_OFFSET_N * 1000 + 3
bj_MISSION_INDEX_N04 = bj_CAMPAIGN_OFFSET_N * 1000 + 4
bj_MISSION_INDEX_N05 = bj_CAMPAIGN_OFFSET_N * 1000 + 5
bj_MISSION_INDEX_N06 = bj_CAMPAIGN_OFFSET_N * 1000 + 6
bj_MISSION_INDEX_N07 = bj_CAMPAIGN_OFFSET_N * 1000 + 7
bj_MISSION_INDEX_N08 = bj_CAMPAIGN_OFFSET_N * 1000 + 8
bj_MISSION_INDEX_N09 = bj_CAMPAIGN_OFFSET_N * 1000 + 9
-- Expansion Night Elf
bj_MISSION_INDEX_XN00 = bj_CAMPAIGN_OFFSET_XN * 1000 + 0
bj_MISSION_INDEX_XN01 = bj_CAMPAIGN_OFFSET_XN * 1000 + 1
bj_MISSION_INDEX_XN02 = bj_CAMPAIGN_OFFSET_XN * 1000 + 2
bj_MISSION_INDEX_XN03 = bj_CAMPAIGN_OFFSET_XN * 1000 + 3
bj_MISSION_INDEX_XN04 = bj_CAMPAIGN_OFFSET_XN * 1000 + 4
bj_MISSION_INDEX_XN05 = bj_CAMPAIGN_OFFSET_XN * 1000 + 5
bj_MISSION_INDEX_XN06 = bj_CAMPAIGN_OFFSET_XN * 1000 + 6
bj_MISSION_INDEX_XN07 = bj_CAMPAIGN_OFFSET_XN * 1000 + 7
bj_MISSION_INDEX_XN08 = bj_CAMPAIGN_OFFSET_XN * 1000 + 8
bj_MISSION_INDEX_XN09 = bj_CAMPAIGN_OFFSET_XN * 1000 + 9
bj_MISSION_INDEX_XN10 = bj_CAMPAIGN_OFFSET_XN * 1000 + 10
-- Expansion Human
bj_MISSION_INDEX_XH00 = bj_CAMPAIGN_OFFSET_XH * 1000 + 0
bj_MISSION_INDEX_XH01 = bj_CAMPAIGN_OFFSET_XH * 1000 + 1
bj_MISSION_INDEX_XH02 = bj_CAMPAIGN_OFFSET_XH * 1000 + 2
bj_MISSION_INDEX_XH03 = bj_CAMPAIGN_OFFSET_XH * 1000 + 3
bj_MISSION_INDEX_XH04 = bj_CAMPAIGN_OFFSET_XH * 1000 + 4
bj_MISSION_INDEX_XH05 = bj_CAMPAIGN_OFFSET_XH * 1000 + 5
bj_MISSION_INDEX_XH06 = bj_CAMPAIGN_OFFSET_XH * 1000 + 6
bj_MISSION_INDEX_XH07 = bj_CAMPAIGN_OFFSET_XH * 1000 + 7
bj_MISSION_INDEX_XH08 = bj_CAMPAIGN_OFFSET_XH * 1000 + 8
bj_MISSION_INDEX_XH09 = bj_CAMPAIGN_OFFSET_XH * 1000 + 9
-- Expansion Undead
bj_MISSION_INDEX_XU00 = bj_CAMPAIGN_OFFSET_XU * 1000 + 0
bj_MISSION_INDEX_XU01 = bj_CAMPAIGN_OFFSET_XU * 1000 + 1
bj_MISSION_INDEX_XU02 = bj_CAMPAIGN_OFFSET_XU * 1000 + 2
bj_MISSION_INDEX_XU03 = bj_CAMPAIGN_OFFSET_XU * 1000 + 3
bj_MISSION_INDEX_XU04 = bj_CAMPAIGN_OFFSET_XU * 1000 + 4
bj_MISSION_INDEX_XU05 = bj_CAMPAIGN_OFFSET_XU * 1000 + 5
bj_MISSION_INDEX_XU06 = bj_CAMPAIGN_OFFSET_XU * 1000 + 6
bj_MISSION_INDEX_XU07 = bj_CAMPAIGN_OFFSET_XU * 1000 + 7
bj_MISSION_INDEX_XU08 = bj_CAMPAIGN_OFFSET_XU * 1000 + 8
bj_MISSION_INDEX_XU09 = bj_CAMPAIGN_OFFSET_XU * 1000 + 9
bj_MISSION_INDEX_XU10 = bj_CAMPAIGN_OFFSET_XU * 1000 + 10
bj_MISSION_INDEX_XU11 = bj_CAMPAIGN_OFFSET_XU * 1000 + 11
bj_MISSION_INDEX_XU12 = bj_CAMPAIGN_OFFSET_XU * 1000 + 12
bj_MISSION_INDEX_XU13 = bj_CAMPAIGN_OFFSET_XU * 1000 + 13

-- Expansion Orc
bj_MISSION_INDEX_XO00 = bj_CAMPAIGN_OFFSET_XO * 1000 + 0
bj_MISSION_INDEX_XO01 = bj_CAMPAIGN_OFFSET_XO * 1000 + 1
bj_MISSION_INDEX_XO02 = bj_CAMPAIGN_OFFSET_XO * 1000 + 2
bj_MISSION_INDEX_XO03 = bj_CAMPAIGN_OFFSET_XO * 1000 + 3

-- Cinematic indexing constants
bj_CINEMATICINDEX_TOP = 0
bj_CINEMATICINDEX_HOP = 1
bj_CINEMATICINDEX_HED = 2
bj_CINEMATICINDEX_OOP = 3
bj_CINEMATICINDEX_OED = 4
bj_CINEMATICINDEX_UOP = 5
bj_CINEMATICINDEX_UED = 6
bj_CINEMATICINDEX_NOP = 7
bj_CINEMATICINDEX_NED = 8
bj_CINEMATICINDEX_XOP = 9
bj_CINEMATICINDEX_XED = 10

-- Alliance settings
bj_ALLIANCE_UNALLIED = 0
bj_ALLIANCE_UNALLIED_VISION = 1
bj_ALLIANCE_ALLIED = 2
bj_ALLIANCE_ALLIED_VISION = 3
bj_ALLIANCE_ALLIED_UNITS = 4
bj_ALLIANCE_ALLIED_ADVUNITS = 5
bj_ALLIANCE_NEUTRAL = 6
bj_ALLIANCE_NEUTRAL_VISION = 7

-- Keyboard Event Types
bj_KEYEVENTTYPE_DEPRESS = 0
bj_KEYEVENTTYPE_RELEASE = 1

-- Keyboard Event Keys
bj_KEYEVENTKEY_LEFT = 0
bj_KEYEVENTKEY_RIGHT = 1
bj_KEYEVENTKEY_DOWN = 2
bj_KEYEVENTKEY_UP = 3

-- Mouse Event Types
bj_MOUSEEVENTTYPE_DOWN = 0
bj_MOUSEEVENTTYPE_UP = 1
bj_MOUSEEVENTTYPE_MOVE = 2

-- Transmission timing methods
bj_TIMETYPE_ADD = 0
bj_TIMETYPE_ = 1
bj_TIMETYPE_SUB = 2

-- Camera bounds adjustment methods
bj_CAMERABOUNDS_ADJUST_ADD = 0
bj_CAMERABOUNDS_ADJUST_SUB = 1

-- Quest creation states
bj_QUESTTYPE_REQ_DISCOVERED = 0
bj_QUESTTYPE_REQ_UNDISCOVERED = 1
bj_QUESTTYPE_OPT_DISCOVERED = 2
bj_QUESTTYPE_OPT_UNDISCOVERED = 3

-- Quest message types
bj_QUESTMESSAGE_DISCOVERED = 0
bj_QUESTMESSAGE_UPDATED = 1
bj_QUESTMESSAGE_COMPLETED = 2
bj_QUESTMESSAGE_FAILED = 3
bj_QUESTMESSAGE_REQUIREMENT = 4
bj_QUESTMESSAGE_MISSIONFAILED = 5
bj_QUESTMESSAGE_ALWAYSHINT = 6
bj_QUESTMESSAGE_HINT = 7
bj_QUESTMESSAGE_SECRET = 8
bj_QUESTMESSAGE_UNITACQUIRED = 9
bj_QUESTMESSAGE_UNITAVAILABLE = 10
bj_QUESTMESSAGE_ITEMACQUIRED = 11
bj_QUESTMESSAGE_WARNING = 12

-- Leaderboard sorting methods
bj_SORTTYPE_SORTBYVALUE = 0
bj_SORTTYPE_SORTBYPLAYER = 1
bj_SORTTYPE_SORTBYLABEL = 2

-- Cinematic fade filter methods
bj_CINEFADETYPE_FADEIN = 0
bj_CINEFADETYPE_FADEOUT = 1
bj_CINEFADETYPE_FADEOUTIN = 2

-- Buff removal methods
bj_REMOVEBUFFS_POSITIVE = 0
bj_REMOVEBUFFS_NEGATIVE = 1
bj_REMOVEBUFFS_ALL = 2
bj_REMOVEBUFFS_NONTLIFE = 3

-- Buff properties - polarity
bj_BUFF_POLARITY_POSITIVE = 0
bj_BUFF_POLARITY_NEGATIVE = 1
bj_BUFF_POLARITY_EITHER = 2

-- Buff properties - resist type
bj_BUFF_RESIST_MAGIC = 0
bj_BUFF_RESIST_PHYSICAL = 1
bj_BUFF_RESIST_EITHER = 2
bj_BUFF_RESIST_BOTH = 3

-- Hero stats
bj_HEROSTAT_STR = 0
bj_HEROSTAT_AGI = 1
bj_HEROSTAT_INT = 2

-- Hero skill point modification methods
bj_MODIFYMETHOD_ADD = 0
bj_MODIFYMETHOD_SUB = 1
bj_MODIFYMETHOD_ = 2

-- Unit state adjustment methods (for replaced units)
bj_UNIT_STATE_METHOD_ABSOLUTE = 0
bj_UNIT_STATE_METHOD_RELATIVE = 1
bj_UNIT_STATE_METHOD_DEFAULTS = 2
bj_UNIT_STATE_METHOD_MAXIMUM = 3

-- Gate operations
bj_GATEOPERATION_CLOSE = 0
bj_GATEOPERATION_OPEN = 1
bj_GATEOPERATION_DESTROY = 2

-- Game cache value types
bj_GAMECACHE_ = 0
bj_GAMECACHE_ = 1
bj_GAMECACHE_ = 2
bj_GAMECACHE_ = 3
bj_GAMECACHE_ = 4

-- Hashtable value types
bj_HASHTABLE_ = 0
bj_HASHTABLE_ = 1
bj_HASHTABLE_ = 2
bj_HASHTABLE_ = 3
bj_HASHTABLE_HANDLE = 4

-- Item status types
bj_ITEM_STATUS_HIDDEN = 0
bj_ITEM_STATUS_OWNED = 1
bj_ITEM_STATUS_INVULNERABLE = 2
bj_ITEM_STATUS_POWERUP = 3
bj_ITEM_STATUS_SELLABLE = 4
bj_ITEM_STATUS_PAWNABLE = 5

-- Itemcode status types
bj_ITEMCODE_STATUS_POWERUP = 0
bj_ITEMCODE_STATUS_SELLABLE = 1
bj_ITEMCODE_STATUS_PAWNABLE = 2

-- Minimap ping styles
bj_MINIMAPPINGSTYLE_SIMPLE = 0
bj_MINIMAPPINGSTYLE_FLASHY = 1
bj_MINIMAPPINGSTYLE_ATTACK = 2

-- Campaign Minimap icon styles
bj_CAMPPINGSTYLE_PRIMARY = 0
bj_CAMPPINGSTYLE_PRIMARY_GREEN = 1
bj_CAMPPINGSTYLE_PRIMARY_RED = 2
bj_CAMPPINGSTYLE_BONUS = 3
bj_CAMPPINGSTYLE_TURNIN = 4
bj_CAMPPINGSTYLE_BOSS = 5
bj_CAMPPINGSTYLE_CONTROL_ALLY = 6
bj_CAMPPINGSTYLE_CONTROL_NEUTRAL = 7
bj_CAMPPINGSTYLE_CONTROL_ENEMY = 8

-- Corpse creation settings
bj_CORPSE_MAX_DEATH_TIME = 8.00

-- Corpse creation styles
bj_CORPSETYPE_FLESH = 0
bj_CORPSETYPE_BONE = 1

-- Elevator pathing-blocker destructable code
bj_ELEVATOR_BLOCKER_CODE = 'DTep'
bj_ELEVATOR_CODE01 = 'DTrf'
bj_ELEVATOR_CODE02 = 'DTrx'

-- Elevator wall codes
bj_ELEVATOR_WALL_TYPE_ALL = 0
bj_ELEVATOR_WALL_TYPE_EAST = 1
bj_ELEVATOR_WALL_TYPE_NORTH = 2
bj_ELEVATOR_WALL_TYPE_SOUTH = 3
bj_ELEVATOR_WALL_TYPE_WEST = 4

-------------------------------------------------------------------------
-- Variables
--

-- Force predefs
bj_FORCE_ALL_PLAYERS = nil
bj_FORCE_PLAYER = {}

bj_MELEE_MAX_TWINKED_HEROES = 0

-- Map area rects
bj_mapInitialPlayableArea = nil
bj_mapInitialCameraBounds = nil

-- Utility function vars
bj_forLoopAIndex = 0
bj_forLoopBIndex = 0
bj_forLoopAIndexEnd = 0
bj_forLoopBIndexEnd = 0

bj_slotControlReady = false
bj_slotControlUsed = {}
bj_slotControl = {}

-- Game started detection vars
bj_gameStartedTimer = nil
bj_gameStarted = false
bj_volumeGroupsTimer = CreateTimer()

-- Singleplayer check
bj_isSinglePlayer = false

-- Day/Night Cycle vars
bj_dncSoundsDay = nil
bj_dncSoundsNight = nil
bj_dayAmbientSound = nil
bj_nightAmbientSound = nil
bj_dncSoundsDawn = nil
bj_dncSoundsDusk = nil
bj_dawn = nil
bj_dusk = nil
bj_useDawnDuskSounds = true
bj_dncIsDaytime = false

-- Triggered sounds
--bj_pingMinimapSound         = nil
bj_rescue = nil
bj_questDiscoveredSound = nil
bj_questUpdatedSound = nil
bj_questCompletedSound = nil
bj_questFailedSound = nil
bj_questHintSound = nil
bj_questSecretSound = nil
bj_questItemAcquiredSound = nil
bj_questWarningSound = nil
bj_victoryDialogSound = nil
bj_defeatDialogSound = nil

-- Marketplace vars
bj_stockItemPurchased = nil
bj_stockUpdateTimer = nil
bj_stockAllowedPermanent = {}
bj_stockAllowedCharged = {}
bj_stockAllowedArtifact = {}
bj_stockPickedItemLevel = 0
bj_stockPickedItemType = {}

-- Melee vars
bj_meleeVisibilityTrained = nil
bj_meleeVisibilityIsDay = true
bj_meleeGrantHeroItems = false
bj_meleeNearestMineToLoc = nil
bj_meleeNearestMine = nil
bj_meleeNearestMineDist = 0.00
bj_meleeGameOver = false
bj_meleeDefeated = {}
bj_meleeVictoried = {}
bj_ghoul = {}
bj_crippledTimer = {}
bj_crippledTimerWindows = {}
bj_playerIsCrippled = {}
bj_playerIsExposed = {}
bj_finishSoonAllExposed = false
bj_finishSoonTimerDialog = nil
bj_meleeTwinkedHeroes = {}

-- Rescue behavior vars
bj_rescueUnitBehavior = nil
bj_rescueChangeColorUnit = true
bj_rescueChangeColorBldg = true

-- Transmission vars
bj_cineSceneEndingTimer = nil
bj_cineSceneLastSound = nil
bj_cineSceneBeingSkipped = nil

-- Cinematic mode vars
bj_cineModePriorSpeed = MAP_SPEED_NORMAL
bj_cineModePriorFogSetting = false
bj_cineModePriorMaskSetting = false
bj_cineModeAlreadyIn = false
bj_cineModePriorDawnDusk = false
bj_cineModeSavedSeed = 0

-- Cinematic fade vars
bj_cineFadeFinishTimer = nil
bj_cineFadeContinueTimer = nil
bj_cineFadeContinueRed = 0
bj_cineFadeContinueGreen = 0
bj_cineFadeContinueBlue = 0
bj_cineFadeContinueTrans = 0
bj_cineFadeContinueDuration = 0
bj_cineFadeContinueTex = ""

-- QueuedTriggerExecute vars
bj_queuedExecTotal = 0
bj_queuedExecTriggers = {}
bj_queuedExecUseConds = {}
bj_queuedExecTimeoutTimer = CreateTimer()
bj_queuedExecTimeout = nil

-- Helper vars (for Filter and Enum funcs)
bj_destInRegionDiesCount = 0
bj_destInRegionDiesTrig = nil
bj_groupCountUnits = 0
bj_forceCountPlayers = 0
bj_groupEnumTypeId = 0
bj_groupEnumOwningPlayer = nil
bj_groupAddGroupDest = nil
bj_groupRemoveGroupDest = nil
bj_groupRandomConsidered = 0
bj_groupRandomCurrentPick = nil
bj_groupLastCreatedDest = nil
bj_randomSubGroupGroup = nil
bj_randomSubGroupWant = 0
bj_randomSubGroupTotal = 0
bj_randomSubGroupChance = 0
bj_destRandomConsidered = 0
bj_destRandomCurrentPick = nil
bj_elevatorWallBlocker = nil
bj_elevatorNeighbor = nil
bj_itemRandomConsidered = 0
bj_itemRandomCurrentPick = nil
bj_forceRandomConsidered = 0
bj_forceRandomCurrentPick = nil
bj_makeUnitRescuableUnit = nil
bj_makeUnitRescuableFlag = true
bj_pauseAllUnitsFlag = true
bj_enumDestructableCenter = nil
bj_enumDestructableRadius = 0
bj_setPlayerTargetColor = nil
bj_isUnitGroupDeadResult = true
bj_isUnitGroupEmptyResult = true
bj_isUnitGroupInRectResult = true
bj_isUnitGroupInRectRect = nil
bj_changeLevelShowScores = false
bj_changeLevelMapName = nil
bj_suspendDecayFleshGroup = CreateGroup()
bj_suspendDecayBoneGroup = CreateGroup()
bj_delayedSuspendDecayTimer = CreateTimer()
bj_delayedSuspendDecayTrig = nil
bj_livingPlayerUnitsTypeId = 0
bj_lastDyingWidget = nil

-- Random distribution vars
bj_randDistCount = 0
bj_randDistID = {}
bj_randDistChance = {}

-- Last X'd vars
bj_lastCreatedUnit = nil
bj_lastCreatedItem = nil
bj_lastRemovedItem = nil
bj_lastHauntedGoldMine = nil
bj_lastCreatedDestructable = nil
bj_lastCreatedGroup = CreateGroup()
bj_lastCreatedFogModifier = nil
bj_lastCreatedEffect = nil
bj_lastCreatedWeatherEffect = nil
bj_lastCreated = nil
bj_lastCreatedQuest = nil
bj_lastCreatedQuestItem = nil
bj_lastCreatedDefeatCondition = nil
bj_lastStartedTimer = CreateTimer()
bj_lastCreatedTimerDialog = nil
bj_lastCreatedLeaderboard = nil
bj_lastCreatedMultiboard = nil
bj_lastPlayedSound = nil
bj_lastPlayedMusic = ""
bj_lastTransmissionDuration = 0
bj_lastCreatedGameCache = nil
bj_lastCreatedHashtable = nil
bj_lastLoadedUnit = nil
bj_lastCreatedButton = nil
bj_lastReplacedUnit = nil
bj_lastCreatedTextTag = nil
bj_lastCreatedLightning = nil
bj_lastCreatedImage = nil
bj_lastCreatedUbersplat = nil
bj_lastCreatedMinimapIcon = nil
bj_lastCreated = nil

-- Filter function vars
filterIssueHauntOrderAtLocBJ = nil
filterEnumDestructablesInCircleBJ = nil
filterGetUnitsInRectOfPlayer = nil
filterGetUnitsOfTypeIdAll = nil
filterGetUnitsOfPlayerAndTypeId = nil
filterMeleeTrainedUnitIsHeroBJ = nil
filterLivingPlayerUnitsOfTypeId = nil

-- Memory cleanup vars
bj_wantDestroyGroup = false

-- Instanced Operation Results
bj_lastInstObjFuncSuccessful = true
qt1 = 0

--***************************************************************************
--*
--*  Debugging Functions
--*
--***************************************************************************

--===========================================================================
function BJDebugMsg(msg)
end



--***************************************************************************
--*
--*  Math Utility Functions
--*
--***************************************************************************

--===========================================================================
function RMinBJ(a, b)
end

--===========================================================================
function RMaxBJ(a, b)
end

--===========================================================================
function RAbsBJ(a)
end

--===========================================================================
function RSignBJ(a)
end

--===========================================================================
function IMinBJ(a, b)
end

--===========================================================================
function IMaxBJ(a, b)
end

--===========================================================================
function IAbsBJ(a)
end

--===========================================================================
function ISignBJ(a)
end

--===========================================================================
function SinBJ(degrees)
    return Sin(degrees * bj_DEGTORAD)
end

--===========================================================================
function CosBJ(degrees)
    return Cos(degrees * bj_DEGTORAD)
end

--===========================================================================
function TanBJ(degrees)
    return Tan(degrees * bj_DEGTORAD)
end

--===========================================================================
function AsinBJ(degrees)
    return Asin(degrees) * bj_RADTODEG
end

--===========================================================================
function AcosBJ(degrees)
    return Acos(degrees) * bj_RADTODEG
end

--===========================================================================
function AtanBJ(degrees)
    return Atan(degrees) * bj_RADTODEG
end

--===========================================================================
function Atan2BJ(y, x)
    return Atan2(y, x) * bj_RADTODEG
end

--===========================================================================
function AngleBetweenPoints(locA, locB)
    return bj_RADTODEG * Atan2(GetLocationY(locB) - GetLocationY(locA), GetLocationX(locB) - GetLocationX(locA))
end

--===========================================================================
function DistanceBetweenPoints(locA, locB)
    local dx = GetLocationX(locB) - GetLocationX(locA)
    local dy = GetLocationY(locB) - GetLocationY(locA)
    return SquareRoot(dx * dx + dy * dy)
end

--===========================================================================
function PolarProjectionBJ(source, dist, angle)
    local x = GetLocationX(source) + dist * Cos(angle * bj_DEGTORAD)
    local y = GetLocationY(source) + dist * Sin(angle * bj_DEGTORAD)
    return Location(x, y)
end

--===========================================================================
function GetRandomDirectionDeg()
    return GetRandom(0, 360)
end

--===========================================================================
function GetRandomPercentageBJ()
    return GetRandom(0, 100)
end

--===========================================================================
function GetRandomLocInRect(whichRect)
    return Location(GetRandom(GetRectMinX(whichRect), GetRectMaxX(whichRect)), GetRandom(GetRectMinY(whichRect), GetRectMaxY(whichRect)))
end

--===========================================================================
-- Calculate the modulus/remainder of (dividend) divided by (divisor).
-- Examples:  18 mod 5 = 3.  15 mod 5 = 0.  -8 mod 5 = 2.
--
function Modulo(dividend, divisor)
    local modulus = dividend - (dividend / divisor) * divisor

    -- If the dividend was negative, the above modulus calculation will
    -- be negative, but within (-divisor..0).  We can add (divisor) to
    -- shift this result into the desired range of (0..divisor).
    if (modulus < 0) then
        modulus = modulus + divisor
    end

    return modulus
end

--===========================================================================
-- Calculate the modulus/remainder of (dividend) divided by (divisor).
-- Examples:  13.000 mod 2.500 = 0.500.  -6.000 mod 2.500 = 1.500.
--
function Modulo(dividend, divisor)
    local modulus = dividend - I2R(R2I(dividend / divisor)) * divisor

    -- If the dividend was negative, the above modulus calculation will
    -- be negative, but within (-divisor..0).  We can add (divisor) to
    -- shift this result into the desired range of (0..divisor).
    if (modulus < 0) then
        modulus = modulus + divisor
    end

    return modulus
end

--===========================================================================
function OffsetLocation(loc, dx, dy)
    return Location(GetLocationX(loc) + dx, GetLocationY(loc) + dy)
end

--===========================================================================
function OffsetRectBJ(r, dx, dy)
    return Rect(GetRectMinX(r) + dx, GetRectMinY(r) + dy, GetRectMaxX(r) + dx, GetRectMaxY(r) + dy)
end

--===========================================================================
function RectFromCenterSizeBJ(center, width, height)
    local x = GetLocationX(center)
    local y = GetLocationY(center)
    return Rect(x - width * 0.5, y - height * 0.5, x + width * 0.5, y + height * 0.5)
end

--===========================================================================
function RectContainsCoords(r, x, y)
    return (GetRectMinX(r) <= x) and (x <= GetRectMaxX(r)) and (GetRectMinY(r) <= y) and (y <= GetRectMaxY(r))
end

--===========================================================================
function RectContainsLoc(r, loc)
    return RectContainsCoords(r, GetLocationX(loc), GetLocationY(loc))
end

--===========================================================================
function RectContainsUnit(r, whichUnit)
    return RectContainsCoords(r, GetUnitX(whichUnit), GetUnitY(whichUnit))
end

--===========================================================================
function RectContainsItem(whichItem, r)
    if (whichItem == nil) then
        return false
    end

    if (IsItemOwned(whichItem)) then
        return false
    end

    return RectContainsCoords(r, GetItemX(whichItem), GetItemY(whichItem))
end



--***************************************************************************
--*
--*  Utility Constructs
--*
--***************************************************************************

--===========================================================================
-- Runs the trigger's actions if the trigger's conditions evaluate to true.
--
function ConditionalTriggerExecute(trig)
    if TriggerEvaluate(trig) then
        TriggerExecute(trig)
    end
end

--===========================================================================
-- Runs the trigger's actions if the trigger's conditions evaluate to true.
--
function TriggerExecuteBJ(trig, checkConditions)
    if checkConditions then
        if not (TriggerEvaluate(trig)) then
            return false
        end
    end
    TriggerExecute(trig)
    return true
end

--===========================================================================
-- Arranges for a trigger to fire almost immediately, except that the calling
-- trigger is not interrupted as is the case with a TriggerExecute call.
-- Since the trigger executes normally, its conditions are still evaluated.
--
function PostTriggerExecuteBJ(trig, checkConditions)
    if checkConditions then
        if not (TriggerEvaluate(trig)) then
            return false
        end
    end
    TriggerRegisterTimerEvent(trig, 0, false)
    return true
end

--===========================================================================
-- Debug - Display the contents of the trigger queue (as either nil or "x"
-- for each entry).
function QueuedTriggerCheck()
    local s = "TrigQueue Check "
    local i

    i = 0
    s = s + "(" + I2S(bj_queuedExecTotal) + " total)"
    DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 600, s)
end

--===========================================================================
-- Searches the queue for a given trigger, returning the index of the
-- trigger within the queue if it is found, or -1 if it is not found.
--
function QueuedTriggerGetIndex(trig)
    -- Determine which, if any, of the queued triggers is being removed.
    local index = 0
    return -1
end

--===========================================================================
-- Removes a trigger from the trigger queue, shifting other triggers down
-- to fill the unused space.  If the currently running trigger is removed
-- in this manner, this function does NOT attempt to run the next trigger.
--
function QueuedTriggerRemoveByIndex(trigIndex)
    local index

    -- If the to-be-removed index is out of range, fail.
    if (trigIndex >= bj_queuedExecTotal) then
        return false
    end

    -- Shift all queue entries down to fill in the gap.
    bj_queuedExecTotal = bj_queuedExecTotal - 1
    index = trigIndex
    return true
end

--===========================================================================
-- Attempt to execute the first trigger in the queue.  If it fails, remove
-- it and execute the next one.  Continue this cycle until a trigger runs,
-- or until the queue is empty.
--
function QueuedTriggerAttemptExec()
    return false
end

--===========================================================================
-- Queues a trigger to be executed, assuring that such triggers are not
-- executed at the same time.
--
function QueuedTriggerAddBJ(trig, checkConditions)
    -- Make sure our queue isn't full.  If it is, return failure.
    if (bj_queuedExecTotal >= bj_MAX_QUEUED_TRIGGERS) then
        return false
    end

    -- Add the trigger to an array of to-be-executed triggers.
    bj_queuedExecTriggers[bj_queuedExecTotal] = trig
    bj_queuedExecUseConds[bj_queuedExecTotal] = checkConditions
    bj_queuedExecTotal = bj_queuedExecTotal + 1

    -- If this is the only trigger in the queue, run it.
    if (bj_queuedExecTotal == 1) then
        QueuedTriggerAttemptExec()
    end
    return true
end

--===========================================================================
-- Denotes the end of a queued trigger. Be sure to this only once per
-- queued trigger, or risk stepping on the toes of other queued triggers.
--
function QueuedTriggerRemoveBJ(trig)
    local index
    local trigIndex
    local trigExecuted

    -- Find the trigger's index.
    trigIndex = QueuedTriggerGetIndex(trig)
    if (trigIndex == -1) then
        return
    end

    -- Shuffle the other trigger entries down to fill in the gap.
    QueuedTriggerRemoveByIndex(trigIndex)

    -- If we just axed the currently running trigger, run the next one.
    if (trigIndex == 0) then
        PauseTimer(bj_queuedExecTimeoutTimer)
        QueuedTriggerAttemptExec()
    end
end

--===========================================================================
-- Denotes the end of a queued trigger. Be sure to this only once per
-- queued trigger, lest you step on the toes of other queued triggers.
--
function QueuedTriggerDoneBJ()
    local index

    -- Make sure there's something on the queue to remove.
    if (bj_queuedExecTotal <= 0) then
        return
    end

    -- Remove the currently running trigger from the array.
    QueuedTriggerRemoveByIndex(0)

    -- If other triggers are waiting to run, run one of them.
    PauseTimer(bj_queuedExecTimeoutTimer)
    QueuedTriggerAttemptExec()
end

--===========================================================================
-- Empty the trigger queue.
--
function QueuedTriggerClearBJ()
    PauseTimer(bj_queuedExecTimeoutTimer)
    bj_queuedExecTotal = 0
end

--===========================================================================
-- Remove all but the currently executing trigger from the trigger queue.
--
function QueuedTriggerClearInactiveBJ()
    bj_queuedExecTotal = IMinBJ(bj_queuedExecTotal, 1)
end

--===========================================================================
function QueuedTriggerCountBJ()
    return bj_queuedExecTotal
end

--===========================================================================
function IsTriggerQueueEmptyBJ()
    return bj_queuedExecTotal <= 0
end

--===========================================================================
function IsTriggerQueuedBJ(trig)
    return QueuedTriggerGetIndex(trig) ~= -1
end

--===========================================================================
function GetForLoopIndexA()
    return bj_forLoopAIndex
end

--===========================================================================
function SetForLoopIndexA(newIndex)
    bj_forLoopAIndex = newIndex
end

--===========================================================================
function GetForLoopIndexB()
    return bj_forLoopBIndex
end

--===========================================================================
function SetForLoopIndexB(newIndex)
    bj_forLoopBIndex = newIndex
end

--===========================================================================
-- We can't do game-time waits, so this simulates one by starting a timer
-- and polling until the timer expires.
function PolledWait(duration)
    local t
    local timeRemaining

    if (duration > 0) then
        t = CreateTimer()
        TimerStart(t, duration, false, nil)
        DestroyTimer(t)
    end
end

--===========================================================================
function TertiaryOp(flag, valueA, valueB)
    if flag then
        return valueA
    else
        return valueB
    end
end


--***************************************************************************
--*
--*  General Utility Functions
--*  These functions exist purely to make the trigger dialogs cleaner and
--*  more comprehensible.
--*
--***************************************************************************

--===========================================================================
function Do()
end

--===========================================================================
-- This function does .  WorldEdit should should eventually ignore
-- CommentString triggers during script generation, but until such a time,
-- this function will serve as a stub.
--
function CommentString(commentString)
end

--===========================================================================
-- This function)the input string, converting it from the localized text, if necessary
--
function StringIdentity(theString)
    return GetLocalizedString(theString)
end

--===========================================================================
function GetBooleanAnd(valueA, valueB)
    return valueA and valueB
end

--===========================================================================
function GetBooleanOr(valueA, valueB)
    return valueA or valueB
end

--===========================================================================
-- Converts a percentage (, 0..100) into a scaled  (0..max),
-- clipping the result to 0..max in case the input is invalid.
--
function PercentToInt(percentage, max)
    local percent = percentage * I2R(max) * 0.01
    local result = MathRound(percent)

    if (result < 0) then
        result = 0
    elseif (result > max) then
        result = max
    end

    return result
end

--===========================================================================
function PercentTo255(percentage)
    return PercentToInt(percentage, 255)
end

--===========================================================================
function GetTimeOfDay()
    return GetFloatGameState(GAME_STATE_TIME_OF_DAY)
end

--===========================================================================
function SetTimeOfDay(whatTime)
    SetFloatGameState(GAME_STATE_TIME_OF_DAY, whatTime)
end

--===========================================================================
function SetTimeOfDayScalePercentBJ(scalePercent)
    SetTimeOfDayScale(scalePercent * 0.01)
end

--===========================================================================
function GetTimeOfDayScalePercentBJ()
    return GetTimeOfDayScale() * 100
end

--===========================================================================
function PlaySound(soundName)
    local soundHandle = CreateSound(soundName, false, false, true, 12700, 12700, "")
    StartSound(soundHandle)
    KillSoundWhenDone(soundHandle)
end

--===========================================================================
function CompareLocationsBJ(A, B)
    return GetLocationX(A) == GetLocationX(B) and GetLocationY(A) == GetLocationY(B)
end

--===========================================================================
function CompareRectsBJ(A, B)
    return GetRectMinX(A) == GetRectMinX(B) and GetRectMinY(A) == GetRectMinY(B) and GetRectMaxX(A) == GetRectMaxX(B) and GetRectMaxY(A) == GetRectMaxY(B)
end

--===========================================================================
--)a square rect that exactly encompasses the specified circle.
--
function GetRectFromCircleBJ(center, radius)
    local centerX = GetLocationX(center)
    local centerY = GetLocationY(center)
    return Rect(centerX - radius, centerY - radius, centerX + radius, centerY + radius)
end



--***************************************************************************
--*
--*  Camera Utility Functions
--*
--***************************************************************************

--===========================================================================
function GetCurrentCameraSetup()
    local theCam = CreateCameraSetup()
    local duration = 0
    CameraSetupSetField(theCam, CAMERA_FIELD_TARGET_DISTANCE, GetCameraField(CAMERA_FIELD_TARGET_DISTANCE), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_FARZ, GetCameraField(CAMERA_FIELD_FARZ), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_ANGLE_OF_ATTACK, bj_RADTODEG * GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_FIELD_OF_VIEW, bj_RADTODEG * GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_ROLL, bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROLL), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_ROTATION, bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROTATION), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_LOCAL_PITCH, bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_PITCH), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_LOCAL_YAW, bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_YAW), duration)
    CameraSetupSetField(theCam, CAMERA_FIELD_LOCAL_ROLL, bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_ROLL), duration)
    CameraSetupSetDestPosition(theCam, GetCameraTargetPositionX(), GetCameraTargetPositionY(), duration)
    return theCam
end

--===========================================================================
function CameraSetupApplyForPlayer(doPan, whichSetup, whichPlayer, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        CameraSetupApplyForceDuration(whichSetup, doPan, duration)
    end
end

--===========================================================================
function CameraSetupApplyForPlayerSmooth(doPan, whichSetup, whichPlayer, dDuration, easeInDuration, easeOutDuration, smoothFactor)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        BlzCameraSetupApplyForceDurationSmooth(whichSetup, doPan, dDuration, easeInDuration, easeOutDuration, smoothFactor)
    end
end

--===========================================================================
function CameraSetupGetFieldSwap(whichField, whichSetup)
    return CameraSetupGetField(whichSetup, whichField)
end

--===========================================================================
function SetCameraFieldForPlayer(whichPlayer, whichField, value, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraField(whichField, value, duration)
    end
end

--===========================================================================
function SetCameraTargetControllerNoZForPlayer(whichPlayer, whichUnit, xoffset, yoffset, inheritOrientation)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraTargetController(whichUnit, xoffset, yoffset, inheritOrientation)
    end
end

--===========================================================================
function SetCameraPositionForPlayer(whichPlayer, x, y)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraPosition(x, y)
    end
end

--===========================================================================
function SetCameraPositionLocForPlayer(whichPlayer, loc)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraPosition(GetLocationX(loc), GetLocationY(loc))
    end
end

--===========================================================================
function RotateCameraAroundLocBJ(degrees, loc, whichPlayer, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraRotateMode(GetLocationX(loc), GetLocationY(loc), bj_DEGTORAD * degrees, duration)
    end
end

--===========================================================================
function PanCameraToForPlayer(whichPlayer, x, y)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        PanCameraTo(x, y)
    end
end

--===========================================================================
function PanCameraToLocForPlayer(whichPlayer, loc)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        PanCameraTo(GetLocationX(loc), GetLocationY(loc))
    end
end

--===========================================================================
function PanCameraToTimedForPlayer(whichPlayer, x, y, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        PanCameraToTimed(x, y, duration)
    end
end

--===========================================================================
function PanCameraToTimedLocForPlayer(whichPlayer, loc, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        PanCameraToTimed(GetLocationX(loc), GetLocationY(loc), duration)
    end
end

--===========================================================================
function PanCameraToTimedLocWithZForPlayer(whichPlayer, loc, zOffset, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        PanCameraToTimedWithZ(GetLocationX(loc), GetLocationY(loc), zOffset, duration)
    end
end

--===========================================================================
function SmartCameraPanBJ(whichPlayer, loc, duration)
    local dist
    local location
    cameraLoc = GetCameraTargetPositionLoc()
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.

        dist = DistanceBetweenPoints(loc, cameraLoc)
        if (dist >= bj_SMARTPAN_TRESHOLD_SNAP) then
            -- If the user is too far away, snap the camera.
            PanCameraToTimed(GetLocationX(loc), GetLocationY(loc), 0)
        elseif (dist >= bj_SMARTPAN_TRESHOLD_PAN) then
            -- If the user is moderately close, pan the camera.
            PanCameraToTimed(GetLocationX(loc), GetLocationY(loc), duration)
        else
            -- User is close enough, so don't touch the camera.
        end
    end
    RemoveLocation(cameraLoc)
end

--===========================================================================
function SetCinematicCameraForPlayer(whichPlayer, cameraModelFile)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCinematicCamera(cameraModelFile)
    end
end

--===========================================================================
function ResetToGameCameraForPlayer(whichPlayer, duration)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        ResetToGameCamera(duration)
    end
end

--===========================================================================
function CameraSetSourceNoiseForPlayer(whichPlayer, magnitude, velocity)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        CameraSetSourceNoise(magnitude, velocity)
    end
end

--===========================================================================
function CameraSetTargetNoiseForPlayer(whichPlayer, magnitude, velocity)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        CameraSetTargetNoise(magnitude, velocity)
    end
end

--===========================================================================
function CameraSetEQNoiseForPlayer(whichPlayer, magnitude)
    local richter = magnitude
    if (richter > 5.0) then
        richter = 5.0
    end
    if (richter < 2.0) then
        richter = 2.0
    end
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        CameraSetTargetNoiseEx(magnitude * 2.0, magnitude * Pow(10, richter), true)
        CameraSetSourceNoiseEx(magnitude * 2.0, magnitude * Pow(10, richter), true)
    end
end

--===========================================================================
function CameraClearNoiseForPlayer(whichPlayer)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        CameraSetSourceNoise(0, 0)
        CameraSetTargetNoise(0, 0)
    end
end

--===========================================================================
-- Query the current camera bounds.
--
function GetCurrentCameraBoundsMapRectBJ()
    return Rect(GetCameraBoundMinX(), GetCameraBoundMinY(), GetCameraBoundMaxX(), GetCameraBoundMaxY())
end

--===========================================================================
-- Query the initial camera bounds, as defined at map init.
--
function GetCameraBoundsMapRect()
    return bj_mapInitialCameraBounds
end

--===========================================================================
-- Query the playable map area, as defined at map init.
--
function GetPlayableMapRect()
    return bj_mapInitialPlayableArea
end

--===========================================================================
-- Query the entire map area, as defined at map init.
--
function GetEntireMapRect()
    return GetWorldBounds()
end

--===========================================================================
function SetCameraBoundsToRect(r)
    local minX = GetRectMinX(r)
    local minY = GetRectMinY(r)
    local maxX = GetRectMaxX(r)
    local maxY = GetRectMaxY(r)
    SetCameraBounds(minX, minY, minX, maxY, maxX, maxY, maxX, minY)
end

--===========================================================================
function SetCameraBoundsToRectForPlayerBJ(whichPlayer, r)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraBoundsToRect(r)
    end
end

--===========================================================================
function AdjustCameraBoundsBJ(adjustMethod, dxWest, dxEast, dyNorth, dySouth)
    local minX = 0
    local minY = 0
    local maxX = 0
    local maxY = 0
    local scale = 0

    if (adjustMethod == bj_CAMERABOUNDS_ADJUST_ADD) then
        scale = 1
    elseif (adjustMethod == bj_CAMERABOUNDS_ADJUST_SUB) then
        scale = -1
    else
        -- Unrecognized adjustment method - ignore the request.
        return
    end

    -- Adjust the actual camera values
    minX = GetCameraBoundMinX() - scale * dxWest
    maxX = GetCameraBoundMaxX() + scale * dxEast
    minY = GetCameraBoundMinY() - scale * dySouth
    maxY = GetCameraBoundMaxY() + scale * dyNorth

    -- Make sure the camera bounds are still valid.
    if (maxX < minX) then
        minX = (minX + maxX) * 0.5
        maxX = minX
    end
    if (maxY < minY) then
        minY = (minY + maxY) * 0.5
        maxY = minY
    end

    -- Apply the new camera values.
    SetCameraBounds(minX, minY, minX, maxY, maxX, maxY, maxX, minY)
end

--===========================================================================
function AdjustCameraBoundsForPlayerBJ(adjustMethod, whichPlayer, dxWest, dxEast, dyNorth, dySouth)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        AdjustCameraBoundsBJ(adjustMethod, dxWest, dxEast, dyNorth, dySouth)
    end
end

--===========================================================================
function SetCameraQuickPositionForPlayer(whichPlayer, x, y)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraQuickPosition(x, y)
    end
end

--===========================================================================
function SetCameraQuickPositionLocForPlayer(whichPlayer, loc)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraQuickPosition(GetLocationX(loc), GetLocationY(loc))
    end
end

--===========================================================================
function SetCameraQuickPositionLoc(loc)
    SetCameraQuickPosition(GetLocationX(loc), GetLocationY(loc))
end

--===========================================================================
function StopCameraForPlayerBJ(whichPlayer)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        StopCamera()
    end
end

--===========================================================================
function SetCameraOrientControllerForPlayerBJ(whichPlayer, whichUnit, xoffset, yoffset)
    if (GetLocalPlayer() == whichPlayer) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        SetCameraOrientController(whichUnit, xoffset, yoffset)
    end
end

--===========================================================================
function CameraSetSmoothingFactorBJ(factor)
    CameraSetSmoothingFactor(factor)
end

--===========================================================================
function CameraResetSmoothingFactorBJ()
    CameraSetSmoothingFactor(0)
end



--***************************************************************************
--*
--*  Text Utility Functions
--*
--***************************************************************************

--===========================================================================
function DisplayTextToForce(toForce, message)
    if (IsPlayerInForce(GetLocalPlayer(), toForce)) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        DisplayTextToPlayer(GetLocalPlayer(), 0, 0, message)
    end
end

--===========================================================================
function DisplayTimedTextToForce(toForce, duration, message)
    if (IsPlayerInForce(GetLocalPlayer(), toForce)) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, duration, message)
    end
end

--===========================================================================
function ClearTextMessagesBJ(toForce)
    if (IsPlayerInForce(GetLocalPlayer(), toForce)) then
        -- Use only local code (no net traffic) within this block to avoid desyncs.
        ClearTextMessages()
    end
end

--===========================================================================
-- The parameters for the API Substring function are unintuitive, so this
-- merely performs a translation for the starting index.
--
function SubStringBJ(source, start, finish)
    return SubString(source, start - 1, finish)
end

function GetHandleIdBJ(h)
    return GetHandleId(h)
end

function StringHashBJ(s)
    return StringHash(s)
end



--***************************************************************************
--*
--*  Event Registration Utility Functions
--*
--***************************************************************************

--===========================================================================
function TriggerRegisterTimerEventPeriodic(trig, timeout)
    return TriggerRegisterTimerEvent(trig, timeout, true)
end

--===========================================================================
function TriggerRegisterTimerEventSingle(trig, timeout)
    return TriggerRegisterTimerEvent(trig, timeout, false)
end

--===========================================================================
function TriggerRegisterTimerExpireEventBJ(trig, t)
    return TriggerRegisterTimerExpireEvent(trig, t)
end

--===========================================================================
function TriggerRegisterPlayerUnitEventSimple(trig, whichPlayer, whichEvent)
    return TriggerRegisterPlayerUnitEvent(trig, whichPlayer, whichEvent, nil)
end

--===========================================================================
function TriggerRegisterAnyUnitEventBJ(trig, whichEvent)
    local index

    index = 0
end

--===========================================================================
function TriggerRegisterPlayerSelectionEventBJ(trig, whichPlayer, selected)
    if selected then
        return TriggerRegisterPlayerUnitEvent(trig, whichPlayer, EVENT_PLAYER_UNIT_SELECTED, nil)
    else
        return TriggerRegisterPlayerUnitEvent(trig, whichPlayer, EVENT_PLAYER_UNIT_DESELECTED, nil)
    end
end

--===========================================================================
function TriggerRegisterPlayerKeyEventBJ(trig, whichPlayer, keType, keKey)
    if (keType == bj_KEYEVENTTYPE_DEPRESS) then
        -- Depress event - find out what key
        if (keKey == bj_KEYEVENTKEY_LEFT) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_LEFT_DOWN)
        elseif (keKey == bj_KEYEVENTKEY_RIGHT) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_RIGHT_DOWN)
        elseif (keKey == bj_KEYEVENTKEY_DOWN) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_DOWN_DOWN)
        elseif (keKey == bj_KEYEVENTKEY_UP) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_UP_DOWN)
        else
            -- Unrecognized key - ignore the request and return failure.
            return nil
        end
    elseif (keType == bj_KEYEVENTTYPE_RELEASE) then
        -- Release event - find out what key
        if (keKey == bj_KEYEVENTKEY_LEFT) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_LEFT_UP)
        elseif (keKey == bj_KEYEVENTKEY_RIGHT) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_RIGHT_UP)
        elseif (keKey == bj_KEYEVENTKEY_DOWN) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_DOWN_UP)
        elseif (keKey == bj_KEYEVENTKEY_UP) then
            return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ARROW_UP_UP)
        else
            -- Unrecognized key - ignore the request and return failure.
            return nil
        end
    else
        -- Unrecognized type - ignore the request and return failure.
        return nil
    end
end

--===========================================================================
function TriggerRegisterPlayerMouseEventBJ(trig, whichPlayer, meType)
    if (meType == bj_MOUSEEVENTTYPE_DOWN) then
        -- Mouse down event
        return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_MOUSE_DOWN)
    elseif (meType == bj_MOUSEEVENTTYPE_UP) then
        -- Mouse up event
        return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_MOUSE_UP)
    elseif (meType == bj_MOUSEEVENTTYPE_MOVE) then
        -- Mouse move event
        return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_MOUSE_MOVE)
    else
        -- Unrecognized type - ignore the request and return failure.
        return nil
    end
end

--===========================================================================
function TriggerRegisterPlayerEventVictory(trig, whichPlayer)
    return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_VICTORY)
end

--===========================================================================
function TriggerRegisterPlayerEventDefeat(trig, whichPlayer)
    return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_DEFEAT)
end

--===========================================================================
function TriggerRegisterPlayerEventLeave(trig, whichPlayer)
    return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_LEAVE)
end

--===========================================================================
function TriggerRegisterPlayerEventAllianceChanged(trig, whichPlayer)
    return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_ALLIANCE_CHANGED)
end

--===========================================================================
function TriggerRegisterPlayerEventEndCinematic(trig, whichPlayer)
    return TriggerRegisterPlayerEvent(trig, whichPlayer, EVENT_PLAYER_END_CINEMATIC)
end

--===========================================================================
function TriggerRegisterGameStateEventTimeOfDay(trig, opcode, limitval)
    return TriggerRegisterGameStateEvent(trig, GAME_STATE_TIME_OF_DAY, opcode, limitval)
end

--===========================================================================
function TriggerRegisterEnterRegionSimple(trig, whichRegion)
    return TriggerRegisterEnterRegion(trig, whichRegion, nil)
end

--===========================================================================
function TriggerRegisterLeaveRegionSimple(trig, whichRegion)
    return TriggerRegisterLeaveRegion(trig, whichRegion, nil)
end

--===========================================================================
function TriggerRegisterEnterRectSimple(trig, r)
    local rectRegion = CreateRegion()
    RegionAddRect(rectRegion, r)
    return TriggerRegisterEnterRegion(trig, Region, nil)
end

--===========================================================================
function TriggerRegisterLeaveRectSimple(trig, r)
    local rectRegion = CreateRegion()
    RegionAddRect(rectRegion, r)
    return TriggerRegisterLeaveRegion(trig, rectRegion, nil)
end

--===========================================================================
function TriggerRegisterDistanceBetweenUnits(trig, whichUnit, condition, range)
    return TriggerRegisterUnitInRange(trig, whichUnit, range, condition)
end

--===========================================================================
function TriggerRegisterUnitInRangeSimple(trig, range, whichUnit)
    return TriggerRegisterUnitInRange(trig, whichUnit, range, nil)
end

--===========================================================================
function TriggerRegisterUnitLifeEvent(trig, whichUnit, opcode, limitval)
    return TriggerRegisterUnitStateEvent(trig, whichUnit, _STATE_LIFE, opcode, limitval)
end

--===========================================================================
function TriggerRegisterUnitManaEvent(trig, whichUnit, opcode, limitval)
    return TriggerRegisterUnitStateEvent(trig, whichUnit, _STATE_MANA, opcode, limitval)
end

--===========================================================================
function TriggerRegisterDialogEventBJ(trig, whichDialog)
    return TriggerRegisterDialogEvent(trig, whichDialog)
end

--===========================================================================
function TriggerRegisterShowSkillEventBJ(trig)
    return TriggerRegisterGameEvent(trig, EVENT_GAME_SHOW_SKILL)
end

--===========================================================================
function TriggerRegisterBuildSubmenuEventBJ(trig)
    return TriggerRegisterGameEvent(trig, EVENT_GAME_BUILD_SUBMENU)
end

--===========================================================================
function TriggerRegisterBuildCommandEventBJ(trig, unitId)
    TriggerRegisterCommandEvent(trig, 'ANbu', Id2String(unitId))
    TriggerRegisterCommandEvent(trig, 'AHbu', Id2String(unitId))
    TriggerRegisterCommandEvent(trig, 'AEbu', Id2String(unitId))
    TriggerRegisterCommandEvent(trig, 'AObu', Id2String(unitId))
    TriggerRegisterCommandEvent(trig, 'AUbu', Id2String(unitId))
    return TriggerRegisterCommandEvent(trig, 'AGbu', Id2String(unitId))
end

--===========================================================================
function TriggerRegisterTrainCommandEventBJ(trig, unitId)
    return TriggerRegisterCommandEvent(trig, 'Aque', Id2String(unitId))
end

--===========================================================================
function TriggerRegisterUpgradeCommandEventBJ(trig, techId)
    return TriggerRegisterUpgradeCommandEvent(trig, techId)
end

--===========================================================================
function TriggerRegisterCommonCommandEventBJ(trig, order)
    return TriggerRegisterCommandEvent(trig, 0, order)
end

--===========================================================================
function TriggerRegisterGameLoadedEventBJ(trig)
    return TriggerRegisterGameEvent(trig, EVENT_GAME_LOADED)
end

--===========================================================================
function TriggerRegisterGameSavedEventBJ(trig)
    return TriggerRegisterGameEvent(trig, EVENT_GAME_SAVE)
end

--===========================================================================
function RegisterDestDeathInRegionEnum()
    bj_destInRegionDiesCount = bj_destInRegionDiesCount + 1
    if (bj_destInRegionDiesCount <= bj_MAX_DEST_IN_REGION_EVENTS) then
        TriggerRegisterDeathEvent(bj_destInRegionDiesTrig, GetEnumDestructable())
    end
end

--===========================================================================
function TriggerRegisterDestDeathInRegionEvent(trig, r)
    bj_destInRegionDiesTrig = trig
    bj_destInRegionDiesCount = 0
end



--***************************************************************************
--*
--*  Environment Utility Functions
--*
--***************************************************************************

--===========================================================================
function AddWeatherEffectSaveLast(where, effectID)
    bj_lastCreatedWeatherEffect = AddWeatherEffect(where, effectID)
    return bj_lastCreatedWeatherEffect
end

--===========================================================================
function GetLastCreatedWeatherEffect()
    return bj_lastCreatedWeatherEffect
end

--===========================================================================
function RemoveWeatherEffectBJ(whichWeatherEffect)
    RemoveWeatherEffect(whichWeatherEffect)
end

--===========================================================================
function TerrainDeformationCraterBJ(duration, permanent, where, radius, depth)
    bj_lastCreatedTerrainDeformation = TerrainDeformCrater(GetLocationX(where), GetLocationY(where), radius, depth, R2I(duration * 1000), permanent)
    return bj_lastCreatedTerrainDeformation
end

--===========================================================================
function TerrainDeformationRippleBJ(duration, limitNeg, where, startRadius, endRadius, depth, wavePeriod, waveWidth)
    local spaceWave
    local timeWave
    local radiusRatio

    if (endRadius <= 0 or waveWidth <= 0 or wavePeriod <= 0) then
        return nil
    end

    timeWave = 2.0 * duration / wavePeriod
    spaceWave = 2.0 * endRadius / waveWidth
    radiusRatio = startRadius / endRadius

    bj_lastCreatedTerrainDeformation = TerrainDeformRipple(GetLocationX(where), GetLocationY(where), endRadius, depth, R2I(duration * 1000), 1, spaceWave, timeWave, radiusRatio, limitNeg)
    return bj_lastCreatedTerrainDeformation
end

--===========================================================================
function TerrainDeformationWaveBJ(duration, source, target, radius, depth, trailDelay)
    local distance
    local dirX
    local dirY
    local speed

    distance = DistanceBetweenPoints(source, target)
    if (distance == 0 or duration <= 0) then
        return nil
    end

    dirX = (GetLocationX(target) - GetLocationX(source)) / distance
    dirY = (GetLocationY(target) - GetLocationY(source)) / distance
    speed = distance / duration

    bj_lastCreatedTerrainDeformation = TerrainDeformWave(GetLocationX(source), GetLocationY(source), dirX, dirY, distance, speed, radius, depth, R2I(trailDelay * 1000), 1)
    return bj_lastCreatedTerrainDeformation
end

--===========================================================================
function TerrainDeformationRandomBJ(duration, where, radius, minDelta, maxDelta, updateInterval)
    bj_lastCreatedTerrainDeformation = TerrainDeformRandom(GetLocationX(where), GetLocationY(where), radius, minDelta, maxDelta, R2I(duration * 1000), R2I(updateInterval * 1000))
    return bj_lastCreatedTerrainDeformation
end

--===========================================================================
function TerrainDeformationStopBJ(deformation, duration)
    TerrainDeformStop(deformation, R2I(duration * 1000))
end

--===========================================================================
function GetLastCreatedTerrainDeformation()
    return bj_lastCreatedTerrainDeformation
end

--===========================================================================
function AddLightningLoc(codeName, where1, where2)
    bj_lastCreatedLightning = AddLightningEx(codeName, true, GetLocationX(where1), GetLocationY(where1), GetLocationZ(where1), GetLocationX(where2), GetLocationY(where2), GetLocationZ(where2))
    return bj_lastCreatedLightning
end

--===========================================================================
function DestroyLightningBJ(whichBolt)
    return DestroyLightning(whichBolt)
end

--===========================================================================
function MoveLightningLoc(whichBolt, where1, where2)
    return MoveLightningEx(whichBolt, true, GetLocationX(where1), GetLocationY(where1), GetLocationZ(where1), GetLocationX(where2), GetLocationY(where2), GetLocationZ(where2))
end

--===========================================================================
function GetLightningColorABJ(whichBolt)
    return GetLightningColorA(whichBolt)
end

--===========================================================================
function GetLightningColorRBJ(whichBolt)
    return GetLightningColorR(whichBolt)
end

--===========================================================================
function GetLightningColorGBJ(whichBolt)
    return GetLightningColorG(whichBolt)
end

--===========================================================================
function GetLightningColorBBJ(whichBolt)
    return GetLightningColorB(whichBolt)
end

--===========================================================================
function SetLightningColorBJ(whichBolt, r, g, b, a)
    return SetLightningColor(whichBolt, r, g, b, a)
end

--===========================================================================
function GetLastCreatedLightningBJ()
    return bj_lastCreatedLightning
end

--===========================================================================
function GetAbilityEffectBJ(abilcode, t, index)
    return GetAbilityEffectById(abilcode, t, index)
end

--===========================================================================
function GetAbilitySoundBJ(abilcode, t)
    return GetAbilitySoundById(abilcode, t)
end


--===========================================================================
function GetTerrainCliffLevelBJ(where)
    return GetTerrainCliffLevel(GetLocationX(where), GetLocationY(where))
end

--===========================================================================
function GetTerrainTypeBJ(where)
    return GetTerrainType(GetLocationX(where), GetLocationY(where))
end

--===========================================================================
function GetTerrainVarianceBJ(where)
    return GetTerrainVariance(GetLocationX(where), GetLocationY(where))
end

--===========================================================================
function SetTerrainTypeBJ(where, terrainType, variation, area, shape)
    SetTerrainType(GetLocationX(where), GetLocationY(where), terrainType, variation, area, shape)
end

--===========================================================================
function IsTerrainPathableBJ(where, t)
    return IsTerrainPathable(GetLocationX(where), GetLocationY(where), t)
end

--===========================================================================
function SetTerrainPathableBJ(where, t, flag)
    SetTerrainPathable(GetLocationX(where), GetLocationY(where), t, flag)
end

--===========================================================================
function SetWaterBaseColorBJ(red, green, blue, transparency)
    SetWaterBaseColor(PercentTo255(red), PercentTo255(green), PercentTo255(blue), PercentTo255(100.0 - transparency))
end

--===========================================================================
function CreateFogModifierRectSimple(whichPlayer, whichFogState, r, afterUnits)
    bj_lastCreatedFogModifier = CreateFogModifierRect(whichPlayer, whichFogState, r, true, afterUnits)
    return bj_lastCreatedFogModifier
end

--===========================================================================
function CreateFogModifierRadiusLocSimple(whichPlayer, whichFogState, center, radius, afterUnits)
    bj_lastCreatedFogModifier = CreateFogModifierRadiusLoc(whichPlayer, whichFogState, center, radius, true, afterUnits)
    return bj_lastCreatedFogModifier
end

--===========================================================================
-- Version of CreateFogModifierRect that assumes use of sharedVision and
-- gives the option of immediately enabling the modifier, so that triggers
-- can default to modifiers that are immediately enabled.
--
function CreateFogModifierRectBJ(enabled, whichPlayer, whichFogState, r)
    bj_lastCreatedFogModifier = CreateFogModifierRect(whichPlayer, whichFogState, r, true, false)
    if enabled then
        FogModifierStart(bj_lastCreatedFogModifier)
    end
    return bj_lastCreatedFogModifier
end

--===========================================================================
-- Version of CreateFogModifierRadius that assumes use of sharedVision and
-- gives the option of immediately enabling the modifier, so that triggers
-- can default to modifiers that are immediately enabled.
--
function CreateFogModifierRadiusLocBJ(enabled, whichPlayer, whichFogState, center, radius)
    bj_lastCreatedFogModifier = CreateFogModifierRadiusLoc(whichPlayer, whichFogState, center, radius, true, false)
    if enabled then
        FogModifierStart(bj_lastCreatedFogModifier)
    end
    return bj_lastCreatedFogModifier
end

--===========================================================================
function GetLastCreatedFogModifier()
    return bj_lastCreatedFogModifier
end

--===========================================================================
function FogEnableOn()
    FogEnable(true)
end

--===========================================================================
function FogEnableOff()
    FogEnable(false)
end

--===========================================================================
function FogMaskEnableOn()
    FogMaskEnable(true)
end

--===========================================================================
function FogMaskEnableOff()
    FogMaskEnable(false)
end

--===========================================================================
function UseTimeOfDayBJ(flag)
    SuspendTimeOfDay(not flag)
end

--===========================================================================
function SetTerrainFogExBJ(style, zstart, zend, density, red, green, blue)
    SetTerrainFogEx(style, zstart, zend, density, red * 0.01, green * 0.01, blue * 0.01)
end

--===========================================================================
function ResetTerrainFogBJ()
    ResetTerrainFog()
end

--===========================================================================
function SetDoodadAnimationBJ(animName, doodadID, radius, center)
    SetDoodadAnimation(GetLocationX(center), GetLocationY(center), radius, doodadID, false, animName, false)
end

--===========================================================================
function SetDoodadAnimationRectBJ(animName, doodadID, r)
    SetDoodadAnimationRect(r, doodadID, animName, false)
end

--===========================================================================
function AddUnitAnimationPropertiesBJ(add, animProperties, whichUnit)
    AddUnitAnimationProperties(whichUnit, animProperties, add)
end


--============================================================================
function CreateImageBJ(file, size, where, zOffset, imageType)
    bj_lastCreatedImage = CreateImage(file, size, size, size, GetLocationX(where), GetLocationY(where), zOffset, 0, 0, 0, imageType)
    return bj_lastCreatedImage
end

--============================================================================
function ShowImageBJ(flag, whichImage)
    ShowImage(whichImage, flag)
end

--============================================================================
function SetImagePositionBJ(whichImage, where, zOffset)
    SetImagePosition(whichImage, GetLocationX(where), GetLocationY(where), zOffset)
end

--============================================================================
function SetImageColorBJ(whichImage, red, green, blue, alpha)
    SetImageColor(whichImage, PercentTo255(red), PercentTo255(green), PercentTo255(blue), PercentTo255(100.0 - alpha))
end

--============================================================================
function GetLastCreatedImage()
    return bj_lastCreatedImage
end

--============================================================================
function CreateUbersplatBJ(where, name, red, green, blue, alpha, Paused, noBirthTime)
    bj_lastCreatedUbersplat = CreateUbersplat(GetLocationX(where), GetLocationY(where), name, PercentTo255(red), PercentTo255(green), PercentTo255(blue), PercentTo255(100.0 - alpha), Paused, noBirthTime)
    return bj_lastCreatedUbersplat
end

--============================================================================
function ShowUbersplatBJ(flag, whichSplat)
    ShowUbersplat(whichSplat, flag)
end

--============================================================================
function GetLastCreatedUbersplat()
    return bj_lastCreatedUbersplat
end

--============================================================================
function GetLastCreatedMinimapIcon()
    return bj_lastCreatedMinimapIcon
end

--============================================================================
function CreateMinimapIconOnUnitBJ(whichUnit, red, green, blue, pingPath, fogVisibility)
    bj_lastCreatedMinimapIcon = CreateMinimapIconOnUnit(whichUnit, red, green, blue, pingPath, fogVisibility)
    return bj_lastCreatedMinimapIcon
end

--============================================================================
function CreateMinimapIconAtLocBJ(where, red, green, blue, pingPath, fogVisibility)
    bj_lastCreatedMinimapIcon = CreateMinimapIconAtLoc(where, red, green, blue, pingPath, fogVisibility)
    return bj_lastCreatedMinimapIcon
end

--============================================================================
function CreateMinimapIconBJ(x, y, red, green, blue, pingPath, fogVisibility)
    bj_lastCreatedMinimapIcon = CreateMinimapIcon(x, y, red, green, blue, pingPath, fogVisibility)
    return bj_lastCreatedMinimapIcon
end

--============================================================================
function CampaignMinimapIconUnitBJ(whichUnit, style)
    local red
    local green
    local blue
    local path
    if (style == bj_CAMPPINGSTYLE_PRIMARY) then
        -- green
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_PRIMARY_GREEN) then
        -- green
        red = 0
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_PRIMARY_RED) then
        -- green
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_BONUS) then
        -- yellow
        red = 255
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectiveBonus")
    elseif (style == bj_CAMPPINGSTYLE_TURNIN) then
        -- yellow
        red = 255
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestTurnIn")
    elseif (style == bj_CAMPPINGSTYLE_BOSS) then
        -- red
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestBoss")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_ALLY) then
        -- green
        red = 0
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_NEUTRAL) then
        -- white
        red = 255
        green = 255
        blue = 255
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_ENEMY) then
        -- red
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    end
    CreateMinimapIconOnUnitBJ(whichUnit, red, green, blue, path, FOG_OF_WAR_MASKED)
    SetMinimapIconOrphanDestroy(bj_lastCreatedMinimapIcon, true)
end


--============================================================================
function CampaignMinimapIconLocBJ(where, style)
    local red
    local green
    local blue
    local path
    if (style == bj_CAMPPINGSTYLE_PRIMARY) then
        -- green (different from the unit version)
        red = 0
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_PRIMARY_GREEN) then
        -- green (different from the unit version)
        red = 0
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_PRIMARY_RED) then
        -- green (different from the unit version)
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectivePrimary")
    elseif (style == bj_CAMPPINGSTYLE_BONUS) then
        -- yellow
        red = 255
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestObjectiveBonus")
    elseif (style == bj_CAMPPINGSTYLE_TURNIN) then
        -- yellow
        red = 255
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestTurnIn")
    elseif (style == bj_CAMPPINGSTYLE_BOSS) then
        -- red
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestBoss")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_ALLY) then
        -- green
        red = 0
        green = 255
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_NEUTRAL) then
        -- white
        red = 255
        green = 255
        blue = 255
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    elseif (style == bj_CAMPPINGSTYLE_CONTROL_ENEMY) then
        -- red
        red = 255
        green = 0
        blue = 0
        path = SkinManagerGetLocalPath("MinimapQuestControlPoint")
    end
    CreateMinimapIconAtLocBJ(where, red, green, blue, path, FOG_OF_WAR_MASKED)
end


--***************************************************************************
--*
--*  Sound Utility Functions
--*
--***************************************************************************

--===========================================================================
function PlaySoundBJ(soundHandle)
    bj_lastPlayedSound = soundHandle
    if (soundHandle ~= nil) then
        StartSound(soundHandle)
    end
end

--===========================================================================
function StopSoundBJ(soundHandle, fadeOut)
    StopSound(soundHandle, false, fadeOut)
end

--===========================================================================
function SetSoundVolumeBJ(soundHandle, volumePercent)
    SetSoundVolume(soundHandle, PercentToInt(volumePercent, 127))
end

--===========================================================================
function SetSoundOffsetBJ(newOffset, soundHandle)
    SetSoundPlayPosition(soundHandle, R2I(newOffset * 1000))
end

--===========================================================================
function SetSoundDistanceCutoffBJ(soundHandle, cutoff)
    SetSoundDistanceCutoff(soundHandle, cutoff)
end

--===========================================================================
function SetSoundPitchBJ(soundHandle, pitch)
    SetSoundPitch(soundHandle, pitch)
end

--===========================================================================
function SetSoundPositionLocBJ(soundHandle, loc, z)
    SetSoundPosition(soundHandle, GetLocationX(loc), GetLocationY(loc), z)
end

--===========================================================================
function AttachSoundToUnitBJ(soundHandle, whichUnit)
    AttachSoundToUnit(soundHandle, whichUnit)
end

--===========================================================================
function SetSoundConeAnglesBJ(soundHandle, inside, outside, outsideVolumePercent)
    SetSoundConeAngles(soundHandle, inside, outside, PercentToInt(outsideVolumePercent, 127))
end

--===========================================================================
function KillSoundWhenDoneBJ(soundHandle)
    KillSoundWhenDone(soundHandle)
end

--===========================================================================
function PlaySoundAtPointBJ(soundHandle, volumePercent, loc, z)
    SetSoundPositionLocBJ(soundHandle, loc, z)
    SetSoundVolumeBJ(soundHandle, volumePercent)
    PlaySoundBJ(soundHandle)
end

--===========================================================================
function PlaySoundOnUnitBJ(soundHandle, volumePercent, whichUnit)
    AttachSoundToUnitBJ(soundHandle, whichUnit)
    SetSoundVolumeBJ(soundHandle, volumePercent)
    PlaySoundBJ(soundHandle)
end

--===========================================================================
function PlaySoundFromOffsetBJ(soundHandle, volumePercent, startingOffset)
    SetSoundVolumeBJ(soundHandle, volumePercent)
    PlaySoundBJ(soundHandle)
    SetSoundOffsetBJ(startingOffset, Handle)
end

--===========================================================================
function PlayMusicBJ(musicFileName)
    bj_lastPlayedMusic = musicFileName
    PlayMusic(musicFileName)
end

--===========================================================================
function PlayMusicExBJ(musicFileName, startingOffset, fadeInTime)
    bj_lastPlayedMusic = musicFileName
    PlayMusicEx(musicFileName, R2I(startingOffset * 1000), R2I(fadeInTime * 1000))
end

--===========================================================================
function SetMusicOffsetBJ(newOffset)
    SetMusicPlayPosition(R2I(newOffset * 1000))
end

--===========================================================================
function PlayThematicMusicBJ(musicName)
    PlayThematicMusic(musicName)
end

--===========================================================================
function PlayThematicMusicExBJ(musicName, startingOffset)
    PlayThematicMusicEx(musicName, R2I(startingOffset * 1000))
end

--===========================================================================
function SetThematicMusicOffsetBJ(newOffset)
    SetThematicMusicPlayPosition(R2I(newOffset * 1000))
end

--===========================================================================
function EndThematicMusicBJ()
    EndThematicMusic()
end

--===========================================================================
function StopMusicBJ(fadeOut)
    StopMusic(fadeOut)
end

--===========================================================================
function ResumeMusicBJ()
    ResumeMusic()
end

--===========================================================================
function SetMusicVolumeBJ(volumePercent)
    SetMusicVolume(PercentToInt(volumePercent, 127))
end

--===========================================================================
function SetThematicMusicVolumeBJ(volumePercent)
    SetThematicMusicVolume(PercentToInt(volumePercent, 127))
end

--===========================================================================
function GetSoundDurationBJ(soundHandle)
    if (soundHandle == nil) then
        return bj__SOUND_DURATION
    else
        return I2R(GetSoundDuration(soundHandle)) * 0.001
    end
end

--===========================================================================
function GetSoundFileDurationBJ(musicFileName)
    return I2R(GetSoundFileDuration(musicFileName)) * 0.001
end

--===========================================================================
function GetLastPlayedSound()
    return bj_lastPlayedSound
end

--===========================================================================
function GetLastPlayedMusic()
    return bj_lastPlayedMusic
end

--===========================================================================
function VolumeGroupSetVolumeBJ(vgroup, percent)
    VolumeGroupSetVolume(vgroup, percent * 0.01)
end

--===========================================================================
function SetCineModeVolumeGroupsImmediateBJ()
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UNITMOVEMENT, bj_CINEMODE_VOLUME_UNITMOVEMENT)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UNITSOUNDS, bj_CINEMODE_VOLUME_UNITSOUNDS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_COMBAT, bj_CINEMODE_VOLUME_COMBAT)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_SPELLS, bj_CINEMODE_VOLUME_SPELLS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UI, bj_CINEMODE_VOLUME_UI)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, bj_CINEMODE_VOLUME_MUSIC)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_AMBIENTSOUNDS, bj_CINEMODE_VOLUME_AMBIENTSOUNDS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_FIRE, bj_CINEMODE_VOLUME_FIRE)
end

--===========================================================================
function SetCineModeVolumeGroupsBJ()
    -- Delay the request if it occurs at map init.
    if bj_gameStarted then
        SetCineModeVolumeGroupsImmediateBJ()
    else
        TimerStart(bj_volumeGroupsTimer, bj_GAME_STARTED_THRESHOLD, false, function()
            SetCineModeVolumeGroupsImmediateBJ()
        end)
    end
end

--===========================================================================
function SetSpeechVolumeGroupsImmediateBJ()
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UNITMOVEMENT, bj_SPEECH_VOLUME_UNITMOVEMENT)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UNITSOUNDS, bj_SPEECH_VOLUME_UNITSOUNDS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_COMBAT, bj_SPEECH_VOLUME_COMBAT)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_SPELLS, bj_SPEECH_VOLUME_SPELLS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UI, bj_SPEECH_VOLUME_UI)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, bj_SPEECH_VOLUME_MUSIC)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_AMBIENTSOUNDS, bj_SPEECH_VOLUME_AMBIENTSOUNDS)
    VolumeGroupSetVolume(SOUND_VOLUMEGROUP_FIRE, bj_SPEECH_VOLUME_FIRE)
end

--===========================================================================
function SetSpeechVolumeGroupsBJ()
    -- Delay the request if it occurs at map init.
    if bj_gameStarted then
        SetSpeechVolumeGroupsImmediateBJ()
    else
        TimerStart(bj_volumeGroupsTimer, bj_GAME_STARTED_THRESHOLD, false, function()
            SetSpeechVolumeGroupsImmediateBJ()
        end)
    end
end

--===========================================================================
function VolumeGroupResetImmediateBJ()
    VolumeGroupReset()
end

--===========================================================================
function VolumeGroupResetBJ()
    -- Delay the request if it occurs at map init.
    if bj_gameStarted then
        VolumeGroupResetImmediateBJ()
    else
        TimerStart(bj_volumeGroupsTimer, bj_GAME_STARTED_THRESHOLD, false, function()
            VolumeGroupResetImmediateBJ()
        end)
    end
end

--===========================================================================
function GetSoundIsPlayingBJ(soundHandle)
    return GetSoundIsLoading(soundHandle) or GetSoundIsPlaying(soundHandle)
end

--===========================================================================
function WaitForSoundBJ(soundHandle, offset)
    TriggerWaitForSound(soundHandle, offset)
end

--===========================================================================
function SetMapMusicIndexedBJ(musicName, index)
    SetMapMusic(musicName, false, index)
end

--===========================================================================
function SetMapMusicRandomBJ(musicName)
    SetMapMusic(musicName, true, 0)
end

--===========================================================================
function ClearMapMusicBJ()
    ClearMapMusic()
end

--===========================================================================
function SetStackedSoundBJ(add, soundHandle, r)
    local width = GetRectMaxX(r) - GetRectMinX(r)
    local height = GetRectMaxY(r) - GetRectMinY(r)

    SetSoundPosition(soundHandle, GetRectCenterX(r), GetRectCenterY(r), 0)
    if add then
        RegisterStackedSound(soundHandle, true, width, height)
    else
        UnregisterStackedSound(soundHandle, true, width, height)
    end
end

--===========================================================================
function StartSoundForPlayerBJ(whichPlayer, soundHandle)
    if (whichPlayer == GetLocalPlayer()) then
        StartSound(soundHandle)
    end
end

--===========================================================================
function VolumeGroupSetVolumeForPlayerBJ(whichPlayer, vgroup, scale)
    if (GetLocalPlayer() == whichPlayer) then
        VolumeGroupSetVolume(vgroup, scale)
    end
end

--===========================================================================
function EnableDawnDusk(flag)
    bj_useDawnDuskSounds = flag
end

--===========================================================================
function IsDawnDuskEnabled()
    return bj_useDawnDuskSounds
end



--***************************************************************************
--*
--*  Day/Night ambient sounds
--*
--***************************************************************************

--===========================================================================
function SetAmbientDaySound(inLabel)
    local ToD

    -- Stop old sound, if necessary
    if (bj_dayAmbientSound ~= nil) then
        StopSound(bj_dayAmbientSound, true, true)
    end

    -- Create new sound
    bj_dayAmbientSound = CreateMIDISound(inLabel, 20, 20)

    -- Start the sound if necessary, based on current time
    ToD = GetTimeOfDay()
    if (ToD >= bj_TOD_DAWN and ToD < bj_TOD_DUSK) then
        StartSound(bj_dayAmbientSound)
    end
end

--===========================================================================
function SetAmbientNightSound(inLabel)
    local ToD

    -- Stop old sound, if necessary
    if (bj_nightAmbientSound ~= nil) then
        StopSound(bj_nightAmbientSound, true, true)
    end

    -- Create new sound
    bj_nightAmbientSound = CreateMIDISound(inLabel, 20, 20)

    -- Start the sound if necessary, based on current time
    ToD = GetTimeOfDay()
    if (ToD < bj_TOD_DAWN or ToD >= bj_TOD_DUSK) then
        StartSound(bj_nightAmbientSound)
    end
end



--***************************************************************************
--*
--*  Special Effect Utility Functions
--*
--***************************************************************************

--===========================================================================
function AddSpecialEffectLocBJ(where, modelName)
    bj_lastCreatedEffect = AddSpecialEffectLoc(modelName, where)
    return bj_lastCreatedEffect
end

--===========================================================================
function AddSpecialEffectTargetUnitBJ(attachPointName, targetWidget, modelName)
    bj_lastCreatedEffect = AddSpecialEffectTarget(modelName, targetWidget, attachPointName)
    return bj_lastCreatedEffect
end

--===========================================================================
-- Two distinct trigger actions can't share the same function name, so this
-- dummy function simply mimics the behavior of an existing call.
--
-- Commented out - Destructibles have no attachment points.
--
--function AddSpecialEffectTargetDestructableBJ(attachPointName, targetWidget, modelName)
--    return AddSpecialEffectTargetUnitBJ(attachPointName, targetWidget, modelName)
--end

--===========================================================================
-- Two distinct trigger actions can't share the same function name, so this
-- dummy function simply mimics the behavior of an existing call.
--
-- Commented out - Items have no attachment points.
--
--function AddSpecialEffectTargetItemBJ(attachPointName, targetWidget, modelName)
--    return AddSpecialEffectTargetUnitBJ(attachPointName, targetWidget, modelName)
--end

--===========================================================================
function DestroyEffectBJ(whichEffect)
    DestroyEffect(whichEffect)
end

--===========================================================================
function GetLastCreatedEffectBJ()
    return bj_lastCreatedEffect
end



--***************************************************************************
--*
--*  Command Button Effect Utility Functions
--*
--***************************************************************************

--===========================================================================
function CreateCommandButtonEffectBJ(abilityId, order)
    bj_lastCreatedCommandButtonEffect = CreateCommandButtonEffect(abilityId, order)
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function CreateTrainCommandButtonEffectBJ(unitId)
    bj_lastCreatedCommandButtonEffect = CreateCommandButtonEffect('Aque', Id2String(unitId))
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function CreateUpgradeCommandButtonEffectBJ(techId)
    bj_lastCreatedCommandButtonEffect = CreateUpgradeCommandButtonEffect(techId)
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function CreateCommonCommandButtonEffectBJ(order)
    bj_lastCreatedCommandButtonEffect = CreateCommandButtonEffect(0, order)
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function CreateLearnCommandButtonEffectBJ(abilityId)
    bj_lastCreatedCommandButtonEffect = CreateLearnCommandButtonEffect(abilityId)
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function CreateBuildCommandButtonEffectBJ(unitId)
    local r = GetPlayerRace(GetLocalPlayer())
    local abilityId
    if (r == RACE_HUMAN) then
        abilityId = 'AHbu'
    elseif (r == RACE_ORC) then
        abilityId = 'AObu'
    elseif (r == RACE_UNDEAD) then
        abilityId = 'AUbu'
    elseif (r == RACE_NIGHTELF) then
        abilityId = 'AEbu'
    else
        abilityId = 'ANbu'
    end
    bj_lastCreatedCommandButtonEffect = CreateCommandButtonEffect(abilityId, Id2String(unitId))
    return bj_lastCreatedCommandButtonEffect
end

--===========================================================================
function GetLastCreatedCommandButtonEffectBJ()
    return bj_lastCreatedCommandButtonEffect
end


--***************************************************************************
--*
--*  Hero and Item Utility Functions
--*
--***************************************************************************

--===========================================================================
function GetItemLoc(whichItem)
    return Location(GetItemX(whichItem), GetItemY(whichItem))
end

--===========================================================================
function GetItemLifeBJ(whichWidget)
    return GetWidgetLife(whichWidget)
end

--===========================================================================
function SetItemLifeBJ(whichWidget, life)
    SetWidgetLife(whichWidget, life)
end

--===========================================================================
function AddHeroXPSwapped(xpToAdd, whichHero, showEyeCandy)
    AddHeroXP(whichHero, xpToAdd, showEyeCandy)
end

--===========================================================================
function SetHeroLevelBJ(whichHero, newLevel, showEyeCandy)
    local oldLevel = GetHeroLevel(whichHero)

    if (newLevel > oldLevel) then
        SetHeroLevel(whichHero, newLevel, showEyeCandy)
    elseif (newLevel < oldLevel) then
        UnitStripHeroLevel(whichHero, oldLevel - newLevel)
    else
        -- No change in level - ignore the request.
    end
end

--===========================================================================
function DecUnitAbilityLevelSwapped(abilcode, whichUnit)
    return DecUnitAbilityLevel(whichUnit, abilcode)
end

--===========================================================================
function IncUnitAbilityLevelSwapped(abilcode, whichUnit)
    return IncUnitAbilityLevel(whichUnit, abilcode)
end

--===========================================================================
function SetUnitAbilityLevelSwapped(abilcode, whichUnit, level)
    return SetUnitAbilityLevel(whichUnit, abilcode, level)
end

--===========================================================================
function GetUnitAbilityLevelSwapped(abilcode, whichUnit)
    return GetUnitAbilityLevel(whichUnit, abilcode)
end

--===========================================================================
function UnitHasBuffBJ(whichUnit, buffcode)
    return (GetUnitAbilityLevel(whichUnit, buffcode) > 0)
end

--===========================================================================
function UnitRemoveBuffBJ(buffcode, whichUnit)
    return UnitRemoveAbility(whichUnit, buffcode)
end

--===========================================================================
function UnitAddItemSwapped(whichItem, whichHero)
    return UnitAddItem(whichHero, whichItem)
end

--===========================================================================
function UnitAddItemByIdSwapped(itemId, whichHero)
end

--===========================================================================
function UnitRemoveItemSwapped(whichItem, whichHero)
end

--===========================================================================
-- Translates 0-based slot indices to 1-based slot indices.
--
function UnitRemoveItemFromSlotSwapped(itemSlot, whichHero)
end

--===========================================================================
function CreateItemLoc(itemId, loc)
end

--===========================================================================
function GetLastCreatedItem()
end

--===========================================================================
function GetLastRemovedItem()
end

--===========================================================================
function SetItemPositionLoc(whichItem, loc)
end

--===========================================================================
function GetLearnedSkillBJ()
end

--===========================================================================
function SuspendHeroXPBJ(flag, whichHero)
end

--===========================================================================
function SetPlayerHandicapDamageBJ(whichPlayer, handicapPercent)
end

--===========================================================================
function GetPlayerHandicapDamageBJ(whichPlayer)
end

--===========================================================================
function SetPlayerHandicapReviveTimeBJ(whichPlayer, handicapPercent)
end

--===========================================================================
function GetPlayerHandicapReviveTimeBJ(whichPlayer)
end

--===========================================================================
function SetPlayerHandicapXPBJ(whichPlayer, handicapPercent)
end

--===========================================================================
function GetPlayerHandicapXPBJ(whichPlayer)
end

--===========================================================================
function SetPlayerHandicapBJ(whichPlayer, handicapPercent)
end

--===========================================================================
function GetPlayerHandicapBJ(whichPlayer)
end

--===========================================================================
function GetHeroStatBJ(whichStat, whichHero, includeBonuses)
end

--===========================================================================
function SetHeroStat(whichHero, whichStat, value)
end

--===========================================================================
function ModifyHeroStat(whichStat, whichHero, modifyMethod, value)
end

--===========================================================================
function ModifyHeroSkillPoints(whichHero, modifyMethod, value)
end

--===========================================================================
function UnitDropItemPointBJ(whichUnit, whichItem, x, y)
end

--===========================================================================
function UnitDropItemPointLoc(whichUnit, whichItem, loc)
end

--===========================================================================
function UnitDropItemSlotBJ(whichUnit, whichItem, slot)
end

--===========================================================================
function UnitDropItemTargetBJ(whichUnit, whichItem, target)
end

--===========================================================================
-- Two distinct trigger actions can't share the same function name, so this
-- dummy function simply mimics the behavior of an existing call.
--
function UnitUseItemDestructable(whichUnit, whichItem, target)
end

--===========================================================================
function UnitUseItemPointLoc(whichUnit, whichItem, loc)
end

--===========================================================================
-- Translates 0-based slot indices to 1-based slot indices.
--
function UnitItemInSlotBJ(whichUnit, Slot)
end

--===========================================================================
function GetItemOfTypeFromUnitBJ(whichUnit, Id)
end

--===========================================================================
function UnitHasItemOfTypeBJ(whichUnit, Id)
end

--===========================================================================
function UnitInventoryCount(whichUnit)
end

--===========================================================================
function UnitInventorySizeBJ(whichUnit)
end

--===========================================================================
function SetItemInvulnerableBJ(whichItem, flag)
end

--===========================================================================
function SetItemDropOnDeathBJ(whichItem, flag)
end

--===========================================================================
function SetItemDroppableBJ(whichItem, flag)
end

--===========================================================================
function SetItemPlayerBJ(whichItem, whichPlayer, changeColor)
end

--===========================================================================
function SetItemVisibleBJ(show, whichItem)
end

--===========================================================================
function IsItemHiddenBJ(whichItem)
end

--===========================================================================
function ChooseRandomItemBJ(level)
end

--===========================================================================
function ChooseRandomItemExBJ(level, whichType)
end

--===========================================================================
function ChooseRandomNPBuildingBJ()
end

--===========================================================================
function ChooseRandomCreepBJ(level)
end

--===========================================================================
function EnumItemsInRectBJ(r, actionFunc)
end

--===========================================================================
-- See GroupPickRandomUnitEnum for the details of this algorithm.
--
function RandomItemInRectBJEnum()
end

--===========================================================================
-- Picks a random item from within a rect, matching a condition
--
function RandomItemInRectBJ(r, filter)
end

--===========================================================================
-- Picks a random item from within a rect
--
function RandomItemInRectSimpleBJ(r)
end

--===========================================================================
function CheckItemStatus(whichItem, status)
end

--===========================================================================
function CheckItemcodeStatus(itemId, status)
end



--***************************************************************************
--*
--*  Unit Utility Functions
--*
--***************************************************************************

--===========================================================================
function UnitId2OrderIdBJ(unitId)
end

--===========================================================================
function String2UnitIdBJ(unitIdString)
end

--===========================================================================
function UnitId2StringBJ(unitId)
end

--===========================================================================
function String2OrderIdBJ(orderIdString)
end

--===========================================================================
function OrderId2StringBJ(orderId)
end

--===========================================================================
function GetIssuedOrderIdBJ()
end

--===========================================================================
function GetKillingUnitBJ()
end

--===========================================================================
function CreateUnitAtLocSaveLast(id, unitid, loc, face)
end

--===========================================================================
function GetLastCreatedUnit()
end

--===========================================================================
function CreateNUnitsAtLoc(count, Id, whichPlayer, loc, face)
end

--===========================================================================
function CreateNUnitsAtLocFacingLocBJ(count, Id, whichPlayer, loc, lookAt)
end

--===========================================================================
function GetLastCreatedGroupEnum()
end

--===========================================================================
function GetLastCreatedGroup()
end

--===========================================================================
function CreateCorpseLocBJ(unitid, whichPlayer, loc)
end

--===========================================================================
function UnitSuspendDecayBJ(suspend, whichUnit)
end

--===========================================================================
function DelayedSuspendDecayStopAnimEnum()
end

--===========================================================================
function DelayedSuspendDecayBoneEnum()
end

--===========================================================================
-- Game code explicitly sets the animation back to "decay bone" after the
-- initial corpse fades away, so we reit now.  It's best not to show
-- off corpses thus created until after this grace period has passed.
--
function DelayedSuspendDecayFleshEnum()
end

--===========================================================================
-- Waits a short period of time to ensure that the corpse is decaying, and
-- then suspend the animation and corpse decay.
--
function DelayedSuspendDecay()
end

--===========================================================================
function DelayedSuspendDecayCreate()
end

--===========================================================================
function CreatePermanentCorpseLocBJ(style, id, whichPlayer, loc, facing)
end

--===========================================================================
function GetUnitStateSwap(whichState, whichUnit)
end

--===========================================================================
function GetUnitStatePercent(whichUnit, whichState, whichMaxState)
end

--===========================================================================
function GetUnitLifePercent(whichUnit)
end

--===========================================================================
function GetUnitManaPercent(whichUnit)
end

--===========================================================================
function SelectUnitSingle(whichUnit)
end

--===========================================================================
function SelectGroupBJEnum()
end

--===========================================================================
function SelectGroupBJ(g)
end

--===========================================================================
function SelectUnitAdd(whichUnit)
end

--===========================================================================
function SelectUnitRemove(whichUnit)
end

--===========================================================================
function ClearSelectionForPlayer(whichPlayer)
end

--===========================================================================
function SelectUnitForPlayerSingle(whichUnit, whichPlayer)
end

--===========================================================================
function SelectGroupForPlayerBJ(g, whichPlayer)
end

--===========================================================================
function SelectUnitAddForPlayer(whichUnit, whichPlayer)
end

--===========================================================================
function SelectUnitRemoveForPlayer(whichUnit, whichPlayer)
end

--===========================================================================
function SetUnitLifeBJ(whichUnit, newValue)
end

--===========================================================================
function SetUnitManaBJ(whichUnit, newValue)
end

--===========================================================================
function SetUnitLifePercentBJ(whichUnit, percent)
end

--===========================================================================
function SetUnitManaPercentBJ(whichUnit, percent)
end

--===========================================================================
function IsUnitDeadBJ(whichUnit)
end

--===========================================================================
function IsUnitAliveBJ(whichUnit)
end

--===========================================================================
function IsUnitGroupDeadBJEnum()
end

--===========================================================================
--)true if every unit of the group is dead.
--
function IsUnitGroupDeadBJ(g)
end

--===========================================================================
function IsUnitGroupEmptyBJEnum()
end

--===========================================================================
--)true if the group contains no units.
--
function IsUnitGroupEmptyBJ(g)
end

--===========================================================================
function IsUnitGroupInRectBJEnum()
end

--===========================================================================
--)true if every unit of the group is within the given rect.
--
function IsUnitGroupInRectBJ(g, r)
end

--===========================================================================
function IsUnitHiddenBJ(whichUnit)
end

--===========================================================================
function ShowUnitHide(whichUnit)
end

--===========================================================================
function ShowUnitShow(whichUnit)
end

--===========================================================================
function IssueHauntOrderAtLocBJFilter()
end

--===========================================================================
function IssueHauntOrderAtLocBJ(whichPeon, loc)
end

--===========================================================================
function IssueBuildOrderByIdLocBJ(whichPeon, Id, loc)
end

--===========================================================================
function IssueTrainOrderByIdBJ(whichUnit, Id)
end

--===========================================================================
function GroupTrainOrderByIdBJ(g, Id)
end

--===========================================================================
function IssueUpgradeOrderByIdBJ(whichUnit, techId)
end

--===========================================================================
function GetAttackedUnitBJ()
end

--===========================================================================
function SetUnitFlyHeightBJ(whichUnit, newHeight, rate)
end

--===========================================================================
function SetUnitTurnSpeedBJ(whichUnit, turnSpeed)
end

--===========================================================================
function SetUnitPropWindowBJ(whichUnit, propWindow)
end

--===========================================================================
function GetUnitPropWindowBJ(whichUnit)
end

--===========================================================================
function GetUnitDefaultPropWindowBJ(whichUnit)
end

--===========================================================================
function SetUnitBlendTimeBJ(whichUnit, blendTime)
end

--===========================================================================
function SetUnitAcquireRangeBJ(whichUnit, acquireRange)
end

--===========================================================================
function UnitSetCanSleepBJ(whichUnit, canSleep)
end

--===========================================================================
function UnitCanSleepBJ(whichUnit)
end

--===========================================================================
function UnitWakeUpBJ(whichUnit)
end

--===========================================================================
function UnitIsSleepingBJ(whichUnit)
end

--===========================================================================
function WakePlayerUnitsEnum()
end

--===========================================================================
function WakePlayerUnits(whichPlayer)
end

--===========================================================================
function EnableCreepSleepBJ(enable)
end

--===========================================================================
function UnitGenerateAlarms(whichUnit, generate)
end

--===========================================================================
function DoesUnitGenerateAlarms(whichUnit)
end

--===========================================================================
function PauseAllUnitsBJEnum()
end

--===========================================================================
-- Pause all units
function PauseAllUnitsBJ(pause)
end

--===========================================================================
function PauseUnitBJ(pause, whichUnit)
end

--===========================================================================
function IsUnitPausedBJ(whichUnit)
end

--===========================================================================
function UnitPauseTimedLifeBJ(flag, whichUnit)
end

--===========================================================================
function UnitApplyTimedLifeBJ(duration, buffId, whichUnit)
end

--===========================================================================
function UnitShareVisionBJ(share, whichUnit, whichPlayer)
end

--===========================================================================
function UnitRemoveBuffsExBJ(polarity, resist, whichUnit, bTLife, bAura)
end

--===========================================================================
function UnitRemoveAbilityBJ(abilityId, whichUnit)
end

--===========================================================================
function UnitAddAbilityBJ(abilityId, whichUnit)
end

--===========================================================================
function UnitRemoveTypeBJ(whichType, whichUnit)
end

--===========================================================================
function UnitAddTypeBJ(whichType, whichUnit)
end

--===========================================================================
function UnitMakeAbilityPermanentBJ(permanent, abilityId, whichUnit)
end

--===========================================================================
function SetUnitExplodedBJ(whichUnit, exploded)
end

--===========================================================================
function ExplodeUnitBJ(whichUnit)
end

--===========================================================================
function GetTransportUnitBJ()
end

--===========================================================================
function GetLoadedUnitBJ()
end

--===========================================================================
function IsUnitInTransportBJ(whichUnit, whichTransport)
end

--===========================================================================
function IsUnitLoadedBJ(whichUnit)
end

--===========================================================================
function IsUnitIllusionBJ(whichUnit)
end

--===========================================================================
-- This attempts to replace a unit with a new unit type by creating a new
-- unit of the desired type using the old unit's location, facing, etc.
--
function ReplaceUnitBJ(whichUnit, newUnitId, unitStateMethod)
end

--===========================================================================
function GetLastReplacedUnitBJ()
end

--===========================================================================
function SetUnitPositionLocFacingBJ(whichUnit, loc, facing)
end

--===========================================================================
function SetUnitPositionLocFacingLocBJ(whichUnit, loc, lookAt)
end

--===========================================================================
function AddItemToStockBJ(itemId, whichUnit, currentStock, stockMax)
end

--===========================================================================
function AddUnitToStockBJ(unitId, whichUnit, currentStock, stockMax)
end

--===========================================================================
function RemoveItemFromStockBJ(itemId, whichUnit)
end

--===========================================================================
function RemoveUnitFromStockBJ(unitId, whichUnit)
end

--===========================================================================
function SetUnitUseFoodBJ(enable, whichUnit)
end

--===========================================================================
function UnitDamagePointLoc(whichUnit, delay, radius, loc, amount, whichAttack, whichDamage)
end

--===========================================================================
function UnitDamageTargetBJ(whichUnit, target, amount, whichAttack, whichDamage)
end



--***************************************************************************
--*
--*  Destructable Utility Functions
--*
--***************************************************************************

--===========================================================================
function CreateDestructableLoc(objectid, loc, facing, scale, variation)
end

--===========================================================================
function CreateDeadDestructableLocBJ(objectid, loc, facing, scale, variation)
end

--===========================================================================
function GetLastCreatedDestructable()
end

--===========================================================================
function ShowDestructableBJ(flag, d)
end

--===========================================================================
function SetDestructableInvulnerableBJ(d, flag)
end

--===========================================================================
function IsDestructableInvulnerableBJ(d)
end

--===========================================================================
function GetDestructableLoc(whichDestructable)
end

--===========================================================================
function EnumDestructablesInRectAll(r, actionFunc)
end

--===========================================================================
function EnumDestructablesInCircleBJFilter()
end

--===========================================================================
function IsDestructableDeadBJ(d)
end

--===========================================================================
function IsDestructableAliveBJ(d)
end

--===========================================================================
-- See GroupPickRandomUnitEnum for the details of this algorithm.
--
function RandomDestructableInRectBJEnum()
end

--===========================================================================
-- Picks a random destructable from within a rect, matching a condition
--
function RandomDestructableInRectBJ(r, filter)
end

--===========================================================================
-- Picks a random destructable from within a rect
--
function RandomDestructableInRectSimpleBJ(r)
end

--===========================================================================
-- Enumerates within a rect, with a filter to narrow the enumeration down
-- objects within a circular area.
--
function EnumDestructablesInCircleBJ(radius, loc, actionFunc)
end

--===========================================================================
function SetDestructableLifePercentBJ(d, percent)
    SetDestructableLife(d, GetDestructableMaxLife(d) * percent * 0.01)
end

--===========================================================================
function SetDestructableMaxLifeBJ(d, max)
    SetDestructableMaxLife(d, max)
end

--===========================================================================
function ModifyGateBJ(gateOperation, d)
    if (gateOperation == bj_GATEOPERATION_CLOSE) then
        if (GetDestructableLife(d) <= 0) then
            DestructableRestoreLife(d, GetDestructableMaxLife(d), true)
        end
        SetDestructableAnimation(d, "stand")
    elseif (gateOperation == bj_GATEOPERATION_OPEN) then
        if (GetDestructableLife(d) > 0) then
            KillDestructable(d)
        end
        SetDestructableAnimation(d, "death alternate")
    elseif (gateOperation == bj_GATEOPERATION_DESTROY) then
        if (GetDestructableLife(d) > 0) then
            KillDestructable(d)
        end
        SetDestructableAnimation(d, "death")
    else
        -- Unrecognized gate state - ignore the request.
    end
end

--===========================================================================
-- Determine the elevator's height from its occlusion height.
--
function GetElevatorHeight(d)
    local height

    height = 1 + R2I(GetDestructableOccluderHeight(d) / bj_CLIFFHEIGHT)
    if (height < 1) or (height > 3) then
        height = 1
    end
    return height
end

--===========================================================================
-- To properly animate an elevator, we must know not only what height we
-- want to change to, but also what height we are currently at.  This code
-- determines the elevator's current height from its occlusion height.
-- Arbitrarily changing an elevator's occlusion height is thus inadvisable.
--
function ChangeElevatorHeight(d, newHeight)
    local oldHeight

    -- Cap the new height within the supported range.
    newHeight = IMaxBJ(1, newHeight)
    newHeight = IMinBJ(3, newHeight)

    -- Find out what height the elevator is already at.
    oldHeight = GetElevatorHeight(d)

    -- the elevator's occlusion height.
    SetDestructableOccluderHeight(d, bj_CLIFFHEIGHT * (newHeight - 1))

    if (newHeight == 1) then
        if (oldHeight == 2) then
            SetDestructableAnimation(d, "birth")
            QueueDestructableAnimation(d, "stand")
        elseif (oldHeight == 3) then
            SetDestructableAnimation(d, "birth third")
            QueueDestructableAnimation(d, "stand")
        else
            -- Unrecognized old height - snap to new height.
            SetDestructableAnimation(d, "stand")
        end
    elseif (newHeight == 2) then
        if (oldHeight == 1) then
            SetDestructableAnimation(d, "death")
            QueueDestructableAnimation(d, "stand second")
        elseif (oldHeight == 3) then
            SetDestructableAnimation(d, "birth second")
            QueueDestructableAnimation(d, "stand second")
        else
            -- Unrecognized old height - snap to new height.
            SetDestructableAnimation(d, "stand second")
        end
    elseif (newHeight == 3) then
        if (oldHeight == 1) then
            SetDestructableAnimation(d, "death third")
            QueueDestructableAnimation(d, "stand third")
        elseif (oldHeight == 2) then
            SetDestructableAnimation(d, "death second")
            QueueDestructableAnimation(d, "stand third")
        else
            -- Unrecognized old height - snap to new height.
            SetDestructableAnimation(d, "stand third")
        end
    else
        -- Unrecognized new height - ignore the request.
    end
end

--===========================================================================
-- Grab the unit and throw his own coords in his face, forcing him to push
-- and shove until he finds a spot where noone will bother him.
--
function NudgeUnitsInRectEnum()
    local unit
    nudgee = GetEnumUnit()

    SetUnitPosition(nudgee, GetUnitX(nudgee), GetUnitY(nudgee))
end

--===========================================================================
function NudgeItemsInRectEnum()
    local item
    nudgee = GetEnumItem()

    SetItemPosition(nudgee, GetItemX(nudgee), GetItemY(nudgee))
end

--===========================================================================
-- Nudge the items and units within a given rect ever so gently, so as to
-- encourage them to find locations where they can peacefully coexist with
-- pathing restrictions and live happy, fruitful lives.
--
function NudgeObjectsInRect(nudgeArea)
end

--===========================================================================
function NearbyElevatorExistsEnum()
end

--===========================================================================
function NearbyElevatorExists(x, y)
end

--===========================================================================
function FindElevatorWallBlockerEnum()
end

--===========================================================================
-- This toggles pathing on or off for one wall of an elevator by killing
-- or reviving a pathing blocker at the appropriate location (and creating
-- the pathing blocker in the first place, if it does not yet exist).
--
function ChangeElevatorWallBlocker(x, y, facing, open)
end

--===========================================================================
function ChangeElevatorWalls(open, walls, d)
end



--***************************************************************************
--*
--*  Neutral Building Utility Functions
--*
--***************************************************************************

--===========================================================================
function WaygateActivateBJ(activate, waygate)
end

--===========================================================================
function WaygateIsActiveBJ(waygate)
end

--===========================================================================
function WaygateSetDestinationLocBJ(waygate, loc)
end

--===========================================================================
function WaygateGetDestinationLocBJ(waygate)
end

--===========================================================================
function UnitSetUsesAltIconBJ(flag, whichUnit)
end



--***************************************************************************
--*
--*  UI Utility Functions
--*
--***************************************************************************

--===========================================================================
function ForceUIKeyBJ(whichPlayer, key)
end

--===========================================================================
function ForceUICancelBJ(whichPlayer)
end



--***************************************************************************
--*
--*  Group and Force Utility Functions
--*
--***************************************************************************

--===========================================================================
function ForGroupBJ(whichGroup, callback)
end

--===========================================================================
function GroupAddUnitSimple(whichUnit, whichGroup)
end

--===========================================================================
function GroupRemoveUnitSimple(whichUnit, whichGroup)
end

--===========================================================================
function GroupAddGroupEnum()
end

--===========================================================================
function GroupAddGroup(sourceGroup, destGroup)
end

--===========================================================================
function GroupRemoveGroupEnum()
end

--===========================================================================
function GroupRemoveGroup(sourceGroup, destGroup)
end

--===========================================================================
function ForceAddPlayerSimple(whichPlayer, whichForce)
end

--===========================================================================
function ForceRemovePlayerSimple(whichPlayer, whichForce)
end

--===========================================================================
-- Picks a random unit from a group.
--
function GroupPickRandomUnit(whichGroup)
end

--===========================================================================
-- See GroupPickRandomUnitEnum for the details of this algorithm.
--
function ForcePickRandomPlayerEnum()
end

--===========================================================================
-- Picks a random player from a force.
--
function ForcePickRandomPlayer(whichForce)
end

--===========================================================================
function EnumUnitsSelected(whichPlayer, enumFilter, enumAction)
end

--===========================================================================
function GetUnitsInRectMatching(r, filter)
end

--===========================================================================
function GetUnitsInRectAll(r)
end

--===========================================================================
function GetUnitsInRectOfPlayerFilter()
end

--===========================================================================
function GetUnitsInRectOfPlayer(r, whichPlayer)
end

--===========================================================================
function GetUnitsInRangeOfLocMatching(radius, whichLocation, filter)
end

--===========================================================================
function GetUnitsInRangeOfLocAll(radius, whichLocation)
end

--===========================================================================
function GetUnitsOfTypeIdAllFilter()
end

--===========================================================================
function GetUnitsOfTypeIdAll(unitid)
end

--===========================================================================
function GetUnitsOfPlayerMatching(whichPlayer, filter)
end

--===========================================================================
function GetUnitsOfPlayerAll(whichPlayer)
end

--===========================================================================
function GetUnitsOfPlayerAndTypeIdFilter()
end

--===========================================================================
function GetUnitsOfPlayerAndTypeId(whichPlayer, id)
end

--===========================================================================
function GetUnitsSelectedAll(whichPlayer)
end

--===========================================================================
function GetForceOfPlayer(whichPlayer)
end

--===========================================================================
function GetPlayersAll()
end

--===========================================================================
function GetPlayersByMapControl(whichControl)
end

--===========================================================================
function GetPlayersAllies(whichPlayer)
end

--===========================================================================
function GetPlayersEnemies(whichPlayer)
end

--===========================================================================
function GetPlayersMatching(filter)
end

--===========================================================================
function CountUnitsInGroupEnum()
end

--===========================================================================
function CountUnitsInGroup(g)
end

--===========================================================================
function CountPlayersInForceEnum()
end

--===========================================================================
function CountPlayersInForceBJ(f)
end

--===========================================================================
function GetRandomSubGroupEnum()
end

--===========================================================================
function GetRandomSubGroup(count, sourceGroup)
end

--===========================================================================
function LivingPlayerUnitsOfTypeIdFilter()
end

--===========================================================================
function CountLivingPlayerUnitsOfTypeId(unitId, whichPlayer)
end



--***************************************************************************
--*
--*  Animation Utility Functions
--*
--***************************************************************************

--===========================================================================
function ResetUnitAnimation(whichUnit)
end

--===========================================================================
function SetUnitTimeScalePercent(whichUnit, percentScale)
end

--===========================================================================
function SetUnitScalePercent(whichUnit, percentScaleX, percentScaleY, percentScaleZ)
end

--===========================================================================
-- This version differs from the common.j interface in that the alpha value
-- is reversed so as to be displayed as transparency, and all four parameters
-- are treated as percentages rather than bytes.
--
function SetUnitVertexColorBJ(whichUnit, red, green, blue, transparency)
end

--===========================================================================
function UnitAddIndicatorBJ(whichUnit, red, green, blue, transparency)
end

--===========================================================================
function DestructableAddIndicatorBJ(whichDestructable, red, green, blue, transparency)
end

--===========================================================================
function ItemAddIndicatorBJ(whichItem, red, green, blue, transparency)
end

--===========================================================================
-- Sets a unit's facing to point directly at a location.
--
function SetUnitFacingToFaceLocTimed(whichUnit, target, duration)
end

--===========================================================================
-- Sets a unit's facing to point directly at another unit.
--
function SetUnitFacingToFaceUnitTimed(whichUnit, target, duration)
end

--===========================================================================
function QueueUnitAnimationBJ(whichUnit, whichAnimation)
end

--===========================================================================
function SetDestructableAnimationBJ(d, whichAnimation)
end

--===========================================================================
function QueueDestructableAnimationBJ(d, whichAnimation)
end

--===========================================================================
function SetDestAnimationSpeedPercent(d, percentScale)
end



--***************************************************************************
--*
--*  Dialog Utility Functions
--*
--***************************************************************************

--===========================================================================
function DialogDisplayBJ(flag, whichDialog, whichPlayer)
end

--===========================================================================
function DialogSetMessageBJ(whichDialog, message)
end

--===========================================================================
function DialogAddButtonBJ(whichDialog, buttonText)
end

--===========================================================================
function DialogAddButtonWithHotkeyBJ(whichDialog, buttonText, hotkey)
end

--===========================================================================
function DialogClearBJ(whichDialog)
end

--===========================================================================
function GetLastCreatedButtonBJ()
end

--===========================================================================
function GetClickedButtonBJ()
end

--===========================================================================
function GetClickedDialogBJ()
end



--***************************************************************************
--*
--*  Alliance Utility Functions
--*
--***************************************************************************

--===========================================================================
function SetPlayerAllianceBJ(sourcePlayer, whichAllianceSetting, value, otherPlayer)
end

--===========================================================================
-- all flags used by the in-game "Ally" checkbox.
--
function SetPlayerAllianceStateAllyBJ(sourcePlayer, otherPlayer, flag)
end

--===========================================================================
-- all flags used by the in-game "Shared Vision" checkbox.
--
function SetPlayerAllianceStateVisionBJ(sourcePlayer, otherPlayer, flag)
end

--===========================================================================
-- all flags used by the in-game "Shared Units" checkbox.
--
function SetPlayerAllianceStateControlBJ(sourcePlayer, otherPlayer, flag)
end

--===========================================================================
-- all flags used by the in-game "Shared Units" checkbox with the Full
-- Shared Unit Control feature enabled.
--
function SetPlayerAllianceStateFullControlBJ(sourcePlayer, otherPlayer, flag)
end

--===========================================================================
function SetPlayerAllianceStateBJ(sourcePlayer, otherPlayer, allianceState)
end

--===========================================================================
-- the alliance states for an entire force towards another force.
--
function SetForceAllianceStateBJ(sourceForce, targetForce, allianceState)
end

--===========================================================================
-- Test to see if two players are co-allied (allied with each other).
--
function PlayersAreCoAllied(playerA, playerB)
end

--===========================================================================
-- Force (whichPlayer) AI player to share vision and advanced unit control
-- with all AI players of its allies.
--
function ShareEverythingWithTeamAI(whichPlayer)
end

--===========================================================================
-- Force (whichPlayer) to share vision and advanced unit control with all of his/her allies.
--
function ShareEverythingWithTeam(whichPlayer)
end

--===========================================================================
-- Creates a 'Neutral Victim' player slot.  This slot is passive towards all
-- other players, but all other players are aggressive towards him/her.
--
function ConfigureNeutralVictim()
end

--===========================================================================
function MakeUnitsPassiveForPlayerEnum()
end

--===========================================================================
-- Change ownership for every unit of (whichPlayer)'s team to neutral passive.
--
function MakeUnitsPassiveForPlayer(whichPlayer)
end

--===========================================================================
-- Change ownership for every unit of (whichPlayer)'s team to neutral passive.
--
function MakeUnitsPassiveForTeam(whichPlayer)
end

--===========================================================================
-- Determine whether or not victory/defeat is disabled via cheat codes.
--
function AllowVictoryDefeat(gameResult)
end

--===========================================================================
function EndGameBJ()
end

--===========================================================================
function MeleeVictoryDialogBJ(whichPlayer, leftGame)
end

--===========================================================================
function GameOverDialogBJ(whichPlayer, leftGame)
end

--===========================================================================
function RemovePlayerPreserveUnitsBJ(whichPlayer, gameResult, leftGame)
end

--===========================================================================
function CustomVictoryOkBJ()
end

--===========================================================================
function CustomVictoryQuitBJ()
end

--===========================================================================
function CustomVictoryDialogBJ(whichPlayer)
end

--===========================================================================
function CustomVictorySkipBJ(whichPlayer)
end

--===========================================================================
function CustomVictoryBJ(whichPlayer, showDialog, showScores)
end

--===========================================================================
function CustomDefeatRestartBJ()
end

--===========================================================================
function CustomDefeatReduceDifficultyBJ()
end

--===========================================================================
function CustomDefeatLoadBJ()
end

--===========================================================================
function CustomDefeatQuitBJ()
end

--===========================================================================
function CustomDefeatDialogBJ(whichPlayer, message)
end

--===========================================================================
function CustomDefeatBJ(whichPlayer, message)
end

--===========================================================================
function SetNextLevelBJ(nextLevel)
end

--===========================================================================
function SetPlayerOnScoreScreenBJ(flag, whichPlayer)
end



--***************************************************************************
--*
--*  Quest Utility Functions
--*
--***************************************************************************

--===========================================================================
function CreateQuestBJ(questType, title, description, iconPath)
end

--===========================================================================
function DestroyQuestBJ(whichQuest)
end

--===========================================================================
function QuestSetEnabledBJ(enabled, whichQuest)
end

--===========================================================================
function QuestSetTitleBJ(whichQuest, title)
end

--===========================================================================
function QuestSetDescriptionBJ(whichQuest, description)
end

--===========================================================================
function QuestSetCompletedBJ(whichQuest, completed)
end

--===========================================================================
function QuestSetFailedBJ(whichQuest, failed)
end

--===========================================================================
function QuestSetDiscoveredBJ(whichQuest, discovered)
end

--===========================================================================
function GetLastCreatedQuestBJ()
end

--===========================================================================
function CreateQuestItemBJ(whichQuest, description)
end

--===========================================================================
function QuestItemSetDescriptionBJ(whichQuestItem, description)
end

--===========================================================================
function QuestItemSetCompletedBJ(whichQuestItem, completed)
end

--===========================================================================
function GetLastCreatedQuestItemBJ()
end

--===========================================================================
function CreateDefeatConditionBJ(description)
end

--===========================================================================
function DestroyDefeatConditionBJ(whichCondition)
end

--===========================================================================
function DefeatConditionSetDescriptionBJ(whichCondition, description)
end

--===========================================================================
function GetLastCreatedDefeatConditionBJ()
end

--===========================================================================
function FlashQuestDialogButtonBJ()
end

--===========================================================================
function QuestMessageBJ(f, messageType, message)
end



--***************************************************************************
--*
--*  Timer Utility Functions
--*
--***************************************************************************

--===========================================================================
function StartTimerBJ(t, periodic, timeout)
end

--===========================================================================
function CreateTimerBJ(periodic, timeout)
end

--===========================================================================
function DestroyTimerBJ(whichTimer)
end

--===========================================================================
function PauseTimerBJ(pause, whichTimer)
end

--===========================================================================
function GetLastCreatedTimerBJ()
end

--===========================================================================
function CreateTimerDialogBJ(t, title)
end

--===========================================================================
function DestroyTimerDialogBJ(td)
end

--===========================================================================
function TimerDialogSetTitleBJ(td, title)
end

--===========================================================================
function TimerDialogSetTitleColorBJ(td, red, green, blue, transparency)
end

--===========================================================================
function TimerDialogSetTimeColorBJ(td, red, green, blue, transparency)
end

--===========================================================================
function TimerDialogSetSpeedBJ(td, speedMultFactor)
end

--===========================================================================
function TimerDialogDisplayForPlayerBJ(show, td, whichPlayer)
end

--===========================================================================
function TimerDialogDisplayBJ(show, td)
end

--===========================================================================
function GetLastCreatedTimerDialogBJ()
end



--***************************************************************************
--*
--*  Leaderboard Utility Functions
--*
--***************************************************************************

--===========================================================================
function LeaderboardResizeBJ(lb)
end

--===========================================================================
function LeaderboardSetPlayerItemValueBJ(whichPlayer, lb, val)
end

--===========================================================================
function LeaderboardSetPlayerItemLabelBJ(whichPlayer, lb, val)
end

--===========================================================================
function LeaderboardSetPlayerItemStyleBJ(whichPlayer, lb, showLabel, showValue, showIcon)
end

--===========================================================================
function LeaderboardSetPlayerItemLabelColorBJ(whichPlayer, lb, red, green, blue, transparency)
end

--===========================================================================
function LeaderboardSetPlayerItemValueColorBJ(whichPlayer, lb, red, green, blue, transparency)
end

--===========================================================================
function LeaderboardSetLabelColorBJ(lb, red, green, blue, transparency)
end

--===========================================================================
function LeaderboardSetValueColorBJ(lb, red, green, blue, transparency)
end

--===========================================================================
function LeaderboardSetLabelBJ(lb, label)
end

--===========================================================================
function LeaderboardSetStyleBJ(lb, showLabel, showNames, showValues, showIcons)
end

--===========================================================================
function LeaderboardGetItemCountBJ(lb)
end

--===========================================================================
function LeaderboardHasPlayerItemBJ(lb, whichPlayer)
end

--===========================================================================
function ForceSetLeaderboardBJ(lb, toForce)
end

--===========================================================================
function CreateLeaderboardBJ(toForce, label)
end

--===========================================================================
function DestroyLeaderboardBJ(lb)
end

--===========================================================================
function LeaderboardDisplayBJ(show, lb)
end

--===========================================================================
function LeaderboardAddItemBJ(whichPlayer, lb, label, value)
end

--===========================================================================
function LeaderboardRemovePlayerItemBJ(whichPlayer, lb)
end

--===========================================================================
function LeaderboardSortItemsBJ(lb, sortType, ascending)
end

--===========================================================================
function LeaderboardSortItemsByPlayerBJ(lb, ascending)
end

--===========================================================================
function LeaderboardSortItemsByLabelBJ(lb, ascending)
end

--===========================================================================
function LeaderboardGetPlayerIndexBJ(whichPlayer, lb)
end

--===========================================================================
--)the player who is occupying a specified position in a leaderboard.
-- The position parameter is expected in the range of 1..16.
--
function LeaderboardGetIndexedPlayerBJ(position, lb)
end

--===========================================================================
function PlayerGetLeaderboardBJ(whichPlayer)
end

--===========================================================================
function GetLastCreatedLeaderboard()
end

--***************************************************************************
--*
--*  Multiboard Utility Functions
--*
--***************************************************************************

--===========================================================================
function CreateMultiboardBJ(cols, rows, title)
end

--===========================================================================
function DestroyMultiboardBJ(mb)
end

--===========================================================================
function GetLastCreatedMultiboard()
end

--===========================================================================
function MultiboardDisplayBJ(show, mb)
end

--===========================================================================
function MultiboardMinimizeBJ(minimize, mb)
end

--===========================================================================
function MultiboardSetTitleTextColorBJ(mb, red, green, blue, transparency)
end

--===========================================================================
function MultiboardAllowDisplayBJ(flag)
end

--===========================================================================
function MultiboardSetItemStyleBJ(mb, col, row, showValue, showIcon)
end

--===========================================================================
function MultiboardSetItemValueBJ(mb, col, row, val)
end

--===========================================================================
function MultiboardSetItemColorBJ(mb, col, row, red, green, blue, transparency)
end

--===========================================================================
function MultiboardSetItemWidthBJ(mb, col, row, width)
end

--===========================================================================
function MultiboardSetItemIconBJ(mb, col, row, iconFileName)
end



--***************************************************************************
--*
--*  Text Tag Utility Functions
--*
--***************************************************************************

--===========================================================================
-- Scale the font size linearly such that size 10 equates to height 0.023.
-- Screen-relative font heights are harder to grasp and than font sizes.
--
function TextTagSize2Height(size)
end

--===========================================================================
-- Scale the speed linearly such that speed 128 equates to 0.071.
-- Screen-relative speeds are hard to grasp.
--
function TextTagSpeed2Velocity(speed)
end

--===========================================================================
function SetTextTagColorBJ(tt, red, green, blue, transparency)
end

--===========================================================================
function SetTextTagVelocityBJ(tt, speed, angle)
end

--===========================================================================
function SetTextTagTextBJ(tt, s, size)
end

--===========================================================================
function SetTextTagPosBJ(tt, loc, zOffset)
end

--===========================================================================
function SetTextTagPosUnitBJ(tt, whichUnit, zOffset)
end

--===========================================================================
function SetTextTagSuspendedBJ(tt, flag)
end

--===========================================================================
function SetTextTagPermanentBJ(tt, flag)
end

--===========================================================================
function SetTextTagAgeBJ(tt, age)
end

--===========================================================================
function SetTextTagLifespanBJ(tt, lifespan)
end

--===========================================================================
function SetTextTagFadepointBJ(tt, fadepoint)
end

--===========================================================================
function CreateTextTagLocBJ(s, loc, zOffset, size, red, green, blue, transparency)
end

--===========================================================================
function CreateTextTagUnitBJ(s, whichUnit, zOffset, size, red, green, blue, transparency)
end

--===========================================================================
function DestroyTextTagBJ(tt)
end

--===========================================================================
function ShowTextTagForceBJ(show, tt, whichForce)
end

--===========================================================================
function GetLastCreatedTextTag()
end



--***************************************************************************
--*
--*  Cinematic Utility Functions
--*
--***************************************************************************

--===========================================================================
function PauseGameOn()
end

--===========================================================================
function PauseGameOff()
end

--===========================================================================
function SetUserControlForceOn(whichForce)
end

--===========================================================================
function SetUserControlForceOff(whichForce)
end

--===========================================================================
function ShowInterfaceForceOn(whichForce, fadeDuration)
end

--===========================================================================
function ShowInterfaceForceOff(whichForce, fadeDuration)
end

--===========================================================================
function PingMinimapForForce(whichForce, x, y, duration)
end

--===========================================================================
function PingMinimapLocForForce(whichForce, loc, duration)
end

--===========================================================================
function PingMinimapForPlayer(whichPlayer, x, y, duration)
end

--===========================================================================
function PingMinimapLocForPlayer(whichPlayer, loc, duration)
end

--===========================================================================
function PingMinimapForForceEx(whichForce, x, y, duration, style, red, green, blue)
end

--===========================================================================
function PingMinimapLocForForceEx(whichForce, loc, duration, style, red, green, blue)
end

--===========================================================================
function EnableWorldFogBoundaryBJ(enable, f)
end

--===========================================================================
function EnableOcclusionBJ(enable, f)
end



--***************************************************************************
--*
--*  Cinematic Transmission Utility Functions
--*
--***************************************************************************

--===========================================================================
-- If cancelled, stop the sound and end the cinematic scene.
--
function CancelCineSceneBJ()
end

--===========================================================================
-- Init a trigger to listen for END_CINEMATIC events and respond to them if
-- a cinematic scene is in progress.  For performance reasons, this should
-- only be called once a cinematic scene has been started, so that maps
-- lacking such scenes do not bother to register for these events.
--
function TryInitCinematicBehaviorBJ()
end

--===========================================================================
function SetCinematicSceneBJ(soundHandle, portraitUnitId, color, speakerTitle, text, sceneDuration, voiceoverDuration)
end

--===========================================================================
function GetTransmissionDuration(soundHandle, timeType, timeVal)
end

--===========================================================================
function WaitTransmissionDuration(soundHandle, timeType, timeVal)
end

--===========================================================================
function DoTransmissionBasicsXYBJ(unitId, color, x, y, soundHandle, unitName, message, duration)
end

--===========================================================================
-- Display a text message to a Player Group with an accompanying sound,
-- portrait, speech indicator, and all that good stuff.
--   - Query duration of sound
--   - Play sound
--   - Display text message for duration
--   - Display animating portrait for duration
--   - Display a speech indicator for the unit
--   - Ping the minimap
--
function TransmissionFromUnitWithNameBJ(toForce, whichUnit, unitName, soundHandle, message, timeType, timeVal, wait)
end

--===========================================================================
function PlayDialogueFromSpeakerEx(toForce, speaker, speakerType, soundHandle, timeType, timeVal, wait)
end

--===========================================================================
function PlayDialogueFromSpeakerTypeEx(toForce, fromPlayer, speakerType, loc, soundHandle, timeType, timeVal, wait)
end

--===========================================================================
-- This operates like TransmissionFromUnitWithNameBJ, but for a unit type
-- rather than a unit instance.  As such, no speech indicator is employed.
--
function TransmissionFromUnitTypeWithNameBJ(toForce, fromPlayer, Id, unitName, loc, soundHandle, message, timeType, timeVal, wait)
end

--===========================================================================
function GetLastTransmissionDurationBJ()
end

--===========================================================================
function ForceCinematicSubtitlesBJ(flag)
end


--***************************************************************************
--*
--*  Cinematic Mode Utility Functions
--*
--***************************************************************************

--===========================================================================
-- Makes many common UI settings changes at once, for use when beginning and
-- ending cinematic sequences.  Note that some affects apply to all players,
-- such as game speed.  This is unavoidable.
--   - Clear the screen of text messages
--   - Hide interface UI (letterbox mode)
--   - Hide game messages (ally under attack, etc.)
--   - Disable user control
--   - Disable occlusion
--   - game speed (for all players)
--   - Lock game speed (for all players)
--   - Disable black mask (for all players)
--   - Disable fog of war (for all players)
--   - Disable world boundary fog (for all players)
--   - Dim non-speech sound channels
--   - End any outstanding music themes
--   - Fix the random seed to a value
--   - Rethe camera smoothing factor
--
function CinematicModeExBJ(cineMode, forForce, interfaceFadeTime)
end

--===========================================================================
function CinematicModeBJ(cineMode, forForce)
end



--***************************************************************************
--*
--*  Cinematic Filter Utility Functions
--*
--***************************************************************************

--===========================================================================
function DisplayCineFilterBJ(flag)
end

--===========================================================================
function CinematicFadeCommonBJ(red, green, blue, duration, tex, startTrans, endTrans)
end

--===========================================================================
function FinishCinematicFadeBJ()
end

--===========================================================================
function FinishCinematicFadeAfterBJ(duration)
end

--===========================================================================
function ContinueCinematicFadeBJ()
end

--===========================================================================
function ContinueCinematicFadeAfterBJ(duration, red, green, blue, trans, tex)
end

--===========================================================================
function AbortCinematicFadeBJ()
end

--===========================================================================
function CinematicFadeBJ(fadetype, duration, tex, red, green, blue, trans)
end

--===========================================================================
function CinematicFilterGenericBJ(duration, bmode, tex, red0, green0, blue0, trans0, red1, green1, blue1, trans1)
end



--***************************************************************************
--*
--*  Rescuable Unit Utility Functions
--*
--***************************************************************************

--===========================================================================
-- Rescues a unit for a player.  This performs the default rescue behavior,
-- including a rescue sound, flashing selection circle, ownership change,
-- and optionally a unit color change.
--
function RescueUnitBJ(whichUnit, rescuer, changeColor)
end

--===========================================================================
function TriggerActionUnitRescuedBJ()
end

--===========================================================================
-- Attempt to init triggers for default rescue behavior.  For performance
-- reasons, this should only be attempted if a player is to Rescuable,
-- or if a specific unit is thus flagged.
--
function TryInitRescuableTriggersBJ()
end

--===========================================================================
-- Determines whether or not rescued units automatically change color upon
-- being rescued.
--
function SetRescueUnitColorChangeBJ(changeColor)
end

--===========================================================================
-- Determines whether or not rescued buildings automatically change color
-- upon being rescued.
--
function SetRescueBuildingColorChangeBJ(changeColor)
end

--===========================================================================
function MakeUnitRescuableToForceBJEnum()
end

--===========================================================================
function MakeUnitRescuableToForceBJ(whichUnit, isRescuable, whichForce)
end

--===========================================================================
function InitRescuableBehaviorBJ()
end



--***************************************************************************
--*
--*  Research and Upgrade Utility Functions
--*
--***************************************************************************

--===========================================================================
function SetPlayerTechResearchedSwap(techid, levels, whichPlayer)
end

--===========================================================================
function SetPlayerTechMaxAllowedSwap(techid, maximum, whichPlayer)
end

--===========================================================================
function SetPlayerMaxHeroesAllowed(maximum, whichPlayer)
end

--===========================================================================
function GetPlayerTechCountSimple(techid, whichPlayer)
end

--===========================================================================
function GetPlayerTechMaxAllowedSwap(techid, whichPlayer)
end

--===========================================================================
function SetPlayerAbilityAvailableBJ(avail, abilid, whichPlayer)
end



--***************************************************************************
--*
--*  Campaign Utility Functions
--*
--***************************************************************************

function SetCampaignMenuRaceBJ(campaignNumber)
end

--===========================================================================
-- Converts a single campaign mission designation into campaign and mission
-- numbers.  The 1000's digit is considered the campaign index, and the 1's
-- digit is considered the mission index within that campaign.  This is done
-- so that the trigger for this can use a single drop-down to list all of
-- the campaign missions.
--
function SetMissionAvailableBJ(available, missionIndex)
end

--===========================================================================
function SetCampaignAvailableBJ(available, campaignNumber)
end

--===========================================================================
function SetCinematicAvailableBJ(available, cinematicIndex)
end

--===========================================================================
function InitGameCacheBJ(campaignFile)
end

--===========================================================================
function SaveGameCacheBJ(cache)
end

--===========================================================================
function GetLastCreatedGameCacheBJ()
end

--===========================================================================
function InitHashtableBJ()
end

--===========================================================================
function GetLastCreatedHashtableBJ()
end

--===========================================================================
function StoreBJ(value, key, missionKey, cache)
end

--===========================================================================
function StoreBJ(value, key, missionKey, cache)
end

--===========================================================================
function StoreBooleanBJ(value, key, missionKey, cache)
end

--===========================================================================
function StoreStringBJ(value, key, missionKey, cache)
end

--===========================================================================
function StoreUnitBJ(whichUnit, key, missionKey, cache)
end

--===========================================================================
function SaveBJ(value, key, missionKey, table)
end

--===========================================================================
function SaveBJ(value, key, missionKey, table)
end

--===========================================================================
function SaveBooleanBJ(value, key, missionKey, table)
end

--===========================================================================
function SaveStringBJ(value, key, missionKey, table)
end

--===========================================================================
function SavePlayerHandleBJ(whichPlayer, key, missionKey, table)
end

--===========================================================================
function SaveWidgetHandleBJ(whichWidget, key, missionKey, table)
end

--===========================================================================
function SaveDestructableHandleBJ(whichDestructable, key, missionKey, table)
end

--===========================================================================
function SaveItemHandleBJ(whichItem, key, missionKey, table)
end

--===========================================================================
function SaveUnitHandleBJ(whichUnit, key, missionKey, table)
end

--===========================================================================
function SaveAbilityHandleBJ(whichAbility, key, missionKey, table)
end

--===========================================================================
function SaveTimerHandleBJ(whichTimer, key, missionKey, table)
end

--===========================================================================
function SaveTriggerHandleBJ(whichTrigger, key, missionKey, table)
    return SaveTriggerHandle(table, missionKey, key, whichTrigger)
end

--===========================================================================
function SaveTriggerConditionHandleBJ(whichTriggercondition, key, missionKey, table)
end

--===========================================================================
function SaveTriggerActionHandleBJ(whichTriggeraction, key, missionKey, table)
end

--===========================================================================
function SaveTriggerEventHandleBJ(whichEvent, key, missionKey, table)
end

--===========================================================================
function SaveForceHandleBJ(whichForce, key, missionKey, table)
end

--===========================================================================
function SaveGroupHandleBJ(whichGroup, key, missionKey, table)
end

--===========================================================================
function SaveLocationHandleBJ(whichLocation, key, missionKey, table)
end

--===========================================================================
function SaveRectHandleBJ(whichRect, key, missionKey, table)
end

--===========================================================================
function SaveBooleanExprHandleBJ(whichBoolexpr, key, missionKey, table)
end

--===========================================================================
function SaveSoundHandleBJ(whichSound, key, missionKey, table)
end

--===========================================================================
function SaveEffectHandleBJ(whichEffect, key, missionKey, table)
end

--===========================================================================
function SaveUnitPoolHandleBJ(whichUnitpool, key, missionKey, table)
end

--===========================================================================
function SaveItemPoolHandleBJ(whichItempool, key, missionKey, table)
end

--===========================================================================
function SaveQuestHandleBJ(whichQuest, key, missionKey, table)
end

--===========================================================================
function SaveQuestItemHandleBJ(whichQuestitem, key, missionKey, table)
end

--===========================================================================
function SaveDefeatConditionHandleBJ(whichDefeatcondition, key, missionKey, table)
end

--===========================================================================
function SaveTimerDialogHandleBJ(whichTimerdialog, key, missionKey, table)
end

--===========================================================================
function SaveLeaderboardHandleBJ(whichLeaderboard, key, missionKey, table)
end

--===========================================================================
function SaveMultiboardHandleBJ(whichMultiboard, key, missionKey, table)
end

--===========================================================================
function SaveMultiboardItemHandleBJ(whichMultiboarditem, key, missionKey, table)
end

--===========================================================================
function SaveTrackableHandleBJ(whichTrackable, key, missionKey, table)
end

--===========================================================================
function SaveDialogHandleBJ(whichDialog, key, missionKey, table)
end

--===========================================================================
function SaveButtonHandleBJ(whichButton, key, missionKey, table)
end

--===========================================================================
function SaveTextTagHandleBJ(whichTexttag, key, missionKey, table)
end

--===========================================================================
function SaveLightningHandleBJ(whichLightning, key, missionKey, table)
end

--===========================================================================
function SaveImageHandleBJ(whichImage, key, missionKey, table)
end

--===========================================================================
function SaveUbersplatHandleBJ(whichUbersplat, key, missionKey, table)
end

--===========================================================================
function SaveRegionHandleBJ(whichRegion, key, missionKey, table)
end

--===========================================================================
function SaveFogStateHandleBJ(whichFogState, key, missionKey, table)
end

--===========================================================================
function SaveFogModifierHandleBJ(whichFogModifier, key, missionKey, table)
end

--===========================================================================
function SaveAgentHandleBJ(whichAgent, key, missionKey, table)
end

--===========================================================================
function SaveHashtableHandleBJ(whichHashtable, key, missionKey, table)
end

--===========================================================================
function GetStoredBJ(key, missionKey, cache)
end

--===========================================================================
function GetStoredBJ(key, missionKey, cache)
end

--===========================================================================
function GetStoredBooleanBJ(key, missionKey, cache)
end

--===========================================================================
function GetStoredStringBJ(key, missionKey, cache)
end

--===========================================================================
function LoadBJ(key, missionKey, table)
end

--===========================================================================
function LoadBJ(key, missionKey, table)
end

--===========================================================================
function LoadBooleanBJ(key, missionKey, table)
end

--===========================================================================
function LoadStringBJ(key, missionKey, table)
end

--===========================================================================
function LoadPlayerHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadWidgetHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadDestructableHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadItemHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadUnitHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadAbilityHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTimerHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTriggerHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTriggerConditionHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTriggerActionHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTriggerEventHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadForceHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadGroupHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadLocationHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadRectHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadBooleanExprHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadSoundHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadEffectHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadUnitPoolHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadItemPoolHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadQuestHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadQuestItemHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadDefeatConditionHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTimerDialogHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadLeaderboardHandleBJ(key, missionKey, table)
    return LoadLeaderboardHandle(table, missionKey, key)
end

--===========================================================================
function LoadMultiboardHandleBJ(key, missionKey, table)
    return LoadMultiboardHandle(table, missionKey, key)
end

--===========================================================================
function LoadMultiboardItemHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTrackableHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadDialogHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadButtonHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadTextTagHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadLightningHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadImageHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadUbersplatHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadRegionHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadFogStateHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadFogModifierHandleBJ(key, missionKey, table)
end

--===========================================================================
function LoadHashtableHandleBJ(key, missionKey, table)
end

--===========================================================================
function RestoreUnitLocFacingAngleBJ(key, missionKey, cache, forWhichPlayer, loc, facing)
end

--===========================================================================
function RestoreUnitLocFacingPointBJ(key, missionKey, cache, forWhichPlayer, loc, lookAt)
end

--===========================================================================
function GetLastRestoredUnitBJ()
end

--===========================================================================
function FlushGameCacheBJ(cache)
end

--===========================================================================
function FlushStoredMissionBJ(missionKey, cache)
end

--===========================================================================
function FlushParentHashtableBJ(table)
end

--===========================================================================
function FlushChildHashtableBJ(missionKey, table)
end

--===========================================================================
function HaveStoredValue(key, valueType, missionKey, cache)
end

--===========================================================================
function HaveSavedValue(key, valueType, missionKey, table)
end

--===========================================================================
function ShowCustomCampaignButton(show, whichButton)
end

--===========================================================================
function IsCustomCampaignButtonVisibile(whichButton)
end

--===========================================================================
-- Placeholder function for auto save feature
--===========================================================================
function SaveGameCheckPointBJ(mapSaveName, doCheckpointHint)
end

--===========================================================================
function LoadGameBJ(loadFileName, doScoreScreen)
end

--===========================================================================
function SaveAndChangeLevelBJ(saveFileName, newLevel, doScoreScreen)
end

--===========================================================================
function SaveAndLoadGameBJ(saveFileName, loadFileName, doScoreScreen)
end

--===========================================================================
function RenameSaveDirectoryBJ(sourceDirName, destDirName)
end

--===========================================================================
function RemoveSaveDirectoryBJ(sourceDirName)
end

--===========================================================================
function CopySaveGameBJ(sourceSaveName, destSaveName)
end



--***************************************************************************
--*
--*  Miscellaneous Utility Functions
--*
--***************************************************************************

--===========================================================================
function GetPlayerStartLocationX(whichPlayer)
end

--===========================================================================
function GetPlayerStartLocationY(whichPlayer)
end

--===========================================================================
function GetPlayerStartLocationLoc(whichPlayer)
end

--===========================================================================
function GetRectCenter(whichRect)
end

--===========================================================================
function IsPlayerSlotState(whichPlayer, whichState)
end

--===========================================================================
function GetFadeFromSeconds(seconds)
end

--===========================================================================
function GetFadeFromSecondsAs(seconds)
end

--===========================================================================
function AdjustPlayerStateSimpleBJ(whichPlayer, whichPlayerState, delta)
end

--===========================================================================
function AdjustPlayerStateBJ(delta, whichPlayer, whichPlayerState)
end

--===========================================================================
function SetPlayerStateBJ(whichPlayer, whichPlayerState, value)
end

--===========================================================================
function SetPlayerFlagBJ(whichPlayerFlag, flag, whichPlayer)
end

--===========================================================================
function SetPlayerTaxRateBJ(rate, whichResource, sourcePlayer, otherPlayer)
end

--===========================================================================
function GetPlayerTaxRateBJ(whichResource, sourcePlayer, otherPlayer)
end

--===========================================================================
function IsPlayerFlagSetBJ(whichPlayerFlag, whichPlayer)
end

--===========================================================================
function AddResourceAmountBJ(delta, whichUnit)
end

--===========================================================================
function GetConvertedPlayerId(whichPlayer)
end

--===========================================================================
function ConvertedPlayer(convertedPlayerId)
end

--===========================================================================
function GetRectWidthBJ(r)
end

--===========================================================================
function GetRectHeightBJ(r)
end

--===========================================================================
-- Replaces a gold mine with a blighted gold mine for the given player.
--
function BlightGoldMineForPlayerBJ(goldMine, whichPlayer)
end

--===========================================================================
function BlightGoldMineForPlayer(goldMine, whichPlayer)
end

--===========================================================================
function GetLastHauntedGoldMine()
end

--===========================================================================
function IsPointBlightedBJ(where)
end

--===========================================================================
function SetPlayerColorBJEnum()
end

--===========================================================================
function SetPlayerColorBJ(whichPlayer, color, changeExisting)
end

--===========================================================================
function SetPlayerUnitAvailableBJ(unitId, allowed, whichPlayer)
end

--===========================================================================
function LockGameSpeedBJ()
end

--===========================================================================
function UnlockGameSpeedBJ()
end

--===========================================================================
function IssueTargetOrderBJ(whichUnit, order, targetWidget)
end

--===========================================================================
function IssuePointOrderLocBJ(whichUnit, order, whichLocation)
end

--===========================================================================
-- Two distinct trigger actions can't share the same function name, so this
-- dummy function simply mimics the behavior of an existing call.
--
function IssueTargetDestructableOrder(whichUnit, order, targetWidget)
end

function IssueTargetItemOrder(whichUnit, order, targetWidget)
end

--===========================================================================
function IssueImmediateOrderBJ(whichUnit, order)
end

--===========================================================================
function GroupTargetOrderBJ(whichGroup, order, targetWidget)
end

--===========================================================================
function GroupPointOrderLocBJ(whichGroup, order, whichLocation)
end

--===========================================================================
function GroupImmediateOrderBJ(whichGroup, order)
end

--===========================================================================
-- Two distinct trigger actions can't share the same function name, so this
-- dummy function simply mimics the behavior of an existing call.
--
function GroupTargetDestructableOrder(whichGroup, order, targetWidget)
end

function GroupTargetItemOrder(whichGroup, order, targetWidget)
end

--===========================================================================
function GetDyingDestructable()
end

--===========================================================================
-- Rally point setting
--
function SetUnitRallyPoint(whichUnit, targPos)
end

--===========================================================================
function SetUnitRallyUnit(whichUnit, targUnit)
end

--===========================================================================
function SetUnitRallyDestructable(whichUnit, targDest)
end

--===========================================================================
-- Utility function for use by editor-generated item drop table triggers.
-- This function is added as an action to all destructable drop triggers,
-- so that a widget drop may be differentiated from a unit drop.
--
function SaveDyingWidget()
end

--===========================================================================
function SetBlightRectBJ(addBlight, whichPlayer, r)
end

--===========================================================================
function SetBlightRadiusLocBJ(addBlight, whichPlayer, loc, radius)
end

--===========================================================================
function GetAbilityName(abilcode)
end


--***************************************************************************
--*
--*  Melee Template Visibility Settings
--*
--***************************************************************************

--===========================================================================
function MeleeStartingVisibility()
end



--***************************************************************************
--*
--*  Melee Template Starting Resources
--*
--***************************************************************************

--===========================================================================
function MeleeStartingResources()
end



--***************************************************************************
--*
--*  Melee Template Hero Limit
--*
--***************************************************************************

--===========================================================================
function ReducePlayerTechMaxAllowed(whichPlayer, techId, limit)
end

--===========================================================================
function MeleeStartingHeroLimit()
end



--***************************************************************************
--*
--*  Melee Template Granted Hero Items
--*
--***************************************************************************

--===========================================================================
function MeleeTrainedUnitIsHeroBJFilter()
end

--===========================================================================
-- The first N heroes trained or hired for each player start off with a
-- standard of items.  This is currently:
--   - 1x Scroll of Town Portal
--
function MeleeGrantItemsToHero(whichUnit)
end

--===========================================================================
function MeleeGrantItemsToTrainedHero()
end

--===========================================================================
function MeleeGrantItemsToHiredHero()
end

--===========================================================================
function MeleeGrantHeroItems()
end



--***************************************************************************
--*
--*  Melee Template Clear Start Locations
--*
--***************************************************************************

--===========================================================================
function MeleeClearExcessUnit()
end

--===========================================================================
function MeleeClearNearbyUnits(x, y, range)
end

--===========================================================================
function MeleeClearExcessUnits()
end



--***************************************************************************
--*
--*  Melee Template Starting Units
--*
--***************************************************************************

--===========================================================================
function MeleeEnumFindNearestMine()
end

--===========================================================================
function MeleeFindNearestMine(src, range)
end

--===========================================================================
function MeleeRandomHeroLoc(p, id1, id2, id3, id4, loc)
end

--===========================================================================
--)a location which is (distance) away from (src) in the direction of (targ).
--
function MeleeGetProjectedLoc(src, targ, distance, deltaAngle)
end

--===========================================================================
function MeleeGetNearestValueWithin(val, minVal, maxVal)
end

--===========================================================================
function MeleeGetLocWithinRect(src, r)
end

--===========================================================================
-- Starting Units for Human Players
--   - 1 Town Hall, placed at start location
--   - 5 Peasants, placed between start location and nearest gold mine
--
function MeleeStartingUnitsHuman(whichPlayer, startLoc, doHeroes, doCamera, doPreload)
end

--===========================================================================
-- Starting Units for Orc Players
--   - 1 Great Hall, placed at start location
--   - 5 Peons, placed between start location and nearest gold mine
--
function MeleeStartingUnitsOrc(whichPlayer, startLoc, doHeroes, doCamera, doPreload)
end

--===========================================================================
-- Starting Units for Undead Players
--   - 1 Necropolis, placed at start location
--   - 1 Haunted Gold Mine, placed on nearest gold mine
--   - 3 Acolytes, placed between start location and nearest gold mine
--   - 1 Ghoul, placed between start location and nearest gold mine
--   - Blight, centered on nearest gold mine, spread across a "large area"
--
function MeleeStartingUnitsUndead(whichPlayer, startLoc, doHeroes, doCamera, doPreload)
end

--===========================================================================
-- Starting Units for Night Elf Players
--   - 1 Tree of Life, placed by nearest gold mine, already entangled
--   - 5 Wisps, placed between Tree of Life and nearest gold mine
--
function MeleeStartingUnitsNightElf(whichPlayer, startLoc, doHeroes, doCamera, doPreload)
end

--===========================================================================
-- Starting Units for Players Whose Race is Unknown
--   - 12 Sheep, placed randomly around the start location
--
function MeleeStartingUnitsUnknownRace(whichPlayer, startLoc, doHeroes, doCamera, doPreload)
end

--===========================================================================
function MeleeStartingUnits()
end

--===========================================================================
function MeleeStartingUnitsForPlayer(whichRace, whichPlayer, loc, doHeroes)
end



--***************************************************************************
--*
--*  Melee Template Starting AI Scripts
--*
--***************************************************************************

--===========================================================================
function PickMeleeAI(num, s1, s2, s3)
end

--===========================================================================
function MeleeStartingAI()
end

function LockGuardPosition(targ)
end


--***************************************************************************
--*
--*  Melee Template Victory / Defeat Conditions
--*
--***************************************************************************

--===========================================================================
function MeleePlayerIsOpponent(playerIndex, opponentIndex)
end

--===========================================================================
-- Count buildings currently owned by all allies, including the player themself.
--
function MeleeGetAllyStructureCount(whichPlayer)
end

--===========================================================================
-- Count allies, excluding dead players and the player themself.
--
function MeleeGetAllyCount(whichPlayer)
end

--===========================================================================
-- Counts key structures owned by a player and his or her allies, including
-- structures currently upgrading or under construction.
--
-- Key structures: Town Hall, Great Hall, Tree of Life, Necropolis
--
function MeleeGetAllyKeyStructureCount(whichPlayer)
end

--===========================================================================
-- Enum: Draw out a specific player.
--
function MeleeDoDrawEnum()
end

--===========================================================================
-- Enum: Victory out a specific player.
--
function MeleeDoVictoryEnum()
end

--===========================================================================
-- Defeat out a specific player.
--
function MeleeDoDefeat(whichPlayer)
end

--===========================================================================
-- Enum: Defeat out a specific player.
--
function MeleeDoDefeatEnum()
end

--===========================================================================
-- A specific player left the game.
--
function MeleeDoLeave(whichPlayer)
end

--===========================================================================
-- Remove all observers
-- 
function MeleeRemoveObservers()
end

--===========================================================================
-- Test all players to determine if a team has won.  For a team to win, all
-- remaining (read: undefeated) players need to be co-allied with all other
-- remaining players.  If even one player is not allied towards another,
-- everyone must be denied victory.
--
function MeleeCheckForVictors()
end

--===========================================================================
-- Test each player to determine if anyone has been defeated.
--
function MeleeCheckForLosersAndVictors()
end

--===========================================================================
--)a race-specific "build X or be revealed" message.
--
function MeleeGetCrippledWarningMessage(whichPlayer)
end

--===========================================================================
--)a race-specific "build X" label for cripple timers.
--
function MeleeGetCrippledRevealedMessage(whichPlayer)
end

--===========================================================================
function MeleeExposePlayer(whichPlayer, expose)
end

--===========================================================================
function MeleeExposeAllPlayers()
end

--===========================================================================
function MeleeCrippledPlayerTimeout()
end

--===========================================================================
function MeleePlayerIsCrippled(whichPlayer)
end

--===========================================================================
-- Test each player to determine if anyone has become crippled.
--
function MeleeCheckForCrippledPlayers()
end

--===========================================================================
-- Determine if the lost unit should result in any defeats or victories.
--
function MeleeCheckLostUnit(lostUnit)
end

--===========================================================================
-- Determine if the gained unit should result in any defeats, victories,
-- or cripple-status changes.
--
function MeleeCheckAddedUnit(addedUnit)
end

--===========================================================================
function MeleeTriggerActionConstructCancel()
end

--===========================================================================
function MeleeTriggerActionUnitDeath()
end

--===========================================================================
function MeleeTriggerActionUnitConstructionStart()
end

--===========================================================================
function MeleeTriggerActionPlayerDefeated()
end

--===========================================================================
function MeleeTriggerActionPlayerLeft()
end

--===========================================================================
function MeleeTriggerActionAllianceChange()
end

--===========================================================================
function MeleeTriggerTournamentFinishSoon()
end


--===========================================================================
function MeleeWasUserPlayer(whichPlayer)
end

--===========================================================================
function MeleeTournamentFinishNowRuleA(multiplier)
end

--===========================================================================
function MeleeTriggerTournamentFinishNow()
end

--===========================================================================
function MeleeInitVictoryDefeat()
end



--***************************************************************************
--*
--*  Player Slot Availability
--*
--***************************************************************************

--===========================================================================
function CheckInitPlayerSlotAvailability()
end

--===========================================================================
function SetPlayerSlotAvailable(whichPlayer, control)
end



--***************************************************************************
--*
--*  Generic Template Player-slot Initialization
--*
--***************************************************************************

--===========================================================================
function TeamInitPlayerSlots(teamCount)
end

--===========================================================================
function MeleeInitPlayerSlots()
end

--===========================================================================
function FFAInitPlayerSlots()
end

--===========================================================================
function OneOnOneInitPlayerSlots()
end

--===========================================================================
function InitGenericPlayerSlots()
end



--***************************************************************************
--*
--*  Blizzard.j Initialization
--*
--***************************************************************************

--===========================================================================
function SetDNCSoundsDawn()
end

--===========================================================================
function SetDNCSoundsDusk()
end

--===========================================================================
function SetDNCSoundsDay()
end

--===========================================================================
function SetDNCSoundsNight()
end

--===========================================================================
function InitDNCSounds()
end

--===========================================================================
function InitBlizzardGlobals()
end

--===========================================================================
function InitQueuedTriggers()
end

--===========================================================================
function InitMapRects()
end

--===========================================================================
function InitSummonableCaps()
end

--===========================================================================
-- Update the per-class stock limits.
--
function UpdateStockAvailability(whichItem)
end

--===========================================================================
-- Find a sellable item of the given type and level, and then add it.
--
function UpdateEachStockBuildingEnum()
end

--===========================================================================
function UpdateEachStockBuilding(iType, iLevel)
end

--===========================================================================
-- Update stock inventory.
--
function PerformStockUpdates()
end

--===========================================================================
-- Perform the first update, and then arrange future updates.
--
function StartStockUpdates()
end

--===========================================================================
function RemovePurchasedItem()
end

--===========================================================================
function InitNeutralBuildings()
end

--===========================================================================
function MarkGameStarted()
end

--===========================================================================
function DetectGameStarted()
end

--===========================================================================
function InitBlizzard()
end



--***************************************************************************
--*
--*  Random distribution
--*
--*  Used to select a random object from a given distribution of chances
--*
--*  - RandomDistReclears the distribution list
--*
--*  - RandomDistAddItem adds a new object to the distribution list
--*    with a given identifier and an  chance to be chosen
--*
--*  - RandomDistChoose will use the current distribution list to choose
--*    one of the objects randomly based on the chance distribution
--*
--*  Note that the chances are effectively normalized by their sum,
--*  so only the relative values of each chance are important
--*
--***************************************************************************

--===========================================================================
function RandomDistReset()
end

--===========================================================================
function RandomDistAddItem(inID, inChance)
end

--===========================================================================
function RandomDistChoose()
end



--***************************************************************************
--*
--*  Drop item
--*
--*  Makes the given unit drop the given item
--*
--*  Note: This could potentially cause problems if the unit is standing
--*        right on the edge of an unpathable area and happens to drop the
--*        item into the unpathable area where nobody can get it...
--*
--***************************************************************************

function UnitDropItem(inUnit, inItemID)
end

--===========================================================================
function WidgetDropItem(inWidget, inItemID)
end


--***************************************************************************
--*
--*  Instanced Object Operation Functions
--*
--*  Get/specific fields for single unit/item/ability instance
--*
--***************************************************************************

--===========================================================================
function BlzIsLastInstanceObjectFunctionSuccessful()
end

-- Ability
--===========================================================================
function BlzSetAbilityBooleanFieldBJ(whichAbility, whichField, value)
end

--===========================================================================
function BlzSetAbilityFieldBJ(whichAbility, whichField, value)
end

--===========================================================================
function BlzSetAbilityFieldBJ(whichAbility, whichField, value)
end

--===========================================================================
function BlzSetAbilityStringFieldBJ(whichAbility, whichField, value)
end

--===========================================================================
function BlzSetAbilityBooleanLevelFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzSetAbilityLevelFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzSetAbilityLevelFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzSetAbilityStringLevelFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzSetAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, index, value)
end

--===========================================================================
function BlzSetAbilityLevelArrayFieldBJ(whichAbility, whichField, level, index, value)
end

--===========================================================================
function BlzSetAbilityLevelArrayFieldBJ(whichAbility, whichField, level, index, value)
end

--===========================================================================
function BlzSetAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, index, value)
end

--===========================================================================
function BlzAddAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzAddAbilityLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzAddAbilityLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzAddAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzRemoveAbilityBooleanLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzRemoveAbilityLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzRemoveAbilityLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

--===========================================================================
function BlzRemoveAbilityStringLevelArrayFieldBJ(whichAbility, whichField, level, value)
end

-- Item
--=============================================================
function BlzItemAddAbilityBJ(whichItem, abilCode)
end

--===========================================================================
function BlzItemRemoveAbilityBJ(whichItem, abilCode)
end

--===========================================================================
function BlzSetItemBooleanFieldBJ(whichItem, whichField, value)
end

--===========================================================================
function BlzSetItemFieldBJ(whichItem, whichField, value)
end

--===========================================================================
function BlzSetItemFieldBJ(whichItem, whichField, value)
end

--===========================================================================
function BlzSetItemStringFieldBJ(whichItem, whichField, value)
end


-- Unit
--===========================================================================
function BlzSetUnitBooleanFieldBJ(whichUnit, whichField, value)
end

--===========================================================================
function BlzSetUnitFieldBJ(whichUnit, whichField, value)
end

--===========================================================================
function BlzSetUnitFieldBJ(whichUnit, whichField, value)
end

--===========================================================================
function BlzSetUnitStringFieldBJ(whichUnit, whichField, value)
end

-- Unit Weapon
--===========================================================================
function BlzSetUnitWeaponBooleanFieldBJ(whichUnit, whichField, index, value)
end

--===========================================================================
function BlzSetUnitWeaponFieldBJ(whichUnit, whichField, index, value)
end

--===========================================================================
function BlzSetUnitWeaponFieldBJ(whichUnit, whichField, index, value)
end

--===========================================================================
function BlzSetUnitWeaponStringFieldBJ(whichUnit, whichField, index, value)
end