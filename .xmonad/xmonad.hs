import System.IO
import System.Exit

import XMonad
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog)
import XMonad.Config.Desktop
import XMonad.Config.Azerty
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.SpawnOn
import XMonad.Util.EZConfig (additionalKeys, additionalMouseBindings)
import XMonad.Actions.CycleWS
import XMonad.Hooks.UrgencyHook
import qualified Codec.Binary.UTF8.String as UTF8

import XMonad.Util.Themes
import XMonad.Layout.Tabbed
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.ClickableWorkspaces

import Data.Char (isSpace, toLower)
import XMonad.Util.WorkspaceCompare(getSortByIndex)
import XMonad.Util.Loggers

import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.ResizableTile
---import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.Cross(simpleCross)
import XMonad.Layout.Spiral(spiral)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.IndependentScreens

import qualified XMonad.Util.Hacks as Hacks
import XMonad.Layout.CenteredMaster(centerMaster)

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified Data.ByteString as B
import Control.Monad (liftM2)
import qualified DBus as D
import qualified DBus.Client as D

myStartupHook :: X ()
myStartupHook = do
    spawn "$HOME/.xmonad/scripts/autostart.sh"
    setWMName "LG3D"

normBord, focdBord, fore, back, winType :: String
normBord = "#4c566a"
focdBord = "#5e81ac"
fore     = "#DEE3E0"
back     = "#282c34"
winType  = "#c678dd"

myModMask :: KeyMask
myModMask = mod4Mask

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myBorderWidth :: Dimension
myBorderWidth = 3

myWorkspaces :: [String]
myWorkspaces    = map show [1 .. 9]

myBaseConfig = desktopConfig

volDown, volUp, mute, brightnessUp, brightnessDown :: KeySym 
volDown = 0xffbf
volUp = 0xffc0
mute = 0xffbe
brightnessDown = 0xffc6
brightnessUp = 0xffc7

windowCount :: Logger
windowCount = do
    ws <- gets windowset
    let count = length . W.integrate' . W.stack . W.workspace . W.current $ ws
    return $ Just $ show count

concatLoggers :: Logger -> Logger -> Logger
concatLoggers logger1 logger2 = do
    output1 <- logger1
    output2 <- logger2
    return $ (++) <$> output1 <*> output2    


toggleFloat :: Window -> X ()
toggleFloat w = windows (\s -> if M.member w (W.floating s)
                            then W.sink w s
                            else (W.float w (W.RationalRect (1/4) (1/8) (1/2) (4/5)) s))

-- window manipulations
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    ]
    where
    -- doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["Archlinux-logout.py", "Arandr", "Arcolinux-calamares-tool.py", "Archlinux-tweak-tool.py", "Arcolinux-welcome-app.py", "Galculator", "feh", "mpv", "Xfce4-terminal"]
    myTFloats = ["Downloads", "Save As..."]
    myRFloats = []
    myIgnores = ["desktop_window"]
    -- my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    -- my2Shifts = []
    -- my3Shifts = ["Inkscape"]
    -- my4Shifts = []
    -- my5Shifts = ["Gimp", "feh"]
    -- my6Shifts = ["vlc", "mpv"]
    -- my7Shifts = ["Virtualbox"]
    -- my8Shifts = ["Thunar"]
    -- my9Shifts = []
    -- my10Shifts = ["discord"]


{- myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        ratio = 1/2
        delta = 3/100 -}


myLayout = spacingRaw True (Border 0 5 5 5) True (Border 5 5 5 5) True $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ tiled |||tabbedL ||| Full
    where
        tabbedL = tabbed shrinkText (theme adwaitaDarkTheme)
        tiled = Tall nmaster delta tiled_ratio
        nmaster = 1
        delta = 3/100
        tiled_ratio = 1/2 


myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, 1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, 2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, 3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))

    ]



