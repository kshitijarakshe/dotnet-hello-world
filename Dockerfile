# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy everything
COPY . ./

# Restore the solution
RUN dotnet restore dotnet-hello-world.sln

# Build the solution
RUN dotnet build dotnet-hello-world.sln -c Release -o /app/build

# Publish
RUN dotnet publish dotnet-hello-world.sln -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app

# Copy the published app
COPY --from=build /app/publish .

# Start the application
ENTRYPOINT ["dotnet", "dotnet-hello-world.dll"]
