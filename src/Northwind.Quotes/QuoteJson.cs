using System.Text.Json;
using System.Text.Json.Serialization;
using Northwind.Domain;

namespace Northwind.Quotes;

public static class QuoteJson
{
    private static readonly HashSet<string> Fields =
    [
        "order_id", "customer_id", "customer_email", "customer_type",
        "unit_price", "quantity", "correlation_id"
    ];

    private static readonly JsonSerializerOptions OutputOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never,
        Converters = { new JsonStringEnumConverter<CustomerType>(JsonNamingPolicy.CamelCase, false) }
    };

    public static QuoteRequest Read(string json)
    {
        try
        {
            using var document = JsonDocument.Parse(json, new JsonDocumentOptions
            {
                MaxDepth = 8, AllowTrailingCommas = true, CommentHandling = JsonCommentHandling.Skip
            });
            var root = document.RootElement;
            if (root.ValueKind != JsonValueKind.Object)
                throw new InvalidQuoteException();
            var seen = new HashSet<string>(StringComparer.Ordinal);
            foreach (var property in root.EnumerateObject())
                if (!Fields.Contains(property.Name) || !seen.Add(property.Name))
                    throw new InvalidQuoteException();
            if (seen.Count != Fields.Count)
                throw new InvalidQuoteException();
            string Text(string name) => root.GetProperty(name).ValueKind == JsonValueKind.String
                ? root.GetProperty(name).GetString()! : throw new InvalidQuoteException();
            var type = Text("customer_type") switch
            {
                "standard" => CustomerType.Standard,
                "partner" => CustomerType.Partner,
                _ => throw new InvalidQuoteException()
            };
            if (root.GetProperty("unit_price").ValueKind != JsonValueKind.Number ||
                !root.GetProperty("unit_price").TryGetDecimal(out decimal price) ||
                root.GetProperty("quantity").ValueKind != JsonValueKind.Number ||
                !root.GetProperty("quantity").TryGetInt32(out int quantity))
                throw new InvalidQuoteException();
            var request = new QuoteRequest(Text("order_id"), Text("customer_id"),
                Text("customer_email"), type, price, quantity, Text("correlation_id"));
            request.Validate();
            return request;
        }
        catch (JsonException)
        {
            throw new InvalidQuoteException();
        }
    }

    public static string Write(QuoteResponse response) => JsonSerializer.Serialize(response, OutputOptions);
}
