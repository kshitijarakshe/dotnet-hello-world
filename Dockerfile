# Use official .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set working directory
WORKDIR /app

# Copy everything into the container
COPY . .

# Set working directory to the project folder
WORKDIR /app/hello-world-api

# Restore dependencies
RUN dotnet restore

# Build the project
RUN dotnet publish -c Release -o out

# Use a smaller runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/hello-world-api/out ./

# Expose port
EXPOSE 80

# Entry point
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
