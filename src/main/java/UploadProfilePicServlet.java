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
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/UploadProfilePic")
@MultipartConfig(maxFileSize = 10485760) 
public class UploadProfilePicServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Part filePart = request.getPart("profilePic");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String uploadPath = getServletContext().getRealPath("") + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        filePart.write(uploadPath + File.separator + fileName);
        String fileUrl = "uploads/" + fileName;

        try (Connection con = DBUtil.getConnection()) {
            String updateQuery = "UPDATE Users SET profile_pic = ? WHERE username = ?";
            PreparedStatement pst = con.prepareStatement(updateQuery);
            pst.setString(1, fileUrl);
            pst.setString(2, username);
            pst.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
            return;
        }

        request.getSession().setAttribute("userProfilePic", fileUrl);
        response.sendRedirect("profile?username=" + username);
    }
}
