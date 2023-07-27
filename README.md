# Linux - Lista de Comandos

Como entusiasta e utilizador do Linux, montei uma lista de comandos com o intuito de facilitar pesquisas e consolidar conhecimentos já utilizados. Com ela, economizo tempo e consigo manter o foco nas tarefas que estou fazendo sem precisar investir muito tempo para pesquisar conteúdos que já utilizei, podendo entender com minhas próprias palavras como o comando funciona de forma simples e prática, procurando absorver, fixar e me desenvolver em linux, pois sempre há algo novo para aprender em um mundo de código aberto em constante evolução.

Bem-vindo ao mundo dos comandos Linux! 👨‍💻  
Boas descobertas! 😉  

---

| Comando ou Sintaxe | Contexto | Descrição | Exemplo |
| :---               | :----    | :---      | :---    | 
| Comando ou sintaxe    | Contexto    | Descrição | Exemplo ou Conceito |
| service {subcomando} <nome do serviço> | Gerenciamento de Serviço | utiliza-se o comando systemctl para esse tipo de serviço | Conceito |
| service {subcomando} <nome do serviço> | Gerenciamento de Serviço | Apresenta uma lista do status de todos os serviços | service --status-all |
| systemctl {subcomando} <nome do serviço> | Gerenciamento de Serviço | Fornece uma maneira simples e eficaz de iniciar, interromper, reiniciar e monitorar os serviços no sistema. | Conceito | 
| systemctl status <nome do serviço> | Gerenciamento de Serviço | Verificação de status do serviço httpd (apache) | systemctl status httpd.service | 
| systemctl start <nome do serviço> | Gerenciamento de Serviço | Ativação do serviço httpd (apache) | systemctl start httpd.service | 
| systemctl stop <nome do serviço> | Gerenciamento de Serviço | Interrompe o serviço httpd (apache) | systemctl stop httpd.service |
| systemctl status | Gerenciamento de Serviço | Apresenta a lista de todos os serviços em forma de cadeia, assim é possivel verificar os serviços e sub-serviços | Conceito |
| top | Gerenciamento de Serviço | Exibe os processos atualmente em execução, bem como o uso de recursos, como uso de CPU e uso de memória | Conceito |
| kill <numero-do-PID> | Gerenciamento de Serviço | Finaliza o processo no qual foi indicado o ID, é possivel coletar o PID executando o comando top | kill 2967 |
