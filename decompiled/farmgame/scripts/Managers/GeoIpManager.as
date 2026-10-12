package Managers
{
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   
   public class GeoIpManager
   {
      
      private var m_geoIP:Object = null;
      
      private var m_geoIpResults:Object = {};
      
      public function GeoIpManager()
      {
         super();
      }
      
      public function set geoip(geoip:Object) : void
      {
         this.m_geoIP = geoip;
      }
      
      public function get geoip() : Object
      {
         return this.m_geoIP;
      }
      
      private function isWithinLocation(locationField:String, includeLocations:Array) : Boolean
      {
         var location:String = null;
         var result:Boolean = false;
         if(this.m_geoIP != null && this.m_geoIP.hasOwnProperty(locationField))
         {
            location = this.m_geoIP[locationField];
            result = includeLocations != null && includeLocations.indexOf(location) >= 0;
         }
         return result;
      }
      
      private function cacheGeoIpResult(areaName:String) : Boolean
      {
         var result:Boolean = false;
         var geoIpAreasXML:XMLList = null;
         var geoIpAreaXML:XMLList = null;
         var countryIndex:String = null;
         var countryXML:XML = null;
         var countryCode:String = null;
         var regions:Array = null;
         result = false;
         geoIpAreasXML = Global.farmGameSettingsManager.getGeoIpAreas();
         geoIpAreaXML = geoIpAreasXML.descendants().(attribute("name") == areaName);
         if(geoIpAreaXML.length() > 0)
         {
            for(countryIndex in geoIpAreaXML.country)
            {
               countryXML = geoIpAreaXML.country[countryIndex];
               countryCode = countryXML.@code;
               if(this.isWithinLocation("country_code",[countryCode]))
               {
                  result = true;
                  if(countryXML.attributes().hasOwnProperty("regions"))
                  {
                     regions = countryXML.@regions.split(";");
                     if(regions.length > 0)
                     {
                        result = this.isWithinLocation("region",regions);
                     }
                  }
               }
               if(result)
               {
                  break;
               }
            }
         }
         this.m_geoIpResults[areaName] = result;
         return result;
      }
      
      public function isUserInArea(areaName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_geoIpResults.hasOwnProperty(areaName))
         {
            result = Boolean(this.m_geoIpResults[areaName]);
         }
         else
         {
            result = this.cacheGeoIpResult(areaName);
         }
         return result;
      }
      
      public function getGeoipLocale() : String
      {
         var localeParts:Array = null;
         var geoipLocale:String = ZLocUtils.getDefaultLocale();
         var acceptedLocales:Array = ZLocUtils.getAcceptedLocales();
         var locale:String = "";
         for each(locale in acceptedLocales)
         {
            localeParts = locale.split("_");
            if(this.isUserInArea(localeParts[0]))
            {
               geoipLocale = locale;
               break;
            }
         }
         return geoipLocale;
      }
      
      public function checkGeoGate(geoIpXML:XMLList, geoIpData:BaseDataSource = null) : Boolean
      {
         var excludeArea:String = null;
         var includeArea:String = null;
         var excludeAreaXML:XMLList = null;
         var includeAreaXML:XMLList = null;
         var result:Boolean = false;
         if(this.m_geoIP)
         {
            if(geoIpData)
            {
               excludeArea = geoIpData.getString("excludeArea","area");
               if(excludeArea != "")
               {
                  result = !this.isUserInArea(excludeArea);
               }
               else
               {
                  includeArea = geoIpData.getString("includeArea","area");
                  if(includeArea != "")
                  {
                     result = this.isUserInArea(includeArea);
                  }
               }
            }
            else if(geoIpXML.hasOwnProperty("excludeArea"))
            {
               excludeAreaXML = geoIpXML["excludeArea"];
               excludeArea = excludeAreaXML.@area;
               result = !this.isUserInArea(excludeArea);
            }
            else if(geoIpXML.hasOwnProperty("includeArea"))
            {
               includeAreaXML = geoIpXML["includeArea"];
               includeArea = includeAreaXML.@area;
               result = this.isUserInArea(includeArea);
            }
         }
         return result;
      }
   }
}

