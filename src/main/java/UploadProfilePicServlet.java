import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.socialmedia.util.CloudinaryUtil;
import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

@WebServlet("/UploadProfilePic")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1MB bellekte tutulacak eşik
    maxFileSize = 1024 * 1024 * 10,       // 10MB maksimum dosya boyutu (Profil için gayet yeterli)
    maxRequestSize = 1024 * 1024 * 15     // Toplam istek boyutu
)
public class UploadProfilePicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Mantık Kontrolü: Oturum açılmış mı?
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String username = (String) session.getAttribute("user");
        Part filePart = request.getPart("profilePic");

        // Güvenlik: Boş dosya yüklenmesini engelle
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("profile?username=" + username + "&error=empty_file");
            return;
        }

        String profilePicUrl = null;
        try {
            // Merkezi Cloudinary yapımızı çağırıyoruz (API anahtarlarımız artık güvende)
            Cloudinary cloudinary = CloudinaryUtil.getInstance();
            Map uploadResult = cloudinary.uploader().upload(filePart.getInputStream().readAllBytes(), ObjectUtils.emptyMap());
            profilePicUrl = (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile?username=" + username + "&error=upload_failed");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            // Performans: Artık "username" yerine indeksli olan "user_id" üzerinden güncelleme yapıyoruz
            String updateQuery = "UPDATE users SET profile_pic = ? WHERE user_id = ?";
            try (PreparedStatement pst = con.prepareStatement(updateQuery)) {
                pst.setString(1, profilePicUrl);
                pst.setInt(2, userId);
                pst.executeUpdate();
            }
            
            // Başarılı olduğunda, HTML/JSP dosyasına değil, kendi profilimizi toplayan Servlet'e dönüyoruz
            response.sendRedirect("profile?username=" + username);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile?username=" + username + "&error=db_error");
        }
    }
}