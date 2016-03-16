package xpt.evolve;
import flash.events.TimerEvent;
import xpt.evolve.Individual;
import xpt.evolve.State;
import xpt.evolve.Test_HEvalulationManager;




@:allow(xpt.evolve.Test_HEvalulationManager)
class HEvaluationManager
{
	var params:Map<String, Int>;
	var callback:Array<Individual>->Void;
	var id_counter:Int;
	var pool:Array<Individual>;
	var potentially_tested_pool:Array<Individual>;
	var tested_pool:Array<Individual>;

	public function new(callback:Array<Individual>->Void, params:Map<String,Int>) {
		_add_defaults(params);
        this.params = params;
        this.callback = callback;
        this.id_counter = 0;

        this.pool = new Array<Individual>();
        this.potentially_tested_pool = new Array<Individual>();
        this.tested_pool = new Array<Individual>();
	}
  
    static function _add_defaults(params:Map<String,Int>){

        function check_add(what:String, defaultVal:Int){
            if (params.exists(what) == false) {
				params[what] = defaultVal;
			}
		}

        check_add('minimum_finished', 5);
        check_add('num_evals', 5);
        check_add('timeout', 60);
	}

	public function add(item:Dynamic){
        var individual = new Individual(item, this.id_counter, this._callback_individual, this.params);
        this.pool.push(individual);
        this.id_counter += 1;
	}

    public function add_many(items:Array<Dynamic>){
        for(item in items){
            this.add(item);
		}
	}

    function _callback_individual(individual:Individual){
        if (individual.state == State.FINISHED){
            this.potentially_tested_pool.remove(individual);
            this.tested_pool.push(individual);

            if (this.tested_pool.length >= this.params.get('minimum_finished')){
                var test_these:Array<Individual> = new Array<Individual>();
                while (this.tested_pool.length > 0)  test_these.push(this.tested_pool.pop());
                this.callback(test_these);
			}
		}

        else if (individual.state == State.POOL){
            this.potentially_tested_pool.remove(individual);
            this.pool.push(individual);
		}
	}


    public function get_item(rater:String):Map<String,String>{

        if (this.pool.length == 0)  return null;
		
		var info:Map<String,String> = null;
		var item:Individual = null;
        for (item in this.pool){
            info = item.rating_request(rater);
            if (info != null) {
				
				if (item.state == State.POTENTIALLY_TESTED){
					this.pool.remove(item);
					this.potentially_tested_pool.push(item);
				}

				return info;
				
				break;
			}
		}

        return null;
	}

    public function return_item( rating:Int, rating_num:Int, rating_id:Int){
        for (given_pool in [this.pool, this.potentially_tested_pool]){
            for (item in given_pool){
                if (item.id == rating_id){
                    item.rated(rating, rating_num);
                    return;
				}
			}
		}

        throw('the item was not found in the pool. Devel error.');
	}
}