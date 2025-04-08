<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  Cookie[] cookies = request.getCookies();
  for (Cookie cookie : cookies) {
    if ("user".equals(cookie.getName())) {
      response.sendRedirect("welcome.jsp");
      return;
    }
  }
%>
<!DOCTYPE html>
<html lang="pl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Logowanie</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    #errorBox {
      display: none;
      position: fixed;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      background-color: #bfdbfe;
      color: #3b82f6;
      border: 1px solid #93c5fd;
      padding: 10px 20px;
      border-radius: 8px;
      width: 96%;
      max-width: 24rem;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      font-weight: 600;
      text-align: center;
      z-index: 1000;
      opacity: 1;
      transition: opacity 2s ease-in-out;
    }
    #errorBox.hidden {
      opacity: 0;
    }
  </style>
</head>
<body class="bg-gradient-to-r from-sky-300 to-indigo-300 flex items-center justify-center min-h-screen">
<div class="bg-white p-8 rounded-lg shadow-lg w-96">
  <h1 class="text-3xl font-semibold text-center text-gray-800 mb-6">Logowanie</h1>
  <form action="login" method="post">
    <div class="mb-4">
      <input placeholder="Imię" class="text-gray-800 mt-1 p-2 w-full border border-gray-300 rounded-md focus:outline-none focus:ring-2 transition duration-300 ease-in-out focus:ring-blue-500" type="text" id="name" name="name" required>
    </div>
    <div>
      <button type="submit" class="w-full py-2 mt-4 bg-blue-500 text-white font-semibold rounded-lg hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-300 ease-in-out transform hover:scale-105">Zaloguj</button>
    </div>
  </form>
</div>

<%
  String error = (String) session.getAttribute("error");
  if (error != null && !error.isEmpty()) {
    session.removeAttribute("error");
%>
<div id="errorBox">
  <p><%= error %></p>
</div>
<% } %>

<script>
  function showErrorBox() {
    const errorBox = document.getElementById('errorBox');
    if (errorBox) {
      errorBox.style.display = 'block';
      setTimeout(() => {
        errorBox.classList.add('hidden');
      }, 4000);
      setTimeout(() => {
        errorBox.style.display = 'none';
      }, 6000);
    }
  }
  window.onload = function() {
    showErrorBox();
  };
</script>
</body>
</html>
