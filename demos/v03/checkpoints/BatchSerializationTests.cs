using System.Text.Json;
using System.Text.Json.Nodes;
using Northwind.Domain;
using Northwind.Quotes;
using Xunit;

namespace Northwind.UnitTests;

public class BatchSerializationTests
{
    [Fact]
    public void EveryItemMatchesTheSingleResponseContract()
    {
        QuoteResponse[] responses =
        [
            new("FIRST", CustomerType.Partner, 100.05m, 10.01m, 12m, 102.04m, null),
            new("SECOND", CustomerType.Standard, 250m, 0m, 0m, 250m, "Synthetic review")
        ];
        using var document = JsonDocument.Parse(QuoteJson.WriteBatch(responses));
        Assert.Equal(JsonValueKind.Array, document.RootElement.ValueKind);
        Assert.Equal(2, document.RootElement.GetArrayLength());
        for (int i = 0; i < responses.Length; i++)
        {
            var item = document.RootElement[i];
            Assert.True(JsonNode.DeepEquals(JsonNode.Parse(QuoteJson.Write(responses[i])),
                JsonNode.Parse(item.GetRawText())));
            Assert.Equal(responses[i].OrderId, item.GetProperty("order_id").GetString());
            Assert.Equal(JsonValueKind.String, item.GetProperty("customer_type").ValueKind);
            Assert.Equal(JsonValueKind.Number, item.GetProperty("total").ValueKind);
        }
        Assert.Equal(JsonValueKind.Null, document.RootElement[0].GetProperty("review_note").ValueKind);
    }

    [Fact]
    public void EmptyInputProducesAnEmptyArray()
    {
        using var document = JsonDocument.Parse(QuoteJson.WriteBatch([]));
        Assert.Equal(JsonValueKind.Array, document.RootElement.ValueKind);
        Assert.Equal(0, document.RootElement.GetArrayLength());
    }

    [Fact]
    public void NullCollectionIsRejected() =>
        Assert.Throws<ArgumentNullException>(() => QuoteJson.WriteBatch(null!));
}
