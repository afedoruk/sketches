class Edge {
  PVector start;
  PVector end;
  Edge(PVector _start, PVector _end) {
    start = _start;
    end = _end;
  }
  
  PVector getVector() {
    return PVector.sub(end, start);
  }
}
