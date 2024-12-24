import ddf.minim.*;
import java.util.HashMap;

Minim minim;
AudioOutput out;
HashMap<Character, Float> redNoteMap = new HashMap<>();
HashMap<Character, Float> blueNoteMap = new HashMap<>();

int successCount = 0; // Tracks successful decoding attempts
float redBeatDuration = 500; 
float blueBeatDuration = 750; 
long lastDecodingAttemptMillis = 0;
int decodingSpeed = 500; // Controls decoding attempts every 500 ms (2 per second)

String textToDisplay = "Hi I am Adam".toUpperCase();

float redBaseSize = 200;     // Base size of Red circle
float blueBaseSize = 200;    // Base size of Blue circle
float redBreathFactor = 5;   // Amount to expand/contract during "breathing"
float blueBreathFactor = 5;  // Amount to expand/contract during "breathing"
float breathSpeed = 0.05;    // Speed of the breathing effect
float breathOffset = 0;      // Offset for smoother animation

boolean gameStarted = false; 
boolean showPulse = false;      // Track if we should show a pulse
int pulseAlpha = 255;           // Starting alpha for pulse
int pulseDecay = 15;            // Decay speed for the pulse alpha
float purplePulseSize = 50;     // Size of the Purple pulse

void setup() {
  fullScreen();
  minim = new Minim(this);
  out = minim.getLineOut();

  // C Major (Red)
  float[] redNotes = {82.41, 87.31, 98.00, 110.00, 123.47, 130.81, 146.83, 164.81, 174.61, 196.00, 
                      220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 
                      523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77};
  for (char c = 'A'; c <= 'Z'; c++) redNoteMap.put(c, redNotes[c - 'A']);

  // D Major (Blue)
  float[] blueNotesArray = {73.42, 82.41, 92.50, 98.00, 110.00, 123.47, 138.59, 146.83, 164.81, 184.99, 
                            196.00, 220.00, 246.94, 277.18, 293.66, 329.63, 369.99, 392.00, 440.00, 
                            493.88, 554.37, 587.33, 659.25, 739.99, 783.99, 880.00};
  for (int i = 0; i < blueNotesArray.length; i++) blueNoteMap.put((char)('A' + i), blueNotesArray[i]);
}

void draw() {
  
   if (!gameStarted) {
    showStartScreen(); 
    return; 
  }
  background(0);
  noStroke();
  
  // Update breathing offset
  breathOffset += breathSpeed;

  // Calculate breathing sizes using a sine wave for smooth expansion/contraction
  float redCurrentSize = redBaseSize + sin(breathOffset) * redBreathFactor;
  float blueCurrentSize = blueBaseSize + sin(breathOffset + PI) * blueBreathFactor; // Offset for asynchronous breathing

  float centerX = width / 2;
  float centerY = height / 2;

  // Red circle with breathing effect
  fill(255, 0, 0);
  ellipse(centerX - 100, centerY, redCurrentSize, redCurrentSize);
  displayDecodingText("Red Decoding", centerX - 100, centerY + 70);

  // Blue circle with breathing effect
  fill(0, 0, 255);
  ellipse(centerX + 100, centerY, blueCurrentSize, blueCurrentSize);
  displayDecodingText("Blue Decoding", centerX + 100, centerY + 70);

  // Attempt decoding every 500 ms
  if (millis() - lastDecodingAttemptMillis >= decodingSpeed) {
    attemptDecoding(); 
    lastDecodingAttemptMillis = millis();
  }

  displayPulse(); // Show purple pulse effect if triggered

  if (successCount >= textToDisplay.length() * 2) { // Check if full phrase decoded by both
    fill(128, 0, 128);
    ellipse(centerX, centerY, 70, 70); // Permanent Purple circle
  }
}

void showStartScreen() {
  background(0); 
  fill(200);
  textAlign(CENTER, CENTER);
  textSize(45);
  text("Click the mouse to start", width / 2, height / 2 - 20);
  textSize(30);
  text("Language decoder", width / 2, height / 2 + 20);
}

void mousePressed() {
  if (!gameStarted) {
    gameStarted = true; 
  }
}

void attemptDecoding() {
  char redChar = getRandomChar();
  char blueChar = getRandomChar();

  float redDecodedFreq = redNoteMap.get(redChar);
  float blueActualFreq = blueNoteMap.get(blueChar);
  println("Red attempts to decode Blue's '" + blueChar + "' with frequency " + redDecodedFreq);
  playSoundAndDisplayLetter(redChar, redNoteMap, redBeatDuration); // Play sound for Red's attempt
  
  if (Math.abs(redDecodedFreq - blueActualFreq) < 5.0) {
    successCount++;
    addPulse();  // Trigger pulse on success
    println("Success! Red decoded Blue's '" + blueChar + "'");
  }

  float blueDecodedFreq = blueNoteMap.get(blueChar);
  float redActualFreq = redNoteMap.get(redChar);
  println("Blue attempts to decode Red's '" + redChar + "' with frequency " + blueDecodedFreq);
  playSoundAndDisplayLetter(blueChar, blueNoteMap, blueBeatDuration); // Play sound for Blue's attempt

  if (Math.abs(blueDecodedFreq - redActualFreq) < 5.0) {
    successCount++;
    addPulse();  // Trigger pulse on success
    println("Success! Blue decoded Red's '" + redChar + "'");
  }
}

void addPulse() {
  showPulse = true;
  pulseAlpha = 255;
}

void displayPulse() {
  if (showPulse) {
    fill(128, 0, 128, pulseAlpha);
    ellipse(width / 2, height / 2, purplePulseSize, purplePulseSize);
    pulseAlpha -= pulseDecay;
    if (pulseAlpha <= 0) {
      showPulse = false;
    }
  }
}

void playSoundAndDisplayLetter(char letter, HashMap<Character, Float> noteMap, float beatDuration) {
  if (noteMap.containsKey(letter)) {
    float freq = noteMap.get(letter);
    out.playNote(beatDuration / 1000.0, freq);
  }
}

void displayDecodingText(String decodingText, float x, float y) {
  fill(225);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(decodingText, x, y);
}

char getRandomChar() {
  int randomIndex = (int)random(26); // A to Z
  return (char)('A' + randomIndex);
}

void stop() {
  out.close();
  minim.stop();
  super.stop();
}
