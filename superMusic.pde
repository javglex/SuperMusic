/* Javier Gonzalez
 * A different take on the music visualizer
 * Walk through an adventures created by your musci
 /////////////README///////////////////
 Make sure your soundcard is set as your microphone
*/




import ddf.minim.*;  //import audio library
import ddf.minim.analysis.*;  //includes FFT library

Minim minim;
AudioInput in;
FFT fft;
BeatDetect beat;

PGraphics p_graphics;  
ShapeHearts hearts = new ShapeHearts();
ShapeFloor floor=new ShapeFloor();
ShapeSun sun= new ShapeSun();
ShapeStars star= new ShapeStars();

float time=0;
float vol;  //volume level of audio
float volLeft;
float volRight;
float avgBPS=1;    //average beats per minute
int beatCount=1;
int prevBeatCount=1;
int secondChecked=0;  //the second() the beat was previously averaged on. Avoid averaging on same second
float kickSize, snareSize, hatSize;


void setup(){
  size(700,700,P3D);
  p_graphics = createGraphics(width,height,P3D);
  hearts.InitGraphics(p_graphics);
  floor.InitGraphics(p_graphics);
  sun.InitGraphics(p_graphics);
  star.InitGraphics(p_graphics);
  
  minim = new Minim(this);
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  beat = new BeatDetect();
  fft= new FFT(in.bufferSize(),in.sampleRate());
  textFont(createFont("Helvetica", 16));
}

void draw(){
  averageBPS();

  vol=in.mix.level()+adjVol;  //volume level of audio
  volLeft=in.left.level()+adjVol;
  volRight=in.right.level()+adjVol;


  drawSun();
  drawHearts();
  drawFloor();
  drawStars();
  text(avgBPS,14,14);
  autoVolControl(in.mix.level());
  
  if (time>1000000) 
    time=0;
  time+=.01f;
  delay(2);
}

void drawFloor(){
  floor.setDrawnShape();
  image(floor.getDrawnShape(),floor.getPos().x, floor.getPos().y);
}


void drawHearts(){
  hearts.setDrawnShape();
  image(hearts.getDrawnShape(),hearts.getPos().x,hearts.getPos().y);
}


void drawSun(){
  sun.setDrawnShape();
  image(sun.getDrawnShape(), sun.getPos().x,sun.getPos().y);
}

void drawStars(){
  star.setDrawnShape();
  image(star.getDrawnShape(),star.getPos().x,star.getPos().y);
  
}



void averageBPS(){

  beat.detect(in.mix);
  if ( beat.isOnset() || beat.isKick() || beat.isHat()){
    beatCount++;
  }
  text(beatCount,14,40);
  if ((int)second()%3==0&&secondChecked!=(int)second()){ //every five seconds take average
    secondChecked=second();
    avgBPS=beatCount/3;
    beatCount=0; //reset number of beats
  }
}


float adjVol=0;
void autoVolControl(float vol){    //automatic volume control, caps volume at a certain level (.05-.06 average)
  text("before: " +vol,34,34);
  if (vol+adjVol<.04)
    adjVol=lerp(adjVol,.1,.006);
  else
  if (vol+adjVol>.04)
    adjVol=lerp(adjVol,-.1,.006);
  text("after: " +adjVol, 34,50);
}