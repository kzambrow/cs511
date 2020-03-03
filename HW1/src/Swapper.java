// I Pledge My Honor That I Have Abided By THe Stevens Honor System
// Kamil Zambrowski

public class Swapper implements Runnable {
    private int offset;
    private Interval interval;
    private String content;
    private char[] buffer;

    public Swapper(Interval interval, String content, char[] buffer, int offset) {
        this.offset = offset;
        this.interval = interval;
        this.content = content;
        this.buffer = buffer;
    }

    @Override
    public void run() {
        for(int i = 0; i < (interval.getY() - interval.getX()); i++){
            buffer[i + offset] =  content.charAt(interval.getX() + i);
        }
    }
}