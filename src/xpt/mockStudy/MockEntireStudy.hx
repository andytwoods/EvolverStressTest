package xpt.mockStudy;
import xpt.mockStudy.MockEntireStudy.Params;
import xpt.mockStudy.MockEntireStudy.SJ;
import xpt.mockStudy.Scheduler;
import xpt.mockStudy.Scheduler.Plan;
import xpt.tools.XRandom;

/**
 * ...
 * @author Andy Woods
 */


@:allow(xpt.mockStudy.Test_MockEntireStudy)
class MockEntireStudy
{	
	var scheduler:Scheduler = new Scheduler(600);
	var params:Params;
	
	public function new() 
	{
		params = new Params();
		
		var SJs = generateSJs(params.numSJs, callback_for_SJs);
		randomlyFailSJs(SJs, params.percent_SJs_who_finish_study);
		
		scheduler = populate_scedule(params, SJs);
		
		run(scheduler, params);
		
	}
	
	private static function run(scheduler:Scheduler, params:Params) 
	{
		var plan:Plan = scheduler.next();
		while (plan != null) {
			plan = scheduler.next();
		}
	}
	
	private function callback_for_SJs(sj:SJ) {
		
	}
	
	
	
	
	
	
	
	static private function randomlyFailSJs(SJs:Array<SJ>, percent_SJs_who_finish_study:Float) 
	{
		var failures:Int = Std.int(percent_SJs_who_finish_study / 100 * SJs.length);
		for (i in 0...failures) {
			SJs[i].finishesStudy = false;
		}
		XRandom.shuffle(SJs);
	}
	
	static private function generateSJs(numSJs:Int, callback:SJ->Void):Array<SJ>
	{
		var SJs:Array<SJ> = new Array<SJ>();
		for (i in 0...numSJs) {
			SJs.push(new SJ(callback, i));
		}
		
		return SJs;
	}
	
	static private function populate_scedule(params:Params, SJs:Array<SJ>):Scheduler
	{
		var s:Scheduler = new Scheduler(params.scheduleStartingDuration);
		
		var total:Int = SJs.length;
		
		var some:Array<SJ>;
		
		var seconds_per_signup:Float = 60 / params.signup_per_minute;
		if (seconds_per_signup < 1) throw 'this function needs redesigning for when more than 1 SJ signs up per second.';
		
		var SJs_copy:Array<SJ> = new Array<SJ>();
		for (sj in SJs) {
			SJs_copy.push(sj);
		}
		
		var time:Int;
		var counter:Int = 0;
		var sj:SJ;
		while (SJs_copy.length > 0) {
			sj = SJs_copy.shift();
			time = Std.int(counter * seconds_per_signup);			
			var plan:Plan = s.add(time, null);
			sj.setupFutureRatings(plan, time, params);
			counter++;
		}
		
		return s;
		
	}

}

class SJ {

	public var finishesStudy:Bool = true;
	public var startTime:Int;
	public var ratingId:Int = -1;
	public var currentPlan:Plan = null;
	
	var callback:SJ->Void;
	var id:Int;
	
	public function new(callback:SJ->Void, id:Int) {
		this.callback = callback;
		this.id = id;
	}
	

	
	public function setupFutureRatings(plan:Plan, startTime:Int, params:Params) 
	{
		this.startTime = startTime;
		
		if (finishesStudy == false) return;
		
		
		var numAssessments:Int = params.assessments_per_SJ;
		var timePerAssessment:Int = params.seconds_per_rating;
		
		var counter:Int = 1;
		var offset:Int;
		while (numAssessments > 0) {
			offset = timePerAssessment * counter;

			plan.inFuture(offset, doneRatingPing);
			
			counter ++;
			numAssessments--;
		}

	}
	
	private function doneRatingPing(plan:Plan) {
		if (finishesStudy == false) throw 'devel err';
		
		ratingId++;
		currentPlan = plan;
		if (callback != null) callback(this);
	}
	
	
}


class Params {
	
	public function new(){}
	
	public var numSJs:Int = 10;
	public var assessments_per_SJ = 20;
	public var percent_SJs_who_finish_study:Float = 90;	
	public var signup_per_minute:Float = 20;
	public var seconds_per_rating:Int = 15;	
	public var scheduleStartingDuration:Int = 600;

	
}
 
 


