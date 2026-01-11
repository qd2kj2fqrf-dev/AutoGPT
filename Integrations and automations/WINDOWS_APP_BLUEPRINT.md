# WINDOWS APPLICATION (.NET 8 + WinUI 3)
## Integrations & Automations Studio - Desktop Client

---

## 🏗️ PROJECT STRUCTURE

```
IntegrationsStudio.Windows/
│
├── Views/
│   ├── MainWindow.xaml              # Root window with navigation
│   ├── MainWindow.xaml.cs
│   ├── Pages/
│   │   ├── LoginPage.xaml
│   │   ├── DashboardPage.xaml       # Main hub (flows, integrations)
│   │   ├── FlowsPage.xaml           # List of flows
│   │   ├── FlowDetailsPage.xaml     # Single flow editor
│   │   ├── IntegrationsPage.xaml    # Integration management
│   │   ├── WorkbenchesPage.xaml     # Workspace selection
│   │   ├── SettingsPage.xaml        # User preferences
│   │   └── Components/
│   │       ├── FlowNodeCard.xaml    # Node rendering
│   │       ├── IntegrationCard.xaml
│   │       ├── MetricsPanel.xaml
│   │       └── ExecutionLogView.xaml
│   │
├── ViewModels/
│   ├── ViewModelBase.cs             # Base class with INotifyPropertyChanged
│   ├── MainViewModel.cs
│   ├── DashboardViewModel.cs
│   ├── FlowsViewModel.cs
│   ├── FlowDetailsViewModel.cs
│   ├── IntegrationViewModel.cs
│   ├── WorkbenchViewModel.cs
│   ├── SettingsViewModel.cs
│   └── RelayCommand.cs              # Command implementation
│   
├── Services/
│   ├── ApiService.cs                # HTTP client wrapper
│   ├── AuthService.cs               # Login/token management
│   ├── FlowService.cs               # Flow CRUD operations
│   ├── IntegrationService.cs        # Integration management
│   ├── StorageService.cs            # Local SQLite cache
│   ├── WebSocketService.cs          # Real-time updates
│   ├── NotificationService.cs       # Toast notifications
│   └── ThemeService.cs              # Theme management
│   
├── Models/
│   ├── Dto/
│   │   ├── UserDto.cs
│   │   ├── FlowDto.cs
│   │   ├── NodeDto.cs
│   │   ├── IntegrationDto.cs
│   │   └── ExecutionLogDto.cs
│   │
│   ├── Domain/
│   │   ├── User.cs
│   │   ├── Flow.cs
│   │   ├── Node.cs
│   │   ├── Integration.cs
│   │   └── ExecutionLog.cs
│
├── Converters/
│   ├── BoolToVisibilityConverter.cs
│   ├── EnumToStringConverter.cs
│   └── DateTimeConverter.cs
│
├── Behaviors/
│   ├── FocusBehavior.cs             # Auto-focus on page load
│   └── ValidationBehavior.cs        # Form validation
│
├── Resources/
│   ├── Strings/
│   │   └── en-US.resw               # Localization strings
│   │
│   ├── Styles/
│   │   ├── Colors.xaml
│   │   ├── Typography.xaml
│   │   └── CommonStyles.xaml
│   │
│   └── Icons/
│       ├── ic_flow.svg
│       ├── ic_integration.svg
│       └── ic_settings.svg
│
├── Database/
│   ├── AppDatabase.cs               # SQLite context
│   └── Migrations/
│       └── 001_InitialSchema.sql
│
├── App.xaml
├── App.xaml.cs
├── App.config                       # Configuration
├── IntegrationsStudio.Windows.csproj
└── README.md
```

---

## 📝 CSPROJ FILE

