# Use .NET 6 SDK to build the app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy everything to /app
COPY . .

# Restore dependencies for the solution
RUN dotnet restore "dotnet-hello-world.sln"

# Build and publish the project
RUN dotnet publish "dotnet-hello-world.sln" -c Release -o /app/out

# Use .NET 6 runtime for the final image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/out .

# Expose port (adjust if your API uses another port)
EXPOSE 5000

# Run the application
ENTRYPOINT ["dotnet", "hello-world-api.dll"]
