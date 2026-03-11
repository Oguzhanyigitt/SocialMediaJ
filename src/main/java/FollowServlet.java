import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/follow")
public class FollowServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentUser = (String) request.getSession().getAttribute("user");
        String action = request.getParameter("action");
        int followedId = Integer.parseInt(request.getParameter("followed_id"));

        if ("follow".equals(action)) {
            try (Connection con = DBUtil.getConnection()) {
                String followQuery = "INSERT INTO Followers (follower_id, followed_id) VALUES ((SELECT user_id FROM users WHERE username = ?), ?)";
                PreparedStatement pst = con.prepareStatement(followQuery);
                pst.setString(1, currentUser);
                pst.setInt(2, followedId);
                pst.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("unfollow".equals(action)) {
            try (Connection con = DBUtil.getConnection()) {
                String unfollowQuery = "DELETE FROM Followers WHERE follower_id = (SELECT user_id FROM users WHERE username = ?) AND followed_id = ?";
                PreparedStatement pst = con.prepareStatement(unfollowQuery);
                pst.setString(1, currentUser);
                pst.setInt(2, followedId);
                pst.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("home.jsp");
    }
}
