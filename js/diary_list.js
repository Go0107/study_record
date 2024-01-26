fetch("/after_header.html")
.then((response) => response.text())
.then((data) => document.querySelector("#header").innerHTML = data);

let deleteButtons = document.querySelectorAll('.styled[value="削除"]');

// NodeList内の各要素に対してループをかける
deleteButtons.forEach(function(button) {
  button.addEventListener('click', function(event) {
    var infoList = findAncestor(event.target, 'info-list');

      if (infoList) {
        var infoListId = infoList.getAttribute('id');
        deleteDatabase(infoListId);
    }
  });
});

// 指定されたクラス名を持つ親要素を検索する関数
function findAncestor(element, className) {
  while ((element = element.parentElement) && !element.classList.contains(className));
  return element;
}

function deleteDatabase(infoListId) {
  let xhr = new XMLHttpRequest();

  xhr.open('GET', '/delete_request?id=' + encodeURIComponent(infoListId), true);

  xhr.onload = function() {
    if (xhr.status >= 200 && xhr.status < 300) {
        // 成功時の処理
        console.log('データベースから削除されました。ページをリロードします。');
        location.reload();
    } else {
        // エラー時の処理
        console.error('失敗');
    }
};

  xhr.send();
}

