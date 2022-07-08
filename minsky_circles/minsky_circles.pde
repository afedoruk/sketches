import java.sql.Timestamp;

int centerX, centerY, cX = 100, cY = 100, randLimitX, randLimitY, numOfPoints = 20000;
float epsilonX = 2, epsilonY = 2;//0.0625;
float colorNoiseScale = 0.5, sizeNoiseScale = 0.1;
color bg = 0;//#666666;
//color[] colors = {#00b8a2,#12dbc4,#25db0d,#780387,#ab071a};
//color[] colors = {#7649c9,#8e59f0,#2a066b,#461f8f,#693cbd}; //monochromatic
//color[] colors = {#cc70e6,#e390fc,#a410e3,#a3b8cf,#5b72a6};
//color[] colors = {#8a9669,#a6027a,#8e8a99,#b9e346,#e1f7e7};
//color[] colors = {#a69ef0,#17b374,#f5428a,#a84d72,#cf789a};
color[] colors = {#d4968c,#8ff79f,#367985,#b8f2fc,#c9a1c3};

void setup() {
  size(800, 800);
  
  background(bg);

  centerX = width/2;
  centerY = height/2;

  drawShape(cX, cY, false);
  //drawShape(false);
  //drawShape(false);
}

void drawShape(int x, int y, boolean curve) {
  epsilonX = random(0.09);
  epsilonY = random(0.09);
  randLimitX = (int)random(5);
  randLimitY = (int)random(5);
  
  push();
  translate(centerX, centerY);
 
 
  int count = 0, colorIndex;
  noFill();
  beginShape();
  
  do {
    if(count%250 == 0) {
      noStroke();
      fill(bg, 7);
      rect(-width/2, -height/2, width, height);
    }
    PVector point = getNewPoint(x, y);
    colorIndex = (int)(noise(count*colorNoiseScale)*(colors.length));
    stroke( colors[colorIndex]);
    if ( curve) {
      curveVertex(point.x,  point.y);
    } else {
      //fill( colors[colorIndex]);
      strokeWeight(2);    
      float dist = sqrt(pow(point.x,2) + pow(point.y,2));
      float rScale = map(dist, 0, 400, 0, 40); 
      
      int r = (int)(noise(count*sizeNoiseScale)*rScale);//random(10);
      strokeWeight(random(5));    
      ellipse(point.x,  point.y, r, r);
    }
    x = (int)point.x;
    y = (int)point.y;
    count++;
  } while(count < numOfPoints);
  endShape();
  pop();
}

PVector getNewPoint(int x, int y) {
  int newX, newY;
  int randX, randY;

  randX = int(random(-randLimitX, randLimitX));
  randY = int(random(-randLimitY, randLimitY));

  newX = x - floor(epsilonX * y)+ randX;
  newY = y + floor(epsilonY * newX)+ randY;
  x = newX;
  y = newY;
  
  return new PVector(x, y);
}

void keyPressed() {
  print(key);
  if(key == 's') {
   Timestamp timestamp = new Timestamp(System.currentTimeMillis());
   save(timestamp+".png");
  }
  if(key == 'c') {
    background(bg);
    drawShape(cX, cY, false);
  }
}

void draw() {}

//todo одновременно рисовать несколько кругов с разными эпсилон разными цветами
//todo расстояние от центра влияет, например, на насыщенность цвета
