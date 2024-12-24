import ddf.minim.*;
import java.util.HashMap;
import java.util.Collections;
import java.util.List;
import java.util.ArrayList;

Minim minim;
AudioOutput out;
HashMap<Character, Float> redNoteMap = new HashMap<>();
HashMap<Character, Float> yellowNoteMap = new HashMap<>();
HashMap<Character, Float> blueNoteMap = new HashMap<>();
HashMap<Character, Float> orangeNoteMap = new HashMap<>();
HashMap<Character, Float> purpleNoteMap = new HashMap<>();
HashMap<Character, Float> greenNoteMap = new HashMap<>();
HashMap<Character, Float> letterDurations = new HashMap<>();

int orangeLetterIndex = 0, purpleLetterIndex = 0, greenLetterIndex = 0;
boolean orangeShowText = false, purpleShowText = false, greenShowText = false;
float orangeBeatDuration = 400; 
float purpleBeatDuration = 600; 
float greenBeatDuration = 500; 
long lastOrangeMillis, lastPurpleMillis, lastGreenMillis;

String textToDisplay = "A for Apple A A Apple".toUpperCase();
int redLetterIndex = 0, yellowLetterIndex = 0, blueLetterIndex = 0;
boolean redShowText = false, yellowShowText = false, blueShowText = false;
float redBeatDuration = 500; 
float yellowBeatDuration = 667; 
float blueBeatDuration = 750; 
long lastRedMillis, lastYellowMillis, lastBlueMillis;

boolean redClicked = false, yellowClicked = false, blueClicked = false;
boolean orangeClicked = false, purpleClicked = false, greenClicked = false;
boolean showStartScreen = true; 

