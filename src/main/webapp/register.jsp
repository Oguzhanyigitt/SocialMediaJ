<form action="register" method="post">
    Username: <input type="text" name="username" required><br>
    Password: <input type="password" name="password" required><br>
    Email: <input type="email" name="email" required><br>
    <input type="submit" value="Register">
</form>
<% if (request.getParameter("error") != null) { %>
    <p style="color: red;">Kayıt Hatalı</p>
<% } %>
<% if (request.getParameter("registration") != null) { %>
    <p style="color: green;">Kayıt Başarılı. Lütfen<a href="login.jsp">Giriş Yap</a>.</p>
<% } %>
