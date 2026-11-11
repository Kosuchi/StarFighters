// ============================================================
//  ASTRO ARENA  -  AppGameKit Studio (AGK BASIC, Tier 1)
//
//  STAGE 1: start menu + ship selection
//  STAGE 2: arena, walls, collisions, zoom camera
//  STAGE 3: shooting, damage, health, explosions, rounds
//  STAGE 4: controls (2 keyboards + gamepads), AI opponents
//           (easy/normal/hard) and generated sounds
//
//  CONTROLS
//   Keyboard 1:  A/D turn, W thrust, S brake, SPACE (or F) fire
//   Keyboard 2:  left/right arrows turn, up thrust, down brake,
//                ENTER (or numpad 0 / Ctrl) fire
//   Gamepad:     left stick turns, A or RB thrust,
//                LB or Y brake, X or B fire
//   Connect gamepads BEFORE starting the game (AGK detects them at startup).
//   M = sound on/off
// ============================================================

#constant SCR_W         1280
#constant SCR_H         720
#constant STATE_COUNT   0
#constant STATE_SHIPS   1
#constant STATE_ARENA   2
#constant STATE_END     3

#constant ARENA_W       2000
#constant ARENA_H       1125
#constant SHIP_SCALE    1.4
#constant ZOOM_MIN      0.64
#constant ZOOM_MAX      1.6
#constant CAM_MARGIN    260
#constant WALL_BOUNCE   0.45
#constant SHIP_BOUNCE   0.6
#constant BULLET_SPEED  720
#constant BULLET_LIFE   1.8
#constant WIN_SCORE     3

// Gamepad buttons (typical Xbox-style order; change if needed)
#constant PAD_A         1
#constant PAD_B         2
#constant PAD_X         3
#constant PAD_Y         4
#constant PAD_LB        5
#constant PAD_RB        6
#constant PAD_START     8

// Sounds
#constant SND_SHOT      1
#constant SND_HIT       2
#constant SND_WALL      3
#constant SND_EXPLODE   4
#constant SND_SELECT    5
#constant SND_CONFIRM   6
#constant SND_WIN       7
#constant SND_BUMP      8

// ---------- Globals ----------
global state as integer = 0

// Player counts: humans occupy slots 1..numHumans, AI players come after them
global numHumans as integer = 1
global numAI as integer = 1
global numPlayers as integer = 2
global maxHumans as integer = 2
global difficulty as integer = 1
global menuRow as integer = 0
global soundOn as integer = 1
global startTimer as float = 0
global matchWinner as integer = 0
global panelN as integer = 0
global endTimer as float = 0

// Areas where background stars are not drawn (so boxes look fully solid)
global holeN as integer = 0
global holeX1 as float[7]
global holeY1 as float[7]
global holeX2 as float[7]
global holeY2 as float[7]

// Text object pool (Say function)
global tc as integer = 0
global maxText as integer = 0
global lblTmp as string = ""

// Background stars
global starX as float[119]
global starY as float[119]
global starS as float[119]

// Ship vector shapes (nose pointing up), 4 ship types, max 5 points
global shapeX as float[3,4]
global shapeY as float[3,4]
global shapeN as integer[3]
global shipBaseRad as float[3]

// Ship data
global shipName as string[3]
global shipDesc as string[3]
global statSpeed as integer[3]
global statArmor as integer[3]
global statFire as integer[3]
global statTurn as integer[3]

// Difficulty levels (0=easy 1=normal 2=hard)
global diffName as string[2]
global dTurn as float[2]
global dTol as float[2]
global dErr as float[2]
global dLead as float[2]
global dFireGap as float[2]
global dPref as float[2]
global dSpd as float[2]
global dDodge as integer[2]

// Per-player menu data (indices 1..4)
global choice as integer[4]
global ready as integer[4]
global pcR as integer[4]
global pcG as integer[4]
global pcB as integer[4]
global spawnX as float[4]
global spawnY as float[4]
global spawnAng as float[4]

// Controllers: device 0=none, 1=keyboard 1 (WASD), 2=keyboard 2 (arrows), 3..10 = gamepad 1..8
global dev as integer[4]
global devUsed as integer[10]
global padExists as integer[8]
global padCount as integer = 0

// Inputs per player (humans and AI use the same ones)
global inTurn as float[4]
global inThrust as integer[4]
global inBrake as integer[4]
global inFire as integer[4]
global inLeftP as integer[4]
global inRightP as integer[4]
global inFireP as integer[4]
global inSwitchP as integer[4]
global pvLeft as integer[4]
global pvRight as integer[4]
global pvFire as integer[4]
global pvSwitch as integer[4]

// Menu inputs (once per frame)
global mL as integer = 0
global mR as integer = 0
global mU as integer = 0
global mD as integer = 0
global mOK as integer = 0
global padPL as integer[8]
global padPR as integer[8]
global padPU as integer[8]
global padPD as integer[8]
global padPA as integer[8]

// AI memory
global aiErr as float[4]
global aiErrT as float[4]
global aiWander as integer[4]
global aiDodge as float[4]

// Arena player state (indices 1..4)
global pType as integer[4]
global pAlive as integer[4]
global pThrust as integer[4]
global pX as float[4]
global pY as float[4]
global pVX as float[4]
global pVY as float[4]
global pAng as float[4]
global pAccel as float[4]
global pMax as float[4]
global pTurn as float[4]
global pRad as float[4]
global pMass as float[4]

// Health, fire and scores
global pHP as float[4]
global pMaxHP as float[4]
global pDmg as float[4]
global pCool as float[4]
global pCoolMax as float[4]
global pScore as integer[4]
global roundOver as integer = 0
global roundTimer as float = 0
global winner as integer = 0

// Bullets (100)
global bX as float[99]
global bY as float[99]
global bVX as float[99]
global bVY as float[99]
global bDmg as float[99]
global bLife as float[99]
global bOwner as integer[99]
global bAlive as integer[99]

// Particles (400)
global prX as float[399]
global prY as float[399]
global prVX as float[399]
global prVY as float[399]
global prLife as float[399]
global prMax as float[399]
global prR as integer[399]
global prG as integer[399]
global prB as integer[399]

// Walls (rectangles in world coordinates)
global wallCount as integer = 7
global wallX1 as float[7]
global wallY1 as float[7]
global wallX2 as float[7]
global wallY2 as float[7]

// Camera
global camX as float = 1000
global camY as float = 562.5
global camZoom as float = 0.64

// ---------- Setup ----------
SetWindowTitle("ASTRO ARENA")
SetWindowSize(1280, 720, 0)
SetVirtualResolution(SCR_W, SCR_H)
SetOrientationAllowed(0, 0, 1, 1)
SetSyncRate(60, 0)
SetScissor(0, 0, 0, 0)
UseNewDefaultFonts(1)
SetClearColor(4, 6, 16)
SetRandomSeed(GetSeconds())

InitData()
InitSounds()
DetectPads()

// ---------- Main loop ----------
do
    tc = 0
    HideTexts()
    HidePanels()
    if GetRawKeyPressed(77) then soundOn = 1 - soundOn
    MenuInput()
    ReadInputs()
    if state <> STATE_ARENA then UpdateStars(GetFrameTime())
    DrawStars()
    holeN = 0

    select state
        case STATE_COUNT
            DoCountMenu()
        endcase
        case STATE_SHIPS
            DoShipSelect()
        endcase
        case STATE_ARENA
            DoArena()
        endcase
        case STATE_END
            DoEnd()
        endcase
    endselect

    Sync()
loop

