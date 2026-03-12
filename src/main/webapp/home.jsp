<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ana Sayfa - Sosyal</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; padding-top: 70px; }
        .navbar-brand { font-weight: bold; color: #1877f2 !important; }
        .post-card { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.12); margin-bottom: 20px; overflow: hidden; }
        .post-header { padding: 15px; display: flex; align-items: center; justify-content: space-between; }
        .profile-pic { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 12px; background-color: #e4e6eb; }
        .post-author { font-weight: 600; color: #050505; text-decoration: none; font-size: 1.05rem; }
        .post-author:hover { text-decoration: underline; color: #050505; }
        .post-time { font-size: 0.8rem; color: #65676b; }
        .post-content { padding: 0 15px 15px 15px; font-size: 1.05rem; color: #1c1e21; white-space: pre-wrap; word-wrap: break-word; }
        .post-media { width: 100%; max-height: 500px; object-fit: contain; background-color: #f0f2f5; }
        .post-actions { border-top: 1px solid #ced0d4; padding: 5px 15px; display: flex; }
        .action-btn { background: none; border: none; color: #65676b; font-weight: 600; padding: 8px; flex: 1; border-radius: 5px; transition: 0.2s; }
        .action-btn:hover { background-color: #f0f2f5; outline: none; }
        .action-btn.liked { color: #1877f2; }
        .comment-section { background-color: #f0f2f5; padding: 15px; }
        .comment-item { margin-bottom: 12px; display: flex; align-items: flex-start; }
        .comment-bubble { background: #fff; padding: 8px 12px; border-radius: 18px; display: inline-block; max-width: 90%; word-wrap: break-word; }
        #searchResults { max-height: 300px; overflow-y: auto; }
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
                <li class="nav-item"><a class="nav-link" href="profile?username=<c:out value="${sessionScope.user}" />"><i class="fas fa-user"></i> Profil</a></li>
            </ul>
            
            <div class="position-relative mr-3" id="searchContainer">
                <div class="input-group">
                    <input class="form-control" type="search" placeholder="Kullanıcı Ara..." id="searchInput" autocomplete="off">
                    <div class="input-group-append">
                        <button class="btn btn-outline-primary" type="button"><i class="fas fa-search"></i></button>
                    </div>
                </div>
                <div id="searchResults" class="dropdown-menu w-100 position-absolute shadow-sm" style="display: none; top: 100%; z-index: 1050;"></div>
            </div>

            <a class="btn btn-danger btn-sm" href="logout"><i class="fas fa-sign-out-alt"></i> Çıkış</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            
            <div class="post-card p-3">
                <form action="post" method="post" enctype="multipart/form-data">
                    <div class="d-flex mb-2">
                        <textarea class="form-control border-0" name="content" placeholder="Aklından neler geçiyor, <c:out value="${sessionScope.user}" />?" rows="2" style="resize: none;" required></textarea>
                    </div>
                    <div class="d-flex justify-content-between align-items-center border-top pt-2">
                        <div class="custom-file w-50">
                            <input type="file" class="custom-file-input" id="mediaFile" name="media" accept="image/*,video/mp4">
                            <label class="custom-file-label border-0 text-muted" for="mediaFile"><i class="fas fa-image text-success"></i> Fotoğraf/Video</label>
                        </div>
                        <button type="submit" class="btn btn-primary px-4 rounded-pill font-weight-bold">Paylaş</button>
                    </div>
                </form>
            </div>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show">
                    İşlem sırasında bir hata oluştu. Lütfen tekrar deneyin.
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${not empty posts}">
                    <c:forEach var="post" items="${posts}">
                        <div class="post-card">
                            <div class="post-header">
                                <div class="d-flex align-items-center">
                                    <img src="<c:out value="${post.authorPic}" />" class="profile-pic" alt="Profile">
                                    <div>
                                        <a href="profile?username=<c:out value="${post.authorName}" />" class="post-author"><c:out value="${post.authorName}" /></a>
                                        <div class="post-time"><c:out value="${post.createdAt}" /></div>
                                    </div>
                                </div>
                                <c:if test="${sessionScope.userId == post.authorId}">
                                    <form action="deletePost" method="post" class="m-0" onsubmit="return confirm('Silmek istediğinize emin misiniz?');">
                                        <input type="hidden" name="postId" value="${post.postId}">
                                        <input type="hidden" name="redirect" value="home">
                                        <button type="submit" class="btn btn-sm text-danger bg-transparent border-0"><i class="fas fa-trash"></i></button>
                                    </form>
                                </c:if>
                            </div>
                            
                            <div class="post-content"><c:out value="${post.content}" /></div>

                            <c:if test="${not empty post.mediaUrl}">
                                <c:choose>
                                    <c:when test="${post.mediaUrl.toLowerCase().endsWith('.mp4')}">
                                        <video controls class="post-media"><source src="<c:out value="${post.mediaUrl}" />" type="video/mp4"></video>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="<c:out value="${post.mediaUrl}" />" class="post-media" alt="Post Image">
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <div class="post-actions">
                                <form action="like" method="post" class="flex-fill m-0 text-center">
								    <input type="hidden" name="post_id" value="${post.postId}">
								    <input type="hidden" name="from" value="home"> <button type="submit" class="action-btn w-100 ${post.isLiked ? 'liked' : ''}">
								        <i class="${post.isLiked ? 'fas' : 'far'} fa-thumbs-up"></i> ${post.isLiked ? 'Beğendin' : 'Beğen'} (${post.likeCount})
								    </button>
								</form>
                                <button class="action-btn flex-fill" data-toggle="collapse" data-target="#comments-${post.postId}">
                                    <i class="far fa-comment-alt"></i> Yorumlar
                                </button>
                            </div>

                            <div id="comments-${post.postId}" class="collapse comment-section">
                                <form action="comment" method="post" class="mb-3 d-flex">
                                    <input type="hidden" name="postId" value="${post.postId}">
                                    <input type="hidden" name="from" value="home">
                                    <input type="text" name="content" class="form-control rounded-pill mr-2" placeholder="Yorum yaz..." required autocomplete="off">
                                    <button type="submit" class="btn btn-primary rounded-pill btn-sm px-3"><i class="fas fa-paper-plane"></i></button>
                                </form>
                                
                                <c:if test="${not empty post.comments}">
                                    <c:forEach var="comment" items="${post.comments}">
                                        <div class="comment-item w-100">
                                            <div class="comment-bubble">
                                                <strong><a href="profile?username=<c:out value="${comment.username}" />" class="text-dark"><c:out value="${comment.username}" /></a>:</strong> 
                                                <span><c:out value="${comment.content}" /></span>
                                            </div>
                                            <c:if test="${sessionScope.userId == comment.userId}">
                                                <form action="deleteComment" method="post" class="m-0 ml-2" onsubmit="return confirm('Yorumu sil?');">
                                                    <input type="hidden" name="commentId" value="${comment.commentId}">
                                                    <button type="submit" class="btn btn-sm text-danger border-0 p-0 bg-transparent"><i class="fas fa-times"></i></button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="text-center text-muted mt-5">
                        <i class="fas fa-images fa-3x mb-3 text-light"></i>
                        <h4>Henüz hiç gönderi yok.</h4>
                        <p>İlk paylaşan sen ol!</p>
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
    // Dosya Seçici İsim Gösterme (Mobilde de düzgün çalışır)
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        if(fileName) {
            $(this).next('.custom-file-label').html('<i class="fas fa-check text-success"></i> ' + fileName);
        }
    });

    // Canlı Arama (AJAX) - Güvenlik İçin encodeURI eklendi
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
                                // XSS engellemek için JS tarafında da temel encode işlemi yapıyoruz
                                let safeUsername = encodeURIComponent(user.username);
                                let safePic = encodeURI(user.pic);
                                resultsBox.append(
                                    `<a class="dropdown-item d-flex align-items-center py-2" href="profile?username=\${safeUsername}">
                                        <img src="\${safePic}" style="width: 35px; height: 35px; border-radius: 50%; margin-right: 12px; object-fit: cover; background-color: #ccc;">
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