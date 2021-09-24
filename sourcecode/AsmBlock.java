/* Anvendes til lagring af genereret Assemblerkode */
import java.util.Vector;

public class AsmBlock
{
	private Vector b = new Vector();
	
	public void add(String s){b.addElement(s);}

	public String toString()
	{
		StringBuffer buf = new StringBuffer();

		for(int i = 0; i < b.size(); i++)
		{
			String s = (String) b.elementAt(i);

			// if not a label, insert spaces
			if((s.endsWith(":") || s.endsWith("PROC") || s.endsWith("ENDP") || s.endsWith("DOSSEG") || s.endsWith("END")) == false)
				 buf.append("    ");
			buf.append( s + "\n");
		}
		
		return(buf.toString());			
	}
}