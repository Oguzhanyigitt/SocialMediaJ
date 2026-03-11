import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/post")
@MultipartConfig
public class PostServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String mediaUrl = null;

        Part filePart = request.getPart("media"); 
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = new File(filePart.getSubmittedFileName()).getName();
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            File file = new File(uploadPath + File.separator + fileName);
            filePart.write(file.getAbsolutePath());
            mediaUrl = UPLOAD_DIR + "/" + fileName;
        }

        try (Connection con = DBUtil.getConnection()) {
            String query = "INSERT INTO Posts (user_id, content, media_url, created_at) VALUES ((SELECT user_id FROM users WHERE username = ?), ?, ?, NOW())";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, username);
            pst.setString(2, content);
            pst.setString(3, mediaUrl);
            int rowsAffected = pst.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("home.jsp?post=success");
            } else {
                response.sendRedirect("post.jsp?error=true");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("post.jsp?error=true");
        }
    }
}
