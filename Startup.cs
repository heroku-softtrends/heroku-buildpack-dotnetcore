using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Propertynetcore.Model;

namespace Propertynetcore
{
    public class Startup
    {
        public static string appRoutePath = string.Empty;
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllersWithViews();

            //Get Database Connection 
            //Environment.SetEnvironmentVariable("DATABASE_URL", "postgres://fdhbjevexgwois:f03ca3e6d3653031f3407a8f9f8cbfaecc7ade5d9b7cd6c3185859bfe450b55f@ec2-184-73-169-163.compute-1.amazonaws.com:5432/d9lrbre1cgv2q4");
            string _connectionString = Environment.GetEnvironmentVariable("DATABASE_URL");
            _connectionString.Replace("//", "");

            char[] delimiterChars = { '/', ':', '@', '?' };
            string[] strConn = _connectionString.Split(delimiterChars);
            strConn = strConn.Where(x => !string.IsNullOrEmpty(x)).ToArray();

            Config.User = strConn[1];
            Config.Pass = strConn[2];
            Config.Server = strConn[3];
            Config.Database = strConn[5];
            Config.Port = strConn[4];
            Config.ConnectionString = "host=" + Config.Server + ";port=" + Config.Port + ";database=" + Config.Database + ";uid=" + Config.User + ";pwd=" + Config.Pass + ";sslmode=Require;Trust Server Certificate=true;Timeout=1000";

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            appRoutePath = Path.Combine(env.ContentRootPath, "Data", "property.sql");
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
               // app.UseHsts();
            }
            //app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=property}/{action=index}/{id?}");
					
            });
        }
    }
}
