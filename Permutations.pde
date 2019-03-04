ArrayList<IntList> get_permutations(int n)
{
  return get_permutations(n,n);
}

ArrayList<IntList> get_permutations(int n, int r)
{
  IntList master_list = new IntList();
  for (int i = 0; i < n; ++i)
    master_list.append(i);
  
  return get_permutations(master_list, r);
}

ArrayList<IntList> get_permutations(IntList master_list, int r)
{
  ArrayList<IntList> retval = new ArrayList<IntList>();
    
  for (int i = 0; i < master_list.size(); ++i)
    retval.add(new IntList(new int[]{master_list.get(i)}));
    
  //start at 1 because the first "loop" was already done above
  for (int i = 1; i < r; ++i)
  {
    ArrayList<IntList> next_layer = new ArrayList<IntList>();
    
    for (IntList il : retval)
    {
      for (int j = 0; j < master_list.size(); ++j)
      {
        if (!il.hasValue(master_list.get(j)))
        {
          IntList nl = il.copy();
          nl.append(master_list.get(j));
          
          next_layer.add(nl);
        }
      }
    }
    
    retval = next_layer;
  }
  
  return retval;
}

ArrayList<IntList> get_circular_permutations(int n)
{
  return get_circular_permutations(n,n);
}

ArrayList<IntList> get_circular_permutations(int n, int r)
{
  IntList master_list = new IntList();
  for (int i = 0; i < n; ++i)
    master_list.append(i);
  
  return get_circular_permutations(master_list, r);
}

//the idea here is to get all the permutations where the first number is 0, then all the permutations where the first number is 1 and 0 isn't present, then all the permutations where the first number is 2 but neither 0 nor 1 are present, etc., doing that 1 + n - r (so if n==r we just loop once)
//So for P(3,2) of {0,1,2} you'll get {0,1},{0,2}, {1,2}
ArrayList<IntList> get_circular_permutations(IntList master_list, int r)
{
  ArrayList<IntList> retval = new ArrayList<IntList>();
  
  //peel layers off one at a time
  IntList remaining = master_list.copy();
  for (int i = 0; i < 1 + master_list.size() - r; ++i)
  {
    int v = remaining.remove(0);
    
    ArrayList<IntList> substuff = get_permutations(remaining,r-1);
    
    for (IntList il : substuff)
    {
      IntList ol = il.copy();
      ol.push(v);
      
      retval.add(ol);
    }
  }
  
  return retval;
}
