// Kamil Zambrowski
// Matthew Jaros
// I Pledge My Honor The I Have Abided By The Stevens Honor System

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Client {
	
	private int id;
	private List<Exercise> routine;
	
	public Client(int id) {
		this.id = id;
		routine = new ArrayList<Exercise>();
	}
	
	public int getId() {
		return id;
	}
	
	public List<Exercise> getRoutine() {
		return routine;
	}
	
	public void addExercise(Exercise e) {
		this.routine.add(e);
	}
	
	public static Client generateRandom(int id) {
		Client temp = new Client(id);
		Random r = new Random();
		//between 15 to 20 exercises
		int exerciseCount = r.nextInt(6) + 15;
		for (int i = 0; i < exerciseCount; i++) {
			temp.addExercise(Exercise.generateRandom());
		}
		return temp;
	}
}
