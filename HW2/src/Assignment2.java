// Kamil Zambrowski
// Matthew Jaros
// I Pledge My Honor That I Have Abided By The Stevens Honor System

/** start the simulation */
public class Assignment2 {
	public static void main(String[] args) {
		Thread thread = new Thread(new Gym());
		thread.start();
		try {
			thread.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}