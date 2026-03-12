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

        // Mantık Kontrolü 1: Gelen veriler boş olamaz
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty() || 
            email == null || email.trim().isEmpty()) {
            response.sendRedirect("index.jsp?error=registerError");
            return;
        }

        // Güvenlik: Şifreyi BCrypt ile tuzlayarak (salt) hashliyoruz
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

        try (Connection con = DBUtil.getConnection()) {
            // Mantık Kontrolü 2: Bu kullanıcı adı veya e-posta zaten kullanımda mı?
            String checkQuery = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
            try (PreparedStatement checkPst = con.prepareStatement(checkQuery)) {
                checkPst.setString(1, username);
                checkPst.setString(2, email);
                try (ResultSet rs = checkPst.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        // Kullanıcı zaten var, farklı bir hata mesajıyla döndürebiliriz
                        response.sendRedirect("index.jsp?error=registerError");
                        return;
                    }
                }
            }

            // Güvenli Kayıt İşlemi
            String insertQuery = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(insertQuery)) {
                pst.setString(1, username);
                pst.setString(2, hashedPassword); // Orijinal şifre yerine hashlenmiş versiyon gidiyor
                pst.setString(3, email);
                pst.executeUpdate();
            }
            response.sendRedirect("index.jsp?registration=success");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=registerError");
        }
    }
}