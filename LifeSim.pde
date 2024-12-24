import java.util.Random;

// Size of cells
int cellSize = 15;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 3;

// Variables for timer
int interval = 100; // Interval between iterations
int lastRecordedTime = 0; // Time of the last iteration

// Colors for active/inactive cells
color dead = color(0); // Dead cells are represented by black

// Arrays for cells, age, and names
int[][] cells;  // Array for cell states (alive or dead)
int[][] age;  // Array for tracking the age of cells
String[][] names;  // Array for cell names
int[][] cellsBuffer;  // Buffer array for storing cell states temporarily
int[][] ageBuffer;  // Buffer array for storing cell age temporarily
int[][] survivalFailedSteps;  // Array to track survival failure steps for cells
String[][] namesBuffer;  // Buffer array for storing cell names temporarily

boolean gameStarted = false;  // Flag to track if the game has started
boolean pause = false;  // Flag to track if the game is paused

// Function to return grid position in (x, y) format
String getGridPosition(int x, int y) {
  String column = str(x + 1);  // Horizontal index starts from 1
  String row = str(y + 1);     // Vertical index starts from 1
  return "(" + column + ", " + row + ")";
}

void setup() {
  fullScreen(); // Set fullscreen mode

  // Instantiate arrays
  cells = new int[width/cellSize][height/cellSize];
  age = new int[width/cellSize][height/cellSize];
  names = new String[width/cellSize][height/cellSize];
  survivalFailedSteps = new int[width/cellSize][height/cellSize];  // Initialize failure counters
  cellsBuffer = new int[width/cellSize][height/cellSize];
  ageBuffer = new int[width/cellSize][height/cellSize];
  namesBuffer = new String[width/cellSize][height/cellSize];

  stroke(48); // Set stroke color
  noSmooth(); // Disable smoothing

  // Initialize cell states
  for (int x = 0; x < width/cellSize; x++) {
    for (int y = 0; y < height/cellSize; y++) {
      float state = random(100); // Randomize initial state
      if (state > probabilityOfAliveAtStart) {
        state = 0; // Dead cell
      } else {
        state = 1; // Alive cell
        names[x][y] = generateRandomName(); // Generate a random name for the cell
        println(names[x][y] + " Birth");
      }
      cells[x][y] = int(state);
      age[x][y] = 0; // Initialize age to 0
      survivalFailedSteps[x][y] = 0;  // Initialize failure counter to 0
    }
  }
  background(0); // Set background to black
}

void draw() {
  if (!gameStarted) { // Show start screen if game hasn't started
    showStartScreen(); 
    return; 
  }
  
  // Render cells
  for (int x = 0; x < width/cellSize; x++) {
    for (int y = 0; y < height/cellSize; y++) {
      if (cells[x][y] == 1) { // If cell is alive
        fill(getColorByAge(age[x][y]));  // Set color based on cell's age
      } else {
        fill(dead);  // Set color to black for dead cells
      }
      rect(x * cellSize, y * cellSize, cellSize, cellSize); // Draw the cell
    }
  }

  // Check for interval and update cells if not paused
  if (millis() - lastRecordedTime > interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis(); // Update last recorded time
    }
  }

  // Handle mouse interactions in pause mode
  if (pause && mousePressed) {
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize - 1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize - 1);

    if (cellsBuffer[xCellOver][yCellOver] == 1) { // If cell is alive, kill it
      cells[xCellOver][yCellOver] = 0;  
      age[xCellOver][yCellOver] = 0;  
      println(names[xCellOver][yCellOver] + " is Dead, It lived for " + age[xCellOver][yCellOver] + " Years");
      names[xCellOver][yCellOver] = null;  
      fill(dead); // Set color to black
    } else { // If cell is dead, revive it
      cells[xCellOver][yCellOver] = 1;
      names[xCellOver][yCellOver] = generateRandomName();  
      println(names[xCellOver][yCellOver] + " Birth");
      fill(getColorByAge(0));  
    }
  }
}

