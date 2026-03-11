import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");

        if (username != null && !username.isEmpty()) {
            try (Connection con = DBUtil.getConnection()) {
                String userQuery = "SELECT user_id,email,profile_pic FROM users WHERE username = ?";
                PreparedStatement userPst = con.prepareStatement(userQuery);
                userPst.setString(1, username);
                ResultSet userRs = userPst.executeQuery();

                if (userRs.next()) {
                    String userEmail = userRs.getString("email");
                    String profilePic = userRs.getString("profile_pic");
                    int userId = userRs.getInt("user_id"); 

                    request.setAttribute("username", username);
                    request.setAttribute("userEmail", userEmail);
                    request.setAttribute("userProfilePic", profilePic);
                    request.setAttribute("userId", userId); 

                    request.getRequestDispatcher("profile.jsp").forward(request, response);
                } else {
                    System.out.println("User not found for username: " + username);
                    response.sendRedirect("error.jsp"); 
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("error.jsp");
            }
        } else {
            response.sendRedirect("error.jsp");
        }
    }
}
