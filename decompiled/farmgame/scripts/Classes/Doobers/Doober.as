package Classes.Doobers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.XMLKeys;
   import Classes.FarmGameObject;
   import Managers.DefconManager;
   import flash.utils.Dictionary;
   
   public class Doober
   {
      
      public static const NO_DOOBER_DEFCON_LEVEL:int = 7;
      
      private var m_actionName:String = "";
      
      private var m_actionObject:FarmGameObject;
      
      private var m_locations:Dictionary;
      
      private var m_chances:Vector.<DooberChance>;
      
      public function Doober(dooberXml:XML, actionObject:FarmGameObject)
      {
         var locationXml:XML = null;
         var location:DooberLocation = null;
         var chance:XML = null;
         var dooberChance:DooberChance = null;
         super();
         this.m_actionName = Doober.getDooberActionNameFromConfig(dooberXml);
         if(null != actionObject)
         {
            this.m_actionObject = actionObject;
         }
         this.m_locations = new Dictionary();
         if(dooberXml.hasOwnProperty(XMLKeys.CHILD_LOCATIONS))
         {
            for each(locationXml in dooberXml.locations.location)
            {
               if(locationXml.hasOwnProperty(XMLKeys.ATTR_NAME))
               {
                  location = new DooberLocation(locationXml);
                  this.m_locations[location.getLocationName()] = location;
               }
            }
         }
         this.m_chances = new Vector.<DooberChance>();
         if(dooberXml.hasOwnProperty(XMLKeys.CHILD_CHANCES))
         {
            for each(chance in dooberXml.chances.chance)
            {
               dooberChance = new DooberChance(chance,this.m_actionObject);
               if(dooberChance.isAvailable())
               {
                  this.m_chances.push(dooberChance);
               }
            }
         }
      }
      
      public static function getDooberActionNameFromConfig(dooberXml:XML) : String
      {
         var result:String = "";
         if(dooberXml.hasOwnProperty(XMLKeys.ATTR_ACTION))
         {
            result = dooberXml[XMLKeys.ATTR_ACTION];
         }
         return result;
      }
      
      public function isAvailable() : Boolean
      {
         var isLocationUnlocked:Boolean = false;
         var location:DooberLocation = this.m_locations[Global.worldManager.currentWorldType] as DooberLocation;
         if(Boolean(location) && location.isAvailable())
         {
            isLocationUnlocked = true;
         }
         var result:Boolean = isLocationUnlocked;
         var dooberVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HOOBERS);
         if(dooberVariant == 2 || dooberVariant == 3)
         {
            result &&= DefconManager.defconLevel < NO_DOOBER_DEFCON_LEVEL;
         }
         return result;
      }
      
      public function getChances() : Vector.<DooberChance>
      {
         return this.m_chances;
      }
      
      public function getDooberActionName() : String
      {
         return this.m_actionName;
      }
   }
}

