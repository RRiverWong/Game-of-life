int cols, rows;
int w = 20; 
Cell[][] grid;
ArrayList<Cell> stack = new ArrayList<Cell>();
PVector apple;
NPC redNPC, blueNPC;

boolean gameStarted = false; 
boolean gameOver = false;
String winner = "";

void setup() {
  fullScreen(); 
  cols = floor(width / w); 
  rows = floor(height / w); 
  grid = new Cell[cols][rows];
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      grid[i][j] = new Cell(i, j);
    }
  }
  
  generateMaze(); 
  
  apple = new PVector(cols / 2 * w + w / 2, rows / 2 * w + w / 2);
  
  redNPC = new NPC(0, 0, color(255, 0, 0)); 
  blueNPC = new NPC(cols - 1, rows - 1, color(0, 0, 255)); 
}

void draw() {
   if (!gameStarted) {
    showStartScreen(); 
    return; 
  }
  background(0); 
  
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      grid[i][j].show();
    }
  }
  
  fill(0, 255, 0);
  noStroke();
  rect(apple.x - w / 4, apple.y - w / 4, w / 2, w / 2); 
  
  // NPC 
  if (!gameOver) {
    redNPC.move();
    blueNPC.move();
    redNPC.show();
    blueNPC.show();
    
    if (redNPC.pos.equals(apple)) {
      gameOver = true;
      winner = "Red Find the Green First!";
    } else if (blueNPC.pos.equals(apple)) {
      gameOver = true;
      winner = "Blue Find the Green First!";
    }
  } else {
    
    textSize(32);
    fill(255);
    textAlign(CENTER, CENTER);
    text(winner, width / 2, height / 2);
  }
}

void showStartScreen() {
  background(0); 
  fill(200);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("Click the mouse to start", width / 2, height / 2 - 20);
  textSize(16);
  text("An NPC with a compass. Based on A* algorithm", width / 2, height / 2 + 20);
}

void mousePressed() {
  if (!gameStarted) {
    gameStarted = true; 
  }
}

void generateMaze() {
  Cell current = grid[0][0];
  stack.add(current);
  
  while (stack.size() > 0) {
    current.visited = true;
    Cell next = current.checkNeighbors();
    if (next != null) {
      next.visited = true;
      stack.add(current);
      removeWalls(current, next);
      current = next;
    } else {
      current = stack.remove(stack.size() - 1);
    }
  }
}

void removeWalls(Cell a, Cell b) {
  int x = a.i - b.i;
  if (x == 1) {
    a.walls[3] = false;
    b.walls[1] = false;
  } else if (x == -1) {
    a.walls[1] = false;
    b.walls[3] = false;
  }
  int y = a.j - b.j;
  if (y == 1) {
    a.walls[0] = false;
    b.walls[2] = false;
  } else if (y == -1) {
    a.walls[2] = false;
    b.walls[0] = false;
  }
}


class Cell {
  int i, j;
  boolean[] walls = {true, true, true, true};
  boolean visited = false;

  Cell(int i, int j) {
    this.i = i;
    this.j = j;
  }

  void show() {
    int x = i * w;
    int y = j * w;
    
    
    stroke(255); 
    strokeWeight(2); 
    
 
    if (walls[0]) line(x, y, x + w, y);      
    if (walls[1]) line(x + w, y, x + w, y + w); 
    if (walls[2]) line(x + w, y + w, x, y + w); 
    if (walls[3]) line(x, y + w, x, y);         
    
    
    if (visited) {
      noStroke();
      noFill(); 
    }
  }

  Cell checkNeighbors() {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();

    
    if (j > 0 && !grid[i][j - 1].visited) neighbors.add(grid[i][j - 1]);
    if (i < cols - 1 && !grid[i + 1][j].visited) neighbors.add(grid[i + 1][j]);
    if (j < rows - 1 && !grid[i][j + 1].visited) neighbors.add(grid[i][j + 1]);
    if (i > 0 && !grid[i - 1][j].visited) neighbors.add(grid[i - 1][j]);

    if (neighbors.size() > 0) {
      int r = floor(random(0, neighbors.size()));
      return neighbors.get(r);
    } else {
      return null;
    }
  }
}


class NPC {
  PVector pos;
  int c;

  NPC(int i, int j, int c) {
    pos = new PVector(i * w + w / 2, j * w + w / 2);
    this.c = c;
  }

  void move() {
    int i = int(pos.x / w);
    int j = int(pos.y / w);
    Cell current = grid[i][j];

    ArrayList<PVector> options = new ArrayList<PVector>();
    if (!current.walls[0] && j > 0) options.add(new PVector(i, j - 1));
    if (!current.walls[1] && i < cols - 1) options.add(new PVector(i + 1, j));
    if (!current.walls[2] && j < rows - 1) options.add(new PVector(i, j + 1));
    if (!current.walls[3] && i > 0) options.add(new PVector(i - 1, j));

    if (options.size() > 0) {
      PVector next = options.get(floor(random(options.size())));
      pos.x = next.x * w + w / 2;
      pos.y = next.y * w + w / 2;
    }
  }

  void show() {
    fill(c);
    noStroke();
    rect(pos.x - w / 4, pos.y - w / 4, w / 2, w / 2); 
  }
}
