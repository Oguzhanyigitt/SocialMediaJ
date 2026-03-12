import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.socialmedia.util.CloudinaryUtil;
import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder; // ÇÖZÜM İÇİN EKLENDİ
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

@WebServlet("/UploadProfilePic")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15
)
public class UploadProfilePicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String username = (String) session.getAttribute("user");
        
        // KRİTİK ÇÖZÜM: Türkçe karakter ve boşlukları güvenli URL formatına çeviriyoruz
        String encodedUsername = URLEncoder.encode(username, "UTF-8");

        Part filePart = request.getPart("profilePic");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("profile?username=" + encodedUsername + "&error=empty_file");
            return;
        }

        String profilePicUrl = null;
        try {
            Cloudinary cloudinary = CloudinaryUtil.getInstance();
            Map uploadResult = cloudinary.uploader().upload(filePart.getInputStream().readAllBytes(), ObjectUtils.emptyMap());
            profilePicUrl = (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile?username=" + encodedUsername + "&error=upload_failed");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            String updateQuery = "UPDATE users SET profile_pic = ? WHERE user_id = ?";
            try (PreparedStatement pst = con.prepareStatement(updateQuery)) {
                pst.setString(1, profilePicUrl);
                pst.setInt(2, userId);
                pst.executeUpdate();
            }
            
            // Artık güvenli formattaki ismi yönlendiriyoruz
            response.sendRedirect("profile?username=" + encodedUsername);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile?username=" + encodedUsername + "&error=db_error");
        }
    }
}