// Show the start screen
void showStartScreen() {
  background(0); 
  fill(200); // Set text color to white
  textAlign(CENTER, CENTER);
  textSize(45);
  text("Click the mouse to start", width / 2, height / 2 - 20); // Instructions
  textSize(30);
  text("Game of Life", width / 2, height / 2 + 20); // Title
}

// Start the game on mouse press
void mousePressed() {
  if (!gameStarted) {
    gameStarted = true; 
  }
}
// Main iteration logic
void iteration() {
  // Copy current state to buffer
  for (int x = 0; x < width/cellSize; x++) {
    for (int y = 0; y < height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
      ageBuffer[x][y] = age[x][y];
      namesBuffer[x][y] = names[x][y];
    }
  }

  // Process each cell
  for (int x = 0; x < width/cellSize; x++) {
    for (int y = 0; y < height/cellSize; y++) {
      int neighbours = 0; // Neighbor count

      // Count live neighbors
      for (int xx = x - 1; xx <= x + 1; xx++) {
        for (int yy = y - 1; yy <= y + 1; yy++) {
          if ((xx >= 0 && xx < width/cellSize) && (yy >= 0 && yy < height/cellSize)) {
            if (!(xx == x && yy == y)) { // Exclude the cell itself
              if (cellsBuffer[xx][yy] == 1) {
                neighbours++;
              }
            }
          }
        }
      }

      // Handle live cells
      if (cellsBuffer[x][y] == 1) {
        if (neighbours < 2 || neighbours > 3) { // Check survival rules
          survivalFailedSteps[x][y]++; // Increment failure counter
          if (survivalFailedSteps[x][y] >= 3) { // Die after 3 failed steps
            println(names[x][y] + " died after failing to survive for 3 steps, position: " + getGridPosition(x, y));
            cells[x][y] = 0;
            age[x][y] = 0;
            names[x][y] = null;
            survivalFailedSteps[x][y] = 0; // Reset failure counter
            continue;
          }
        } else {
          survivalFailedSteps[x][y] = 0; // Reset failure counter
          age[x][y]++; // Increment age
        }
      }

      // Handle dead cells
      if (cellsBuffer[x][y] == 0 && neighbours == 3) { // Revival condition
        cells[x][y] = 1;
        names[x][y] = generateRandomName();
        age[x][y] = 1;
        survivalFailedSteps[x][y] = 0; // Reset failure counter
        println(names[x][y] + " Birth in " + getGridPosition(x, y));
      }
    }
  }
}

// Return cell color based on age
color getColorByAge(int age) {
  if (age < 18) {
    return color(255, 255, 0);  // Yellow (young)
  } else if (age < 30) {
    return color(173, 255, 47);  // Yellow-green
  } else if (age < 50) {
    return color(255, 255, 0);  // Yellow again
  } else if (age < 80) {
    return color(255, 165, 0);  // Orange
  } else {
    return color(255, 0, 0);    // Red (old)
  }
}

// Generate random names for cells
String generateRandomName() {
  String[] namesList = {"Alice", "Bob", "Charlie", "Daisy", "Eve", "Frank", "Grace", "Hank", "Ivy", "Jack"};
  Random random = new Random();
  return namesList[random.nextInt(namesList.length)];
}

// Handle key inputs for additional functionality
void keyPressed() {
  if (key == 'r' || key == 'R') { // Reset cells with random states
    for (int x = 0; x < width/cellSize; x++) {
      for (int y = 0; y < height/cellSize; y++) {
        float state = random(100);
        if (state > probabilityOfAliveAtStart) {
          state = 0; // Dead cell
        } else {
          state = 1; // Alive cell
          names[x][y] = generateRandomName();
          println(names[x][y] + " Birth in ");
        }
        cells[x][y] = int(state);
        age[x][y] = 0; // Reset age
      }
    }
  }
  if (key == ' ') { // Pause or resume the game
    pause = !pause;
  }
  if (key == 'c' || key == 'C') { // Clear all cells
    for (int x = 0; x < width/cellSize; x++) {
      for (int y = 0; y < height/cellSize; y++) {
        cells[x][y] = 0;
        age[x][y] = 0;
        names[x][y] = null;
      }
    }
  }
}
