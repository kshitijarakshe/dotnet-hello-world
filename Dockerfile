# =========================
# Build Stage
# =========================
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy csproj and restore dependencies
COPY hello-world-api/hello-world-api.csproj ./hello-world-api/
RUN dotnet restore hello-world-api/hello-world-api.csproj

# Copy the rest of the source code
COPY hello-world-api/. ./hello-world-api/

# Publish the application
RUN dotnet publish hello-world-api/hello-world-api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore


# =========================
# Runtime Stage
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/publish .

# Expose port used by the app
EXPOSE 80

# Run the application
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
