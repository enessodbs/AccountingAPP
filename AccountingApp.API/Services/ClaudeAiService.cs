using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace AccountingApp.API.Services
{
    public class ClaudeAiService : IAiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ClaudeAiService> _logger;

        public ClaudeAiService(HttpClient httpClient, IConfiguration configuration, ILogger<ClaudeAiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<string> SendMessageAsync(string prompt, string? systemPrompt = null)
        {
            var apiKey = _configuration["ClaudeSettings:ApiKey"];
            var model = _configuration["ClaudeSettings:Model"] ?? "claude-3-5-sonnet-20241022";
            var maxTokens = int.Parse(_configuration["ClaudeSettings:MaxTokens"] ?? "4096");

            var requestBody = new ClaudeRequest
            {
                Model = model,
                MaxTokens = maxTokens,
                System = systemPrompt,
                Messages = new List<ClaudeMessage>
                {
                    new ClaudeMessage { Role = "user", Content = prompt }
                }
            };

            var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages");
            request.Headers.Add("x-api-key", apiKey);
            request.Headers.Add("anthropic-version", "2023-06-01");
            
            var json = JsonSerializer.Serialize(requestBody, new JsonSerializerOptions 
            { 
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            });

            request.Content = new StringContent(json, Encoding.UTF8, "application/json");

            try
            {
                var response = await _httpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("Claude API Error: {StatusCode} - {Body}", response.StatusCode, responseBody);
                    throw new Exception($"Claude API error: {response.StatusCode}");
                }

                var claudeResponse = JsonSerializer.Deserialize<ClaudeResponse>(responseBody, new JsonSerializerOptions 
                { 
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase 
                });

                return claudeResponse?.Content?.FirstOrDefault()?.Text ?? "Yanıt alınamadı.";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Claude API");
                throw;
            }
        }

        private class ClaudeRequest
        {
            public string Model { get; set; } = string.Empty;
            public int MaxTokens { get; set; }
            public string? System { get; set; }
            public List<ClaudeMessage> Messages { get; set; } = new();
        }

        private class ClaudeMessage
        {
            [JsonPropertyName("role")]
            public string Role { get; set; } = "user";

            [JsonPropertyName("content")]
            public string Content { get; set; } = string.Empty;
        }

        private class ClaudeResponse
        {
            public string Id { get; set; } = string.Empty;
            public List<ClaudeContent> Content { get; set; } = new();
        }

        private class ClaudeContent
        {
            public string Type { get; set; } = "text";
            public string Text { get; set; } = string.Empty;
        }
    }
}
