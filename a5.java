/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package javaapplication5;
import java.sql.*;
import java.util.*;
/**
 *
 * @author Carpe
 */
public class JavaApplication5 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.println("-------- Oracle JDBC Connection  ------");
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("Where is your Oracle JDBC Driver?");
            e.printStackTrace();
            return;
        }
        System.out.println("Oracle JDBC Driver Registered!");
        Connection conn = null;
        try {
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "HR", "password");
        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }
        //---------------------------------START------------------------------------------------
        
        
        if (conn  != null) {
            try {
                while (true) {
                    System.out.println("Enter question number:");
                    int qno = sc.nextInt();
                    // ------------------------------------------- Q1 ------------------------------------------------
                    if(qno == 1) {
                       PreparedStatement prep_stmt=null;
                       System.out.println("Enter Employee ID : ");
                       int empID = sc.nextInt();
                       System.out.println("Enter new Job ID : ");
                       String jobID = sc.next();
                       System.out.println("Enter new Department ID : ");
                       int depID = sc.nextInt();
                       String query = "UPDATE HR.EMPLOYEES SET department_id = ? , job_id = ? WHERE employee_id = ?";
                       prep_stmt = conn.prepareStatement(query);
                       prep_stmt.setInt(1,depID);
                       prep_stmt.setString(2, jobID);
                       prep_stmt.setInt(3, empID);
                       System.out.println("Reached Here ");
                       int i=prep_stmt.executeUpdate();
                       System.out.println(i+" Rows Updated !");
                       System.out.println("Successful ! ");
                    }
                        // ------------------------------------------- Q2 ------------------------------------------------
    
                     if(qno == 2) {
                         
                         //Create a Procedure first
                         System.out.println("Enter Department ID : ");
                         int depID = sc.nextInt();
                         System.out.println("Enter new Manager ID : ");
                         int manID = sc.nextInt();
                         CallableStatement cst = conn.prepareCall("{call DeptManager(?,?)}");
                         cst.setInt(1, depID);
                         cst.setInt(2,manID);
                         cst.execute();
                         System.out.println("Successful !");
                     }
                     

                        // ------------------------------------------- Q3 ------------------------------------------------
                    if(qno == 3) {
                        //Create a procedure name promote first
                        System.out.println("Enter Department ID : ");
                         int depID = sc.nextInt();
                         CallableStatement cst = conn.prepareCall("{call UpdateManSalary(?)}");
                         cst.setInt(1, depID);
                         int i = cst.executeUpdate();
                         System.out.println(i+"  Successful !");
                        }

                    // ------------------------------------------- Q4 ------------------------------------------------
                    if(qno == 4) {
                        // incSalDept is the Procedure here
                        CallableStatement cst = null;
                        System.out.println("Enter Department ID : ");
                        int depID = sc.nextInt();
                        System.out.println("Enter Bonus : ");
                        float bonus = sc.nextFloat();
                        cst=conn.prepareCall("{call incSalDept(?,?)}");
                        cst.setInt(1, depID);
                        cst.setFloat(2, bonus);
                        int i = cst.executeUpdate();
                        System.out.println(i+" Successful !");
                        
                        }

                    // ------------------------------------------- Q5 ------------------------------------------------
                    if(qno == 5) {
                        Statement stmt = conn.createStatement();
                        String query = "SELECT D.department_id , D.department_name , SUM(E.SALARY) AS SAL FROM HR.EMPLOYEES E , HR.DEPARTMENTS D WHERE D.department_id=E.department_id GROUP BY (D.department_id,D.department_name) HAVING SUM(E.SALARY)>10000";
                        try{
                            ResultSet rs = stmt.executeQuery(query);
                            while(rs.next()){
                            int dID = rs.getInt("department_id");
                            String dName= rs.getString("department_name");
                            int sal = rs.getInt("SAL");
                            System.out.println(dID + "\t" + dName + "\t" + sal);
                            
                            }
                        }
                        catch(Exception E){
                            System.out.println(E.getMessage());
                        }
                        }

                }

            } catch (Exception E) {
                System.err.println(E.getMessage());
            }
        } else {
            System.out.println("DB not connected");
        }
    }
    
}
