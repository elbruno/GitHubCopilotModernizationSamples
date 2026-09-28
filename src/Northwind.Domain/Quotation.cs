using Northwind.Audit;

namespace Northwind.Domain;

public enum CustomerType { Standard, Partner }

public sealed record QuoteRequest(
    string OrderId, string CustomerId, string CustomerEmail,
    CustomerType CustomerType, decimal UnitPrice, int Quantity, string CorrelationId)
{
    public void Validate()
    {
        if (!ValidText(OrderId, 64) || !ValidText(CustomerId, 128) ||
            !ValidText(CustomerEmail, 256) || !ValidText(CorrelationId, 128) ||
            !Enum.IsDefined(CustomerType) || UnitPrice is < 0 or > 1_000_000 ||
            decimal.Round(UnitPrice, 2) != UnitPrice || Quantity is < 1 or > 10_000)
            throw new InvalidQuoteException();
    }

    private static bool ValidText(string? value, int max) =>
        !string.IsNullOrWhiteSpace(value) && value.Length <= max;
}

public sealed class InvalidQuoteException : Exception
{
    public InvalidQuoteException() : base("Invalid quote request.") { }
}

public sealed record QuoteResponse(
    string OrderId, CustomerType CustomerType, decimal Subtotal,
    decimal Discount, decimal Shipping, decimal Total, string? ReviewNote);

public sealed class QuoteCalculator(IAuditTrail audit)
{
    public QuoteResponse Calculate(QuoteRequest request)
    {
        request.Validate();
        decimal subtotal = request.UnitPrice * request.Quantity;
        decimal discount = request.CustomerType == CustomerType.Partner && request.Quantity >= 3
            ? decimal.Round(subtotal * 0.10m, 2, MidpointRounding.AwayFromZero)
            : 0m;
        decimal net = subtotal - discount;
        decimal shipping = net >= 250m ? 0m : 12m;
        var response = new QuoteResponse(request.OrderId, request.CustomerType,
            subtotal, discount, shipping, net + shipping, null);
        audit.QuoteCalculated(CorrelationId.Normalize(request.CorrelationId), response.Total);
        return response;
    }
}
