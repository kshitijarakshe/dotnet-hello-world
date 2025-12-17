# Use .NET 6 SDK for build
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set working directory
WORKDIR /app

# Copy everything from repo to container
COPY . .

# Restore dependencies (runs in the directory with .csproj)
RUN dotnet restore

# Build the project in Release mode
RUN dotnet build -c Release -o out

# Publish the app
RUN dotnet publish -c Release -o out/publish

# Use .NET 6 ASP.NET runtime for final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/out/publish .

# Expose port 80
EXPOSE 80

# Start the application
ENTRYPOINT ["dotnet", "Net-application.dll"]
