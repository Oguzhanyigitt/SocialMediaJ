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

@WebServlet("/post")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB (Bellekte tutulacak miktar)
    maxFileSize = 1024 * 1024 * 50,       // 50MB (Maksimum dosya boyutu)
    maxRequestSize = 1024 * 1024 * 55     // 55MB (Tüm isteğin maksimum boyutu)
)
public class PostServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Mantık Kontrolü 1: Oturum yoksa veya userId session'da değilse işlem yapma
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String content = request.getParameter("content");
        Part mediaPart = request.getPart("media");
        
        // Mantık Kontrolü 2: İçerik boş mu? Sadece boşluk karakteri (space) basıp geçmesini engelliyoruz.
        if (content == null || content.trim().isEmpty()) {
            response.sendRedirect("home?error=empty_content");
            return;
        }

        // XSS Koruması (Basic Level): HTML etiketlerini zararsız metne çeviriyoruz.
        // Böylece tarayıcı bunları kod olarak değil, düz yazı olarak okur.
        content = content.replace("<", "&lt;").replace(">", "&gt;");

        String mediaUrl = null;
        // Dosya yüklenmiş mi kontrolü
        if (mediaPart != null && mediaPart.getSize() > 0) {
            try {
                // Güvenlik adımında yazdığımız yeni merkezi yapıdan Cloudinary'yi çağırıyoruz
                Cloudinary cloudinary = CloudinaryUtil.getInstance();
                Map uploadResult = cloudinary.uploader().upload(mediaPart.getInputStream().readAllBytes(), ObjectUtils.emptyMap());
                mediaUrl = (String) uploadResult.get("secure_url");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("home?error=upload_failed");
                return;
            }
        }

        try (Connection con = DBUtil.getConnection()) {
            // Performans: Artık "SELECT user_id FROM users WHERE username = ?" alt sorgusuna ihtiyacımız yok.
            // ID'yi zaten login olurken bulduk ve session'a koyduk.
            String query = "INSERT INTO Posts (user_id, content, media_url, created_at) VALUES (?, ?, ?, NOW())";
            try (PreparedStatement pst = con.prepareStatement(query)) {
                pst.setInt(1, userId);
                pst.setString(2, content);
                pst.setString(3, mediaUrl);
                pst.executeUpdate();
            }
            response.sendRedirect("home?post=success");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home?error=db_error");
        }
    }
}