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

@WebServlet("/post")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,      // Maksimum dosya boyutu: 10 MB
    maxRequestSize = 1024 * 1024 * 15    // Maksimum istek boyutu: 15 MB
)
public class PostServlet extends HttpServlet {

    // Kendi Cloudinary API bilgilerinle BURAYI DEĞİŞTİR:
    private static final Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
        "cloud_name", "doa50jbp4",
        "api_key", "332471892235188",
        "api_secret", "_dNllJagLHuw6kFWTy_FWiuymUw"
    ));

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String mediaUrl = null;

        Part filePart = request.getPart("media");
        // Eğer kullanıcı bir dosya seçtiyse buluta gönder
        if (filePart != null && filePart.getSize() > 0) {
            try {
                // MANTIK BOŞLUĞU KAPATILDI: Dosyayı Render diskine yazmak yerine,
                // InputStream ile RAM'e alıp doğrudan Cloudinary API'sine fırlatıyoruz.
                byte[] fileBytes = filePart.getInputStream().readAllBytes();
                Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.emptyMap());
                
                // Cloudinary'nin bize oluşturduğu kalıcı ve açık "https://" linkini alıyoruz
                mediaUrl = (String) uploadResult.get("secure_url");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("home.jsp?error=upload_failed");
                return;
            }
        }

        // Veritabanına sadece metinleri ve Cloudinary'den gelen URL'yi kaydediyoruz
        try (Connection con = DBUtil.getConnection()) {
            // DİKKAT: Linux büyük/küçük harf duyarlılığı için tablo adlarını küçük yazdım (posts ve users)
            String query = "INSERT INTO Posts (user_id, content, media_url, created_at) VALUES ((SELECT user_id FROM users WHERE username = ?), ?, ?, NOW())";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, username);
            pst.setString(2, content);
            pst.setString(3, mediaUrl);
            
            int rowsAffected = pst.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("home.jsp?post=success");
            } else {
                response.sendRedirect("home.jsp?error=true");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?error=true");
        }
    }
}