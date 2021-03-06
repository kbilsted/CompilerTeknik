import java.util.Vector;

public abstract class Tree
{
    public abstract String toString();    
    
    protected void errorAndExit(String s)
    {System.out.print(s); System.exit(0);}
    
    protected int lineno; // line # of element in source
    public int lineno(){return(lineno);}
}


class Classdef extends Tree
{
    private int getCounter = 0;
    private Vector classList = new Vector(); // touple af (navn, contents)
    
    // constructor
    Classdef(int lineno){super.lineno = lineno;}
    
    public void add(Object o){classList.addElement(o);}
    
    public void resetGet(){getCounter = 0;}
        
    public Object getNext()
    {
        if(getCounter > -1 && getCounter < classList.size())
            return(classList.elementAt(getCounter++));
        return(null);
    }
    
    public void pushBack(){getCounter--;}
    
    public String toString()
    {
        StringBuffer buf = new StringBuffer();
        
        for(int i = 0; i < classList.size(); i++)    
            buf.append("class " + (String) classList.elementAt(i++) + "\n{\n"
                       + classList.elementAt(i).toString() + "}\n\n");
        
        return(buf.toString());
    }
}        


class Classcontents extends Tree
{
    private int getCounter = 0;
    private Vector defList = new Vector(); // list of vardef/fncdef
    
    // constructor
    Classcontents(int lineno){super.lineno = lineno;}
    
    public void add(Object o){defList.addElement(o);}

    public void resetGet(){getCounter = 0;}
        
    public Tree getNext()
    {
        if(getCounter > -1 && getCounter < defList.size())
            return((Tree) defList.elementAt(getCounter++));
        return(null);
    }
    
    public void pushBack(){getCounter--;}

    public String toString()
    {
        StringBuffer buf = new StringBuffer();
        
        for(int i = 0; i < defList.size(); i++)
            buf.append( defList.elementAt(i).toString() + "\n");
        
        return(buf.toString());
    }
}


class Vardef extends Tree
{
    private String name;
    private String type;

    // constructor
    Vardef(String t, String n, int lineno)
    {type=t; name=n; super.lineno = lineno;}

    public String getName(){ return(name); }
    public String getType(){ return(type); }
            
    public String toString()
    {
        return("(vardef) " + type + " " + name);    
    }
}


class Fncdef extends Tree
{
    private String name;
    private Vector argList; // contains (tyindeholder altid par af <ID>, dvs. 2, 4, ... , 2*n antal <ID>
    private Tree sentences;

    // constructor
    Fncdef(String name, Vector list, Tree s, int lineno)
    {this.name = name; argList = list; sentences = s; super.lineno = lineno;}
            
            
    public String getName(){return(name);}
    public Vector getArgList(){return(argList);}
    public Sentences getSentence(){return((Sentences) sentences);}
    
    public String toString()
    {
        // navn
        StringBuffer buf = new StringBuffer("\n(fncdef) void " + name + "(");
        
        // argumenter
        for(int i = 0; i < argList.size(); i++)
        {
            if(i != 0) buf.append(", ");
            buf.append((String) argList.elementAt(i++) + " " + 
                       (String) argList.elementAt(i));
        }
    
        // indhold
        buf.append(")\n{\n" + sentences.toString() + "}");
    
        return(buf.toString());    
    }
}



class Sentences extends Tree
{
    private int getCounter = 0;
    private Vector sList = new Vector(); // liste of <sentences>
    
    // constructor
    Sentences(int lineno){super.lineno = lineno;}
    public void add(Object o){sList.addElement(o);}
    
    public Tree getNext()
    {
        if(getCounter > -1 && getCounter < sList.size()) 
            return((Tree) sList.elementAt(getCounter++));
        return(null);
    }
    
    public void pushBack(){getCounter--;}
    
    public String toString()
    {
        StringBuffer buf = new StringBuffer();
        
        for(int i = 0; i < sList.size(); i++)
            buf.append( sList.elementAt(i).toString() + "\n");

        return(buf.toString());
    }
}


class Fnccall extends Tree
{
    private boolean localCall; 
    private String name;
    private Vector argList = new Vector();
    
    // constructor
    Fnccall(String name, boolean localCall, int lineno)
    {this.name = name; this.localCall = localCall; super.lineno = lineno;}
    
    // to convert an OpCall to a Fnccall
    Fnccall(String name, Vector argList, boolean localCall)
    {this.name = name; this.argList = argList; this.localCall = localCall;}

    public String getName(){return(name);}
    public Vector getArgList(){return(argList);}
    public boolean isCallLocal(){return(localCall);}
    
    
    public void add(Object o){argList.addElement(o);}

    public String toString()
    {
        StringBuffer buf = new StringBuffer("\n(fnccall) "+ name + "(");
        
        for(int i = 0; i < argList.size(); i++)
        {    
            if(i > 0) buf.append(", ");
            buf.append(argList.elementAt(i).toString() + "\n");
        }
            
        return(buf.toString() + ")");
    }
}


class If extends Tree
{
    private Tree condCode;
    private Tree thenCode;
    private Tree elseCode;

    // constructor
    If(Tree c, Tree t, Tree e, int lineno)
    { condCode = c; thenCode = t; elseCode = e; super.lineno = lineno;}
    
    public Tree getCond(){return(condCode);}
    public Tree getThen(){return(thenCode);}
    public Tree getElse(){return(elseCode);}
    
