<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.persistence.*, java.util.*, com.tmq.jeelab2.model.*" %>
<%@ taglib uri = "http://java.sun.com/jsp/jstl/core" prefix = "c" %>
<%
    // Sprawdzenie, czy użytkownik jest zalogowany
    Cookie[] cookies = request.getCookies();
    String userName = null;

    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("user".equals(cookie.getName())) {
                userName = cookie.getValue();
                break;
            }
        }
    }

    if (userName == null) {
        session.setAttribute("error", "Aby przejść dalej, podaj imię.");
        response.sendRedirect("index.jsp");
        return;
    }

    // Ustawienie EntityManagera
    EntityManagerFactory emf = Persistence.createEntityManagerFactory("jeeAppPU");
    EntityManager em = emf.createEntityManager();

    User user = null;
    List<Attribute> attributes = new ArrayList<>();
    try {
        user = em.createQuery("SELECT u FROM User u WHERE u.name = :name", User.class)
                .setParameter("name", userName)
                .getSingleResult();
        attributes = user.getAttributes();
    } catch (NoResultException e) {
        session.setAttribute("error", "Spróbuj podać imię bez polskich znaków.(NoResultException)");
        response.sendRedirect("index.jsp");
        em.close();
        emf.close();
        return;
    } catch (IllegalStateException e){
        session.setAttribute("error", "Spróbuj podać imię bez polskich znaków. (IllegalStateException)");
        response.sendRedirect("index.jsp");
        em.close();
        emf.close();
        return;
    }
    finally {
        em.close();
        emf.close();
    }
%>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Powitanie</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-r from-green-300 to-teal-300 text-white">
<div class="flex items-center justify-center min-h-screen">
    <div class="bg-white p-8 rounded-lg shadow-lg w-96">
        <!-- Nagłówek powitania -->
        <h1 class="text-4xl font-extrabold mb-6 text-center text-gray-800">Witaj, <%= userName %>!</h1>

        <!-- Formularz dodawania atrybutów -->
        <form action="welcome.jsp" method="post" class="mb-4">
            <input type="text" name="attributeName" placeholder="Nazwa atrybutu" required class="block text-gray-800 w-full px-4 py-2 mb-2 border rounded-lg">
            <input type="text" name="attributeValue" placeholder="Wartość atrybutu" required class="block text-gray-800 w-full px-4 py-2 mb-4 border rounded-lg">
            <button type="submit" class="w-full px-4 py-2 mb-4 bg-blue-500 hover:bg-blue-600 text-white font-bold rounded-lg">Dodaj atrybut</button>
        </form>

        <!-- Wyświetlanie atrybutów -->
        <%
            if (!attributes.isEmpty()) {
        %>
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

            <c:forEach var="attribute" items="${attributes}">
                <tr>
                    <td class="border px-4 py-2">${attribute.attributeName}</td>
                    <td class="border px-4 py-2">${attribute.attributeName}</td>
                    <td class="border px-4 py-2">
                        <form action="welcome.jsp" method="post" style="display:inline;">
                            <input type="hidden" name="deleteAttributeId" value="${attribute.id}">
                            <button type="submit" class="px-2 py-1 bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg">Usuń</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>

            </tbody>
        </table>
        <%
            }
        %>

        <!-- Przycisk wylogowania -->
        <a href="welcome.jsp?action=logout" class="w-full inline-block px-4 py-2 mt-4 bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg text-center">Wyloguj</a>
    </div>
</div>
</body>
</html>

<%
    // Obsługa dodawania atrybutów
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String attributeName = request.getParameter("attributeName");
        String attributeValue = request.getParameter("attributeValue");
        String deleteAttributeId = request.getParameter("deleteAttributeId");

        emf = Persistence.createEntityManagerFactory("jeeAppPU");
        em = emf.createEntityManager();

        try {
            em.getTransaction().begin();

            if (attributeName != null && attributeValue != null) {
                Attribute newAttribute = new Attribute();
                newAttribute.setAttributeName(attributeName);
                newAttribute.setAttributeValue(attributeValue);
                newAttribute.setUser(user);
                user.getAttributes().add(newAttribute);
                em.persist(newAttribute);
            }

            if (deleteAttributeId != null) {
                Attribute attrToDelete = em.find(Attribute.class, Integer.parseInt(deleteAttributeId));
                if (attrToDelete != null) {
                    em.remove(attrToDelete);
                }
            }

            em.getTransaction().commit();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
            emf.close();
        }

        // Odświeżenie strony po wykonaniu operacji
        response.sendRedirect("welcome.jsp");
    }

    // Obsługa wylogowania
    if ("logout".equals(request.getParameter("action"))) {
        Cookie userCookie = new Cookie("user", "");
        userCookie.setMaxAge(0); // Usunięcie ciasteczka
        response.addCookie(userCookie);
        session.setAttribute("error", "Wylogowano pomyślnie.");
        response.sendRedirect("index.jsp");
    }
%>
