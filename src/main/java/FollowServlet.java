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

@WebServlet("/follow")
public class FollowServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int currentUserId = (int) session.getAttribute("userId");
        String followedIdStr = request.getParameter("followed_id");
        String targetUsername = request.getParameter("target_username"); // Geri dönüş için gerekli

        if (followedIdStr == null || followedIdStr.trim().isEmpty() || targetUsername == null) {
            response.sendRedirect("home");
            return;
        }

        int followedId = Integer.parseInt(followedIdStr);

        // Kendi kendini takip etmeyi engelle (Mantık kontrolü)
        if (currentUserId == followedId) {
            response.sendRedirect("profile?username=" + targetUsername);
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            // Takip ediyor muyuz kontrolü
            String checkQuery = "SELECT COUNT(*) FROM Followers WHERE follower_id = ? AND followed_id = ?";
            boolean isFollowing = false;
            try (PreparedStatement checkPst = con.prepareStatement(checkQuery)) {
                checkPst.setInt(1, currentUserId);
                checkPst.setInt(2, followedId);
                try (ResultSet rs = checkPst.executeQuery()) {
                    if (rs.next()) isFollowing = rs.getInt(1) > 0;
                }
            }

            // Toggle (Aç/Kapat) Mantığı
            if (isFollowing) {
                String unfollowQuery = "DELETE FROM Followers WHERE follower_id = ? AND followed_id = ?";
                try (PreparedStatement delPst = con.prepareStatement(unfollowQuery)) {
                    delPst.setInt(1, currentUserId);
                    delPst.setInt(2, followedId);
                    delPst.executeUpdate();
                }
            } else {
                String followQuery = "INSERT INTO Followers (follower_id, followed_id) VALUES (?, ?)";
                try (PreparedStatement insPst = con.prepareStatement(followQuery)) {
                    insPst.setInt(1, currentUserId);
                    insPst.setInt(2, followedId);
                    insPst.executeUpdate();
                }
            }

            // İşlem bittiğinde aynı profile geri dönüyoruz
            response.sendRedirect("profile?username=" + targetUsername);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}