void setup() {
  fullScreen();
  minim = new Minim(this);
  out = minim.getLineOut();
  float[] durations = {100, 250, 400, 600, 200, 800, 300, 700, 500, 1000, 450, 350, 600,
                       200, 750, 300, 900, 250, 550, 800, 650, 150, 450, 900, 200, 1000};
  for (char c = 'A'; c <= 'Z'; c++) {
    letterDurations.put(c, durations[c - 'A']);
  }

  
  // A Major (Orange)
  float[] orangeNotes = {110.00, 123.47, 138.59, 146.83, 164.81, 184.99, 196.00, 220.00, 246.94, 
                         277.18, 293.66, 329.63, 369.99, 392.00, 440.00, 493.88, 554.37, 587.33, 
                         659.25, 739.99, 783.99, 880.00, 987.77, 1046.50, 1174.66, 1318.51};
  for (char c = 'A'; c <= 'Z'; c++) orangeNoteMap.put(c, orangeNotes[c - 'A']);

  // B Minor (Purple) - Reversed
  float[] purpleNotes = {123.47, 130.81, 146.83, 164.81, 174.61, 196.00, 220.00, 246.94, 261.63, 
                         293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 659.25, 
                         698.46, 783.99, 880.00, 987.77, 1046.50, 1174.66, 1318.51, 1480.00};
  for (int i = 0; i < purpleNotes.length; i++) purpleNoteMap.put((char)('A' + i), purpleNotes[purpleNotes.length - i - 1]);

  // E Minor (Green) - Randomized
  float[] greenNotesArray = {82.41, 92.50, 98.00, 110.00, 123.47, 138.59, 146.83, 164.81, 184.99, 
                             196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 369.99, 392.00, 
                             440.00, 493.88, 554.37, 587.33, 659.25, 739.99, 783.99, 880.00};
  List<Float> greenNotes = new ArrayList<Float>();
  for (float note : greenNotesArray) greenNotes.add(note);
  Collections.shuffle(greenNotes);
  for (int i = 0; i < greenNotes.size(); i++) greenNoteMap.put((char)('A' + i), greenNotes.get(i));

  // C Major (Red)
  float[] redNotes = {82.41, 87.31, 98.00, 110.00, 123.47, 130.81, 146.83, 164.81, 174.61, 196.00, 
                      220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 
                      523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77};
  for (char c = 'A'; c <= 'Z'; c++) redNoteMap.put(c, redNotes[c - 'A']);

  // G Major (Yellow) - Reversed
  float[] yellowNotes = {98.00, 110.00, 123.47, 130.81, 146.83, 164.81, 174.61, 196.00, 220.00, 246.94,
                         261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 
                         659.25, 698.46, 783.99, 880.00, 987.77, 1046.50, 1174.66};
  for (int i = 0; i < yellowNotes.length; i++) yellowNoteMap.put((char)('A' + i), yellowNotes[yellowNotes.length - i - 1]);

  // D Major (Blue) - Randomized
  float[] blueNotesArray = {73.42, 82.41, 92.50, 98.00, 110.00, 123.47, 138.59, 146.83, 164.81, 184.99, 
                            196.00, 220.00, 246.94, 277.18, 293.66, 329.63, 369.99, 392.00, 440.00, 
                            493.88, 554.37, 587.33, 659.25, 739.99, 783.99, 880.00};
  List<Float> blueNotes = new ArrayList<Float>();
  for (float note : blueNotesArray) blueNotes.add(note);
  Collections.shuffle(blueNotes);
  for (int i = 0; i < blueNotes.size(); i++) blueNoteMap.put((char)('A' + i), blueNotes.get(i));
}
void draw() {
  if (showStartScreen) {
    background(0); // 黑色背景
    fill(200); // 浅灰文字
    textAlign(CENTER, CENTER);
    textSize(45);
    text("Click the mouse to start", width / 2, height / 2 - 20);
    textSize(30);
    text("Language System", width / 2, height / 2 + 20);
    return; 
  }
  
  background(0);
  noStroke();
  
  float centerX = width / 2;
  float rowSpacing = 150;
  float circleSpacing = 130;
  float row1Y = height / 2 - rowSpacing / 2;
  float row2Y = height / 2 + rowSpacing / 2;
  int defaultSize = 100;
  int clickedSize = 120;

  // Red square
  fill(255, 0, 0);
  float redSize = redClicked ? clickedSize : defaultSize;
  ellipse(centerX - circleSpacing, row1Y , redSize, redSize);
  if (redShowText && millis() - lastRedMillis >= redBeatDuration && redLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(redLetterIndex++);
    playSoundAndDisplayLetter(letter, redNoteMap, redBeatDuration);
    lastRedMillis = millis();
  }
  if (redShowText) displayText(textToDisplay.substring(0, redLetterIndex), centerX - circleSpacing, row1Y + 70);

  // Reset click effect for red
  if (redClicked && millis() - lastRedMillis > 100) redClicked = false;

  // Repeat similar structure for other squares (Yellow, Blue, Orange, Purple, Green)

  // Yellow square
  fill(255, 255, 0);
  float yellowSize = yellowClicked ? clickedSize : defaultSize;
  ellipse(centerX , row1Y , yellowSize, yellowSize);
  if (yellowShowText && millis() - lastYellowMillis >= yellowBeatDuration && yellowLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(yellowLetterIndex++);
    playSoundAndDisplayLetter(letter, yellowNoteMap, yellowBeatDuration);
    lastYellowMillis = millis();
  }
  if (yellowShowText) displayText(textToDisplay.substring(0, yellowLetterIndex), centerX, row1Y + 70);
  if (yellowClicked && millis() - lastYellowMillis > 100) yellowClicked = false;

  // Blue square
  fill(0, 0, 255);
  float blueSize = blueClicked ? clickedSize : defaultSize;
  ellipse(centerX + circleSpacing , row1Y , blueSize, blueSize);
  if (blueShowText && millis() - lastBlueMillis >= blueBeatDuration && blueLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(blueLetterIndex++);
    playSoundAndDisplayLetter(letter, blueNoteMap, blueBeatDuration);
    lastBlueMillis = millis();
  }
  if (blueShowText) displayText(textToDisplay.substring(0, blueLetterIndex), centerX + circleSpacing, row1Y + 70);
  if (blueClicked && millis() - lastBlueMillis > 100) blueClicked = false;

  // Orange square
  fill(255, 165, 0);
  float orangeSize = orangeClicked ? clickedSize : defaultSize;
  ellipse(centerX - circleSpacing, row2Y , orangeSize, orangeSize);
  if (orangeShowText && millis() - lastOrangeMillis >= orangeBeatDuration && orangeLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(orangeLetterIndex++);
    playSoundAndDisplayLetter(letter, orangeNoteMap, orangeBeatDuration);
    lastOrangeMillis = millis();
  }
  if (orangeShowText) displayText(textToDisplay.substring(0, orangeLetterIndex), centerX - circleSpacing, row2Y + 70);
  if (orangeClicked && millis() - lastOrangeMillis > 100) orangeClicked = false;

  // Purple square
  fill(128, 0, 128);
  float purpleSize = purpleClicked ? clickedSize : defaultSize;
  ellipse(centerX, row2Y, purpleSize, purpleSize);
  if (purpleShowText && millis() - lastPurpleMillis >= purpleBeatDuration && purpleLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(purpleLetterIndex++);
    playSoundAndDisplayLetter(letter, purpleNoteMap, purpleBeatDuration);
    lastPurpleMillis = millis();
  }
  if (purpleShowText) displayText(textToDisplay.substring(0, purpleLetterIndex), centerX, row2Y + 70);
  if (purpleClicked && millis() - lastPurpleMillis > 100) purpleClicked = false;

  // Green square
  fill(0, 255, 0);
  float greenSize = greenClicked ? clickedSize : defaultSize;
  ellipse(centerX + circleSpacing , row2Y, greenSize, greenSize);
  if (greenShowText && millis() - lastGreenMillis >= greenBeatDuration && greenLetterIndex < textToDisplay.length()) {
    char letter = textToDisplay.charAt(greenLetterIndex++);
    playSoundAndDisplayLetter(letter, greenNoteMap, greenBeatDuration);
    lastGreenMillis = millis();
  }
  if (greenShowText) displayText(textToDisplay.substring(0, greenLetterIndex), centerX + circleSpacing, row2Y + 70);
  if (greenClicked && millis() - lastGreenMillis > 100) greenClicked = false;
}

