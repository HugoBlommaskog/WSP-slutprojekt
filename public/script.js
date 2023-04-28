function likePost(userId, postId) {
    fetch(`/posts/${postId}/likes`, {method: 'POST'});

    let likeThing = document.getElementById(postId);
    let unliked = likeThing.querySelector(".unliked")
    let liked = likeThing.querySelector(".liked")
    let count = likeThing.querySelector(".count")
    count.innerHTML = parseInt(count.innerHTML) + 1

    // Hide the outlined button and display the filled one
    unliked.classList.add("hidden")
    liked.classList.remove("hidden")
}

function unlikePost(userId, postId) {
    fetch(`/posts/${postId}/likes`, {method: 'DELETE'})

    let likeThing = document.getElementById(postId);
    let unliked = likeThing.querySelector(".unliked")
    let liked = likeThing.querySelector(".liked")
    let count = likeThing.querySelector(".count")
    count.innerHTML = parseInt(count.innerHTML) - 1

    // Hide the outlined button and display the filled one
    liked.classList.add("hidden")
    unliked.classList.remove("hidden")
}