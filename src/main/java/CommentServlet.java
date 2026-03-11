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
import java.sql.SQLException;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));
        String commentContent = request.getParameter("comment");

        try (Connection con = DBUtil.getConnection()) {
            String getUserIdQuery = "SELECT user_id FROM users WHERE username = ?";
            PreparedStatement getUserIdPst = con.prepareStatement(getUserIdQuery);
            getUserIdPst.setString(1, username);
            ResultSet rs = getUserIdPst.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");

                String insertCommentQuery = "INSERT INTO Comments (user_id, post_id, content) VALUES (?, ?, ?)";
                PreparedStatement insertCommentPst = con.prepareStatement(insertCommentQuery);
                insertCommentPst.setInt(1, userId);
                insertCommentPst.setInt(2, postId);
                insertCommentPst.setString(3, commentContent);
                insertCommentPst.executeUpdate();
            }

            response.sendRedirect("home.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?error=true");
        }
    }
}
