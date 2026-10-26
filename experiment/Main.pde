Target left;
Target right;
boolean leftActive = true;
int lastHitTime = 0;
boolean firstClick = true;

ArrayList<Trial> trials = new ArrayList<Trial>();
int trialNumber = 0;
float A = 400;
float W = 40;

void setup() {
  size(1200, 600);
  left = new Target(width/2 - A/2, height/2, W);
  right = new Target(width/2 + A/2, height/2, W);
}

void draw() {
  background(255);
  left.display(leftActive);
  right.display(!leftActive);
}

void mousePressed() {
  // Which target is red? Did the click hit it?
  boolean hit;
  float targetX;
  if (leftActive) {
    hit = left.contains(mouseX, mouseY);
    targetX = left.x;
  } else {
    hit = right.contains(mouseX, mouseY);
    targetX = right.x;
  }

  // Before the start click, nothing is recorded
  if (firstClick) {
    if (hit) {
      println("START");
      firstClick = false;
      lastHitTime = millis();
      leftActive = !leftActive;
    }
    return;
  }

  // From here on, every click gets a card
  int mt = millis() - lastHitTime;
  trialNumber = trialNumber + 1;
  Trial t = new Trial("P00", "mouse", 1, trialNumber, A, W, mt, hit, mouseX, mouseY, targetX);
  trials.add(t);
  println("Trial " + trialNumber + "  hit: " + hit + "  MT: " + mt + " ms  cards in box: " + trials.size());

  // Only a hit moves to the other target and restarts the timer
  if (hit) {
    lastHitTime = millis();
    leftActive = !leftActive;
  }}
void saveData() {
  // 1. An empty table with the column names
  Table table = new Table();
  table.addColumn("participant");
  table.addColumn("device");
  table.addColumn("block");
  table.addColumn("trial");
  table.addColumn("A");
  table.addColumn("W");
  table.addColumn("ID");
  table.addColumn("MT_ms");
  table.addColumn("hit");
  table.addColumn("clickX");
  table.addColumn("clickY");
  table.addColumn("targetX");

  // 2. One row for each card in the box
  for (Trial t : trials) {
    TableRow row = table.addRow();
    row.setString("participant", t.participant);
    row.setString("device", t.device);
    row.setInt("block", t.block);
    row.setInt("trial", t.trial);
    row.setFloat("A", t.A);
    row.setFloat("W", t.W);
    row.setFloat("ID", t.ID);
    row.setInt("MT_ms", t.MT);

    int hitValue = 0;
    if (t.hit) {
      hitValue = 1;
    }
    row.setInt("hit", hitValue);

    row.setFloat("clickX", t.clickX);
    row.setFloat("clickY", t.clickY);
    row.setFloat("targetX", t.targetX);
  }

  // 3. Save it as a file
  saveTable(table, "../data/P00_mouse.csv");
  println("Saved " + trials.size() + " trials");
}
void keyPressed() {
  if (key == 's') {
    saveData();
  }
}