// ============================================================
//  INITIALIZATION
// ============================================================
function InitData()
    local i as integer

    // Stars
    for i = 0 to 119
        starX[i] = Random(0, SCR_W)
        starY[i] = Random(0, SCR_H)
        starS[i] = Random(8, 60)
    next i

    // Ship 0: VIPER (balanced)
    shapeN[0] = 4
    SetPt(0, 0, 0, -20)
    SetPt(0, 1, 14, 16)
    SetPt(0, 2, 0, 8)
    SetPt(0, 3, -14, 16)
    SetShip(0, "VIPER", "Balanced for any situation", 3, 3, 3, 3)
    shipBaseRad[0] = 17

    // Ship 1: HEAVY (armor)
    shapeN[1] = 5
    SetPt(1, 0, 0, -18)
    SetPt(1, 1, 20, -4)
    SetPt(1, 2, 22, 16)
    SetPt(1, 3, -22, 16)
    SetPt(1, 4, -20, -4)
    SetShip(1, "HEAVY", "Takes a beating, but slow", 2, 5, 3, 2)
    shipBaseRad[1] = 21

    // Ship 2: ARROW (fast)
    shapeN[2] = 4
    SetPt(2, 0, 0, -26)
    SetPt(2, 1, 8, 14)
    SetPt(2, 2, 0, 8)
    SetPt(2, 3, -8, 14)
    SetShip(2, "ARROW", "Fast and agile, fragile", 5, 1, 2, 5)
    shipBaseRad[2] = 14

    // Ship 3: KNIGHT (firepower)
    shapeN[3] = 5
    SetPt(3, 0, 0, -22)
    SetPt(3, 1, 16, 0)
    SetPt(3, 2, 10, 16)
    SetPt(3, 3, -10, 16)
    SetPt(3, 4, -16, 0)
    SetShip(3, "KNIGHT", "Heavy firepower, medium speed", 3, 2, 5, 3)
    shipBaseRad[3] = 17

    // Player colors
    pcR[1] = 255 : pcG[1] = 90  : pcB[1] = 90
    pcR[2] = 90  : pcG[2] = 170 : pcB[2] = 255
    pcR[3] = 100 : pcG[3] = 235 : pcB[3] = 130
    pcR[4] = 255 : pcG[4] = 225 : pcB[4] = 90

    // Spawn positions in world coordinates
    spawnX[1] = 200  : spawnY[1] = 170 : spawnAng[1] = 135
    spawnX[2] = 1800 : spawnY[2] = 955 : spawnAng[2] = 315
    spawnX[3] = 1800 : spawnY[3] = 170 : spawnAng[3] = 225
    spawnX[4] = 200  : spawnY[4] = 955 : spawnAng[4] = 45

    // Walls (point-symmetric layout)
    SetWall(0, 880, 520, 1120, 605)
    SetWall(1, 420, 250, 480, 560)
    SetWall(2, 1520, 565, 1580, 875)
    SetWall(3, 1380, 200, 1700, 260)
    SetWall(4, 300, 865, 620, 925)
    SetWall(5, 700, 100, 760, 300)
    SetWall(6, 1240, 825, 1300, 1025)

    // AI difficulty levels
    diffName[0] = "EASY"
    diffName[1] = "NORMAL"
    diffName[2] = "HARD"
    SetDiff(0, 0.55, 24.0, 20.0, 0.0, 0.55, 520.0, 0.70, 0)
    SetDiff(1, 0.85, 11.0, 8.0, 0.6, 0.20, 420.0, 0.90, 3)
    SetDiff(2, 1.00, 5.0, 2.5, 1.0, 0.00, 330.0, 1.00, 8)
endfunction

function SetPt(t as integer, i as integer, x as float, y as float)
    shapeX[t, i] = x
    shapeY[t, i] = y
endfunction

function SetShip(t as integer, n as string, d as string, spd as integer, arm as integer, fir as integer, trn as integer)
    shipName[t] = n
    shipDesc[t] = d
    statSpeed[t] = spd
    statArmor[t] = arm
    statFire[t] = fir
    statTurn[t] = trn
endfunction

function SetWall(i as integer, x1 as float, y1 as float, x2 as float, y2 as float)
    wallX1[i] = x1
    wallY1[i] = y1
    wallX2[i] = x2
    wallY2[i] = y2
endfunction

// turn=turn speed, tol=firing tolerance (degrees), err=aiming error (degrees), lead=target leading,
// gap=extra delay between shots (s), pref=preferred distance, spd=speed usage, dodge=dodge probability
function SetDiff(i as integer, turn as float, tol as float, err as float, lead as float, gap as float, pref as float, spd as float, dodge as integer)
    dTurn[i] = turn
    dTol[i] = tol
    dErr[i] = err
    dLead[i] = lead
    dFireGap[i] = gap
    dPref[i] = pref
    dSpd[i] = spd
    dDodge[i] = dodge
endfunction

// ============================================================
//  GAMEPADS AND INPUT
// ============================================================
function DetectPads()
    local k as integer

    CompleteRawJoystickDetection()
    padCount = 0
    for k = 1 to 8
        padExists[k] = GetRawJoystickExists(k)
        if padExists[k] = 1 then inc padCount
    next k
    maxHumans = Min(4, 2 + padCount)
endfunction

// Returns 1 if device d is available
function DevAvailable(d as integer)
    local r as integer
    r = 0
    if d = 1 or d = 2 then r = 1
    if d >= 3 and d <= 10
        if padExists[d - 2] = 1 then r = 1
    endif
endfunction r

// Gives human players the first free devices: keyboard 1, keyboard 2, gamepads
function AssignDevices()
    local d as integer
    local p as integer

    for d = 0 to 10
        devUsed[d] = 0
    next d
    for p = 1 to numHumans
        dev[p] = 0
        for d = 1 to 10
            if dev[p] = 0 and DevAvailable(d) = 1 and devUsed[d] = 0 then dev[p] = d
        next d
        devUsed[dev[p]] = 1
    next p
endfunction

// Switches player p's controller to the next free one
function SwitchDevice(p as integer)
    local n as integer
    local d as integer
    local k as integer
    local ok as integer

    for n = 1 to 10
        d = mod(dev[p] - 1 + n, 10) + 1
        if DevAvailable(d) = 1
            ok = 1
            for k = 1 to numHumans
                if k <> p and dev[k] = d then ok = 0
            next k
            if ok = 1
                dev[p] = d
                PlaySnd(SND_SELECT, 40)
                exitfunction
            endif
        endif
    next n
endfunction

// Menu input: keyboards and all gamepads
function MenuInput()
    local k as integer
    local x as float
    local y as float
    local nl as integer
    local nr as integer
    local nu as integer
    local nd as integer
    local na as integer

    mL = 0
    mR = 0
    mU = 0
    mD = 0
    mOK = 0
    if GetRawKeyPressed(37) or GetRawKeyPressed(65) then mL = 1
    if GetRawKeyPressed(39) or GetRawKeyPressed(68) then mR = 1
    if GetRawKeyPressed(38) or GetRawKeyPressed(87) then mU = 1
    if GetRawKeyPressed(40) or GetRawKeyPressed(83) then mD = 1
    if GetRawKeyPressed(13) or GetRawKeyPressed(32) then mOK = 1

    for k = 1 to 8
        if padExists[k] = 1
            x = GetRawJoystickX(k)
            y = GetRawJoystickY(k)
            nl = 0
            nr = 0
            nu = 0
            nd = 0
            na = 0
            if x < -0.6 then nl = 1
            if x > 0.6 then nr = 1
            if y < -0.6 then nu = 1
            if y > 0.6 then nd = 1
            if GetRawJoystickButtonState(k, PAD_A) = 1 or GetRawJoystickButtonState(k, PAD_START) = 1 then na = 1

            if nl = 1 and padPL[k] = 0 then mL = 1
            if nr = 1 and padPR[k] = 0 then mR = 1
            if nu = 1 and padPU[k] = 0 then mU = 1
            if nd = 1 and padPD[k] = 0 then mD = 1
            if na = 1 and padPA[k] = 0 then mOK = 1

            padPL[k] = nl
            padPR[k] = nr
            padPU[k] = nu
            padPD[k] = nd
            padPA[k] = na
        endif
    next k
endfunction

// Reads human players' input (slots 1..numHumans) from their controllers
function ReadInputs()
    local p as integer
    local d as integer
    local k as integer
    local l as integer
    local r as integer
    local f as integer
    local s as integer
    local x as float

    for p = 1 to numHumans
        d = dev[p]
        l = 0
        r = 0
        s = 0
        inTurn[p] = 0
        inThrust[p] = 0
        inBrake[p] = 0
        inFire[p] = 0

        if d = 1
            // Keyboard 1: WASD + SPACE / F
            if GetRawKeyState(65) then inTurn[p] = inTurn[p] - 1
            if GetRawKeyState(68) then inTurn[p] = inTurn[p] + 1
            if GetRawKeyState(65) then l = 1
            if GetRawKeyState(68) then r = 1
            if GetRawKeyState(87) then inThrust[p] = 1
            if GetRawKeyState(87) then s = 1
            if GetRawKeyState(83) then inBrake[p] = 1
            if GetRawKeyState(32) or GetRawKeyState(70) then inFire[p] = 1
        elseif d = 2
            // Keyboard 2: arrows + ENTER / numpad 0 / Ctrl
            if GetRawKeyState(37) then inTurn[p] = inTurn[p] - 1
            if GetRawKeyState(39) then inTurn[p] = inTurn[p] + 1
            if GetRawKeyState(37) then l = 1
            if GetRawKeyState(39) then r = 1
            if GetRawKeyState(38) then inThrust[p] = 1
            if GetRawKeyState(38) then s = 1
            if GetRawKeyState(40) then inBrake[p] = 1
            if GetRawKeyState(13) or GetRawKeyState(96) or GetRawKeyState(17) then inFire[p] = 1
        elseif d >= 3
            // Gamepad
            k = d - 2
            x = GetRawJoystickX(k)
            if Abs(x) > 0.2 then inTurn[p] = x
            if x < -0.5 then l = 1
            if x > 0.5 then r = 1
            if GetRawJoystickButtonState(k, PAD_A) = 1 or GetRawJoystickButtonState(k, PAD_RB) = 1 then inThrust[p] = 1
            if GetRawJoystickButtonState(k, PAD_LB) = 1 or GetRawJoystickButtonState(k, PAD_Y) = 1 then inBrake[p] = 1
            if GetRawJoystickButtonState(k, PAD_X) = 1 or GetRawJoystickButtonState(k, PAD_B) = 1 then inFire[p] = 1
            if GetRawJoystickButtonState(k, PAD_Y) = 1 then s = 1
        endif

        f = inFire[p]

        inLeftP[p] = 0
        inRightP[p] = 0
        inFireP[p] = 0
        inSwitchP[p] = 0
        if l = 1 and pvLeft[p] = 0 then inLeftP[p] = 1
        if r = 1 and pvRight[p] = 0 then inRightP[p] = 1
        if f = 1 and pvFire[p] = 0 then inFireP[p] = 1
        if s = 1 and pvSwitch[p] = 0 then inSwitchP[p] = 1
        pvLeft[p] = l
        pvRight[p] = r
        pvFire[p] = f
        pvSwitch[p] = s
    next p
