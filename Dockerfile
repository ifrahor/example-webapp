# שלב הבנייה: מכיל .NET 8 SDK יחד עם Node.js מותקן
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# התקנת Node.js 18 ו-npm עבור ה-Frontend של React
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# העתקת קבצי הפרויקט ובנייה
COPY . .
RUN dotnet restore "WebApiServer/WebApiServer.csproj"
RUN dotnet publish "WebApiServer/WebApiServer.csproj" -c Release -o /app/publish

# שלב ה-Runtime הסופי
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "WebApiServer.dll"]
