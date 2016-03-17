package xpt.mockStudy;

import utest.Assert;
import xpt.mockStudy.MockEntireStudy.Params;
import xpt.mockStudy.MockEntireStudy.SJ;
import xpt.mockStudy.MockEntireStudy.SJevent;
import xpt.mockStudy.MockEntireStudy.TransmissionManager;
import xpt.mockStudy.Scheduler.Plan;

class Test_MockEntireStudy
{

	public function new() {	}
	
	
	
	public function test1() {
		
		var SJs = MockEntireStudy.generateSJs(5, null);
		Assert.isTrue(SJs.length == 5);
		
		MockEntireStudy.randomlyFailSJs(SJs, 20);
		var fail:Int = 0;
		for (sj in SJs) {
			if (sj.finishesStudy == false) fail++;
		}
		
		Assert.isTrue(fail == 1);
		
		var counter:Map<SJevent,Int> = [SJevent.GetStimulus =>0, SJevent.ReturnStimulus =>0];
		function callback(_sj:SJ, event:SJevent, data:Map<String,Dynamic>) {
			counter.set(event, counter.get(event) + 1);
		}
		
		var sj:SJ = new SJ(callback, 0);
		sj.numAssessments = 2;
		sj.requestStimulus();
		
		Assert.equals(counter.get(SJevent.GetStimulus), 1);
		Assert.equals(counter.get(SJevent.ReturnStimulus), 0);
		
		sj.doneRatingPing(null);
		Assert.equals(sj.ratingId, 1);
		Assert.equals(counter.get(SJevent.GetStimulus), 2);
		Assert.equals(counter.get(SJevent.ReturnStimulus), 1);
		
		sj.doneRatingPing(null);
		Assert.equals(sj.ratingId, 2);
		Assert.equals(counter.get(SJevent.ReturnStimulus), 2);
		Assert.equals(counter.get(SJevent.GetStimulus), 2);
		
		Assert.raises(function(){
			sj.doneRatingPing(null);
		});
	}
	
	public function test_populate_scedule1() {
		
		var SJs = MockEntireStudy.generateSJs(1, null);
		
		var params:Params = new Params();
		params.scheduleStartingDuration = 5;
		params.assessments_per_SJ = 5;
		
		var s:Scheduler = MockEntireStudy.populate_scedule(params, SJs);
		
		var plan:Plan;
		var time:Int;
		
		for (rating in 0...params.assessments_per_SJ) {
			time = rating * params.seconds_per_rating + params.seconds_per_rating;
			plan = s.schedule.get(time);
			Assert.equals(1, plan.toRun.length);
		}

		
	}
	
	public function test_populate_scedule2() {
		var sj_count:Int = 2;
		var SJs = MockEntireStudy.generateSJs(sj_count, null);
		
		var params:Params = new Params();
		params.scheduleStartingDuration = 5;
		params.signup_per_minute = 1;
		params.assessments_per_SJ = 5;
		
		var s:Scheduler = MockEntireStudy.populate_scedule(params, SJs);
		
		var plan:Plan;
		var time:Int;
		
		var sj_offset:Int;
		
		var check:Map<Int,Int> = new Map<Int,Int>();
		
		for(sj in 0...sj_count){
			for (rating in 0...params.assessments_per_SJ) {
				sj_offset = Std.int(sj * (60 / params.signup_per_minute));
				time = rating * params.seconds_per_rating + params.seconds_per_rating + sj_offset;
				plan = s.schedule.get(time);
				if (check.exists(time) == false) check.set(time, 0);
				check.set(time, check.get(time) + 1);
			}
		}

		Assert.equals(check.get(15), 1);
		Assert.equals(check.get(30), 1);
		Assert.equals(check.get(45), 1);
		Assert.equals(check.get(60), 1);
		Assert.equals(check.get(75), 2);
		Assert.equals(check.get(90), 1);
		Assert.equals(check.get(105), 1);
		Assert.equals(check.get(120), 1);
		Assert.equals(check.get(135), 1);

		
	}
	
	public function test_run() {
		var sj_count:Int = 2;
		
		var callback_count:Int = 0;
		var last_plan:Plan = null;

		function callback(_sj:SJ, sjEvent:SJevent, data:Map<String,Dynamic>) {
			if(sjEvent == SJevent.ReturnStimulus){
				callback_count++;
				last_plan = _sj.currentPlan;
			}
		}
		
		
		var SJs = MockEntireStudy.generateSJs(sj_count, callback);
		
		var params:Params = new Params();
		params.scheduleStartingDuration = 5;
		params.signup_per_minute = 1;
		params.assessments_per_SJ = 5;
		
		var s:Scheduler = MockEntireStudy.populate_scedule(params, SJs);
		
		MockEntireStudy.run(s, params);

		Assert.isTrue(callback_count == 10);
		Assert.isTrue(last_plan.minute == 135);

		
	}
	
	public function test_run_withRandDropouts() {
		var sj_count:Int = 20;
		
		var callback_count:Int = 0;
		var last_plan:Plan = null;

		function callback(_sj:SJ, sjEvent:SJevent, data:Map<String,Dynamic>) {
			if(sjEvent == SJevent.ReturnStimulus){
				callback_count++;
				last_plan = _sj.currentPlan;
			}
		}		
		
		var params:Params = new Params();
		params.scheduleStartingDuration = 5;
		params.signup_per_minute = 1;
		params.assessments_per_SJ = 5;
		params.percent_SJs_who_finish_study = 10;
		
		var SJs = MockEntireStudy.generateSJs(sj_count, callback);
		MockEntireStudy.randomlyFailSJs(SJs, params.percent_SJs_who_finish_study);
		
		var s:Scheduler = MockEntireStudy.populate_scedule(params, SJs);
		
		var dontFinishStudy:Int = Std.int(sj_count * (params.percent_SJs_who_finish_study) / 100);
		
		MockEntireStudy.run(s, params);
		Assert.isTrue(callback_count == (sj_count - dontFinishStudy) * params.assessments_per_SJ);
	}
	
	public function test_TransmissionManager() {
	
		var params:Params = new Params();
		params.assessments_per_SJ = 5;
		params.numSJs = 5;
		params.sendDataPercentageFailureRate = 0;
		params.retrieveDataPercentFailureRate = 0;
		
		var t:TransmissionManager = new TransmissionManager(params);
		
		for (count in 0...t.returnPool.length) {
			Assert.isTrue(t.returnPool[count] == true && t.getPool[count] == true );
		}
		
		params.assessments_per_SJ = 25;
		params.numSJs = 4;
		params.sendDataPercentageFailureRate = 10;
		params.retrieveDataPercentFailureRate = 20;
		
		t = new TransmissionManager(params);
		
		var returnFails:Int = 0;
		var returnSuccesses:Int = 0;
		var getFails:Int = 0;
		var getSuccesses:Int = 0;
		
		Assert.equals(t.returnPool.length, 100);
		Assert.equals(t.getPool.length, 100);
		
		for (count in 0...t.returnPool.length) {
			if (t.returnPool[count] == true) returnSuccesses++;
			else returnFails++;
			
			if (t.getPool[count] == true) getSuccesses++;
			else getFails++;
		}
		
		Assert.equals(returnFails, 10);
		Assert.equals(returnSuccesses, 90);
		Assert.equals(getFails, 20);
		Assert.equals(getSuccesses, 80);
	}
}