```xml
<!-- IntegrationsStudio.Windows.csproj -->
<Project Sdk="Microsoft.NET.Sdk.WindowsDesktop">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows10.0.20348.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <UseWPF>false</UseWPF>
    <UseWindowsUI>true</UseWindowsUI>
    <AssemblyName>IntegrationsStudio</AssemblyName>
    <RootNamespace>IntegrationsStudio.Windows</RootNamespace>
    <Version>1.0.0</Version>
    <Authors>Your Company</Authors>
  </PropertyGroup>

  <ItemGroup>
    <!-- WinUI 3 -->
    <PackageReference Include="Microsoft.WindowsAppSDK" Version="1.6.0" />
    <PackageReference Include="Microsoft.Windows.SDK.BuildTools" Version="10.0.22621.756" />
    
    <!-- HTTP & Networking -->
    <PackageReference Include="HttpClientInterceptor" Version="6.1.0" />
    <PackageReference Include="Refit" Version="7.1.4" />
    
    <!-- Data & Storage -->
    <PackageReference Include="SQLite" Version="3.13.0" />
    <PackageReference Include="Entity Framework Core" Version="8.0.0" />
    
    <!-- Dependency Injection -->
    <PackageReference Include="Microsoft.Extensions.DependencyInjection" Version="8.0.0" />
    <PackageReference Include="Microsoft.Extensions.Configuration" Version="8.0.0" />
    
    <!-- JSON -->
    <PackageReference Include="System.Text.Json" Version="8.0.0" />
    
    <!-- Real-time -->
    <PackageReference Include="WebSocketSharp" Version="1.0.3-rc11" />
    
    <!-- Logging -->
    <PackageReference Include="Serilog" Version="4.0.0" />
    <PackageReference Include="Serilog.Sinks.File" Version="5.0.0" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\IntegrationsStudio.Shared\IntegrationsStudio.Shared.csproj" />
  </ItemGroup>
</Project>
```

---

## 🔧 CORE IMPLEMENTATION

### 1. Main Window (MVVM)

```xaml
<!-- Views/MainWindow.xaml -->
<?xml version="1.0" encoding="utf-8"?>
<Window
    x:Class="IntegrationsStudio.Windows.Views.MainWindow"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Integrations & Automations Studio"
    Width="1400"
    Height="900"
    Background="{ThemeResource ApplicationPageBackgroundThemeBrush}"
    mc:Ignorable="d"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">

    <Grid RowDefinitions="50,*">
        <!-- Top Navigation Bar -->
        <Grid Grid.Row="0" Background="#1a1a1a" Padding="16,0">
            <Grid ColumnDefinitions="*,Auto">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock 
                        Text="🚀 Integrations Studio"
                        FontSize="16"
                        FontWeight="Bold"
                        Foreground="#e0e0e0"
                        Margin="0,0,32,0"/>
                </StackPanel>
                
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Spacing="16">
                    <Button Content="Settings" />
                    <Button Content="Help" />
                    <PersonPicture Width="40" Height="40"/>
                </StackPanel>
            </Grid>
        </Grid>

        <!-- Main Content -->
        <Grid Grid.Row="1" ColumnDefinitions="280,*">
            <!-- Sidebar Navigation -->
            <StackPanel Grid.Column="0" Background="#0f0f0f" Padding="0,16">
                <NavigationView 
                    PaneDisplayMode="Top"
                    IsSettingsVisible="True"
                    SelectionChanged="OnNavigationChanged">
                    <NavigationViewItem 
                        Icon="Home" 
                        Content="Dashboard"
                        Tag="Dashboard"/>
                    <NavigationViewItem 
                        Icon="Library" 
                        Content="Flows"
                        Tag="Flows"/>
                    <NavigationViewItem 
                        Icon="PlugConnected" 
                        Content="Integrations"
                        Tag="Integrations"/>
                    <NavigationViewItem 
                        Icon="Tiles" 
                        Content="Workbenches"
                        Tag="Workbenches"/>
                    
                    <NavigationViewItemSeparator/>
                    
                    <NavigationViewItem 
                        Icon="Setting" 
                        Content="Settings"
                        Tag="Settings"/>
                </NavigationView>
            </StackPanel>

            <!-- Main Content Area -->
            <Frame Grid.Column="1" x:Name="ContentFrame"/>
        </Grid>
    </Grid>
</Window>
```

```csharp
// Views/MainWindow.xaml.cs
using Microsoft.UI.Xaml;
using IntegrationsStudio.Windows.ViewModels;

namespace IntegrationsStudio.Windows.Views
{
    public sealed partial class MainWindow : Window
    {
        public MainViewModel ViewModel { get; }

        public MainWindow()
        {
            this.InitializeComponent();
            ViewModel = new MainViewModel();
            this.DataContext = ViewModel;
        }

        private void OnNavigationChanged(NavigationView sender, NavigationViewSelectionChangedEventArgs args)
        {
            if (args.SelectedItem is NavigationViewItem item)
            {
                string tag = item.Tag.ToString();
                ContentFrame.Navigate(Type.GetType($"IntegrationsStudio.Windows.Views.Pages.{tag}Page"));
            }
        }
    }
}
```

### 2. API Service

