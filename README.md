🧙‍♂️ Shapeshifter — O Mago das Formas  
"A solução está na transformação."  
Um jogo de puzzle e plataforma 2D desenvolvido em Godot 4, onde você controla um mago capaz de se transformar em diferentes animais para resolver enigmas únicos em cada fase.  
   
🎮 Sobre o Jogo  
Em Shapeshifter, o jogador não vence pela força — vence pela inteligência e pela escolha certa da forma. Cada fase apresenta um puzzle que exige transformar o personagem na criatura certa, na hora certa, para superar obstáculos que nenhuma forma sozinha conseguiria resolver.  
   
🐾 As 4 Formas  
FormaHabilidade PrincipalQuando Usar  
🧙 MagoForma base, neutroNavegação geral  
🐕 CachorroForça, empurrar objetos pesadosMover caixas, cadeiras, obstáculos  
🐀 RatoTamanho pequeno, escalarPassar por frestas, subir superfícies  
🐦 PássaroVoo curtoAlcançar plataformas e itens no alto  
🐟 Peixe-EspadaNadar, mover em águaFases com seções aquáticas  
   
   
🧩 Sistema de Puzzles  
Os puzzles são projetados para exigir múltiplas transformações em sequência. Não existe uma forma "melhor" — cada uma tem seu momento.  
Exemplo de Fase: O Puzzle da Chave no Alto  
📍 Cenário: Uma sala com mesa alta, cadeira derrubada e uma chave na viga do teto.1. 🐕 Vira Cachorro  → Empurra a cadeira derrubada até a mesa2. 🐀 Vira Rato      → Sobe pela cadeira e chega ao topo da mesa3. 🐦 Vira Pássaro   → Dá um voo curto e alcança a chave na viga  
Cada fase foi construída para que a sequência de transformações seja a solução.  
   
🎨 Animações por Forma  
🧙 Mago  
·idle_player — 6 frames  
·caminhar_player — 8 frames  
·pulo_player — 11 frames  
🐕 Cachorro  
·idle_cao — 4 frames  
·cao_correndo — 6 frames  
·cao_pulando — 2 frames  
🐀 Rato  
·idle_rato — 4 frames  
·rato_correndo — 4 frames  
·rato_pulando — 3 frames  
🐦 Pássaro  
·idle_passaro — 4 frames  
·voar_passaro — 6 frames  
🐟 Peixe-Espada  
·idle_peixe — 4 frames  
·peixe_nadando — 4 frames  
·peixe_debatendo — 6 frames (fora d'água)  
   
🗂️ Estrutura do Projeto  
Jogo-Bootcamp/├── scenes/│   └── player.tscn          # Cena principal do jogador├── scripts/│   └── player.gd            # Lógica de movimento e transformação├── sprites/│   ├── Wizard/│   │   ├── Idle.png│   │   ├── Run.png│   │   └── Jump.png│   ├── 1 Dog/│   │   ├── Idle.png│   │   └── Walk.png│   ├── 6 Rat 2/│   │   ├── Idle.png│   │   └── Walk.png│   ├── 7 Bird/│   │   ├── Idle.png│   │   └── Walk.png│   └── peixe-espada/│       ├── Idle.png│       ├── Walk.png│       └── Death.png└── README.md  
   
⚔️ Inimigos  
Os inimigos não são apenas obstáculos — eles fazem parte da solução dos puzzles. Ignorar, fugir ou enfrentar cada um depende da forma escolhida e do contexto da fase.  
Comportamentos  
TipoComportamentoComo Lidar  
PatrulheiroFica fixo em uma área, patrulha um caminhoPassar furtivamente (Rato) ou desviar pela rota alternativa  
PerseguidorDetecta o jogador e o persegue ativamenteFugir em velocidade (Cachorro/Pássaro) ou derrotar  
   
Inimigos como Parte do Puzzle  
Alguns puzzles exigem que o jogador use o inimigo para resolver a fase — seja atraindo-o para uma posição, usando-o como plataforma, ou fazendo-o ativar um mecanismo sem querer.  
💡 Exemplo: Um inimigo patrulheiro bloqueia a única passagem.   O jogador vira Rato para passar por baixo sem ser detectado,   mas precisa que o inimigo se mova para liberar um botão no chão.   A solução: atrair o inimigo com a forma Cachorro e recuar rapidamente.  
A regra de ouro: antes de fugir ou lutar, pense se o inimigo pode ser parte da resposta.  
   
🛠️ Tecnologias  
·Engine:Godot 4  
·Linguagem: GDScript  
·Tipo: 2D Puzzle Platformer  
·Sprites: Pixel Art 2D com spritesheets em atlas  
   
▶️ Como Jogar  
1.Clone o repositório:  
git clone https://github.com/Cesar-Tapuio/Jogo-Bootcamp.git  
2.Abra o projeto no Godot 4  
3.Execute a cena principal  
4.Use as teclas de movimento para se locomover  
5.Pressione o botão de transformação para alternar entre as formas  
   
🚀 Status do Projeto  
🚧 Em desenvolvimento — projeto criado durante Bootcamp  
·Sistema de transformação implementado  
·Animações de todas as formas  
·Colisores individuais por forma  
·Fases completas  
·Sistema de puzzles finalizado  
·Inimigos implementados  
·IA dos inimigos (patrulha e perseguição)  
·Menu e UI  
