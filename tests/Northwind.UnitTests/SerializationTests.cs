using System.Text.Json;
using Northwind.Domain;
using Northwind.Quotes;
using Xunit;

namespace Northwind.UnitTests;

public class SerializationTests
{
    [Fact]
    public void PreservesExplicitNull()
    {
        var response = new QuoteResponse("ORDER", CustomerType.Partner, 300m, 30m, 0m, 270m, null);
        using var document = JsonDocument.Parse(QuoteJson.Write(response));
        Assert.True(document.RootElement.TryGetProperty("review_note", out var note),
            "R2: review_note must exist even when its value is null");
        Assert.Equal(JsonValueKind.Null, note.ValueKind);
    }

    [Theory]
    [InlineData(CustomerType.Standard, "standard")]
    [InlineData(CustomerType.Partner, "partner")]
    public void PreservesWireTypesAndNames(CustomerType type, string expected)
    {
        using var document = JsonDocument.Parse(QuoteJson.Write(
            new QuoteResponse("ORDER", type, 100.05m, 10.01m, 12m, 102.04m, "Synthetic review")));
        var json = document.RootElement;
        Assert.Equal(new[] { "customer_type", "discount", "order_id", "review_note", "shipping", "subtotal", "total" },
            json.EnumerateObject().Select(p => p.Name).Order().ToArray());
        Assert.Equal(expected, json.GetProperty("customer_type").GetString());
        Assert.Equal("Synthetic review", json.GetProperty("review_note").GetString());
        Assert.Equal(JsonValueKind.Number, json.GetProperty("total").ValueKind);
        Assert.Equal(102.04m, json.GetProperty("total").GetDecimal());
    }
}
