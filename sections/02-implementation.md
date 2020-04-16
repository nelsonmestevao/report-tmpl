# Cliente de Vendas {#sec:cv}

Recebe pedidos através do `STDIN` que comunica ao servidor e mostra os
resultados obtidos pelo `STDOUT`. Os pedidos contém sempre o código do artigo
associado. Se o pedido apenas contiver o código, é mostrado o seu stock e preço.
Caso o código venha acompanhado de uma quantidade é pedido ao servidor para
atualizar o stock desse artigo; O servidor envia o novo stock ao cliente de
vendas e este mostra-o.

```
$ ./bin/cv
<código_numérico>              --> mostra no stdout stock e preço
<código_numérico> <quantidade> --> actualiza stock e mostra novo stock
...
<EOF>
```

Os pedidos são comunicados ao servidor através da escrita num pipe com nome
criado pelo servidor. Essa escrita contém a estrutura `LCliente`.

```C
typedef struct linhaCliente {
   char operacao;
   unsigned long int codigo;
   long int quantidade;
   char nomeCliente[128];
} LCliente;
```

O primeiro campo desta estrutura contém um `char` identificativo. Se este campo
contiver um *a*, é porque se trata de uma atualização de *stock*, se contiver um
*c* é porque se trata de uma consulta de *stock*.

O segundo campo contém o código do artigo e o terceiro a quantidade (caso seja
necessário para a operação).

O último campo, contém o nome do pipe criado pelo cliente que o servidor deverá
usar para enviar as respostas.

As respostas são enviadas na forma das estruturas de `LinhaAtualiza` e
`LinhaConsulta`.

```C
typedef struct linhaAtualiza {
    unsigned long int codigo;
    unsigned long int stock;
} LinhaAtualiza;
```

```C
typedef struct linhaConsulta {
    unsigned long int stock;
    float preco;
} LinhaConsulta;
```

# Implementação

O programa `gerar` recebe três argumentos à sua chamada:

- dificuldade;
- número de linhas;
- número de colunas.

A dificuldade pode variar entre fácil (1) e difícil (2). O número de linhas e o
número de colunas podem variar entre 1 e 20[^1]. Assim sendo, começamos por
construir a nossa estrutura de dados que servirá para a construção do tabuleiro.
A sua definição pode ser vista no seguinte bloco de código:

[^1]: O `MAX_GRID` é definido como $20$.

```C
  typedef struct puzzle {
    int num_lins, num_cols;
    int validade;
    int sizeU, sizeR, numAncs;
    LISTA undo, redo;
    char grelha[MAX_GRID][MAX_GRID];
  } PUZZLE;
```

Os dois primeiros inteiros representam a dimensão do tabuleiro e são
inicialmente atribuídos com os argumentos do programa. Ao inteiro `validade` é
atribuído o valor `VALIDO`.

```C
  typedef enum {INVALIDO, IMPOSSIVEL, VALIDO} VALIDADE;
```

A lista `undo` e `redo` são definidas como listas ligadas com três inteiros, em
que o `x` e o `y` são a posição da jogada e o `a` é o número da ancora em que o
puzzle estava no momento da jogada.

```C
  typedef struct lista {
      int x, y, a;
      struct lista *next;
  } *LISTA;
```

Os inteiros `sizeU`, `sizeR` e `numAncs` indicam o tamanho da lista `undo`, da
lista `redo` e o número de ancoras até ao momento, respetivamente. Cada elemento
da grelha tem um `VALOR` associado que pode ser descrito pelo bloco de código
seguinte.

```C
  typedef enum { BLOQUEADA,
                 FIXO_X, FIXO_O,
                 VAZIA,
                 SOL_X, SOL_O
               } VALOR;
```

Cada `VALOR` está diretamente ligado a uma peça apresentada na Figura 1. A
diferença entre um `FIXO_X` e um `SOL_X` é que o primeiro é uma peça do próprio
tabuleiro, e a segunda uma peça jogada. Na construção do tabuleiro o `SOL_X` e o
`SOL_O` serão usadas como auxiliares.

