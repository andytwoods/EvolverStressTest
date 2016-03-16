package xpt.evolve;

import utest.Assert;
import xpt.evolve.Individual;
import xpt.evolve.Rating;
import xpt.evolve.Test_HEvalulationManager.TestData;

class Test_HEvalulationManager
{

	public function new() 
	{
	}
	
	
	public function test_rating(){
        var params:Map<String,Int> = [ 'time_out'=> 1 ];
        var r = new Rating(1, params);
        Assert.equals(r.rating_num, 1 );
		
		var done = Assert.createAsync(5);
		
        function _callback() {
			//fails as rating not given (ever!)
			done();
		}
		
		r.start('rater', _callback);
	}



    public function test_rating_givenResponseWithinTime(){
        var params:Map<String,Int> = [ 'time_out'=> 5 ];
        var r = new Rating(2, params);
		

		function _callback() {
			//should not be called
			Assert.isFalse(true);
		}
		
        r.start('rater2', _callback);
		

        Assert.isTrue(r.rater == 'rater2');
        Assert.isTrue(r.rating_num == 2);
      
        r.rated(2);
        Assert.isTrue(r.rating == 2);
	}
		

    public function test_1(){


        var default_num_evaluations = 5;

		function _callback(ind:Individual){
			Assert.isTrue(true);
		}
		
        var params:Map<String,Int> = ['num_evals'=> default_num_evaluations, 'time_out'=> 5];
        var ind = new Individual('my_item', 123, _callback, params);

        Assert.equals(ind.to_be_rated.length, default_num_evaluations);
        var request = ind.rating_request('rater');

        Assert.isTrue(ind.to_be_rated.length == 4);
        Assert.isTrue(request.get('id') == '123');
        Assert.isTrue(request.get('rating_num') == '0');
        Assert.isTrue(request.get('data') != '');
        Assert.isTrue(ind.in_limbo.length == 1);

        ind.rated(123, 0);
        Assert.isTrue(ind.has_been_rated.length == 1);

        request = ind.rating_request('rater2');
        Assert.isTrue(request.get('rating_num') == '1');
        ind.rated(123, 1);

        Assert.isTrue(ind.has_been_rated.length == 2);
	}
	


    public function test_failed_assessment(){
        var params:Map<String,Int> = ['time_out'=> 5, 'num_evals' => 5];
		
		
		function callback(ind: Individual){
			Assert.isTrue(true);
		}
		
        var ind = new Individual('my_item', 123, callback, params);

        Assert.equals(ind.to_be_rated.length, 5);
        var rating_request = ind.rating_request('rater');

        var failed_rating = ind.in_limbo[0];
        Assert.equals(ind.to_be_rated.length, 4);
        failed_rating.do_callback(null);
        Assert.equals(ind.to_be_rated.length, 5);

        //testing unique raters only, are allowed
        rating_request = ind.rating_request('rater');
        Assert.equals(rating_request, null);

        rating_request = ind.rating_request('rater2');
        Assert.notEquals(rating_request, null);

        //testing unique raters only, are allowed
        rating_request = ind.rating_request('rater2');
        Assert.equals(rating_request, null);
	}



