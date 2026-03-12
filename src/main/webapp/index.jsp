<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sosyal - Giriş Yap veya Kaydol</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css">
    <style>
        body {
            background-color: #f0f2f5;
            height: 100vh;
            display: flex;
            align-items: center;
        }
        .brand-section {
            padding-right: 50px;
        }
        .brand-logo {
            font-size: 4rem;
            font-weight: bold;
            color: #1877f2;
            margin-bottom: 10px;
        }
        .brand-text {
            font-size: 1.5rem;
            color: #1c1e21;
        }
        .auth-card {
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .nav-tabs .nav-link {
            color: #65676b;
            font-weight: bold;
        }
        .nav-tabs .nav-link.active {
            color: #1877f2;
            border-bottom: 3px solid #1877f2;
            border-top: none;
            border-left: none;
            border-right: none;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="row align-items-center">
        <div class="col-md-6 d-none d-md-block brand-section">
            <div class="brand-logo"><i class="fas fa-globe"></i> Sosyal</div>
            <p class="brand-text">Tanıdıklarınla iletişim kurmanı ve hayatında olup bitenleri paylaşmanı sağlar.</p>
        </div>

        <div class="col-md-6">
            <div class="auth-card">
                <% 
                    String error = request.getParameter("error");
                    String success = request.getParameter("success");
                    String logout = request.getParameter("logout");
                    
                    if ("login_failed".equals(error)) { 
                %>
                    <div class="alert alert-danger">Kullanıcı adı veya şifre hatalı!</div>
                <% } else if ("register_failed".equals(error)) { %>
                    <div class="alert alert-danger">Kayıt işlemi başarısız. Kullanıcı adı veya e-posta kullanımda olabilir.</div>
                <% } else if ("registered".equals(success)) { %>
                    <div class="alert alert-success">Kayıt başarılı! Şimdi giriş yapabilirsin.</div>
                <% } else if ("true".equals(logout)) { %>
                    <div class="alert alert-info">Başarıyla çıkış yapıldı. Tekrar görüşmek üzere!</div>
                <% } %>

                <ul class="nav nav-tabs mb-4" id="authTab" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active" id="login-tab" data-toggle="tab" href="#login" role="tab">Giriş Yap</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" id="register-tab" data-toggle="tab" href="#register" role="tab">Yeni Hesap Oluştur</a>
                    </li>
                </ul>

                <div class="tab-content" id="authTabContent">
                    <div class="tab-pane fade show active" id="login" role="tabpanel">
                        <form action="login" method="post">
                            <div class="form-group">
                                <input type="text" name="username" class="form-control form-control-lg" placeholder="Kullanıcı Adı" required>
                            </div>
                            <div class="form-group">
                                <input type="password" name="password" class="form-control form-control-lg" placeholder="Şifre" required>
                            </div>
                            <button type="submit" class="btn btn-primary btn-lg btn-block font-weight-bold">Giriş Yap</button>
                        </form>
                    </div>

                    <div class="tab-pane fade" id="register" role="tabpanel">
                        <form action="register" method="post">
                            <div class="form-group">
                                <input type="text" name="username" class="form-control form-control-lg" placeholder="Kullanıcı Adı" required>
                            </div>
                            <div class="form-group">
                                <input type="email" name="email" class="form-control form-control-lg" placeholder="E-posta Adresi" required>
                            </div>
                            <div class="form-group">
                                <input type="password" name="password" class="form-control form-control-lg" placeholder="Yeni Şifre" required minlength="6">
                            </div>
                            <button type="submit" class="btn btn-success btn-lg btn-block font-weight-bold">Kaydol</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>