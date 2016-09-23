//v0.1
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;
using Toybox.Attention as Attn;
using Toybox.Time.Gregorian as Cal;
using Toybox.Time as Time;

// globals
var m_actualtime;
var m_actualtimeDefaultCount;
var m_actualtimeCount;
var m_actualtimeRunning = false;
var m_actualtimeReachedZero = false;
var m_gametime;
var m_gametimeDefaultCount;
var m_gametimeCount = 0;
var m_gametimeRunning = false;
var m_gametimeOver = false;
var m_invertColors = false;
var m_savedClockMins;
var m_showClock = true;
var m_showPaused = false;
var m_GameTimePaused = false;
var m_alreadyAlerted = false;

class RefereeTimerView extends Ui.View
{
    function onUpdate(dc)
    {
    
    	//Format the display of Actual time
        var min = 0;
        var sec = m_actualtimeCount;
        
        // convert secs to mins and secs
        while (sec > 59) {
            min += 1;
            sec -= 60;
        }
    
        // make the secs pretty (heh heh)
        var stringActualTime;
        if (sec > 9) {
            stringActualTime = "" + min + ":" + sec;
        } else {
            stringActualTime = "" + min + ":0" + sec;
        }
        
        
        //Format the display of Game time
        var minGameTime = 0;
        var secGameTime = m_gametimeCount;
        
        // convert secs to mins and secs
        while (secGameTime > 59) {
            minGameTime += 1;
            secGameTime -= 60;
        }
    
        // make the secs pretty (heh heh)
        var stringGameTime;
        if (secGameTime > 9) {
            stringGameTime = "" + minGameTime + ":" + secGameTime;
        } else {
            stringGameTime = "" + minGameTime + ":0" + secGameTime;
        }
           
        
         // flip foreground and background colors based on invert colors boolean
        if (!m_invertColors) {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        } else {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_WHITE );
        }
        dc.clear();
        if (!m_invertColors) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT );
        }

        // display actual time - big middle
        if (m_actualtimeReachedZero) {
        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Gfx.FONT_NUMBER_THAI_HOT, stringActualTime, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
        
        // display status
        //show the clock if no status shown
		if (m_showClock) {
       		dc.setColor( Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 58, Gfx.FONT_MEDIUM, getClockTime(), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
		
		} else if (m_actualtimeReachedZero) {
		//Actual time over
		 	dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 58, Gfx.FONT_MEDIUM, "ACTUAL TIME OVER", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
       //     m_invertColors = !m_invertColors;      
         } else if (m_gametimeOver && m_showPaused)  {    
		//If paused after Game Time over - show different message to say Game Time is over but watch paused 
        	dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
         	dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 58, Gfx.FONT_SMALL, "PAUSED-GT OVER", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
        } else if 
		//Actual Time paused        
        	(m_showPaused) {
        	dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
         	dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 58, Gfx.FONT_MEDIUM, "PAUSED", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );     
 		} else if (m_gametimeOver) {
 		//Game Time reached zero
        	dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) + 58, Gfx.FONT_MEDIUM, "GAME TIME OVER", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
       //     m_invertColors = !m_invertColors;
       }
       
        dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
              
        //Display the Game Time - small top
        dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2) - 58, Gfx.FONT_MEDIUM, stringGameTime , Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER );
    }
    
    function getClockTime() {
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        if (!Sys.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format("$1$:$2$", [hours.format("%02d"), clockTime.min.format("%02d")]);
        return timeString;
    }

}

class RefereeTimerDelegate extends Ui.BehaviorDelegate {

    // ctor
    function initialize() {
        // init Game timer
        m_actualtime = new Timer.Timer();
        // load default timer count
        m_actualtimeDefaultCount = App.getApp().getDefaultTimerCount();
        m_actualtimeCount = m_actualtimeDefaultCount;
        // save off current clock minutes
        m_savedClockMins = Sys.getClockTime().min;
        // start timer
        m_actualtime.start( method(:timerCallback), 1000, true );
        
        // init Actual timer
        m_gametime = new Timer.Timer();
        // load default timer count
        m_gametimeDefaultCount = App.getApp().getDefaultTimerCount();
        //m_gametimeCount = m_gametimeDefaultCount;
 
        // start timer
        m_gametime.start( method(:TimerGameTimeCallback), 1000, true );
        m_showClock = true;
    }

