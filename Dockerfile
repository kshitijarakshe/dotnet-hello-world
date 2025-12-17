# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy only csproj and restore dependencies
COPY hello-world-api/hello-world-api.csproj ./hello-world-api/
RUN dotnet restore hello-world-api/hello-world-api.csproj

# Copy the rest of the source code
COPY hello-world-api/. ./hello-world-api/

# Build and publish
RUN dotnet publish hello-world-api/hello-world-api.csproj -c Release -o /app/out

# Stage 2: Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app/out .

# Run the application
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
