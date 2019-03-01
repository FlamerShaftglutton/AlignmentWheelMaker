int[][] damage;
String[][] justifications;
String[] names;

PVector[] spots;

ArrayList<Result> layouts;
int current_index;




void setup()
{
  size(800,800);
  
  //fill this in with your names
  names = new String[]{ "Fire", "Plant","Stone","Lisa Frank","Vacuum","Electricity","Water" };
  
  //just some initializers
  damage = new int[names.length][names.length];
  justifications = new String[names.length][names.length]; for (int i = 0; i < names.length; ++i) { for (int j = 0; j < names.length; ++j) justifications[i][j] = ""; }
  
  //replace these with your own rivalries
  add_rivalry("Fire","Plant",10,"Burns");
  add_rivalry("Fire","Lisa Frank",10,"Burns");
  add_rivalry("Plant","Stone",10,"Erodes");
  add_rivalry("Plant","Lisa Frank",3,"Dirty");
  add_rivalry("Plant","Vacuum",5,"Fills it");
  add_rivalry("Plant","Electricity",8,"Draws Power");
  add_rivalry("Plant","Water",10,"Drinks");
  add_rivalry("Stone","Fire",8,"Unburnable");
  add_rivalry("Stone","Lisa Frank",3,"Drab");
  add_rivalry("Stone","Vacuum",10,"Fills it");
  add_rivalry("Stone","Electricity",10,"Nonconductive");
  add_rivalry("Lisa Frank", "Plant", 3, "Use as paper");
  add_rivalry("Lisa Frank", "Stone", 10, "Prettier");
  add_rivalry("Lisa Frank", "Vacuum",10, "Antithesis");
  add_rivalry("Lisa Frank", "Electricity", 3, "Better Art");
  add_rivalry("Vacuum","Fire",10,"Extinguishes");
  add_rivalry("Vacuum","Plant",8,"Strangles");
  add_rivalry("Vacuum","Lisa Frank",10, "Antithesis");
  add_rivalry("Vacuum","Electricity",8, "Nonconductive");
  add_rivalry("Electricity","Plant",6,"High Water Content");
  add_rivalry("Electricity","Lisa Frank",6,"Lightning's cooler");
  add_rivalry("Electricity","Water",10,"Classic Zap-Zap");
  add_rivalry("Water","Fire",10,"Extinguishes");
  add_rivalry("Water","Stone",10,"Erodes");
  add_rivalry("Water","Lisa Frank",6,"Ruins colors");
  add_rivalry("Water","Vacuum",5, "Fills it");
  //theoretical maximum : 136
  
  //this does the actual work
  layouts = produce_layouts();
  
  //set the display to the best result
  current_index = layouts.size() - 1;
  
  //debug, prints how many results we got
  println(layouts.size());
  
  //center align text for the rest of the program
  textAlign(CENTER,CENTER);
  
  //precalculate the position of all the circles
  spots = new PVector[names.length];
  for (int i = 0; i < spots.length; ++i)
  {
    float ex = width / 2f;
    float ey = height / 2f;
    
    float dist_from_center = width * 27f / 64f;
    
    ex -= cos(-HALF_PI - TWO_PI * (float(i) / float(spots.length))) * dist_from_center;
    ey += sin(-HALF_PI - TWO_PI * (float(i) / float(spots.length))) * dist_from_center;
    
    spots[i] = new PVector(ex,ey);
  }
}




void add_rivalry(String from, String to, int level, String justification)
{
  //make a stringlist out of the names list since it gives us better search functionality
  StringList s = new StringList(names);
  
  //get the indices of the two names
  int from_index = s.index(from);
  int to_index = s.index(to);
  
  //basic error handling
  if (from_index < 0) println(from + " is not a valid name.");
  if (to_index < 0) println(to + " is not a valid name.");
  
  //update the damage and justification grids with the new values
  damage[from_index][to_index] = level;
  justifications[from_index][to_index] = justification;
}




