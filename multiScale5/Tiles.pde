void drawTile(int i,float tileWidth,color c0,color c1) {
  switch(i) {
    case 0: drawTile1(tileWidth,c0,c1);  break;
    case 1: drawTile2(tileWidth,c0,c1);  break;
    case 2: drawTile3(tileWidth,c0,c1);  break;
    case 3: drawTile4(tileWidth,c0,c1);  break;
    
    case 4: drawTile5(tileWidth,c0,c1);  break;
    case 5: drawTile6(tileWidth,c0,c1);  break;
    case 6: drawTile7(tileWidth,c0,c1);  break;
    case 7: drawTile8(tileWidth,c0,c1);  break;
    
    case 8: drawTile9(tileWidth,c0,c1);  break;
    case 9: drawTile10(tileWidth,c0,c1);  break;
    case 10: drawTile11(tileWidth,c0,c1);  break;
    case 11: drawTile12(tileWidth,c0,c1);  break;
    
    case 12: drawTile13(tileWidth,c0,c1);  break;
    case 13: drawTile14(tileWidth,c0,c1);  break;
    case 14: drawTile15(tileWidth,c0,c1);  break;
    default: throw new RuntimeException("invalid tile number");
  }
}


void drawTile1(float tileWidth,color c0,color c1) {
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;

  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  fill(c1);
  arc(tileWidth,0,twoThird*2,twoThird*2,HALF_PI,PI);  // north east
  arc(0,tileWidth,twoThird*2,twoThird*2,PI+HALF_PI,TWO_PI);  // southwest
  fill(c0);
  
  circle(0,0,twoThird);  // north west
  circle(tileWidth,0,twoThird);  // north east
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  popMatrix();
}


void drawTile2(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(90));
  drawTile1(tileWidth,c0,c1);
  popMatrix();
}


void drawTile3(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  circle(0,0,twoThird);  // north west
  circle(tileWidth,0,twoThird);  // north east
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  fill(c1);
  rect(0,third,tileWidth,third);
  circle(half,0,third);
  circle(half,tileWidth,third);
  popMatrix();
}

void drawTile4(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(90));
  drawTile3(tileWidth,c0,c1);
  popMatrix();
}

void drawTile5(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  circle(0,0,twoThird);  // north west
  circle(tileWidth,0,twoThird);  // north east
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  fill(c1);
  circle(half,0,third);  // north
  circle(half,tileWidth,third);  // south
  circle(tileWidth,half,third);  // east
  circle(0,half,third);  // west
  popMatrix();
}

void drawTile6(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c1);
  rect(0,0,tileWidth,tileWidth);
  circle(half,0,third);  // north
  circle(half,tileWidth,third);  // south
  circle(tileWidth,half,third);  // east
  circle(0,half,third);  // west
  fill(c0);
  circle(tileWidth,0,twoThird);
  circle(0,tileWidth,twoThird);
  circle(0,0,twoThird);
  circle(tileWidth,tileWidth,twoThird);
  popMatrix();
}

void drawTile7(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  circle(0,0,twoThird);  // north west
  circle(tileWidth,0,twoThird);  // north east
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  fill(c1);
  rect(0,third,tileWidth,third);
  rect(third,0,third,tileWidth);
  circle(half,0,third);  // north
  circle(half,tileWidth,third);  // south
  circle(tileWidth,half,third);  // east
  circle(0,half,third);  // west
  popMatrix();
}

void drawTile8(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  circle(0,0,twoThird);  // north west
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  fill(c1);
  circle(half,0,third);  // north
  circle(half,tileWidth,third);  // south
  circle(tileWidth,half,third);  // east
  circle(0,half,third);  // west
  fill(c1);
  arc(tileWidth,0,twoThird*2,twoThird*2,HALF_PI,PI);  // north east
  fill(c0);
  circle(tileWidth,0,twoThird);  // north east
  popMatrix();
}

void drawTile9(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(270));
  drawTile8(tileWidth,c0,c1);
  popMatrix();
}

void drawTile10(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(180));
  drawTile8(tileWidth,c0,c1);
  popMatrix();
}

void drawTile11(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(90));
  drawTile8(tileWidth,c0,c1);
  popMatrix();
}

void drawTile12(float tileWidth,color c0,color c1) {
  float third = tileWidth/3.0f;
  float twoThird = tileWidth*2.0f/3.0f;
  float half = tileWidth/2.0f;
  
  pushMatrix();
  translate(-half,-half);
  fill(c0);
  rect(0,0,tileWidth,tileWidth);
  circle(0,0,twoThird);  // north west
  circle(tileWidth,0,twoThird);  // north east
  circle(0,tileWidth,twoThird);  // south west
  circle(tileWidth,tileWidth,twoThird);  // south east
  fill(c1);
  rect(0,0,tileWidth,twoThird);
  fill(c0);
  arc(tileWidth,0,twoThird,twoThird,HALF_PI,PI);  // north east
  arc(0,0,twoThird,twoThird,0,HALF_PI);  // north west
  fill(c1);
  circle(half,0,third);  // north
  circle(half,tileWidth,third);  // south
  circle(tileWidth,half,third);  // east
  circle(0,half,third);  // west
  
  popMatrix();
}

void drawTile13(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(270));
  drawTile12(tileWidth,c0,c1);
  popMatrix();
}

void drawTile14(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(180));
  drawTile12(tileWidth,c0,c1);
  popMatrix();
}

void drawTile15(float tileWidth,color c0,color c1) {
  pushMatrix();
  rotate(radians(270));
  drawTile12(tileWidth,c0,c1);
  popMatrix();
}
