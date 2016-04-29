import oscP5.*;
//import netP5.*;

OscP5 oscP5;
PFont font;
String oscInput = "nothing yet";

void setup()
{
  oscP5 = new OscP5(this,12000);
  font = createFont("Courier New.ttf", 24);
  textFont(font);
  textAlign(CENTER, CENTER);
  color(255);
}


void draw()
{
  background(0);
  text(oscInput, width/2, height/2);  
}

void oscEvent(OscMessage msg) {
  /* print the address pattern and the typetag of the received OscMessage */
  if(msg.checkTypetag("iffff")) {
    print("### received an osc message : ");
    print(msg.addrPattern());
    print(" " + msg.get(0).intValue());
    print(" " + msg.get(1).floatValue());
    print(" " + msg.get(2).floatValue());
    print(" " + msg.get(3).floatValue());
    println(" " + msg.get(4).floatValue());
  }
}