void draw()
{
  background(200);
  
  textSize(36f);
  text("Schools of Magic", 160f, 24f);
  
  float circle_radius = 50f;
  
  textSize(16);
  
  Result r = layouts.get(current_index);
  for (int i = 0; i < r.layout.size(); ++i)
  {
    PVector p = spots[i];
    fill(255);
    stroke(0);
    strokeWeight(1);
    
    ellipse(p.x,p.y,2f * circle_radius, 2f * circle_radius);
    
    fill(0);
    text(names[r.layout.get(i)], p.x, p.y);
  }
  
  for (int i = 0; i < r.layout.size(); ++i)
  {
    PVector p = spots[i];//the current circle
    
    PVector p1 = spots[(i+1)%spots.length];//the next circle, clockwise
    PVector p2 = spots[(i+r.hops)%spots.length];//the other circle this spot attacks, as specified in the Result.hops
    
    draw_arrow(p, p1, circle_radius);
    draw_arrow(p, p2, circle_radius);
    
    draw_text_between(p, p1, justifications[r.layout.get(i)][r.layout.get((i+1) % spots.length)]);
    draw_text_between(p, p2, justifications[r.layout.get(i)][r.layout.get((i+r.hops) % spots.length)]);
  }
  
  text("Score: " + r.score, width * 0.9f, 24f);
}




void keyReleased()
{
  if (key == CODED && keyCode == UP)//if you press the UP arrow we move the display to the next layout, so better or equal than our current layout. It does wrap if you go too high, though.
    current_index = (current_index + 1) % layouts.size();
    
  else if (key == CODED && keyCode == DOWN)//if you press the DOWN arrow we move the display down to the previous layout, so worse or equal to our current layout. It does wrap if you go too low, though.
    current_index = (current_index + layouts.size() - 1) % layouts.size();
    
  else if (key == 's')//save a screenshot if you press the 's' key
    saveFrame("Screencap.png");
}




ArrayList<Result> produce_layouts()
{
  //first get a list of all possible permutations of [0,1,...,n], with n being the number of names you input
  ArrayList<IntList> permutations = get_permutations(names.length);
  
  //the above step would normally be good enough, but because of the circular nature of the wheel [0,1,2] is a duplicate of [2,0,1] (just rotated to the right one space). Remove all duplicates.
  ArrayList<IntList> trimmed_permutations = remove_duplicates(permutations);
  
  //the output list of results
  ArrayList<Result> retval = new ArrayList<Result>();
  
  //for each permuation of the list...
  for (IntList il : trimmed_permutations)
  {
    //for each set of hops (1 is the clockwise neighbor, so it's always done, and the last hop would be to the counter-clockwise neighbor, which wouldn't make much sense)...
    for (int j = 2; j < names.length - 1; ++j)
    {
      //determine the score make a Result object to store all the stats in
      Result r = new Result(il, j, get_score(il.array(), j));
      
      //a special case for trying to append to the end of the list
      if (retval.isEmpty() || r.score >= retval.get(retval.size()-1).score)
        retval.add(r);
      else
      {
        //loop through the list, insert this result where it belongs if sorted by score
        for (int i = 0; i < retval.size(); ++i)
        {
          if (r.score <= retval.get(i).score)
          {
            retval.add(i,r);
            break;
          }
        }
      }
    }
  }
  
  return retval;
}




int get_score(int[] layout, int hops)
{
  int retval = 0;
  
  //pretty easy, just loop through each node, and add up how much damage it does to its clockwise neighbor and its (+hops) neighbor
  for (int i = 0; i < layout.length; ++i)
  {
    int elm = layout[i];
    
    retval += damage[elm][layout[(i + 1) % names.length]]; //% names.length lets us wrap around
    retval += damage[elm][layout[(i + hops) % names.length]];
  }
  
  return retval;
}




void draw_arrow(PVector c0, PVector c1, float c_radius)
{
  //first find the angle from c0 to c1
  float a = atan2(c0.y-c1.y,c1.x-c0.x);
  
  //the coordinates where a line from c0 to c1 meets the edge of c0
  float x0 = c0.x + cos(a) * c_radius;
  float y0 = c0.y - sin(a) * c_radius;
  
  //the coordinates where a line from c0 to c1 meets the edge of c1
  float x1 = c1.x - cos(-a) * c_radius;
  float y1 = c1.y - sin(-a) * c_radius;
  
  //drawing stuff
  stroke(0);
  fill(0);
  strokeWeight(1);
  
  //draw the line between the edges of the two circles
  line(x0,y0,x1,y1);
  
  //tilt clockwise ao radians for one point of the arrowhead, tilt counter-clockwise ao radians for the other point
  float ao = PI/6f;
  float arrowhead_size = 10f;
  
  //one of the two backends of the arrowhead
  float xo0 = x1 - cos(a+ao) * arrowhead_size;
  float yo0 = y1 + sin(a+ao) * arrowhead_size;
  
  //the other backend point of the arrowhead
  float xo1 = x1 - cos(a-ao) * arrowhead_size;
  float yo1 = y1 + sin(a-ao) * arrowhead_size;
  
  //x1,y1 (the point where a line from c0 to c1 meets the edge of c1) forms the tip of the arrowhead
  triangle(xo0,yo0,xo1,yo1,x1,y1);
}




