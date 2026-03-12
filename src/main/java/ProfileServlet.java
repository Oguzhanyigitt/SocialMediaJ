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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        int currentUserId = (int) session.getAttribute("userId");
        String targetUsername = request.getParameter("username");

        if (targetUsername == null || targetUsername.trim().isEmpty()) {
            response.sendRedirect("home");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            // 1. Hedef Kullanıcı Bilgilerini Çek
            String userQuery = "SELECT user_id, email, profile_pic FROM users WHERE username = ?";
            int targetUserId = -1;
            String targetEmail = "";
            String targetProfilePic = null;

            try (PreparedStatement uPst = con.prepareStatement(userQuery)) {
                uPst.setString(1, targetUsername);
                try (ResultSet uRs = uPst.executeQuery()) {
                    if (uRs.next()) {
                        targetUserId = uRs.getInt("user_id");
                        targetEmail = uRs.getString("email");
                        targetProfilePic = uRs.getString("profile_pic");
                    } else {
                        response.sendRedirect("home?error=user_not_found");
                        return;
                    }
                }
            }

            boolean isOwnProfile = (currentUserId == targetUserId);

            // 2. Takipçi Sayısını Çek
            int followerCount = 0;
            String followerQuery = "SELECT COUNT(*) FROM Followers WHERE followed_id = ?";
            try (PreparedStatement fPst = con.prepareStatement(followerQuery)) {
                fPst.setInt(1, targetUserId);
                try (ResultSet fRs = fPst.executeQuery()) {
                    if (fRs.next()) followerCount = fRs.getInt(1);
                }
            }

            // 3. Biz bu kullanıcıyı takip ediyor muyuz?
            boolean isFollowing = false;
            if (!isOwnProfile) {
                String checkFollowQuery = "SELECT COUNT(*) FROM Followers WHERE follower_id = ? AND followed_id = ?";
                try (PreparedStatement checkPst = con.prepareStatement(checkFollowQuery)) {
                    checkPst.setInt(1, currentUserId);
                    checkPst.setInt(2, targetUserId);
                    try (ResultSet cRs = checkPst.executeQuery()) {
                        if (cRs.next()) isFollowing = cRs.getInt(1) > 0;
                    }
                }
            }

            // 4. Hedef Kullanıcının Gönderilerini Çek (Beğenme durumu da eklendi)
            List<Map<String, Object>> posts = new ArrayList<>();
            List<Integer> postIds = new ArrayList<>();
            
            String postQuery = "SELECT p.post_id, p.content, p.media_url, p.created_at, " +
                               "(SELECT COUNT(*) FROM Likes l WHERE l.post_id = p.post_id) AS like_count, " +
                               "(SELECT COUNT(*) FROM Likes l2 WHERE l2.post_id = p.post_id AND l2.user_id = ?) AS is_liked " +
                               "FROM Posts p WHERE p.user_id = ? ORDER BY p.created_at DESC";
                               
            try (PreparedStatement pPst = con.prepareStatement(postQuery)) {
                pPst.setInt(1, currentUserId); // is_liked kontrolü için kendi ID'miz
                pPst.setInt(2, targetUserId);  // Gönderilerini çektiğimiz kişinin ID'si
                try (ResultSet pRs = pPst.executeQuery()) {
                    while (pRs.next()) {
                        Map<String, Object> post = new HashMap<>();
                        int postId = pRs.getInt("post_id");
                        post.put("postId", postId);
                        post.put("content", pRs.getString("content"));
                        post.put("mediaUrl", pRs.getString("media_url"));
                        post.put("createdAt", pRs.getTimestamp("created_at"));
                        post.put("likeCount", pRs.getInt("like_count"));
                        post.put("isLiked", pRs.getInt("is_liked") > 0);
                        post.put("comments", new ArrayList<Map<String, String>>()); // Yorumlar için boş liste
                        
                        posts.add(post);
                        postIds.add(postId);
                    }
                }
            }

            // 5. Yorumları Çek (Senin istediğin eksik parçayı ekliyoruz)
            if (!postIds.isEmpty()) {
                String inClause = postIds.stream().map(String::valueOf).collect(Collectors.joining(","));
                String commentQuery = "SELECT c.comment_id, c.post_id, c.user_id, c.content, u.username " +
                                      "FROM Comments c JOIN users u ON c.user_id = u.user_id " +
                                      "WHERE c.post_id IN (" + inClause + ") ORDER BY c.created_at ASC";
                
                try (PreparedStatement cPst = con.prepareStatement(commentQuery);
                     ResultSet cRs = cPst.executeQuery()) {
                    
                    while (cRs.next()) {
                        int pId = cRs.getInt("post_id");
                        Map<String, String> comment = new HashMap<>();
                        comment.put("commentId", String.valueOf(cRs.getInt("comment_id")));
                        comment.put("userId", String.valueOf(cRs.getInt("user_id")));
                        comment.put("username", cRs.getString("username"));
                        comment.put("content", cRs.getString("content"));

                        for (Map<String, Object> p : posts) {
                            if ((Integer) p.get("postId") == pId) {
                                ((List<Map<String, String>>) p.get("comments")).add(comment);
                                break;
                            }
                        }
                    }
                }
            }

            // Verileri JSP'ye aktar
            request.setAttribute("targetUsername", targetUsername);
            request.setAttribute("targetUserId", targetUserId);
            request.setAttribute("targetEmail", targetEmail);
            request.setAttribute("targetProfilePic", targetProfilePic != null ? targetProfilePic : "https://via.placeholder.com/150");
            request.setAttribute("followerCount", followerCount);
            request.setAttribute("isOwnProfile", isOwnProfile);
            request.setAttribute("isFollowing", isFollowing);
            request.setAttribute("posts", posts);

            request.getRequestDispatcher("/profile.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}