# Relatório de validação — 14/11/2026

**Resultado:** projeto preparado para build Linux; nenhuma ISO foi gerada. Não existe hash de ISO nesta entrega. Nenhum teste de boot, desktop ou instalação foi executado. A configuração não deve ser tratada como um sistema homologado.

## Ambiente e verificações executadas

- Repositório inicialmente vazio, apenas `.git`.
- Host Windows/PowerShell. `wsl --status` informou WSL não instalado. Docker, QEMU e VBoxManage não foram encontrados no PATH. Não foi instalado hipervisor nem alterada a configuração do host.
- O Bash do Git foi utilizado para `bash -n` nos scripts e hook: aprovado. Sua primeira execução no sandbox foi bloqueada pelo runtime MSYS; a execução autorizada fora desse isolamento funcionou.
- Entrada normal `bash scripts/build.sh`: executada no Git Bash, recusou o host com `Build requer Linux e sudo.` e código 1. Interrupção esperada antes do live-build, sem imagem gerada.
- `scripts/validate.py`: executado com Python 3.12 empacotado e PyYAML 6.0.3 isolado em `research/python`; aprovado para 31 arquivos. Verificou UTF-8 sem BOM/CRLF, XML/SVG, YAML local do Calamares, referências do painel e lista de pacotes.
- Índice oficial trixie amd64 consultado: os 65 pacotes desktop existem. Três pacotes do repositório binário do instalador também existem (`grub-pc`, `grub-efi`, `grub-efi-amd64`, versão consultada 2.12-9+deb13u2). O pacote antigo `policykit-1-gnome` foi detectado como ausente e substituído por `lxpolkit`.
- Fonte oficial `calamares-settings-debian_13.0.13.orig.tar.bz2` inspecionada: sequência, unpackfs, usuários, helpers de APT/GRUB e wrapper de execução. A sequência original é carregada do pacote durante o build; mudanças incompatíveis nos módulos essenciais interrompem o hook.
- ShellCheck não foi executado neste host. Está instalado pelo script de preparo e integra a verificação Linux antes de construir.

Essas verificações **não** demonstram que dependências serão resolvidas juntas, que a ISO inicializará ou que o Calamares instalará corretamente. Os próximos resultados devem ser registrados na matriz abaixo junto dos logs e imagens reais.

## Matriz de aceitação em VM

Todos os itens abaixo estão **PENDENTES — sem VM/ISO neste ambiente**.

| Teste | Procedimento e critério de aprovação |
|---|---|
| Construção | Executar preparo e build numa VM Debian trixie; saída zero, ISO não vazia, SHA-256 conferido e manifests preservados |
| Live BIOS | Iniciar `bios live`; atingir LightDM/sessão XFCE; capturar desktop |
| Live UEFI | Iniciar `uefi live`, Secure Boot desligado; atingir XFCE; confirmar `/sys/firmware/efi` |
| Mouse/teclado | Digitar `ação ç ~ @` em Mousepad, testar rolagem e arraste; minimizar, maximizar, alternar e fechar janelas |
| DHCP/NAT/DNS | `nmcli device status`, `ip address`, `ip route`, `getent hosts www.debian.org`; obter IP e gateway |
| HTTPS/download | Abrir site HTTPS no Firefox sem alerta; baixar arquivo, localizar em Downloads e reabrir |
| Desenho | No KolourPaint usar pincel, borracha, preenchimento e formas; salvar PNG e reabrir |
| Áudio | Reproduzir `speaker-test -c 2 -t wav`, alterar volume/mudo no painel; interromper com Ctrl+C |
| Microfone | Quando o host expuser entrada, conferir medidor de entrada no pavucontrol e gravar/reproduzir amostra |
| Personalização | Trocar wallpaper, tema e fonte; testar 1024×768 e 1920×1080, além de escala ampliada sem ocultar controles |
| SPICE | Conectar remote-viewer, redimensionar e copiar texto nos dois sentidos; nenhuma conexão externa exposta |
| Instalação BIOS | Disco virtual vazio, particionamento automático, conta nova com senha; Calamares conclui sem erros |
| Instalação UEFI | Repetir em disco separado UEFI; verificar ESP e entrada de boot |
| Boot instalado | Desligar e executar modo `installed`, sem CD; login com a conta criada e desktop acessível |
| Privilégios | Conta não-root; `sudo -k; sudo -v` pede senha escolhida; conta live e sudo sem senha não permanecem |
| Persistência | Criar `~/persistencia.txt`, salvar desenho e mudar wallpaper; reiniciar pelo disco e verificar os três |
| Atualizações | `sudo apt update`, conferir somente fontes trixie oficiais e instalar pacote pequeno |
| Encerramento | Encerrar sessão, reiniciar e desligar pelo painel; processo QEMU termina no desligamento |

Colete diagnóstico dentro do guest com `bash scripts/collect-guest-evidence.sh` (transfira o script para a VM). Ele salva rede, DNS/HTTPS, áudio, resoluções e journal em `~/motaos-evidence-<UTC>/`. Para screenshots reais, use o Capturador de tela XFCE. Preserve também logs do Calamares antes de desligar a live, pois são voláteis. Os logs serial/QEMU do host podem não conter saída gráfica do guest.

## Limitações conhecidas

- Build requer Linux root com mounts/chroot; nenhuma infraestrutura Linux utilizável está disponível nesta sessão Windows.
- Instalação online é o caminho documentado; cache na mídia não foi testado para operação offline.
- Guest Additions VirtualBox não incluídas; prioridade QEMU/SPICE. Sem testes de clipboard, aceleração, microfone ou alta escala.
- Firmware proprietário, hardware físico, Secure Boot, criptografia e instalação junto de outro sistema não foram validados.
- Branding GTK cobre a aparência XFCE; aplicativos Qt podem apresentar diferenças. O papel de parede foi validado como SVG, sem inspeção num desktop real.
- Pacotes seguem atualizações oficiais; a consulta de disponibilidade não constitui lock de build. Os manifests finais só existirão após uma build concluída.
- Arquivo completo de fontes para redistribuição de uma futura ISO ainda deve ser produzido e conferido, conforme `REDISTRIBUTION.md`.