```csharp
// Services/ApiService.cs
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Refit;

namespace IntegrationsStudio.Windows.Services
{
    [Headers("Content-Type: application/json")]
    public interface IApiClient
    {
        [Post("/api/v1/auth/login")]
        Task<AuthResponse> LoginAsync([Body] LoginRequest request);

        [Get("/api/v1/flows")]
        Task<List<FlowDto>> GetFlowsAsync();

        [Get("/api/v1/flows/{id}")]
        Task<FlowDto> GetFlowAsync(string id);

        [Post("/api/v1/flows")]
        Task<FlowDto> CreateFlowAsync([Body] CreateFlowRequest request);

        [Put("/api/v1/flows/{id}")]
        Task<FlowDto> UpdateFlowAsync(string id, [Body] UpdateFlowRequest request);

        [Delete("/api/v1/flows/{id}")]
        Task DeleteFlowAsync(string id);

        [Post("/api/v1/flows/{id}/execute")]
        Task<ExecutionResponse> ExecuteFlowAsync(string id);

        [Get("/api/v1/integrations")]
        Task<List<IntegrationDto>> GetIntegrationsAsync();

        [Get("/api/v1/logs")]
        Task<List<ExecutionLogDto>> GetLogsAsync([Query] int skip = 0, [Query] int take = 50);
    }

    public class ApiService
    {
        private readonly IApiClient _client;
        private readonly IAuthService _authService;
        private string _baseUrl = "http://localhost:3000";

        public ApiService(IAuthService authService)
        {
            _authService = authService;
            _client = RestService.For<IApiClient>(_baseUrl, new HttpClientHandler());
        }

        public async Task<AuthResponse> LoginAsync(string email, string password)
        {
            return await _client.LoginAsync(new LoginRequest { Email = email, Password = password });
        }

        public async Task<List<FlowDto>> GetFlowsAsync()
        {
            return await _client.GetFlowsAsync();
        }

        // Additional methods...
    }

    // DTOs
    public record LoginRequest(string Email, string Password);
    public record AuthResponse(string AccessToken, string RefreshToken, UserDto User);
    public record UserDto(string Id, string Email, string Name, string Theme);
    public record FlowDto(string Id, string Name, string Intention, List<NodeDto> Nodes);
    public record NodeDto(string Id, string Title, string Kind);
    public record IntegrationDto(string Id, string Name, string Type, bool IsConnected);
    public record ExecutionLogDto(string Id, string FlowId, string Status, DateTime CreatedAt);
    public record ExecutionResponse(string LogId, string Status);
    public record CreateFlowRequest(string Name, string Intention);
    public record UpdateFlowRequest(string Name, string Intention, List<NodeDto> Nodes);
}
```

### 3. Authentication Service

```csharp
// Services/AuthService.cs
using Windows.Security.Credentials;

namespace IntegrationsStudio.Windows.Services
{
    public interface IAuthService
    {
        Task<bool> LoginAsync(string email, string password);
        Task<bool> LogoutAsync();
        string GetAccessToken();
        bool IsAuthenticated { get; }
    }

    public class AuthService : IAuthService
    {
        private const string CredentialResource = "IntegrationsStudio";
        private const string AccessTokenKey = "access_token";
        private const string RefreshTokenKey = "refresh_token";

        private readonly PasswordVault _vault = new();
        private string _accessToken;

        public bool IsAuthenticated => !string.IsNullOrEmpty(_accessToken);

        public async Task<bool> LoginAsync(string email, string password)
        {
            try
            {
                // API call handled by ApiService
                // Store tokens securely
                _vault.Add(new PasswordCredential(CredentialResource, AccessTokenKey, _accessToken));
                _vault.Add(new PasswordCredential(CredentialResource, RefreshTokenKey, _refreshToken));
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> LogoutAsync()
        {
            try
            {
                _vault.Remove(new PasswordCredential(CredentialResource, AccessTokenKey, ""));
                _vault.Remove(new PasswordCredential(CredentialResource, RefreshTokenKey, ""));
                _accessToken = null;
                return true;
            }
            catch
            {
                return false;
            }
        }

        public string GetAccessToken()
        {
            if (!string.IsNullOrEmpty(_accessToken)) return _accessToken;

            try
            {
                var cred = _vault.Retrieve(CredentialResource, AccessTokenKey);
                _accessToken = cred.Password;
                return _accessToken;
            }
            catch
            {
                return null;
            }
        }
    }
}
```

### 4. ViewModel Base