    public function test_2(){

        var eval:HEvaluationManager = null;
        function callback(_items:Array<Individual>){

            Assert.equals(_items.length, 3);
            Assert.equals(eval.pool.length, 0);

            //there is 1 item left over in potentially_tested_pool as this function != async - code still running
            Assert.equals(eval.potentially_tested_pool.length, 1);
		}


        var params:Map<String,Int> = ['minimum_finished' => 3, "num_evals" => 5, 'time_out'=> 5];
        eval = new HEvaluationManager(callback, params);

        var items_to_evaluate = 4;
        var items = new Array<Map<String,Int>>();
		var item:Map<String,Int>;
        for(i in 0...items_to_evaluate){
            item = [ 'id'=> i ];
            items.push(item);
		}
			
        eval.add_many(items);

        Assert.equals(eval.pool.length, items_to_evaluate);

        var counter:Int = 0;
        var checkedout = eval.get_item('rater' + Std.string(counter));

        Assert.equals(checkedout.get('id'), 0);
        Assert.equals(checkedout.get('rating_num'), 0);

        var checkedouts = new Array<Map<String,String>>();

        //this gets all possible ratings to undertake
        while (checkedout != null) {

            counter += 1;
            checkedouts.push(checkedout);
            checkedout = eval.get_item('rater' + Std.string(counter));
		}

        //is 20
        Assert.equals(checkedouts.length, items_to_evaluate * params.get('num_evals'));

        Assert.equals(eval.tested_pool.length, 0);

        var dict = new Map<Int,Int>();
        for(i in 0 ...items_to_evaluate){
            dict[i] = 0;
		}
		
		for (checkedout in checkedouts) {
			var id:String = checkedout.get('id');
			var intId:Int = Std.parseInt(id);
            dict.set(intId, dict.get(intId) + 1);
		}
		
        for(key in dict.keys()){
            Assert.equals(dict.get(key), params.get('num_evals'));
		}

		
        for (checkedout in checkedouts){
            var rating_num = checkedout.get('rating_num');
            var _id = checkedout.get('id');
            eval.return_item(123, Std.parseInt(rating_num), Std.parseInt(_id));
/*            Assert.raises(
                //when tried to return a second time, should raise an error
					eval.return_item(123, rating_num, _id)
				);*/
		}


        //after everything done, should be 1 item remaining in finished_pool
        Assert.equals(eval.tested_pool.length, 1);
        var left_over = eval.tested_pool[0];
        Assert.equals(left_over.id, 3);
        Assert.equals(left_over.in_limbo.length, 0);
        Assert.equals(left_over.has_been_rated.length, params.get('num_evals'));

  
	}




    public function test1(){

        var items_to_evaluate:Int = 50;
        var minimum_finished:Int = items_to_evaluate + 1;  // we dont want this to ever occur
        var num_eval:Int = 5;

        var eval = new HEvaluationManager(null, ['minimum_finished' => minimum_finished, 'num_evals' => num_eval,  'time_out' => 5]);

        

        //generate items and for each random data
        var items = new Array < TestData >();
		
        for(i in 0...items_to_evaluate){
 
            items.push(new TestData(i,num_eval) ) ;
		}

        eval.add_many(items);

        var checkedouts = new Array<Map<String,String>>();
        var counter = 0;
        var checkedout = eval.get_item('rater' + Std.string(counter));

        //this gets all possible ratings to undertake
        while(checkedout != null){
            counter += 1;
            checkedouts.push(checkedout);
            checkedout = eval.get_item('rater' + Std.string(counter));
		}

        Assert.equals(checkedouts.length, items_to_evaluate * num_eval);

        for(i in 0...items.length){
            var item:TestData = items[i];
            for(eval_num in 0...num_eval){
                checkedout = checkedouts.pop();
                eval.return_item(item.test_data[eval_num], Std.parseInt(checkedout.get('rating_num')), Std.parseInt(checkedout.get('id')));
			}
		}

        Assert.equals(eval.pool.length, 0);
        Assert.equals(eval.potentially_tested_pool.length, 0);

        var results = eval.tested_pool;

        //test to see that data tallies
        for(i in 0...items.length){
            var item__data = items[i].test_data;
            var derived_item__data = results[i].data;

            for (i_rating in 0...num_eval){
                Assert.equals(item__data[i_rating], derived_item__data[i_rating]);
			}
		}
	}	
}

class TestData {
	public var id:Int;
	public var test_data:Array<Int>;
	
	public function new(id:Int, num_eval:Int) {
		this.id = id;
		this.test_data = generate(num_eval);
	}
	
	function generate(num_eval:Int):Array<Int>{
            var mock:Array<Int> = new Array<Int>();
            for(i in 0...num_eval){
                mock.push(Std.int(Math.random()*100));
			}
			return mock;
		}
	
}