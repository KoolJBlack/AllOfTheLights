import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioPlayer player;
FFT fftLog;
// Bar Hats
int[] barHats;
int barHat_fallVelo = 1;

float eq_gain = 1.0;

void setup()
{
  size(512, 300, P3D);

  minim = new Minim(this);
  player = minim.loadFile("around.mp3", 2048);
  // loop the file
  player.loop();
  
  fftLog = new FFT(player.bufferSize(), player.sampleRate());
  fftLog.window(FFT.HAMMING);
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages(32, 3);
  rectMode(CORNERS);
  
  //Init the barHats
  barHats = new int[fftLog.avgSize()];
  for(int i = 0; i < barHats.length; i++){
    barHats[i] = height; 
  }
  
  // set frametrate
  frameRate(60);
}

void draw()
{
  background(50);
  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  

  int barHeight = -1;
  
  // draw the logarithmic averages
  fftLog.forward(player.mix);
  int w = int(width/fftLog.avgSize());
  for(int i = 0; i < fftLog.avgSize(); i++)
  {
    // draw a rectangle for each average, multiply the value by 5 so we can see it better
    //rect(i*w, height, i*w + w, height - eq_gain* 5*fftLog.getAvg(i));
    // log scale looks right
    stroke(0);
    fill(50, 70,255);
    barHeight = height - (int)Math.round(eq_gain * 2* 20*Math.log10(100*fftLog.getBand(i)));
    rect(i*w, height, i*w + w, barHeight);
    
    
    // update barHat
    if(barHeight < barHats[i]){
      barHats[i] = barHeight;
    }else{
      barHats[i] = barHats[i] + barHat_fallVelo;
    }
    // draw barHat at the top of the bar
    stroke(255);
    rect(i*w, barHats[i], i*w + w, barHats[i]);
  }
  //println("fftLog.avgSize: " + fftLog.avgSize());
  println("eq_gain: " + eq_gain);
}

void stop()
{
  // always close Minim audio classes when you are done with them
  player.close();
  // always stop Minim before exiting
  minim.stop();
  
  super.stop();
}

public void keyPressed(){
  if(keyCode == UP){
    eq_gain = constrain(eq_gain + 0.1, 0.1, 2);
  }else  if(keyCode == DOWN){
    eq_gain =  constrain(eq_gain - 0.1, 0.1,2 );
  }else if(key == 's'){
    player.pause();
  }else if(key == 'p'){
    player.play();
  }
  
}

