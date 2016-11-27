using ASPSimple.ViewModels;
using Steeltoe.Extensions.Configuration.CloudFoundry;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ASPSimple.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var cloudFoundryApplication = ServerConfig.CloudFoundryApplication;
            var cloudFoundryServices = ServerConfig.CloudFoundryServices;
            return View(new CloudFoundryViewModel(
                cloudFoundryApplication == null ? new CloudFoundryApplicationOptions() : cloudFoundryApplication,
                cloudFoundryServices == null ? new CloudFoundryServicesOptions() : cloudFoundryServices));
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}