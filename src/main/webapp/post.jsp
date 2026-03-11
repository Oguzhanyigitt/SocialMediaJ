<%@ page import="com.socialmedia.util.DBUtil" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paylaşım - Sosyal Medya</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding-top: 56px; 
        }
        .navbar {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
    <a class="navbar-brand" href="#">Sosyal Medya</a>
    <div class="collapse navbar-collapse">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                <a class="nav-link" href="home.jsp">Ana Sayfa</a>
            </li>
            <li class="nav-item active">
                <a class="nav-link" href="post.jsp">Paylaşım <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="profile.jsp">Profil</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="logout.jsp">Çıkış Yap</a>
            </li>
        </ul>
    </div>
</nav>

<div class="container mt-4">
    <h1>Yeni Bir Paylaşım Yap</h1>
    <form action="post" method="post" enctype="multipart/form-data">
        <div class="form-group">
            <textarea class="form-control" name="content" placeholder="Aklında Neler Var" rows="3" required></textarea>
        </div>
        <div class="form-group">
        <input type="file" name="media" class="form-control-file" accept="video/mp4,image/*" required>
        </div>
        <button type="submit" class="btn btn-primary">Paylaş</button>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
