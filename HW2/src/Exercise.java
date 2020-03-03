// Kamil Zambrowski
// Matthew Jaros
// I Pledge My Honor The I Have Abided By The Stevens Honor System

import java.util.Map;
import java.util.HashMap;
import java.util.Random;

public class Exercise {
	private ApparatusType at;								//apparatus being used
	private Map<WeightPlateSize, Integer> weight;			//weight on apparatus
	private int duration;									//duration of exercise

	public Exercise(ApparatusType at, Map<WeightPlateSize, Integer> weight, int duration) {
		this.at = at;
		this.weight = weight;
		this.duration = duration;
	}
	
	public ApparatusType getApparatus() {
		return at;
	}
	
	public Map<WeightPlateSize, Integer> getWeight() {
		return weight;
	}
	
	public int getDuration() {
		return duration;
	}
	
	public static Exercise generateRandom() {
		Random r = new Random();
		// between 0-10 plates of each weight and at least 1 weight plate
		int num_small = r.nextInt(11);
		int num_med = r.nextInt(11);
		int num_large = r.nextInt(11);
		if ((num_small == 0) && (num_med == 0) && num_large == 0) {
			num_small = 1;
		}
		Map<WeightPlateSize, Integer> weight_used = new HashMap<WeightPlateSize, Integer>();
		weight_used.put(WeightPlateSize.SMALL_3KG, new Integer(num_small));
		weight_used.put(WeightPlateSize.MEDIUM_5KG, new Integer(num_med));
		weight_used.put(WeightPlateSize.LARGE_10KG, new Integer(num_large));
		ApparatusType exercises[] = ApparatusType.values();
		Exercise random_exercise = new Exercise(exercises[r.nextInt(8)], weight_used, ((r.nextInt(15)+3)*1000));;
		return random_exercise;
	}
}


