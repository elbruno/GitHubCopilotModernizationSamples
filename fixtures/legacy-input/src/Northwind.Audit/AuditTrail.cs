using System.Text.Json;

namespace Northwind.Audit;

// Fictional demo component, not an internal Northwind or Microsoft library.
public interface IAuditTrail
{
    void QuoteCalculated(string correlationId, decimal total);
}

public static class CorrelationId
{
    public static string Normalize(string value)
    {
        var safe = new string(value.Where(c =>
            c is >= 'A' and <= 'Z' or >= 'a' and <= 'z' or >= '0' and <= '9' or '-' or '_')
            .Take(32).ToArray());
        return safe.Length == 0 ? "UNSPECIFIED" : safe;
    }
}

public sealed class JsonAuditTrail(TextWriter diagnostics) : IAuditTrail
{
    public void QuoteCalculated(string correlationId, decimal total) =>
        diagnostics.WriteLine(JsonSerializer.Serialize(new
        {
            event_name = "quote_calculated",
            correlation_id = CorrelationId.Normalize(correlationId),
            total
        }));
}
