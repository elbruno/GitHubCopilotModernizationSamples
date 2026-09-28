using Northwind.Audit;
using Northwind.Domain;
using Northwind.Quotes;

return QuoteCli.Run(args, Console.In, Console.Out, Console.Error);

namespace Northwind.Quotes
{
    public static class QuoteCli
    {
        public static int Run(string[] args, TextReader input, TextWriter output, TextWriter error)
        {
            if (args is ["--help"])
            {
                output.WriteLine("Northwind Outfitters Quote Service (synthetic demo)");
                output.WriteLine("Usage: Northwind.Quotes [request.json | -]");
                output.WriteLine("No argument or - reads stdin. One request, at most 16384 characters.");
                output.WriteLine("Exit codes: 0 success/help, 2 invalid input, 3 I/O error, 64 usage.");
                return 0;
            }
            if (args.Length > 1 || (args.Length == 1 && args[0].StartsWith('-') && args[0] != "-"))
            {
                error.WriteLine("Usage error. Use --help.");
                return 64;
            }
            try
            {
                string json;
                if (args.Length == 0 || args[0] == "-")
                    json = ReadBounded(input);
                else
                {
                    using var file = File.OpenText(args[0]);
                    json = ReadBounded(file);
                }
                var request = QuoteJson.Read(json);
                var response = new QuoteCalculator(new JsonAuditTrail(error)).Calculate(request);
                output.WriteLine(QuoteJson.Write(response));
                return 0;
            }
            catch (InvalidQuoteException)
            {
                error.WriteLine("Invalid quote request.");
                return 2;
            }
            catch (IOException)
            {
                error.WriteLine("Unable to read or write quote data.");
                return 3;
            }
            catch (UnauthorizedAccessException)
            {
                error.WriteLine("Unable to access quote data.");
                return 3;
            }
        }

        private static string ReadBounded(TextReader reader)
        {
            var buffer = new char[16_385];
            int count = reader.ReadBlock(buffer, 0, buffer.Length);
            if (count > 16_384)
                throw new InvalidQuoteException();
            return new string(buffer, 0, count);
        }
    }
}
