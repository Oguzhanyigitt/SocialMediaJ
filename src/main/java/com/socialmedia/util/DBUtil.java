package com.socialmedia.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL = "jdbc:mysql://mysql://ug7pr3pldqy48wti:7mmbBUrjEq1VagR2x8NI@bumany9xxetbkgcw7gl2-mysql.services.clever-cloud.com:3306/bumany9xxetbkgcw7gl2:3306/bumany9xxetbkgcw7gl2?useSSL=false&serverTimezone=UTC";;
    private static final String USER = "ug7pr3pldqy48wti";
    private static final String PASSWORD = "7mmbBUrjEq1VagR2x8NI";

    public static Connection getConnection() throws SQLException {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); 
    } catch (ClassNotFoundException e) {
        throw new SQLException("MySQL Driver not found.", e);
    }
    return DriverManager.getConnection(URL, USER, PASSWORD);
}
}