package xpt.mockStudy;
import xpt.mockStudy.Scheduler;



@:allow(xpt.mockStudy.Test_Sceduler,xpt.mockStudy.Test_MockEntireStudy)
class Scheduler
{

	private var schedule:Map<Int, Plan> = new Map<Int, Plan>();
	private var clock:Int = 0;
	var minutes:Int;
	
	//note that zero minutes added, so in effect we have minutes + 1
	public function new(minutes:Int) 
	{
		this.minutes = minutes;
		
		for (minute in 0...minutes+1) {
			schedule.set(minute, new Plan(this, minute));
		}
	}
	
	public function add(actualMinute:Int, f:Plan->Void ):Plan {
		//nb not efficient. No need to add 'vacant' Plans, given we use a Map, not Array.
		
		while (schedule.exists(actualMinute) == false) {
			minutes++;
			schedule.set(minutes, new Plan(this, minutes));
		}

		var plan = schedule.get(actualMinute);
		if(f!=null) plan.add(f);
		return plan;
	}
	
	public function next():Plan { 
		var plan:Plan = schedule.get(clock);
		if (plan == null) return null;
		plan.run();
		schedule.set(clock, null);
		clock++;
	
		return plan;
	}
	
	
}

@:allow(xpt.mockStudy.Test_MockEntireStudy)
class Plan {
	var parent:Scheduler;
	public var minute:Int;
	var toRun:Array<Plan->Void> = new Array<Plan->Void>();

	public function new(parent:Scheduler, minute:Int) {
		this.parent = parent;
		this.minute = minute;
	}
	
	public function inFuture(minutes_in_future:Int, f:Plan->Void) {
		parent.add(minute + minutes_in_future, f);
	}
	
	public function add(f:Plan->Void) {
		toRun.push(f);
	}
	
	public function run() {
		
		var f:Plan->Void;
		
		while ( toRun.length>0 ) {
			f = toRun.shift();
			f(this);
		}
	}
	
	public function kill() {
		
	}
	
	
}