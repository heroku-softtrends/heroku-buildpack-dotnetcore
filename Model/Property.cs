using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;
using System.Text;
using System.Data;
using Microsoft.AspNetCore.Hosting.Server;
using System.IO;
using Microsoft.Extensions.PlatformAbstractions;
using System.Text.RegularExpressions;

namespace Propertynetcore.Model
{
    public class Property
    {
        //OleDbConnection oledbConn;
        public string Description { get; set; }

        public string Address { get; set; }

        public string State { get; set; }

        public string Country { get; set; }

        public string SubDivision { get; set; }

        public DateTime OnSaleDate { get; set; }

        public double Price { get; set; }

        public double GPSLat { get; set; }

        public double GPSLong { get; set; }


        public void CreatePropertyTable()
        {
            try
            {
                NpgsqlConnection conn;
                NpgsqlCommand cmd;
                using (conn = new NpgsqlConnection(Config.ConnectionString))
                {
                    conn.Open();
                    //StringBuilder qry = "";
                    using (cmd = new NpgsqlCommand("CREATE TABLE IF NOT EXISTS public.property(propertyid bigint NOT NULL,description text,address varchar(700) NOT NULL,state varchar(100),country varchar(100),subdivision varchar(200),onsaledate date,price bigint,gpslat decimal(17, 10),gpslong decimal(17, 10),point polygon,CONSTRAINT property_pkey PRIMARY KEY(propertyid))", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                    using (cmd = new NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS \"cube\";", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                    using (cmd = new NpgsqlCommand("CREATE EXTENSION IF NOT EXISTS \"earthdistance\";", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message, ex);
            }
        }

        public void Export()
        {
            var path = Startup.appRoutePath;

            string script = File.ReadAllText(path);

            // split script on GO command
            IEnumerable<string> commandStrings = Regex.Split(script, @"^\s*GO\s*$",
                                     RegexOptions.Multiline | RegexOptions.IgnoreCase);
            NpgsqlConnection conn;
            NpgsqlCommand cmd;
            using (conn = new NpgsqlConnection(Config.ConnectionString))
            {
                conn.Open();
                int totalRecordCount = 0;
                using (cmd = new NpgsqlCommand("select count(propertyid) as totalCount from property", conn))
                {
                    using (NpgsqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Int32.TryParse(reader["totalCount"].ToString(), out totalRecordCount);
                        }
                    }
                }
                if (totalRecordCount == 0)
                {
                    foreach (string commandString in commandStrings)
                    {
                        string str = commandString;
                        //foreach (string query in Regex.Split(commandString.ToString(), @"[);]*", RegexOptions.IgnoreCase))
                        foreach (string query in Regex.Split(commandString.ToString(), @";\n", RegexOptions.IgnoreCase))
                        {
                            if (query.Trim() != "")
                            {
                                //using (var command = new NpgsqlCommand(string.Format("{0});", query), conn))
                                using (var command = new NpgsqlCommand(query, conn))
                                {
                                    command.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
