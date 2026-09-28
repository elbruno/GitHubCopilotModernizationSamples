using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;
using Northwind.Domain;

namespace Northwind.Quotes;

public static class QuoteJson
{
    private static readonly HashSet<string> Fields =
    [
        "order_id", "customer_id", "customer_email", "customer_type",
        "unit_price", "quantity", "correlation_id"
    ];

    private static readonly JsonSerializerSettings OutputSettings = new()
    {
        ContractResolver = new DefaultContractResolver { NamingStrategy = new SnakeCaseNamingStrategy() },
        NullValueHandling = NullValueHandling.Include,
        Converters = { new StringEnumConverter(new CamelCaseNamingStrategy(), false) }
    };

    public static QuoteRequest Read(string json)
    {
        try
        {
            using var text = new StringReader(json);
            using var reader = new JsonTextReader(text)
            {
                MaxDepth = 8, FloatParseHandling = FloatParseHandling.Decimal,
                DateParseHandling = DateParseHandling.None
            };
            var root = JObject.Load(reader, new JsonLoadSettings
            {
                DuplicatePropertyNameHandling = DuplicatePropertyNameHandling.Error
            });
            while (reader.Read())
                if (reader.TokenType != JsonToken.Comment)
                    throw new InvalidQuoteException();
            if (root.Properties().Count() != Fields.Count ||
                root.Properties().Any(p => !Fields.Contains(p.Name)))
                throw new InvalidQuoteException();
            string Text(string name) => root[name]?.Type == JTokenType.String
                ? root[name]!.Value<string>()! : throw new InvalidQuoteException();
            var type = Text("customer_type") switch
            {
                "standard" => CustomerType.Standard,
                "partner" => CustomerType.Partner,
                _ => throw new InvalidQuoteException()
            };
            if (root["unit_price"]?.Type is not (JTokenType.Integer or JTokenType.Float) ||
                root["quantity"]?.Type != JTokenType.Integer ||
                !decimal.TryParse(root["unit_price"]!.ToString(Formatting.None), NumberStyles.Float,
                    CultureInfo.InvariantCulture, out decimal price) ||
                !int.TryParse(root["quantity"]!.ToString(Formatting.None), NumberStyles.Integer,
                    CultureInfo.InvariantCulture, out int quantity))
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
        catch (OverflowException)
        {
            throw new InvalidQuoteException();
        }
    }

    public static string Write(QuoteResponse response) => JsonConvert.SerializeObject(response, OutputSettings);
}
