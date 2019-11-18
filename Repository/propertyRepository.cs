using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Propertynetcore.Model;
using Npgsql;
using NpgsqlTypes;

namespace Propertynetcore.Repository
{
    public class PropertyRepository
    {
       // public static string connString = "Host=ec2-54-243-210-223.compute-1.amazonaws.com;Port=5432;User Id=bpqmfsatgaabpb;Password=TIpfRzH32iobV_8Q8Fi--bx9IV;Database=d6kdk6sivm8mpe;sslmode=Require;Trust Server Certificate=true;Timeout=1000";

        public List<Property> GetSearchList(string latitude1, string latitude2)
        {
            var property = new List<Property>();
            using (var sqlCon = new NpgsqlConnection(Config.ConnectionString))
            {
                sqlCon.Open();
                
                //var watch = System.Diagnostics.Stopwatch.StartNew();
                int recordsCount = 0;
                //select obpropid from property_r1 where abs(latitude) > 0 and abs(latitude) > 0 and point(latitude, longitude) <@> point({ 0},{ 1})<={ 2}limit 10000;
                //using (NpgsqlCommand cmd = new NpgsqlCommand(string.Format("select propertyid,description,address,state,country,subdivision,onsaledate,price,gpslat,gpslong,point from property where abs(gpslat)>=abs({0}) and abs(gpslong)<=abs({1}) limit 10000;", latitude1, latitude2), sqlCon))
                using (NpgsqlCommand cmd = new NpgsqlCommand(string.Format("select propertyid,description,address,state,country,subdivision,onsaledate,price,gpslat,gpslong,point from property where abs(gpslat) > 0 and abs(gpslong) > 0 and point(gpslat, gpslong) <@> point({0},{1})<=100 limit 1000;", latitude1, latitude2), sqlCon))
                {
                    using (NpgsqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            Property prop = new Property();
                            prop.Description = Convert.ToString(dr[1]).Replace("&apos;","'").Replace("&#47;", "/");
                            prop.Address = Convert.ToString(dr[2]);
                            prop.State = Convert.ToString(dr[3]);
                            prop.Country = Convert.ToString(dr[4]);
                            prop.SubDivision = Convert.ToString(dr[5]);
                            prop.OnSaleDate = Convert.ToDateTime(dr[6]);
                            prop.Price = Convert.ToDouble(dr[7]);
                            prop.GPSLat = Convert.ToDouble(dr[8]);
                            prop.GPSLong = Convert.ToDouble(dr[9]);
                            property.Add(prop);
                            recordsCount++;
                        }

                    }
                }
                //watch.Stop();
                //var elapsedMs = watch.ElapsedMilliseconds;
                //ViewBag.TimeElapsed = (elapsedMs / 1000).ToString();
                //ViewBag.RecordsCount = recordsCount.ToString();
            }
            return property;
        }

    }
}
