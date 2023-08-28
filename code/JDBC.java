import java.io.*;
import java.sql.*;
import com.ibm.as400.access.*;

public class JDBC {

  public static void main(String[] args) throws Exception{

    Connection conn = null;

    Class.forName("com.ibm.as400.access.AS400JDBCDriver");
    conn = DriverManager.getConnection("jdbc:as400:" +
           args[0] + ";extended metadata=true;trace=false;", args[1], args[2]);

    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("select * from GURILIB.TOKMSP WHERE TKBANG LIKE '02_10'");

    ResultSetMetaData rsmd = rs.getMetaData();

    for (int i = 1 ; i <= rsmd.getColumnCount() ; i++) {
      System.out.print(rsmd.getColumnLabel(i).trim().replaceAll("[　 ]", ""));
      if (i < rsmd.getColumnCount()) System.out.print("\t");
    }
    System.out.println();

    while (rs.next()) {
      for (int j = 1 ; j <= rsmd.getColumnCount() ; j++) {
        System.out.print(rs.getString(j).trim());
        if (j < rsmd.getColumnCount()) System.out.print("\t");
      }
      System.out.println();

    }
    rs.close();
    stmt.close();

  }

}
