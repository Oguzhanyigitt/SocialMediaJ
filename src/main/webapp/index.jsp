<%@ page import="com.socialmedia.util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hoş Geldin</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f0f2f5;
        }
        .container {
            max-width: 900px;
            display: flex;
            justify-content: space-between;
        }
        .form-container {
            max-width: 400px;
            padding: 20px;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin: 10px;
        }
        .alert {
            margin-top: 15px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="form-container">
        <h2 class="text-center">Giriş Yap</h2>
        <% if ("loginError".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Geçersiz Kullanıcı adı veya şifre</div>
        <% } %>
        <form action="login" method="post">
            <div class="form-group">
                <label for="loginUsername">Kullanıcı Adı</label>
                <input type="text" id="loginUsername" name="username" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="loginPassword">Şifre</label>
                <input type="password" id="loginPassword" name="password" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Giriş Yap</button>
        </form>
    </div>

    <div class="form-container">
        <h2 class="text-center">Kayıt Ol</h2>
        <% if ("registerError".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">Kayıt Hatası.</div>
        <% } %>
        <form action="register" method="post">
            <div class="form-group">
                <label for="registerUsername">Kullanıcı Adı</label>
                <input type="text" id="registerUsername" name="username" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="registerPassword">Şifre</label>
                <input type="password" id="registerPassword" name="password" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="registerEmail">Email</label>
                <input type="email" id="registerEmail" name="email" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-success btn-block">Kayıt Ol</button>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
