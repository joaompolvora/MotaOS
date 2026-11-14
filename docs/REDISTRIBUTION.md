# Licenças e redistribuição

O MotaOS agrega componentes independentes. A licença MIT deste repositório se aplica somente ao código, documentação e arte originais. Não substitui GPL, LGPL, MPL, licenças de fontes ou outras licenças dos pacotes Debian. Debian e Firefox são marcas de seus respectivos titulares; este projeto não afirma ser uma distribuição oficial Debian.

Os arquivos `/usr/share/doc/<pacote>/copyright`, avisos e licenças dos pacotes permanecem na imagem. A integração do Calamares é instalada pelo pacote oficial, não copiada sem licença para este repositório. A build registra as versões de todos os pacotes para rastrear fontes correspondentes.

Antes de redistribuir uma ISO, arquive e disponibilize o código-fonte correspondente às versões binárias distribuídas, conforme as obrigações de cada licença (incluindo patches Debian e este repositório). Links para espelhos mutáveis não são garantia de disponibilidade futura. `deb-src` está habilitado para obter fontes via `apt source`, mas isso, sozinho, não produz um arquivo completo de fontes.

Para uma distribuição que inclua imagem de fontes, avalie a opção oficial `lb config --source true --source-images tar` antes de `lb build`, reserve espaço adicional e confira se todos os fontes correspondentes estão presentes. Esse modo não foi executado nesta entrega. Não publique uma ISO com componentes copyleft sem atender às respectivas condições de fornecimento de fontes. Nenhuma ISO foi produzida ou redistribuída nesta sessão.
