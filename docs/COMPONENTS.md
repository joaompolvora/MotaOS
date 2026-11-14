# Componentes e fontes

Consulta realizada em 14/11/2026. Base fixada: **Debian 13, trixie, amd64**, repositórios oficiais `main`, `trixie-updates` e `trixie-security`.

As versões abaixo são referências consultadas, **não versões executadas numa ISO**. O arquivo [package-availability.tsv](package-availability.tsv) registra a consulta direta ao índice `trixie/main/binary-amd64/Packages.gz`, com 65 pacotes encontrados. Esse índice não inclui as atualizações de segurança separadas; elas podem prevalecer durante o build. APT verifica os metadados assinados durante a construção.

| Componente | Versão de referência | Papel |
|---|---|---|
| live-build | 1:20250505+deb13u1 | Construção da ISO |
| linux-image-amd64 | 6.12.107-1 | Metapacote de kernel |
| XFCE | 4.20.1 | Desktop |
| Firefox ESR | 140.15.0esr-1~deb13u1 no índice base | Navegador; segurança pode substituir |
| KolourPaint | 4:25.04.0-1 | Desenho |
| Calamares | 3.3.14-1 | Instalador |
| calamares-settings-debian | 13.0.13-1 | Integração oficial Debian |
| PipeWire | 1.4.2-1 | Áudio |
| NetworkManager | 1.52.1-1 | Rede |

O hook grava todas as versões instaladas em `/usr/share/motaos/package-versions.tsv`; o build copia esse registro e versões das ferramentas do host para `dist/`. Não há lock de versões binárias nem snapshot congelado: atualizações de segurança são deliberadamente permitidas.

Fontes oficiais consultadas:

- [Release trixie](https://www.debian.org/releases/trixie/)
- [Manual live-build: includes e hooks](https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-contents.en.html)
- [Opções de lb config](https://manpages.debian.org/trixie/live-build/lb_config.1.en.html)
- [Parâmetros do live-config](https://manpages.debian.org/trixie/live-config-doc/live-config.7.en.html)
- [live-build no Debian](https://packages.debian.org/trixie/live-build)
- [XFCE](https://packages.debian.org/trixie/xfce4), [KolourPaint](https://packages.debian.org/trixie/kolourpaint), [Firefox ESR](https://packages.debian.org/trixie/firefox-esr)
- [Calamares](https://packages.debian.org/trixie/calamares) e [configuração Debian](https://packages.debian.org/source/trixie/calamares-settings-debian)
- [Fonte oficial da configuração inspecionada](https://deb.debian.org/debian/pool/main/c/calamares-settings-debian/calamares-settings-debian_13.0.13.orig.tar.bz2)
- [Documentação QEMU](https://www.qemu.org/docs/master/system/)
- [Integrações VirtualBox](https://www.virtualbox.org/manual/ch04.html)

A integração conserva os módulos Debian de particionamento, unpackfs, criação de usuário, GRUB, initramfs e repositórios. Modifica branding, adiciona confirmação e uma etapa de limpeza dentro do target. A dependência de rede para pacotes de boot permanece documentada. Secure Boot, criptografia e instalação em hardware físico não foram validados.
