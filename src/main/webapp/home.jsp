<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ana Sayfa - Sosyal Medya</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; padding-top: 70px; }
        .navbar-brand { font-weight: bold; color: #1877f2 !important; }
        .create-post-card { border-radius: 10px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .post-card { border-radius: 10px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); margin-bottom: 20px; background: #fff; }
        .post-header { display: flex; align-items: center; padding: 15px; }
        .profile-pic { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; margin-right: 10px; background-color: #ccc; }
        .post-author { font-weight: bold; color: #050505; text-decoration: none; }
        .post-time { font-size: 0.8rem; color: #65676b; }
        .post-content { padding: 0 15px 15px 15px; font-size: 1.1rem; }
        .post-media { width: 100%; max-height: 500px; object-fit: cover; }
        .post-actions { border-top: 1px solid #e4e6eb; border-bottom: 1px solid #e4e6eb; padding: 5px 15px; display: flex; justify-content: space-around; }
        .action-btn { background: none; border: none; color: #65676b; font-weight: 600; padding: 10px; width: 100%; transition: 0.2s; border-radius: 5px; }
        .action-btn:hover { background-color: #f0f2f5; text-decoration: none; }
        .action-btn.liked { color: #1877f2; }
        .comment-section { padding: 15px; background-color: #f9f9f9; border-radius: 0 0 10px 10px; }
        .comment-item { margin-bottom: 10px; background: #fff; padding: 10px; border-radius: 15px; box-shadow: 0 1px 1px rgba(0,0,0,0.05); }
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
                <li class="nav-item active"><a class="nav-link" href="home"><i class="fas fa-home"></i> Ana Sayfa</a></li>
                <li class="nav-item"><a class="nav-link" href="profile?username=<%= session.getAttribute("user") %>"><i class="fas fa-user"></i> Profil</a></li>
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
            
            <div class="card create-post-card">
                <div class="card-body">
                    <h5 class="card-title mb-3"><i class="fas fa-edit"></i> Yeni Gönderi</h5>
                    <form action="post" method="post" enctype="multipart/form-data">
                        <div class="form-group">
                            <textarea class="form-control" name="content" placeholder="Aklından neler geçiyor, <%= session.getAttribute("user") %>?" rows="3" required></textarea>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="custom-file w-50">
                                <input type="file" class="custom-file-input" id="mediaFile" name="media" accept="image/*,video/mp4">
                                <label class="custom-file-label" for="mediaFile">Fotoğraf/Video Ekle</label>
                            </div>
                            <button type="submit" class="btn btn-primary px-4">Paylaş</button>
                        </div>
                    </form>
                </div>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger">Bir hata oluştu. Lütfen tekrar deneyin.</div>
            <% } %>

            <% 
                List<Map<String, Object>> posts = (List<Map<String, Object>>) request.getAttribute("posts");
                if (posts != null && !posts.isEmpty()) {
                    for (Map<String, Object> post : posts) {
                        String mediaUrl = (String) post.get("mediaUrl");
                        boolean isLiked = (Boolean) post.get("isLiked");
            %>
            <div class="post-card">
                <div class="post-header">
                    <img src="<%= post.get("authorPic") != null ? post.get("authorPic") : "https://via.placeholder.com/40" %>" class="profile-pic" alt="Profile">
                    <div>
                        <a href="profile?username=<%= post.get("authorName") %>" class="post-author"><%= post.get("authorName") %></a>
                        <div class="post-time"><%= post.get("createdAt") %></div>
                    </div>
                </div>
                
                <div class="post-content">
                    <%= post.get("content") %> </div>

                <% if (mediaUrl != null && !mediaUrl.isEmpty()) { 
                    if (mediaUrl.toLowerCase().endsWith(".mp4")) { %>
                        <video controls class="post-media">
                            <source src="<%= mediaUrl %>" type="video/mp4">
                        </video>
                    <% } else { %>
                        <img src="<%= mediaUrl %>" class="post-media" alt="Post Image">
                    <% } 
                } %>

                <div class="post-actions">
                    <form action="like" method="post" class="w-50 text-center">
                        <input type="hidden" name="post_id" value="<%= post.get("postId") %>">
                        <button type="submit" class="action-btn <%= isLiked ? "liked" : "" %>">
                            <i class="fa<%= isLiked ? "s" : "r" %> fa-thumbs-up"></i> <%= isLiked ? "Beğendin" : "Beğen" %> (<%= post.get("likeCount") %>)
                        </button>
                    </form>
                    
                    <button class="action-btn w-50" data-toggle="collapse" data-target="#comments-<%= post.get("postId") %>">
                        <i class="far fa-comment-alt"></i> Yorumlar
                    </button>
                </div>

                <div id="comments-<%= post.get("postId") %>" class="collapse comment-section">
                    <form action="comment" method="post" class="mb-3 d-flex">
                        <input type="hidden" name="postId" value="<%= post.get("postId") %>">
                        <input type="text" name="content" class="form-control form-control-sm mr-2" placeholder="Yorum yaz..." required>
                        <button type="submit" class="btn btn-sm btn-primary">Gönder</button>
                    </form>
                    
                    <% 
                        List<Map<String, String>> comments = (List<Map<String, String>>) post.get("comments");
                        if (comments != null) {
                            for (Map<String, String> comment : comments) {
                    %>
                    <div class="comment-item">
                        <strong><%= comment.get("username") %>:</strong> <%= comment.get("content").replace("<", "&lt;").replace(">", "&gt;") %>
                    </div>
                    <%      }
                        } 
                    %>
                </div>
            </div>
            <% 
                    }
                } else { 
            %>
                <div class="text-center text-muted mt-5">
                    <h4>Henüz hiç gönderi yok.</h4>
                    <p>İlk paylaşan sen ol!</p>
                </div>
            <% } %>

        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
    // Dosya seçildiğinde ismini inputta göstermek için küçük bir UX dokunuşu
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        $(this).next('.custom-file-label').addClass("selected").html(fileName);
    });
</script>
</body>
</html>