//v0.1
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class RefereeTimer extends App.AppBase {

    // get default timer count from properties, if not set return default
    function getDefaultTimerCount() {
        var time = getProperty("time");
        if (time != null) {
            return time;
        } else {
            return 2400; // 40 min default timer count
        }
    }
    
    // set default timer count in properties
    function setDefaultTimerCount(time) {
        setProperty("time", time);
    }
    
    // get repeat boolean from properties, if not set return default
    function getRepeat() {
        var repeat = getProperty("repeat");
        if (repeat != null) {
            return repeat;
        } else {
            return false; // repeat off by default
        }
    }
    
    // set repeat boolean in properties
    function setRepeat(repeat) {
    //    setProperty("repeat", repeat);
    }

    // onStart() is called on application start up
    function onStart(state) {
   // System.println("onStart");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
   // System.println("onStop");
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new RefereeTimerView(), new RefereeTimerDelegate() ];
    //    System.println("getInitialView");
    }

}