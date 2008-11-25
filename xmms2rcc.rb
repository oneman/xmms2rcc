#!/usr/bin/env ruby
#
# xmms2 ruby curses client
#
# wrotted by David Richards

CLIENT = "xmms2rcc"
CLIENTVERSION = "0.2 Public Alpha"


require 'curses'
include Curses
require 'time'

IPCPATH = "unix:///tmp/xmms-ipc-oneman"


require "xmmsclient"

xc = Xmms::Client.new(CLIENT)
xc.connect

init_screen
begin
  crmode
  noecho
  stdscr.keypad(true)
  screen = stdscr.subwin(24, 80, 0, 0)
  screen.box(0,0)
  setpos(0,11); addstr("xmms2rcc version #{CLIENTVERSION}");

  setpos(3,15); addstr("Welcome to xmms2 ruby curses client");
  setpos(6,15); addstr("s to stop, p to play/resume, h to pause");
  setpos(7,15); addstr("q to quit, right left arrows to switch tracks");
#  do init stuff here

  Curses.timeout=0
  loop do
      case getch
      when ?Q, ?q    :  break
 #     when Key::UP   :  paddle.upq
 #     when Key::DOWN :  paddle.down
      when ?p, ?P
        xc.playback_start
        #xc.playback_tickle
        xc.playback_status.wait.value
      when ?h, ?h
        xc.playback_pause
        #xc.playback_tickle
        xc.playback_status.wait.value
      when ?s, ?S
        xc.playback_stop
        xc.playback_tickle
        xc.playback_status.wait.value
      when Key::RIGHT 
        xc.playlist_set_next_rel(1)
        xc.playback_tickle
        xc.playback_status.wait.value
      when Key::LEFT 
        xc.playlist_set_next_rel(-1)
        xc.playback_tickle
        xc.playback_status.wait.value
      else

 # update status
status = xc.playback_status.wait.value
if status == 1
   textstatus = "Playing"
else
   textstatus = "Stopped"
end

    setpos(18,6)
    addstr(textstatus)

    setpos(21,6)
    addstr( (Time.now.strftime("%m/%d/%Y %H:%M:%S")).to_s)


# update title

    setpos(9,6)
    addstr("Track")
    playback_id = xc.playback_current_id.wait.value


   
    res = xc.medialib_get_info(playback_id).wait
    current_track = res.value
    filename = current_track[:url].split("/").last.to_s
    trackinfo1 = current_track[:artist].to_s + " - " + current_track[:title].to_s
    #if current_track[:year].length > 2
    #   trackinfo1 = trackinfo1 + " - " + current_track[:year].to_s
    #end
    trackinfo1 = "" unless trackinfo1.length > 8 


    # clear old track info
    setpos(13,6)
    addstr("                                                   ")
    setpos(11,6)
    addstr("                                                   ")

    setpos(11,6)
    addstr(trackinfo1[0..50])
    setpos(13,6)
    addstr(filename[0..50])
 
# update playtime

     time = current_track[:duration] - xc.playback_playtime.wait.value
     #duration = format_time(@last_track.duration)
     minutes = (time/1000)/60
     seconds = ((time/1000)-(minutes*60)).to_s.rjust(2,'0')
     minutes = minutes.to_s


    setpos(18,43)
    addstr("Remaining: #{minutes}:#{seconds}")





    setpos(19,77)
    sleep 0.2
      end
  end
ensure
  close_screen
end
