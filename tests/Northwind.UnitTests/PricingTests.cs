using Northwind.Audit;
using Northwind.Domain;
using Xunit;

namespace Northwind.UnitTests;

public class PricingTests
{
    [Theory]
    [InlineData(CustomerType.Standard, "100", 2, "200", "0", "12", "212")]
    [InlineData(CustomerType.Partner, "100", 2, "200", "0", "12", "212")]
    [InlineData(CustomerType.Partner, "100", 3, "300", "30", "0", "270")]
    [InlineData(CustomerType.Partner, "33.35", 3, "100.05", "10.01", "12", "102.04")]
    [InlineData(CustomerType.Standard, "250", 1, "250", "0", "0", "250")]
    [InlineData(CustomerType.Standard, "249.99", 1, "249.99", "0", "12", "261.99")]
    public void PricesAndAuditUseApprovedRules(CustomerType type, string price, int quantity,
        string subtotal, string discount, string shipping, string total)
    {
        var audit = new RecordingAudit();
        var result = new QuoteCalculator(audit).Calculate(
            new("ORDER", "SYNTH", "demo@example.invalid", type, Money(price), quantity, "DEMO\n-001"));
        Assert.Equal(Money(subtotal), result.Subtotal);
        Assert.Equal(Money(discount), result.Discount);
        Assert.Equal(Money(shipping), result.Shipping);
        Assert.Equal(Money(total), result.Total);
        Assert.Null(result.ReviewNote);
        Assert.Equal([("DEMO-001", result.Total)], audit.Events);
    }

    [Fact]
    public void RejectsInvalidDomainRequestWithoutAuditing()
    {
        var audit = new RecordingAudit();
        Assert.Throws<InvalidQuoteException>(() => new QuoteCalculator(audit).Calculate(
            new("ORDER", "SYNTH", "demo@example.invalid", CustomerType.Standard, -1m, 1, "DEMO")));
        Assert.Empty(audit.Events);
    }

    private static decimal Money(string text) => decimal.Parse(text, System.Globalization.CultureInfo.InvariantCulture);
    private sealed class RecordingAudit : IAuditTrail
    {
        public List<(string, decimal)> Events { get; } = [];
        public void QuoteCalculated(string correlationId, decimal total) => Events.Add((correlationId, total));
    }
}
