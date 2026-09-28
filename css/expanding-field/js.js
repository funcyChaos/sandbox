const results = document.getElementById("results")
let showResults = false

document.getElementById("text_test").addEventListener("input", e=>{
    if(!showResults){
        results.classList.add("open")
        showResults = true
    }else{
        if(!e.data){
            showResults = false
            results.classList.add("close")
            results.addEventListener("animationend", e=>{
                results.classList.remove("open", "close")
            }, {once:true})
        }
    }
})