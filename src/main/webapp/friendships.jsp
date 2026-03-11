<%@ page import="java.sql.*" %>
<%@ page import="com.socialmedia.util.DBUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arkadaslar - Sosyal Medya</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f0f2f5;
        }
        .container {
            max-width: 800px;
        }
        .friend-card {
            margin-bottom: 15px;
        }
    </style>
</head>
<body>

<div class="container mt-4">
    <h2>Arkadaslar</h2>
    
    <div class="friends-container">
        <% 
        String username = (String) session.getAttribute("user");
        Connection con = DBUtil.getConnection();
        String query = "SELECT u.username, u.profile_pic_url FROM Friends f JOIN Users u ON f.friend_id = u.user_id WHERE f.user_id = (SELECT user_id FROM Users WHERE username = ?)";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, username);
        ResultSet rs = pst.executeQuery();
        while (rs.next()) {
            String friendName = rs.getString("username");
            String profilePic = rs.getString("profile_pic_url");
        %>
        <div class="card friend-card">
            <div class="card-body d-flex align-items-center">
                <img src="<%= profilePic %>" class="profile-img" alt="Profile Picture">
                <h5 class="ml-3"><%= friendName %></h5>
            </div>
        </div>
        <% 
        }
        con.close();
        %>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
