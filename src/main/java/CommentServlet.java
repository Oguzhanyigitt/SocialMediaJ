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
        String postIdStr = request.getParameter("postId"); // home.jsp'deki formda name="postId" yaptık
        String content = request.getParameter("content");

        // Mantık Kontrolü: Yorum boş mu?
        if (content == null || content.trim().isEmpty() || postIdStr == null || postIdStr.trim().isEmpty()) {
            response.sendRedirect("home?error=empty_comment");
            return;
        }

        int postId;
        try {
            postId = Integer.parseInt(postIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("home?error=invalid_post");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            String insertCommentQuery = "INSERT INTO Comments (user_id, post_id, content) VALUES (?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(insertCommentQuery)) {
                pst.setInt(1, userId);
                pst.setString(2, content.trim()); // Başındaki ve sonundaki boşlukları temizleyerek kaydediyoruz
                pst.executeUpdate();
            }
            
            // Başarılı olursa yine ana Servlet'e dönüyoruz
            response.sendRedirect("home");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}