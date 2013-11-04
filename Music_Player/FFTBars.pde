import ddf.minim.analysis.*;
import ddf.minim.*;
import java.text.DecimalFormat;

public class FFTBars extends GenericControl{
  // Minim
  protected AudioPlayer player;
  protected FFT fftLog;
  
  // Bar Hats
  protected int[] barHats;
  protected int barHatFallVelo = 1;
  
  // EQ Gain
  protected float eq_gain = 1.0;
  
  // Size Normalization
  int heightNormal = 300;
  
  // Color Scheme
  int color_bg = color(50);
  int color_barStroke = color(0);
  int color_barFill1 = color(0, 0,255);  
  int color_barFill2 = color(20, 120,255);  
  int color_hatStoke = color(255);
  int color_text = color(255);
  
  // Scale Display
  PFont myFont;
  int minBandwith = 32;
  int bandsPerOctave = 6;
  int numFrequencies = ceil(log(22050/minBandwith)/log(2));
  String[] freqValuesString;
  int[]    freqValues;   
  
  // ===== Constructors =====
  
  public FFTBars(AudioPlayer player, int x, int y, int w, int h){
    this.player = player;
    this.setControlPosition(x,y);
    this.setControlSize(w,h);
    myFont = createFont("FFScala", 12);
    makeFreqValues();
    init();
  }
  
  public FFTBars( int x, int y, int w, int h){
    this.player = player;
    this.setControlPosition(x,y);
    this.setControlSize(w,h);
    myFont = createFont("FFScala", 12);
    makeFreqValues();
  }
  
  // ===== Methods =====

  public void init(){
    fftLog = new FFT(player.bufferSize(), player.sampleRate());
    fftLog.window(FFT.HAMMING);
    // calculate averages based on a miminum octave width of 22 Hz
    // split each octave into ````three bands
    // this should result in 30 averages
    fftLog.logAverages(minBandwith, bandsPerOctave);
    
    //Init the barHats
    barHats = new int[fftLog.avgSize()];
    for(int i = 0; i < barHats.length; i++){
      barHats[i] = (int)mySize.y; 
    } 
  }
  
  private void makeFreqValues(){
    //TODO: Fix number format later
    NumberFormat formatter = new DecimalFormat("00");
    freqValuesString = new String[numFrequencies];
    freqValues = new int[numFrequencies];
    for(int i = 0; i < numFrequencies; i++){
      freqValues[i] = (int)(32 * pow(2,i));
      String f = formatter.format(freqValues[i]);
      freqValuesString[i] = "" + f + "Hz";
    }
  }

  public void initWithPlayer(AudioPlayer player){
    this.player = player;
    init();
  }  
 
  
  public void display(){
    
    pushMatrix();
    translate(myPos.x, myPos.y);
    rectMode(CORNERS);
    //Draw Controller Background
    fill(color_bg);
    noStroke();
    rect(0,0,mySize.x,mySize.y);
    
    // Dont display if player is null or not playing
    if(player == null ||!player.isPlaying()){
      popMatrix(); 
      return;
    }
    
    int barHeight = -1;
  
    // draw the logarithmic averages
    fftLog.forward(player.mix);
    int w = int(mySize.x/fftLog.avgSize());
    for(int i = 0; i < fftLog.avgSize(); i++){
      
      stroke(color_barStroke);
      if((i / bandsPerOctave)%2 == 1){
        fill(color_barFill1);
      }else{
        fill(color_barFill2);
      }

      barHeight = (int)constrain((mySize.y 
                  - eq_gain * 50 * Music_Player.log10(fftLog.getBand(i))),
                  0, mySize.y);
      rect(i*w, mySize.y, i*w + w, barHeight);
      
      // update barHat
      if(barHeight < barHats[i]){
        barHats[i] = barHeight;
      }else{
        barHats[i] = (int)constrain(barHats[i] + barHatFallVelo, 0,  mySize.y);
      }
      
      // draw barHat at the top of the bar
      stroke(color_hatStoke);
      rect(i*w, barHats[i], i*w + w, barHats[i]);
      
    }//end for i
    
    // draw the frequency values
    w = (int)mySize.x/numFrequencies;
    rectMode(CENTER);
    fill(color_text);
    textAlign(CENTER);
    for(int i = 0; i < numFrequencies; i ++){
      text(freqValuesString[i], w/2 + w*i, mySize.y - 10);
    }
    textAlign(LEFT);
    
    // debug
    //println("fftLog.avgSize: " + fftLog.avgSize());
    //println("eq_gain: " + eq_gain);
    
    popMatrix();  
   
  }// end display
  
  
  // ===== Accessors =====
  
  public float getEqGain(){
    return eq_gain;
  }
  
  public void setEqGain(float gain){
    eq_gain = constrain(gain, 0.1,2);
  }
  
  public void incrEqGain(){
    eq_gain = constrain(eq_gain +0.05, 0.1,2);
  }
  
  public void decrEqGain(){
    eq_gain = constrain(eq_gain -0.05, 0.1,2);
  }
  
  public void nullPlayer(){
    player = null;
  }
  
}
