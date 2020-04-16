# Introdução

No âmbito da Unidade Curricular *Laboratórios de Informática II* foi-nos
proposto a criação de um programa capaz de gerar tabuleiros para o jogo -
**GandaGalo** - desenvolvido durante esta mesma Unidade Curricular.

Os tabuleiros deste jogo podem conter três tipos de peças, tal como se pode
verificar na figura seguinte:

![Tipos de Peças](figures/figure0.pdf)

Os tabuleiros são matrizes que podem ou não ser quadradas. Estes estão
compreendidos entre 1 a 20 quadriculas (tanto linhas como colunas). O objetivo é
completar o tabuleiro, ou seja, preencher todas as quadriculas com uma *cruz* ou
com uma *bola*. No final, não podem existir mais de duas bolas nem duas cruzes
seguidas em qualquer uma das direções, horizontal, vertical e diagonal.


![Exemplos de casos inválidos](figures/invalidos.pdf)

Não existe qualquer restrição para as peças bloqueadas, ou seja, não existe
qualquer limitação de quantas podem estar seguidas. As bloqueadas interrompem as
sequências de cruzes ou bolas na sua intersecção. Contudo, não é permitido ao
jogador colocar uma peça bloqueada. Estas existem num tabuleiro ou não no início
e nenhuma outra pode ser acrescentada durante.

Estas devem ser colocadas estrategicamente em locais que nenhuma outra seria
possível.

![Tabuleiro impossível de resolver](figures/impossivel.pdf){ height=4.5cm }

Qualquer tabuleiro que tivesse uma configuração inicial do tipo representado na
Figura 3 seria de resolução impossível, uma vez que, quer se coloque uma bola na
casa laranja quer se coloque cruz passaria a estar num dos casos representados
na Figura 2. Um tabuleiro não é impossível de resolver se apresentar uma
situação de resolução impossível logo à partida mas sim, se a sua configuração
leve a uma serie de jogadas forçadas que resultam num caso impossível. No caso
em concreto, passaríamos a estar num caso válido se estivesse uma peça bloqueada
nesse lugar, tal como está representado na Figura 4.

![Correção possível para tabuleiro impossível](figures/fix-bloqueada.pdf){ height=4.5cm }

Contudo, um tabuleiro só é verdadeiramente válido se, para além de ser de
possível resolução, tiver uma e uma só possível solução. Este relatório descreve
como conseguimos criar um programa capaz de gerar tabuleiros com uma única
solução recebendo apenas a dimensão desejada e a dificuldade esperada.
