<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("targetUsername") %> - Profil</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; padding-top: 70px; }
        .navbar-brand { font-weight: bold; color: #1877f2 !important; }
        .profile-header-card { background: #fff; border-radius: 10px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); padding: 30px; margin-bottom: 20px; text-align: center; }
        .profile-img-large { width: 150px; height: 150px; border-radius: 50%; object-fit: cover; border: 4px solid #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 15px; background-color: #ccc; }
        .post-card { background: #fff; border-radius: 10px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); margin-bottom: 20px; overflow: hidden; }
        .post-content { padding: 15px; font-size: 1.1rem; }
        .post-media { width: 100%; max-height: 400px; object-fit: cover; }
        .post-footer { padding: 10px 15px; background: #f9f9f9; border-top: 1px solid #eee; font-size: 0.9rem; color: #666; display: flex; justify-content: space-between;}
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white fixed-top shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="home"><i class="fas fa-globe"></i> Sosyal</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item"><a class="nav-link" href="home"><i class="fas fa-home"></i> Ana Sayfa</a></li>
                <li class="nav-item active"><a class="nav-link" href="profile?username=<%= session.getAttribute("user") %>"><i class="fas fa-user"></i> Profil</a></li>
            </ul>
            <form class="form-inline my-2 my-lg-0 mr-3" action="profile" method="get">
                <div class="input-group">
                    <input class="form-control" type="search" placeholder="Kullanıcı Ara" name="username" required>
                    <div class="input-group-append">
                        <button class="btn btn-outline-primary" type="submit"><i class="fas fa-search"></i></button>
                    </div>
                </div>
            </form>
            <a class="btn btn-danger btn-sm" href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Çıkış</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            
            <% 
                String targetUsername = (String) request.getAttribute("targetUsername");
                boolean isOwnProfile = (Boolean) request.getAttribute("isOwnProfile");
                boolean isFollowing = (Boolean) request.getAttribute("isFollowing");
                String profilePic = (String) request.getAttribute("targetProfilePic");
            %>

            <div class="profile-header-card">
                <img src="<%= profilePic != null ? profilePic : "https://via.placeholder.com/150" %>" class="profile-img-large" alt="Profil Fotoğrafı">
                <h2><%= targetUsername %></h2>
                <p class="text-muted"><%= request.getAttribute("targetEmail") %></p>
                <div class="mb-3">
                    <span class="badge badge-primary p-2" style="font-size: 1rem;"><%= request.getAttribute("followerCount") %> Takipçi</span>
                </div>

                <% if (isOwnProfile) { %>
                    <hr>
                    <form action="UploadProfilePic" method="post" enctype="multipart/form-data" class="form-inline justify-content-center mt-3">
                        <div class="custom-file mb-2 mr-sm-2" style="max-width: 300px;">
                            <input type="file" class="custom-file-input" name="profilePic" id="profilePic" accept="image/*" required>
                            <label class="custom-file-label text-left" for="profilePic">Fotoğraf Değiştir</label>
                        </div>
                        <button type="submit" class="btn btn-success mb-2">Yükle</button>
                    </form>
                <% } else { %>
                    <form action="follow" method="post" class="mt-2">
                        <input type="hidden" name="followed_id" value="<%= request.getAttribute("targetUserId") %>">
                        <input type="hidden" name="target_username" value="<%= targetUsername %>">
                        <button type="submit" class="btn <%= isFollowing ? "btn-secondary" : "btn-primary" %> px-4">
                            <i class="fas <%= isFollowing ? "fa-user-minus" : "fa-user-plus" %>"></i> 
                            <%= isFollowing ? "Takibi Bırak" : "Takip Et" %>
                        </button>
                    </form>
                <% } %>
            </div>

            <h4 class="mb-3">Gönderiler</h4>
            <% 
                List<Map<String, Object>> posts = (List<Map<String, Object>>) request.getAttribute("posts");
                if (posts != null && !posts.isEmpty()) {
                    for (Map<String, Object> post : posts) {
                        String mediaUrl = (String) post.get("mediaUrl");
            %>
            <div class="post-card">
                <div class="post-content">
                    <%= ((String)post.get("content")).replace("<", "&lt;").replace(">", "&gt;") %>
                </div>

                <% if (mediaUrl != null && !mediaUrl.isEmpty()) { 
                    if (mediaUrl.toLowerCase().endsWith(".mp4")) { %>
                        <video controls class="post-media">
                            <source src="<%= mediaUrl %>" type="video/mp4">
                        </video>
                    <% } else { %>
                        <img src="<%= mediaUrl %>" class="post-media" alt="Post Media">
                    <% } 
                } %>
                
                <div class="post-footer">
                    <span><i class="far fa-thumbs-up"></i> <%= post.get("likeCount") %> Beğeni</span>
                    <span><%= post.get("createdAt") %></span>
                </div>
            </div>
            <% 
                    }
                } else { 
            %>
                <div class="alert alert-light text-center">Bu kullanıcı henüz hiç gönderi paylaşmamış.</div>
            <% } %>

        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
    // Profil fotoğrafı seçildiğinde ismini gösterme
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        $(this).next('.custom-file-label').addClass("selected").html(fileName);
    });
</script>
</body>
</html>