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
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/like")
public class LikeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Güvenlik ve Mantık Kontrolü: Oturum yoksa veya userId session'da değilse
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String postIdStr = request.getParameter("post_id");

        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            response.sendRedirect("home?error=invalid_post");
            return;
        }

        int postId = Integer.parseInt(postIdStr);

        try (Connection con = DBUtil.getConnection()) {
            // Adım 1: Kullanıcı bu postu daha önce beğenmiş mi?
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

            // Adım 2: Duruma göre Ekle veya Sil (Toggle Mantığı)
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

            // İşlem bittiğinde, JSP dosyasına değil, veri toplayıcı Servlet'e yönlendiriyoruz
            response.sendRedirect("home");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}