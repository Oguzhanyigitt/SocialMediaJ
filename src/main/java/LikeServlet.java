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

@WebServlet("/like")
public class LikeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(request.getParameter("post_id"));

        try (Connection con = DBUtil.getConnection()) {
            String getUserIdQuery = "SELECT user_id FROM Users WHERE username = ?";
            PreparedStatement getUserIdPst = con.prepareStatement(getUserIdQuery);
            getUserIdPst.setString(1, username);
            ResultSet rs = getUserIdPst.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("user_id");

                String checkLikeQuery = "SELECT COUNT(*) FROM Likes WHERE user_id = ? AND post_id = ?";
                PreparedStatement checkLikePst = con.prepareStatement(checkLikeQuery);
                checkLikePst.setInt(1, userId);
                checkLikePst.setInt(2, postId);
                ResultSet checkRs = checkLikePst.executeQuery();

                if (checkRs.next() && checkRs.getInt(1) == 0) {
                    String insertLikeQuery = "INSERT INTO Likes (user_id, post_id) VALUES (?, ?)";
                    PreparedStatement insertLikePst = con.prepareStatement(insertLikeQuery);
                    insertLikePst.setInt(1, userId);
                    insertLikePst.setInt(2, postId);
                    insertLikePst.executeUpdate();
                } else {
                    String deleteLikeQuery = "DELETE FROM Likes WHERE user_id = ? AND post_id = ?";
                    PreparedStatement deleteLikePst = con.prepareStatement(deleteLikeQuery);
                    deleteLikePst.setInt(1, userId);
                    deleteLikePst.setInt(2, postId);
                    deleteLikePst.executeUpdate();
                }
            }

            response.sendRedirect("home.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?error=true");
        }
    }
}