endfunction

// Player short name (P1 / AI1) -> lblTmp
function SetLabel(p as integer)
    if p <= numHumans
        lblTmp = "P" + str(p)
    else
        lblTmp = "AI" + str(p - numHumans)
    endif
endfunction

// Player long name -> lblTmp
function SetLabelLong(p as integer)
    if p <= numHumans
        lblTmp = "PLAYER " + str(p)
    else
        lblTmp = "AI PLAYER " + str(p - numHumans)
    endif
endfunction

// ============================================================
//  SOUNDS (generated in code into a memblock, no files)
// ============================================================
function InitSounds()
    //        id          start freq  end    length(ms) volume    noise  vibrato
    MakeSound(SND_SHOT,    900.0, 260.0, 130.0, 0.35, 0.00, 0.0)
    MakeSound(SND_HIT,     240.0, 100.0, 140.0, 0.55, 0.55, 0.0)
    MakeSound(SND_WALL,   1300.0, 800.0,  55.0, 0.25, 0.65, 0.0)
    MakeSound(SND_EXPLODE, 160.0,  40.0, 750.0, 0.80, 0.90, 25.0)
    MakeSound(SND_SELECT,  620.0, 760.0,  60.0, 0.30, 0.00, 0.0)
    MakeSound(SND_CONFIRM, 500.0, 1100.0, 140.0, 0.35, 0.00, 0.0)
    MakeSound(SND_WIN,     420.0, 980.0, 600.0, 0.40, 0.00, 18.0)
    MakeSound(SND_BUMP,     95.0,  55.0, 110.0, 0.50, 0.45, 0.0)
endfunction

// Simple synthesizer: frequency slides f0 -> f1, fades out toward the end
function MakeSound(id as integer, f0 as float, f1 as float, ms as float, vol as float, noise as float, vibDepth as float)
    local rate as integer
    local frames as integer
    local mem as integer
    local i as integer
    local t as float
    local f as float
    local ph as float
    local v as float
    local env as float
    local nz as float
    local lp as float
    local sv as integer

    rate = 22050
    frames = Round(ms / 1000.0 * rate)
    mem = CreateMemblock(12 + frames * 2)

    // Header: channels (2 bytes), bits/sample (2 bytes), sample rate (4), frames (4)
    SetMemblockShort(mem, 0, 1)
    SetMemblockShort(mem, 2, 16)
    SetMemblockInt(mem, 4, rate)
    SetMemblockInt(mem, 8, frames)

    ph = 0
    lp = 0
    for i = 0 to frames - 1
        t = i / (frames * 1.0)
        f = f0 + (f1 - f0) * t + vibDepth * sin(t * 1800.0)
        ph = ph + 360.0 * f / rate
        if ph > 360.0 then ph = ph - 360.0

        nz = (Random(0, 2000) - 1000) / 1000.0
        lp = lp + (nz - lp) * 0.35
        v = sin(ph) * (1.0 - noise) + lp * noise * 1.6

        env = 1.0 - t
        env = env * env
        if t < 0.02 then env = env * (t / 0.02)

        sv = Round(v * env * vol * 30000.0)
        if sv > 32000 then sv = 32000
        if sv < -32000 then sv = -32000
        if sv < 0 then sv = sv + 65536
        SetMemblockShort(mem, 12 + i * 2, sv)
    next i

    if GetSoundExists(id) = 1 then DeleteSound(id)
    CreateSoundFromMemblock(id, mem)
    DeleteMemblock(mem)
endfunction

function PlaySnd(id as integer, vol as integer)
    if soundOn = 1 then PlaySound(id, vol, 0)
endfunction

// ============================================================
//  STATE 0: SETTINGS (players, AI opponents, difficulty)
// ============================================================
function DoCountMenu()
    local row as integer
    local y as float
    local c as integer
    local r as integer
    local g as integer
    local b as integer

    // Row change
    if mU = 1
        menuRow = Max(0, menuRow - 1)
        PlaySnd(SND_SELECT, 30)
    endif
    if mD = 1
        menuRow = Min(2, menuRow + 1)
        PlaySnd(SND_SELECT, 30)
    endif

    // Value change
    if mL = 1 or mR = 1
        PlaySnd(SND_SELECT, 40)
        if menuRow = 0
            if mL = 1 then numHumans = Max(1, numHumans - 1)
            if mR = 1 then numHumans = Min(maxHumans, numHumans + 1)
            numAI = Min(numAI, 4 - numHumans)
        elseif menuRow = 1
            if mL = 1 then numAI = Max(0, numAI - 1)
            if mR = 1 then numAI = Min(4 - numHumans, numAI + 1)
        else
            if mL = 1 then difficulty = Max(0, difficulty - 1)
            if mR = 1 then difficulty = Min(2, difficulty + 1)
        endif
    endif

    if mOK = 1
        PlaySnd(SND_CONFIRM, 50)
        StartShipSelect()
        exitfunction
    endif

    Say("ASTRO ARENA", 640, 40, 80, 1, 255, 255, 255)
    Say("Space arena combat: 1-4 ships on one shared screen", 640, 130, 22, 1, 150, 170, 210)

    for row = 0 to 2
        y = 215 + row * 105
        if row = menuRow
            PanelFill(300, y, 980, y + 80, 70, 110, 200, 90)
            DrawFrame(300, y, 980, y + 80, 255, 230, 120)
            r = 255
            g = 255
            b = 255
        else
            DrawFrame(300, y, 980, y + 80, 70, 80, 110)
            r = 140
            g = 150
            b = 175
        endif

        if row = 0
            Say("HUMAN PLAYERS", 330, y + 24, 30, 0, r, g, b)
            Say("<   " + str(numHumans) + "   >", 950, y + 22, 34, 2, r, g, b)
        elseif row = 1
            Say("AI OPPONENTS", 330, y + 24, 30, 0, r, g, b)
            Say("<   " + str(numAI) + "   >", 950, y + 22, 34, 2, r, g, b)
        else
            if numAI > 0
                Say("AI DIFFICULTY", 330, y + 24, 30, 0, r, g, b)
                Say("<   " + diffName[difficulty] + "   >", 950, y + 22, 34, 2, r, g, b)
            else
                Say("AI DIFFICULTY", 330, y + 24, 30, 0, 80, 85, 105)
                Say("-", 950, y + 22, 34, 2, 80, 85, 105)
            endif
        endif
    next row

    if numHumans + numAI < 2
        Say("Practice mode: no opponents", 640, 545, 22, 1, 255, 200, 120)
    else
        Say("Total ships: " + str(numHumans + numAI), 640, 545, 22, 1, 200, 205, 225)
    endif

    Say("Up / down: row   -   Left / right: change   -   ENTER / A: continue", 640, 590, 20, 1, 200, 205, 225)
    Say("Keyboard 1: WASD + SPACE    Keyboard 2: arrows + ENTER    Gamepads detected: " + str(padCount), 640, 635, 16, 1, 120, 130, 160)
    Say("Connect gamepads before starting the game. Max " + str(maxHumans) + " human players. M = sound on/off", 640, 660, 16, 1, 120, 130, 160)
endfunction

function StartShipSelect()
    local i as integer

    numPlayers = numHumans + numAI
    AssignDevices()
    for i = 1 to 4
        ready[i] = 0
        choice[i] = mod(i - 1, 4)
    next i
    // AI players pick their ships randomly and are ready immediately
    for i = numHumans + 1 to numPlayers
        choice[i] = Random(0, 3)
        ready[i] = 1
    next i
    startTimer = 0
    ReadInputs()
    state = STATE_SHIPS
endfunction

