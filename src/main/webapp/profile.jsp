<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${targetUsername}" /> - Profil</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body { background-color: #f0f2f5; padding-top: 70px; }
        .navbar-brand { font-weight: bold; color: #1877f2 !important; }
        .profile-header-card { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.12); padding: 30px; margin-bottom: 20px; text-align: center; }
        .profile-img-large { width: 150px; height: 150px; border-radius: 50%; object-fit: cover; border: 4px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); margin-bottom: 15px; background-color: #e4e6eb; }
        .post-card { background: #fff; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.12); margin-bottom: 20px; overflow: hidden; }
        .post-header { padding: 15px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f0f2f5; }
        .post-content { padding: 15px; font-size: 1.05rem; white-space: pre-wrap; word-wrap: break-word; color: #1c1e21; }
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
                <li class="nav-item"><a class="nav-link" href="home"><i class="fas fa-home"></i> Ana Sayfa</a></li>
                <li class="nav-item active"><a class="nav-link" href="profile?username=<c:out value="${sessionScope.user}" />"><i class="fas fa-user"></i> Profil</a></li>
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
            
            <div class="profile-header-card">
                <img src="<c:out value="${targetProfilePic}" />" class="profile-img-large" alt="Profil Fotoğrafı">
                <h2 class="font-weight-bold"><c:out value="${targetUsername}" /></h2>
                <p class="text-muted"><c:out value="${targetEmail}" /></p>
                
                <div class="mb-3">
                    <span class="badge badge-primary badge-pill px-3 py-2" style="font-size: 1rem;"><c:out value="${followerCount}" /> Takipçi</span>
                </div>

                <c:choose>
                    <c:when test="${isOwnProfile}">
                        <hr>
                        <form action="UploadProfilePic" method="post" enctype="multipart/form-data" class="d-flex flex-column align-items-center mt-3">
                            <div class="custom-file mb-2" style="max-width: 300px;">
                                <input type="file" class="custom-file-input" name="profilePic" id="profilePic" accept="image/*" required>
                                <label class="custom-file-label text-left text-muted" for="profilePic"><i class="fas fa-camera"></i> Fotoğraf Değiştir</label>
                            </div>
                            <button type="submit" class="btn btn-success btn-sm px-4 rounded-pill font-weight-bold">Yükle</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <form action="follow" method="post" class="mt-3">
                            <input type="hidden" name="followed_id" value="${targetUserId}">
                            <input type="hidden" name="target_username" value="<c:out value="${targetUsername}" />">
                            <button type="submit" class="btn rounded-pill font-weight-bold px-4 ${isFollowing ? 'btn-secondary' : 'btn-primary'}">
                                <i class="fas ${isFollowing ? 'fa-user-check' : 'fa-user-plus'}"></i> 
                                ${isFollowing ? 'Takibi Bırak' : 'Takip Et'}
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>

            <h4 class="mb-3 font-weight-bold text-muted">Gönderiler</h4>
            
            <c:choose>
                <c:when test="${not empty posts}">
                    <c:forEach var="post" items="${posts}">
                        <div class="post-card">
                            <div class="post-header">
                                <span class="text-muted small"><i class="far fa-clock"></i> <c:out value="${post.createdAt}" /></span>
                                <c:if test="${isOwnProfile}">
                                    <form action="deletePost" method="post" class="m-0" onsubmit="return confirm('Silmek istediğinize emin misiniz?');">
                                        <input type="hidden" name="postId" value="${post.postId}">
                                        <input type="hidden" name="redirect" value="profile">
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
                                        <img src="<c:out value="${post.mediaUrl}" />" class="post-media" alt="Post Media">
                                    </c:otherwise>
                                </c:choose>
                            </c:if>

                            <div class="post-actions">
                                <form action="like" method="post" class="flex-fill m-0 text-center">
								    <input type="hidden" name="post_id" value="${post.postId}">
								    <input type="hidden" name="from" value="profile"> <input type="hidden" name="targetUsername" value="<c:out value="${targetUsername}" />"> <button type="submit" class="action-btn w-100 ${post.isLiked ? 'liked' : ''}">
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
                                    <input type="hidden" name="from" value="profile"> 
                                    <input type="hidden" name="targetUsername" value="<c:out value="${targetUsername}" />">
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
                    <div class="alert alert-light text-center border mt-3 rounded-lg text-muted">
                        <i class="fas fa-ghost fa-2x mb-2 d-block"></i>
                        Bu kullanıcı henüz hiç gönderi paylaşmamış.
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
    // Profil fotoğrafı seçici metni (Mobilde temiz görünüm)
    $('.custom-file-input').on('change', function() {
        let fileName = $(this).val().split('\\').pop();
        if(fileName) {
            $(this).next('.custom-file-label').html('<i class="fas fa-check text-success"></i> ' + fileName);
        }
    });

    // Canlı Arama (AJAX) - EncodeURI güvenlikli
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

        $(document).click(function(e) {
            if (!$(e.target).closest('#searchContainer').length) {
                $('#searchResults').hide();
            }
        });
    });
</script>
</body>
</html>