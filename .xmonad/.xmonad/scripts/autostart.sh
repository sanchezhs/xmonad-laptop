#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#Set your native resolution IF it does not exist in xrandr
#More info in the script
#run $HOME/.xmonad/scripts/set-screen-resolution-in-virtualbox.sh

#Find out your monitor name with xrandr or arandr (save and you get this line)
#xrandr --output VGA-1 --primary --mode 1360x768 --pos 0x0 --rotate normal
#xrandr --output DP2 --primary --mode 1920x1080 --rate 60.00 --output LVDS1 --off &
#xrandr --output LVDS1 --mode 1366x768 --output DP3 --mode 1920x1080 --right-of LVDS1
#xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off

#(sleep 2; run $HOME/.config/polybar/launch.sh) &

#change your keyboard if you need it
#setxkbmap -layout be

#cursor active at boot
xsetroot -cursor_name left_ptr &

#Some ways to set your wallpaper besides variety or nitrogen
nitrogen --restore &

#starting utility applications at boot time
#eww daemon
run nm-applet &
run pamac-tray &
#run xfce4-power-manager &
run volumeicon &
numlockx on &
blueberry-tray &
#picom --config $HOME/.xmonad/scripts/picom.conf &
picom --config $HOME/.xmonad/scripts/picom-anim.conf &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
/usr/lib/xfce4/notifyd/xfce4-notifyd &

# check if trayer is already running
if ! pgrep -x "trayer" > /dev/null
then
    trayer \
    --edge top             \
    --align right          \
    --SetDockType true     \
    --SetPartialStrut true \
    --expand true          \
    --transparent true     \
    --width 8              \
    --height 40            \
    --tint 0x1e1e1e        \
    --alpha 0              \
    --iconspacing 9        \
    &
fi

#starting user applications at boot time
#nitrogen --restore &
#run caffeine &
#run vivaldi-stable &
#run firefox &
#run thunar &
#run spotify &
#run atom &

#run telegram-desktop &
#run discord &
#run dropbox &
#run insync start &
#run ckb-next -b &
