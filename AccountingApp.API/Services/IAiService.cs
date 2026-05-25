namespace AccountingApp.API.Services
{
    public interface IAiService
    {
        Task<string> SendMessageAsync(string prompt, string? systemPrompt = null);
    }
}
