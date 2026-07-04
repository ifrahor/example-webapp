# 1. Build the React frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY clientapp/package*.json ./clientapp/
RUN cd clientapp && npm install
COPY clientapp/ ./clientapp/
RUN cd clientapp && npm run build

# 2. Build the .NET Backend
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS backend-build
WORKDIR /src
COPY WebApiServer/*.csproj ./WebApiServer/
RUN dotnet restore "./WebApiServer/WebApiServer.csproj"
COPY WebApiServer/ ./WebApiServer/
RUN dotnet publish "./WebApiServer/WebApiServer.csproj" -c Release -o /app/publish

# 3. Final Runtime Image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
COPY --from=backend-build /app/publish .
COPY --from=frontend-build /app/clientapp/build ./wwwroot
EXPOSE 80
ENTRYPOINT ["dotnet", "WebApiServer.dll"]
