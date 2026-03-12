
import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/like")
public class LikeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String postIdStr = request.getParameter("post_id");
        
        // Yönlendirme parametrelerini yakala
        String from = request.getParameter("from");
        String targetUsername = request.getParameter("targetUsername");

        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            redirectBack(response, from, targetUsername, "invalid_post");
            return;
        }

        int postId = Integer.parseInt(postIdStr);

        try (Connection con = DBUtil.getConnection()) {
            String checkLikeQuery = "SELECT COUNT(*) FROM Likes WHERE user_id = ? AND post_id = ?";
            boolean isLiked = false;
            
            try (PreparedStatement checkPst = con.prepareStatement(checkLikeQuery)) {
                checkPst.setInt(1, userId);
                checkPst.setInt(2, postId);
                try (ResultSet rs = checkPst.executeQuery()) {
                    if (rs.next()) {
                        isLiked = rs.getInt(1) > 0;
                    }
                }
            }

            if (isLiked) {
                String deleteLikeQuery = "DELETE FROM Likes WHERE user_id = ? AND post_id = ?";
                try (PreparedStatement deletePst = con.prepareStatement(deleteLikeQuery)) {
                    deletePst.setInt(1, userId);
                    deletePst.setInt(2, postId);
                    deletePst.executeUpdate();
                }
            } else {
                String insertLikeQuery = "INSERT INTO Likes (user_id, post_id) VALUES (?, ?)";
                try (PreparedStatement insertPst = con.prepareStatement(insertLikeQuery)) {
                    insertPst.setInt(1, userId);
                    insertPst.setInt(2, postId);
                    insertPst.executeUpdate();
                }
            }

            redirectBack(response, from, targetUsername, null);

        } catch (SQLException e) {
            e.printStackTrace();
            redirectBack(response, from, targetUsername, "db_error");
        }
    }
    
    // Akıllı yönlendirme metodu
    private void redirectBack(HttpServletResponse response, String from, String targetUsername, String error) throws IOException {
        String errorParam = (error != null) ? "&error=" + error : "";
        if ("profile".equals(from) && targetUsername != null && !targetUsername.trim().isEmpty()) {
            String encodedTarget = URLEncoder.encode(targetUsername, "UTF-8");
            response.sendRedirect("profile?username=" + encodedTarget + errorParam);
        } else {
            response.sendRedirect("home" + (error != null ? "?error=" + error : ""));
        }
    }
}