-- keys config
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- SUPER + FUNCTION KEYS

  [((modMask, xK_f), sendMessage $ Toggle NBFULL)
  , ((modMask, xK_q), kill )
  , ((modMask, xK_r), spawn $ "rofi -show" )
  , ((modMask, xK_w), spawn $ "rofi -show run" )
  , ((modMask, xK_v), spawn $ "pavucontrol" )
  , ((modMask, xK_x), spawn $ "archlinux-logout" )
  , ((modMask, xK_Escape), spawn $ "xkill" )
  , ((modMask, xK_Return), spawn $ "alacritty" )

  , ((modMask, xK_l), spawn $ "betterlockscreen -l" )

  -- SUPER + SHIFT KEYS

  , ((modMask .|. shiftMask , xK_Return ), spawn $ "thunar")
  , ((modMask, xK_d ), spawn $ "~/.xmonad/launcher/launcher.sh")
  , ((modMask .|. shiftMask , xK_r ), spawn $ "xmonad --recompile && xmonad --restart")
  , ((modMask .|. shiftMask , xK_q ), kill)
  -- , ((modMask .|. shiftMask , xK_x ), io (exitWith ExitSuccess))

  -- CONTROL + ALT KEYS

  , ((controlMask .|. mod1Mask , xK_a ), spawn $ "xfce4-appfinder")
  , ((controlMask .|. mod1Mask , xK_b ), spawn $ "thunar")
  , ((controlMask .|. mod1Mask , xK_e ), spawn $ "archlinux-tweak-tool")
  , ((controlMask .|. mod1Mask , xK_f ), spawn $ "firefox")
  , ((controlMask .|. mod1Mask , xK_g ), spawn $ "chromium -no-default-browser-check")
  , ((controlMask .|. mod1Mask , xK_i ), spawn $ "nitrogen")
  , ((controlMask .|. mod1Mask , xK_k ), spawn $ "archlinux-logout")
  , ((controlMask .|. mod1Mask , xK_l ), spawn $ "archlinux-logout")
  , ((controlMask .|. mod1Mask , xK_m ), spawn $ "xfce4-settings-manager")
  , ((controlMask .|. mod1Mask , xK_o ), spawn $ "$HOME/.xmonad/scripts/picom-toggle.sh")
  , ((controlMask .|. mod1Mask , xK_p ), spawn $ "pamac-manager")
  , ((controlMask .|. mod1Mask , xK_r ), spawn $ "rofi-theme-selector")
  , ((controlMask .|. mod1Mask , xK_s ), spawn $ "spotify")
  , ((controlMask .|. mod1Mask , xK_t ), spawn $ "alacritty")
  , ((controlMask .|. mod1Mask , xK_u ), spawn $ "pavucontrol")
  , ((controlMask .|. mod1Mask , xK_v ), spawn $ "vivaldi-stable")
  , ((controlMask .|. mod1Mask , xK_w ), spawn $ "arcolinux-welcome-app")
  , ((controlMask .|. mod1Mask , xK_Return ), spawn $ "alacritty")

  ,((mod4Mask, xK_g     ), sendMessage ToggleStruts)
  --SCREENSHOTS

  , ((0, xK_Print), spawn $ "scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")
  , ((controlMask, xK_Print), spawn $ "xfce4-screenshooter" )
  , ((controlMask .|. shiftMask , xK_Print ), spawn $ "gnome-screenshot -i")
  , ((controlMask .|. modMask , xK_Print ), spawn $ "flameshot gui")

  --MULTIMEDIA KEYS

  -- Mute volume
  , ((0, mute), spawn $ "amixer -q set Master toggle")

  -- Increase volume 
  , ((0, volUp), spawn $ "amixer -q set Master 5%+")
  
  -- Decrease volume 
  , ((0, volDown), spawn $ "amixer -q set Master 5%-")

  -- Increase brightness
  , ((0, brightnessUp),  spawn $ "brightnessctl s 5%+")

  -- Decrease brightness
  , ((0, brightnessDown), spawn $ "brightnessctl s 5%-")

--  , ((0, xF86XK_AudioPlay), spawn $ "mpc toggle")
--  , ((0, xF86XK_AudioNext), spawn $ "mpc next")
--  , ((0, xF86XK_AudioPrev), spawn $ "mpc prev")
--  , ((0, xF86XK_AudioStop), spawn $ "mpc stop")

  , ((0, xF86XK_AudioPlay), spawn $ "playerctl play-pause")
  , ((0, xF86XK_AudioNext), spawn $ "playerctl next")
  , ((0, xF86XK_AudioPrev), spawn $ "playerctl previous")
  , ((0, xF86XK_AudioStop), spawn $ "playerctl stop")


  --------------------------------------------------------------------
  --  XMONAD LAYOUT KEYS

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space), sendMessage NextLayout)

  --Focus selected desktop
  , ((mod1Mask, xK_Tab), nextWS)

  --Focus selected desktop
  , ((modMask, xK_Tab), nextWS)

  --Focus selected desktop
  , ((mod4Mask .|. shiftMask, xK_Left ), prevWS)

  --Focus selected desktop
  , ((modMask .|. shiftMask, xK_Right ), nextWS)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Move focus to the next window.
  , ((modMask, xK_j), windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k), windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask .|. shiftMask, xK_m), windows W.focusMaster  )

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown  )

  -- Swap the focused window with the next window.
  , ((controlMask .|. modMask, xK_Down), windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k), windows W.swapUp    )

  -- Swap the focused window with the previous window.
  , ((controlMask .|. modMask, xK_Up), windows W.swapUp  )

  -- Shrink the master area.
  , ((modMask .|. shiftMask , xK_h), sendMessage Shrink)

  -- Expand the master area.
  , ((modMask .|. shiftMask , xK_l), sendMessage Expand)

  -- Push window back into tiling.
  , ((mod4Mask .|. shiftMask , xK_t), withFocused $ windows . W.sink)

  -- Float window
  , ((mod4Mask .|. shiftMask , xK_f), withFocused toggleFloat)

  -- Increment the number of windows in the master area.
  , ((controlMask .|. modMask, xK_Left), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((controlMask .|. modMask, xK_Right), sendMessage (IncMasterN (-1)))

  ]

  ++

  [((m .|. modMask, k), windows $ f i)
   | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7,xK_8,xK_9,xK_0]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
      --, (\i -> W.greedyView i . W.shift i, shiftMask)]]
  
 {-  ++
    
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_Left, xK_Right] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]] -}
 

