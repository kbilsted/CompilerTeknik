class A
{
	String a;
    String space;
    
    void main()
    {
	    int i; 
	    i = 0;
    	a = "*";
    	space = " ";	
	    while(i < 500)
    	{
    		f(i);
    	    i = i + 1;
	    }
    }
    
    void f(int i)
    {
   		System.out.print(Integer.toString(i));
   		System.out.print(space);
	}

}