// ============================================================
//  STATE 1: SHIP SELECTION
// ============================================================
function DoShipSelect()
    local p as integer
    local allReady as integer
    local pw as float
    local x0 as float
    local cx as float
    local ship as integer
    local t as float
    local dt as float

    dt = GetFrameTime()

    allReady = 1
    for p = 1 to numHumans
        if ready[p] = 0
            if inLeftP[p] = 1
                choice[p] = mod(choice[p] + 3, 4)
                PlaySnd(SND_SELECT, 40)
            endif
            if inRightP[p] = 1
                choice[p] = mod(choice[p] + 1, 4)
                PlaySnd(SND_SELECT, 40)
            endif
            if inSwitchP[p] = 1 then SwitchDevice(p)
        endif
        if inFireP[p] = 1
            ready[p] = 1 - ready[p]
            PlaySnd(SND_CONFIRM, 40)
        endif
        if ready[p] = 0 then allReady = 0
    next p

    if GetRawKeyPressed(27)
        state = STATE_COUNT
        exitfunction
    endif

    // When all humans are ready, the game starts after a moment
    if allReady = 1
        startTimer = startTimer + dt
        if startTimer > 1.2
            StartMatch()
            state = STATE_ARENA
            exitfunction
        endif
    else
        startTimer = 0
    endif

    t = Timer()
    pw = Min(340.0, 1280.0 / numPlayers)
    x0 = (1280.0 - numPlayers * pw) / 2.0

    Say("CHOOSE YOUR SHIP", 640, 30, 44, 1, 255, 255, 255)
    Say("ESC = back", 30, 20, 18, 0, 110, 120, 150)
    if allReady = 1 then Say("STARTING...", 640, 88, 24, 1, 255, 255, 120)

    for p = 1 to numPlayers
        cx = x0 + (p - 0.5) * pw
        ship = choice[p]
        AddHole(cx - pw / 2 + 10, 120, cx + pw / 2 - 10, 650)

        PanelFill(cx - pw / 2 + 10, 120, cx + pw / 2 - 10, 650, 10, 14, 34, 235)
        DrawFrame(cx - pw / 2 + 10, 120, cx + pw / 2 - 10, 650, pcR[p], pcG[p], pcB[p])
        if ready[p] = 1
            DrawFrame(cx - pw / 2 + 14, 124, cx + pw / 2 - 14, 646, pcR[p], pcG[p], pcB[p])
        endif

        SetLabelLong(p)
        Say(lblTmp, cx, 132, 28, 1, pcR[p], pcG[p], pcB[p])
        DrawShip(ship, cx, 245, t * 60.0 + p * 40, 2.2, pcR[p], pcG[p], pcB[p])

        Say(shipName[ship], cx, 325, 32, 1, 255, 255, 255)
        Say(shipDesc[ship], cx, 365, 14, 1, 150, 160, 190)

        Say("SPEED", cx - pw / 2 + 28, 410, 16, 0, 190, 195, 215)
        DrawBar(cx - 10, 412, statSpeed[ship], pcR[p], pcG[p], pcB[p])
        Say("ARMOR", cx - pw / 2 + 28, 440, 16, 0, 190, 195, 215)
        DrawBar(cx - 10, 442, statArmor[ship], pcR[p], pcG[p], pcB[p])
        Say("FIREPOWER", cx - pw / 2 + 28, 470, 16, 0, 190, 195, 215)
        DrawBar(cx - 10, 472, statFire[ship], pcR[p], pcG[p], pcB[p])
        Say("TURNING", cx - pw / 2 + 28, 500, 16, 0, 190, 195, 215)
        DrawBar(cx - 10, 502, statTurn[ship], pcR[p], pcG[p], pcB[p])

        if p <= numHumans
            if ready[p] = 1
                Say("READY!", cx, 545, 34, 1, 120, 255, 140)
            else
                Say("<   SELECT   >", cx, 545, 26, 1, 255, 255, 255)
            endif
            SayDevice(dev[p], cx, 592)
        else
            Say("READY", cx, 545, 34, 1, 120, 255, 140)
            Say("DIFFICULTY: " + diffName[difficulty], cx, 595, 18, 1, 200, 205, 225)
        endif
    next p

    Say("Change controller: thrust button (W / up / A)   -   Fire button = ready", 640, 668, 15, 1, 120, 130, 160)
endfunction

// Controller name and instructions for the bottom of the panel
function SayDevice(d as integer, cx as float, y as float)
    if d = 1
        Say("KEYBOARD 1", cx, y, 15, 1, 255, 255, 255)
        Say("A/D turn, W thrust, S brake", cx, y + 20, 12, 1, 150, 160, 190)
        Say("SPACE (or F) fires", cx, y + 34, 12, 1, 150, 160, 190)
    elseif d = 2
        Say("KEYBOARD 2", cx, y, 15, 1, 255, 255, 255)
        Say("Arrows: turn, thrust, brake", cx, y + 20, 12, 1, 150, 160, 190)
        Say("ENTER (or numpad 0) fires", cx, y + 34, 12, 1, 150, 160, 190)
    elseif d >= 3
        Say("GAMEPAD " + str(d - 2), cx, y, 15, 1, 255, 255, 255)
        Say("Stick turns, A thrust, LB brake", cx, y + 20, 12, 1, 150, 160, 190)
        Say("X or B fires", cx, y + 34, 12, 1, 150, 160, 190)
    else
        Say("NO CONTROLLER", cx, y, 15, 1, 255, 120, 120)
    endif
endfunction

// ============================================================
//  STATE 2: ARENA
// ============================================================

// New match: scores are reset
function StartMatch()
    local p as integer
    for p = 1 to 4
        pScore[p] = 0
    next p
    StartArena()
endfunction

// Places ships at spawn points and computes physics values from the stats
function StartArena()
    local p as integer
    local t as integer
    local i as integer

    for p = 1 to 4
        t = choice[p]
        pType[p] = t
        pX[p] = spawnX[p]
        pY[p] = spawnY[p]
        pVX[p] = 0
        pVY[p] = 0
        pAng[p] = spawnAng[p]
        pThrust[p] = 0
        pAccel[p] = 240.0 + statSpeed[t] * 70.0
        pMax[p] = 200.0 + statSpeed[t] * 55.0
        pTurn[p] = 110.0 + statTurn[t] * 38.0
        pRad[p] = shipBaseRad[t] * SHIP_SCALE
        pMass[p] = 1.0 + statArmor[t] * 0.5
        pMaxHP[p] = 40.0 + statArmor[t] * 20.0
        pHP[p] = pMaxHP[p]
        pDmg[p] = 6.0 + statFire[t] * 2.0
        pCoolMax[p] = 0.62 - statFire[t] * 0.09
        pCool[p] = 0
        aiErr[p] = 0
        aiErrT[p] = 0
        aiWander[p] = 0
        aiDodge[p] = 0
        inTurn[p] = 0
        inThrust[p] = 0
        inBrake[p] = 0
        inFire[p] = 0
        if p <= numPlayers
            pAlive[p] = 1
        else
            pAlive[p] = 0
        endif
    next p

    for i = 0 to 99
        bAlive[i] = 0
    next i
    for i = 0 to 399
        prLife[i] = 0
    next i
    roundOver = 0
    roundTimer = 0
    winner = 0

    UpdateCamera(0.0, 1)
endfunction

function DoArena()
    local dt as float
    local p as integer

    dt = Min(0.05, GetFrameTime())

    if GetRawKeyPressed(27)
        state = STATE_SHIPS
        startTimer = 0
        for p = 1 to numHumans
            ready[p] = 0
        next p
        exitfunction
    endif
    if GetRawKeyPressed(82) then StartArena()

    if roundOver = 1
        roundTimer = roundTimer + dt
        if roundTimer > 2.0 and mOK = 1
            if winner > 0 and pScore[winner] >= WIN_SCORE
                StartEnd()
                exitfunction
            else
                StartArena()
            endif
        endif
    endif

    // AI players decide their moves (human input is read in the main loop)
    for p = numHumans + 1 to numPlayers
        if pAlive[p] = 1 then UpdateAI(p, dt)
    next p

    UpdateShips(dt)
    UpdateBullets(dt)
    UpdateBursts(dt)
    CollideShips()
    CollideWalls()
    CheckRoundEnd()
    UpdateCamera(dt, 0)
    DrawArena()
    DrawHUD()
endfunction

// Control and movement (uses the inTurn/inThrust/inBrake/inFire inputs)
function UpdateShips(dt as float)
    local p as integer
    local dx as float
    local dy as float
    local damp as float
    local sp as float

    for p = 1 to numPlayers
        if pAlive[p] = 1
            pAng[p] = pAng[p] + inTurn[p] * pTurn[p] * dt

            // Nose direction: (sin a, -cos a)
            dx = sin(pAng[p])
            dy = 0.0 - cos(pAng[p])

            if inThrust[p] = 1
                pThrust[p] = 1
                pVX[p] = pVX[p] + dx * pAccel[p] * dt
                pVY[p] = pVY[p] + dy * pAccel[p] * dt
            else
                pThrust[p] = 0
            endif

            // Light damping, braking adds to it
            damp = Max(0.0, 1.0 - 0.45 * dt)
            if inBrake[p] = 1 then damp = damp * Max(0.0, 1.0 - 2.2 * dt)
            pVX[p] = pVX[p] * damp
            pVY[p] = pVY[p] * damp

            // Top speed
            sp = sqrt(pVX[p] * pVX[p] + pVY[p] * pVY[p])
            if sp > pMax[p]
                pVX[p] = pVX[p] * pMax[p] / sp
                pVY[p] = pVY[p] * pMax[p] / sp
            endif

            pX[p] = pX[p] + pVX[p] * dt
            pY[p] = pY[p] + pVY[p] * dt

            // Firing (auto-fire while the button is held)
            if pCool[p] > 0 then pCool[p] = pCool[p] - dt
            if roundOver = 0 and pCool[p] <= 0 and inFire[p] = 1
                FireBullet(p)
                if p > numHumans then pCool[p] = pCool[p] + dFireGap[difficulty]
            endif
        endif
    next p
