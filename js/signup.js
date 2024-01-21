fetch("../header/before_header.html")
.then((response) => response.text())
.then((data) => document.querySelector("#header").innerHTML = data);