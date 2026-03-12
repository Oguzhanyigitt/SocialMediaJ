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
import java.sql.SQLException;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String postIdStr = request.getParameter("postId");
        String content = request.getParameter("content");
        
        // Nereden geldiğimizi yakalıyoruz
        String from = request.getParameter("from");
        String targetUsername = request.getParameter("targetUsername");

        if (content == null || content.trim().isEmpty() || postIdStr == null || postIdStr.trim().isEmpty()) {
            redirectBack(response, from, targetUsername, "empty_comment");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            String insertCommentQuery = "INSERT INTO Comments (user_id, post_id, content) VALUES (?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(insertCommentQuery)) {
                pst.setInt(1, userId);
                pst.setInt(2, Integer.parseInt(postIdStr));
                pst.setString(3, content.trim());
                pst.executeUpdate();
            }
            redirectBack(response, from, targetUsername, null);

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            redirectBack(response, from, targetUsername, "db_error");
        }
    }

    // Yönlendirmeyi (Redirect) güvenli ve akıllıca yöneten yardımcı metod
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