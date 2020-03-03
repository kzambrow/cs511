import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class BarrierExample {
	
	public static class Barrier {
		private final Lock lock = new ReentrantLock();
		private final Condition door1 = lock.newCondition(); 
		private final Condition door2 = lock.newCondition(); 
		private boolean d1 = false; // door1 is open 
		private boolean d2 = true; // door2 is closed
		private int c=0;
		private final int n=3;
		void synch() {
			lock.lock();
			try {
				while (d1) { door1.await(); }
				c++;
				if (c==n) {
					d2=false;d1=true;door2.signalAll(); 
				}
				while (d2) { door2.await(); }
				c--;
				if (c==0) {
					d1=false; d2=true; door1.signalAll(); 
				}
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			lock.unlock();
		}
		
		public static void main(String[] args) {
			Barrier b1 = new Barrier();
			Barrier b2 = new Barrier();
			Thread t1 = new Thread(new P("a","1",b1,b2));
			Thread t2 = new Thread(new P("b","2",b1,b2));
			Thread t3 = new Thread(new P("c","3",b1,b2));
			
			t1.start();
			t2.start();
			t3.start();
			try {
				t1.join();
				t2.join();
				t3.join();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			
		}
	}
	
	public static class P implements Runnable {
		private String pre,post;
		Barrier barrier1,barrier2;
		
		P(String pre, String post, Barrier b1, Barrier b2) {
			this.pre=pre;
			this.post=post;
			this.barrier1=b1;
			this.barrier2=b2;
		}
		
		public void run() {
			for (int i=0;i<100;i++) {
				System.out.println(pre);
				barrier1.synch();
				System.out.println(post);
				barrier2.synch();

			}
		}
		
	}

}
