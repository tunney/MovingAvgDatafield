using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class MovingAvgDatafieldView extends Ui.DataField {

    hidden var displayValue;
	hidden var rollingArray;
	hidden var pointer;
	hidden var rolled;
	hidden var duration;
	hidden var resetOnLap;
		
    function initialize() {
        DataField.initialize();
        
        duration = Application.getApp().getProperty("duration_prop");
        resetOnLap = Application.getApp().getProperty("lapreset_prop");
        
        rollingArray = new[duration];
        displayValue = 0;
        pointer = 0;
        rolled = false;
        
        
    }

	function onTimerLap(){
		if(resetOnLap){
			pointer = 0;
			System.println("reset on lap");
			rollingArray = new[duration];
			rolled = false;
		}
	}
	
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 26;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

		if (getBackgroundColor() == Gfx.COLOR_BLACK) {
            View.findDrawableById("label").setColor(Gfx.COLOR_WHITE);
        } else {
        	View.findDrawableById("label").setColor(Gfx.COLOR_BLACK);
        }
        
        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
       
       	var mTime;
       	var power;
       	
       	if(info.timerState == Activity.TIMER_STATE_ON){
	        if(info has :currentPower){
	        	if(info.currentPower != null){
	                power = info.currentPower;
	                rollingArray[pointer % duration] = power;
	                pointer ++;
	                if(pointer > duration){
	                	pointer = 0;
	                	rolled = true;
	                } 
	                
	                var tempSum = 0;
	                for (var i = 0; i < rollingArray.size(); i++) {
	                	if(rollingArray[i] != null){
	                		tempSum += rollingArray[i];
	                	}
	                }
	                var div = duration;
	                if(!rolled){
	                	div = pointer;
	                }
	                
	                displayValue = tempSum/div;
	                
	                System.println("time: " + info.timerTime);
	                System.println("tempsum: " + tempSum);
	                System.println("avg: " +info.averagePower);
	                System.println("power: " + power);
	                System.println("value: " + displayValue);
	                System.println("pointer: " + pointer);
	                System.println("rolling: " + rolled);
	                System.println("div: " + div);
	                System.println("duration: " + duration);
	                System.println("lapreset: " + resetOnLap);
	                System.println("--------"); 
	            } 
	        }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());
        
        // Set the foreground color and value
        var value = View.findDrawableById("value");
        if (getBackgroundColor() == Gfx.COLOR_BLACK) {
            value.setColor(Gfx.COLOR_WHITE);
            View.findDrawableById("label").setColor(Gfx.COLOR_WHITE);
        } else {
            value.setColor(Gfx.COLOR_BLACK);
        	View.findDrawableById("label").setColor(Gfx.COLOR_BLACK);
        }
        value.setText(displayValue.format("%.0f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
