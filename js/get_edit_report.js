document.querySelectorAll('.styled.edit').forEach(function(editButton) {
  editButton.addEventListener('click', function() {
    // クリックされたボタンに関連する記事のIDを取得
    var reportId = this.getAttribute('data-report-id');

    // Ajaxリクエストを行う
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/get_edit_report?report_id=' + reportId, true);

    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          // レスポンスの処理を行う
          console.log(xhr.responseText);
          
          // レスポンスを受けたら編集ページに遷移する
          window.location.href = 'http://localhost:3000/edit_diary.html?report_id=' + reportId;
        } else {
          // エラー時の処理をここに追加
          console.error('Failed to get edit report. Status code: ' + xhr.status);
        }
      }
    };

    xhr.send();
  });
});
