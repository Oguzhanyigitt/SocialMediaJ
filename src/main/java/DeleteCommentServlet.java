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

@WebServlet("/deleteComment")
public class DeleteCommentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String commentIdStr = request.getParameter("commentId");

        if (commentIdStr != null && !commentIdStr.trim().isEmpty()) {
            try (Connection con = DBUtil.getConnection()) {
                // GÜVENLİK: Sadece kendi yorumunu silebilir
                String query = "DELETE FROM Comments WHERE comment_id = ? AND user_id = ?";
                try (PreparedStatement pst = con.prepareStatement(query)) {
                    pst.setInt(1, Integer.parseInt(commentIdStr));
                    pst.setInt(2, userId);
                    pst.executeUpdate();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("home");
    }
}