No nosso programa, após verificarmos a validade dos argumentos declaramos um
tabuleiro e inicializamos as posições com o valor `VAZIA`.

```C
  for (i = 0; i < board->num_cols; i++)
    for (j = 0; j < board->num_lins; j++)
      board->grelha[i][j] = VAZIA;
```

Uma das primeiras características que o nosso programa precisava de ter era uma
certa aleatoriedade. Não seria de todo interessante se dados os mesmos
argumentos, obtivéssemos o mesmo tabuleiro. Para tal, usando a função `rand()` e
uma divisão modular pelo número de colunas desejadas pelo o utilizador,
escolhemos a coluna (`x`) da casa em que iremos jogar. O mesmo se aplica para a
linha (`y`).

```C
  int x = rand() % board->num_cols;
  int y = rand() % board->num_lins;
```

Para a escolha do tipo de peça que será colocada recorremos a uma estratégia
semelhante.

```C
  int k = rand() % 2;
  if (board->grelha[x][y] == VAZIA)
    board->grelha[x][y] = k == 1 ? FIXO_X : FIXO_O;
```

No caso do `if statement` der negativo, voltamos a tentar encontrar outra casa
aleatoriamente usando os mesmos processos, sendo que nunca é colocada uma peça
num local onde o tabuleiro ficaria invalido, ou seja, se encontrar uma peça
vazia onde não poderá ser colocado um `FIXO_X` então é colocada um `FIXO_O`
nessa posição e vice-versa.  Graficamente, começamos com um tabuleiro vazio e
fazemos uma jogada aleatória nesse tabuleiro.  Isto não compromete a validade do
tabuleiro porque para qualquer dimensão entre 1 e 20, com nenhuma peça, existem
várias soluções possíveis. Supondo que o tabuleiro pretendido tem dimensão 3 por
3, a Figura 5 representa o como o puzzle está e como fica após aplicada a
estratégia descrita anteriormente.

![Jogada aleatória na posição (1,2) seguida de jogada aleatória na posição (2,1)](figures/randomPlay.pdf){ height=4.5cm }

Nesta fase, ainda não existem peças suficientes para fazer jogadas definitivas.
Seja qual for a casa escolhida, tanto uma cruz como uma bola pode levar a um
tabuleiro possível de resolver. Desta forma, voltamos a fazer uma jogada
aleatória usando a mesma estratégia. Suponhamos que a posição escolhida foi
(2,1) com uma cruz. Nesse momento, existe uma jogada obrigatória na posição
(3,2) que é uma bola. Essa jogada obrigatória é feita com um `SOL_O`[^2], uma
vez que é só uma peça auxiliar que não constará no tabuleiro final (nesta
posição existe só uma possibilidade e por isso a ausência desta não levará a
nenhuma solução dupla).

![Jogada obrigatória feita na posição (3,2)](figures/jogadaObvia.pdf){ height=4.5cm }

[^2]: As peças auxiliares (`SOL_X` e `SOL_O`) têm contorno branco.

Nesta fase, volta a não existir uma jogada obrigatória e, por isso, é atribuída
uma jogada aleatória. Começaremos com o nível de dificuldade fácil. Suponhamos
que essa jogada é na posição (1,2) uma bola. Uma vez que esta não é invalida e
não cria jogada óbvia, volta-se a repetir o procedimento. Se calhar uma bola na
posição (3,3), passamos a ter um jogada obrigatória na casa (3,1) que terá o
valor de `SOL_X`.

![Etapas de construção de tabuleiro fácil](figures/etapasFacil.pdf)

Nesta fase, o procedimento é repetido levando à situação em que na posição (1,1)
é indiferente qual o tipo peça colocada.

![Tabuleiro fácil completo](figures/etapasFacil2.pdf){ height=4.5cm }

Este processo é executado através da função `solver_easy`.  Esta função tentará
para as casas vazias colocar quer uma cruz quer uma bola e verificar se torna o
tabuleiro inválido. Caso assim seja, é porque poderá ter encontrado que naquela
casa que só a peça contrária é valida.  Se encontrar tal para os dois, é porque
terá que ser bloqueada. A sua implementação pode ser lida no próximo bloco de
código.

