using System.Diagnostics;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Nodes;
using Xunit;

namespace Northwind.AcceptanceTests;

// This process-level evaluator is kept outside the agent-visible export.
public class ContractTests
{
    private const string CustomerId = "SYNTH-SECRET-ID-7f92";
    private const string Email = "sentinel-7f92@example.invalid";
    private static string App => Environment.GetEnvironmentVariable("QUOTE_APP_DLL") ??
        Path.GetFullPath(Path.Combine(AppContext.BaseDirectory,
            "../../../../../src/Northwind.Quotes/bin/Debug/net10.0/Northwind.Quotes.dll"));

    private static JsonObject Request() => new()
    {
        ["order_id"] = "ORDER-001", ["customer_id"] = CustomerId, ["customer_email"] = Email,
        ["customer_type"] = "partner", ["unit_price"] = 100m,
        ["quantity"] = 3, ["correlation_id"] = "DEMO-001"
    };

    [Theory]
    [InlineData("standard", "100", 2, "200", "0", "12", "212")]
    [InlineData("partner", "100", 2, "200", "0", "12", "212")]
    [InlineData("partner", "100", 3, "300", "30", "0", "270")]
    [InlineData("partner", "33.35", 3, "100.05", "10.01", "12", "102.04")]
    [InlineData("standard", "250", 1, "250", "0", "0", "250")]
    [InlineData("standard", "249.99", 1, "249.99", "0", "12", "261.99")]
    [InlineData("partner", "90", 3, "270", "27", "12", "255")]
    [InlineData("standard", "1000000", 10000, "10000000000", "0", "0", "10000000000")]
    public async Task R1_R2_R3_R4_PricingContractAndAudit(string type, string price, int quantity,
        string subtotal, string discount, string shipping, string total)
    {
        var request = Request();
        request["customer_type"] = type;
        request["unit_price"] = Money(price);
        request["quantity"] = quantity;
        var result = await Run(request.ToJsonString());
        Assert.Equal(0, result.Code);
        using var json = JsonDocument.Parse(result.Out);
        var root = json.RootElement;
        Assert.Equal(new[] { "customer_type", "discount", "order_id", "review_note", "shipping", "subtotal", "total" },
            root.EnumerateObject().Select(p => p.Name).Order().ToArray());
        Assert.Equal("ORDER-001", root.GetProperty("order_id").GetString());
        Assert.Equal(type, root.GetProperty("customer_type").GetString());
        Assert.Equal(JsonValueKind.Null, root.GetProperty("review_note").ValueKind);
        foreach (var (name, value) in new[] { ("subtotal", subtotal), ("discount", discount),
                     ("shipping", shipping), ("total", total) })
        {
            Assert.Equal(JsonValueKind.Number, root.GetProperty(name).ValueKind);
            Assert.Equal(Money(value), root.GetProperty(name).GetDecimal());
        }
        var lines = result.Error.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        Assert.Single(lines);
        using var audit = JsonDocument.Parse(lines[0]);
        Assert.Equal(new[] { "correlation_id", "event_name", "total" },
            audit.RootElement.EnumerateObject().Select(p => p.Name).Order().ToArray());
        Assert.Equal("quote_calculated", audit.RootElement.GetProperty("event_name").GetString());
        Assert.Equal("DEMO-001", audit.RootElement.GetProperty("correlation_id").GetString());
        Assert.Equal(Money(total), audit.RootElement.GetProperty("total").GetDecimal());
        NoLeaks(result);
    }

    public static IEnumerable<object[]> InvalidRequests()
    {
        foreach (string field in Request().Select(p => p.Key))
        {
            var missing = Request(); missing.Remove(field);
            yield return [missing.ToJsonString()];
            var nil = Request(); nil[field] = null;
            yield return [nil.ToJsonString()];
        }
        foreach (var (name, value) in new (string, JsonNode?)[]
        {
            ("customer_type", JsonValue.Create("vip")), ("customer_type", JsonValue.Create("Partner")),
            ("customer_type", JsonValue.Create(1)), ("unit_price", JsonValue.Create(-1)),
            ("unit_price", JsonValue.Create(1000000.01m)), ("unit_price", JsonValue.Create(0.001m)),
            ("unit_price", JsonValue.Create("100")), ("quantity", JsonValue.Create(0)),
            ("quantity", JsonValue.Create(-1)), ("quantity", JsonValue.Create(10001)),
            ("quantity", JsonValue.Create(1.5)), ("quantity", JsonValue.Create("3")),
            ("order_id", JsonValue.Create("")), ("order_id", JsonValue.Create(new string('x', 65))),
            ("customer_email", JsonValue.Create(new string('x', 257))),
            ("correlation_id", JsonValue.Create(new string('x', 129))),
            ("surprise", JsonValue.Create("unknown"))
        })
        {
            var request = Request(); request[name] = value;
            yield return [request.ToJsonString()];
        }
        yield return [Request().ToJsonString().Replace("\"order_id\"", "\"Order_id\"", StringComparison.Ordinal)];
        yield return [Request().ToJsonString().Replace("\"unit_price\":100", "\"unit_price\":1e100", StringComparison.Ordinal)];
        yield return [Request().ToJsonString().Replace("\"quantity\":3", "\"quantity\":99999999999999999999", StringComparison.Ordinal)];
        yield return [Request().ToJsonString().Replace("\"quantity\":3", "\"quantity\":3,\"quantity\":4", StringComparison.Ordinal)];
        yield return ["{\"customer_email\":\"" + Email + "\",\"customer_id\":\"" + CustomerId + "\",broken"];
        yield return ["[]"];
        yield return ["null"];
        yield return ["{} {}"];
        yield return [new string(' ', 16385)];
    }

