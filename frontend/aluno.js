let editandoId = null;

function servidor() {
    let AlunoNome = document.querySelector("#nome").value;
    let AlunoCPF = document.querySelector("#cpf").value;
    let AlunoTelefone = document.querySelector("#telefone").value;
    let AlunoIdade = parseInt(document.querySelector("#idade").value);
    let AlunoPeso = parseFloat(document.querySelector("#peso").value);
    let AlunoAltura = parseFloat(document.querySelector("#altura").value);

    let metodo = editandoId ? "PUT" : "POST";
    let url = editandoId 
        ? `http://localhost:8080/aluno/${editandoId}` 
        : "http://localhost:8080/aluno";

    fetch(url, {
        method: metodo,
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
            id: editandoId ?? 0,
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
        document.querySelector("#res").innerHTML = editandoId
            ? "Aluno atualizado!"
            : "Aluno cadastrado! ID: " + json.resultado;

        editandoId = null;
        document.querySelector("#btn").innerText = "Cadastrar";

        atualizarAlunos();
    })
    .catch(error => alert(error));
}

function teste(){
    document.querySelector("#btn").addEventListener("click", servidor);
}

function atualizarAlunos() {
    fetch("http://localhost:8080/aluno")
        .then(response => response.json())
        .then(json => {
            let tabela = document.querySelector("#tabelaAlunos tbody");
            tabela.innerHTML = "";

            json.alunos.forEach(alu => {
                let linha = `
                    <tr>
                        <td>
                            <button onclick="editarAluno(${alu.id})">Editar</button>
                            <button onclick="excluirAluno(${alu.id})">Excluir</button>
                        </td>
                        <td>${alu.id}</td>
                        <td>${alu.nome}</td>
                        <td>${alu.cpf}</td>
                        <td>${alu.telefone}</td>
                        <td>${alu.idade}</td>
                        <td>${alu.peso}</td>
                        <td>${alu.altura}</td>
                    </tr>
                `;
                tabela.innerHTML += linha;
            });
        })
        .catch(err => alert("Erro ao atualizar alunos: " + err));
}

function excluirAluno(id) {
    if (!confirm("Tem certeza que deseja excluir o aluno " + id + "?")) return;

    fetch(`http://localhost:8080/aluno/${id}`, {
        method: "DELETE"
    })
    .then(res => {
        if (res.ok) {
            alert("Aluno excluído!");
            atualizarAlunos();
        } else {
            alert("Erro ao excluir aluno.");
        }
    })
    .catch(err => alert("Erro: " + err));
}

function editarAluno(id) {
    fetch(`http://localhost:8080/aluno/${id}`)
        .then(res => res.json())
        .then(json => {
            let alu = json.aluno;

            document.querySelector("#nome").value = alu.nome;
            document.querySelector("#cpf").value = alu.cpf;
            document.querySelector("#telefone").value = alu.telefone;
            document.querySelector("#idade").value = alu.idade;
            document.querySelector("#peso").value = alu.peso;
            document.querySelector("#altura").value = alu.altura;

            editandoId = id;

            document.querySelector("#btn").innerText = "Salvar Edição";
        });
}

window.onload = () => {
    teste();
    atualizarAlunos();
};
