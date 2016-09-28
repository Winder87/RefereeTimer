//v0.1
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Position as Position;

class RefereeTimer extends App.AppBase {
	var refereeTimerView;

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
    Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
   // System.println("onStart");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	refereeTimerView.stopRecording();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
   // System.println("onStop");
    }

    // Return the initial view of your application here
    function getInitialView() {
    	refereeTimerView = new RefereeTimerView();
        return [ refereeTimerView, new RefereeTimerDelegate() ];
    //    System.println("getInitialView");
    }
    function onPosition(info) {
    }

}