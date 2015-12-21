/***************************************************
 *  The Pritzker Architecture Prize Visualization
 *  Created by David Jan Mercado 2015 
 *  www.davidjanmercado.com
 ***************************************************/

//color[]  dessert = {#9F9694, #791F33, #BA3D49, #F1E6D4, #E2E1DC};
// {bg, graph, highlight, text, sub1, sub2}
color[] archi = {#131512, #F2771F, #F7F3F0, #EAEAEA, #D3D3D3, #FF8C3A};
color[] palette = archi;
PFont titleFont, labelFont, nameFont, scriptFont, yearFont;

Table pdata;
int rowCount;
float mx = 30, my = 30;
int d = 6;

Table schooldata;
int schoolCount;

Table countrydata;
int countryCount;

int width = 1000;
int height = 450;

int graphWidth = 700;
int graphHeight = 500;

// Real values
float minX = 0;
float maxX = 40;
float minY = 0;
float maxY = 110;

// Values to map to (size of graph)
int originX = 400; // 50
int originY = (int)(graphHeight/2);
int endX = width-40;
int endY = 50;

// Image positions
int imgX = 20;
int imgY = 50;

// Text positions (name)
int textX = imgX;
int textY = imgY + 225;

// School axis
float schoolOriginY = originY + 120;
float schoolEndY = schoolOriginY + 5;

PImage[] webimg;
PImage defaultimg;
String url;
int imgScaleFactor = 3;

// country stacked bar
int barheight = 5;

void setup() {
  size(width, height);
  pdata = new Table("pritzker.txt");
  rowCount = pdata.getRowCount();

  schooldata = new Table("archischools.txt");
  schoolCount = schooldata.getRowCount(); 
  
  countrydata = new Table("countries.txt");
  countryCount = countrydata.getRowCount();

  titleFont = loadFont("HelveticaNeueCE-Bold-20.vlw");
  labelFont = loadFont("HelveticaNeue-10.vlw");
  nameFont = loadFont("HelveticaNeueCE-Thin-18.vlw");
  smooth();
  
  // Load all images
  loadImages();
  
  noCursor();
  //noLoop();
  
  // Frame
  frame.setTitle("The Pritzker Architecture Prize Visualization by David Jan Mercado");
}

void draw() {
  background(palette[0]);

  // Map data
  drawAveLine();
  drawAxis();
  drawData();
  drawSchoolAxis();
  drawCountry();

  // Cursor
  fill(palette[3]);
  ellipse(mx, my, 4, 4);
  
  //saveFrame();
}

void drawData() {
  // Draw default image
  image(defaultimg, imgX, imgY, defaultimg.width/imgScaleFactor, defaultimg.height/imgScaleFactor);
  textAlign(LEFT);
  textFont(titleFont);
  fill(palette[3], 100.0);
  strokeWeight(0.5);
  stroke(palette[3], 100.0);
  text("The Pritzker Architecture Prize", textX, textY);
  //line(textX, textY+10, (int)(defaultimg.width/imgScaleFactor), textY+10);
  
  textFont(labelFont);
  
  for (int row = 1; row < rowCount; row++) {
    // Age v Name graph
    float year = pdata.getFloat(row, 0);
    float age = pdata.getFloat(row, 4);
    String name = pdata.getString(row, 1);
    String birth = pdata.getString(row, 5);
    String death = pdata.getString(row, 6);
    float x = map(row, minX, maxX, originX, endX);
    float y = map(age, minY, maxY, originY, endY);

    // Stem
    stroke(palette[1]);
    strokeWeight(0.8);
    line(x, y, x, originY);

    // Solid fill
    noStroke();
    fill(palette[3]);
    ellipse(x, y, d, d);

    // Ellipse around fill
    stroke(palette[2]);
    strokeWeight(0.8);
    noFill();

    // School v Name graph
    // You gotta know the x of the school
    // Draw a line from xy name to xy school
    String pCode = pdata.getString(row, 7);

    // Store pcode in an array after splitting
    String[] pcodeArr = splitTokens(pCode, ",");
    int pcodeArrLen = pcodeArr.length;
    
    // For each code in the array, map it to the schools
    for (int iarray = 0; iarray < pcodeArrLen; iarray++) {
      // Remove the trailing " in first and last items
      if (pcodeArrLen > 1) {
        pcodeArr[0] = pcodeArr[0].substring(1);
        pcodeArr[pcodeArrLen-1] = pcodeArr[pcodeArrLen-1].substring(0, 3);
      }

      // For each pCode, run through all scode
      for (int sRow = 1; sRow < schoolCount; sRow++) {
        String sCode = schooldata.getString(sRow, 0);
        String sName = schooldata.getString(sRow, 1);
        
        // If there's a match, map the two and draw a curve
        if (pcodeArr[iarray].equals(sCode)) {
          // Initial color if mouse is not within range
          stroke(palette[1]);
          strokeWeight(0.2);
          float sX = map(sRow, 0, schoolCount, originX, endX);

          // Show connection when mouse hovers over school ellipse
          if ((dist(sX, schoolOriginY, mx, my) < 5)) {
            showConnection(x, y);
          }

          // Show the data for each stem
          if ((mx > originX) && (mx < endX) && (my < originY) && (my > endY) && (my > y)) {
            
            // If the mouse is within the stem i.e. the y
            if ((abs(mx - x) < 4)) {
              showConnection(x, y);
              
              // Create the dashed line from year to age
              strokeWeight(0.6);
              patternLine((int)x, (int)y, originX, (int)y, 0x5555, 5);
              
              // Draw image and name of laureate
              image(webimg[row], imgX, imgY, webimg[row].width/imgScaleFactor, webimg[row].height/imgScaleFactor);
              textAlign(LEFT);
              
              fill(palette[3]);
              textFont(nameFont);
              if (!death.equals("na")) {
                text(name + " (" + birth + " - " + death + ")", textX, textY+35);
              } else {
                text(name + " (" + birth + ")", textX, textY+35);
              }
              textFont(nameFont);
              text(nf(year, 4, 0) + " Laureate", textX, textY+60);
              
              noFill();
              
              // Draw the age on top of the ellipse
              textFont(labelFont);
              textAlign(CENTER);
              text(nf(age, 2, 0), x, y-15);

              // Display the name of the school
              textAlign(CENTER);
              
              // If it's not Tadao Ando. Not a good practice to hardcode but his case is an exception
              if (row != 18) {
                // Exception for rightmost school
                if (sName.equals("Southern California Institute of Architecture") ||
                    sName.equals("University of Manchester")) { textAlign(RIGHT); }
                  
                // Display the name of the laureate
                switch(iarray) {
                  case 0:
                    text(sName, sX, schoolOriginY+30);
                    patternLine((int)sX, (int)schoolOriginY, (int)sX, (int)schoolOriginY+20, 0x5555, 2);
                    break;
                  case 1:
                    text(sName, sX, schoolOriginY+40);
                    patternLine((int)sX, (int)schoolOriginY, (int)sX, (int)schoolOriginY+30, 0x5555, 2);
                    break;
                  case 2:
                    text(sName, sX, schoolOriginY+50);
                    patternLine((int)sX, (int)schoolOriginY, (int)sX, (int)schoolOriginY+40, 0x5555, 2);
                    break;
                }
              }
            }
          }
          // Again, if not Tadao Ando.
          if (row != 18) {
            // Highlight the school to architect connection
            if ((dist(sX, schoolOriginY, mx, my) < 5)) {
              stroke(palette[2]);
              strokeWeight(0.5);
              writeVerticalText((int)x+4, (int)y-15, name);
            }
            // Note on bezier curves
            // second control point - half in y, end point)
            // the control point is basically where you're pulling it from
            bezier(x, originY, x, originY+60, sX, schoolOriginY-80, sX, schoolOriginY);
          }
        }
      }
    }
  }
}

void drawAxis() {
  // X-axis
  stroke(palette[1]);
  strokeWeight(1.5);
  line(originX, originY, endX, originY);

  // Y-axis
  stroke(palette[1]);
  strokeWeight(0.8);

  // Loop for the line
  for (float i = minY; i < maxY; i += 10) {
    float y = map(i, minY, maxY, originY, endY);
    line(originX-3, y, originX, y);
  }

  // Loop for the text
  for (float i = minY; i < maxY; i += 20) {
    float y = map(i, minY, maxY, originY, endY);
    line(originX-5, y, originX, y);
    textFont(labelFont);
    textAlign(LEFT);
    text(nf(i, 2, 0), originX-25, y);
  }
}

void drawAveLine() {
  int ave = 0;
  for (int row = 0; row < rowCount; row++) {
    float age = pdata.getFloat(row, 4);
    ave += age;
  }
  
  ave = ave/rowCount;
  float avemap = map(ave, minY, maxY, originY, endY);
  stroke(palette[3]);
  fill(palette[3], 30.0);
  strokeWeight(0.1);
  line(originX, avemap, endX, avemap);
  fill(palette[3], 100.0); // Revert
  
  // Display average line
  if (abs(my - avemap) < 4) {
    textAlign(LEFT);
    strokeWeight(1);
    text("Ave.\nAge:", originX-50, avemap);
    text(nf(ave, 2, 0), originX-50, avemap+25);
  }
}

void drawSchoolAxis() {
  stroke(palette[2]);
  strokeWeight(0.8);

  for (int row = 2; row < schoolCount; row++) {
    float x = map(row, 0, schoolCount, originX, endX);
    float count = schooldata.getFloat(row, 3);
    String schoolname = schooldata.getString(row, 1);

    // Adjust the stroke weight based on school count
    int scaleCount = (int)count+1;
    strokeWeight(scaleCount);
    ellipse(x, schoolOriginY, scaleCount, scaleCount);
    
    // If mouse hovers the school
    if (dist(x, schoolOriginY, mx, my) < scaleCount+2) {
      strokeWeight(0.6);
      textAlign(CENTER);
      if (schoolname.equals("Southern California Institute of Architecture") ||
          schoolname.equals("University of Manchester")) { textAlign(RIGHT); }
      patternLine((int)x, (int)schoolOriginY, (int)x, (int)schoolOriginY+20, 0x5555, 2);
      text(schoolname, x, schoolOriginY+30);
    }
  }
}

void drawCountry() {
  float[] stackedBar = new float[countryCount];
  
  noStroke();
  textAlign(LEFT);
  
  // Get the normal mapping
  for (int row = 0; row < countryCount; row++) {
    String countryname = countrydata.getString(row, 0);
    float count = countrydata.getFloat(row, 1);
    float x = map(count, 0, 9, 0, width); // 9 is the maxcount in the countrydata 
    float y = map(row, 0, countryCount, 0, height);
    stackedBar[row] = x;
  }
  
  // Get the sum of the items in the array
  int sum = getSum(stackedBar, countryCount);
  
  // Map the 'normals' to a new scale
  int prevX = 0;
  for (int row = 1; row < countryCount; row++) {
    
    if (row%2 == 0) { fill(palette[5]); } else { fill(palette[4]); }
    float x = map(stackedBar[row], 0, sum, 0, width);
    float y = map(row, 0, countryCount, 0, height);
    rect(prevX, height-barheight, (int)x, barheight);
    
    // Show the country name
    String countryname = countrydata.getString(row, 0);
    
    if (my > (height-barheight)) {
      if ((mx >= prevX) && (dist(prevX, height-barheight, mx, my) < x)) {
        
        // Show thin line on top of the selected name
        fill(palette[2]);
        noStroke();
        rect(prevX, height-23, (int)x, 0.5);
        
        // Show the name
        fill(palette[3]);
        if (countryname.equals("Australia")) { textAlign(RIGHT); prevX+=20; }
        text(countryname, prevX, height - 10);
        
        // For every country in countries.txt, check if it matches the nationality in pritzker.txt
        for(int nRow = 1; nRow < rowCount; nRow++) {
          String nationality = pdata.getString(nRow, 3);
          float year = pdata.getFloat(nRow, 0);
          float age = pdata.getFloat(nRow, 4);
          float nX = map(nRow, minX, maxX, originX, endX);
          float nY = map(age, minY, maxY, originY, endY);
          
          if(countryname.equals(nationality)) {
            // Highlight and display the names
            String name = pdata.getString(nRow, 1);
            showConnection(nX, nY);
          
            stroke(palette[3]);
            strokeWeight(0.5);
            writeVerticalText((int)nX+4, (int)nY-15, name);
              
            noStroke();
          }
        }
      }
    }
    prevX += x;
  }
}

int getSum(float[] array, int count) {
  int sum = 0;
  for (int i = 0; i < count; i++) {
    sum += array[i];
  }
  return sum;
}

void showConnection(float x, float y) {
  // Ellipse around fill gets larger
  stroke(palette[2]);
  strokeWeight(0.8);
  noFill();
  ellipse(x, y, d+10, d+10);
                
  // Stem changes color
  stroke(palette[2]);
  strokeWeight(0.8);
  line(x, y, x, originY);
}

void loadImages() {
  
  // Show laureate photo
  defaultimg = loadImage("http://www.pritzkerprize.com/sites/default/files/splash_images/bg_home_3.jpg", "jpg");
  webimg = new PImage[rowCount];
  int year = 1979;
  for (int i = 1; i < rowCount; i++) {
    url = "http://www.pritzkerprize.com/sites/default/files/" + year + "-p-lg.jpg";
    //println(url);
    if (year == 1988) {
      String url1 = "http://www.pritzkerprize.com/sites/default/files/" + year + "b-p-lg.jpg";
      String url2 = "http://www.pritzkerprize.com/sites/default/files/" + year + "a-p-lg.jpg";
      webimg[i] = loadImage(url1, "jpg");
      webimg[i+1] = loadImage(url2, "jpg");
      i+=1;
      //println(url1);
      //println(url2);
    } else if (year == 2001 || year == 2010) {
      String url1 = "http://www.pritzkerprize.com/sites/default/files/" + year + "-p-lg.jpg";
      String url2 = "http://www.pritzkerprize.com/sites/default/files/" + year + "-p-lg.jpg";
      webimg[i] = loadImage(url1, "jpg");
      webimg[i+1] = loadImage(url2, "jpg");
      i+=1;
      //println(url1);
      //println(url2);
    } else if (year == 2015) {
      url = "http://www.pritzkerprize.com/sites/default/files/649027_" + year + "-p-lg-vs2.jpg";
      webimg[i] = loadImage(url, "jpg");
      //println(url);
    } else {
      webimg[i] = loadImage(url, "jpg");
      //println(url);
    }
    year++;
  }
}

void mouseMoved() {
  mx = mouseX;
  my = mouseY;
}

// Write the text vertically
void writeVerticalText(int x, int y, String text) {
  textAlign(LEFT);
  stroke(palette[3]);
  pushMatrix();
  translate(x, y);
  rotate(-HALF_PI);
  if (text.equals("Paulo Mendes da Rocha")) { text = "Paolo M. da Rocha"; }
  text(text, 0, 0);
  popMatrix();
}

// Code from processing.org, user schill
// based on Bresenham's algorithm from wikipedia
// http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
void patternLine(int xStart, int yStart, int xEnd, int yEnd, int linePattern, int lineScale) {
  stroke(palette[2]);
  int temp, yStep, x, y;
  int pattern = linePattern;
  int carry;
  int count = lineScale;

  boolean steep = (abs(yEnd - yStart) > abs(xEnd - xStart));
  if (steep == true) {
    temp = xStart;
    xStart = yStart;
    yStart = temp;
    temp = xEnd;
    xEnd = yEnd;
    yEnd = temp;
  }    
  if (xStart > xEnd) {
    temp = xStart;
    xStart = xEnd;
    xEnd = temp;
    temp = yStart;
    yStart = yEnd;
    yEnd = temp;
  }
  int deltaX = xEnd - xStart;
  int deltaY = abs(yEnd - yStart);
  int error = - (int)((deltaX + 1) / 2);

  y = yStart;
  if (yStart < yEnd) {
    yStep = 1;
  } else {
    yStep = -1;
  }
  for (x = xStart; x <= xEnd; x++) {
    if ((pattern & 1) == 1) {
      if (steep == true) {
        point(y, x);
      } else {
        point(x, y);
      }
      carry = 0x8000;
    } else {
      carry = 0;
    }  
    count--;
    if (count <= 0) {
      pattern = (pattern >> 1) + carry;
      count = lineScale;
    }
    error += deltaY;
    if (error >= 0) {
      y += yStep;
      error -= deltaX;
    }
  }
}

