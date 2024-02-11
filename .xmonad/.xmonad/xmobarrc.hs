Config { 

 -- appearance
     font =         "Iosevka Normal 17"--"Ubuntu Semibold 17"--"Bitstream Vera Sans Mono Bold 16"
   , bgColor =      "#1e1e1e"  
   , fgColor =      "#f3f4f5"  
   , position =     TopH 45
   , border =       NoBorder

   -- layout
   , sepChar =  "%"   
   , alignSep = "}{"
   , template = "  %UnsafeStdinReader% } <action=`bash /home/samuel/.xmonad/scripts/calendar.sh`>%date%</action> { %battery% %mybright% %_XMONAD_TRAYPAD%"

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)
   , iconRoot = "/home/samuel/.xmonad/icons/"
   -- plugins
   --   Numbers can be automatically colored according to their value. xmobar
   --   decides color based on a three-tier/two-cutoff system, controlled by
   --   command options:
   --     --Low sets the low cutoff
   --     --High sets the high cutoff
   --
   --     --low sets the color below --Low cutoff
   --     --normal sets the color between --Low and --High cutoffs
   --     --High sets the color above --High cutoff
   --
   --   The --template option controls how the plugin is displayed. Text
   --   color can be set by enclosing in <fc></fc> tags. For more details
   --   see http://projects.haskell.org/xmobar/#system-monitor-plugins.
 , commands = 

        -- weather monitor
        [ Run Weather "RJTT" [ "--template", "<skyCondition>  |  <fc=#6790EB><tempC></fc>°C | <fc=#6790EB><rh></fc>% | <fc=#6790EB><pressure></fc>hPa"
                             ] 36000

        -- network activity monitor (dynamic interface resolution)
        , Run DynNetwork     [ "--template" , "<dev>: <tx>kB/s|<rx>kB/s"
                             , "--Low"      , "1000"       -- units: B/s
                             , "--High"     , "5000"       -- units: B/s
                             , "--low"      , "#a3be8c"   -- Green (Volume Min from your previous config)
                             , "--normal"   , "#ebcb8b"   -- Yellow (Volume Med from your previous config)
                             , "--high"     , "#bf616a"   -- Red (Volume Max from your previous config)
                             ] 10
        -- cpu activity monitor
        , Run MultiCpu       [ "--template" , "Cpu: <total0>%|<total1>%"
                             , "--Low"      , "50"
                             , "--High"     , "85"
                             , "--low"      , "#a3be8c"
                             , "--normal"   , "#ebcb8b"
                             , "--high"     , "#bf616a"
                             ] 10

        -- rest of the config remains unchanged...
        , Run Com "/bin/bash" ["-c", "echo Bright: `brightnessctl | grep -oP '\\(\\K[0-9]+(?=%\\))'`%"] "mybright" 1
        --, Run Brightness ["-t", "<bar>", "--", "-D", "/sys/class/backlight/intel_backlight"] 60
        -- battery monitor
        , Run Battery        [ "--template" , "Bat: <acstatus>"
                             , "--Low"      , "10"
                             , "--High"     , "80"
                             , "--low"      , "#bf616a"
                             , "--normal"   , "#a3be8c"
                             , "--high"     , "#a3be8c"

                             , "--" 
                                       , "-o"	, "<left>% (<timeleft>)"
                                       , "-O"	, "<left>% <fc=#d08770>Charging</fc>"  -- Adjusted to a slightly different color
                                       , "-i"	, "<fc=#5e81ac>Charged</fc>"
                             ] 50
        -- <action=`xclock`>%date%</action>
        -- time and date indicator 
        , Run Date           "<fc=#ABABAB>%A %d %b, %H:%M</fc>" "date" 10
        -- keyboard layout indicator
        , Run Kbd            [ ("us(dvorak)" , "<fc=#00008B>DV</fc>")
                             , ("us"         , "<fc=#8B0000>US</fc>")
                             ]
        , Run XPropertyLog "_XMONAD_TRAYPAD"
        , Run UnsafeStdinReader
        ]
   }
