#!/usr/bin/env ruby
#
# xmms2 ruby curses client
#
# wrotted by David Richards
#
# license is give me some money please :D 

CLIENT = "xmms2rcc"
CLIENTVERSION = "0.3 Public Alpha"


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
  setpos(0,45); addstr("xmms2rcc version #{CLIENTVERSION}");

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

    setpos(10,6)
    addstr("Current Track:")
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
    setpos(12,6)
    addstr("                                                   ")
    setpos(11,6)
    addstr("                                                   ")

    setpos(11,6)
    addstr(trackinfo1[0..50])
    setpos(12,6)
    addstr(filename[0..50])



# update title 2  TEST CRAPVERSON OK

    playlist = xc.playlist.entries.wait.value

    playback_id = xc.playback_current_id.wait.value

    for track in playlist
        if track == playback_id
         nextplayback_id = playlist[playlist.index(track) + 1]
        end
    end

   if nextplayback_id != nil
    res = xc.medialib_get_info(nextplayback_id).wait
    current_track = res.value
    filename = current_track[:url].split("/").last.to_s
    trackinfo1 = current_track[:artist].to_s + " - " + current_track[:title].to_s
    #if current_track[:year].length > 2
    #   trackinfo1 = trackinfo1 + " - " + current_track[:year].to_s
    #end
   end
    trackinfo1 = "" unless trackinfo1.length > 8 

    setpos(14,6)
    addstr("Next Track:              ")

    # clear old track info
    setpos(16,6)
    addstr("                                                   ")
    setpos(15,6)
    addstr("                                                   ")
   if nextplayback_id != nil
    setpos(16,6)
    addstr(trackinfo1[0..50])
    setpos(15,6)
    addstr(filename[0..50])
   else
    setpos(14,6)
    addstr("End of playlist")

   end

# END CRAP TEST
 
# update playtime
     playtime = xc.playback_playtime.wait.value
     time = current_track[:duration] - playtime
     #duration = format_time(@last_track.duration)
     minutes = (time/1000)/60
     seconds = ((time/1000)-(minutes*60)).to_s.rjust(2,'0')
     minutes = minutes.to_s


    setpos(18,43)
    addstr("Remaining: #{minutes}:#{seconds}")

# wooot ghetto progress bar
    playback_percent = ((playtime / (current_track[:duration] / 1000)) * 0.1).to_s.to_i

    setpos(20,43)

    case playback_percent

    when 0..10
     addstr("[=         ]")
    when 11..20
     addstr("[==        ]")
    when 21..30
     addstr("[===       ]")
    when 31..40
     addstr("[====      ]")
    when 41..50
     addstr("[=====     ]")
    when 51..60
     addstr("[======    ]")
    when 61..70
     addstr("[=======   ]")
    when 71..80
     addstr("[========  ]")
    when 81..90
     addstr("[========= ]")
    when 91..100
     addstr("[==========]")
    end
    
    setpos(20,56)
    addstr("#{playback_percent}% ")
# end ghetto progress bar



    setpos(19,77)
    sleep 0.2
      end
  end
ensure
  close_screen
end
