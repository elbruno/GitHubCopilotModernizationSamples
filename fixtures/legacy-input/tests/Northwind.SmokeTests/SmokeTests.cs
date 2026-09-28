using System.Text.Json;
using Northwind.Quotes;
using Xunit;

namespace Northwind.SmokeTests;

public class SmokeTests
{
    [Fact]
    public void StandardQuoteWorks()
    {
        const string input = """
            {"order_id":"ORDER","customer_id":"SYNTH","customer_email":"demo@example.invalid",
             "customer_type":"standard","unit_price":100,"quantity":2,"correlation_id":"DEMO"}
            """;
        var output = new StringWriter();
        int code = QuoteCli.Run([], new StringReader(input), output, new StringWriter());
        Assert.Equal(0, code);
        using var document = JsonDocument.Parse(output.ToString());
        Assert.Equal(212m, document.RootElement.GetProperty("total").GetDecimal());
    }

    [Fact]
    public void MalformedInputHasNonzeroExit()
    {
        var output = new StringWriter();
        Assert.Equal(2, QuoteCli.Run([], new StringReader("{"), output, new StringWriter()));
        Assert.Equal("", output.ToString());
    }
}