    public String toString()
    {
        return("if(" + condCode.toString() + ")\n{\n" 
                     + thenCode.toString() + "}\nelse\n{\n" 
                     + elseCode.toString() + "\n}\n");
    }
}


class While extends Tree
{
    private Tree condCode;
    private Tree whileCode;

    //constructor
    While(Tree c, Tree w, int lineno){condCode = c; whileCode = w;super.lineno = lineno;}

    public Tree getCond(){return(condCode);}
    public Tree getWhile(){return(whileCode);}    
    
    public String toString()
    {
        return("while(" + condCode.toString() + ")\n{" 
                        + whileCode.toString()+ "}\n");
    }
}

class Break extends Tree
{
    // constructor
    Break(int lineno){super.lineno = lineno;}
    
    public String toString(){return("break");}
}


class Return extends Tree 
{
    //constructor
    Return(int lineno){super.lineno = lineno;}
    
    public String toString(){return("return");}
}


class Assign extends Tree
{
    int op; // determine wether we have <ID> or <NAME>
    private String name;
    private Tree E;
     
    // constructor
    Assign(String name, int op, Tree E, int lineno)
    {this.name = name; this.op = op; this.E = E; super.lineno = lineno;}
        
        
    public String getName(){return(name);}
    public Tree getE(){return(E);}
    public int getOp(){return(op);}
    
    public String toString()
    {
        return("(assign) " + name + " = " + E.toString());
    }
}


class OpMonadic extends Tree implements TokenNames
{
    private int op;     // == TokenName
    private Tree right;

    // constructor
    OpMonadic(int op, Tree right, int lineno)
    {this.op = op; this.right = right; super.lineno = lineno;}
    
    public int getOp(){return(op);}
    public Tree getR(){return(right);}
    
    public String toString()
    {
        switch(op)
        {
            case NOT:   return("(! " + right.toString()+")" );
            case MINUS: return("(- " + right.toString()+")" );
            default: errorAndExit("Strange operator (#"+op+") in 'opMonadic' made me stop compiling!\n");
        }    
        return("dummy to make Java<tm> happy");
    }
}


class OpDual extends Tree implements TokenNames
{
    private int op;        // == TokenName
    private Tree left, right;
    
    // constructor
    OpDual(int op, Tree left, Tree right, int lineno)
    { this.op = op; this.left = left; this.right = right; super.lineno = lineno;}
    
    public Tree getL(){return(left);}
    public Tree getR(){return(right);}
    public int getOp(){return(op);}
    
    public String toString()
    {    
        StringBuffer buf = new StringBuffer("("+left.toString() + " ");
        switch(op)
        {
            case PLUS:   buf.append("+"); break;
            case MINUS:  buf.append("-"); break;
            case MULT:   buf.append("*"); break;
            case DIV:    buf.append("/"); break;
            case SET:    buf.append("="); break;
            case NEQUAL: buf.append("!="); break;
            case EQUAL:  buf.append("=="); break;
            case LEQUAL: buf.append("<="); break;
            case LESS:   buf.append("<"); break;
            case AND:    buf.append("&&"); break;
            case BITAND: buf.append("&"); break;
            case OR:     buf.append("||"); break;
            case BITOR:  buf.append("|"); break;
            case MODULO: buf.append("%"); break;
            default: errorAndExit("Strange operator (#"+op+") in 'opDual' made me stop compiling!\n");
        }
        return(buf + " " + right.toString()+")" );
    }
}



// functioncalls samt NEW
class OpCall extends Tree implements TokenNames
{
    private boolean fncCall = false;
    
    private int op;            // anvendes til at bestemme om det er et "new" eller et funktionskald
    private String name;
    private Vector argList = new Vector();

    // constructor
    OpCall(int op, String name, int lineno)
    {this.op = op; this.name = name; super.lineno = lineno;}
    
    public boolean isFncCall(){return(fncCall);}
    public void setIsFncCall(){fncCall = true;}
    
    public int getOp(){return(op);}
    public String getName(){return(name);}
    public Vector getArgList(){return(argList);}


    public void add(Object o){argList.addElement(o);}
    
    public String toString()
    {
        if(op == NEW)
            return("new " + name + "() ");
        else
        {        
            StringBuffer buf = new StringBuffer(name);

            if(argList.size() > 0)
            {    buf.append("(");
                for(int i = 0; i < argList.size(); i++)
                {
                    if(i != 0) buf.append(", ");
                    buf.append(argList.elementAt(i).toString());
                }    
                return(buf.toString() + ")");
            }
            else
                return(buf.toString());
        }
    }
}


class OpConst extends Tree implements TokenNames
{
    private int op;        // tokenName
    private int nval;    
    private String sval;
        
    // constructor
    OpConst(int op, int nval, int lineno)
    {this.op = op; this.nval = nval; super.lineno = lineno;}
    
    OpConst(int op, String sval, int lineno)
    {this.op = op; this.sval = sval; super.lineno = lineno;}
    
    
    
    // for the code generator
    public int getOp(){return(op);}
    public int getNval(){return(nval);}
    public String getSval(){return(sval);}
        
    public String toString()
    {
        switch(op)
        {
            case VAL_CHAR:   return("'"+sval+"' ");
            case VAL_STRING: return("\""+sval+"\" ");
            case VAL_INT:    String s = "" + nval; return(s); 
            default: errorAndExit("Strange operator (#"+op+") in 'opConst' made me stop compiling!\n");
        }    
        return("dummy to make Java<tm> happy");
    }
}