# 1. Build the React frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/clientapp
COPY clientapp/package*.json ./
RUN npm install
COPY clientapp/ ./
RUN npm run build && \
    if [ -d "dist" ]; then cp -r dist build; fi

# 2. Build the .NET Backend
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS backend-build
WORKDIR /src/WebApiServer
COPY WebApiServer/*.csproj ./
RUN dotnet restore
COPY WebApiServer/ ./
RUN dotnet publish -c Release -o /app/publish

# 3. Final Runtime Image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
COPY --from=backend-build /app/publish .
COPY --from=frontend-build /app/clientapp/build ./wwwroot
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApiServer.dll"]
