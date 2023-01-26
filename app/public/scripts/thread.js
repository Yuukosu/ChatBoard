$(document).ready(() => {
	commentForm = $('#comment-form');

	if (commentForm != null) {
		commentForm.on('submit', (e) => {
			e.preventDefault();
			comment = $("#comment").val();
			$.post("/api/post_message/<%%>")
		});
	}
});
