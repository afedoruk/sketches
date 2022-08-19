import java.util.Map;

class Polygon {
  ArrayList<PVector> verts =  new ArrayList<PVector>();
  PVector pivot;
  PShape shape;
  float area;
  boolean immune = false;
  
  Polygon(PVector _pivot, ArrayList<PVector> _verts) {
    pivot = _pivot;
    verts = _verts;
    area = getArea();
    if(random(100) > 95) {
      immune = true;
    }
  }
  
  void display() {
    shape = createShape();
    shape.beginShape();
    //shape.fill((int)random(0,255));
    shape.noFill();
    shape.stroke(bg);
    shape.fill(#637987);
    shape.strokeWeight(map(constrain(area, 400, 1000), 400, 1000, 2, 10));
    //shape.noStroke();
    for(PVector vertex: verts) {
      shape.vertex(vertex.x, vertex.y);
      //println(vertex.x, " ", vertex.y);
    }
    shape.endShape(CLOSE);
    shape(shape, pivot.x, pivot.y);
    //fill(random(200), random(200), random(200));
    //for(int i=0; i < verts.size(); i++) {
    //  text(i, verts.get(i).x+random(20), verts.get(i).y+random(20)); 
    //}
  }
  
  void display2() {
   // display();
    beginShape();
    //shape.fill((int)random(0,255));
    strokeWeight(1);
    
    stroke(bg);
    fill(#637987);
    
    ArrayList<PVector> curvedVerts = new ArrayList<PVector>(); 
    
    for(int i=0; i < verts.size(); i++) {
      PVector edge = PVector.sub(verts.get(getNextVert(i)), verts.get(i));
     // curvedVerts.add(PVector.add(verts.get(i), PVector.mult(edge, 0.3)));
      curvedVerts.add(PVector.add(verts.get(i), PVector.mult(edge, random(0.3, 0.4))));
    }
    
    curveVertex(curvedVerts.get(curvedVerts.size()-1).x, curvedVerts.get(curvedVerts.size()-1).y);
    for(PVector vertex: curvedVerts) {
      curveVertex(vertex.x, vertex.y);
      
    }
    curveVertex(curvedVerts.get(0).x, curvedVerts.get(0).y);
    curveVertex(curvedVerts.get(1).x, curvedVerts.get(1).y);
    endShape(CLOSE);
  }
  
  int getNumOfMostLengthEdge() {
    float maxDist=0;
    int num = 0;
    for(int i=0; i < verts.size(); i++) {
      float dist = verts.get(i).dist(verts.get(getNextVert(i)));
      if(dist > maxDist) {
        maxDist = dist;
        num = i;
      }
    }
    
    return num;
  }
  
  ArrayList<Polygon> divide() {
    int startVertexNum1, endVertexNum1;
    PVector pInt = null;
    
    IntList edgenums = new IntList();
    
    for(int i=0; i < verts.size(); i++) {
      edgenums.append(i);
    }
    
    // 1. выбрать случайную грань
    //int edgeNum1 = edgenums.get((int) random(edgenums.size()));
    int edgeNum1 = getNumOfMostLengthEdge();
    startVertexNum1 = edgeNum1;
    endVertexNum1 = getNextVert(startVertexNum1);
    //println("Initial edge: ", edgeNum1, " ", startVertexNum1," ", endVertexNum1);
    
    PVector startPoint1 = getRandomPointOnEdge(verts.get(endVertexNum1), verts.get(startVertexNum1));
    PVector perpPoint1 = getPerpPoint(verts.get(startVertexNum1), startPoint1);
    
    PVector curPInt;
    for(int i=0; i < verts.size(); i++) {
      if(i == edgeNum1) {
        continue;
      }
      curPInt = findIntersection(startPoint1, perpPoint1, verts.get(i), verts.get(getNextVert(i)));
      if(curPInt!=null) {
        if(pInt == null) {
          pInt = curPInt;
        }
        if(PVector.dist(startPoint1, curPInt) < PVector.dist(startPoint1, pInt)) {
          pInt = curPInt;
        }
      }
      //в невыпуклом прямоугольнике может быть несклько пересечений, надо будет выбрать самое близкое
    }
    
    
    //newEdges используется для кейса, когда мы оставляем все грани
    //edgesToChose - когда хотим выбрать только одну
    HashMap<Integer, Edge> newEdges = new HashMap<Integer, Edge>();
    HashMap<Integer, Edge> edgesToChose = new HashMap<Integer, Edge>();
    Edge initialEdge = new Edge(new PVector(0,0), new PVector(0,0));
    
    if(pInt!=null) {
      PVector pivotPoint = getRandomPointOnEdge(startPoint1, pInt);
      //line(startPoint1.x, startPoint1.y, pivotPoint.x, pivotPoint.y);
      //ellipse(pivotPoint.x, pivotPoint.y, 5, 5);
      
      initialEdge = new Edge(startPoint1, pivotPoint);
      newEdges.put(edgeNum1, initialEdge);
      
      
      for(int i=0; i < verts.size(); i++) {
        if(i == edgeNum1) {
          continue;
        }
        int nextVert = getNextVert(i);
        PVector potentEnd = getPointProjection(pivotPoint, verts.get(i), verts.get(nextVert));
        if(potentEnd != null) {
          newEdges.put(i, new Edge(potentEnd, pivotPoint));
          edgesToChose.put(i, new Edge(potentEnd, pivotPoint));
        } else {
          //println(i, "-", nextVert, " No potent end");
        }
      }
    }
    
    //выбираем с самым тупым углом
    float ang = 0;
    int eN = 0;
    for (Map.Entry me : edgesToChose.entrySet()) {
      float ca = PVector.angleBetween(
        ((Edge)me.getValue()).getVector(),
        initialEdge.getVector()
      );
      if(ca > ang) {
        ang = ca;
        eN = (int)me.getKey();
      }
    }
    
    HashMap<Integer, Edge> chosenEdges = new HashMap<Integer, Edge>();
    chosenEdges.put(edgeNum1, initialEdge);
    chosenEdges.put(eN, newEdges.get(eN));
    
    //return makePolygons(newEdges);
    return makePolygons(chosenEdges);
  }
  
  ArrayList<Polygon> makePolygons(HashMap<Integer, Edge> edges) {
    ArrayList<Polygon> newPolys = new ArrayList<Polygon>();
    for (Map.Entry me : edges.entrySet()) {
      ArrayList<PVector> newVertices = new ArrayList<PVector>();
      
      //добавляем саму новую грань
      newVertices.add(((Edge)me.getValue()).end);
      newVertices.add(((Edge)me.getValue()).start);
      
      //добавляем следующую точку
      int curVertNum = getNextVert((int)me.getKey());
      newVertices.add(verts.get(curVertNum));
      
      while(!edges.containsKey(curVertNum)) {
        curVertNum = getNextVert(curVertNum);
        newVertices.add(verts.get(curVertNum));
      }
      newVertices.add(edges.get(curVertNum).start);
      Polygon newPoly = new Polygon(new PVector(0, 0), newVertices);
      
      newPolys.add(newPoly);
    }

    return newPolys;
  }
  
  
  int getNextVert(int i) {
    return i >= verts.size()-1 ? 0 : i+1;
  }
  
   PVector getPointProjection(PVector thePoint, PVector start, PVector end) {
     float aOrig = (start.y-end.y)/(start.x - end.x);
     float aPerm = -(1/aOrig);
     float sampleX1 = min(start.x, end.x) - 1;
     float sampleY1 = aPerm*(sampleX1 - thePoint.x) + thePoint.y;
     float sampleX2 = max(start.x, end.x) + 1;;
     float sampleY2 = aPerm*(sampleX2 - thePoint.x) + thePoint.y;
     
     return findIntersection(start, end, new PVector(sampleX1, sampleY1), new PVector(sampleX2, sampleY2));
   }
  
   PVector getRandomPointOnEdge(PVector start, PVector end) {
     PVector dividedEdge = PVector.sub(end, start);
     return PVector.add(start, dividedEdge.mult(random(0.1, 0.9))); 
   }
   
   PVector getPerpPoint(PVector p1, PVector p2) {
     float d = 800;
     float dist = PVector.dist(p1, p2);
     float cosAlpha = (p2.x-p1.x)/dist;
     float sinAlpha = (p1.y-p2.y)/dist;
     float newX = sinAlpha*d+p2.x;
     float newY = cosAlpha*d+p2.y;
     
     return new PVector(newX, newY);
   }
   
   PVector findIntersection(PVector start1, PVector end1, PVector start2, PVector end2) {
     float uA, uB;
     float d = ((end2.y - start2.y) * (end1.x - start1.x) - (end2.x - start2.x) * (end1.y - start1.y));
     if (d != 0) {
        uA = ((end2.x - start2.x) * (start1.y - start2.y) - (end2.y - start2.y) * (start1.x - start2.x)) / d;         
        uB = ((end1.x - start1.x) * (start1.y - start2.y) - (end1.y - start1.y) * (start1.x - start2.x)) / d;
    } else {
        return null;
    }
    if (0 > uA || uA > 1 || 0 > uB || uB > 1) {
      return null;
    }
    float x = start1.x + uA * (end1.x - start1.x);
    float y = start1.y + uA * (end1.y - start1.y);
    return new PVector(x, y);
   }
   
   float getArea() {
     float s1=0, s2=0;
     for(int i = 0; i < verts.size(); i++) {
       s1 += verts.get(i).x * verts.get(getNextVert(i)).y;
       s2 += verts.get(i).y * verts.get(getNextVert(i)).x;
     }
     
     return abs(s1-s2)/2;
   }
}
