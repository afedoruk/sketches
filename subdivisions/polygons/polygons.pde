import java.util.*;

color bg = #253446;

int excentr = 1;

ArrayList<PVector> verts =  new ArrayList<PVector>();
ArrayList<Polygon> polys =  new ArrayList<Polygon>();

int NUM_OF_INITIAL_VERTICES = 12;

void setup() {
  size(800, 800);
  background(bg);
  float angle = 0;
  
  for(int i =0; i<NUM_OF_INITIAL_VERTICES; i++) {
    //angle += random(0, 360/NUM_OF_INITIAL_VERICES);
    angle += 360/NUM_OF_INITIAL_VERTICES + random(-10, 10);
    float distance = random(200, width/2);
    
    verts.add(new PVector( width/2 + random(-excentr, excentr) + distance * cos(radians(angle)),  height/2  + random(-excentr, excentr) + distance * sin(radians(angle))));
  }
  Polygon initialPoly = new Polygon(new PVector(0, 0), verts);
  initialPoly.display();
  polys.add(initialPoly);
}

void draw() {
}

void mouseClicked() {
  ArrayList<Polygon> newPolys = new ArrayList<Polygon>();
  for (Polygon poly: polys)  {
    
    float chanceToDivide = random(poly.area);
    if(chanceToDivide > 1000) {
      newPolys.addAll(poly.divide());
    } else {
      newPolys.add(poly);
    }
  }
  background(bg);
  for(Polygon newPoly:newPolys) {
      newPoly.display();
  }
  
  polys.clear();
  polys.addAll(newPolys);
}

void keyPressed() {
  if(key == 's') {
    saveImage();
  }
}

void saveImage() {
  String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  saveFrame("frames/"+timestamp+".png");
}
