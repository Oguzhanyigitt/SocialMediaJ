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
        .post-footer { padding: 10px 15px; background: #f9f9f9; border-top: 1px solid #eee; font-size: 0.9rem; color: #666; display: flex; justify-content: space-between; align-items: center;}
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
                <li class="nav-item"><a class="nav-link" href="home"><i class="fas fa-home"></i> Ana Sayfa</a></li>
                <li class="nav-item active"><a class="nav-link" href="profile?username=<%= session.getAttribute("user") %>"><i class="fas fa-user"></i> Profil</a></li>
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
                        <video controls class="post-media"><source src="<%= mediaUrl %>" type="video/mp4"></video>
                    <% } else { %>
                        <img src="<%= mediaUrl %>" class="post-media" alt="Post Media">
                    <% } 
                } %>
                
                <div class="post-footer">
                    <div>
                        <span class="mr-3"><i class="far fa-thumbs-up"></i> <%= post.get("likeCount") %> Beğeni</span>
                        <span><%= post.get("createdAt") %></span>
                    </div>
                    
                    <% if (isOwnProfile) { %>
                        <form action="deletePost" method="post" onsubmit="return confirm('Bu gönderiyi silmek istediğine emin misin?');" style="margin: 0;">
                            <input type="hidden" name="postId" value="<%= post.get("postId") %>">
                            <input type="hidden" name="redirect" value="profile">
                            <button type="submit" class="btn btn-sm text-danger border-0 bg-transparent" title="Gönderiyi Sil"><i class="fas fa-trash"></i></button>
                        </form>
                    <% } %>
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

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
    // Profil fotoğrafı seçici
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        $(this).next('.custom-file-label').addClass("selected").html(fileName);
    });

    // Canlı Arama (AJAX) - Home ile birebir aynı kurgu
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

        $(document).click(function(e) {
            if (!$(e.target).closest('#searchContainer').length) {
                $('#searchResults').hide();
            }
        });
    });
</script>
</body>
</html>