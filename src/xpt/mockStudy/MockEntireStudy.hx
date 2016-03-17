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
	var return_item:Int->Int->Int->Void;
	var get_item:Int->Void;
	var transmissions:TransmissionManager;
	
	public function new(get_item:Int->Void = null, return_item:Int->Int->Int->Void = null, params:Params = null) 
	{
		if (params == null) params = new Params();
		
		transmissions = new TransmissionManager(params);
		
		this.get_item = get_item;
		this.return_item = return_item;
		
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
	
	//SJ requests a stimulus to test
	private function callback_for_SJs(sj:SJ, event:SJevent, data:Map<String,Dynamic>) {
		switch(event) {
		
			case GetStimulus:
				if (get_item != null) {
					
					if(transmissions.successGet()) {
						//var item = get_item(sj.id);
					}
					
				}
				
			case ReturnStimulus:
				
				if(transmissions.successReturn()) {
				
					//var rating_params:Map<String,Int> = sj.getRatingParams();
					//if(return_item !=null) return_item( rating_params
				}
		}
	}
	
	
	
	
	
	
	
	static private function randomlyFailSJs(SJs:Array<SJ>, percent_SJs_who_finish_study:Float) 
	{
		var failures:Int = Std.int(percent_SJs_who_finish_study / 100 * SJs.length);
		for (i in 0...failures) {
			SJs[i].finishesStudy = false;
		}
		XRandom.shuffle(SJs);
	}
	
	static private function generateSJs(numSJs:Int, callback:SJ->SJevent->Map<String,Dynamic>->Void):Array<SJ>
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

@:allow(xpt.mockStudy.Test_MockEntireStudy)
class SJ {

	public var finishesStudy:Bool = true;
	public var startTime:Int;
	public var ratingId:Int = 0;
	public var currentPlan:Plan = null;
	public var id:Int;
	
	var callback:SJ->SJevent->Map<String,Dynamic>->Void;
	var numAssessments:Int;
	
	public function new(callback:SJ->SJevent->Map<String,Dynamic>->Void, id:Int) {
		this.callback = callback;
		this.id = id;
	}

	public function setupFutureRatings(plan:Plan, startTime:Int, params:Params) 
	{
		this.startTime = startTime;
		
		if (finishesStudy == false) return;
		requestStimulus();
		
		var _numAssessments:Int = numAssessments = params.assessments_per_SJ;
		var timePerAssessment:Int = params.seconds_per_rating;
		
		var counter:Int = 1;
		var offset:Int;
		while (_numAssessments > 0) {
			offset = timePerAssessment * counter;

			plan.inFuture(offset, doneRatingPing);
			
			counter ++;
			_numAssessments--;
		}
	}
	
	function requestStimulus() 
	{
		if(callback != null) callback(this, GetStimulus, null);
	}
	
	function returnStimulus() {
		if(callback != null) callback(this, ReturnStimulus, null);
	}
	
	private function doneRatingPing(plan:Plan) {
		if (finishesStudy == false) throw 'devel err';
		
		ratingId++;
		currentPlan = plan;
		returnStimulus();
		
		if (ratingId < numAssessments) requestStimulus();
		
		if (ratingId > numAssessments) throw 'devel er, ratingId  >= numAssessments';
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
	public var sendDataPercentageFailureRate:Float = 0;
	public var retrieveDataPercentFailureRate:Float = 0;
	
}
 
 
enum SJevent {
	GetStimulus;
	ReturnStimulus;
}

@:allow(xpt.mockStudy.Test_MockEntireStudy)
class TransmissionManager {
	var params:Params;
	var getPool:Array<Bool>;
	var returnPool:Array<Bool>;
	var estPoolSize:Int;
	
	public function new(params:Params) {
		this.params = params;
		estPoolSize = params.numSJs * params.assessments_per_SJ;
		getPool = generatePool(params.retrieveDataPercentFailureRate);
		returnPool = generatePool(params.sendDataPercentageFailureRate);
	}
	
	
	function generatePool(percentFail:Float):Array<Bool>
	{
		var a:Array<Bool> = new Array<Bool>();
		
		var failures:Int = Std.int(estPoolSize * percentFail / 100);
		var successes:Int = estPoolSize - failures;
		
		while(failures > 0) {
			a.push(false);
			failures--;
		}
		while (successes > 0) {
			a.push(true);
			successes--;
		}
		
		return XRandom.shuffle(a);
		
	}
	
	public function successGet() 
	{
		if (getPool.length == 0) {
			getPool = generatePool(params.retrieveDataPercentFailureRate);
		}
		
		return getPool.shift();
	}
	
	public function successReturn() 
	{
		if (returnPool.length == 0) {
			returnPool = generatePool(params.sendDataPercentageFailureRate);
		}
		
		return returnPool.shift();
	}
	
	
}