package Classes.Doobers
{
   import Classes.Constants.XMLKeys;
   
   public class DooberLocation
   {
      
      private static const UNLOCK_TYPE_WORLD_CONTENT_LICENSE:String = "worldContentLicense";
      
      private var m_locationName:String = "";
      
      private var m_experimentName:String = "";
      
      private var m_experimentVariant:int = 0;
      
      private var m_unlockType:String = "";
      
      private var m_unlockKey:String = "";
      
      public function DooberLocation(dooberLocationXml:XML)
      {
         super();
         if(dooberLocationXml.hasOwnProperty(XMLKeys.ATTR_NAME))
         {
            this.m_locationName = dooberLocationXml[XMLKeys.ATTR_NAME];
         }
         if(dooberLocationXml.hasOwnProperty(XMLKeys.ATTR_EXPERIMENT))
         {
            this.m_experimentName = dooberLocationXml[XMLKeys.ATTR_EXPERIMENT];
            this.m_experimentVariant = 1;
            if(dooberLocationXml.hasOwnProperty(XMLKeys.ATTR_EXPERIMENT_VARIANT))
            {
               this.m_experimentVariant = int(dooberLocationXml[XMLKeys.ATTR_EXPERIMENT_VARIANT]);
            }
         }
         if(dooberLocationXml.hasOwnProperty(XMLKeys.ATTR_UNLOCK_TYPE))
         {
            this.m_unlockType = dooberLocationXml[XMLKeys.ATTR_UNLOCK_TYPE];
            if(dooberLocationXml.hasOwnProperty(XMLKeys.ATTR_UNLOCK_KEY))
            {
               this.m_unlockKey = dooberLocationXml[XMLKeys.ATTR_UNLOCK_KEY];
            }
         }
      }
      
      public function isAvailable() : Boolean
      {
         var worldWorldLicensePair:Array = null;
         var worldType:String = null;
         var licenseType:String = null;
         var result:Boolean = true;
         if(Global.experimentManager.getExperimentVariant(this.m_experimentName) != this.m_experimentVariant)
         {
            result = false;
         }
         if(result)
         {
            if(this.m_unlockType == UNLOCK_TYPE_WORLD_CONTENT_LICENSE)
            {
               worldWorldLicensePair = this.m_unlockKey.split(":");
               if(worldWorldLicensePair.length >= 2)
               {
                  worldType = worldWorldLicensePair[0];
                  licenseType = worldWorldLicensePair[1];
                  result = Global.worldManager.hasWorldContentLicense(worldType,licenseType);
               }
            }
         }
         return result;
      }
      
      public function getLocationName() : String
      {
         return this.m_locationName;
      }
   }
}