void draw_text_between(PVector c0, PVector c1, String just)
{
  //get the point directly inbetween c0 and c1
  PVector np = c0.copy().lerp(c1,0.5f);
  
  //first off, this can be done much easier if c0.y == c1.y (no text rotation), and more importantly rotating PI radians and back before drawing isn't perfect, so text doesn't look great
  if (abs(c0.y-c1.y) < 0.01f)
  {
    if (c0.x < c1.x)//however, we still need to respect the rotation when it comes to positioning the text above or below the line. This can still be determined easily by comparing the x values.
      text(just, np.x, np.y - 10f);
    else
      text(just, np.x, np.y + 10f);
  }
  else
  {
    //get the angle to tilt by (subtracting it from TWO_PI to make sure it's positive)
    float a = (TWO_PI - atan2(c0.y-c1.y,c1.x-c0.x)) % TWO_PI;
    
    //start a new drawing context where we can rotate/move however we want
    pushMatrix();
    
    //move the context to center on where the text needs to draw
    translate(np.x,np.y);
    
    //rotate by however much we need
    rotate(a);
    
    //now that we've rotate, push the text up 10 pixels so it doesn't ride directly on the arrow line
    translate(0f,-10f);
    
    //if the text would appear "upside-down", flip it. It's important to do this after the last translate or we'll end up on the wrong side of the arrow line
    if (a > HALF_PI && a < (PI * 1.5f))
      rotate(PI);
    
    //finally draw the text. It goes to 0,0 because we've moved the drawing context to the appropriate point already
    text(just, 0f, 0f);
    
    //go back to the normal drawing context so the other objects don't get messed up
    popMatrix();
  }
}



//naive implementation of the recursive Steinhaus-Johnson-Trotter algorithm (but done with loops instead of recursion). May improve to the full swapping version later, but this works plenty fast enough for my purposes.
//more info here: https://en.wikipedia.org/wiki/Steinhaus%E2%80%93Johnson%E2%80%93Trotter_algorithm
//note: since I don't care about the order of the layouts with respect to each other, the direction swapping isn't necessary. The SJT algorithm desires the correct order to traverse the permutahedron properly, but I don't care.
ArrayList<IntList> get_permutations(int n)
{
  //our current list of permutations
  ArrayList<IntList> vals = new ArrayList<IntList>();
  
  //it starts with just the first value, 0, as a single row (since there's only 1 way to arrange a single element)
  vals.add(new IntList(new int[]{0}));
  
  //for each number not yet added...
  for (int i = 1; i < n; ++i)
  {
    //this list will store all the entries we create this time through the loop, as in all the entries with length i+1
    ArrayList<IntList> nextset = new ArrayList<IntList>();
    
    //for each entry in the value list so far
    for (int j = 0; j < vals.size(); ++j)
    {
      //get the entry we're looking at, like {0,1}
      IntList tv = vals.get(j);
      
      //for each space in this entry
      for (int k = 0; k < tv.size(); ++k)
      {
        //copy the current entry...
        IntList nv = tv.copy();

        //push i into this spot
        nv.insert(k,i);
        
        //add this new layout to the next set (where i+1 will expand this and be inserted into each possible position)
        nextset.add(nv);
      }
      
      //special case for the last entry since we can't insert at tv.size()
      IntList lv = tv.copy();
      lv.append(i);
      nextset.add(lv);
    }
    
    //dump the old set (which had lists only i-1 elements long instead of i elements long) and replace it with the new set
    vals = nextset;
  }
  
  //return the last set done by the loop, which will have n-length sets
  return vals;
}