```csharp
// ViewModels/ViewModelBase.cs
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace IntegrationsStudio.Windows.ViewModels
{
    public abstract class ViewModelBase : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        protected bool SetProperty<T>(ref T storage, T value, [CallerMemberName] string propertyName = null)
        {
            if (Equals(storage, value)) return false;
            storage = value;
            OnPropertyChanged(propertyName);
            return true;
        }
    }
}
```

### 5. Dashboard ViewModel

```csharp
// ViewModels/DashboardViewModel.cs
using System.Collections.ObjectModel;
using IntegrationsStudio.Windows.Services;
using IntegrationsStudio.Windows.Models;

namespace IntegrationsStudio.Windows.ViewModels
{
    public class DashboardViewModel : ViewModelBase
    {
        private readonly ApiService _apiService;
        private ObservableCollection<FlowDto> _recentFlows;
        private ObservableCollection<IntegrationDto> _integrations;
        private bool _isLoading;

        public ObservableCollection<FlowDto> RecentFlows
        {
            get => _recentFlows;
            set => SetProperty(ref _recentFlows, value);
        }

        public ObservableCollection<IntegrationDto> Integrations
        {
            get => _integrations;
            set => SetProperty(ref _integrations, value);
        }

        public bool IsLoading
        {
            get => _isLoading;
            set => SetProperty(ref _isLoading, value);
        }

        public RelayCommand LoadDataCommand { get; }

        public DashboardViewModel(ApiService apiService)
        {
            _apiService = apiService;
            LoadDataCommand = new RelayCommand(async () => await LoadDataAsync());
            LoadDataCommand.Execute(null);
        }

        private async Task LoadDataAsync()
        {
            IsLoading = true;
            try
            {
                var flows = await _apiService.GetFlowsAsync();
                var integrations = await _apiService.GetIntegrationsAsync();

                RecentFlows = new ObservableCollection<FlowDto>(flows.OrderByDescending(f => f.UpdatedAt).Take(5));
                Integrations = new ObservableCollection<IntegrationDto>(integrations.Where(i => i.IsConnected));
            }
            finally
            {
                IsLoading = false;
            }
        }
    }
}
```

---

## 🏃 RUNNING THE WINDOWS APP

```bash
# Create new WinUI 3 project
dotnet new winui

# Restore dependencies
dotnet restore

# Build
dotnet build

# Run
dotnet run

# Build release
dotnet build -c Release

# Create MSIX installer
dotnet publish -c Release -f net8.0-windows10.0.22621.0
```

---

## 🎨 STYLING GUIDELINES

### Color Palette (matching Phase 1 design)

```xaml
<!-- Resources/Colors.xaml -->
<ResourceDictionary>
    <!-- Copper Tide Theme -->
    <Color x:Key="CopperPrimary">#D4835C</Color>
    <Color x:Key="CopperSecondary">#A0654D</Color>
    <Color x:Key="CopperBackground">#1a1a1a</Color>
    
    <!-- Mint Voltage Theme -->
    <Color x:Key="MintPrimary">#00D9AA</Color>
    <Color x:Key="MintSecondary">#00A87F</Color>
    <Color x:Key="MintBackground">#0f1a19</Color>
    
    <!-- Solar Drift Theme -->
    <Color x:Key="SolarPrimary">#FFB800</Color>
    <Color x:Key="SolarSecondary">#FF9500</Color>
    <Color x:Key="SolarBackground">#1a1510</Color>
    
    <!-- Neutral -->
    <Color x:Key="NeutralDark">#0f0f0f</Color>
    <Color x:Key="NeutralLight">#e0e0e0</Color>
</ResourceDictionary>
```

---

## ✅ CHECKLIST

- [ ] Create WinUI 3 project structure
- [ ] Implement MVVM infrastructure (ViewModelBase, RelayCommand)
- [ ] Create API service with Refit
- [ ] Implement authentication (login, token storage)
- [ ] Build main navigation window
- [ ] Create Dashboard page
- [ ] Create Flows list page
- [ ] Create Flow details/editor page
- [ ] Create Integrations page
- [ ] Create Settings page
- [ ] Implement theme switching
- [ ] Add WebSocket real-time updates
- [ ] Implement local SQLite cache
- [ ] Add error handling & logging
- [ ] Create MSIX installer
- [ ] Test on Windows 10/11

---

**Windows App Status:** Architecture complete ✅  
**Ready for:** Implementation (UI development + API integration)

