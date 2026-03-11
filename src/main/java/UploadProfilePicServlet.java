import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

@WebServlet("/UploadProfilePic")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5,      // Profil fotoları için 5 MB yeterlidir
    maxRequestSize = 1024 * 1024 * 10   // Maksimum istek boyutu: 10 MB
)
public class UploadProfilePicServlet extends HttpServlet {

    // PostServlet'e yazdığın kendi Cloudinary API bilgilerinle BURAYI DEĞİŞTİR:
    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
    		"cloud_name", "doa50jbp4",
            "api_key", "332471892235188",
            "api_secret", "_dNllJagLHuw6kFWTy_FWiuymUw"
    ));

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Oturumdaki kullanıcıyı alıyoruz
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // JSP formundaki name="profilePic" değerini yakalıyoruz
        Part filePart = request.getPart("profilePic");
        String profilePicUrl = null;

        if (filePart != null && filePart.getSize() > 0) {
            try {
                // Dosyayı hafızaya alıp Cloudinary'ye yüklüyoruz
                byte[] fileBytes = filePart.getInputStream().readAllBytes();
                Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.emptyMap());
                
                // Cloudinary'nin oluşturduğu kalıcı URL'yi çekiyoruz
                profilePicUrl = (String) uploadResult.get("secure_url");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("error.jsp");
                return;
            }
        } else {
            // Kullanıcı dosya seçmeden butona basarsa geri gönder
            response.sendRedirect("profile?username=" + username);
            return;
        }

        // Veritabanındaki 'profile_pic' sütununu UPDATE komutuyla güncelliyoruz
        try (Connection con = DBUtil.getConnection()) {
            // Linux büyük/küçük harf duyarlılığı için tablo adını 'users' olarak yazdık
            String query = "UPDATE users SET profile_pic = ? WHERE username = ?";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, profilePicUrl);
            pst.setString(2, username);
            
            int rowsAffected = pst.executeUpdate();
            if (rowsAffected > 0) {
                // Yükleme başarılıysa kullanıcının kendi profiline yönlendir
                response.sendRedirect("profile?username=" + username);
            } else {
                response.sendRedirect("error.jsp");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}