myPP :: Handle -> PP 
myPP myBar = def {
      ppCurrent           = xmobarColor "#409EFF" "#1E1E1E"   
    , ppVisible           = xmobarColor "#4EC9B0" ""                
    , ppHidden            = xmobarColor "#D4D4D4" ""                        
    , ppHiddenNoWindows   = xmobarColor "#858585" ""                         
    , ppTitle             = xmobarColor "#4EC9B0" ""                        
    , ppTitleSanitize     = const ""                                       
    , ppLayout            = xmobarColor "#D4D4D4" ""                      
    , ppSep               = xmobarColor "#666666" "" "  |  "                 
    , ppWsSep             = concat $ replicate 7 " "                        
    , ppOrder             = \(ws: _ : _ :e) -> [ws] ++ e                   
    , ppSort              = getSortByIndex                                 
    , ppExtras            = [currLayout, windowCount, currTitle]          
    , ppOutput            = hPutStrLn myBar                              
    }
    where
        l = logLayout
        currTitle = shortenL 25 logTitle
        currLayout = concatLoggers l (wrapL "  <icon=/home/samuel/.xmonad/icons/" "_selected.xpm/>" l) 

main :: IO ()
main = do
    myBar <- spawnPipe "xmobar  ~/.xmonad/xmobarrc.hs" 
    xmonad . ewmhFullscreen . ewmh . docks $ myBaseConfig 
        {startupHook = myStartupHook
        , layoutHook = avoidStruts $ gaps [(U,15), (D,5), (R,5), (L,5)] $ myLayout 
        , logHook = clickablePP (myPP myBar) >>= dynamicLogWithPP
        , manageHook = manageSpawn <+> myManageHook <+> manageHook myBaseConfig
        , modMask = myModMask
        , borderWidth = myBorderWidth
        , handleEventHook = handleEventHook myBaseConfig <> Hacks.trayerPaddingXmobarEventHook
        , focusFollowsMouse = myFocusFollowsMouse
        , workspaces = myWorkspaces
        , focusedBorderColor = focdBord
        , normalBorderColor = normBord
        , keys = myKeys
        , mouseBindings = myMouseBindings
        }
