fetch("after-header.html")
.then((response) => response.text())
.then((data) => document.querySelector("#header").innerHTML = data);


let deleteButtons = document.querySelectorAll('.styled[value="削除"]');
deleteButtons.forEach(function (button) {
  button.addEventListener('click', function (event) {
    var infoList = event.target.closest('.info-list');
    var entryId = infoList.id;

    if (window.confirm('本当に投稿を削除しますか？')) {
      // サーバーに対して削除リクエストを送信
      fetch("/delete_entry", {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ entryId: entryId })
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // UI からエントリーを削除
          infoList.remove();
          alert('削除が成功しました: ' + data.message);
        } else {
          alert('削除に失敗しました: ' + data.message);
        }
      })
      .catch(error => {
        console.error('エラー:', error);
        alert('削除に失敗しました');
      });
    }
  });
});


