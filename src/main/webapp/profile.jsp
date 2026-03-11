<%@ page import="java.sql.*" %>
<%@ page import="com.socialmedia.util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kullanıcı Profili</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f0f2f5;
        }
        .container {
            max-width: 800px;
            margin-top: 20px;
        }
        .profile-img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
        }
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
        
        <form class="form-inline my-2 my-lg-0" action="profile" method="get">
            <input class="form-control mr-sm-2" type="search" placeholder="Kullanıcı Ara" aria-label="Search" name="username">
            <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Ara</button>
        </form>
    </div>
</nav>
<li>
    
</li>
<li>
    
</li>
<div class="container">
    <h2>Profil: <%= request.getAttribute("username") != null ? request.getAttribute("username") : "Kullanıcı Bulunamadı" %></h2>
    <p><%= request.getAttribute("userEmail") != null ? request.getAttribute("userEmail") : "E-posta bulunamadı." %></p>
    <p>Takipçi Sayısı: 
        <% 
            String currentUsername = (String) request.getAttribute("username");
            if (currentUsername != null) {
                Connection con = DBUtil.getConnection();
                String followerCountQuery = "SELECT COUNT(*) FROM Followers WHERE followed_id = (SELECT user_id FROM Users WHERE username = ?)";
                PreparedStatement followerCountPst = con.prepareStatement(followerCountQuery);
                followerCountPst.setString(1, currentUsername);
                ResultSet followerCountRs = followerCountPst.executeQuery();
                if (followerCountRs.next()) {
                    out.print(followerCountRs.getInt(1));
                }
                followerCountRs.close();
                followerCountPst.close();
                con.close();
            } else {
                out.print("0");
            }
        %>
    </p>

    <% String profilePic = (String) request.getAttribute("userProfilePic"); %>
    <% if (profilePic != null && !profilePic.isEmpty()) { %>
        <img src="<%= profilePic %>" class="profile-img" alt="Profil Fotoğrafı">
    <% } else { %>
        <img src="path/to/default/image.jpg" class="profile-img" alt="Varsayılan Profil Fotoğrafı">
    <% } %>

    <form action="UploadProfilePic" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <label for="profilePic">Profil Fotoğrafı Yükle:</label>
            <input type="file" name="profilePic" id="profilePic" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary">Yükle</button>
    </form>

    <div class="post-container mt-4">
        <% 
        Integer userId = (Integer) request.getAttribute("userId");

        if (userId != null) {
            String query = "SELECT p.post_id, p.content, p.media_url, p.created_at FROM Posts p WHERE p.user_id = ? ORDER BY p.created_at DESC";
            Connection con = DBUtil.getConnection();
            PreparedStatement pst = con.prepareStatement(query);
            pst.setInt(1, userId);
            ResultSet rs = pst.executeQuery();
            if (!rs.isBeforeFirst()) {
                out.println("<p>Kullanıcı gönderileri bulunamadı.</p>");
            } else {
                while (rs.next()) {
                    int postId = rs.getInt("post_id");
                    String content = rs.getString("content");
                    String mediaUrl = rs.getString("media_url");
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    String fileExtension = mediaUrl != null ? mediaUrl.substring(mediaUrl.lastIndexOf(".") + 1).toLowerCase() : "";
        %>
        <div class="card mb-4">
            <div class="card-body">
                <p><%= content %></p>
                <% if (mediaUrl != null && !mediaUrl.isEmpty()) { %>
                    <% if ("mp4".equals(fileExtension)) { %>
                        <video controls class="img-fluid">
                            <source src="<%= mediaUrl %>" type="video/mp4">
                            WEB TARAYICIN BU ETIKETI DESTEKLEMIYOR.
                        </video>
                    <% } else { %>
                        <img src="<%= mediaUrl %>" class="img-fluid" alt="Post Media">
                    <% } %>
                <% } %>
                <p class="text-muted"><%= createdAt %></p>
            </div>
        </div>
        <% 
                }
            }
            con.close();
        } else {
            out.println("<p>Kullanıcı gönderileri bulunamadı.</p>");
        }
        %>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
