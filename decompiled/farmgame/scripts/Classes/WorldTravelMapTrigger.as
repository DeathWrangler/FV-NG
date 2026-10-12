package Classes
{
   import Managers.WorldStatManager;
   
   public class WorldTravelMapTrigger extends MapTrigger
   {
      
      private var m_worldType:String = "";
      
      private var m_instantTravel:Boolean = false;
      
      private var m_isTravellingToStaticWorld:Boolean = false;
      
      public function WorldTravelMapTrigger(itemName:String, stateToSet:String = "static")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         if(xmlData.hasOwnProperty("world"))
         {
            this.m_worldType = xmlData.world;
         }
         if(xmlData.hasOwnProperty("instantTravel"))
         {
            this.m_instantTravel = xmlData.instantTravel;
         }
         if(xmlData.hasOwnProperty("staticWorld"))
         {
            this.m_isTravellingToStaticWorld = xmlData.staticWorld;
         }
      }
      
      override public function onClick() : void
      {
         if(this.m_isTravellingToStaticWorld)
         {
            Global.worldManager.visitStaticFarm(this.m_worldType);
         }
         else if(Global.worldManager.hasUnlockedWorld(this.m_worldType))
         {
            if(this.m_instantTravel)
            {
               Global.worldManager.swapFarm(this.m_worldType,false);
            }
            else
            {
               Global.worldManager.showTravelConfirmation(this.m_worldType);
            }
         }
         WorldStatManager.trackWorldTravelMapTriggerClick(Global.worldManager.currentWorldType,this.m_worldType);
      }
   }
}

