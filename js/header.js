let logout = document.getElementById('logout');

logout.addEventListener('click', (event) => {
    event.preventDefault();

    if (window.confirm('本当にログアウトしますか？')) {
        window.location.href = '/logout';
    }
})