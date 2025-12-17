FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy project file first (for layer caching)
COPY *hello-world-api.csproj ./
RUN dotnet restore

# Copy remaining files
COPY . ./

# Build and publish
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "Net-application.dll"]
