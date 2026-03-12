import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Bu filtre, uygulamanın kalbini oluşturan tüm adresleri koruma altına alır
@WebFilter(urlPatterns = {"/home", "/profile", "/post", "/like", "/comment", "/deletePost", "/deleteComment", "/UploadProfilePic"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // BÜYÜK ÇÖZÜM: Tarayıcıya sayfayı KESİNLİKLE önbelleğe (cache) almamasını söylüyoruz.
        // Böylece "Geri" tuşuna basıldığında tarayıcı hafızadan yükleyemez, sunucuya sormak zorunda kalır.
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxyler için

        HttpSession session = request.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("userId") != null);

        if (isLoggedIn) {
            chain.doFilter(request, response); // Giriş yapılmış, yola devam et
        } else {
            response.sendRedirect("index.jsp"); // Oturum yoksa veya geri tuşuyla gelinmişse acımasızca index'e at
        }
    }
}