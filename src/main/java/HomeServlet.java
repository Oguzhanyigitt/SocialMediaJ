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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int currentUserId = (int) session.getAttribute("userId");
        List<Map<String, Object>> posts = new ArrayList<>();

        try (Connection con = DBUtil.getConnection()) {
            // Ana Sorgu: Gönderiler, Yazar Bilgisi ve Toplam Beğeni Sayısı
            String postQuery = "SELECT p.post_id, p.content, p.media_url, p.created_at, u.user_id, u.username, u.profile_pic, " +
                               "(SELECT COUNT(*) FROM Likes l WHERE l.post_id = p.post_id) AS like_count, " +
                               "(SELECT COUNT(*) FROM Likes l2 WHERE l2.post_id = p.post_id AND l2.user_id = ?) AS is_liked " +
                               "FROM Posts p JOIN users u ON p.user_id = u.user_id ORDER BY p.created_at DESC";

            try (PreparedStatement pst = con.prepareStatement(postQuery)) {
                pst.setInt(1, currentUserId);
                
                try (ResultSet rs = pst.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> post = new HashMap<>();
                        int postId = rs.getInt("post_id");
                        post.put("postId", postId);
                        post.put("content", rs.getString("content"));
                        post.put("mediaUrl", rs.getString("media_url"));
                        post.put("createdAt", rs.getTimestamp("created_at"));
                        post.put("authorId", rs.getInt("user_id"));
                        post.put("authorName", rs.getString("username"));
                        post.put("authorPic", rs.getString("profile_pic"));
                        post.put("likeCount", rs.getInt("like_count"));
                        post.put("isLiked", rs.getInt("is_liked") > 0);

                        // Yorumları Çekme (Hala bir döngü içindeyiz ama en azından DB bağlantısı JSP'den Java'ya taşındı ve tek connection üzerinden yürüyor)
                        List<Map<String, String>> comments = new ArrayList<>();
                        String commentQuery = "SELECT c.content, u.username FROM Comments c JOIN users u ON c.user_id = u.user_id WHERE c.post_id = ? ORDER BY c.created_at ASC";
                        try (PreparedStatement cPst = con.prepareStatement(commentQuery)) {
                            cPst.setInt(1, postId);
                            try (ResultSet cRs = cPst.executeQuery()) {
                                while (cRs.next()) {
                                    Map<String, String> comment = new HashMap<>();
                                    comment.put("username", cRs.getString("username"));
                                    comment.put("content", cRs.getString("content"));
                                    comments.add(comment);
                                }
                            }
                        }
                        post.put("comments", comments);
                        posts.add(post);
                    }
                }
            }
            
            // Veriyi hazırladık, şimdi vitrine (JSP) gönderiyoruz
            request.setAttribute("posts", posts);
            request.getRequestDispatcher("home.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=db");
        }
    }
}