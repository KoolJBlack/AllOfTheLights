import controlP5.*;
import ddf.minim.*;
import java.util.concurrent.TimeUnit;

// Main Window Dimensions
int DEFAULT_WIDTH = 1188;
int DEFAULT_HEIGHT = 660;

// Minim Classes
AudioPlayer player;
AudioMetaData meta;
Minim minim;

// Control CP5 Classes
ControlP5 cp5;

// Colro Scheme
int color_text = color(242, 238, 234);
int color_bg = color(35, 31, 32);
int color_cp5_fg = color(241, 94, 0);
int color_cp5_bg = color(241, 156, 40);
int color_cp5_active = color(161, 46, 51);
int color_cp5_textfield = color(35, 31, 32);

// Timing 
long lastUpdateTimeMillis;
String mediaDurationTime = "00:00:00";

// FFT 
PVector FFTWindowPosition = new PVector(30,220);
PVector FFTWindowSize = new PVector(1020, DEFAULT_HEIGHT - FFTWindowPosition.y - 30);

// FFTBars
FFTBars fftBars;
PVector fftBarsPos = new PVector(30,220);
PVector fftBarsSize = new PVector(1020,200);

public void setup(){
  size(DEFAULT_WIDTH , DEFAULT_HEIGHT);
  noStroke();
    
  // Init Gui  
  cp5 = new ControlP5(this);
  this.initGui(cp5);
  
  // Init Minim
  minim = new Minim(this);
  
  // Init FFTBars
  fftBars = new FFTBars((int)fftBarsPos.x,(int)fftBarsPos.y,(int)fftBarsSize.x,(int)fftBarsSize.y);
  
  // Update timeer
  lastUpdateTimeMillis = System.currentTimeMillis();
  
  // Set FrameRate
  frameRate(60);
}


public void draw(){
  background(0);
  
  // Compute elapsed time
  long elapsedTimeMillis = System.currentTimeMillis()-lastUpdateTimeMillis;
  if( elapsedTimeMillis > 1000){ //Update after 1 second (1000 millis) has passed
    //println(elapsedTimeMillis);
    if(player != null){ 
      //Update the position bar and time duration label
      cp5.getController("playPosition").changeValue(float(player.position())/ meta.length() * 100);
      updateTimeDurationLabel(player.position());
    } 
    //Reupdate the time
    lastUpdateTimeMillis = System.currentTimeMillis();
  }
  
  // Draw all controllers
  drawAllControllers();
  
  //Debug Player
  if(player != null){
    //println(player.position());
    //player.printControls();
    /*
        Available controls are:
        Master Gain, which has a range of 13.9794 to -80.0 and doesn't support shifting.    
        Mute
        Pan, which has a range of 1.0 to -1.0 and doesn't support shifting.
        Sample Rate
     */
  }// end player != null
 
}//end draw


public void drawAllControllers(){ 
  // Draw the fft background
  /*
  pushMatrix();
  translate(FFTWindowPosition.x, FFTWindowPosition.y);
  noStroke();
  fill(color(255,50));
  rectMode(CORNER);
  rect(0,0,FFTWindowSize.x, FFTWindowSize.y);
  popMatrix();
  */

  
  // Draw FFTBars Controller
  fftBars.display();
}//end drawAllContorllers


public void mousePressed(){

}


public void keyPressed(){
  if(keyCode == UP){           // Increase EQ Gain
    fftBars.incrEqGain();
  }else  if(keyCode == DOWN){  // Decrease EQ Gain
    fftBars.decrEqGain();
  }else if(key == 's'){        // Start Playback
    player.pause();
  }else if(key == 'p'){        // Stop Playback 
    player.play();
  }else if(keyCode == RIGHT){
    fastFoward();
  }else if(keyCode == LEFT){
    rewind();
  }
}


public void stop(){
  println("Stop Was Called!!!");
  // always close Minim audio classes when you are done with them
  if(player != null)
    player.close();
  minim.stop();
  
  super.stop();
}
//=========================================================
//*********************************************************
//                    Control P5 Functions
//*********************************************************
//=========================================================

