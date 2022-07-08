class URect {
  PVector ul;
  PVector br;
  color col;
  float area;
  
  URect(PVector _ul, PVector _br) {
    ul = _ul;
    br = _br;
    setArea();
  }
  
  URect(float x1, float y1, float x2, float y2) {
    ul = new PVector(x1, y1);
    br = new PVector(x2, y2);
    setArea();
  }
  
  private void setArea() {
    area = abs((br.x-ul.x)*(br.y-ul.y));
  }
  
  void setColor(color _col) {
    col = _col;
  }
  
  void display() {
    rectMode(CORNERS);
    fill(col);
    
    rect(ul.x, ul.y, br.x, br.y);
  }
}
