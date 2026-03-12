import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/deletePost")
public class DeletePostServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String postIdStr = request.getParameter("postId");
        String redirect = request.getParameter("redirect"); // Nereden silindi? (home veya profile)

        if (postIdStr != null && !postIdStr.trim().isEmpty()) {
            try (Connection con = DBUtil.getConnection()) {
                // GÜVENLİK: Sadece post_id değil, user_id de eşleşiyorsa silinir!
                String query = "DELETE FROM Posts WHERE post_id = ? AND user_id = ?";
                try (PreparedStatement pst = con.prepareStatement(query)) {
                    pst.setInt(1, Integer.parseInt(postIdStr));
                    pst.setInt(2, userId);
                    pst.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Kullanıcıyı geldiği sayfaya geri gönder
        if ("profile".equals(redirect)) {
        	String encodedUser = java.net.URLEncoder.encode((String)session.getAttribute("user"), "UTF-8");
        	response.sendRedirect("profile?username=" + encodedUser);
        } else {
            response.sendRedirect("home");
        }
    }
}