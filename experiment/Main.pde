import java.util.Collections;

// --- Targets ---
Target left;
Target right;
boolean leftActive = true;

// --- Timing ---
int lastHitTime = 0;
boolean firstClick = true;

// --- Data ---
ArrayList<Trial> trials = new ArrayList<Trial>();
int trialNumber = 0;

// --- Current card ---
float A = 400;
float W = 40;
int hitCount = 0;
int hitsPerCondition = 10;   // TEST VALUE: set back to 10 after testing

// --- Rounds ---
int block = 1;              // which round we're on
int totalBlocks = 2;        // how many rounds in total

// --- The dealer ---
Study exp;

// --- Start screen ---
boolean started = false;    // the light switch: off until Enter
String participantID = "";  // grows as you type
String device = "mouse";    // TAB switches it

void setup() {
  size(1200, 600);
  exp = new Study();
  exp.printConditions();
  setupTargets();
}

void draw() {
  background(255);

  // Start screen: draw the door and stop here
  if (!started) {
    drawStartScreen();
    return;
  }

  if (exp.isFinished()) {
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("All done! Thank you. Data saved.", width/2, height/2);
  } else {
    left.display(leftActive);
    right.display(!leftActive);

    // Small label in the corner
    fill(120);
    textAlign(LEFT, TOP);
    textSize(18);
    text("Block " + block + " of " + totalBlocks, 20, 20);
  }
}

void drawStartScreen() {
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(28);
  text("Participant ID: " + participantID + "_", width/2, height/2 - 60);
  text("Device: " + device + "   (press TAB to switch)", width/2, height/2);
  textSize(20);
  fill(120);
  text("Press ENTER to start", width/2, height/2 + 70);
}

void mousePressed() {
  // Ignore clicks at the start screen
  if (!started) {
    return;
  }

  // After the last card, clicks do nothing
  if (exp.isFinished()) {
    return;
  }

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
  Trial t = new Trial(participantID, device, block, trialNumber, A, W, mt, hit, mouseX, mouseY, targetX);
  trials.add(t);
  println("Trial " + trialNumber + "  hit: " + hit + "  MT: " + mt + " ms  cards in box: " + trials.size());

  // Only a hit moves to the other target and restarts the timer
  if (hit) {
    lastHitTime = millis();
    leftActive = !leftActive;
    hitCount = hitCount + 1;

    // Enough hits? Next card!
    if (hitCount == hitsPerCondition) {
      exp.next();
      if (exp.isFinished()) {
        if (block < totalBlocks) {
          // Not the last round: new dealer, new shuffle, play again
          block = block + 1;
          println("BLOCK " + block + " STARTING");
          exp = new Study();
          exp.printConditions();
          setupTargets();
        } else {
          // Last round done: save automatically
          println("ALL BLOCKS DONE");
          saveData();
        }
      } else {
        setupTargets();
      }
    }
  }
}

void setupTargets() {
  Condition c = exp.currentCondition();
  A = c.A;
  W = c.W;
  left = new Target(width/2 - A/2, height/2, W);
  right = new Target(width/2 + A/2, height/2, W);
  leftActive = true;
  firstClick = true;   // each new card needs its own start click
  hitCount = 0;        // start counting hits from zero
  println("New card: A = " + A + "  W = " + W);
}

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

  // 3. Save it as a file named after the participant and device
  String filename = "../data/" + participantID + "_" + device + ".csv";
  saveTable(table, filename);
  println("Saved " + trials.size() + " trials to " + filename);
}

void keyPressed() {
  // At the start screen, keys are for typing
  if (!started) {
    if (key == ENTER || key == RETURN) {
      if (participantID.length() > 0) {   // can't start with no name
        started = true;
        println("Starting: " + participantID + ", " + device);
      }
    } else if (key == BACKSPACE) {
      if (participantID.length() > 0) {
        participantID = participantID.substring(0, participantID.length() - 1);
      }
    } else if (key == TAB) {
      if (device.equals("mouse")) {
        device = "phone";
      } else {
        device = "mouse";
      }
    } else if (Character.isLetterOrDigit(key)) {
      participantID = participantID + key;
    }
    return;
  }

  // During the game, S is the backup save
  if (key == 's') {
    saveData();
  }
}
