import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Tüm kritik endpoint'ler koruma altında. JSP dosyalarına doğrudan erişimi engellemek için onları da ekledik.
@WebFilter(urlPatterns = {
    "/home", "/profile", "/post", "/like", "/comment", 
    "/deletePost", "/deleteComment", "/UploadProfilePic", 
    "/follow", "/searchUsers", "/friendships", 
    "/home.jsp", "/profile.jsp", "/post.jsp", "/friendships.jsp"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Önbellek Kapatma: Tarayıcının "Geri" tuşuyla yetkisiz sayfa yüklemesini engeller.
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
        response.setHeader("Pragma", "no-cache"); 
        response.setDateHeader("Expires", 0); 

        HttpSession session = request.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("userId") != null);

        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }
}