void playSoundAndDisplayLetter(char letter, HashMap<Character, Float> noteMap, float beatDuration) {
  if (noteMap.containsKey(letter)) {
    float freq = noteMap.get(letter);
    float duration = letterDurations.getOrDefault(letter, beatDuration); // 使用自定义音长
    out.playNote(duration / 1000.0, freq); // 以自定义音长播放音频
  }
}
void mousePressed() {
    if (showStartScreen) {
    showStartScreen = false; // 切换到主程序
    return;
  }
  
  float centerX = width / 2;
  float rowSpacing = 150;
  float circleSpacing = 130;
  float row1Y = height / 2 - rowSpacing / 2;
  float row2Y = height / 2 + rowSpacing / 2;

  // Red circle click
  if (dist(mouseX, mouseY, centerX - circleSpacing, row1Y) < 50) {
    redShowText = !redShowText;
    redLetterIndex = 0;
    lastRedMillis = millis();
    redClicked = true;
  }

  // Yellow circle click
  if (dist(mouseX, mouseY, centerX, row1Y) < 50) {
    yellowShowText = !yellowShowText;
    yellowLetterIndex = 0;
    lastYellowMillis = millis();
    yellowClicked = true;
  }

  // Blue circle click
  if (dist(mouseX, mouseY, centerX + circleSpacing, row1Y) < 50) {
    blueShowText = !blueShowText;
    blueLetterIndex = 0;
    lastBlueMillis = millis();
    blueClicked = true;
  }

  // Orange circle click
  if (dist(mouseX, mouseY, centerX - circleSpacing, row2Y) < 50) {
    orangeShowText = !orangeShowText;
    orangeLetterIndex = 0;
    lastOrangeMillis = millis();
    orangeClicked = true;
  }

  // Purple circle click
  if (dist(mouseX, mouseY, centerX, row2Y) < 50) {
    purpleShowText = !purpleShowText;
    purpleLetterIndex = 0;
    lastPurpleMillis = millis();
    purpleClicked = true;
  }

  // Green circle click
  if (dist(mouseX, mouseY, centerX + circleSpacing, row2Y) < 50) {
    greenShowText = !greenShowText;
    greenLetterIndex = 0;
    lastGreenMillis = millis();
    greenClicked = true;
  }
}
void displayText(String text, float x, float y) {
  fill(225);
  textAlign(CENTER, CENTER);
  textSize(16);
  text(text, x, y);
}


void stop() {
  out.close();
  minim.stop();
  super.stop();
}
