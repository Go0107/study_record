fetch("/after-header.html")
.then((response) => response.text())
.then((data) => document.querySelector("#header").innerHTML = data);


let today = new Date();
today.setDate(today.getDate());
let yyyy = today.getFullYear();
let mm = ("0"+(today.getMonth()+1)).slice(-2);
let dd = ("0"+today.getDate()).slice(-2);
document.getElementById("today").value=yyyy+'-'+mm+'-'+dd;
