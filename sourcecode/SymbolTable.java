import java.util.Vector;

/* anvendes til typecheck og til kodegenerering */

public class SymbolTable
{
	private Vector list = new Vector(); // contains elements

	protected class Symbol
	{
		int index;
		String fromClass, fromFnc, name, type;

		// konstruktør
		Symbol(String t, String fC, String fF, String n, int i)
		{type = t; fromClass = fC; fromFnc = fF; name = n; index = i;}
	}

	
	
	public void add(String type, String fromClass, String fromFnc, String name, int index)
	{
		this.add(type, fromClass, fromFnc, name);
		
		Symbol s = (Symbol) list.lastElement();
		s.index = index;
		
		list.setElementAt(s, list.size()-1); // overwrite element with the new index value
	}		

		
	public void add(String type, String fromClass, String fromFnc, String name)
	{
		Symbol s;
		int size = 0; // the index possition
		
		if(fromFnc == null)
		{
			// first find no. variables in same scope
			for(int i = 0; i < list.size(); i++)
			{
				s = (Symbol) list.elementAt(i);
				// same class but no function-scope
				if(fromClass.equals(s.fromClass) && fromFnc == null) 
					size++;
			}
		}
		else
		{
			// first find no. variables in same scope
			for(int i = 0; i < list.size(); i++)
			{
				s = (Symbol) list.elementAt(i);
				// same class but no function-scope
				if(fromClass.equals(s.fromClass) && fromFnc.equals(s.fromFnc) ) 
					size++;
			}
		}
				
		s = new Symbol(type, fromClass, fromFnc, name, size*2);

		list.addElement(s);
	}


	public void remove(String type, String fromClass, String fromFnc, String name)
	{
		Symbol s;
		
		for(int i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			
			// we must handle null-pointers sepperatly
			if(fromFnc == null)
			{
				if(fromClass.equals(s.fromClass) && s.fromFnc == null &&
			   	   name.equals(s.name) )
				{
					list.removeElementAt(i);
					return;
				}
			}
			else
			if(fromClass.equals(s.fromClass) && fromFnc.equals(s.fromFnc) &&
			   name.equals(s.name) )
			{
				list.removeElementAt(i);
				return;
			}
		}
	}
		
	
	/* return values:
	 * -1 - var not found
	 *  0 - wrong type
	 *  1 - type is ok.
	 */
	public int typeCheck(String type, String fromClass, String fromFnc, String name)
	{
		Symbol s;
		// find element (class and name)
		for(int i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			if(fromClass.equals(s.fromClass) && name.equals(s.name) )
			{
				// check if variable is from the same function 
				if(fromFnc != null && !fromFnc.equals(s.fromFnc) )
				   	continue;
				   	
				// compare types
				if(type.equals(s.type) )
					return(1);
				else
					return(0);
			}	
		}
		return(-1);
	}
	

	// returns the type of a given variable
	public String varType(String fromClass, String fromFnc, String name)
	{
		Symbol s;
		// find element (class and name)
		for(int i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			if(fromClass.equals(s.fromClass) && name.equals(s.name) )
				return(s.type);
		}
		return(null);
	}

	// returns the size of function in bytes == 2 * #local variables
	public int fncSize(String className, String fncName)
	{
		Symbol s;
		int i, size = 0;

		// summerize all variables with same classname with no [tilhørsforhold] to a function
		for(i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			if(className.equals(s.fromClass) && fncName.equals(s.fromFnc))
				size++;
		}

		// we *2 in indexsize, since all elements is implemented as 
		// 16 bits == 2 elements on the stack/hob
		return(size*2);
	}
	
	
	// returns size of class in bytes = 2 * #local variables
	public int classSize(String className)
	{
		Symbol s;
		int i, size = 0;

		// summerize all variables with same classname with no tilhørsforhold to a function
		for(i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			if(className.equals(s.fromClass) && s.fromFnc == null)
				size++;
		}
		// we *2 in indexsize, since all elements is implemented as 
		// 16 bits == 2 elements on the stack/hob
		return(size*2);
	}
	
	
	public int varIndex(String fromClass, String fromFnc, String name)
	{
		Symbol s;
		// find element (class and name)
		for(int i = 0; i < list.size(); i++)
		{
			s = (Symbol) list.elementAt(i);
			if(fromClass.equals(s.fromClass) && name.equals(s.name) )
			{
				
				// check if variable is from the same function (if from a function)
				if(fromFnc == null && s.fromFnc == null)
					return(s.index);
				else	
				if(fromFnc != null && fromFnc.equals(s.fromFnc) )
					return(s.index);
			}	
		}

		// failed to find variable, 
		
		return(-1); // failed to find variable!
	}
	

/*
// for test only!
static void main(String[] a)
{
		SymbolTable s = new SymbolTable();
		
		s.add("int", "A", "f", "i");
		s.add("int", "A", null, "k");
		s.add("char", "A", "f", "j");

		s.add("int", "A", "g", "j");
		s.add("int", "B", null, "k");
		s.add("char", "A", null, "x");

		System.out.println("A = " + s.classSize("A") );
		System.out.println("A.f() = " + s.fFncSize("A", "f") );
		System.out.println("pos A.f.j = " + s.varIndex("A", "f", "j") );
		System.out.println("pos B.k = " + s.varIndex("B", null, "k") );
		System.out.println("A.g() = " + s.fncSize("A", "g") );

		if(s.typeCheck("int", "A", null, "i") == true)	System.out.println("i er int");
		else System.out.println("i != int ");

		if(s.typeCheck("char", "A", "f", "j") == true)	System.out.println("A.f().j er char");
		else System.out.println("i != int ");

		if(s.typeCheck("int", "A", "f", "j") == true)	System.out.print("A.f.j er int");
		else System.out.println("A.f.j != int ");

}
*/

}