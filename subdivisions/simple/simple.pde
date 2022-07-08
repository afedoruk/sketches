int DEPTH = 12;
int wiggle = 5;

//color[] pallete = {#03071e, #370617, #6a040f, #9d0208, #d00000, #dc2f02, #e85d04, #f48c06, #faa307, #ffba08};
color[] pallete = {#9d0208, #d00000, #dc2f02, #e85d04, #f48c06, #faa307, #ffba08, #03071e, #370617, #6a040f};
//color[] pallete = {#d9ed92, #b5e48c, #99d98c, #76c893, #52b69a, #34a0a4, #168aad, #1a759f, #1e6091, #184e77};
//color[] pallete = {#f72585, #7209b7, #3a0ca3, #4361ee, #4cc9f0};

ArrayList<URect> rects =  new ArrayList<URect>();

void setup() {
  size(800, 800);
  background(0);
  doEverything();
  
  println(rects.size());
}

void draw() {
}

void doEverything() {
  divide(new PVector(10, 10), new PVector(width-10, height-10), 0);
  float maxarea = rects.get(0).area, minarea = rects.get(0).area;
  for(URect item: rects) {
    maxarea = max(maxarea, item.area);
    minarea = min(minarea, item.area);
  }
  
  for(URect item: rects) {
    item.setColor(pickColor(map(item.area, minarea, maxarea, 0, 0.99)));
    item.display();
  }
}

void mouseClicked() {
  doEverything();
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

char getDirection(PVector ul, PVector br) {
  char direction = 'h';
  
  if(abs(br.x - ul.x) == abs(br.y-ul.y)) {
      if(random(-1,1) > 0) {
      direction = 'v';
    }
  }
  
  if(abs(br.x - ul.x) > abs(br.y-ul.y)) {
    direction = 'v';
  }
  
  return direction;
}

void divide(PVector ul, PVector br, int deep) {
  PVector new_br, new_ul;
   
  float k = random(0.2, 0.8);
  
  char direction = getDirection(ul, br);
  
  if(direction == 'v') {
    int borderX = floor(ul.x + (br.x - ul.x)*k);  
    new_br = new PVector(borderX, br.y);
    new_ul = new PVector(borderX, ul.y);
  } else {
    int borderY = floor(br.y + (ul.y - br.y)*k);  
    new_br = new PVector(br.x, borderY);
    new_ul = new PVector(ul.x, borderY);
  }
    
  deep++;
  
  if(deep < DEPTH) {
    divide(ul, new_br, deep);
    divide(new_ul, br, deep);
  } else {
    rects.add(new URect(ul.x + random(-wiggle, wiggle), ul.y + random(-wiggle, wiggle), new_br.x + random(-wiggle, wiggle), new_br.y + random(-wiggle, wiggle)));
    rects.add(new URect(new_ul.x + random(-wiggle, wiggle), new_ul.y + random(-wiggle, wiggle), br.x + random(-wiggle, wiggle), br.y + random(-wiggle, wiggle)));
  }
}

color pickColor(float k) {
  int s = pallete.length;
  int ind = (int)map(k, 0, 1, 0, s);
  color col = pallete[ind];
  return col;
}
