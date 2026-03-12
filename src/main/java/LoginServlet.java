import com.socialmedia.util.DBUtil;
import org.mindrot.jbcrypt.BCrypt;
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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect("index.jsp?error=loginError");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            String query = "SELECT user_id, password FROM users WHERE username = ?";
            try (PreparedStatement pst = con.prepareStatement(query)) {
                pst.setString(1, username);
                
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        String storedHash = rs.getString("password");
                        int userId = rs.getInt("user_id");
                        
                        // Güvenlik: Kullanıcının girdiği düz şifre ile veritabanındaki hash eşleşiyor mu?
                        if (BCrypt.checkpw(password, storedHash)) {
                            HttpSession session = request.getSession();
                            session.setAttribute("user", username);
                            session.setAttribute("userId", userId); // Performans iyileştirmesi: ID'yi session'a aldık
                            response.sendRedirect("home");
                        } else {
                            response.sendRedirect("index.jsp?error=loginError");
                        }
                    } else {
                        response.sendRedirect("index.jsp?error=loginError");
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=loginError");
        }
    }
}