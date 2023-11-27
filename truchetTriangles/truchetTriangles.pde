// converted from python by dan@marginallyclever.com 2023-11-27
// based on work by https://www.reddit.com/user/henryfrgu
int border = 150;
color backC = color(255);
color lineC = color(0);

class Triangle {
  PVector [] p = new PVector[3];
  int a;
  int b;
  
  Triangle() {
    for(int i=0;i<3;++i) {
      p[i]= new PVector();
    }
  }
  Triangle(PVector p0, PVector p1,PVector p2,int a,int b) {
    p[0]=p0;
    p[1]=p1;
    p[2]=p2;
    this.a=a;
    this.b=b;
  }
};

ArrayList<Triangle> finalTri = new ArrayList<Triangle>();
ArrayList<Triangle> tri = new ArrayList<Triangle>();
int iteration = 0;

int minLines;  // per sweep
int maxLines;  // per sweep 
float lineSpacing;
float weight; 
int minRecurs; 
int maxRecurs; 
int splitChance;


void setup() {
  size(1000,1000);
}
    
void draw() {
    background(backC);
    pushMatrix();
    translate(width/2,height/2);
    rotate(PI/6);
    minRecurs = (int)random(2);
    maxRecurs = (int)random(minRecurs+2,6);
    splitChance = (int)random(10,80);
    if( maxRecurs == 5) {
        minLines = 2;
    } else if( maxRecurs == 4) {
        minLines = (int)random(3,5);
    } else if( maxRecurs == 3) {
        minLines = (int)random(3,6);
    } else {
        minLines = (int)random(3,7);
    }
    maxLines = int(pow(2,maxRecurs)) * minLines;
    lineSpacing = float(width - 2*border) / 2 / maxLines;
    weight = lineSpacing/2;
    finalTri.clear();
    tri = createTriGrid();
    triRecursion();
    tri = finalTri;
    for(int i=0;i<tri.size();++i) {
        truchet(tri.get(i));
    }
    drawBorder();
    popMatrix();
    if( iteration != 0) {
        delay(2000);
    }
    iteration++;
}

ArrayList<Triangle> createTriGrid() {
    ArrayList<Triangle> list = new ArrayList<Triangle>();
    
    float triBase = (width - 2 * float(border)) / 2;
    float triHeight = sin(THIRD_PI) * triBase;
    float startX = -triBase;
    float startY = 0;
    
    list.add(new Triangle(
      new PVector(startX,startY),
      new PVector(startX+triBase,startY),
      new PVector(startX+triBase/2,startY-triHeight),
      0,maxLines));
    list.add(new Triangle(
      new PVector(startX+triBase/2,startY-triHeight),
      new PVector(startX+3*triBase/2,startY-triHeight),
      new PVector(startX+triBase,startY),
      1,maxLines));
    list.add(new Triangle(
      new PVector(startX+triBase,startY),
      new PVector(startX+2*triBase,startY),
      new PVector(startX+3*triBase/2,startY-triHeight),
      0,maxLines));
    
    list.add(new Triangle(
      new PVector(startX,startY),
      new PVector(startX+triBase,startY),
      new PVector(startX+triBase/2,startY+triHeight),
      1,maxLines));
    list.add(new Triangle(
      new PVector(startX+triBase/2,startY+triHeight),
      new PVector(startX+3*triBase/2,startY+triHeight),
      new PVector(startX+triBase,startY),
      0,maxLines));
    list.add(new Triangle(
      new PVector(startX+triBase,startY),
      new PVector(startX+2*triBase,startY),
      new PVector(startX+3*triBase/2,startY+triHeight),
      1,maxLines));
    
    return list;
}

/**
 * recursively split triangles.
 */
void triRecursion() {
    for(int i=0;i< maxRecurs;++i) {
        ArrayList<Triangle> holder = new ArrayList<Triangle>();
        
        if( i < minRecurs) {
            for(int j=0;j<tri.size();++j) {
                holder.addAll(splitTri(tri.get(j)));
            }
        } else {
          for(int j=0;j<tri.size();++j) {
              if( random(100) < splitChance) {
                  holder.addAll(splitTri(tri.get(j)));
              } else {
                  holder.add(tri.get(j));
              }
          }
        }
        tri = holder;
    }
    finalTri.addAll(tri);
}

/**
 * Split triangle into 4 smaller triangles.
 */
