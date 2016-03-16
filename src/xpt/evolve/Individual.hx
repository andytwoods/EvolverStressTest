package xpt.evolve;
import xpt.evolve.State;


/**
 * ...
 * @author Andy Woods
 */

@:allow(xpt.evolve.Test_HEvalulationManager)
class Individual{

	var item:Dynamic;
	public var id:Int;
	var callback:Individual->Void;
	var to_be_rated: Array<Rating>;
    var has_been_rated: Array<Rating>;
    var in_limbo: Array<Rating>;
    var data:Dynamic;
    var params:Map<String,Int>;
    public var state:Int;
	
	
    public function new(item:Dynamic, individual_id:Int, callback:Individual->Void, params:Map<String,Int>){
        this.item = item;
        this.id = individual_id;
        this.callback = callback;
        this.to_be_rated = new Array<Rating>();
        this.has_been_rated = new Array<Rating>();
        this.in_limbo = new Array<Rating>();
        this.params = params;
        this.state = State.POOL;


        this.new_rating(this.params.get('num_evals'));
	}

    public function rating_request(rater:String):Map<String,String>{

        for(potential in this.has_been_rated){
            if (potential.rater == rater)   return null;
		}

        for(potential in this.in_limbo){
            if (potential.rater == rater) return null;
		}

        var rating = this.to_be_rated.shift();
        rating.start(rater, this.fail_callback_rating);
        this.in_limbo.unshift(rating);

        if (this.to_be_rated.length == 0){
            this.state = State.POTENTIALLY_TESTED;
		}

        return  ['id' => Std.string(this.id), 'rating_num' => Std.string(rating.rating_num), 'data' => 'this.item' ];
	}	

    function new_rating(how_many) {
		var rating_num:Int;
        for (i in 0...how_many){
            rating_num = this.to_be_rated.length;
            this.to_be_rated.push(new Rating(rating_num, this.params));
		}
	}

    function fail_callback_rating(){
        this.state = State.POOL;
        this.new_rating(1);
	}


    public function rated(score:Int, rating_num:Int){

        for (rating in this.in_limbo){

            if (rating.rating_num == rating_num){
                rating.rated(score);
                this.in_limbo.remove(rating);
                this.has_been_rated.push(rating);

                if (this.has_been_rated.length >= this.params.get('num_evals')){
                    this.state = State.FINISHED;
                    this.data = this.compile_data();
                    this.callback(this); //tell parent that data is collected
				}

                return;
			}
		}

        throw 'When returning a rating, the rating number was not found. Devel error.';
	}

    public function compile_data(){
        var dat = new Array<Int>();
        for(rating in this.has_been_rated){
            dat.push(rating.rating);
		}
        return dat;
	}
}