public void initGui(ControlP5 cp5){
  
  
  // ================= Media Info Group ==============
  Group mediaInfoGroup =  cp5.addGroup("mediaInfo")
                        .setPosition(30,30)
                        .setWidth(width/2-35)
                        .activateEvent(true)
                        .setBackgroundColor(color(255,50))
                        .setBackgroundHeight(170)
                        .setLabel("Media Information")
                        .disableCollapse();
                        ;
                        
  // Meta Data TextArea 
  Textarea metaDataTextarea = cp5.addTextarea("metaData")
                .setPosition(20,20)
                .setSize(width/2-70,130)
                .setFont(createFont("arial",12))
                .setLineHeight(14)
                .setColor(color(228))
                .setColorBackground(color(255,100))
                .setColorForeground(color(255,100))
                .setGroup(mediaInfoGroup)
                ;
   
  // ============== Player Info Group =============
  Group playerInfoGroup =  cp5.addGroup("playerInfo")
                          .setPosition(width/2 + 5,130)
                          .setWidth(width - (int)cp5.getGroup("playerInfo").getPosition().x - 30)
                          .activateEvent(true)
                          .setBackgroundColor(color(255,50))
                          .setBackgroundHeight(70)
                          .setLabel("Player Information")
                          .disableCollapse();
                          ;
  // RW Button
  cp5.addBang("rewind")
     //.setValue(0)
     .setPosition(20,20)
     .setSize(60,20)
     .setGroup(playerInfoGroup)
     ;    
  // FF Button
  cp5.addBang("fastFoward")
     //.setValue(0)
     .setPosition(playerInfoGroup.getWidth() - 80,20)
     .setSize(60,20)
     .setGroup(playerInfoGroup)
     ;
  // Play Positoin Slider
  cp5.addSlider("playPosition")
     .setPosition(100,20)
     .setSize(width/2-234,20)
     .setRange(0,100)
     .setValue(100)
     .setGroup(playerInfoGroup)
     .setSliderMode(Slider.FLEXIBLE)
     .setLabel("Play Position")
     //.setLabelVisible(false);
     .setTriggerEvent(Slider.RELEASE)
     ;
  // hide the Label for controller 'playPosition'
  cp5.getController("playPosition").getValueLabel().hide();
  
     
 cp5.addTextlabel("timeDuration")
     .setText("00:00:00 / "+ mediaDurationTime )
     .setPosition(95,43)
     .setColorValue(0xffffffff)
     //.setFont(createFont("Georgia",20))
     .setGroup(playerInfoGroup)
     ;
  // reposition the Label for controller 'playPosition'
  cp5.getController("playPosition").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("playPosition").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
 
 
  // =============== Controls Group ===============
  Group controlsGroup =  cp5.addGroup("controls")
                            .setPosition(width/2 +5,30)
                            .setWidth(width - (int)cp5.getGroup("controls").getPosition().x - 30)
                            .activateEvent(true)
                            .setBackgroundColor(color(255,50))
                            .setBackgroundHeight(80)
                            .setLabel("Controls")
                            .disableCollapse();
                            ;
  int ctl_button_width = 80;
  int ctl_button_height = 20;
  int ctl_button_spacing = 100;
  // Play Button
  cp5.addButton("playMedia")
     //.setValue(0)
     .setPosition(20,20)
     .setSize(ctl_button_width,ctl_button_height)
     .setGroup(controlsGroup)
     .setCaptionLabel("Play");
     ;
  // Pause Button
  cp5.addButton("pauseMedia")
     //.setValue(0)
     .setPosition(20 + ctl_button_spacing*1,20)
     .setSize(ctl_button_width,ctl_button_height)
     .setGroup(controlsGroup)
     .setCaptionLabel("Pause");
     ;
  // Stop Button
  cp5.addButton("stopMedia")
     //.setValue(0)
     .setPosition(20 + ctl_button_spacing *2,20)
     .setSize(ctl_button_width,ctl_button_height)
     .setGroup(controlsGroup)
     .setCaptionLabel("Stop");
     ;
  // Open Button
  cp5.addButton("openMedia")
     //.setValue(0)
     .setPosition(20 + ctl_button_spacing * 3,20)
     .setSize(ctl_button_width,ctl_button_height)
     .setGroup(controlsGroup)
     .setCaptionLabel("Open MP3");
     ;
  
  // ================= Fourier Group =================
  Group fourierGroup =  cp5.addGroup("foueir")
                        .setPosition(30,220)
                        .setWidth(1020)
                        .activateEvent(true)
                        .setBackgroundColor(color(255,50))
                        //.setBackgroundHeight(height - (int)cp5.getGroup("foueir").getPosition().y - 30)
                        .setBackgroundHeight(0)
                        .setLabel("Fourier")
                        .disableCollapse();
                        ;
                        
  // ============== Media Gain  Group =============
  Group mediaGainGroup =  cp5.addGroup("mediaGain")
                          .setPosition(1060,220)
                          .setWidth(width - (int)cp5.getGroup("mediaGain").getPosition().x - 30)
                          .activateEvent(true)
                          .setBackgroundColor(color(255,50))
                          .setBackgroundHeight(height - (int)cp5.getGroup("mediaGain").getPosition().y - 30)
                          .setLabel("Media Gain")
                          .disableCollapse();
                          ;
  // Volume Slider
  cp5.addSlider("volume")
     .setPosition(20,20)
     .setSize(20,100)
     .setRange(0,100)
     .setValue(90)
     .setGroup(mediaGainGroup)
     //.setTriggerEvent(Slider.RELEASE)
     ;
  // reposition the Label for controller 'volume'
  cp5.getController("volume").getValueLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
}// end public  initGui


