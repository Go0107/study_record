let logout = document.getElementById('logout');

logout.addEventListener('click', () => {
    if (window.confirm('本当にログアウトしますか？')) {
        window.location.href = '../../pages/index.html';
    }
})