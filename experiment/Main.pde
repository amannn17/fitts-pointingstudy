import java.util.Collections;
import netP5.*;
import oscP5.*;

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
int hitsPerCondition = 10;

// --- Rounds ---
int block = 1;              // which round we're on
int totalBlocks = 2;        // how many rounds in total

// --- The dealer ---
Study exp;

// --- Start screen ---
boolean started = false;    // the light switch: off until Enter
String participantID = "";  // grows as you type
String device = "mouse";    // TAB switches it

// --- Phone ---
OscP5 osc;
float gx, gy, gz;           // raw tilt from ZigSim
float neutralX = 0;         // "flat" for this person, set by calibrate()
float neutralY = 0;
float smoothing = 0.25;     // 1 = no smoothing; smaller = calmer but laggier

// --- Pointer (used by both devices) ---
float pointerX, pointerY;   // where the cursor is, whichever device

void setup() {
  size(1200, 600);
  osc = new OscP5(this, 9000);   // switch on the ears
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

    // Update the cursor, and show the dot when using the phone
    updatePointer();
    if (device.equals("phone")) {
      fill(40, 90, 230);
      ellipse(pointerX, pointerY, 12, 12);
    }
  }
}

// Where is the cursor right now? Works for both devices.
void updatePointer() {
  if (device.equals("phone")) {
    // 1. Where the tilt says the dot should be
    float rawX = map(gx - neutralX, -0.5, 0.5, 0, width);
    float rawY = map(gy - neutralY, -0.3, 0.3, 0, height);  // tilt toward = up
    rawX = constrain(rawX, 0, width);
    rawY = constrain(rawY, 0, height);

    // 2. Walk part of the way there (smoothing)
    pointerX = lerp(pointerX, rawX, smoothing);
    pointerY = lerp(pointerY, rawY, smoothing);
  } else {
    pointerX = mouseX;
    pointerY = mouseY;
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
  if (device.equals("phone")) {
    text("Hold the phone comfortably, then press ENTER", width/2, height/2 + 110);
  }
}

// The doorbell: runs by itself when a ZigSim message arrives
void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/ZIGSIM/amansiphone/gravity")) {
    gx = m.get(0).floatValue();
    gy = m.get(1).floatValue();
    gz = m.get(2).floatValue();
  }
}

// Press "zero": the current tilt becomes the middle of the screen
void calibrate() {
  neutralX = gx;
  neutralY = gy;
  println("Calibrated: neutral x = " + nf(neutralX, 1, 2) + "  y = " + nf(neutralY, 1, 2));
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

  // Which target is red? Did the pointer hit it?
  boolean hit;
  float targetX;
  if (leftActive) {
    hit = left.contains(pointerX, pointerY);
    targetX = left.x;
  } else {
    hit = right.contains(pointerX, pointerY);
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
  Trial t = new Trial(participantID, device, block, trialNumber, A, W, mt, hit, pointerX, pointerY, targetX);
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
        if (device.equals("phone")) {
          calibrate();
        }
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

  // During the game, C re-zeros the phone
  if (key == 'c' && device.equals("phone")) {
    calibrate();
  }
}