    [Theory]
    [MemberData(nameof(InvalidRequests))]
    public async Task R2_R4_InvalidInputHasSafeError(string input)
    {
        var result = await Run(input);
        Assert.Equal(2, result.Code);
        Assert.Equal("", result.Out);
        Assert.Equal("Invalid quote request.", result.Error.Trim());
        NoLeaks(result);
    }

    [Fact]
    public async Task R2_CommentsAndTrailingCommaRemainSupported()
    {
        var result = await Run("/* synthetic */" + Request().ToJsonString().TrimEnd('}') + ",}");
        Assert.Equal(0, result.Code);
    }

    [Theory]
    [InlineData("unsafe\n\"{} / DEMO", "unsafeDEMO")]
    [InlineData("!@#$", "UNSPECIFIED")]
    [InlineData("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345")]
    public async Task R3_CorrelationIsNormalized(string raw, string expected)
    {
        var request = Request(); request["correlation_id"] = raw;
        var result = await Run(request.ToJsonString());
        Assert.Equal(0, result.Code);
        using var audit = JsonDocument.Parse(result.Error);
        Assert.Equal(expected, audit.RootElement.GetProperty("correlation_id").GetString());
        NoLeaks(result);
    }

    [Fact]
    public async Task R2_FileAndStdinAgree()
    {
        string path = Path.Combine(Path.GetTempPath(), $"northwind-request-{Guid.NewGuid()}.json");
        try
        {
            await File.WriteAllTextAsync(path, Request().ToJsonString());
            Assert.Equal(await Run(Request().ToJsonString()), await Run("", path));
        }
        finally { File.Delete(path); }
    }

    [Fact]
    public async Task R2_R4_IoAndUsageErrorsDoNotExposeArguments()
    {
        var missing = await Run("", Path.Combine(Path.GetTempPath(), CustomerId + Guid.NewGuid() + ".json"));
        Assert.Equal(3, missing.Code);
        Assert.Equal("", missing.Out);
        NoLeaks(missing);
        var usage = await Run("", "--" + Email);
        Assert.Equal(64, usage.Code);
        Assert.Equal("", usage.Out);
        NoLeaks(usage);
        var help = await Run("", "--help");
        Assert.Equal(0, help.Code);
        Assert.Contains("Usage:", help.Out);
        Assert.Equal("", help.Error);
    }

    private static void NoLeaks(Result result)
    {
        foreach (string forbidden in new[] { CustomerId, Email, "customer_email", "customer_id" })
        {
            Assert.DoesNotContain(forbidden, result.Error, StringComparison.OrdinalIgnoreCase);
            Assert.DoesNotContain(forbidden, result.Out, StringComparison.OrdinalIgnoreCase);
        }
    }

    private static decimal Money(string value) => decimal.Parse(value, CultureInfo.InvariantCulture);
    private sealed record Result(int Code, string Out, string Error);

    private static async Task<Result> Run(string input, params string[] args)
    {
        Assert.True(File.Exists(App), $"Build the application first. Missing app DLL: {App}");
        var start = new ProcessStartInfo("dotnet")
        {
            RedirectStandardInput = true, RedirectStandardOutput = true, RedirectStandardError = true,
            UseShellExecute = false
        };
        start.ArgumentList.Add(App);
        foreach (string arg in args) start.ArgumentList.Add(arg);
        using var process = Process.Start(start) ?? throw new InvalidOperationException("Cannot start dotnet.");
        var stdout = process.StandardOutput.ReadToEndAsync();
        var stderr = process.StandardError.ReadToEndAsync();
        await process.StandardInput.WriteAsync(input);
        process.StandardInput.Close();
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(15));
        try { await process.WaitForExitAsync(timeout.Token); }
        catch (OperationCanceledException)
        {
            process.Kill(entireProcessTree: true);
            throw new TimeoutException("Quote process exceeded 15 seconds.");
        }
        return new(process.ExitCode, await stdout, await stderr);
    }
}
