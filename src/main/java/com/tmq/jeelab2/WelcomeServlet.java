package com.tmq.jeelab2;

import com.tmq.jeelab2.model.Attribute;
import com.tmq.jeelab2.model.User;
import jakarta.persistence.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/home")
public class WelcomeServlet extends HttpServlet {
    private static final String PERSISTENCE_UNIT_NAME = "jeeAppPU";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if ("logout".equals(request.getParameter("action"))) {
            Cookie userCookie = new Cookie("user", "");
            userCookie.setMaxAge(0);
            response.addCookie(userCookie);
            String message = "Wylogowano pomyślnie.";
            System.out.println(message);
            HttpSession session = request.getSession();
            session.setAttribute("error", message);
            response.sendRedirect("index.jsp");
            return;
        }
        String logoutParam = request.getParameter("logout");
        if ("true".equals(logoutParam)) {
            // Usuń cookie
            Cookie cookie = new Cookie("user", null);
            cookie.setMaxAge(0);
            cookie.setPath("/");
            response.addCookie(cookie);
            response.sendRedirect("index.jsp");
            return;
        }

        String userName = null;
        for (Cookie cookie : request.getCookies()) {
            if ("user".equals(cookie.getName())) {
                userName = cookie.getValue();
                break;
            }
        }

        if (userName == null) {
            String message = "Aby przejść dalej podaj imię.";
            System.out.println(message);
            HttpSession session = request.getSession();
            session.setAttribute("error", message);
            response.sendRedirect("index.jsp");
            return;
        }

        EntityManagerFactory emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        EntityManager em = emf.createEntityManager();

        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.name = :name", User.class)
                    .setParameter("name", userName)
                    .getSingleResult();

            List<Attribute> attributes = user.getAttributes();

            response.setContentType("text/html;charset=UTF-8");
            StringBuilder attributesHtml = new StringBuilder();

            if (!attributes.isEmpty()) {
                attributesHtml.append("""
                <h2 class="text-xl font-bold mb-4 text-center text-gray-800">Twoje atrybuty</h2>
                <table class="w-full text-gray-800">
                    <thead>
                        <tr>
                            <th class="px-4 py-2">Nazwa</th>
                            <th class="px-4 py-2">Wartość</th>
                            <th class="px-4 py-2">Akcja</th>
                        </tr>
                    </thead>
                    <tbody>
            """);
                for (Attribute attr : attributes) {
                    attributesHtml.append("""
                    <tr>
                        <td class="border px-4 py-2">%s</td>
                        <td class="border px-4 py-2">%s</td>
                        <td class="border px-4 py-2 text-center">
                            <form method="post" style="display:inline;">
                                <input type="hidden" name="deleteAttributeId" value="%d">
                                <button type="submit" class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg transition duration-300 ease-in-out transform hover:scale-105">Usuń</button>
                            </form>
                        </td>
                    </tr>
                """.formatted(attr.getAttributeName(), attr.getAttributeValue(), attr.getId()));
                }
                attributesHtml.append("""
                    </tbody>
                </table>
            """);
            }

            response.getWriter().write("""
            <!DOCTYPE html>
            <html lang="pl">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Strona główna</title>
                <script src="https://cdn.tailwindcss.com"></script>
            </head>
            <body class="bg-gradient-to-r from-green-300 to-teal-300 text-white">
            <div class="flex items-center justify-center min-h-screen">
                <div class="bg-white p-8 rounded-lg shadow-lg w-96">
                    <h1 class="text-4xl font-extrabold mb-6 text-center text-gray-800">Witaj, %s!</h1>
                    <form method="post" class="mb-4">
                        <input type="text" name="attributeName" placeholder="Nazwa atrybutu" required class="block text-gray-800 w-full px-4 py-2 mb-2 border transition duration-300 ease-in-out focus:ring-blue-500 rounded-lg">
                        <input type="text" name="attributeValue" placeholder="Wartość atrybutu" required class="block text-gray-800 w-full px-4 py-2 mb-4 border transition duration-300 ease-in-out focus:ring-blue-500 rounded-lg">
                        <button type="submit" class="w-full px-4 py-2 mb-4 bg-blue-500 hover:bg-blue-600 text-white font-bold rounded-lg transition duration-300 ease-in-out transform hover:scale-105">Dodaj atrybut</button>
                    </form>
                    %s
                    <a href="home?action=logout" class="w-full inline-block px-4 py-2 mt-4 bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg text-center transition duration-300 ease-in-out transform hover:scale-105">Wyloguj</a>
                </div>
            </div>
            </body>
            </html>
        """.formatted(userName, attributesHtml.toString()));
        } catch (NoResultException e){
            String errorMessage = "Spróbuj podać imię bez polskich znaków.";
            System.out.println(errorMessage);
            HttpSession session = request.getSession();
            session.setAttribute("error", errorMessage);
            response.sendRedirect("home?action=logout");
            /*response.getWriter().write("""
                    <!DOCTYPE html>
                    <html lang="pl">
                    <head>
                    <meta charset="UTF-8">
                    <h1>dupa nie dzialam</h1>
                    </head>
                    </html>
                    """);*/
        }
        finally {
            em.close();
            emf.close();
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String attributeName = request.getParameter("attributeName");
        String attributeValue = request.getParameter("attributeValue");
        String deleteAttributeId = request.getParameter("deleteAttributeId");
        String userName = null;

        for (Cookie cookie : request.getCookies()) {
            if ("user".equals(cookie.getName())) {
                userName = cookie.getValue();
                break;
            }
        }

        if (userName == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        EntityManagerFactory emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        EntityManager em = emf.createEntityManager();

        try {
            em.getTransaction().begin();

            if (deleteAttributeId != null) {
                // Usuwanie atrybutu
                Attribute attribute = em.find(Attribute.class, Integer.parseInt(deleteAttributeId));
                if (attribute != null) {
                    em.remove(attribute);
                }
            } else if (attributeName != null && attributeValue != null) {
                // Dodawanie nowego atrybutu
                User user = em.createQuery("SELECT u FROM User u WHERE u.name = :name", User.class)
                        .setParameter("name", userName)
                        .getSingleResult();

                Attribute newAttribute = new Attribute();
                newAttribute.setAttributeName(attributeName);
                newAttribute.setAttributeValue(attributeValue);
                newAttribute.setUser(user);

                user.getAttributes().add(newAttribute);
                em.persist(newAttribute);
            }

            em.getTransaction().commit();
        } finally {
            em.close();
            emf.close();
        }

        response.sendRedirect("home");
    }
}
