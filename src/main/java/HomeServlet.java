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
import java.util.stream.Collectors;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        int currentUserId = (int) session.getAttribute("userId");
        List<Map<String, Object>> posts = new ArrayList<>();
        List<Integer> postIds = new ArrayList<>(); // Yorumları tek seferde çekmek için ID'leri biriktiriyoruz

        try (Connection con = DBUtil.getConnection()) {
            // SORGÚ 1: Sadece Gönderileri Çek
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
                        post.put("authorPic", rs.getString("profile_pic") != null ? rs.getString("profile_pic") : "https://via.placeholder.com/40");
                        post.put("likeCount", rs.getInt("like_count"));
                        post.put("isLiked", rs.getInt("is_liked") > 0);
                        post.put("comments", new ArrayList<Map<String, String>>()); // Başlangıçta boş yorum listesi
                        
                        posts.add(post);
                        postIds.add(postId);
                    }
                }
            }
            
            // SORGÚ 2: Tüm Yorumları TEK SEFERDE Çek (N+1 Problemini Çözen Kısım)
            if (!postIds.isEmpty()) {
                // postIds listesini virgülle ayrılmış bir string'e çeviriyoruz (örnek: "1,2,5,10")
                String inClause = postIds.stream().map(String::valueOf).collect(Collectors.joining(","));
                String commentQuery = "SELECT c.comment_id, c.post_id, c.user_id, c.content, u.username " +
                                      "FROM Comments c JOIN users u ON c.user_id = u.user_id " +
                                      "WHERE c.post_id IN (" + inClause + ") ORDER BY c.created_at ASC";
                
                try (PreparedStatement cPst = con.prepareStatement(commentQuery);
                     ResultSet cRs = cPst.executeQuery()) {
                    
                    // Gelen yorumları ait oldukları post'un listesine yerleştir
                    while (cRs.next()) {
                        int pId = cRs.getInt("post_id");
                        Map<String, String> comment = new HashMap<>();
                        comment.put("commentId", String.valueOf(cRs.getInt("comment_id")));
                        comment.put("userId", String.valueOf(cRs.getInt("user_id")));
                        comment.put("username", cRs.getString("username"));
                        comment.put("content", cRs.getString("content"));

                        // Hangi post'a aitse onu bulup listesine ekle
                        for (Map<String, Object> p : posts) {
                            if ((Integer) p.get("postId") == pId) {
                                ((List<Map<String, String>>) p.get("comments")).add(comment);
                                break;
                            }
                        }
                    }
                }
            }
            
            request.setAttribute("posts", posts);
            request.getRequestDispatcher("/home.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=db_error");
        }
    }
}