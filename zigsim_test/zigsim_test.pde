import netP5.*;
import oscP5.*;

OscP5 osc;

void setup(){
size(400,400);
osc = new OscP5(this,9000);
}

void draw (){}
void oscEvent(OscMessage m){
println(m.addrPattern(),m.typetag());}
