import com.socialmedia.util.DBUtil;
import org.mindrot.jbcrypt.BCrypt;
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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");

        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty() || 
            email == null || email.trim().isEmpty()) {
            response.sendRedirect("index.jsp?error=register_failed");
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

        try (Connection con = DBUtil.getConnection()) {
            String checkQuery = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
            try (PreparedStatement checkPst = con.prepareStatement(checkQuery)) {
                checkPst.setString(1, username);
                checkPst.setString(2, email);
                try (ResultSet rs = checkPst.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect("index.jsp?error=register_failed");
                        return;
                    }
                }
            }

            String insertQuery = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(insertQuery)) {
                pst.setString(1, username);
                pst.setString(2, hashedPassword);
                pst.setString(3, email);
                pst.executeUpdate();
            }
            response.sendRedirect("index.jsp?success=registered");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=register_failed");
        }
    }
}