public void updateMetaDataTextarea(AudioMetaData meta){
  println("Meta: " + meta.toString());
  String metaText = "Title: " + meta.title() + "\n" +
                    //"File Name: " + meta.fileName() + "\n" +
                    "Length: " + mediaDurationTime + "\n" +
                    "Author: " + meta.author() + "\n" +
                    "Album: " + meta.album() + "\n" +
                    "Date: " + meta.date() + "\n" +
                    "Comment: " + meta.comment() + "\n" +
                    //"Track: " + meta.track() + "\n" +
                    "Genre: " + meta.genre() + "\n" //+
                    //"Copyright: " + meta.copyright() + "\n" +
                    //"Disc: " + meta.disc() + "\n" +
                    //"Composer: " + meta.composer() + "\n" +
                    //"Orchestra: " + meta.orchestra() + "\n" +
                    //"Publisher: " + meta.publisher() + "\n" +
                    //"Encoded: " + meta.encoded() + "\n" 
                    ;
   Textarea metaDataTextarea = (Textarea)cp5.getGroup("metaData");
   metaDataTextarea.setText(metaText);

}

public void updateTimeDurationLabel(int mill){
  ((Textlabel)cp5.getController("timeDuration")).setText(millisToString(mill) + " / " + mediaDurationTime);
}

//=========================================================
//*********************************************************
//                    Control P5 CallBacks
//*********************************************************
//=========================================================


// =================== Palyer InfoCallbacks =================
void playPosition(float value) {
 //println("PlayerPosition: " + value);
  if(player != null){
    float cueValue = player.length() * value / 100;
    //println("CueValue: " + cueValue);
    player.cue(int(cueValue));
  }
}

void fastFoward(){
  println("Fast Forward Was Pressed");
  if(player != null){
    player.skip(5000); //Skip forward 5 seconds
  }
}

void rewind(){
 println("Rewind Was Pressed");
  if(player != null){
    player.skip(-10000); //Skip back 10 seconds
  }
}


// =================== Controls Callbacks =================

public void playMedia(){
    println("PlayMedia Was Called!!!");
    if(player != null){
      player.play();
    }
}

public void openMedia(){
  println("Open Was Called!!!");
  String loadPath = "";
  selectInput("Select a file to process:", loadPath);  // Opens file chooser
  if (loadPath == null) {
    // If a file was not selected
    println("No file was selected...");
  } else {
    // If a file was selected, print path to file
    println("LoadPath: " + loadPath);
    // Close previous player file (if any)
    if(player != null){player.close();}
    // Load new file, create new player, create new meta data
    player = minim.loadFile(loadPath, 1024);//2048);
    meta = player.getMetaData();
    
    // Update the mediaDurationTime
    mediaDurationTime = millisToString(player.length() );
    // Update the metaDataTextArea
    updateMetaDataTextarea(meta);
    
    // Update FFTBars Controller
    fftBars.initWithPlayer(player);

  }
}//end public  open

public void pauseMedia(){
    println("PauseMedia Was Called!!!");
    if(player != null){
      player.pause();
    }
}

public void stopMedia(){
    println("StopMedia Was Called!!!");
    if(player != null){
      fftBars.nullPlayer();
      player.close();
      player = null;
    }
}


// =================== Media Gaub Callbacks =================

void volume(float value) {
  //println("Volume: " + value);
  if(player != null){
    float gainValue = 20 * log10(value / ((Slider)cp5.getController("volume")).getMax() );
    //println("GainValue: " + gainValue);
    player.setGain(gainValue);
  }
}


//=========================================================
//*********************************************************
//                   Random Helper Functions
//*********************************************************
//=========================================================


// Calculates the base-10 logarithm of a number
public static float log10 (float x) {
  return (log(x) / log(10));
}

// Turns time in millis into stirng of form 00:00:00
public static String millisToString(int mill){
  return String.format("%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(mill) ,
  (TimeUnit.MILLISECONDS.toMinutes(mill) - TimeUnit.HOURS.toMinutes(  TimeUnit.MILLISECONDS.toHours(mill))   ), 
  (TimeUnit.MILLISECONDS.toSeconds(mill) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(mill)) )
  ); 
  /*
  return "" + TimeUnit.MILLISECONDS.toHours(mill) +
  ":" + (TimeUnit.MILLISECONDS.toMinutes(mill) - TimeUnit.HOURS.toMinutes(  TimeUnit.MILLISECONDS.toHours(mill))   ) +
  ":" + (TimeUnit.MILLISECONDS.toSeconds(mill) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(mill)) )
  ; */
}



