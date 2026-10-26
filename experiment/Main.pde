Target t;

void setup() {
  size(1200, 600);
  t = new Target(600, 300, 80);
}

void draw() {
  background(255);
  t.display(true);
}

void mousePressed() {
  if (t.contains(mouseX, mouseY)) {
    println("HIT");
  } else {
    println("MISS");
  }
}