endfunction

// ============================================================
//  AI
// ============================================================

// 1 if the point is outside the arena or inside a wall (+margin)
function PointBlocked(x as float, y as float, m as float)
    local r as integer
    r = 0
    if x < m or x > ARENA_W - m or y < m or y > ARENA_H - m then r = 1
    if r = 0 then r = PointInWall(x, y, m)
endfunction r

// 1 if the point is inside any wall (with margin m)
function PointInWall(x as float, y as float, m as float)
    local w as integer
    local r as integer
    r = 0
    for w = 0 to wallCount - 1
        if x > wallX1[w] - m and x < wallX2[w] + m and y > wallY1[w] - m and y < wallY2[w] + m then r = 1
    next w
endfunction r

// 1 if there are no walls on the straight line
function LineClear(x1 as float, y1 as float, x2 as float, y2 as float)
    local n as integer
    local i as integer
    local r as integer
    local x as float
    local y as float
    local d as float

    d = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    n = Max(1, Round(d / 30.0))
    r = 1
    for i = 1 to n
        x = x1 + (x2 - x1) * i / n
        y = y1 + (y2 - y1) * i / n
        if PointInWall(x, y, 2.0) = 1 then r = 0
    next i
endfunction r

// AI sets player p's inputs: aiming, movement, wall avoidance, firing
function UpdateAI(p as integer, dt as float)
    local q as integer
    local i as integer
    local best as integer
    local bd as float
    local dx as float
    local dy as float
    local d2 as float
    local df as integer
    local hx as float
    local hy as float
    local cx as float
    local cy as float
    local tx as float
    local ty as float
    local tvx as float
    local tvy as float
    local td as float
    local lt as float
    local dotv as float
    local da as float
    local sd as float
    local eff as float
    local sp as float
    local pre as float
    local bxp as float
    local byp as float
    local lx as float
    local ly as float
    local rx as float
    local ry as float
    local avoid as integer
    local bl as integer
    local br as integer
    local bs as float
    local along as float
    local crs as float

    df = difficulty
    inTurn[p] = 0
    inThrust[p] = 0
    inBrake[p] = 0
    inFire[p] = 0

    // Nearest living opponent
    best = 0
    bd = 99999999.0
    for q = 1 to numPlayers
        if q <> p and pAlive[q] = 1
            dx = pX[q] - pX[p]
            dy = pY[q] - pY[p]
            d2 = dx * dx + dy * dy
            if d2 < bd
                bd = d2
                best = q
            endif
        endif
    next q
    if best = 0 then exitfunction

    // Random aiming error and "wander" are refreshed at intervals
    aiErrT[p] = aiErrT[p] - dt
    if aiErrT[p] <= 0
        aiErrT[p] = 0.6 + Random(0, 80) / 100.0
        aiErr[p] = (Random(0, 200) - 100) / 100.0 * dErr[df]
        aiWander[p] = Random(0, 1)
    endif
    if aiDodge[p] > 0 then aiDodge[p] = aiDodge[p] - dt

    // Predictive aiming
    dx = pX[best] - pX[p]
    dy = pY[best] - pY[p]
    td = sqrt(dx * dx + dy * dy)
    lt = td / BULLET_SPEED * dLead[df]
    tx = pX[best] + (pVX[best] - pVX[p] * 0.6) * lt
    ty = pY[best] + (pVY[best] - pVY[p] * 0.6) * lt
    tvx = tx - pX[p]
    tvy = ty - pY[p]
    td = sqrt(tvx * tvx + tvy * tvy)
    if td < 1.0 then td = 1.0

    hx = sin(pAng[p])
    hy = 0.0 - cos(pAng[p])
    cx = cos(pAng[p])
    cy = sin(pAng[p])

    dotv = (hx * tvx + hy * tvy) / td
    dotv = Max(-1.0, Min(1.0, dotv))
    da = ACos(dotv)
    sd = 1.0
    if tvx * cx + tvy * cy < 0 then sd = -1.0
    eff = sd * da + aiErr[p]

    sp = sqrt(pVX[p] * pVX[p] + pVY[p] * pVY[p])

    // Wall avoidance: look ahead and to the sides
    avoid = 0
    pre = 120.0 + sp * 0.4
    bxp = pX[p] + hx * pre
    byp = pY[p] + hy * pre
    if PointBlocked(bxp, byp, pRad[p] + 8.0) = 1
        lx = pX[p] + sin(pAng[p] - 55.0) * pre
        ly = pY[p] - cos(pAng[p] - 55.0) * pre
        rx = pX[p] + sin(pAng[p] + 55.0) * pre
        ry = pY[p] - cos(pAng[p] + 55.0) * pre
        bl = PointBlocked(lx, ly, pRad[p] + 8.0)
        br = PointBlocked(rx, ry, pRad[p] + 8.0)
        if br = 0
            inTurn[p] = 1.0
        elseif bl = 0
            inTurn[p] = -1.0
        else
            inTurn[p] = 1.0
        endif
        if sp > 140.0 then inBrake[p] = 1
        avoid = 1
    endif

    if avoid = 0
        // Bullet dodging (normal and hard)
        if aiDodge[p] <= 0 and dDodge[df] > 0
            for i = 0 to 99
                if bAlive[i] = 1 and bOwner[i] <> p
                    rx = pX[p] - bX[i]
                    ry = pY[p] - bY[i]
                    if rx * rx + ry * ry < 90000.0
                        bs = sqrt(bVX[i] * bVX[i] + bVY[i] * bVY[i])
                        if bs > 1.0
                            along = (rx * bVX[i] + ry * bVY[i]) / bs
                            crs = Abs(rx * bVY[i] - ry * bVX[i]) / bs
                            if along > 0 and crs < pRad[p] + 26.0 and Random(0, 99) < dDodge[df] * 4
                                aiDodge[p] = 0.45
                            endif
                        endif
                    endif
                endif
            next i
        endif

        if aiDodge[p] > 0
            // Swerve sideways and thrust
            inTurn[p] = -1.0
            if aiWander[p] = 1 then inTurn[p] = 1.0
            inThrust[p] = 1
        else
            // Turn toward the target
            inTurn[p] = Max(-1.0, Min(1.0, eff / 18.0)) * dTurn[df]

            // Thrust / brake according to the preferred distance
            if td > dPref[df] and Abs(sd * da) < 70.0
                if sp < pMax[p] * dSpd[df] then inThrust[p] = 1
            elseif td < 220.0
                inBrake[p] = 1
            elseif aiWander[p] = 1 and sp < 120.0 and da < 90.0
                inThrust[p] = 1
            endif

            // Fire: aim good enough, distance suitable and no wall in between
            if Abs(sd * da) < dTol[df] and td < 900.0
                if LineClear(pX[p], pY[p], pX[best], pY[best]) = 1 then inFire[p] = 1
            endif
        endif
    endif
endfunction

// ============================================================
//  COLLISIONS
// ============================================================

// Ships against each other (bounce according to mass)
function CollideShips()
    local i as integer
    local j as integer
    local dx as float
    local dy as float
    local dist as float
    local minD as float
    local nx as float
    local ny as float
    local overlap as float
    local mi as float
    local mj as float
    local rv as float
    local imp as float

    for i = 1 to numPlayers - 1
        for j = i + 1 to numPlayers
            if pAlive[i] = 1 and pAlive[j] = 1
                dx = pX[j] - pX[i]
                dy = pY[j] - pY[i]
                dist = sqrt(dx * dx + dy * dy)
                minD = pRad[i] + pRad[j]
                if dist < minD and dist > 0.001
                    nx = dx / dist
                    ny = dy / dist
                    overlap = minD - dist
                    mi = pMass[i]
                    mj = pMass[j]

                    pX[i] = pX[i] - nx * overlap * mj / (mi + mj)
                    pY[i] = pY[i] - ny * overlap * mj / (mi + mj)
                    pX[j] = pX[j] + nx * overlap * mi / (mi + mj)
                    pY[j] = pY[j] + ny * overlap * mi / (mi + mj)

                    rv = (pVX[j] - pVX[i]) * nx + (pVY[j] - pVY[i]) * ny
                    if rv < 0
                        if rv < -90.0 then PlaySnd(SND_BUMP, 45)
                        imp = (0.0 - (1.0 + SHIP_BOUNCE)) * rv / (1.0 / mi + 1.0 / mj)
                        pVX[i] = pVX[i] - imp / mi * nx
                        pVY[i] = pVY[i] - imp / mi * ny
                        pVX[j] = pVX[j] + imp / mj * nx
                        pVY[j] = pVY[j] + imp / mj * ny
                    endif
                endif
            endif
        next j
    next i
