import com.socialmedia.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/searchUsers")
public class SearchUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String query = request.getParameter("q");
        
        // Tarayıcıya HTML değil, JSON (veri formatı) göndereceğimizi söylüyoruz
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (query == null || query.trim().length() < 1) {
            out.print("[]");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {
            // LIKE %...% ile içinde o harfler geçen en fazla 5 kullanıcıyı çekiyoruz
            String sql = "SELECT username, profile_pic FROM users WHERE username LIKE ? LIMIT 5";
            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, "%" + query.trim() + "%");
                
                try (ResultSet rs = pst.executeQuery()) {
                    StringBuilder json = new StringBuilder("[");
                    boolean first = true;
                    while(rs.next()) {
                        if(!first) json.append(",");
                        String uname = rs.getString("username");
                        String pic = rs.getString("profile_pic");
                        pic = (pic != null && !pic.isEmpty()) ? pic : "https://via.placeholder.com/40";
                        
                        // Veriyi JSON formatına çeviriyoruz: {"username": "Ali", "pic": "url"}
                        json.append(String.format("{\"username\":\"%s\", \"pic\":\"%s\"}", uname, pic));
                        first = false;
                    }
                    json.append("]");
                    out.print(json.toString());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("[]");
        }
    }
}