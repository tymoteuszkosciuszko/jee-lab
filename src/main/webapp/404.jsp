<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Strona nie znaleziona</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="text/javascript">
        if ( window.addEventListener ) {
            var state = 0, konami = [38,38,40,40,37,39,37,39,66,65];
            window.addEventListener("keydown", function(e) {
                if ( e.keyCode == konami[state] ) state++;
                else state = 0;
                if ( state == 10 ){
                    document.getElementById('404-txt').classList.add("fadeout");
                    document.getElementById('bottom-txt').classList.add("fadeout");
                    document.getElementById('konami-txt').classList.add("fadeout");
                    setTimeout(function (){
                        document.getElementById('giff').classList.remove("hidden");
                        document.getElementById('giff').classList.add("fadein");
                    },1000);
                }
            }, true);
        }

    </script>
    <style>
        .fadeout{
            animation: fadeout 1s ease-in-out forwards;
        }
        .fadein{
            animation: fadein 1s ease-in-out forwards;
        }
        @keyframes fadeout {
            from {
                opacity: 1;
            }
            to {
                opacity: 0;
            }
        }
        @keyframes fadein {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }
        .hidden{
            display: none;
            opacity: 0;
            transition: ease-in-out;
            transition-duration: 1s;
        }
        .delete{
            display: none;
        }
    </style>
</head>
<body class="bg-gradient-to-r from-red-500 to-red-300 text-white">

<div class="flex items-center justify-center min-h-screen text-center">
    <div>
        <h1 id="404-txt" class="text-6xl font-extrabold mb-4">404</h1>
        <img id="giff" class="hidden w-80 mb-6" src="res/minor-spelling-mistake.gif" alt="">
        <p id="bottom-txt" class="text-xl mb-6">Strona, której szukasz, nie istnieje.</p>
        <p title="↑ ↑ ↓ ↓ ← → ← → B A" id="konami-txt" class="text-m mt-12 text-gray-200">Tak, Konami Code tu działa.</p>
    </div>
</div>

</body>
</html>
