# ----------------------------------------------------
# Stage 1: Build Frontend (React)
# ----------------------------------------------------
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY clientapp/package*.json ./
RUN npm install
COPY clientapp/ ./
RUN npm run build && \
    if [ -d "dist" ]; then cp -r dist build; fi

# ----------------------------------------------------
# Stage 2: Build Backend (.NET)
# ----------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS backend-build
WORKDIR /src
COPY . .
RUN dotnet publish WebApiServer/WebApiServer.csproj -c Release -o /app/publish /p:PublishTrimmed=false

# ----------------------------------------------------
# Stage 3: Final Runtime
# ----------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /app
COPY --from=backend-build /app/publish .
COPY --from=frontend-build /app/build ./wwwroot
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "WebApiServer.dll"]
