FROM node:20-alpine

WORKDIR /app

# Copiar os arquivos do repositório para o container
COPY . .

# Instalar dependências
RUN npm install

# Gerar a pasta dist (depois de npm install, execute o build)
RUN npm run build

# Agora o diretório dist/app deve estar disponível para o Nginx
FROM nginx:stable-alpine

# Copiar o diretório gerado no build para o Nginx
COPY --from=0 /app/dist/app /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
