#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
USER sa
WORKDIR /app2

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src2
COPY ["WorkerService/WorkerService.csproj", "WorkerService/"]
RUN dotnet restore "./WorkerService/./WorkerService.csproj"
COPY . .
WORKDIR "/src2/WorkerService"
RUN dotnet build "./WorkerService.csproj" -c $BUILD_CONFIGURATION -o /app2/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./WorkerService.csproj" -c $BUILD_CONFIGURATION -o /app2/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app2
COPY --from=publish /app2/publish .
ENTRYPOINT ["dotnet", "WorkerService.dll"]