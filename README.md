# MotaOS 0.1

Distribuição desktop experimental para máquinas virtuais x86_64, baseada em **Debian 13 (trixie)**, com XFCE, Firefox ESR, KolourPaint e instalador Calamares. Interface pt-BR, teclado ABNT2 e fuso America/Sao_Paulo. Papel de parede original, tema escuro, destaque roxo e JetBrains Mono no terminal.

**Estado desta entrega:** configuração e scripts implementados, verificação estática executada. **Não há ISO produzida nem boot/instalação comprovados.** O ambiente de desenvolvimento é Windows sem WSL instalado ou hipervisor disponível no PATH. Consulte [o relatório](docs/VALIDATION.md).

## Preparar uma VM de build

1. Baixe a imagem de instalação amd64 no [site oficial do Debian](https://www.debian.org/distrib/). Confira assinatura e checksum conforme as instruções do Debian.
2. Crie uma VM dedicada Debian 13: 4 vCPUs, 8 GiB RAM, disco virtual de 80 GiB, rede NAT. Instale Debian com XFCE e utilitários padrão. Secure Boot pode ficar desativado. Não conecte discos físicos à VM.
3. Transfira este repositório para `~/MotaOS` **no filesystem Linux**, não numa pasta compartilhada NTFS/9p. Pode copiar um ZIP e extrair ou usar Git. A build precisa de semântica Unix, mounts e chroot.
4. Na VM, abra um terminal:

```bash
cd ~/MotaOS
# Se o usuário ainda não tem sudo, use su - e adicione-o ao grupo sudo.
sudo bash scripts/prepare-host.sh
bash scripts/check.sh
sudo bash scripts/build.sh
```

O preparo instala dependências somente na VM dedicada. O build exige root para debootstrap/chroot/mount, ao menos 30 GiB livres (recomendados 50 GiB), acesso HTTPS aos espelhos Debian e espaço adicional para discos de teste. Tempo e tamanho final dependem da rede e dos pacotes. Contêiner comum sem capacidades de mount não é um host adequado. KVM acelera os testes, mas não é necessário para gerar a ISO. Em virtualização aninhada indisponível, QEMU usa TCG, mais lento.

Saídas esperadas **após build bem-sucedido**:

```text
dist/motaos-0.1-trixie-amd64.hybrid.iso
dist/SHA256SUMS
dist/package-versions.tsv
dist/host-versions.tsv
dist/boot-catalog.txt
dist/installer-config/
logs/build-<UTC>.log
```

```bash
cd dist
sha256sum --check SHA256SUMS
```

O script verifica entradas BIOS e UEFI no catálogo El Torito. Isso comprova a estrutura declarada da mídia, **não** que o desktop inicializa. Trixie está fixado pelo codinome; versões individuais recebem atualizações oficiais. O processo é reconstruível, mas não promete reprodução byte a byte. Os manifests registram as versões reais de cada build; consulte [componentes](docs/COMPONENTS.md).

## Testar com QEMU

Execute como usuário comum no host Linux com sessão gráfica:

```bash
bash scripts/run-vm.sh bios live
# Após desligar a VM anterior:
bash scripts/run-vm.sh uefi live
```

Cada firmware recebe um disco QCOW2 independente de 40 GiB em `vms/`. A VM usa 4 GiB RAM, duas CPUs, rede NAT/DHCP, vídeo VirtIO, tablet USB e áudio HDA. O script não aceita discos físicos. A porta SPICE está restrita a localhost; rode uma VM por vez.

Para integração de área de transferência e redimensionamento, abra em outro terminal:

```bash
remote-viewer spice://127.0.0.1:5930
```

O agente SPICE está incluído. A janela GTK básica também permite interação, mas a integração deve ser testada com o cliente SPICE. O áudio usa o servidor PulseAudio ou compatível do host (inclusive PipeWire). Para host sem áudio, use `MOTA_AUDIO_BACKEND=none bash scripts/run-vm.sh bios live`; nesse caso o teste de som permanece pendente. Microfone depende das permissões e da entrada disponibilizada pelo host. O agente QEMU está incluído, mas um canal guest-agent adicional é necessário para ferramentas do host que o utilizem.

## Sessão live e instalação

Na sessão live, usuário **`mota`**, senha padrão do live-config **`live`**, login automático e `sudo` sem senha. Esses privilégios são exclusivos do ambiente de avaliação. Não há servidor SSH habilitado. **Arquivos, downloads, aplicativos instalados e preferências da sessão live são temporários e se perdem ao reiniciar.** Esta versão não configura persistência live.

1. Verifique internet no Firefox. **Mantenha acesso à internet durante a instalação**: os helpers Debian podem buscar pacotes GRUB adicionais. Instalação offline não é garantida nesta versão.
2. Abra **Instalar MotaOS** no menu de aplicativos. O instalador ainda pode apresentar referências e links ao Debian, sua base.
3. Confira idioma, localidade e teclado. Selecione somente o disco virtual vazio de 40 GiB. Para a primeira validação, use particionamento automático sem criptografia.
4. Crie o usuário diário e sua senha. Não use `mota` no primeiro teste, para distinguir a conta instalada da sessão live. Prefira login com senha. Confirme o resumo antes da instalação.
5. Ao terminar, desligue a VM. Inicie novamente **sem a ISO**, usando o mesmo firmware:

```bash
bash scripts/run-vm.sh bios installed
# Ou, se instalou em UEFI:
bash scripts/run-vm.sh uefi installed
```

O modo `installed` não conecta o CD-ROM. A NVRAM UEFI é preservada em `vms/uefi/vars.fd`. Verifique login, `sudo`, boot e persistência seguindo o relatório. A configuração pretende remover permissões live e o atalho do instalador; essa transição ainda exige validação real.

## VirtualBox

Configuração inicial recomendada: tipo Linux / Debian 64-bit, 2 CPUs, 4 GiB RAM, disco VDI dinâmico de 40 GiB, NAT com cabo conectado, vídeo VMSVGA com 128 MiB, aceleração 3D inicialmente desativada, controlador de áudio Intel HD Audio e tablet USB. Teste BIOS e EFI em VMs separadas; desative Secure Boot. Monte a ISO no drive óptico e remova-a após instalar.

Os drivers de vídeo/kernel disponíveis no Debian podem fornecer integração básica. **Guest Additions do VirtualBox não estão incluídas nesta imagem `main`**; clipboard compartilhado e redimensionamento automático não são garantidos. Se necessários, instale as Guest Additions correspondentes à versão do host, seguindo o [manual oficial](https://www.virtualbox.org/manual/ch04.html), após instalar o MotaOS. Essa instalação adicional tem licença e ciclo de atualização próprios. QEMU/SPICE é o caminho prioritário desta versão.

## Uso diário e personalização

- Menu MotaOS: Firefox, KolourPaint, Thunar, Terminal, Mousepad, Galculator, Ristretto e Configurações.
- Alt+Tab alterna janelas; Alt+F4 fecha; Alt+F2 abre o lançador. Botões da janela minimizam, maximizam e fecham. Menu e painel oferecem encerramento de sessão, reinício e desligamento.
- Clique direito no desktop → Configurações da área de trabalho para o papel de parede. Aparência e Gerenciador de janelas ajustam tema, ícones, fontes e escala; Monitor ajusta resolução.
- Rede pelo ícone do NetworkManager; volume e dispositivos de entrada/saída pelo controle de áudio e `pavucontrol`.
- Teclado nas Configurações. Idioma por `sudo dpkg-reconfigure locales`; fuso por `sudo dpkg-reconfigure tzdata`. As escolhas do instalador substituem os padrões iniciais.
- O papel de parede inicial é aplicado uma vez por usuário, sem sobrescrever alterações posteriores. No sistema instalado, home e preferências permanecem no disco.
- Atualize pelo Synaptic ou `sudo apt update && sudo apt full-upgrade`. Elevação administrativa usa a senha escolhida na instalação. Não use root como conta diária.

## Limpeza e solução de problemas

```bash
sudo bash scripts/clean.sh
sudo bash scripts/build.sh
```

A limpeza usa `lb clean --purge`, verifica mounts e remove apenas `build/` identificado pelo projeto. Preserva ISO, logs e discos virtuais. Não remova arquivos de VM enquanto o QEMU estiver ativo.

- **Build falhou:** confira `logs/`; rede, DNS, espaço em disco e privilégios de mount são as primeiras verificações. Limpe antes de repetir; não execute duas builds simultâneas.
- **Pacote ausente ou instalador mudou:** o build deve falhar; revise os manifests e o contrato validado no hook. Não troque automaticamente para testing/unstable.
- **Sem aceleração:** confira `/dev/kvm` e grupo `kvm`; reconecte a sessão após ajustar grupos. Em VM de build, habilite virtualização aninhada no host ou aceite TCG.
- **Tela pequena:** use Configurações → Monitor ou SPICE. Se houver artefatos, desative composição no gerenciador de janelas e 3D no hipervisor.
- **Sem rede:** confirme NAT/cabo conectado, `nmcli device status`, `ip route` e `getent hosts deb.debian.org`.
- **Sem som:** confira volume no host e guest, `wpctl status` e perfil HDA em `pavucontrol`.
- **GRUB falhou:** preserve os logs do Calamares, confira internet e modo BIOS/UEFI. Não declare a instalação concluída até iniciar pelo disco sem CD.

## Organização e licenças

`auto/config` define a imagem; `config/package-lists` lista pacotes; `config/includes.chroot` contém identidade e configurações; `config/hooks/live` integra a instalação; `scripts` prepara, constrói, verifica e inicia VMs. O perfil usa apenas a seção oficial `main`, adequado aos dispositivos virtuais escolhidos; suporte a hardware físico com firmware proprietário está fora desta primeira versão.

Código e arte originais: [licença MIT](LICENSE). Pacotes Debian mantêm suas próprias licenças e avisos em `/usr/share/doc/*/copyright`. Consulte [redistribuição](docs/REDISTRIBUTION.md) antes de publicar uma ISO.
