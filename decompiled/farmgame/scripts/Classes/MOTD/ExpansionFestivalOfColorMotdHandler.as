package Classes.MOTD
{
   import Classes.ZItem.ExpansionData;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.FestivalOfColorManager;
   import Transactions.TSawSpecificMOTD;
   import flash.events.Event;
   
   public class ExpansionFestivalOfColorMotdHandler extends ExpansionEarlyAccessMotdHandler
   {
      
      private static const FESTIVAL_OF_COLOR_EARLY_ACCESS_TYPE:String = "FestivalOfColor";
      
      public function ExpansionFestivalOfColorMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD,addPopupToQueue);
      }
      
      override protected function get earlyAccessType() : String
      {
         return FESTIVAL_OF_COLOR_EARLY_ACCESS_TYPE;
      }
      
      override protected function acceptMOTD() : void
      {
         var expansionData:ExpansionData = null;
         var worldType:String = m_currentMOTD["worldType"];
         if(worldType)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(expansionData == null)
            {
               throw new Error("Invalid expansion MOTD, could not find expansion definition for world: " + worldType);
            }
            closeMOTD();
            TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,false));
            if(Global.worldManager.isWorldSwapStable)
            {
               if(Global.worldManager.currentWorldType != worldType && Global.worldManager.hasUnlockedWorld(worldType))
               {
                  Global.worldManager.swapFarm(worldType,true);
                  Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.OpenFestivalOfColorWindow);
               }
               else if(Global.worldManager.currentWorldType == worldType)
               {
                  this.OpenFestivalOfColorWindow(null);
               }
            }
         }
      }
      
      public function OpenFestivalOfColorWindow(e:Event) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.OpenFestivalOfColorWindow);
         FestivalOfColorManager.getInstance().showHUDWindow();
      }
   }
}

