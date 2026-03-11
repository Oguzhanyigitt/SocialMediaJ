<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="com.socialmedia.util.DBUtil" %>
<!DOCTYPE html>
<html lang="tr">
<head>
    <link rel="shortcut icon" type="image/png" href="https://avatars.mds.yandex.net/i?id=9b727c154ebf81ad18c40bdc4d51d82b1196cfba-5601142-images-thumbs&n=13"/>
    <meta charset="UTF-8">
    <title>Çıkış Yapıldı</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f2f2f2; background-image: url('https://avatars.mds.yandex.net/i?id=d00615946d05cdfd02f0bd01df39cea21042d1ce-5877635-images-thumbs&n=13'); background-size: cover; background-repeat: no-repeat; background-position: center; margin: 0; padding: 350px; }
        .container { max-width: 800px; margin: auto; background: #000; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.3); color: #fff; }
        h1 { color: #fff; }
        .message { margin: 20px 0; font-size: 16px; text-align: center; }
        .back-link { display: block; margin-top: 20px; text-align: center; text-decoration: none; color: #007bff; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Çıkış Yapıldı</h1>

        <div class="message">
            <p>Başarıyla çıkış yaptınız. Ana sayfaya yönlendiriliyorsunuz...</p>
        </div>

        <a href="index.jsp" class="back-link">Ana Sayfa</a>
    </div>

    <script>
      
        setTimeout(function() {
            window.location.href = 'index.jsp';
        }, 3000);
    </script>
</body>
</html>
