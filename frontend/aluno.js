function servidor(){
    let AlunoNome = document.querySelector("#nome").value;
    let AlunoCPF = document.querySelector("#cpf").value;
    let AlunoTelefone = document.querySelector("#telefone").value;
    let AlunoIdade = parseInt(document.querySelector("#idade").value);
    let AlunoPeso = parseFloat(document.querySelector("#peso").value);
    let AlunoAltura = parseFloat(document.querySelector("#altura").value);
    fetch("http://localhost:8080/aluno",{
        method: "POST",
        headers: {"content-type" : "application/json"},
        body: JSON.stringify({
            id: 0,
            nome: AlunoNome,
            cpf: AlunoCPF,
            telefone: AlunoTelefone,
            idade: AlunoIdade,
            peso: AlunoPeso,
            altura: AlunoAltura
        }),
    })
    .then(response => response.json())
    .then(json => {
        document.querySelector("#res").innerHTML = "id: " + json.resultado
    })
    .catch(error => alert(error))
}

function teste(){
    document.querySelector("#btn").addEventListener("click", () => {
        servidor()
    })
}

window.onload = teste