endfunction

// Ships against walls and arena edges
function CollideWalls()
    local p as integer
    local w as integer
    local r as float

    for p = 1 to numPlayers
        if pAlive[p] = 1
            for w = 0 to wallCount - 1
                ShipVsRect(p, wallX1[w], wallY1[w], wallX2[w], wallY2[w])
            next w

            r = pRad[p]
            if pX[p] < r
                pX[p] = r
                if pVX[p] < 0 then pVX[p] = 0.0 - pVX[p] * WALL_BOUNCE
            endif
            if pX[p] > ARENA_W - r
                pX[p] = ARENA_W - r
                if pVX[p] > 0 then pVX[p] = 0.0 - pVX[p] * WALL_BOUNCE
            endif
            if pY[p] < r
                pY[p] = r
                if pVY[p] < 0 then pVY[p] = 0.0 - pVY[p] * WALL_BOUNCE
            endif
            if pY[p] > ARENA_H - r
                pY[p] = ARENA_H - r
                if pVY[p] > 0 then pVY[p] = 0.0 - pVY[p] * WALL_BOUNCE
            endif
        endif
    next p
endfunction

// Circle vs rectangle
function ShipVsRect(p as integer, x1 as float, y1 as float, x2 as float, y2 as float)
    local cx as float
    local cy as float
    local dx as float
    local dy as float
    local d2 as float
    local d as float
    local r as float
    local nx as float
    local ny as float
    local pen as float
    local vn as float
    local dl as float
    local dr as float
    local dtop as float
    local dbot as float
    local m as float

    r = pRad[p]
    cx = Max(x1, Min(x2, pX[p]))
    cy = Max(y1, Min(y2, pY[p]))
    dx = pX[p] - cx
    dy = pY[p] - cy
    d2 = dx * dx + dy * dy

    if d2 < r * r
        if d2 > 0.0001
            d = sqrt(d2)
            nx = dx / d
            ny = dy / d
            pen = r - d
        else
            // Center is inside the rectangle: push out along the shortest route
            dl = pX[p] - x1
            dr = x2 - pX[p]
            dtop = pY[p] - y1
            dbot = y2 - pY[p]
            m = Min(Min(dl, dr), Min(dtop, dbot))
            nx = 0
            ny = 0
            if m = dl
                nx = -1
                pen = dl + r
            elseif m = dr
                nx = 1
                pen = dr + r
            elseif m = dtop
                ny = -1
                pen = dtop + r
            else
                ny = 1
                pen = dbot + r
            endif
        endif

        pX[p] = pX[p] + nx * pen
        pY[p] = pY[p] + ny * pen

        vn = pVX[p] * nx + pVY[p] * ny
        if vn < 0
            if vn < -150.0 then PlaySnd(SND_BUMP, 30)
            pVX[p] = pVX[p] - (1.0 + WALL_BOUNCE) * vn * nx
            pVY[p] = pVY[p] - (1.0 + WALL_BOUNCE) * vn * ny
        endif
    endif
endfunction

// ============================================================
//  CAMERA
// ============================================================

// Center on the midpoint of the ships and zoom so that all fit
function UpdateCamera(dt as float, snap as integer)
    local p as integer
    local minX as float
    local maxX as float
    local minY as float
    local maxY as float
    local count as integer
    local tx as float
    local ty as float
    local tz as float
    local w as float
    local h as float
    local k as float
    local hw as float
    local hh as float

    minX = 999999
    maxX = -999999
    minY = 999999
    maxY = -999999
    count = 0

    for p = 1 to numPlayers
        if pAlive[p] = 1
            minX = Min(minX, pX[p])
            maxX = Max(maxX, pX[p])
            minY = Min(minY, pY[p])
            maxY = Max(maxY, pY[p])
            inc count
        endif
    next p

    if count > 0
        tx = (minX + maxX) / 2.0
        ty = (minY + maxY) / 2.0
        w = (maxX - minX) + 2.0 * CAM_MARGIN
        h = (maxY - minY) + 2.0 * CAM_MARGIN
        tz = Min(1280.0 / w, 720.0 / h)
        tz = Max(ZOOM_MIN, Min(ZOOM_MAX, tz))

        if snap = 1
            camX = tx
            camY = ty
            camZoom = tz
        else
            k = Min(1.0, 4.0 * dt)
            camX = camX + (tx - camX) * k
            camY = camY + (ty - camY) * k
            k = Min(1.0, 3.0 * dt)
            camZoom = camZoom + (tz - camZoom) * k
        endif
    endif

    // Keep the view inside the arena
    hw = 640.0 / camZoom
    hh = 360.0 / camZoom
    camX = Max(hw, Min(ARENA_W - hw, camX))
    camY = Max(hh, Min(ARENA_H - hh, camY))
endfunction

// ============================================================
//  BULLETS, DAMAGE, EXPLOSIONS, ROUNDS
// ============================================================
function FireBullet(p as integer)
    local i as integer
    local found as integer
    local dx as float
    local dy as float

    found = -1
    for i = 0 to 99
        if bAlive[i] = 0
            found = i
            exit
        endif
    next i

    if found >= 0
        dx = sin(pAng[p])
        dy = 0.0 - cos(pAng[p])
        bAlive[found] = 1
        bOwner[found] = p
        bX[found] = pX[p] + dx * (pRad[p] + 8.0)
        bY[found] = pY[p] + dy * (pRad[p] + 8.0)
        bVX[found] = dx * BULLET_SPEED + pVX[p] * 0.6
        bVY[found] = dy * BULLET_SPEED + pVY[p] * 0.6
        bLife[found] = BULLET_LIFE
        bDmg[found] = pDmg[p]
        pCool[p] = pCoolMax[p]
        PlaySnd(SND_SHOT, 35)

        // Small recoil
        pVX[p] = pVX[p] - dx * 12.0
        pVY[p] = pVY[p] - dy * 12.0
    endif
endfunction

function UpdateBullets(dt as float)
    local i as integer
    local p as integer
    local w as integer
    local dx as float
    local dy as float
    local r as float
    local hit as integer

    for i = 0 to 99
        if bAlive[i] = 1
            bX[i] = bX[i] + bVX[i] * dt
            bY[i] = bY[i] + bVY[i] * dt
            bLife[i] = bLife[i] - dt

            if bLife[i] <= 0
                bAlive[i] = 0
            else
                hit = 0
                if bX[i] < 0 or bX[i] > ARENA_W or bY[i] < 0 or bY[i] > ARENA_H then hit = 1

                if hit = 0
                    for w = 0 to wallCount - 1
                        if bX[i] > wallX1[w] and bX[i] < wallX2[w] and bY[i] > wallY1[w] and bY[i] < wallY2[w] then hit = 1
                    next w
                endif

                if hit = 1
                    SpawnBurst(bX[i], bY[i], 6, 150.0, 255, 255, 255, 0.3)
                    PlaySnd(SND_WALL, 20)
                    bAlive[i] = 0
                else
                    for p = 1 to numPlayers
                        if pAlive[p] = 1 and p <> bOwner[i] and bAlive[i] = 1
                            dx = pX[p] - bX[i]
                            dy = pY[p] - bY[i]
                            r = pRad[p] + 4.0
                            if dx * dx + dy * dy < r * r
                                HitShip(p, i)
                            endif
                        endif
                    next p
                endif
            endif
        endif
    next i
endfunction

function HitShip(p as integer, i as integer)
    local sp as float

    pHP[p] = pHP[p] - bDmg[i]
    sp = sqrt(bVX[i] * bVX[i] + bVY[i] * bVY[i])
    if sp > 0.1
        pVX[p] = pVX[p] + bVX[i] / sp * 70.0 / pMass[p]
        pVY[p] = pVY[p] + bVY[i] / sp * 70.0 / pMass[p]
    endif
    SpawnBurst(bX[i], bY[i], 10, 220.0, pcR[p], pcG[p], pcB[p], 0.5)
    PlaySnd(SND_HIT, 55)
    bAlive[i] = 0

    if pHP[p] <= 0 then KillShip(p)
endfunction

function KillShip(p as integer)
    pAlive[p] = 0
    pThrust[p] = 0
    SpawnBurst(pX[p], pY[p], 50, 320.0, pcR[p], pcG[p], pcB[p], 1.2)
    SpawnBurst(pX[p], pY[p], 25, 200.0, 255, 255, 255, 0.8)
    PlaySnd(SND_EXPLODE, 85)
endfunction

