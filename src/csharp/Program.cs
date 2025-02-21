using System.Net;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

const string razor = "🪒";
int counter = 0;

app.Use(async (context, next) =>
{
    Interlocked.Increment(ref counter);
    await next();
});

app.MapGet("/", () => $"{razor}: Hello World!");
app.MapGet("/{name}", (string name) => $"{razor}: Hello {name}!");
app.MapGet("/ping", () => $"{razor}: pong from {Environment.MachineName}");
app.MapGet("/random", () => $"{razor}: {Environment.MachineName} generated random {new Random().Next()}");
app.MapGet("/ip", () => $"{razor}: {string.Join(", ", Dns.GetHostEntry(Dns.GetHostName()).AddressList.ToList())}");

app.MapGet("/count", async context =>
{
    context.Response.ContentType = "text/plain; charset=utf-8";
    await context.Response.WriteAsync($"{razor}: {Environment.MachineName} #{Interlocked.Decrement(ref counter)}");
});

await app.RunAsync();