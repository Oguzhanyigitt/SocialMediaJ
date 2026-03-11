<%@ page import="com.socialmedia.util.DBUtil" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ana Sayfa - Sosyal Medya</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding-top: 56px; }
        .navbar { margin-bottom: 20px; }
        .post { margin-bottom: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 5px; background-color: #f9f9f9; }
        .media { max-width: 100%; height: auto; }
        .like-button, .comment-button, .follow-button { cursor: pointer; }
        .alert { margin-top: 20px; }
        .comment { border-top: 1px solid #ddd; padding-top: 10px; margin-top: 10px; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
    <a class="navbar-brand" href="#">Sosyal Medya</a>
    <div class="collapse navbar-collapse">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item active">
                <a class="nav-link" href="home.jsp">Ana Sayfa <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="profile?username=<%= session.getAttribute("user") %>">Profil <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="logout.jsp">Çıkış Yap</a>
            </li>
        </ul>
        
        <!-- Arama Formu -->
        <form class="form-inline my-2 my-lg-0" action="profile" method="get">
            <input class="form-control mr-sm-2" type="search" placeholder="Kullanıcı Ara" aria-label="Search" name="username">
            <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Ara</button>
        </form>
    </div>
</nav>



<div class="container mt-4">
    <h1>Hoş Geldin, <%= session.getAttribute("user") %>!</h1>

    <div class="mb-4">
        <h2>Bir Şeyler Paylaş</h2>
        <form action="post" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <textarea class="form-control" name="content" placeholder="Aklında ne var?" rows="3" required></textarea>
            </div>
            <div class="form-group">
                <input type="file" name="media" class="form-control-file">
            </div>
            <button type="submit" class="btn btn-primary">Paylaş</button>
        </form>
    </div>

    <% if ("alreadyLiked".equals(request.getParameter("error"))) { %>
        <div class="alert alert-warning">Bu gönderiyi daha önce beğendin.</div>
    <% } %>
    <% if ("true".equals(request.getParameter("error"))) { %>
        <div class="alert alert-danger">Hata.</div>
    <% } %>

    <h2>Son Gönderiler</h2>
    <%
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        try {
            con = DBUtil.getConnection();
            String query = "SELECT p.post_id, p.user_id, p.content, p.media_url, p.created_at, u.username, COUNT(l.like_id) AS like_count FROM Posts p LEFT JOIN Users u ON p.user_id = u.user_id LEFT JOIN Likes l ON p.post_id = l.post_id GROUP BY p.post_id ORDER BY p.created_at DESC";
            pst = con.prepareStatement(query);
            rs = pst.executeQuery();
            while (rs.next()) {
                int postId = rs.getInt("post_id");
                String username = rs.getString("username");
                String content = rs.getString("content");
                String mediaUrl = rs.getString("media_url");
                int likeCount = rs.getInt("like_count");

                String followCheckQuery = "SELECT COUNT(*) FROM Followers WHERE follower_id = (SELECT user_id FROM Users WHERE username = ?) AND followed_id = ?";
                PreparedStatement followCheckPst = con.prepareStatement(followCheckQuery);
                followCheckPst.setString(1, (String) session.getAttribute("user"));
                followCheckPst.setInt(2, rs.getInt("user_id"));
                ResultSet followCheckRs = followCheckPst.executeQuery();
                followCheckRs.next();
                boolean followed = followCheckRs.getInt(1) > 0;
    %>
    <div class="post">
        <h4>
            <a href="profile?username=<%= username %>" style="text-decoration: none;">
                <%= username %>
            </a>
        </h4>
        <p><%= content %></p>
        <% if (mediaUrl != null && !mediaUrl.isEmpty()) { 
            String fileExtension = mediaUrl.substring(mediaUrl.lastIndexOf(".") + 1).toLowerCase();
        %>
            <% if ("mp4".equals(fileExtension)) { %>
                <video controls class="media">
                    <source src="<%= mediaUrl %>" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            <% } else { %>
                <img src="<%= mediaUrl %>" class="media">
            <% } %>
        <% } %>

        <div>
            <form action="like" method="post" style="display:inline;">
                <input type="hidden" name="post_id" value="<%= postId %>">
                <button type="submit" class="btn btn-link like-button">
                    <% 
                        String checkUserLikeQuery = "SELECT COUNT(*) FROM Likes WHERE user_id = (SELECT user_id FROM Users WHERE username = ?) AND post_id = ?";
                        PreparedStatement checkUserLikePst = con.prepareStatement(checkUserLikeQuery);
                        checkUserLikePst.setString(1, username);
                        checkUserLikePst.setInt(2, postId);
                        ResultSet userLikeResult = checkUserLikePst.executeQuery();
                        userLikeResult.next();
                        boolean liked = userLikeResult.getInt(1) > 0;
                    %>
                    <%= liked ? "Beğendin" : "Beğen" %> (<%= likeCount %>)
                </button>
            </form>
            <a href="#comment-section-<%= postId %>" data-toggle="collapse">Yorumlar</a>
        </div>

        <div>
            <form action="follow" method="post" style="display:inline;">
                <input type="hidden" name="followed_id" value="<%= rs.getInt("user_id") %>">
                <input type="hidden" name="action" value="<%= followed ? "unfollow" : "follow" %>">
                <button type="submit" class="btn btn-link follow-button">
                    <%= followed ? "Takibi Bırak" : "Takip Et" %>
                </button>
            </form>
        </div>

        <div id="comment-section-<%= postId %>" class="collapse">
            <form action="comment" method="post">
                <input type="hidden" name="post_id" value="<%= postId %>">
                <div class="form-group">
                    <textarea class="form-control" name="comment" placeholder="Yorumlar" rows="2" required></textarea>
                </div>
                <button type="submit" class="btn btn-secondary comment-button">Yorumlar</button>
            </form>

            <%
                String commentQuery = "SELECT c.content, u.username FROM Comments c JOIN Users u ON c.user_id = u.user_id WHERE c.post_id = ?";
                PreparedStatement commentPst = con.prepareStatement(commentQuery);
                commentPst.setInt(1, postId);
                ResultSet commentRs = commentPst.executeQuery();
                while (commentRs.next()) {
                    String commentUser = commentRs.getString("username");
                    String commentContent = commentRs.getString("content");
            %>
            <div class="comment">
                <strong><%= commentUser %>:</strong> <%= commentContent %>
            </div>
            <% 
                }
                commentRs.close(); 
                commentPst.close(); 
            %>
        </div>
    </div>

    <% 
            }
        } catch (SQLException e) {
            e.printStackTrace();
    %>
    <div class="alert alert-danger">Hata.</div>
    <% 
        } finally {
            try {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