ArrayList<Triangle> splitTri(Triangle t) {
    ArrayList<Triangle> list = new ArrayList<Triangle>();
    PVector p0 = t.p[0];
    PVector p1 = t.p[1];
    PVector p2 = t.p[2];
    
    list.add(new Triangle(
        p0,
        PVector.lerp(p0,p1,0.5),
        PVector.lerp(p0,p2,0.5),
        t.a,t.b/2));
    list.add(new Triangle(
        PVector.lerp(p0,p1,0.5),
        p1,
        PVector.lerp(p2,p1,0.5),
        t.a,t.b/2));
    list.add(new Triangle(
        PVector.lerp(p0,p2,0.5),
        PVector.lerp(p2,p1,0.5),
        p2,
        t.a,t.b/2));
    list.add(new Triangle(
        PVector.lerp(p0,p2,0.5),
        PVector.lerp(p2,p1,0.5),
        PVector.lerp(p0,p1,0.5),
        (t.a+1)%2,t.b/2));
    return list;
}

/**
 * draw one triangle truchet tile
 */
void truchet(Triangle t) {
    int startPt = (int)random(3);
    int n = (int)floor(cos(PI/6) * t.b);
    if( n*lineSpacing+weight/1.2 >= cos(PI/6)*PVector.dist(t.p[0],t.p[1])) {
        n -= 1;
    }
    int m = t.b - n;
    int p1 = (int)random(m,n+1);
    int p2 = t.b - p1;
    if( p1 < p2) {
        p1 += 1;
    } else if( p2 < p1) {
        p2 += 1;
    }
    
    float a1, a2;
    
    for(int i=0;i<3;++i) {
        fill(backC);
        stroke(lineC);
        strokeWeight(weight);
        strokeCap(ROUND);
        if( t.a == 1) {
            int v=(startPt+i)%3;
            a1 = (v*2+0)*PI/3;
            a2 = (v*2+1)*PI/3;
        } else {
            int v=2-(startPt+i)%3;
            a1 = (v*2+1)*PI/3;
            a2 = (v*2+2)*PI/3;
        }
        if( i < 2) {
            for(int j=0;j<n;++j) {
                float r = (n-j) * lineSpacing;
                arc(t.p[(startPt+i)%3].x,t.p[(startPt+i)%3].y,2*r,2*r,a1,a2);
            }
        } else {
            for(int j=0;j<min(p1,p2);++j) {
                float r = (min(p1,p2)-j) * lineSpacing;
                arc(t.p[(startPt+i)%3].x,t.p[(startPt+i)%3].y,2*r,2*r,a1,a2);
            }
        }
        fill(lineC);
        noStroke();
        circle(t.p[(startPt+i)%3].x,t.p[(startPt+i)%3].y,weight);
    }
}

/**
 * draw sweeps outside of the hexagon
 */
void drawBorder() {
    int minBL = 1;
    int maxBL = (int) pow(2,maxRecurs-2)*minLines;
    if( maxBL <= 2) {
        maxBL = 3;
    }
    int maxCA = floor(maxLines/12);
    if(maxCA <= 1) {
        maxCA = 2;
    }
    int [] cornerArcs = new int[6];
    if( maxRecurs == 2) {
        for(int i=0;i<6;++i) cornerArcs[i] = i;
    } else {
        for(int i=0;i<6;++i) cornerArcs[i] = 2*(int)random(1,maxCA);
    }
    float [] angles = new float[6];
    for(int i=0;i<6;++i) angles[i] = 4*PI/3+i*PI/3;
    
    for(int i=0;i<6;++i) {
        fill(backC);
        stroke(lineC);
        strokeWeight(weight);
        // arcs outside of hexagon, on corners?
        for(int j=0;j<cornerArcs[i];++j) {
            arc(cos(i*PI/3)*(width/2-border),
                sin(i*PI/3)*(width/2-border),
                2*(cornerArcs[i]-j)*lineSpacing,
                2*(cornerArcs[i]-j)*lineSpacing,
                angles[i],
                angles[i]+4*PI/3);
        }
        // arcs outside of hexagon, in middle of each hexagon edge
        int n = cornerArcs[i];
        while( n < maxLines - cornerArcs[(i+1)%6]) {
            fill(backC);
            stroke(lineC);
            strokeWeight(weight);
            int arcs = (int)random(minBL,maxBL);
            while( n + 2 * arcs > maxLines - cornerArcs[(i+1)%6]) {
                arcs = (int)random(minBL,maxBL);
            }
            float x = cos(i*PI/3) * (width/2-border) + cos((2+i)*PI/3) * lineSpacing * (arcs+n);
            float y = sin(i*PI/3) * (width/2-border) + sin((2+i)*PI/3) * lineSpacing * (arcs+n);
            for(int j=0;j<arcs;++j) {
                arc(x,
                    y,
                    2*(arcs-j)*lineSpacing,
                    2*(arcs-j)*lineSpacing,
                    angles[(i+1)%6],
                    angles[(i+1)%6]+PI);
            }
            fill(lineC);
            noStroke();
            circle(x,y,weight);
            n += 2 * arcs;
        }
        // points on corners
        fill(lineC);
        noStroke();
        circle(cos(i*PI/3)*(width/2-border),
               sin(i*PI/3)*(width/2-border),
               weight);
    }
}
