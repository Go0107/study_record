fetch("../header/after_header.html")
.then((response) => response.text())
.then((data) => document.querySelector("#header").innerHTML = data);

let deleteButton = document.getElementById('delete');

deleteButton.addEventListener('click', (event) => {
    event.preventDefault();

    if (window.confirm('本当に投稿を削除しますか？')) {
        window.location.reload();
    }
})