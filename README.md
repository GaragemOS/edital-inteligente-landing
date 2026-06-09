# Edital Inteligente — Landing Page

Página de marketing institucional do **Edital Inteligente**, produto da Garagem para
captação de recursos via editais de fomento. A plataforma constrói o dossiê da
organização, analisa cada chamada e entrega veredito acionável, pipeline integrado,
agenda e relatórios de performance.

Este repositório contém **apenas a landing page** (site estático de divulgação). O
produto em si — a aplicação de análise de editais — vive em repositório e serviço
separados.

## Características

- **Site de arquivo único:** todo o conteúdo (marcação, design system em CSS inline e um
  único script trivial que preenche o ano no rodapé) está em `index.html`.
- **Sem framework e sem etapa de build:** não há bundler, `package.json` ou
  `node_modules`. A única dependência externa em runtime é o Google Fonts
  (Orbitron + Funnel Display).
- **Design system** centralizado em CSS custom properties sob `:root` (cores, gradiente,
  bordas e sombra). Alterações de marca devem ser feitas nas variáveis, não nos pontos de
  uso.
- **Copy em PT-BR**, com tom formal/institucional (produto B2B/B2G).

## Estrutura

| Arquivo / diretório            | Função                                                                 |
| ------------------------------ | ---------------------------------------------------------------------- |
| `index.html`                   | Site completo: marcação, design system (CSS inline) e script de rodapé |
| `brand/`                       | Logos em SVG (variantes símbolo/horizontal nas cores gradiente/branco/preto) |
| `Dockerfile`                   | Imagem `nginx:alpine` que serve o site; expõe a porta `8080`           |
| `docker-entrypoint.sh`         | Substitui `${PORT}` no template do nginx via `envsubst` na inicialização |
| `nginx/default.conf.template`  | Server block: fallback SPA, headers de segurança, gzip, cache e `/healthz` |
| `nginx/nginx.conf`             | Configuração base de http/events                                       |
| `railway.toml`                 | Configuração de deploy na Railway (builder Dockerfile, healthcheck)    |

### Seções da página

As seções são delimitadas no corpo do `index.html` por comentários `<!-- ===== NOME ===== -->`
e ancoradas por `id`, na ordem: hero, estatísticas, como funciona, semáforo (veredito),
barema/eixos, pipeline + agenda, documentação centralizada, relatórios quinzenais,
features e CTA final. O header fixo navega por essas âncoras.

## Desenvolvimento local

```bash
# Pré-visualização rápida — abre o arquivo diretamente (o Google Fonts carrega pela rede)
start index.html
```

Para testar exatamente como em produção (nginx + `envsubst`), servindo em
`http://localhost:8080`:

```bash
docker build -t edital-landing .
docker run --rm -p 8080:8080 edital-landing
```

Não há testes, linters ou scripts de build neste repositório.

## Deploy

O site é servido por **nginx em Docker** e implantado na **Railway** (builder =
`DOCKERFILE`). Fluxo:

1. O `Dockerfile` (`nginx:alpine`) copia `index.html` e `brand/` para o web root e instala
   `gettext` para o `envsubst`.
2. Na inicialização, o `docker-entrypoint.sh` executa `envsubst` para injetar `${PORT}`
   (padrão `8080`, definido pela Railway) em `nginx/default.conf.template`, gerando o
   `default.conf` ativo. Esse é o único motivo de a porta ser dinâmica — o nginx não lê
   variáveis de ambiente nativamente.
3. O healthcheck da Railway aponta para `/` (ver `railway.toml`), embora a rota
   `/healthz` (que retorna `ok`) também exista no nginx.

## Convenções

- Toda a copy é **PT-BR**, com tom formal/institucional consistente entre as seções.
- **Sem comentários no código de view/CSS.** Os comentários de banner de seção
  (`<!-- ===== NOME ===== -->`) são a única exceção intencional, como auxílio de
  navegação. Para clareza, prefira refatorar ou renomear.
- O `.dockerignore` remove `*.md`, arquivos de ambiente e diretórios de editor da imagem —
  documentação como este README não é enviada para produção.