// The round ends when at most one ship is alive (only if there are 2+ ships)
function CheckRoundEnd()
    local p as integer
    local count as integer
    local last as integer

    if roundOver = 0 and numPlayers >= 2
        count = 0
        last = 0
        for p = 1 to numPlayers
            if pAlive[p] = 1
                inc count
                last = p
            endif
        next p

        if count <= 1
            roundOver = 1
            roundTimer = 0
            PlaySnd(SND_WIN, 60)
            if count = 1
                winner = last
                pScore[last] = pScore[last] + 1
            else
                winner = 0
            endif
        endif
    endif
endfunction

// Particle burst
function SpawnBurst(x as float, y as float, count as integer, spd as float, r as integer, g as integer, b as integer, life as float)
    local i as integer
    local n as integer
    local a as float
    local s as float

    n = 0
    for i = 0 to 399
        if prLife[i] <= 0
            a = Random(0, 359)
            s = spd * (0.25 + Random(0, 75) / 100.0)
            prX[i] = x
            prY[i] = y
            prVX[i] = cos(a) * s
            prVY[i] = sin(a) * s
            prMax[i] = life * (0.5 + Random(0, 50) / 100.0)
            prLife[i] = prMax[i]
            prR[i] = r
            prG[i] = g
            prB[i] = b
            inc n
            if n >= count then exit
        endif
    next i
endfunction

function UpdateBursts(dt as float)
    local i as integer
    local drag as float

    drag = Max(0.0, 1.0 - 2.0 * dt)
    for i = 0 to 399
        if prLife[i] > 0
            prX[i] = prX[i] + prVX[i] * dt
            prY[i] = prY[i] + prVY[i] * dt
            prVX[i] = prVX[i] * drag
            prVY[i] = prVY[i] * drag
            prLife[i] = prLife[i] - dt
        endif
    next i
endfunction

// ============================================================
//  DRAWING: ARENA
// ============================================================
function DrawArena()
    local p as integer
    local w as integer
    local gx as integer
    local gy as integer
    local sx1 as float
    local sy1 as float
    local sx2 as float
    local sy2 as float
    local c as integer
    local wc as integer

    // Background
    sx1 = (0 - camX) * camZoom + 640.0
    sy1 = (0 - camY) * camZoom + 360.0
    sx2 = (ARENA_W - camX) * camZoom + 640.0
    sy2 = (ARENA_H - camY) * camZoom + 360.0
    PanelFill(sx1, sy1, sx2, sy2, 8, 12, 28, 255)

    // Grid (helps perceive movement and zoom)
    for gx = 0 to ARENA_W step 100
        sx1 = (gx - camX) * camZoom + 640.0
        DrawLine(sx1, (0 - camY) * camZoom + 360.0, sx1, (ARENA_H - camY) * camZoom + 360.0, 20, 30, 58)
    next gx
    for gy = 0 to ARENA_H step 100
        sy1 = (gy - camY) * camZoom + 360.0
        DrawLine((0 - camX) * camZoom + 640.0, sy1, (ARENA_W - camX) * camZoom + 640.0, sy1, 20, 30, 58)
    next gy

    // Walls
    wc = MakeColor(40, 60, 100)
    for w = 0 to wallCount - 1
        sx1 = (wallX1[w] - camX) * camZoom + 640.0
        sy1 = (wallY1[w] - camY) * camZoom + 360.0
        sx2 = (wallX2[w] - camX) * camZoom + 640.0
        sy2 = (wallY2[w] - camY) * camZoom + 360.0
        PanelFill(sx1, sy1, sx2, sy2, 40, 60, 100, 255)
        DrawFrame(sx1, sy1, sx2, sy2, 120, 170, 255)
    next w

    // Borders
    sx1 = (0 - camX) * camZoom + 640.0
    sy1 = (0 - camY) * camZoom + 360.0
    sx2 = (ARENA_W - camX) * camZoom + 640.0
    sy2 = (ARENA_H - camY) * camZoom + 360.0
    DrawFrame(sx1, sy1, sx2, sy2, 80, 200, 255)
    DrawFrame(sx1 - 4, sy1 - 4, sx2 + 4, sy2 + 4, 40, 110, 160)

    DrawBursts()
    DrawBullets()

    // Ships
    for p = 1 to numPlayers
        if pAlive[p] = 1
            if pThrust[p] = 1 then DrawFlame(pX[p], pY[p], pAng[p])
            DrawShip(pType[p], (pX[p] - camX) * camZoom + 640.0, (pY[p] - camY) * camZoom + 360.0, pAng[p], camZoom * SHIP_SCALE, pcR[p], pcG[p], pcB[p])
            DrawHPBar(p)
        endif
    next p
endfunction

// Engine flame behind the ship (takes world coordinates)
function DrawFlame(x as float, y as float, ang as float)
    local sc as float
    local sx as float
    local sy as float
    local ca as float
    local sa as float
    local flen as float
    local ax as float
    local ay as float
    local bx as float
    local by as float
    local tx as float
    local ty as float

    sc = camZoom * SHIP_SCALE
    sx = (x - camX) * camZoom + 640.0
    sy = (y - camY) * camZoom + 360.0
    ca = cos(ang)
    sa = sin(ang)
    flen = 14.0 + Random(0, 12)

    // Local points: (-6,12) (6,12) tip (0,12+flen)
    ax = (-6.0 * sc) * ca - (12.0 * sc) * sa + sx
    ay = (-6.0 * sc) * sa + (12.0 * sc) * ca + sy
    bx = (6.0 * sc) * ca - (12.0 * sc) * sa + sx
    by = (6.0 * sc) * sa + (12.0 * sc) * ca + sy
    tx = 0.0 - ((12.0 + flen) * sc) * sa + sx
    ty = ((12.0 + flen) * sc) * ca + sy

    DrawThickLine(ax, ay, tx, ty, 255, 170, 60)
    DrawThickLine(bx, by, tx, ty, 255, 170, 60)
endfunction

function DrawBursts()
    local i as integer
    local f as float
    local sx as float
    local sy as float
    local cr as integer
    local cg as integer
    local cb as integer

    for i = 0 to 399
        if prLife[i] > 0
            f = prLife[i] / prMax[i]
            cr = prR[i] * f
            cg = prG[i] * f
            cb = prB[i] * f
            sx = (prX[i] - camX) * camZoom + 640.0
            sy = (prY[i] - camY) * camZoom + 360.0
            DrawThickLine(sx, sy, sx - prVX[i] * 0.04 * camZoom, sy - prVY[i] * 0.04 * camZoom, cr, cg, cb)
        endif
    next i
endfunction

function DrawBullets()
    local i as integer
    local sp as float
    local ux as float
    local uy as float
    local sx as float
    local sy as float
    local o as integer

    for i = 0 to 99
        if bAlive[i] = 1
            sp = sqrt(bVX[i] * bVX[i] + bVY[i] * bVY[i])
            if sp > 1.0
                ux = bVX[i] / sp
                uy = bVY[i] / sp
                o = bOwner[i]
                sx = (bX[i] - camX) * camZoom + 640.0
                sy = (bY[i] - camY) * camZoom + 360.0
                DrawThickLine(sx - ux * 18.0 * camZoom, sy - uy * 18.0 * camZoom, sx, sy, pcR[o], pcG[o], pcB[o])
                DrawLine(sx - ux * 8.0 * camZoom, sy - uy * 8.0 * camZoom, sx, sy, 255, 255, 255)
            endif
        endif
    next i
endfunction

// Health bar above the ship
function DrawHPBar(p as integer)
    local sx as float
    local sy as float
    local w as float
    local frac as float
    local cbg as integer
    local cfill as integer

    sx = (pX[p] - camX) * camZoom + 640.0
    sy = (pY[p] - camY) * camZoom + 360.0 - (pRad[p] + 18.0) * camZoom
    w = 56.0 * camZoom
    frac = Max(0.0, pHP[p] / pMaxHP[p])

    cbg = MakeColor(30, 34, 50)
    cfill = MakeColor(255.0 * (1.0 - frac), 60.0 + 195.0 * frac, 70)
    DrawBox(sx - w / 2.0, sy - 3, sx + w / 2.0, sy + 3, cbg, cbg, cbg, cbg, 1)
    DrawBox(sx - w / 2.0, sy - 3, sx - w / 2.0 + w * frac, sy + 3, cfill, cfill, cfill, cfill, 1)
endfunction

