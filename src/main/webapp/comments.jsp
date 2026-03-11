	<%@ page import="java.sql.*" %>
	<%@ page import="com.socialmedia.util.DBUtil" %>
	<!DOCTYPE html>
	<html lang="tr">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>Yorumlar - Sosyal Medya</title>
	    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
	    <style>
	        body {
	            background-color: #f0f2f5;
	        }
	        .container {
	            max-width: 800px;
	        }
	        .comment-card {
	            margin-bottom: 15px;
	        }
	    </style>
	</head>
	<body>
	
	<div class="container mt-4">
	    <h2>Yorumlar</h2>
	    <div class="card mb-4">
	        <div class="card-body">
	            <form action="comment" method="post">
	                <input type="hidden" name="postId" value="<%= request.getParameter("postId") %>">
	                <div class="form-group">
	                    <textarea name="content" class="form-control" rows="3" placeholder="Add a comment..." required></textarea>
	                </div>
	                <button type="submit" class="btn btn-primary">Yorum Yap</button>
	            </form>
	        </div>
	    </div>
	
	    <div class="comments-container">
	        <% 
	        int postId = Integer.parseInt(request.getParameter("postId"));
	        Connection con = DBUtil.getConnection();
	        String query = "SELECT c.comment_id, c.content, c.created_at, u.username FROM Comments c JOIN Users u ON c.user_id = u.user_id WHERE c.post_id = ? ORDER BY c.created_at DESC";
	        PreparedStatement pst = con.prepareStatement(query);
	        pst.setInt(1, postId);
	        ResultSet rs = pst.executeQuery();
	        while (rs.next()) {
	            String userName = rs.getString("username");
	            String content = rs.getString("content");
	            Timestamp createdAt = rs.getTimestamp("created_at");
	        %>
	        <div class="card comment-card">
	            <div class="card-body">
	                <h5><%= userName %></h5>
	                <p><%= content %></p>
	                <p class="text-muted"><%= createdAt %></p>
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
