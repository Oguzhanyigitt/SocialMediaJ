package com.socialmedia.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/social_media_app";
    private static final String USER = "Kullanıcı Adın";
    private static final String PASSWORD = "Şifren";

    public static Connection getConnection() throws SQLException {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); 
    } catch (ClassNotFoundException e) {
        throw new SQLException("MySQL Driver not found.", e);
    }
    return DriverManager.getConnection(URL, USER, PASSWORD);
}
}