function likePost(userId, postId) {
    fetch(`/posts/${postId}/likes`, {method: 'POST'});

    let post = document.getElementById(postId);
    console.log(post)
}

function unlikePost(userId, postId) {
    fetch(`/posts/${postId}/likes`, {method: 'DELETE'}
}