```C
  int solver_easy (PUZZLE *board, int *x, int *y)
  {
    int i, j, found, foundX, foundO;
    i = j = found = foundX = foundO = 0;
    for (i = 0; i < board->num_cols && !found; i++)
      for (j = 0; j < board->num_lins && !found; j++)
        if (board->grelha[i][j] == VAZIA) {
          board->grelha[i][j] = SOL_X;
          if (!validaPeca (board, i, j))
            foundO = 1;
          board->grelha[i][j] = SOL_O;
          if (!validaPeca (board, i, j))
            foundX = 1;
          if (foundX && foundO) {
            found = 2; *x = i; *y = j;
            board->grelha[i][j] = BLOQUEADA;
          } else if (foundX) {
            board->grelha[i][j] = SOL_X;
            found = 1; *x = i; *y = j;
          } else if (foundO) {
            board->grelha[i][j] = SOL_O;
            found = 1; *x = i; *y = j;
          } else board->grelha[i][j] = VAZIA;
        }
    return found;
  }
```

Após o tabuleiro ser verificado como completo, todas as peças auxiliares são
removidas do resultado final. O tabuleiro resultante está representado na Figura
9.

![Tabuleiro fácil de dimensão 3 por 3](figures/tabuleiroFacil.pdf){ height=4cm }

A diferença entre a construção de tabuleiros fáceis e difíceis é que, não só são
acrescentadas peças bloqueadas e fixas aleatórias ao tabuleiro fácil sendo a
quantidade dessas mesmas peças dependente da "área" do tabuleiro, como também
casos que eram considerados como não tendo uma jogada óbvia no tabuleiro fácil
apenas é gerado uma nova peça fixa até voltar a haver jogadas óbvias, enquanto
que no difícil são procuradas peças que não são de jogada imediata mas são peças
que tem se der um determinado tipo para que o mapa seja válido, acrescentando
assim a necessidade de suposição aos tabuleiros mais difíceis.

Seguindo o raciocínio da Figura 10, vamos supor que na casa (3,2) colocamos um
`SOL_O` e vamos verificar se isso nos leva a um caso impossível.

![Suposição que leva a caso impossível](figures/sequenciaImpossivelDificil.pdf){ height=6.5cm }

Isto quererá dizer que na casa (3,2) ou é uma cruz ou terá de ser bloqueada.
Testando isso, verificamos que é possível ter uma cruz, uma vez que não nos leva
a nenhuma impossibilidade.

![Suposição possível](figures/sequenciaPossivel.pdf){ height=6.5cm }

Na Figura 11, mostra a sequência de decisões lógicas resultantes de fazer aquela
suposição. No final, se fizermos a mesma suposição na casa (1,1) verificamos que
tanto pode ser bola como cruz. Por isso, temos de colocar um `FIXO_X` ou um
`FIXO_O`. Se colocarmos um `FIXO_O` seria mais rápido chegar a uma conclusão.
Mas a escolha poderia ser aleatória. A Figura 12, mostra o tabuleiro resultante
de colocar `FIXO_O`.

![Resultado para um tabuleiro difícil](figures/tabuleiroDificil.pdf){ height=3cm }

O seguinte bloco de código mostra como é feito este processo.

```C
  int solver_hard (PUZZLE *board)
  {
    int i, j, found, foundX, foundO;
    found = foundX = foundO = 0;
    for (i = 0; (i < board->num_cols) && !found; i++)
      for (j = 0; (j < board->num_lins) && !found; j++)
        if (board->grelha[i][j] == VAZIA) {
          board->grelha[i][j] = SOL_O;
          found = 0; supor(board,&found);
          if (found == 2) foundX = 1;
          voltaAncora (board); board->grelha[i][j] = SOL_X;
          found = 0; supor(board,&found);
          if (found == 2) foundO = 1;
          if (foundX && foundO) {
            board->grelha[i][j] = BLOQUEADA; found=0;
          } else if (foundX) {
            board->grelha[i][j] = SOL_X; found = 1;
          } else if (foundO) {
            board->grelha[i][j] = SOL_O; found = 1;
          } else {
            board->grelha[i][j] = VAZIA; found = 0;
          }
        voltaAncora(board);
        }
    return found;
  }
```
A função de suposição é uma função auxiliar da `solver_hard` e é definida no
bloco de código seguinte.

