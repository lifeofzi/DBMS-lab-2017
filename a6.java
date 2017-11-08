/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package javaapplication5;
import java.sql.*;
import java.util.*;
import java.io.PrintWriter;
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
        System.out.println("-------- Assignment 6  ------");
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
                      //1. Write a JDBC Application to display jobs where the 
                      //minimum salary is less than salary of a given employee. 
                      PreparedStatement p_stmt=null;
                      System.out.println("Enter employee ID number:");
                      int eID=sc.nextInt();
                      p_stmt = conn.prepareCall("SELECT J.job_title , J.min_salary , E.Salary FROM HR.Employees E , HR.Jobs J WHERE J.job_id=E.job_id AND E.employee_id=? AND E.Salary>J.min_salary");
                      p_stmt.setInt(1, eID);
                      ResultSet rs = p_stmt.executeQuery();
                      System.out.println("Job Title      Minimum Salary      Salary");
                      while(rs.next()){
                          String job = rs.getString("Job_Title");
                          String min_sal = rs.getString("Min_Salary");
                          String sal = rs.getString("Salary");
                          System.out.println(job+"      "+min_sal+"       "+sal);
                        }
                      
                      
                      System.out.println(" -------Successful ! ");
                    }
                        // ------------------------------------------- Q2 ------------------------------------------------
    
                     if(qno == 2) {
                         
                         //2. Write a JDBC Application calling a procedure to find out the 
                         //name of the employee and name of the department for the employee 
                         //who is the manager for a given employee ID.
                         // -- getManagerNameEid is the procedure name
                         System.out.println("Enter Employee ID : ");
                         int eID = sc.nextInt();
                         CallableStatement c_stmt = null;
                         c_stmt = conn.prepareCall("{call getManagerNameEid(?,?,?)}");
                         c_stmt.setInt(1, eID);
                         c_stmt.registerOutParameter(2, Types.VARCHAR);                //NOTE
                         c_stmt.registerOutParameter(3, Types.INTEGER);
                         c_stmt.execute();
                         String name = c_stmt.getString(2);
                         int dID = c_stmt.getInt(3);
                         System.out.println(name+"  "+dID);
                         System.out.println("Successful !");
                     }
                     

                        // ------------------------------------------- Q3 ------------------------------------------------
                    if(qno == 3) {
                       //Write a JDBC application to show the job title and name of those employees 
                      //who have been hired after a given date (supplied by user), 
                      // and who have a manager working in a given department (supplied by user). [Use cursor]
                        
                         System.out.println("Enter Date DD-MM-YY : ");
                         String date=sc.next();
                         System.out.println("Enter department ID :");
                         int dID = sc.nextInt();
                         PreparedStatement p_stmt = null; 
                         p_stmt = conn.prepareCall("SELECT J.job_title , E.first_Name , E.hire_date FROM HR.Employees E, HR.Jobs J WHERE E.hire_date < ? AND manager_id IN (SELECT manager_id FROM HR.Employees WHERE department_id= ?) AND E.job_id=J.job_id");
                         //1 is date 2 is depID
                         p_stmt.setString(1, date);
                         p_stmt.setInt(2, dID);
                         ResultSet rs = p_stmt.executeQuery();
                         while(rs.next()){
                             String job=rs.getString("job_title");
                             String name=rs.getString("first_name");
                             String hire_date=rs.getString("hire_date");
                             System.out.println(job+"       "+name+"      "+hire_date);
                         }
                         System.out.println("  Successful !");
                        }

                    // ------------------------------------------- Q4 ------------------------------------------------
                    if(qno == 4) {
                        
                        System.out.println(" Successful !");
                        
                        }

                    // ------------------------------------------- Q5 ------------------------------------------------
                    if(qno == 5) {
                        Statement stmt = conn.createStatement();
                        String query = "SELECT D.department_id , D.department_name , SUM(E.SALARY) AS SAL FROM HR.EMPLOYEES E , HR.DEPARTMENTS D WHERE D.department_id=E.department_id GROUP BY (D.department_id,D.department_name) HAVING SUM(E.SALARY)>10000";
                        PrintWriter writer = new PrintWriter("C:\\Users\\Carpe\\Desktop\\SQLAssignments\\report.csv","UTF-8");
                        writer.println("Department ID ,Department Name,Salary");
                        
                        ResultSet rs = stmt.executeQuery(query);
                        while(rs.next()){
                        int dID = rs.getInt("department_id");
                        String dName= rs.getString("department_name");
                        int sal = rs.getInt("SAL");
                        writer.println(dID + "," + dName + "," + sal);
                         }
                        writer.close();    
                        
                   
                    }   
                     // ------------------------------------------- Q6 ------------------------------------------------
                    if(qno == 6) {
                        Statement stmt = conn.createStatement();
                        String query = "Select M.department_id ,M.first_name||' '||M.last_name as ManName, E.first_name||' '||E.last_Name as EmpName, E.Salary FROM HR.Employees E , HR.Employees M WHERE E.manager_id = M.employee_id ORDER BY department_id" ;
                        PrintWriter writer = new PrintWriter("C:\\Users\\Carpe\\Desktop\\SQLAssignments\\reportQ6.csv","UTF-8");
                        writer.println("Department ID ,Manager Name,Employee Name,Salary");
                        
                        ResultSet rs = stmt.executeQuery(query);
                        boolean a=true;
                        int dIDOld=0;
                        
                        int totalSal=0;
                        while(rs.next()){
                        if(a){                             
                            dIDOld=rs.getInt("department_id");
                            a = false;
                        }    
                        int dID = rs.getInt("department_id");
                        if(dIDOld == dID){
                            String ManName= rs.getString("ManName");
                            String EmpName= rs.getString("EmpName");
                            int sal = rs.getInt("Salary");
                            totalSal=totalSal+sal;
                            writer.println(dID + "," + ManName + "," + EmpName+","+sal);
                        }
                        else if (dIDOld != dID){
                            writer.println("----------------------------,-------------------------------,--------------------------,----------");
                            writer.println(" ,"+"Total Salary of "+dIDOld+" is : , "+totalSal);
                            writer.println("----------------------------,-------------------------------,---------------------------,-----------------");
                            dIDOld = dID;
                            totalSal = 0;
                        }
                        }
                        writer.close();  
                        System.out.println("Finish");
                         }
                    
                    if(qno == -1) {
                            System.out.println("Exit");
                            break;
                            
                         }
                }
            }
                      
             catch (Exception E) {
                System.err.println(E.getMessage());
            }
        } else {
            System.out.println("DB not connected");
        }
    }
    
}
