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
        .create-post-card, .post-card { border-radius: 10px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); margin-bottom: 20px; background: #fff; }
        .post-header { display: flex; align-items: center; padding: 15px; }
        .profile-pic { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; margin-right: 10px; background-color: #ccc; }
        .post-author { font-weight: bold; color: #050505; text-decoration: none; }
        .post-time { font-size: 0.8rem; color: #65676b; }
        .post-content { padding: 0 15px 15px 15px; font-size: 1.1rem; }
        .post-media { width: 100%; max-height: 500px; object-fit: cover; }
        .post-actions { border-top: 1px solid #e4e6eb; border-bottom: 1px solid #e4e6eb; padding: 5px 15px; display: flex; justify-content: space-around; }
        .action-btn { background: none; border: none; color: #65676b; font-weight: 600; padding: 10px; width: 100%; transition: 0.2s; border-radius: 5px; }
        .action-btn:hover { background-color: #f0f2f5; text-decoration: none; outline: none; }
        .action-btn.liked { color: #1877f2; }
        .comment-section { padding: 15px; background-color: #f9f9f9; border-radius: 0 0 10px 10px; }
        .comment-item { margin-bottom: 10px; background: #fff; padding: 10px 15px; border-radius: 15px; box-shadow: 0 1px 1px rgba(0,0,0,0.05); }
        /* Arama kutusu dropdown stili */
        #searchResults { max-height: 300px; overflow-y: auto; }
        .dropdown-item:active { background-color: #f0f2f5; }
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
            
            <div class="position-relative mr-3" id="searchContainer">
                <div class="input-group">
                    <input class="form-control" type="search" placeholder="Kullanıcı Ara..." id="searchInput" autocomplete="off">
                    <div class="input-group-append">
                        <button class="btn btn-outline-primary" type="button"><i class="fas fa-search"></i></button>
                    </div>
                </div>
                <div id="searchResults" class="dropdown-menu w-100 position-absolute shadow-sm" style="display: none; top: 100%; left: 0; z-index: 1050; border-radius: 0 0 10px 10px;">
                    </div>
            </div>

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
                            <button type="submit" class="btn btn-primary px-4"><i class="fas fa-paper-plane"></i> Paylaş</button>
                        </div>
                    </form>
                </div>
            </div>

            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    Bir hata oluştu. Lütfen tekrar deneyin.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            <% } %>

            <% 
                List<Map<String, Object>> posts = (List<Map<String, Object>>) request.getAttribute("posts");
                if (posts != null && !posts.isEmpty()) {
                    for (Map<String, Object> post : posts) {
                        String mediaUrl = (String) post.get("mediaUrl");
                        boolean isLiked = (Boolean) post.get("isLiked");
            %>
            <div class="post-card">
                <div class="post-header d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center">
                        <img src="<%= post.get("authorPic") != null ? post.get("authorPic") : "https://via.placeholder.com/40" %>" class="profile-pic" alt="Profile">
                        <div>
                            <a href="profile?username=<%= post.get("authorName") %>" class="post-author"><%= post.get("authorName") %></a>
                            <div class="post-time"><%= post.get("createdAt") %></div>
                        </div>
                    </div>
                    
                    <% if (session.getAttribute("userId") != null && session.getAttribute("userId").equals(post.get("authorId"))) { %>
                        <form action="deletePost" method="post" onsubmit="return confirm('Bu gönderiyi silmek istediğine emin misin? Tüm beğeniler ve yorumlar da silinecek.');" style="margin: 0;">
                            <input type="hidden" name="postId" value="<%= post.get("postId") %>">
                            <input type="hidden" name="redirect" value="home">
                            <button type="submit" class="btn btn-sm text-danger border-0 bg-transparent" title="Gönderiyi Sil"><i class="fas fa-trash"></i></button>
                        </form>
                    <% } %>
                </div>
                
                <div class="post-content">
                    <%= ((String)post.get("content")).replace("<", "&lt;").replace(">", "&gt;") %>
                </div>

                <% if (mediaUrl != null && !mediaUrl.isEmpty()) { 
                    if (mediaUrl.toLowerCase().endsWith(".mp4")) { %>
                        <video controls class="post-media"><source src="<%= mediaUrl %>" type="video/mp4"></video>
                    <% } else { %>
                        <img src="<%= mediaUrl %>" class="post-media" alt="Post Image">
                    <% } 
                } %>

                <div class="post-actions">
                    <form action="like" method="post" class="w-50 text-center" style="margin: 0;">
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
                        <input type="text" name="content" class="form-control form-control-sm mr-2" placeholder="Bir yorum yaz..." required>
                        <button type="submit" class="btn btn-sm btn-primary">Gönder</button>
                    </form>
                    
                    <% 
                        List<Map<String, String>> comments = (List<Map<String, String>>) post.get("comments");
                        if (comments != null) {
                            for (Map<String, String> comment : comments) {
                    %>
                    <div class="comment-item d-flex justify-content-between align-items-start">
                        <div>
                            <strong><a href="profile?username=<%= comment.get("username") %>" class="text-dark"><%= comment.get("username") %></a>:</strong> 
                            <span class="text-break"><%= comment.get("content").replace("<", "&lt;").replace(">", "&gt;") %></span>
                        </div>
                        
                        <% if (session.getAttribute("userId") != null && String.valueOf(session.getAttribute("userId")).equals(comment.get("userId"))) { %>
                            <form action="deleteComment" method="post" onsubmit="return confirm('Bu yorumu silmek istediğine emin misin?');" style="margin: 0; padding-left: 10px;">
                                <input type="hidden" name="commentId" value="<%= comment.get("commentId") %>">
                                <button type="submit" class="btn btn-sm text-danger border-0 p-0 bg-transparent" title="Yorumu Sil"><i class="fas fa-times"></i></button>
                            </form>
                        <% } %>
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
                    <i class="fas fa-camera-retro fa-3x mb-3 text-light"></i>
                    <h4>Henüz hiç gönderi yok.</h4>
                    <p>İlk paylaşan sen ol!</p>
                </div>
            <% } %>

        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
    // Dosya Seçici İsim Gösterme
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        $(this).next('.custom-file-label').addClass("selected").html(fileName);
    });

    // Canlı Arama (AJAX)
    $(document).ready(function() {
        $('#searchInput').on('keyup', function() {
            let query = $(this).val().trim();
            let resultsBox = $('#searchResults');

            if (query.length > 0) {
                $.ajax({
                    url: 'searchUsers',
                    method: 'GET',
                    data: { q: query },
                    success: function(data) {
                        resultsBox.empty();
                        if (data.length > 0) {
                        	data.forEach(function(user) {
                                resultsBox.append(
                                    `<a class="dropdown-item d-flex align-items-center py-2" href="profile?username=\${user.username}">
                                        <img src="\${user.pic}" style="width: 35px; height: 35px; border-radius: 50%; margin-right: 12px; object-fit: cover; background-color: #ccc;">
                                        <span class="font-weight-bold text-dark">\${user.username}</span>
                                    </a>`
                                );
                            });
                            resultsBox.show();
                        } else {
                            resultsBox.html('<span class="dropdown-item text-muted text-center py-2">Kullanıcı bulunamadı</span>');
                            resultsBox.show();
                        }
                    }
                });
            } else {
                resultsBox.hide();
            }
        });

        // Ekranda boşa tıklanınca aramayı kapat
        $(document).click(function(e) {
            if (!$(e.target).closest('#searchContainer').length) {
                $('#searchResults').hide();
            }
        });
    });
</script>
</body>
</html>