/*

//naive implementation of the recursive Steinhaus-Johnson-Trotter algorithm (but done with loops instead of recursion). May improve to the full swapping version later, but this works plenty fast enough for my purposes.
//more info here: https://en.wikipedia.org/wiki/Steinhaus%E2%80%93Johnson%E2%80%93Trotter_algorithm
//note: since I don't care about the order of the layouts with respect to each other, the direction swapping isn't necessary. The SJT algorithm desires the correct order to traverse the permutahedron properly, but I don't care.
ArrayList<IntList> get_permutations(int n)
{
  //our current list of permutations
  ArrayList<IntList> vals = new ArrayList<IntList>();
  
  //it starts with just the first value, 0, as a single row (since there's only 1 way to arrange a single element)
  vals.add(new IntList(new int[]{0}));
  
  //for each number not yet added...
  for (int i = 1; i < n; ++i)
  {
    //this list will store all the entries we create this time through the loop, as in all the entries with length i+1
    ArrayList<IntList> nextset = new ArrayList<IntList>();
    
    //for each entry in the value list so far
    int direction = -1;//numbers start at the end of the layout, and move backwards towards the front. Once there, direction flips and it moves towards the back again, where it flips again, and so on.
    for (int j = 0; j < vals.size(); ++j)
    {
      //get the entry we're looking at, like {0,1}
      IntList tv = vals.get(j);
      
      //create a new list with i inserted into each possible position of this entry
      int start = direction < 0 ? tv.size() : 0;//start at the back if direction is negative, otherwise we're starting at the front
      int end = direction < 0 ? -1 : tv.size() + 1;//the end has to be pushed out one space since we can't do >= or <=. With != we've got to be specific.
      
      for (int k = start; k != end; k += direction)
      {
        //copy the current entry...
        IntList nv = tv.copy();
        
        //special case for appending to the end
        if (k >= nv.size())
          nv.append(i);
        //otherwise just insert it normally
        else
          nv.insert(k,i);
        
        //add this new layout to the next set (where i+1 will expand this and be inserted into each possible position)
        nextset.add(nv);
      }
      
      //flip the direction
      direction *= -1;
    }
    
    //dump the old set (which had lists only i-1 elements long instead of i elements long) and replace it with the new set
    vals = nextset;
  }
  
  //return the last set done by the loop, which will have n-length sets
  return vals;
}
*/




//misleadingly titled, but I can't think of a better name. There are no true duplicates if we are using the permutation list, but due to the circular nature of our layouts {0,1,2} is functionally the same as {2,0,1}, just rotated one space to the right.
ArrayList<IntList> remove_duplicates(ArrayList<IntList> vals)
{
  //this could be done inline, but whatever. Make a copy of the input so we don't destroy it.
  ArrayList<IntList> retval = new ArrayList<IntList>(vals);
  
  //for each entry in the list of layouts....
  for (int i = 0; i < retval.size(); ++i)
  {
    //get the current entry
    IntList il = retval.get(i);
    
    //run through the rest of the list and remove any that could be considered duplicates of this list
    for (int j = i + 1; j < retval.size(); ++j)
    {
      if (circular_equivalence(il, retval.get(j)))
      {
        retval.remove(j);//remove the entry
        --j;//back up the iterator or we'll end up skipping entries. I don't think adjacent entries will ever be equivalent, but I'm not a math professor.
      }
    }
  }
  
  return retval;
}




boolean circular_equivalence(IntList lhs, IntList rhs)
{
  //find a common starting point, so if lhs[0] == 7, find out where 7 is in rhs
  int start_lhs = 0;
  int start_rhs = 0;
  for (int i = 0; i < rhs.size(); ++i)
  {
    if (rhs.get(i) == lhs.get(start_lhs))
    {
      start_rhs = i;
      break;
    }
  }
  
  //now loop through to see if there are any differences
  for (int i = 1; i < lhs.size(); ++i)//start at 1 since we know lhs[0] and rhs[start_rhs] match
  {
    if (lhs.get(i) != rhs.get((i + start_rhs) % rhs.size()))//% rhs.size() lets us wrap around to the beginning
      return false;
  }
  
  //if we didn't hit any differences then this is equivalent
  return true;
}




ArrayList<Result> remove_entries_without_justifications(ArrayList<Result> vals)
{
  ArrayList<Result> retval = new ArrayList<Result>();
  
  for (Result r : vals)
  {
    if (has_complete_justifications(r))
      retval.add(r);
  }
  
  return retval;
}




//written to pare down the result list to just those that have complete justification graphs. Nice, but you only get a handful of results unless you really add a ton of rivalries.
boolean has_complete_justifications(Result r)
{
  //for each node in the layout...
  for (int i = 0; i < r.layout.size(); ++i)
  {
    //check if a justification exists between this node and its clockwise neighbor
    if (justifications[r.layout.get(i)][r.layout.get((i + 1) % names.length)].isEmpty())
      return false;
    
    //now check if a justification exists between this node and its (+hops) clockwise neighbor
    if (justifications[r.layout.get(i)][r.layout.get((i + r.hops) % names.length)].isEmpty())
      return false;
  }
  
  return true;
}




class Result
{
  IntList layout;
  int score;
  int hops;
  
  Result(IntList layout, int hops, int score) { this.layout = layout; this.hops = hops; this.score = score; }
}
