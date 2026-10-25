import netP5.*;
import oscP5.*;

OscP5 osc;

void setup(){
size(400,400);
osc = new OscP5(this,9000);
}

void draw (){}
void oscEvent(OscMessage m){
if (m.checkAddrPattern("/ZIGSIM/amansiphone/gravity")) {
    float gx = m.get(0).floatValue();
    float gy = m.get(1).floatValue();
    float gz = m.get(2).floatValue();
    println(nf(gx, 1, 2), nf(gy, 1, 2), nf(gz, 1, 2));
  }}