```C
  void supor (PUZZLE *board,int *found)
  {
    int x, y, tmp;
    marcaAncora(board);
    while ((*found )==0)
    {
      tmp = solver_easy (board, &x, &y);
      if (tmp == 1)
      {
        push(x, y, board->numAncs, &(board->undo));
        board->sizeU++;
      } else if (tmp == 2) {
        board->grelha[x][y] = VAZIA;
        *found = 2;
      } else if (tmp == 0) *found = 1;
    }
  }
```

Em tabuleiros de dimensão pequena, os tabuleiros acabam por não se diferenciar
muito em termos de dificuldade. No entanto, com maiores dimensões fica mais
clara a distinção.

# Testes de Desempenho

Os valores dos testes apresentados resultam executar o mesmo teste 20 vezes no
mesmo computador.

## Manutenção de Artigos

| Quantidade | Média  | $\sigma$ | Min    | Max    |
|-----------:|-------:|---------:|-------:|-------:|
|      1 000 |  0.015 |    0.002 |  0.013 |  0.018 |
|     10 000 |  0.143 |    0.004 |  0.136 |  0.152 |
|    100 000 |  1.419 |    0.013 |  1.401 |  1.453 |
|  1 000 000 | 14.410 |    0.080 | 14.254 | 14.562 |

: Tempo (em segundos) de inserir artigos pelo programa de manutenção
de artigos.

| Quantidade | Média  | $\sigma$ | Min    | Max    |
|-----------:|-------:|---------:|-------:|-------:|
|      1 000 |  0.028 |    0.003 |  0.024 |  0.036 |
|     10 000 |  0.266 |    0.008 |  0.256 |  0.287 |
|    100 000 |  2.660 |    0.016 |  2.635 |  2.686 |
|  1 000 000 | 15.805 |    0.120 | 15.594 | 16.043 |

: Tempo (em segundos) de trocar preços de artigos pelo programa de manutenção
de artigos.

| Quantidade | Média  | $\sigma$ | Min    | Max    |
|-----------:|-------:|---------:|-------:|-------:|
|      1 000 |  0.033 |    0.002 |  0.030 |  0.037 |
|     10 000 |  0.316 |    0.004 |  0.308 |  0.325 |
|    100 000 |  3.142 |    0.014 |  3.121 |  3.167 |
|  1 000 000 | 31.985 |    0.151 | 31.729 | 32.341 |

: Tempo (em segundos) de trocar nomes de artigos pelo programa de manutenção
de artigos.

\newpage


## Agregador de Vendas

| Quantidade | Média  | $\sigma$ | Min    | Max    |
|-----------:|-------:|---------:|-------:|-------:|
|      1 000 |  0.004 |    0.001 |  0.003 |  0.008 |
|     10 000 |  0.033 |    0.002 |  0.030 |  0.038 |
|    100 000 |  0.272 |    0.004 |  0.268 |  0.284 |
|  1 000 000 |  2.287 |    0.024 |  2.257 |  2.372 |
| 10 000 000 | 22.330 |    0.191 | 22.092 | 22.899 |

: Tempo (em segundos) de agregar linhas de vendas pelo agregador de forma
sequencial.

| Quantidade | Média  | $\sigma$ | Min    | Max    |
|-----------:|-------:|---------:|-------:|-------:|
|      1 000 |  0.007 |    0.001 |  0.003 |  0.009 |
|     10 000 |  0.037 |    0.011 |  0.029 |  0.041 |
|    100 000 |  0.576 |    0.121 |  0.385 |  0.759 |
|  1 000 000 |  4.243 |    1.100 |  2.157 |  5.862 |
| 10 000 000 | 21.211 |    5.122 | 11.055 | 38.244 |

: Tempo (em segundos) de agregar linhas de vendas pelo agregador de forma
concorrente.