    function onMenu() {
    /*  DH v0.5 Removed as Actual Time was stopping when going to the menu
      if (!m_actualtimeReachedZero) {
            m_actualtimeRunning = false;
            Sys.println("m_actualtimeRunning = false");
        } else if (!m_gametimeOver) {
            m_gametimeRunning = false;
            Sys.println("m_gametimeRunning = false");
        } else {
        Sys.println("resetTimer");
            resetTimer();
        }
*/        
        var menu = new Rez.Menus.RefereeTimerMenu();
        menu.setTitle("Setup");
        Ui.pushView(menu, new RefereeTimerMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }
    
    function showAbout() {
        var menu = new Rez.Menus.AboutMenu();
        menu.setTitle("About");
        Ui.pushView(menu, new showAboutMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }
    
    // tap to start/stop timer
    function onTap(evt) {
        startStop();
    }
    
    // hold to reset timer
    function onHold() {
        var vibe = [new Attn.VibeProfile(  50, 100 )];
        Attn.vibrate(vibe);
        resetTimer();
    }
    
    function onKey(key) {
        if (key.getKey() == Ui.KEY_ENTER) {
            startStop();
        } else if (key.getKey() == Ui.KEY_UP) {
            onMenu();
        } else if (key.getKey() == Ui.KEY_DOWN) {
            showAbout();
        }
	}      
          
    function startStop() {   
    alert();  
    //DH - Show the clock when not paused, show PAUSED when paused. 
    if (m_actualtimeRunning) {
    	m_showClock = false;
    	m_showPaused = true;
    }
    else if (!m_actualtimeRunning) {
    	m_showClock = true;
    	m_showPaused = false;		
   	}
   	
    //what happens when the ENTER button is pressed  	
    	
        Ui.requestUpdate();      
        //Actual time. This starts and stops when the ENTER button is pressed.  
         if (!m_actualtimeReachedZero) { 
        //Actual timer has not reached zero so there is still actual time remaining.
        	if (!m_actualtimeRunning) {
        	//if actual time is not running, i.e. is already in a paused state, then restart the timer
        	// reset timer so the user doesn't only get a partial second to start     		
                m_actualtime.stop();
                m_actualtime.start( method(:timerCallback), 1000, true );
            }
            //from "if (!m_actualtimeReachedZero) {" 
            //if the timer has reached zero then it is not running, so set the state to not running.    
            m_actualtimeRunning = !m_actualtimeRunning;
            //set timer to not running as it has reached zero
        } else {
        /*  resetTimerGameTime();
            resetTimer();*/
         //Reset the timer once actual time is finished  
        }  
        
        //Game time. This keeps running down. Does not stop when any keys are pressed.
         if (!m_gametimeOver) { 
        //timer not at zero, still got time	remaining
        	if (!m_gametimeRunning) {
        		//alreay paused
                // reset timer so the user doesn't only get a partial second to start
                m_gametime.stop();
                m_gametime.start( method(:TimerGameTimeCallback), 1000, true );
            }
            
            // DH - this starts the Game Time running but it never stops. 
            m_gametimeRunning = true;
            //always keep game time running
        } else {         

            // set to not running, not zero
        }       
    }
    
    function timerCallback() {
        if (!m_actualtimeRunning) {
            // state 1: timer is not running
            // refresh the UI only if the minute has changed
            if (m_savedClockMins != Sys.getClockTime().min) {
                m_savedClockMins = Sys.getClockTime().min;
                Ui.requestUpdate();
            }
        } else if (!m_actualtimeReachedZero) {
            // state 2: timer is running
            // decrement the timer until zero, refreshing the UI each time
            // when zero is reached, trigger alerts
            m_actualtimeCount -= 1;
            if (m_actualtimeCount > 0) {
                Ui.requestUpdate();
            } else  {
                reachedZero();
            }
        } else {
        
        	// DH - Reset the timer but do not restart it automatically. Only reset when actual time is up.
            // state 3: timer has completed
            // repeat or alert based on user configuration
          	// if (m_repeat) {
                resetTimer();
                resetTimerGameTime();           
            //   startStop();
          	//  } else {
                Ui.requestUpdate();
                alert();
           // }
        }
    }
    
     function TimerGameTimeCallback() {
        if (!m_gametimeRunning) {
            // state 1: timer is not running
            // refresh the UI only if the minute has changed
            if (m_savedClockMins != Sys.getClockTime().min) {
                m_savedClockMins = Sys.getClockTime().min;
                Ui.requestUpdate();
            }
        } else if (!m_gametimeOver) {
            // state 2: timer is running
            // decrement the timer until zero, refreshing the UI each time
            // when zero is reached, trigger alerts
            m_gametimeCount += 1;
            if (m_gametimeCount < m_gametimeDefaultCount) {
                Ui.requestUpdate();
            } else  {
                reachedZeroGameTime();
                alertGameTime();
            }
        } else {
            /* DH - Reset the timer but do not restart it automatically
            // state 3: timer has completed
            // repeat or alert based on user configuration
           	// if (m_repeat) {
            //    resetTimer();
            //   startStop();
          	  } else {
          	*/
                Ui.requestUpdate();
                alertGameTime();
            //  }
        }
    }
    
    function alert() {
        var vibe = [new Attn.VibeProfile(  50, 125 ),
                    new Attn.VibeProfile( 100, 125 ),
                    new Attn.VibeProfile(  50, 125 ),
                    new Attn.VibeProfile( 100, 125 )];
        Attn.vibrate(vibe);
        
     }
     
    function alertGameTime() {
       	if (!m_alreadyAlerted){    
        var vibeGameTime = [new Attn.VibeProfile(  50, 125 ),
                    new Attn.VibeProfile( 100, 125 ),
                    new Attn.VibeProfile(  50, 125 ),
                    new Attn.VibeProfile( 100, 125 )];
                    Attn.vibrate(vibeGameTime);
			        m_alreadyAlerted = true; 
         }
         
        // removed because vivoactive crashes
        //Attn.playTone(Attn.TONE_TIME_ALERT); // 12
    }
    
    //Actual time at zero
    function reachedZero() {
    	m_showClock= false;
        m_actualtimeReachedZero = true;
        m_invertColors = true;
        Ui.requestUpdate();
        alert();
    }
    
    //Game time at zero
    function reachedZeroGameTime() {
    	m_GameTimePaused = true;
    	m_showClock= false;
        m_gametimeOver = true;
        m_alreadyAlerted = false;
        //m_invertColors = true;
        Ui.requestUpdate();
        alertGameTime();
    }
    
    function resetTimer() {
        m_actualtimeReachedZero = false;
        m_actualtimeRunning = false;
        m_actualtimeCount = m_actualtimeDefaultCount;
        m_invertColors = false;
        //show the clock
        m_showClock = true;
        m_alreadyAlerted = true;
        Ui.requestUpdate();
    }

    function resetTimerGameTime() {
        m_gametimeOver = false;
        m_gametimeRunning = false;
        //m_gametimeCount = m_gametimeDefaultCount;
        m_gametimeCount=0;
        m_invertColors = false;
        m_alreadyAlerted = true;
        Ui.requestUpdate();
    }
}

class RefereeTimerMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        if (item == :item_45) {
            setTimer(2700);
        } else if (item == :item_40) {
            setTimer(2400);
        } else if (item == :item_30) {
            setTimer(1800);
        /*} else if (item == :item_120) {
            setTimer(120);
        } else if (item == :item_300) {
            setTimer(300);
        } else if (item == :item_1800) {
            setTimer(1800);*/
        } else if (item == :item_custom) {
            var customDuration = Cal.duration( {:minutes=>1} );
            var customTimePicker = new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME_MIN_SEC, customDuration);
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            Ui.pushView(customTimePicker, new CustomTimePickerDelegate(), Ui.SLIDE_IMMEDIATE);
            //Ui.switchToView(customTimePicker, new CustomTimePickerDelegate(), Ui.SLIDE_IMMEDIATE);
       } /* else if (item == :item_repeat) {
            toggleRepeat();
        }
       */
    }  
    
    
    function setTimer(time) {
        m_actualtimeReachedZero = false;
        m_gametimeOver = false;
        m_actualtimeRunning = false;
        m_gametimeRunning = false;
        m_actualtimeDefaultCount = time;
        m_gametimeDefaultCount = time;
        App.getApp().setDefaultTimerCount(m_actualtimeDefaultCount); // save new default to properties     
        m_actualtimeCount = m_actualtimeDefaultCount;
        //m_gametimeCount = m_actualtimeDefaultCount;
        m_gametimeCount=0;
        m_invertColors = false;
        Ui.requestUpdate();
    }
    
}

class CustomTimePickerDelegate extends Ui.NumberPickerDelegate {
    function onNumberPicked(value) {
        setCustomTimer(value.value());
    }
    
    function setCustomTimer(time) {
        m_actualtimeReachedZero = false;
        m_gametimeOver = false;
        m_actualtimeRunning = false;
        m_gametimeRunning = false;
        m_actualtimeDefaultCount = time;
        m_gametimeDefaultCount = time;
        App.getApp().setDefaultTimerCount(m_actualtimeDefaultCount); // save new default to properties
        m_actualtimeCount = m_actualtimeDefaultCount;
        //m_gametimeCount = m_actualtimeDefaultCount;
        m_gametimeCount = 0;
        m_invertColors = false;
        Ui.requestUpdate();
    }
}

class showAboutMenuDelegate extends Ui.MenuInputDelegate {

}