// Scores and round end text
function DrawHUD()
    local p as integer
    local x as float

    Say("ESC = menu    R = restart round    M = sound", 20, 14, 16, 0, 120, 130, 160)
    Say("Zoom " + str(camZoom, 2), 1260, 14, 16, 2, 120, 130, 160)

    if numPlayers >= 2
        for p = 1 to numPlayers
            x = 640.0 + (p - (numPlayers + 1) / 2.0) * 150.0
            SetLabel(p)
            Say(lblTmp + "  " + str(pScore[p]), x, 10, 28, 1, pcR[p], pcG[p], pcB[p])
        next p
        Say("First to " + str(WIN_SCORE) + " round wins takes the match", 640, 46, 14, 1, 100, 110, 140)
    else
        Say("Practice: shoot the walls and explore the arena (add opponents in the menu)", 640, 46, 14, 1, 100, 110, 140)
    endif

    if roundOver = 1
        PanelFill(200, 235, 1080, 380, 0, 0, 0, 150)
        if winner > 0
            SetLabelLong(winner)
            if pScore[winner] >= WIN_SCORE
                Say(lblTmp + " WINS THE MATCH!", 640, 250, 56, 1, pcR[winner], pcG[winner], pcB[winner])
            else
                Say(lblTmp + " WINS THE ROUND", 640, 250, 50, 1, pcR[winner], pcG[winner], pcB[winner])
            endif
        else
            Say("DRAW", 640, 250, 56, 1, 255, 255, 255)
        endif

        if roundTimer > 2.0
            if winner > 0 and pScore[winner] >= WIN_SCORE
                Say("ENTER / SPACE / A = final results", 640, 330, 26, 1, 255, 255, 255)
            else
                Say("ENTER / SPACE / A = next round", 640, 330, 26, 1, 255, 255, 255)
            endif
        endif
    endif
endfunction

// ============================================================
//  DRAWING HELPER FUNCTIONS
// ============================================================

// Draw text: reuses text objects, align: 0=left 1=center 2=right
function Say(s as string, x as float, y as float, size as float, align as integer, r as integer, g as integer, b as integer)
    inc tc
    if GetTextExists(tc) = 0 then CreateText(tc, "")
    SetTextString(tc, s)
    SetTextSize(tc, size)
    SetTextPosition(tc, x, y)
    SetTextAlignment(tc, align)
    SetTextColor(tc, r, g, b, 255)
    SetTextVisible(tc, 1)
    if tc > maxText then maxText = tc
endfunction

function HideTexts()
    local i as integer
    for i = 1 to maxText
        SetTextVisible(i, 0)
    next i
endfunction

// Thicker line (3 lines side by side)
function DrawThickLine(x1 as float, y1 as float, x2 as float, y2 as float, r as integer, g as integer, b as integer)
    DrawLine(x1, y1, x2, y2, r, g, b)
    DrawLine(x1 + 1, y1, x2 + 1, y2, r, g, b)
    DrawLine(x1, y1 + 1, x2, y2 + 1, r, g, b)
endfunction

function DrawFrame(x1 as float, y1 as float, x2 as float, y2 as float, r as integer, g as integer, b as integer)
    DrawThickLine(x1, y1, x2, y1, r, g, b)
    DrawThickLine(x2, y1, x2, y2, r, g, b)
    DrawThickLine(x2, y2, x1, y2, r, g, b)
    DrawThickLine(x1, y2, x1, y1, r, g, b)
endfunction

// Vector ship: t=type, ang=angle in degrees (0 = nose up), sc=scale
function DrawShip(t as integer, cx as float, cy as float, ang as float, sc as float, r as integer, g as integer, b as integer)
    local i as integer
    local j as integer
    local n as integer
    local ca as float
    local sa as float
    local x1 as float
    local y1 as float
    local x2 as float
    local y2 as float
    local rx1 as float
    local ry1 as float
    local rx2 as float
    local ry2 as float

    n = shapeN[t]
    ca = cos(ang)
    sa = sin(ang)
    for i = 0 to n - 1
        j = mod(i + 1, n)
        x1 = shapeX[t, i] * sc
        y1 = shapeY[t, i] * sc
        x2 = shapeX[t, j] * sc
        y2 = shapeY[t, j] * sc
        rx1 = x1 * ca - y1 * sa + cx
        ry1 = x1 * sa + y1 * ca + cy
        rx2 = x2 * ca - y2 * sa + cx
        ry2 = x2 * sa + y2 * ca + cy
        DrawThickLine(rx1, ry1, rx2, ry2, r, g, b)
    next i
endfunction

// Five-segment value bar
function DrawBar(x as float, y as float, value as integer, r as integer, g as integer, b as integer)
    local s as integer
    local c as integer
    for s = 1 to 5
        if s <= value
            c = MakeColor(r, g, b)
        else
            c = MakeColor(40, 46, 70)
        endif
        DrawBox(x + (s - 1) * 26, y, x + (s - 1) * 26 + 22, y + 12, c, c, c, c, 1)
    next s
endfunction

// Background stars
function UpdateStars(dt as float)
    local i as integer
    for i = 0 to 119
        starY[i] = starY[i] + starS[i] * dt
        if starY[i] > SCR_H
            starY[i] = 0
            starX[i] = Random(0, SCR_W)
        endif
    next i
endfunction

function DrawStars()
    local i as integer
    local j as integer
    local c as integer
    local v as integer
    local skip as integer
    for i = 0 to 119
        skip = 0
        for j = 0 to holeN - 1
            if starX[i] > holeX1[j] - 4 and starX[i] < holeX2[j] + 4 and starY[i] > holeY1[j] - 4 and starY[i] < holeY2[j] + 4 then skip = 1
        next j
        if skip = 0
            v = 70 + starS[i] * 3
            c = MakeColor(v, v, v)
            DrawBox(starX[i], starY[i], starX[i] + 2, starY[i] + 2, c, c, c, c, 1)
        endif
    next i
endfunction

// Registers an area where stars are not drawn (takes effect on the next frame)
function AddHole(x1 as float, y1 as float, x2 as float, y2 as float)
    if holeN < 8
        holeX1[holeN] = x1
        holeY1[holeN] = y1
        holeX2[holeN] = x2
        holeY2[holeN] = y2
        inc holeN
    endif
endfunction

// ============================================================
//  MATH HELPER FUNCTIONS (AGK has no built-in Min/Max)
//  They return a float; when assigned to integers
//  the result is truncated, so they work exactly with integers.
// ============================================================
function Min(a as float, b as float)
    local r as float
    r = a
    if b < a then r = b
endfunction r

function Max(a as float, b as float)
    local r as float
    r = a
    if b > a then r = b
endfunction r

// ============================================================
//  STATE 3: END SCREEN (match winner)
// ============================================================
function StartEnd()
    matchWinner = winner
    endTimer = 0
    PlaySnd(SND_WIN, 80)
    state = STATE_END
endfunction

function DoEnd()
    local p as integer
    local w as integer
    local t as float

    endTimer = endTimer + GetFrameTime()
    t = Timer()
    w = matchWinner

    if GetRawKeyPressed(27)
        state = STATE_COUNT
        exitfunction
    endif
    if endTimer > 1.0 and mOK = 1
        for p = 1 to numHumans
            ready[p] = 0
        next p
        startTimer = 0
        PlaySnd(SND_CONFIRM, 50)
        state = STATE_SHIPS
        exitfunction
    endif

    Say("VICTORY!", 640, 30, 100, 1, pcR[w], pcG[w], pcB[w])
    SetLabelLong(w)
    Say(lblTmp, 640, 150, 60, 1, 255, 255, 255)
    if w > numHumans
        Say("AI opponent, difficulty: " + diffName[difficulty], 640, 218, 22, 1, 170, 180, 210)
    else
        Say("Congratulations!", 640, 218, 22, 1, 170, 180, 210)
    endif

    DrawShip(choice[w], 640, 320, t * 60.0, 4.0, pcR[w], pcG[w], pcB[w])
    Say(shipName[choice[w]], 640, 385, 30, 1, pcR[w], pcG[w], pcB[w])

    Say("FINAL SCORE", 640, 440, 26, 1, 200, 205, 225)
    for p = 1 to numPlayers
        SetLabelLong(p)
        Say(lblTmp + "   " + str(pScore[p]) + " wins", 640, 478 + (p - 1) * 28, 22, 1, pcR[p], pcG[p], pcB[p])
    next p

    if endTimer > 1.0
        Say("ENTER / SPACE / A = new match (ship select)     ESC = settings", 640, 660, 20, 1, 255, 255, 255)
    endif
endfunction

// ============================================================
//  BACKGROUND PANELS (sprites draw BELOW text, unlike DrawBox)
//  Order: later calls are closer to the front. a = opacity 0-255.
// ============================================================
function PanelFill(x1 as float, y1 as float, x2 as float, y2 as float, r as integer, g as integer, b as integer, a as integer)
    local id as integer

    if panelN < 30
        id = 101 + panelN
        if GetSpriteExists(id) = 0 then CreateSprite(id, 0)
        SetSpritePosition(id, x1, y1)
        SetSpriteSize(id, x2 - x1, y2 - y1)
        SetSpriteColor(id, r, g, b, a)
        SetSpriteDepth(id, 100 - panelN)
        SetSpriteVisible(id, 1)
        inc panelN
    endif
endfunction

function HidePanels()
    local id as integer
    for id = 101 to 130
        if GetSpriteExists(id) = 1 then SetSpriteVisible(id, 0)
    next id
    panelN = 0
endfunction
