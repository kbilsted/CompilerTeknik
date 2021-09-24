class A
{
	String space;
	String strfalse;
	String strtrue;
		
	void f()
	{
		int i;
		int j;
		
		// 00000100 (4) OR 00000010 (2) = 00000110 (6)
		System.out.print( Integer.toString(4|2) );	// | test
		System.out.print(space);

		// 00001100 (12) OR 00001010 (10) = 00001000 (8)
		System.out.print( Integer.toString(12&10) );// & test	
		System.out.print(space);
		
		System.out.print( Integer.toString(1+1) );	// + test (2)
		System.out.print( Integer.toString(4-1) );	// - test (3)
		System.out.print( Integer.toString(2*3) );	// * test (6)
		System.out.print( Integer.toString(25/5) );	// / test (5)
		System.out.print( Integer.toString(23%8) );	// % test (7)
		System.out.print( Integer.toString(6- -2) );// - (fortegn) test (8)
		System.out.print(space);
		
		
		// ! test på bits 11111111 11111000 (65528) = 00000000 00000111 (7)
		System.out.print( Integer.toString(!65528) );	
		System.out.print(space);
		System.out.print(space);



		// == test 1
		j = 1;
		if(j == 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}

		// == test 2
		j = 0;
		if(j == 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);
		
		// != test 1
		j = 0;
		if(j != 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// != test 2
		j = 1;
		if(j != 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);

		
		// < test 1
		j = 0;
		if(j < 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		
		// < test 2
		j = 1;
		if(j < 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);

			
		// <= test 1
		j = 0;
		if(j <= 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// <= test 2
		j = 1;
		if(j <= 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// <= test 3
		j = 2;
		if(j <= 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);

		
		// ! test på boolske udtryk 1, false
		if(!(1 == 1)){System.out.print(strtrue);}
		else{System.out.print(strfalse);}

		
		// ! test på boolske udtryk 2, false
		if(!(1 == 0)){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);


			
		// && test 1
		j = 0;
		if(j == 1 && j == 0){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// && test 2
		j = 0;
		if(j == 1 && j == 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// && test 3
		j = 0;
		if(j == 0 && j == 0){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);


			
		// || test 1
		j = 0;
		if(j == 1 || j == 0){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// || test 2
		j = 0;
		if(j == 1 || j == 1){System.out.print(strtrue);}
		else{System.out.print(strfalse);}


		// || test 3
		j = 0;
		if(j == 0 || j == 0){System.out.print(strtrue);}
		else{System.out.print(strfalse);}
		System.out.print(space);
		System.out.print(space);



		// while test, udskriver 0
		j = 0;
		while(j == 0)
		{
			System.out.print( Integer.toString(j));	
			j = j + 1;
		}


		// while test, udskriver intet 
		j = 6;
		while(j < 5)
		{
			System.out.print( Integer.toString(j));	
			j = j + 1;
		}
		System.out.print(space);
		
		
		// while test, udskriver 1..5
		j = 0;
		while(j < 5)
		{
			System.out.print( Integer.toString(j));	
			j = j + 1;
		}
		System.out.print(space);
		System.out.print(space);


		// test af break, udskriver intet
		j = 0;
		while(j < 5)
		{
			break;
			System.out.print( Integer.toString(j));	
		}
		
		
		// test af return, udskriver ikke mere
		return;
		j = 42;
		System.out.print( Integer.toString(j));	
	}


	// test af metode med argumenter
	void g(int x, int y)
	{
		int pp;
		pp = 3;
		System.out.print( Integer.toString(pp));
		System.out.print( Integer.toString(x));
		System.out.print( Integer.toString(y));
		System.out.print(space);
	}

	
	void main()
	{
		String s;
		String s2;
		s = "Datama";	
		s2 = "t!";
		space = " ";
		
		int i;
		i = s.length();
		System.out.print( Integer.toString(i) );
		System.out.print(space);
		
		s = s.concat(s2);
		System.out.print(s);
		System.out.print(space);

		i = s.length();
		System.out.print( Integer.toString(i) );
		System.out.print(space);

		// print ascii value of t == 116
		char c;
		c = s.charAt(2);
		System.out.print( Integer.toString(c));
		System.out.print(space);
		
		strfalse = "F";
		strtrue = "T";
	
		

		f();
		
		B bptr;
		bptr = new B();

		g(2,1);		

		bptr.g();
	}
}




class B
{
	void g()
	{
		String s;
		s = "hej fra objekt B";
		System.out.print(s);
	}	
}

