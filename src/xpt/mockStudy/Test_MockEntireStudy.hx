package xpt.mockStudy;

import utest.Assert;
import xpt.mockStudy.MockEntireStudy.Params;
import xpt.mockStudy.MockEntireStudy.SJ;
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
		var last_plan:Plan;

		function callback(_sj:SJ) {
			callback_count++;
			last_plan = _sj.currentPlan;
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
		var last_plan:Plan;

		function callback(_sj:SJ) {
			callback_count++;
			last_plan = _sj.currentPlan;
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
		trace(last_plan.minute);

		
	}
}

