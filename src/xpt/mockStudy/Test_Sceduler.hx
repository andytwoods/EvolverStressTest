package xpt.mockStudy;
import utest.Assert;
import xpt.mockStudy.Scheduler.Plan;

class Test_Sceduler
{

	public function new() { }

	
	public function test_plan1() {
		
		var s:Scheduler = new Scheduler(10);
		
		var count:Int = 0;
		for (key in s.schedule.keys()) {
			count++;
		}
		
		
		Assert.isTrue(count == 11);
		
		
		var run = Assert.createAsync();
		
		function callback(p:Plan) {
			run();
		}
		
		s.add(15, callback);
		
		
		count = 0;
		for (key in s.schedule.keys()) {
			count++;
		}
	
		Assert.isTrue(count == 16);
		
		var run2 = Assert.createAsync();
		function callback2(p:Plan) {
			run2();
		}
		
		var plan:Plan;
		var count:Int = 0;
		while (true) {
			plan = s.next();
			if (plan == null) break;
			if (plan.minute == 15) {
				plan.inFuture(1, callback2);
			}
			count ++;
			
		}

		Assert.isTrue(count == 17);

		
	}
	
	public function test_plan2() {
		
		var s:Scheduler = new Scheduler(10);
		
		var run = Assert.createAsync();
		var run2 = Assert.createAsync();
		
		function callback2(p:Plan) {
			run2();
		}
		
		function callback(p:Plan) {
			p.inFuture(10, callback2);
			run();
		}
		
		s.add(10, callback);
		
		var plan:Plan;
		var count:Int = 0;
		while (true) {
			plan = s.next();
			if (plan == null) break;	
			count++;
		}

		Assert.isTrue(count == 21);

		
	}
}