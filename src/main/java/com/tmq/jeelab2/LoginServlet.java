package com.tmq.jeelab2;

import com.tmq.jeelab2.model.User;
import jakarta.persistence.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final String PERSISTENCE_UNIT_NAME = "jeeAppPU";
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("index.jsp");
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        for (Cookie cookie : request.getCookies()) {
            if ("user".equals(cookie.getName())) {
                response.sendRedirect("welcome.jsp");
                return;
            }
        }
        if (name == null || name.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        EntityManagerFactory emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        EntityManager em = emf.createEntityManager();

        try {
            em.getTransaction().begin();
            User user = em.createQuery("SELECT u FROM User u WHERE u.name = :name", User.class)
                    .setParameter("name", name)
                    .getResultStream()
                    .findFirst()
                    .orElseGet(() -> {
                        User newUser = new User();
                        newUser.setName(name);
                        em.persist(newUser);
                        return newUser;
                    });
            em.getTransaction().commit();

            Cookie userCookie = new Cookie("user", name);
            userCookie.setMaxAge(60 * 30); // Sesja na 30 minut
            response.addCookie(userCookie);
            response.sendRedirect("welcome.jsp");
        } catch (IllegalArgumentException e) {
            String errorMessage = "Spróbuj podać imię bez znaków specjalnych (w tym polskich znaków).";
            System.out.println(errorMessage);
            HttpSession session = request.getSession();
            session.setAttribute("error", errorMessage);
            response.sendRedirect("index.jsp");
        } catch (PersistenceException e){
            e.printStackTrace();
            String errorMessage = "Wystąpił problem z bazą danych.";
            System.out.println(errorMessage);
            HttpSession session = request.getSession();
            session.setAttribute("error", errorMessage);
            response.sendRedirect("index.jsp");
        }
        finally {
            em.close();
            emf.close();
        }
    }
}
