using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Npgsql;
using NpgsqlTypes;
using Propertynetcore.Model;
using System.Data;
using Propertynetcore.Repository;


// For more information on enabling MVC for empty projects, visit http://go.microsoft.com/fwlink/?LinkID=397860

namespace Propertynetcore.Controllers
{
    public class PropertyController : Controller
    {
        //public static string connString = "Host=ec2-54-243-210-223.compute-1.amazonaws.com;Port=5432;User Id=bpqmfsatgaabpb;Password=TIpfRzH32iobV_8Q8Fi--bx9IV;Database=d6kdk6sivm8mpe;sslmode=Require;Trust Server Certificate=true;Timeout=1000";
        //private readonly string minlat;
        //private readonly string maxlat;
        

        public PropertyController()
        {
            //using (var sqlCon = new NpgsqlConnection(connString))
            //{
            //    sqlCon.Open();
            //    using (NpgsqlCommand cmd = new NpgsqlCommand("select min(gpslat) as minlat,max(gpslong) as maxlat from property", sqlCon))
            //    {
            //        using (NpgsqlDataReader reader = cmd.ExecuteReader())
            //        {
            //            while (reader.Read())
            //            {
            //                minlat = reader["minlat"].ToString();
            //                maxlat = reader["maxlat"].ToString();
            //            }
            //        }
            //    }
            //}
        }

        // GET: /<controller>/
        public IActionResult Index(string latitude1, string latitude2)
        {
            Property prop = new Property();
            prop.CreatePropertyTable();
            prop.Export();
            //ViewBag.MinLat = minlat;
            //ViewBag.MaxLat = maxlat;
            //try
            //{
            //    ViewBag.MinLat = minlat;
            //    ViewBag.MaxLat = maxlat;
            //    ViewBag.TimeElapsed = "0";
            //    if (string.IsNullOrEmpty(latitude1) || string.IsNullOrEmpty(latitude2))
            //    {
            //        return View();
            //    }

            //    using (var sqlCon = new NpgsqlConnection(connString))
            //    {
            //        sqlCon.Open();

            //        var watch = System.Diagnostics.Stopwatch.StartNew();
            //        int recordsCount = 0;
            //        using (NpgsqlCommand cmd = new NpgsqlCommand(string.Format("select propertyid from property where abs(gpslat)>={0} and abs(gpslong)<={1} limit 10000;", latitude1, latitude2), sqlCon))
            //        {
            //            using (NpgsqlDataReader reader = cmd.ExecuteReader())
            //            {
            //                while (reader.Read())
            //                    recordsCount++;
            //            }
            //        }
            //        watch.Stop();
            //        var elapsedMs = watch.ElapsedMilliseconds;
            //        ViewBag.TimeElapsed = (elapsedMs / 1000).ToString();
            //        ViewBag.RecordsCount = recordsCount.ToString();
            //    }
            //}
            //catch (Exception ex)
            //{
            //    throw ex;
            //}

            return View();
        }


        public IActionResult ViewProperty()
        {
            return View();
        }


        public JsonResult GetSearchList(string latitude1, string latitude2)
        {
            var property = new List<Property>();
            PropertyRepository pRepo = new PropertyRepository();
            property = pRepo.GetSearchList(latitude1, latitude2);
            return Json(property);
        }


    }
}
