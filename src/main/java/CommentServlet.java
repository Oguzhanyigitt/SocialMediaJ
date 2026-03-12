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

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String postIdStr = request.getParameter("postId");
        String content = request.getParameter("content");

        // Mantık Kontrolü: Veriler boş mu?
        if (content == null || content.trim().isEmpty() || postIdStr == null || postIdStr.trim().isEmpty()) {
            response.sendRedirect("home?error=empty_comment");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            // Sorguda 3 parametre var: user_id (1), post_id (2), content (3)
            String insertCommentQuery = "INSERT INTO Comments (user_id, post_id, content) VALUES (?, ?, ?)";
            
            try (PreparedStatement pst = con.prepareStatement(insertCommentQuery)) {
                pst.setInt(1, userId);
                pst.setInt(2, Integer.parseInt(postIdStr));
                pst.setString(3, content.trim()); // HATA BURADAYDI: 3. parametre eksik veya yanlış set ediliyordu
                
                pst.executeUpdate();
            }
            
            response.sendRedirect("home");

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}