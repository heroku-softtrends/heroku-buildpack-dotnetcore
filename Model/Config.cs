using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Propertynetcore.Model
{
    public class Config
    {
        public static string Server { get; set; }
        public static string User { get; set; }
        public static string Pass { get; set; }
        public static string Port { get; set; }
        public static string Database { get; set; }
        public static string ConnectionString { get; set; }
    }
}
